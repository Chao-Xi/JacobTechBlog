# 基于 Jenkins、Gitlab、Harbor、Helm 和 Kubernetes 的 CI/CD(二, Pipeline) 

## Pipeline

### 第一个阶段：

**单元测试**，我们可以在这个阶段是运行一些**单元测试**或者**静态代码分析的脚本**，我们这里直接忽略。

### 第二个阶段：

**代码编译打包**，我们可以看到我们是在一个`maven`的容器中来执行的，所以我们只需要在**该容器中获取到代码**，然后**在代码目录下面执行 `maven` 打包命令即可**，如下所示：

```
 stage('代码编译打包') {
    try {
      container('maven') {
        echo "2. 代码编译打包阶段"
        sh "mvn clean package -Dmaven.test.skip=true"
      }
    } catch (exc) {
      println "构建失败 - ${currentBuild.fullDisplayName}"
      throw(exc)
    }
  }
```

### 第三个阶段：

1. 构建 `Docker` 镜像，
2. 要构建 `Docker` 镜像，就需要提供镜像的名称和 `tag`，
3. 要推送到 `Harbor` 仓库，就需要提供登录的用户名和密码，**所以我们这里使用到了`withCredentials`方法，在里面可以提供一个`credentialsId`为`dockerhub`的认证信息**，

**如下：**

```
container('构建 Docker 镜像') {
  withCredentials([[$class: 'UsernamePasswordMultiBinding',
    credentialsId: 'dockerhub',
    usernameVariable: 'DOCKER_HUB_USER',
    passwordVariable: 'DOCKER_HUB_PASSWORD']]) {
      container('docker') {
        echo "3. 构建 Docker 镜像阶段"
        sh """
          docker login ${dockerRegistryUrl} -u ${DOCKER_HUB_USER} -p ${DOCKER_HUB_PASSWORD}
          docker build -t ${image}:${imageTag} .
          docker push ${image}:${imageTag}
          """
      }
  }
}
```
其中 `${image}` 和 `${imageTag} `我们可以在上面定义成全局变量：

```
def imageTag = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
def dockerRegistryUrl = "registry.example.com"
def imageEndpoint = "course/polling-app-server"
def image = "${dockerRegistryUrl}/${imageEndpoint}"
```

`docker` 的用户名和密码信息则需要通过凭据来进行添加，进入 `jenkins 首页 -> 左侧菜单凭据 -> 添加凭据`，选择用户名和密码类型的，**其中 `ID` 一定要和上面的`credentialsId`的值保持一致**：

![Alt Image Text](images/5_1.png "Body image")

### 第四个阶段：

运行 `kubectl` 工具，其实在我们当前使用的流水线中是用不到 `kubectl` 工具的，那么为什么我们这里要使用呢？

这还不是因为我们暂时还没有去写应用的 `Helm Chart` 包吗？所以我们先去用原始的 `YAML` 文件来编写应用部署的资源清单文件，这也是我们写出 `Chart` 包前提，**因为只有知道了应用如何部署才可能知道 `Chart` 包如何编写，所以我们先编写应用部署资源清单。**

首先当然就是 `Deployment` 控制器了，如下所示：（`k8s.yaml`）

```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: polling-server
  namespace: course
  labels:
    app: polling-server
spec:
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: polling-server
    spec:
      restartPolicy: Always
      imagePullSecrets:
        - name: myreg
      containers:
      - image: <IMAGE>:<IMAGE_TAG>
        name: polling-server
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 8080
          name: api
        env:
        - name: DB_HOST
          value: mysql
        - name: DB_PORT
          value: "3306"
        - name: DB_NAME
          value: polling_app
        - name: DB_USER
          value: polling
        - name: DB_PASSWORD
          value: polling321

---

kind: Service
apiVersion: v1
metadata:
  name: polling-server
  namespace: course
spec:
  selector:
    app: polling-server
  type:  ClusterIP
  ports:
  - name: api-port
    port: 8080
    targetPort:  api

---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: mysql
  namespace: course
spec:
  template:
    metadata:
      labels:
        app: mysql
    spec:
      restartPolicy: Always
      containers:
      - name: mysql
        image: mysql:5.7
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 3306
          name: dbport
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: rootPassW0rd
        - name: MYSQL_DATABASE
          value: polling_app
        - name: MYSQL_USER
          value: polling
        - name: MYSQL_PASSWORD
          value: polling321
        volumeMounts:
        - name: db
          mountPath: /var/lib/mysql
      volumes:
      - name: db
        hostPath:
          path: /var/lib/mysql

---
kind: Service
apiVersion: v1
metadata:
  name: mysql
  namespace: course
spec:
  selector:
    app: mysql
  type:  ClusterIP
  ports:
  - name: dbport
    port: 3306
    targetPort: dbport
```

**可以看到我们上面的 `YAML` 文件中添加使用的镜像是用标签代替的：`<IMAGE>:<IMAGE_TAG>`，**

这是因为我们的镜像地址是动态的，下依赖我们在上一个阶段打包出来的镜像地址的，所以我们这里用标签代替，然后将标签替换成真正的值即可，另外为了保证应用的稳定性，**我们还在应用中添加了健康检查，所以需要在代码中添加一个健康检查的 Controller**：（`src/main/java/com/example/polls/controller/StatusController.java`）

```
package com.example.polls.controller;

import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/_status/healthz")
public class StatusController {

    @GetMapping
    public String healthCheck() {
        return "UP";
    }

}
```

最后就是环境变量了，还记得前面[我们更改了资源文件中数据库的配置吗](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_dev/k8s_gitlab/4K8S_gitlab_cicd.md#%E6%9C%8D%E5%8A%A1%E7%AB%AF)？（`src/main/resources/application.properties`）**因为要尽量通用**，我们在部署应用的时候很有可能已经有一个外部的数据库服务了，所以这个时候通过环境变量传入进来即可。

另外由于我们这里使用的是私有镜像仓库，所以需要在集群中提前创建一个对应的 `Secret` 对象：

```
$ kubectl create secret docker-registry myreg --docker-server=registry.example.com --docker-username=DOCKER_USER --docker-password=DOCKER_PASSWORD --docker-email=DOCKER_EMAIL --namespace course
```

**在代码根目录下面创建一个 `manifests` 的目录，用来存放上面的资源清单文件**，正常来说是不是我们只需要在镜像构建成功后，将上面的 `k8s.yaml` 文件中的镜像标签替换掉就 `OK`，所以这一步的动作如下：

### 第五阶段：

运行 `Helm` 工具，就是直接使用 `Helm` 来部署应用了，现在有了上面的基本的资源对象了，要创建 `Chart` 模板就相对容易了，`Chart` [模板仓库地址](polling-helm-master)，我们可以根据**`values.yaml`**文件来进行自定义安装，**模板中我们定义了可以指定使用外部数据库服务或者内部独立的数据库服务**，具体的我们可以去看模板中的定义。首先我们可以先使用这个模板在集群中来测试下。首先在集群中 `Clone` 上面的 `Chart` 模板：

```
$ git clone https://github.com/cnych/polling-helm.git
```

然后我们使用内部的数据库服务，新建一个 `custom.yaml` 文件来覆盖 `values.yaml` 文件中的值：

```
persistence:
  enabled: true
  persistentVolumeClaim:
    database:
      storageClass: "database"

database:
  type: internal
  internal:
    database: "polling"
    # 数据库用户
    username: "polling"
    # 数据库用户密码
    password: "polling321"
```

可以看到我们这里使用了一个名为`database`的 `StorgeClass` 对象，所以还得创建先创建这个资源对象：

```
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: database
provisioner: fuseim.pri/ifs
```

然后我们就可以在 `Chart` 根目录下面安装应用，执行下面的命令：

```
$ helm upgrade --install polling -f custom.yaml . --namespace course
Release "polling" does not exist. Installing it now.
NAME:   polling
LAST DEPLOYED: Sat May  4 23:31:42 2019
NAMESPACE: course
STATUS: DEPLOYED

RESOURCES:
==> v1/Pod(related)
NAME                                  READY  STATUS             RESTARTS  AGE
polling-polling-api-6b699478d6-lqwhw  0/1    ContainerCreating  0         0s
polling-polling-ui-587bbfb7b5-xr2ff   0/1    ContainerCreating  0         0s
polling-polling-database-0            0/1    Pending            0         0s

==> v1/Secret
NAME                      TYPE    DATA  AGE
polling-polling-database  Opaque  1     0s

==> v1/Service
NAME                      TYPE       CLUSTER-IP     EXTERNAL-IP  PORT(S)   AGE
polling-polling-api       ClusterIP  10.109.19.220  <none>       8080/TCP  0s
polling-polling-database  ClusterIP  10.98.136.190  <none>       3306/TCP  0s
polling-polling-ui        ClusterIP  10.108.170.43  <none>       80/TCP    0s

==> v1beta2/Deployment
NAME                 DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE
polling-polling-api  1        1        1           0          0s
polling-polling-ui   1        1        1           0          0s

==> v1/StatefulSet
NAME                      DESIRED  CURRENT  AGE
polling-polling-database  1        1        0s

==> v1beta1/Ingress
NAME                     HOSTS              ADDRESS  PORTS  AGE
polling-polling-ingress  ui.polling.domain  80       0s


NOTES:
1. Get the application URL by running these commands:
  http://ui.polling.domain

You have new mail in /var/spool/mail/root
```

### 注意我们这里安装也是使用的`helm upgrade`命令，这样有助于安装和更新的时候命令统一。

安装完成后，查看下 Pod 的运行状态：

```
$ kubectl get pods -n course
NAME                                   READY     STATUS    RESTARTS   AGE
polling-polling-api-6b699478d6-lqwhw   1/1       Running   0          3m
polling-polling-database-0             1/1       Running   0          3m
polling-polling-ui-587bbfb7b5-xr2ff    1/1       Running   0          3m
```

然后我们可以在本地`/etc/hosts`里面加上`http://ui.polling.domain`的的映射，这样我们就可以通过这个域名来访问我们安装的应用了，可以注册、登录、发表投票内容了：

![Alt Image Text](images/5_2.png "Body image")

这样我们就完成了使用 `Helm Chart` 安装应用的过程，但是现在我们使用的包还是直接使用的 `git` 仓库中的，平常我们正常安装的时候都是使用的 `Chart` 仓库中的包，所以我们需要将该 `Chart` 包上传到一个仓库中去，**比较幸运的是我们的 `Harbor` 也是支持 `Helm Chart` 包的。**

我们可以选择手动通过 `Harbor` 的` Dashboard`将 `Chart` 包进行上传，**也可以通过使用`Helm Push`插件**：

```
$ helm plugin install https://github.com/chartmuseum/helm-push
Downloading and installing helm-push v0.7.1 ...
https://github.com/chartmuseum/helm-push/releases/download/v0.7.1/helm-push_0.7.1_linux_amd64.tar.gz

Installed plugin: push
```

**当然我们需要首先将 `Harbor` 提供的仓库添加到 `helm repo` 中，由于是私有仓库，所以在添加的时候我们需要添加用户名和密码**：

```
$ helm repo add course https://registry.example.com/chartrepo/course --username=<harbor用户名> --password=<harbor密码>
"course" has been added to your repositories
```

**这里的 `repo` 的地址是`<Harbor URL>/chartrepo/<Harbor中项目名称>`**，`Harbor` 中每个项目是分开的 `repo`，如果不提供项目名称，则默认使用`library`这个项目。

> 需要注意的是如果你的 `Harbor` 是采用的自建的 `https` 证书，这里就需要提供 `ca `证书和私钥文件了，否则会出现证书校验失败的错误`x509: certificate signed by unknown authority`。

> 我们这里是通过`cert-manager`为 `Harbor` 提供的一个信任的 `https` 证书，所以没有指定 `ca` 证书相关的参数。

**Reference:**

1. [在 Kubernetes 在快速安装 Harbor](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_dev/harbor/2install_harbor_helm.md)
2. [Kubernetes Ingress 使用 Let's Encrypt 自动化 HTTPS](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_adv30_ingress_auto_https.md)


然后我们将上面的`polling-helm`这个 `Chart` 包上传到 `Harbor` 仓库中去：

```
$ helm push polling-helm course
Pushing polling-0.1.0.tgz to course...
Done.
```

这个时候我们登录的 `Harbor` 仓库中去，查看 `course` 这个项目下面的`Helm Charts`就可以发现多了一个 `polling` 的应用了：

![Alt Image Text](images/5_3.png "Body image")

我们也可以在右下角看到有添加仓库和安装 `Chart` 的相关命令。

到这里 `Helm` 相关的工作就准备好了。那么我们如何在 `Jenkins Pipeline` 中去使用 Helm 呢？

**我们可以回顾下，我们平时的一个 CI/CD 的流程：**

**开发代码 -> 提交代码 -> 触发镜像构建 -> 修改镜像tag -> 推送到镜像仓库中去 -> 然后更改 YAML 文件镜像版本 -> 使用 kubectl 工具更新应用。**

现在我们是不是直接使用 `Helm` 了，就不需要去手动更改 `YAML `文件了，也不需要使用 `kubectl` 工具来更新应用了，而是**只需要去覆盖下 `helm` 中的镜像版本，直接 `upgrade` 是不是就可以达到应用更新的结果了**。

我们可以去查看下 `chart` 包的 `values.yaml` 文件中关于 `api` 服务的定义：

```
api:
  image:
    repository: example/polling-api
    tag: 0.0.7
    pullPolicy: IfNotPresent
```

我们是不是只需要将上面关于 `ap`i 服务使用的镜像用我们这里 `Jenkins` 构建后的替换掉就可以了，这样我们更改上面的最后运行 `Helm`的阶段如下：

```
stage('运行 Helm') {
  container('helm') {
    echo "更新 polling 应用"
    sh """
      helm upgrade --install polling polling --set persistence.persistentVolumeClaim.database.storageClass=database --set database.type=internal --set database.internal.database=polling --set database.internal.username=polling --set database.internal.password=polling321 --set api.image.repository=${image} --set api.image.tag=${imageTag} --set imagePullSecrets[0].name=myreg --namespace course
    """
  }
}
```

当然我们可以将需要更改的值都放入一个 YAML 之中来进行修改，我们这里通过`--set`来覆盖对应的值，这样整个 `API` 服务的完整 `Jenkinsfile` 文件如下所示：

```
def label = "slave-${UUID.randomUUID().toString()}"

def helmLint(String chartDir) {
    println "校验 chart 模板"
    sh "helm lint ${chartDir}"
}

def helmInit() {
  println "初始化 helm client"
  sh "helm init --client-only --stable-repo-url https://mirror.azure.cn/kubernetes/charts/"
}

def helmRepo(Map args) {
  println "添加 course repo"
  sh "helm repo add --username ${args.username} --password ${args.password} course https://registry.qikqiak.com/chartrepo/course"

  println "更新 repo"
  sh "helm repo update"

  println "获取 Chart 包"
  sh """
    helm fetch course/polling
    tar -xzvf polling-0.1.0.tgz
    """
}

def helmDeploy(Map args) {
    helmInit()
    helmRepo(args)

    if (args.dry_run) {
        println "Debug 应用"
        sh "helm upgrade --dry-run --debug --install ${args.name} ${args.chartDir} --set persistence.persistentVolumeClaim.database.storageClass=database --set database.type=internal --set database.internal.database=polling --set database.internal.username=polling --set database.internal.password=polling321 --set api.image.repository=${args.image} --set api.image.tag=${args.tag} --set imagePullSecrets[0].name=myreg --namespace=${args.namespace}"
    } else {
        println "部署应用"
        sh "helm upgrade --install ${args.name} ${args.chartDir} --set persistence.persistentVolumeClaim.database.storageClass=database --set database.type=internal --set database.internal.database=polling --set database.internal.username=polling --set database.internal.password=polling321 --set api.image.repository=${args.image} --set api.image.tag=${args.tag} --set imagePullSecrets[0].name=myreg --namespace=${args.namespace}"
        echo "应用 ${args.name} 部署成功. 可以使用 helm status ${args.name} 查看应用状态"
    }
}


podTemplate(label: label, containers: [
  containerTemplate(name: 'maven', image: 'maven:3.6-alpine', command: 'cat', ttyEnabled: true),
  containerTemplate(name: 'docker', image: 'docker', command: 'cat', ttyEnabled: true),
  containerTemplate(name: 'helm', image: 'cnych/helm', command: 'cat', ttyEnabled: true)
], volumes: [
  hostPathVolume(mountPath: '/root/.m2', hostPath: '/var/run/m2'),
  hostPathVolume(mountPath: '/home/jenkins/.kube', hostPath: '/root/.kube'),
  hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock')
]) {
  node(label) {
    def myRepo = checkout scm
    def gitCommit = myRepo.GIT_COMMIT
    def gitBranch = myRepo.GIT_BRANCH
    def imageTag = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
    def dockerRegistryUrl = "registry.qikqiak.com"
    def imageEndpoint = "course/polling-api"
    def image = "${dockerRegistryUrl}/${imageEndpoint}"

    stage('单元测试') {
      echo "1.测试阶段"
    }
    stage('代码编译打包') {
      try {
        container('maven') {
          echo "2. 代码编译打包阶段"
          sh "mvn clean package -Dmaven.test.skip=true"
        }
      } catch (exc) {
        println "构建失败 - ${currentBuild.fullDisplayName}"
        throw(exc)
      }
    }
    container('构建 Docker 镜像') {
      withCredentials([[$class: 'UsernamePasswordMultiBinding',
        credentialsId: 'dockerhub',
        usernameVariable: 'DOCKER_HUB_USER',
        passwordVariable: 'DOCKER_HUB_PASSWORD']]) {
          container('docker') {
            echo "3. 构建 Docker 镜像阶段"
            sh """
              docker login ${dockerRegistryUrl} -u ${DOCKER_HUB_USER} -p ${DOCKER_HUB_PASSWORD}
              docker build -t ${image}:${imageTag} .
              docker push ${image}:${imageTag}
              """
          }
      }
    }
    stage('运行 Helm') {
      withCredentials([[$class: 'UsernamePasswordMultiBinding',
        credentialsId: 'dockerhub',
        usernameVariable: 'DOCKER_HUB_USER',
        passwordVariable: 'DOCKER_HUB_PASSWORD']]) {
          container('helm') {
            echo "4. [INFO] 开始 Helm 部署"
            helmDeploy(
                dry_run     : false,
                name        : "polling",
                chartDir    : "polling",
                namespace   : "course",
                tag         : "${imageTag}",
                image       : "${image}",
                username    : "${DOCKER_HUB_USER}",
                password    : "${DOCKER_HUB_PASSWORD}"
            )
            echo "[INFO] Helm 部署应用成功..."
          }
      }
    }
  }
}
```

由于我们没有将 `chart` 包放入到 `API` 服务的代码仓库中，这是因为我们这里使用的 `chart` 包涉及到两个应用，一个 API 服务，一个是前端展示的服务，所以我们这里是通过脚本里面去主动获取到 chart 包来进行安装的，如果 chart 包跟随代码仓库一起管理当然就要简单许多了。

现在我们去更新 `Jenkinsfile` 文件，然后提交到 `gitlab` 中，然后去观察下 `Jenkins` 中的构建是否成功，我们重点观察下 `Helm` 阶段：

![Alt Image Text](images/5_4.png "Body image")

当然我们还可以去做一些必要的判断工作，比如根据分支判断是否需要自动部署等等，同样也可以切换到 `Blue Occean` 界面查看构建结果。

![Alt Image Text](images/5_5.png "Body image")
