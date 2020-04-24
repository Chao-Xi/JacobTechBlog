# JAM Operation guide on ArgoCD

## 1. Introduction

ArgoCD is a declarative, GitOps continuous delivery tool for Kubernetes. We are using ArgoCD both for deployment ad rollout jam on k8s.

### 1.1 installation

* Install ArgoCD CLI

```
brew tap argoproj/tap
brew install argoproj/tap/argocd
```

* Install ArgoCD to cluster

```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v1.4.2/manifests/install.yaml
```

* Init ArgoCD password

By running

```
kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2
```

You can get the initial password for ArgoCD. Please note the password, we are going to change this.

```
$ kubectl port-forward svc/argocd-server -n argocd 8081:443
```

Then you can login and change password:

```
argocd login localhost:8081 #input the password you've noted. Default username is "admin"
argocd account update-password #Please change to "bobobo"
```

* Add projects to ArgoCD

```
argocd repo add https://github.tools.sap/.../jam-on-k8s --username argocd --password <password> # password is the access token for multi-cloud
```

```
helm install argocd-projects helm/argocd/projects -f instances/$JAM_INSTANCE-k8s.yaml --namespace argocd


helm install argocd-applications helm/argocd/applications -f instances/$JAM_INSTANCE-k8s.yaml --namespace argocd
```

Tips: in `instances/$JAM_INSTANCE-k8s.yaml`, Please keep `argocd.autoSync` as `false` until the whole deployment is done, to avoid accidental auto sync.


### 1.2 Concepts

We are using four main concepts of ArgoCD: **Repository**, **Project**, **Application**, and **Sync**.

**1.Repository**:

A repository means the blueprint for your apps. It could be Git repo or Helm repo. In the installation guide, we add a git repository of GitHub by running:

```
argocd repo add https://github.tools.sap/sap-zone/jam-on-k8s --username argocd --password <password>
```

And then ArgoCD can access the GitHub repo via an access token. It will get all of our helm charts and values from this repo.

**2.Project:**

ArgoCD could both deploy apps whin the same k8s cluster it been deployed at or an external cluster. So we can define multiple projects. Since we are only dealing with in-cluster apps, we use projects to distinguish deferent function modules. We have three projects defined: **`$JAM_INSTANCE`**: the project contains all of our business services related to jam; **logging**: the project contains EFK stack, and **arogocd**: contains both **ArgoCD project** and **ArgoCD application** definitions. So the definitions for applications are self-deployed.


**3.Application:**

An application equals a helm release. We have all the jam services application definitions in our repository. We can define the helm chart path, value path, sync policy, and target GitHub branch for a certain application.

**4.Sync:**

Sync means deployment. ArgoCD will sync with the target repository every couple minutes and use **helm to render templates**. If the rendered manifest is different from the online manifest, **ArgoCD will mark the application as "out of sync"**. If the application is configured as "auto sync", ArgoCD will automatically deploy the outdated applications, or we need to deploy it manually. 

ArgoCD will also convert helm hook to Argo hook, but not 100% precise. **The pre-install and post-install hooks will become pre-sync and post-sync hooks. So they will be executed every sync**.

## 2. Deployment guide

### 2.1 Branch cut and tag

The deployment of Jam is based on the branch cut, and the image tag is also aligned with the branch cut. 

Most of the time it works fine, but for the master branch, it's not aligned with image tag "lastStableBuild". **So during the deployment, we need to let code know that when deploying "lastStableBuild" means master.** 

For **`orchestrated-jam`**, it has a Jenkins job and a Github webhook to tag every commit of the master as "lastStableBuild". But for `github.tools.sap`, **it can't access our Jenkins system, so no webhook for it. The workaround is a polling Jenkins job**(https://jenkins-new.jam.only.sap/job/tag_tools_as_lastStableBuild/). It will tag the master of jam-on-k8s as "lastStableBuild". every 10 minutes on workday, you can also manually trigger this job.

**`H/10 * * * 1,2,3,4,5`**

**Pipeline**

```
node {
  cleanWs()
  withCredentials([string(credentialsId: 'tools_deployer', variable: 'ACCESS_TOKEN')]) {
    def token = "$ACCESS_TOKEN"
    git url: "https://${token}:x-oauth-basic@github.tools.sap/sap-zone/jam-on-k8s.git",
        branch: "master"
  }
  stage('Tag Build if needed') {
      sh 'git tag -d $(git tag -l)'
      sh 'git config --global user.email "jambot@sap.com"'
      sh 'git config --global user.name "jambot"'
      sh "git push origin :refs/tags/lastStableBuild"
      sh "git tag -f lastStableBuild"
      sh "git push origin lastStableBuild --tags"
  }
}
```

* `tools_deployer` jenkins global credentials
* `git tag -d <tag_name>`: delete a local Git tag
* `git tag -l` list all local git tags
* `git tag -f ` replace the tag if exists
* `git push origin lastStableBuild --tags` git push tag to remote server `--tags`


### 2.2 Deployment trigger

Since ArgoCD follows the concept of git-ops, all the deployments are triggered by Github commit. Let's say we are deploying **`dev701`** as **`lastStableBuild`**, we need to change the **`"jam.release"`** to  **`"lastStableBuild"`** and **`"jam.nonce"`** a different value for **`dev701-k8s.yaml`**. Then the applications which labeled as <apply-cd: "true"> will be marked as `"out of sync"` by ArgoCD. The application will be **automatically** or **manually** deployed, depends on the `"argocd.autoSync"` value of `$JAM_INSTANCE-k8s.yaml`. 

The commit can be manually pushed to Github or handled by Jenkins Job(`https://jenkins-new.jam.only.sap/job/deploy_multicloud_via_argo`).

**Change `nonce` to `data.argocd.nonce` in `argo_nonce.yaml`**

```
node {
  cleanWs()
  withCredentials([string(credentialsId: 'tools_deployer', variable: 'ACCESS_TOKEN')]) {
    def token = "$ACCESS_TOKEN"
    git url: "https://${token}:x-oauth-basic@github.tools.sap/sap-zone/jam-on-k8s.git",
        branch: "master"
  }
  stage("change nonce") {
      
      def filename = 'instances/argo_nonce.yaml'
      def data = readYaml file: filename
      def nonce = "${new Date().format( 'yyyyMMddHHmmss' )}"
      data.argocd.nonce = nonce
      sh "rm $filename"
      writeYaml file: filename, data: data
      sh "git add ."
      sh "git commit -m \"change argo nonce to ${nonce}\""
      sh "git push origin master"
  }
}
```


**Notice that**: If you are going to deploy a cluster as release other than "**lastStableBuild**",**you need to always do it via Jenkins Job.** Because the job will commit the change to the target branch and then **`cherry-pick` to the master branch.** 

The value file of the target cluster should keep the same for the master and target branch, or the cherry-pick will fail. The reason why we are doing this is: 

**the application argocd-application is targeted at master, but all other applications are targeted at the target release branch.** If we point argocd-application to the target branch, it will be very hard to switch branch(if we need to switch branch from R538 to R539, we need to commit "jam.release" as R539 both for branch R538 and R539). So we chose to track all of the branch status at master.

If the value of `"argocd.dailyBuild"` of  `$JAM_INSTANCE-k8s.yaml` is **true**, the target cluster will subscribe to a value named `"argocd.nonce"`. It will be changed every day at 0:00am UTC. 

Jenkins Job：`https://jenkins-new.jam.only.sap/job/daily_deployment_for_multicloud/`

```
node {
  cleanWs()
  withCredentials([string(credentialsId: 'tools_deployer', variable: 'ACCESS_TOKEN')]) {
    def token = "$ACCESS_TOKEN"
    git url: "https://${token}:x-oauth-basic@github.tools.sap/sap-zone/jam-on-k8s.git",
        branch: "master"
  }
  stage("change nonce") {
      
      def filename = 'instances/argo_nonce.yaml'
      def data = readYaml file: filename
      def nonce = "${new Date().format( 'yyyyMMddHHmmss' )}"
      data.argocd.nonce = nonce
      sh "rm $filename"
      writeYaml file: filename, data: data
      sh "git add ."
      sh "git commit -m \"change argo nonce to ${nonce}\""
      sh "git push origin master"
  }
}
```

