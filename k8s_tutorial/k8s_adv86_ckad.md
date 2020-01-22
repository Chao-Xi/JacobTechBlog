# CKAD 模拟考试

https://medium.com/bb-tutorials-and-thoughts/practice-enough-with-these-questions-for-the-ckad-exam-2f42d1228552

### CKAD 考试内容分为：

* 核心概念（13％）
* 多容器 Pod（10％）
* Pod 设计（20％）
* 状态持久性（8％）
* 配置（18％）
* 可观察性（18％）
* 服务和网络（13％）


## 核心概念

请根据以下概念进行练习：了解 Kubernetes API 原语，创建和配置基本 Pod。

### 1.列出集群中的所有命名空间

```
kubectl get namespaces
kubectl get ns
```

### 2.列出所有命名空间中的所有 Pod

```
kubectl get po --all-namespaces
```

### 3.列出特定命名空间中的所有 Pod

```
kubectl get po -n <namespace name>
```

### 4.列出特定命名空间中的所有 Service

```
kubectl get svc -n <namespace name>
```

### 5.用 json 路径表达式列出所有显示名称和命名空间的 Pod

> List all the pods showing name and namespace with a json path expression

```
kubectl get pods -o=jsonpath="{.items[*]['metadata.name', 'metadata.namespace']}"
```

### 6.在默认命名空间中创建一个 Nginx Pod，并验证 Pod 是否正在运行

> Create an nginx pod in a default namespace and verify the pod running

```
// creating a pod
kubectl run nginx --image=nginx --restart=Never
// List the pod
kubectl get po
```

### 7.使用 yaml 文件创建相同的 Nginx Pod

> Output the yaml file of the pod you just created without the cluster-specific information

```
// get the yaml file with --dry-run flag
kubectl run nginx --image=nginx --restart=Never --dry-run -o yaml > nginx-pod.yaml

// cat nginx-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}
// create a pod

kubectl create -f nginx-pod.yaml
```

### 8.输出刚创建的 Pod 的 yaml 文件

```
kubectl get po nginx -o yaml
```

### 9.输出刚创建的 `Pod` 的 `yaml` 文件，并且其中不包含特定于集群的信息

```
kubectl get po nginx -o yaml --export
```

### 10.获取刚刚创建的 Pod 的完整详细信息

```
kubectl describe pod nginx
```

### 11.删除刚创建的 Pod

```
kubectl delete po nginx
kubectl delete -f nginx-pod.yaml
```

### 12.强制删除刚创建的 Pod

> Delete the pod you just created without any delay (force delete)

```
kubectl delete po nginx --grace-period=0 --force
```

### 13.创建版本为 1.17.4 的 Nginx Pod，并将其暴露在端口 80 上

>  Create the nginx pod with version 1.17.4 and expose it on port 80

```
kubectl run nginx --image=nginx:1.17.4 --restart=Never --port=80
```

### 14.将刚创建的容器的镜像更改为 1.15-alpine，并验证该镜像是否已更新

> Change the Image version to `1.15-alpine` for the pod you just created and verify the image version is updated

```
kubectl set image pod/nginx nginx=nginx:1.15-alpine
kubectl describe po nginx
// another way it will open vi editor and change the version
kubeclt edit po nginx
kubectl describe po nginx
```

### 15.对于刚刚更新的 Pod，将镜像版本改回 1.17.1，并观察变化

> Change the Image version back to 1.17.1 for the pod you just updated and observe the changes

* Output watch event objects when `--watch` or `--watch-only` is used

```
kubectl set image pod/nginx nginx=nginx:1.17.1

kubectl describe po nginx

kubectl get po nginx -w # watch it
```

### 16.在不用 describe 命令的情况下检查镜像版本

> Check the Image version without the describe command

```
kubectl get po nginx -o jsonpath='{.spec.containers[].image}{"\n"}'
```

```
$ kubectl get po nginx -o custom-columns='DATA:spec.containers[0].image'
DATA
mongo
```

### 17.创建 Nginx Pod 并在 Pod 上执行简单的 shell

> Create the nginx pod and execute the simple shell on the pod

```
// creating a pod
kubectl run nginx --image=nginx --restart=Never
// exec into the pod
kubectl exec -it nginx /bin/sh
```

### 18.获取刚刚创建的 Pod 的 IP 地址



```
kubectl get po nginx -o wide
```

### 19.创建一个 `busybox Pod`，在创建它时运行命令 `ls` 并检查日志

>  Create a busybox pod and run command ls while creating it and check the logs

```
$ kubectl run busybox --image=busybox --restart=Never -- ls

$ kubectl logs busybox
bin
dev
etc
home
proc
root
sys
tmp
usr
var
```

### 20.如果 Pod 崩溃了，请检查 Pod 的先前日志

> If pod crashed check the previous logs of the pod

```
kubectl logs busybox -p
```

### 21.用命令 sleep 3600 创建一个 busybox Pod

> Create a busybox pod with command sleep 3600

```
kubectl run busybox --image=busybox --restart=Never -- /bin/sh -c "sleep 3600"
```

### 22.检查 busybox Pod 中 Nginx Pod 的连接

> Check the connection of the nginx pod from the busybox pod

```
kubectl get po nginx -o wide
// check the connection

kubectl exec -it busybox -- wget -o- <IP Address>


$ kubectl get po nginx -o wide
NAME    READY   STATUS    RESTARTS   AGE   IP           NODE             NOMINATED NODE   READINESS GATES
nginx   1/1     Running   0          60s   10.1.2.227   docker-desktop   <none>           <none>

$ kubectl run busybox --image=busybox --restart=Never -- /bin/sh -c "sleep 3600"
pod/busybox created

$ kubectl exec -it busybox -- wget -o- 10.1.2.227
Connecting to 10.1.2.227 (10.1.2.227:80)
saving to 'index.html'
index.html           100% |********************************|   612  0:00:00 ETA
'index.html' saved
```

### 23.创建一个能回显消息“How are you”的 busybox Pod，并手动将其删除

```
$ kubectl run busybox --image=nginx --restart=Never -it -- echo "How are you"
How are you

kubectl delete pod busybox
```

### 24.创建一个能回显消息“How are you”的 busybox Pod，并立即将其删除

```
// notice the --rm flag
$ kubectl run busybox --image=nginx --restart=Never -it --rm -- echo "How are you"
How are you
pod "busybox" deleted
```

### 25.创建一个 Nginx Pod 并列出具有不同复杂度（verbosity）的 Pod

> Create an nginx pod and list the pod with different levels of verbosity

```
// create a pod
kubectl run nginx --image=nginx --restart=Never --port=80

kubectl get po nginx --v=7
kubectl get po nginx --v=8
kubectl get po nginx --v=9
```

### 26.使用自定义列 `POD_NAME` 和 `POD_STATUS` 列出 Nginx Pod

> List the nginx pod with custom columns POD_NAME and POD_STATUS

```
kubectl get po -o=custom-columns="POD_NAME:.metadata.name, POD_STATUS:.status.containerStatuses[].state"
```

### 27.列出所有按名称排序的 Pod

>  List all the pods sorted by name

```
kubectl get pods --sort-by=.metadata.name
```

### 28.列出所有按创建时间排序的 Pod

> List all the pods sorted by created timestamp

```
kubectl get pods --sort-by=.metadata.creationTimestamp
```

## 多容器pod

请根据以下概念进行练习：了解多容器 Pod 的设计模式（例如 ambassador、adaptor、sidecar）。

### 29.用`“ls; sleep 3600;”“echo Hello World; sleep 3600;”`及`“echo this is the third container; sleep 3600”`三个命令创建一个包含三个 `busybox `容器的 Pod，并观察其状态

```
// first create single container pod with dry run flag
kubectl run busybox --image=busybox --restart=Never --dry-run -o yaml -- bin/sh -c "sleep 3600; ls" > multi-container.yaml

// edit the pod to following yaml and create it
kubectl create -f multi-container.yaml
```

```
piVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: busybox
  name: busybox
spec:
  containers:
  - args:
    - bin/sh
    - -c
    - ls; sleep 3600
    image: busybox
    name: busybox1
    resources: {}
  - args:
    - bin/sh
    - -c
    - echo Hello world; sleep 3600
    image: busybox
    name: busybox2
    resources: {}
  - args:
    - bin/sh
    - -c
    - echo this is third container; sleep 3600
    image: busybox
    name: busybox3
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}
```

### 30.检查刚创建的每个容器的日志

> Check the logs of each container that you just created

```
kubectl logs busybox -c busybox1
kubectl logs busybox -c busybox2
kubectl logs busybox -c busybox3
```

### 31.检查第二个容器 busybox2 的先前日志（如果有）

> Check the previous logs of the second container busybox2 if any

```
kubectl logs busybox -c busybox2 --previous
```

### 32.在上述容器的第三个容器 busybox3 中运行命令 ls

> Run command ls in the third container busybox3 of the above pod

```
kubectl exec busybox -c busybox3 -- ls
```

### 33.显示以上容器的 `metrics`，将其放入 `file.log` 中并进行验证

> Show metrics of the above pod containers and puts them into the file.log and verify

```
kubectl top pod busybox --containers
// putting them into file
kubectl top pod busybox --containers > file.log
cat file.log
```

### 34.用主容器 `busybox` 创建一个` Pod`，并执行`“while true; do echo ‘Hi I am from Main container’ >> /var/log/index.html; sleep 5; done”`，并带有暴露在端口 `80` 上的 `Nginx` 镜像的 `sidecar `容器。用 `emptyDir Volume` 将该卷安装在 `/var/log` 路径（用于 busybox）和` /usr/share/nginx/html `路径（用于nginx容器）。验证两个容器都在运行。



```
// create an initial yaml file with this
kubectl run multi-cont-pod --image=busbox --restart=Never --dry-run -o yaml > multi-container.yaml

// edit the yml as below and create it
kubectl create -f multi-container.yaml

kubectl get po multi-cont-pod
```
```
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: multi-cont-pod
  name: multi-cont-pod
spec:
  volumes:
  - name: var-logs
    emptyDir: {}
  containers:
  - image: busybox
    command: ["/bin/sh"]
    args: ["-c", "while true; do echo 'Hi I am from Main container' >> /var/log/index.html; sleep 5;done"]
    name: main-container
    resources: {}
    volumeMounts:
    - name: var-logs
      mountPath: /var/log
  - image: nginx
    name: sidecar-container
    resources: {}
    ports:
      - containerPort: 80
    volumeMounts:
    - name: var-logs
      mountPath: /usr/share/nginx/html
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}
```

### 35. 进入两个容器并验证 `main.txt` 是否存在，并用 `curl localhost `从 `sidecar` 容器中查询 `main.txt`

> Exec into both containers and verify that main.txt exist and query the `main.txt` from sidecar container with `curl localhost`

```
// exec into main container
kubectl exec -it  multi-cont-pod -c main-container -- sh
cat /var/log/main.txt

// exec into sidecar container
kubectl exec -it  multi-cont-pod -c sidecar-container -- sh

cat /usr/share/nginx/html/index.html

// install curl and get default page
kubectl exec -it  multi-cont-pod -c sidecar-container -- sh
# apt-get update && apt-get install -y curl
# curl localhost
```

## Pod 设计

请根据以下概念进行练习：了解如何使用 `Labels`、`Selectors` 和 `Annotations`，了解部署以及如何执行滚动更新，了解部署以及如何执行回滚，了解 `Jobs` 和` CronJobs`。

### 36.获取带有标签信息的 Pod

```
kubectl get pods --show-labels
```

### 37.创建 5 个 Nginx Pod，其中两个标签为 env = prod，另外三个标签为 `env = dev`

> Create 5 nginx pods in which two of them is labeled `env=prod` and three of them is labeled `env=dev`

```
kubectl run nginx-dev1 --image=nginx --restart=Never --labels=env=dev
kubectl run nginx-dev2 --image=nginx --restart=Never --labels=env=dev
kubectl run nginx-dev3 --image=nginx --restart=Never --labels=env=dev
kubectl run nginx-prod1 --image=nginx --restart=Never --labels=env=prod
kubectl run nginx-prod2 --image=nginx --restart=Never --labels=env=prod
```

### 38.确认所有 Pod 都使用正确的标签创建

```
kubeclt get pods --show-labels
```

### 39.获得带有标签 env = dev 的 Pod

```
kubectl get pods -l env=dev
```

### 40.获得带标签 env = dev 的 Pod 并输出标签

```
kubectl get pods -l env=dev --show-labels
```

### 41.获得带有标签 env = prod 的 Pod

```
kubectl get pods -l env=prod
```

### 42.获得带标签 env = prod 的 Pod 并输出标签

```
kubectl get pods -l env=prod --show-labels
```

### 43.获取带有标签 env 的 Pod

> Get the pods with `label env`

```
kubectl get pods -L env
```

### 44.获得带标签 `env = dev、env = prod` 的 Pod

> Get the pods with labels `env=dev` and `env=prod`

```
kubectl get pods -l 'env in (dev,prod)'
```

### 45.获取带有标签 `env = dev` 和 `env = prod` 的 Pod 并输出标签

> Get the pods with labels `env=dev` and `env=prod` and output the labels as well

```
kubectl get pods -l 'env in (dev,prod)' --show-labels
```

### 46.将其中一个容器的标签更改为 `env = uat` 并列出所有要验证的容器

> . Change the label for one of the pod to env=uat and list all the pods to verify

```
kubectl label pod/nginx-dev3 env=uat --overwrite
kubectl get pods --show-labels
```

### 47.删除刚才创建的 Pod 标签，并确认所有标签均已删除

> Remove the labels for the pods that we created now and verify all the labels are removed

```
kubectl label pod nginx-dev{1..3} env-
kubectl label pod nginx-prod{1..2} env-
kubectl get po --show-labels
```

### 48.为所有 Pod 添加标签 `app = nginx` 并验证

>  Let’s add the label `app=nginx` for all the pods and verify

```
kubectl label pod nginx-dev{1..3} app=nginx
kubectl label pod nginx-prod{1..2} app=nginx
kubectl get po --show-labels
```

### 49.获取所有带有标签的节点（如果使用 minikube，则只会获得主节点）

```
kubectl get nodes --show-labels
```

### 50.标记节点（如果正在使用，则为 minikube）`nodeName = nginxnode`

> Label the node (minikube if you are using) `nodeName=nginxnode`

```
kubectl label node minikube nodeName=nginxnode
```

### 51.建一个标签为 `nodeName = nginxnode` 的 Pod 并将其部署在此节点上

> Create a Pod that will be deployed on this node with the label `nodeName=nginxnode`

```
kubectl run nginx --image=nginx --restart=Never --dry-run -o yaml > pod.yaml

// add the nodeSelector like below and create the pod
kubectl create -f pod.yaml
```
```
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  nodeSelector:
    nodeName: nginxnode  
  containers:
  - image: nginx
    name: nginx
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}
```

### 52.使用节点选择器验证已调度的 Pod

> Verify the pod that it is scheduled with the node selector

```
kubectl describe po nginx | grep Node-Selectors
```

### 53.验证我们刚刚创建的 `Pod Nginx` 是否具有 `nodeName=nginxnode `这个标签

```
kubectl describe po nginx | grep Labels
```

### 54.用 `name=webapp` 注释 Pod

> Annotate the pods with `name=webapp`

```
kubectl annotate pod nginx-dev{1..3} name=webapp
kubectl annotate pod nginx-prod{1..2} name=webapp
```

### 55.验证已正确注释的 Pod

> Verify the pods that have been annotated correctly

```
kubectl describe po nginx-dev{1..3} | grep -i annotations
kubectl describe po nginx-prod{1..2} | grep -i annotations
```

### 56.删除 Pod 上的注释并验证

> Remove the annotations on the pods and verify

```
kubectl annotate pod nginx-dev{1..3} name-
kubectl annotate pod nginx-prod{1..2} name-
kubectl describe po nginx-dev{1..3} | grep -i annotations
kubectl describe po nginx-prod{1..2} | grep -i annotation
```

### 57.删除到目前为止我们创建的所有 Pod

```
kubectl delete po --all
```

### 58.创建一个名为 `webapp` 的 `Deployment`，它带有 `5` 个副本的镜像 `Nginx`

```
kubectl create deploy webapp --image=nginx --dry-run -o yaml > webapp.yaml

// change the replicas to 5 in the yaml and create it
kubectl create -f webapp.yaml
```

```
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: webapp
  name: webapp
spec:
  replicas: 5
  selector:
    matchLabels:
      app: webapp
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: webapp
    spec:
      containers:
      - image: nginx
        name: nginx
        resources: {}
status: {}
```

### 59.用标签获取我们刚刚创建的 Deployment


```
kubectl get deploy webapp --show-labels
```

### 60.导出该 `Deployment` 的 `yaml `文件

```
kubectl get deploy webapp -o yaml
```

### 61.获取该 Deployment 的 Pod

```
// get the label of the deployment
kubectl get deploy --show-labels

// get the pods with that label
kubectl get pods -l app=webapp
```

### 62.将该 Deployment 从 5 个副本扩展到 20 个副本并验证

```
kubectl scale deploy webapp --replicas=20
kubectl get po -l app=webapp
```

### 63.获取该 Deployment 的 rollout 状态

```
kubectl rollout status deploy webapp
```

### 64.获取使用该 Deployment 创建的副本集

```
kubectl get rs -l app=webapp
```

### 65.获取该 Deployment 的副本集和 Pod 的 yaml


```
kubectl get rs -l app=webapp -o yaml
kubectl get po -l app=webapp -o yaml
```

### 66.删除刚创建的 Deployment，并查看所有 Pod 是否已被删除

> Delete the deployment you just created and watch all the pods are also being deleted

```
kubectl delete deploy webapp
kubectl get po -l app=webapp -w
```

### 67.使用镜像 `nginx：1.17.1 ` 和容器端口 `80 `创建 `webapp Deployment`，并验证镜像版本

>  Create a deployment of webapp with image `nginx:1.17.1` with container `port 80` and verify the image version

```
kubectl create deploy webapp --image=nginx:1.17.1 --dry-run -o yaml > webapp.yaml

// add the port section and create the deployment
kubectl create -f webapp.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: webapp
  name: webapp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: webapp
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: webapp
    spec:
      containers:
      - image: nginx:1.17.1
        name: nginx
        ports:
        - containerPort: 80
        resources: {}
status: {}


// verify
kubectl describe deploy webapp | grep Image
```

### 68.使用镜像版本 1.17.4 更新 Deployment 并验证

> Update the deployment with the image version `1.17.4` and verify

```
kubectl set image deploy/webapp nginx=nginx:1.17.4
kubectl describe deploy webapp | grep Image
```

### 69.检查 rollout 历史记录，并确保更新后一切正常

> Check the rollout history and make sure everything is ok after the update

```
kubectl rollout history deploy webapp
kubectl get deploy webapp --show-labels
kubectl get rs -l app=webapp
kubectl get po -l app=webapp
```

### 70.撤消之前使用版本 1.17.1 的 Deployment，并验证镜像是否还有老版本

> Undo the deployment to the previous version 1.17.1 and verify Image has the previous version

```
kubectl rollout undo deploy webapp
kubectl describe deploy webapp | grep Image
```

### 71.使用镜像版本 1.16.1 更新 Deployment，并验证镜像、检查 rollout 历史记录

> Update the deployment with the image version 1.16.1 and verify the image and also check the rollout history

```
kubectl set image deploy/webapp nginx=nginx:1.16.1
kubectl describe deploy webapp | grep Image
kubectl rollout history deploy webapp
```

### 72.将 Deployment 更新到镜像 1.17.1 并确认一切正常

>  Update the deployment to the Image 1.17.1 and verify everything is ok

```
kubectl rollout undo deploy webapp --to-revision=3
kubectl describe deploy webapp | grep Image
kubectl rollout status deploy webapp
```

### 73.使用错误的镜像版本 1.100 更新 Deployment，并验证有问题

> Update the deployment with the wrong image version 1.100 and verify something is wrong with the deployment

```
kubectl set image deploy/webapp nginx=nginx:1.100
kubectl rollout status deploy webapp (still pending state)
kubectl get pods (ImagePullErr)
```

### 74.撤消使用先前版本的 Deployment，并确认一切正常

> Undo the deployment with the previous version and verify everything is Ok

```
kubectl rollout undo deploy webapp
kubectl rollout status deploy webapp
kubectl get pods
```

### 75.检查该 Deployment 的特定修订版本的历史记录

> Check the history of the specific revision of that deployment

```
kubectl rollout history deploy webapp --revision=7
```

### 76.暂停 Deployment rollout

> Pause the rollout of the deployment

```
kubectl rollout pause deploy webapp
```

### 77.用最新版本的镜像更新 Deployment，并检查历史记录

> Update the deployment with the image version latest and check the history and verify nothing is going on

```
kubectl set image deploy/webapp nginx=nginx:latest
kubectl rollout history deploy webapp (No new revision)
```

### 78.恢复 Deployment rollout

```
kubectl rollout resume deploy webapp
```

### 79.检查 rollout 历史记录，确保是最新版本

```
kubectl rollout history deploy webapp
kubectl rollout history deploy webapp --revision=9
```

### 80.将自动伸缩应用到该 Deployment 中，最少副本数为 10，最大副本数为 20，目标 CPU 利用率 85%，并验证 hpa 已创建，将副本数从 1 个增加到 10 个

> Apply the autoscaling to this deployment with minimum 10 and maximum 20 replicas and target CPU of 85% and verify hpa is created and replicas are increased to 10 from 1

```
kubectl autoscale deploy webapp --min=10 --max=20 --cpu-percent=85
kubectl get hpa
kubectl get pod -l app=webapp
```

### 81.通过删除刚刚创建的 Deployment 和 hpa 来清理集群

```
kubectl delete deploy webapp
kubectl delete hpa webapp
```

### 82.用镜像 node 创建一个 Job，并验证是否有对应的 Pod 创建

```
kubectl create job nodeversion --image=node -- node -v
kubectl get job -w
kubectl get pod
```

### 83.获取刚刚创建的 Job 的日志

```
kubectl logs <pod name> // created from the job
```

### 84.用镜像 `busybox` 输出 `Job` 的 `yaml `文件，并回显“Hello I am from job”

```
kubectl create job hello-job --image=busybox --dry-run -o yaml -- echo "Hello I am from job"
```

### 85.将上面的 yaml 文件复制到 hello-job.yaml 文件并创建 Job

```
kubectl create job hello-job --image=busybox --dry-run -o yaml -- echo "Hello I am from job" > hello-job.yaml
kubectl create -f hello-job.yaml
```

### 86.验证 Job 并创建关联的容器，检查日志

```
kubectl get job
kubectl get po
kubectl logs hello-job-*
```

### 87.删除我们刚刚创建的 Job

```
kubectl delete job hello-job
```

### 88.创建一个相同的 Job，并使它一个接一个地运行 10 次

> Create the same job and make it run 10 times one after one


```
kubectl create job hello-job --image=busybox --dry-run -o yaml -- echo "Hello I am from job" > hello-job.yaml

// edit the yaml file to add completions: 10
apiVersion: batch/v1
kind: Job
metadata:
  creationTimestamp: null
  name: hello-job
spec:
  completions: 10
  template:
    metadata:
      creationTimestamp: null
    spec:
      containers:
      - command:
        - echo
        - Hello I am from job
        image: busybox
        name: hello-job
        resources: {}
      restartPolicy: Never
status: {}

kubectl create -f hello-job.yaml
```

### 89.运行 10 次，确认已创建 10 个 Pod，并在完成后删除它们



```
kubectl get job -w
kubectl get po
kubectl delete job hello-job
```

### 90.创建相同的 Job 并使它并行运行 10 次

> Create the same job and make it run 10 times parallel

```
kubectl create job hello-job --image=busybox --dry-run -o yaml -- echo "Hello I am from job" > hello-job.yaml

// edit the yaml file to add parallelism: 10
apiVersion: batch/v1
kind: Job
metadata:
  creationTimestamp: null
  name: hello-job
spec:
  parallelism: 10
  template:
    metadata:
      creationTimestamp: null
    spec:
      containers:
      - command:
        - echo
        - Hello I am from job
        image: busybox
        name: hello-job
        resources: {}
      restartPolicy: Never
status: {}

kubectl create -f hello-job.yaml
```

### 91.并行运行 10 次，确认已创建 10 个 Pod，并在完成后将其删除

> Watch the job that runs 10 times parallelly and verify 10 pods are created and delete those after it’s completed

```
kubectl get job -w
kubectl get po
kubectl delete job hello-job
```

### 92.创建一个带有 busybox 镜像的 Cronjob，每分钟打印一次来自 Kubernetes 集群消息的日期和 hello

> Create a Cronjob with busybox image that prints date and hello from kubernetes cluster message for every minute

```
kubectl create cronjob date-job --image=busybox --schedule="*/1 * * * *" -- bin/sh -c "date; echo Hello from kubernetes cluster"
```

### 93.输出上述 cronjob 的 yaml 文件

```
kubectl get cj date-job -o yaml
```

### 94.验证 cronJob 为每分钟运行创建一个单独的 Job 和 Pod，并验证 Pod 的日志

```
kubectl get job
kubectl get po
kubectl logs date-job-<jobid>-<pod>
```

### 95.删除 cronJob，并验证所有关联的 Job 和 Pod 也都被删除

```
kubectl delete cj date-job
// verify pods and jobs
kubectl get po
kubectl get job
```

## 状态持久性

根据概念练习问题：了解存储的持久卷声明。

### 96.列出集群中的持久卷


```
kubectl get pv
```

### 97.创建一个名为 `task-pv-volume` 的` PersistentVolume`，其 `storgeClassName` 为 `manual`，`storage` 为 `10Gi`，`accessModes `为 `ReadWriteOnce`，`hostPath` 为 `/mnt/data`


> Create a hostPath PersistentVolume named task-pv-volume with storage `10Gi`, access modes `ReadWriteOnce`, `storageClassName manual`, and volume at `/mnt/data` and verify

```
kubectl create -f task-pv-volume.yaml
kubectl get pv
```

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: task-pv-volume
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data"
 ```
 
### 98.创建一个存储至少 `3Gi`、访问模式为 `ReadWriteOnce` 的 `PersistentVolumeClaim`，并确认它的状态是否是绑定的
 
 ```
kubectl create -f task-pv-claim.yaml
kubectl get pvc
```
```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: task-pv-claim
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 3Gi
```

### 99.删除我们刚刚创建的持久卷和 `PersistentVolumeClaim`

```
kubectl delete pvc task-pv-claim
kubectl delete pv task-pv-volume
```

### 100.使用镜像 Redis 创建 Pod，并配置一个在 Pod 生命周期内可持续使用的卷

```
// emptyDir is the volume that lasts for the life of the pod
kubectl create -f redis-storage.yaml
```
```

apiVersion: v1
kind: Pod
metadata:
  name: redis
spec:
  containers:
  - name: redis
    image: redis
    volumeMounts:
    - name: redis-storage
      mountPath: /data/redis
  volumes:
  - name: redis-storage
    emptyDir: {}
```

### 101.在上面的 Pod 中执行操作，并在 `/data/redis` 路径中创建一个名为 `file.txt` 的文件，其文本为`“This is the file”`，然后打开另一个选项卡，再次使用同一 `Pod` 执行，并验证文件是否在同一路径中

```
// first terminal
kubectl exec -it redis-storage /bin/sh
cd /data/redis
echo 'This is called the file' > file.txt
//open another tab
kubectl exec -it redis-storage /bin/sh
cat /data/redis/file.txt
```

### 102.删除上面的 Pod，然后从相同的 `yaml` 文件再次创建，并验证路径 `/data/redis` 中是否没有 file.txt

```
kubectl delete pod redis
kubectl create -f redis-storage.yaml
kubectl exec -it redis-storage /bin/sh
cat /data/redis/file.txt // file doesn't exist
```

### 103.创建一个名为 `task-pv-volume` 的 `PersistentVolume`，其 `storgeClassName` 为` manual`，`storage` 为 `10Gi`，`accessModes` 为 `ReadWriteOnce`，`hostPath` 为 `/mnt/data`；

并创建一个存储至少 3Gi、访问模式为 ReadWriteOnce 的 PersistentVolumeClaim，并确认它的状态是否是绑定的

```
kubectl create -f task-pv-volume.yaml
kubectl create -f task-pv-claim.yaml
kubectl get pv
kubectl get pvc
```

### 104.用容器端口` 80` 和 `PersistentVolumeClaim task-pv-claim `创建一个 Nginx 容器，且具有路径`“/usr/share/nginx/html”`

```
kubectl create -f task-pv-pod.yaml

apiVersion: v1
kind: Pod
metadata:
  name: task-pv-pod
spec:
  volumes:
    - name: task-pv-storage
      persistentVolumeClaim:
        claimName: task-pv-claim
  containers:
    - name: task-pv-container
      image: nginx
      ports:
        - containerPort: 80
          name: "http-server"
      volumeMounts:
        - mountPath: "/usr/share/nginx/html"
          name: task-pv-storage
```

## Configuration (18%)


Practice questions based on these concepts

* Understand ConfigMaps
* Understand SecurityContexts
* Define an application’s resource requirements
* Create & Consume Secrets
* Understand ServiceAccounts

### 105. List all the configmaps in the cluster


```
kubectl get cm

kubectl get configmap
```

### 106. Create a configmap called myconfigmap with _literal_ value `appname=myapp`

```
kubectl create cm myconfigmap --from-literal=appname=myapp
```

### 107. Verify the configmap we just created has this data

```
// you will see under data
kubectl get cm -o yaml
         or
kubectl describe cm
```

## 108. delete the configmap myconfigmap we just created

```
kubectl delete cm myconfigmap
```

### 109. Create a file called `config.txt` with two `values key1=value1` and `key2=value2 `and verify the file

```
cat >> config.txt << EOF
key1=value1
key2=value2
EOF

cat config.txt
```

### 110. Create a configmap named keyvalcfgmap and read data from the file `config.txt` and verify that configmap is created correctly

```
kubectl create cm keyvalcfgmap --from-file=config.txt

kubectl get cm keyvalcfgmap -o yaml
```

### 111. Create an nginx pod and load environment values from the above configmap keyvalcfgmap and exec into the pod and verify the environment variables and delete the pod

```
// first run this command to save the pod yml
kubectl run nginx --image=nginx --restart=Never --dry-run -o yaml > nginx-pod.yml

// edit the yml to below file and create
kubectl create -f nginx-pod.yml

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    resources: {}
    envFrom:
    - configMapRef:
        name: keyvalcfgmap
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}

// verify
kubectl exec -it nginx -- env

kubectl delete po nginx
```

### 112. Create an env file `file.env` with `var1=val1` and create a configmap envcfgmap from this env file and verify the configmap

```
echo var1=val1 > file.env
cat file.env

kubectl create cm envcfgmap --from-env-file=file.env

kubectl get cm envcfgmap -o yaml --export
```

### 113. Create an nginx pod and load environment values from the above configmap `envcfgmap` and exec into the pod and verify the environment variables and delete the pod

```
// first run this command to save the pod yml
kubectl run nginx --image=nginx --restart=Never --dry-run -o yaml > nginx-pod.yml

// edit the yml to below file and create
kubectl create -f nginx-pod.yml

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    resources: {}
    env:
    - name: ENVIRONMENT
      valueFrom:
        configMapKeyRef:
          name: envcfgmap
          key: var1
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}

// verify
kubectl exec -it nginx -- env

kubectl delete po nginx
```


### 114. Create a configmap called cfgvolume with values `var1=val1,` `var2=val2` and create an nginx pod with volume nginx-volume which reads data from this configmap `cfgvolume` and put it on the path `/etc/cfg`

```
// first create a configmap cfgvolume
kubectl create cm cfgvolume --from-literal=var1=val1 --from-literal=var2=val2

// verify the configmap
kubectl describe cm cfgvolume

// create the config map 
kubectl create -f nginx-volume.yml

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  volumes:
  - name: nginx-volume
    configMap:
      name: cfgvolume
  containers:
  - image: nginx
    name: nginx
    resources: {}
    volumeMounts:
    - name: nginx-volume
      mountPath: /etc/cfg
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}

// exec into the pod
kubectl exec -it nginx -- /bin/sh

// check the path
cd /etc/cfg
ls
```

### 115. Create a pod called secbusybox with the image busybox which executes command sleep 3600 and makes sure any Containers in the Pod, all processes run with `user ID 1000` and with `group id 2000 `and verify.

```
// create yml file with dry-run
kubectl run secbusybox --image=busybox --restart=Never --dry-run -o yaml -- /bin/sh -c "sleep 3600;" > busybox.yml

// edit the pod like below and create
kubectl create -f busybox.yml

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: secbusybox
  name: secbusybox
spec:
  securityContext: # add security context
    runAsUser: 1000
    runAsGroup: 2000
  containers:
  - args:
    - /bin/sh
    - -c
    - sleep 3600;
    image: busybox
    name: secbusybox
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}

// verify
kubectl exec -it secbusybox -- sh
id // it will show the id and group
```

### 116. Create the same pod as above this time set the securityContext for the container as well and verify that the securityContext of container overrides the Pod level securityContext.

```
// create yml file with dry-run
kubectl run secbusybox --image=busybox --restart=Never --dry-run -o yaml -- /bin/sh -c "sleep 3600;" > busybox.yml

// edit the pod like below and create
kubectl create -f busybox.yml

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: secbusybox
  name: secbusybox
spec:
  securityContext:
    runAsUser: 1000
  containers:
  - args:
    - /bin/sh
    - -c
    - sleep 3600;
    image: busybox
    securityContext:
      runAsUser: 2000
    name: secbusybox
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}

// verify
kubectl exec -it secbusybox -- sh
id // you can see container securityContext overides the Pod level
```

### 117. Create pod with an nginx image and configure the pod with capabilities `NET_ADMIN` and `SYS_TIME` verify the capabilities

```
// create the yaml file
kubectl run nginx --image=nginx --restart=Never --dry-run -o yaml > nginx.yml

// edit as below and create pod
kubectl create -f nginx.yml

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    securityContext:
      capabilities:
        add: ["SYS_TIME", "NET_ADMIN"]
    name: nginx
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}


// exec and verify
kubectl exec -it nginx -- sh
cd /proc/1
cat status

// you should see these values
CapPrm: 00000000aa0435fb
CapEff: 00000000aa0435fb
```

### 118. Create a Pod nginx and specify a memory request and a memory limit of 100Mi and 200Mi respectively.

```
// create a yml file
kubectl run nginx --image=nginx --restart=Never --dry-run -o yaml > nginx.yml

// add the resources section and create
kubectl create -f nginx.yml

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    resources: 
      requests:
        memory: "100Mi"
      limits:
        memory: "200Mi"
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}

// verify
kubectl top pod
```

### 119. Create a Pod nginx and specify a CPU request and a CPU limit of `0.5` and `1` respectively.

```
// create a yml file
kubectl run nginx --image=nginx --restart=Never --dry-run -o yaml > nginx.yml


// add the resources section and create
kubectl create -f nginx.yml

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    resources:
      requests:
        cpu: "0.5"
      limits:
        cpu: "1"
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}

// verify
kubectl top pod
```

### 120. Create a Pod nginx and specify both CPU, memory requests and limits together and verify.

```
// create a yml file
kubectl run nginx --image=nginx --restart=Never --dry-run -o yaml > nginx.yml

// add the resources section and create
kubectl create -f nginx.yml

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    resources:
      requests:
        memory: "100Mi"
        cpu: "0.5"
      limits:
        memory: "200Mi"
        cpu: "1"
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}

// verify
kubectl top pod
```

### 121. Create a Pod nginx and specify a memory request and a memory limit of `100Gi` and `200Gi` respectively which is too big for the nodes and verify pod fails to start because of insufficient memory

```
// create a yml file
kubectl run nginx --image=nginx --restart=Never --dry-run -o yaml > nginx.yml

// add the resources section and create
kubectl create -f nginx.yml

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    resources:
      requests:
        memory: "100Gi"
        cpu: "0.5"
      limits:
        memory: "200Gi"
        cpu: "1"
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}

// verify
kubectl describe po nginx // you can see pending state
```

### 122. Create a secret mysecret with values `user=myuser` and `password=mypassword`

```
kubectl create secret generic my-secret --from-literal=username=user --from-literal=password=mypassword
```

### 123. List the secrets in all namespaces

```
kubectl get secret --all-namespaces
```

### 124. Output the yaml of the secret created above

```
kubectl get secret my-secret -o yaml
```

### 125. Create an nginx pod which reads username as the environment variable

```
// create a yml file
kubectl run nginx --image=nginx --restart=Never --dry-run -o yaml > nginx.yml

// add env section below and create
kubectl create -f nginx.yml

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    env:
    - name: USER_NAME
      valueFrom:
        secretKeyRef:
          name: my-secret
          key: username
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}


//verify
kubectl exec -it nginx -- env
```

### 126. Create an nginx pod which loads the secret as environment variables

```
// create a yml file
kubectl run nginx --image=nginx --restart=Never --dry-run -o yaml > nginx.yml

// add env section below and create
kubectl create -f nginx.yml

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    envFrom:
    - secretRef:
        name: my-secret
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}

//verify
kubectl exec -it nginx -- env
```

### 127. List all the service accounts in the default namespace

```
kubectl get sa
```

### 128. List all the service accounts in all namespaces

```
kubectl get sa --all-namespaces
```

### 129. Create a service account called `admin`

```
kubectl create sa admin
```

### 130. Output the YAML file for the service account we just created

```
kubectl get sa admin -o yaml
```

### 131. Create a busybox pod which executes this command sleep 3600 with the service account admin and verify

```
kubectl run busybox --image=busybox --restart=Never --dry-run -o yaml -- /bin/sh -c "sleep 3600" > busybox.yml

kubectl create -f busybox.yml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: busybox
  name: busybox
spec:
  serviceAccountName: admin
  containers:
  - args:
    - /bin/sh
    - -c
    - sleep 3600
    image: busybox
    name: busybox
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}

// verify
kubectl describe po busybox
```

## Observability (18%)

Practice questions based on these concepts


* Understand LivenessProbes and ReadinessProbes
* Understand Container Logging
* Understand how to monitor applications in kubernetes
* Understand Debugging in Kubernetes

### 132. Create an nginx pod with containerPort 80 and it should only `receive traffic only it checks the endpoint / on port 80` and verify and delete the pod.

```
kubectl run nginx --image=nginx --restart=Never --port=80 --dry-run -o yaml > nginx-pod.yaml

// add the readinessProbe section and create
kubectl create -f nginx-pod.yaml

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    ports:
    - containerPort: 80
    readinessProbe:
      httpGet:
        path: /
        port: 80
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}

// verify
kubectl describe pod nginx | grep -i readiness
kubectl delete po nginx
```

### 133. Create an nginx pod with containerPort 80 and it should check the pod running at endpoint / healthz on port 80 and verify and delete the pod.

```
kubectl run nginx --image=nginx --restart=Never --port=80 --dry-run -o yaml > nginx-pod.yaml

// add the livenessProbe section and create
kubectl create -f nginx-pod.yaml


apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    ports:
    - containerPort: 80
    livenessProbe:
      httpGet:
        path: /healthz
        port: 80
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}
```

### 134. Create an nginx pod with containerPort 80 and it should check the pod running at `endpoint /healthz on port 80` and it should only receive traffic only it checks the `endpoint / on port 80`. verify the pod.

```
kubectl run nginx --image=nginx --restart=Never --port=80 --dry-run -o yaml > nginx-pod.yaml

// add the livenessProbe and readiness section and create
kubectl create -f nginx-pod.yaml

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    ports:
    - containerPort: 80
    livenessProbe:
      httpGet:
        path: /healthz
        port: 80
    readinessProbe:
      httpGet:
        path: /
        port: 80
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}


// verify
kubectl describe pod nginx | grep -i readiness
kubectl describe pod nginx | grep -i liveness
```

### 135. Check what all are the options that we can configure with readiness and liveness probes

```
kubectl explain Pod.spec.containers.livenessProbe
kubectl explain Pod.spec.containers.readinessProbe
```

### 136. Create the pod nginx with the above liveness and readiness probes so that it should wait for 20 seconds before it checks liveness and readiness probes and it should check every 25 seconds.

```
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    ports:
    - containerPort: 80
    livenessProbe:
      initialDelaySeconds: 20
      periodSeconds: 25
      httpGet:
        path: /healthz
        port: 80
    readinessProbe:
      initialDelaySeconds: 20
      periodSeconds: 25
      httpGet:
        path: /
        port: 80
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}
```

### 137. Create a busybox pod with this command `“echo I am from busybox pod; sleep 3600;”` and verify the logs.

```
kubectl run busybox --image=busybox --restart=Never -- /bin/sh -c "echo I am from busybox pod; sleep 3600;"

kubectl logs busybox
```

### 138. copy the logs of the above pod to the busybox-logs.txt and verify

```
kubectl logs busybox > busybox-logs.txt

cat busybox-logs.txt
```

### 139. List all the events sorted by timestamp and put them into file.log and verify

```
kubectl get events --sort-by=.metadata.creationTimestamp

// putting them into file.log
kubectl get events --sort-by=.metadata.creationTimestamp > file.log

cat file.log
```

### 140. Create a pod with an image alpine which executes this command `”while true; do echo ‘Hi I am from alpine’; sleep 5; done”` and verify and follow the logs of the pod.

```
// create the pod
kubectl run hello --image=alpine --restart=Never  -- /bin/sh -c "while true; do echo 'Hi I am from Alpine'; sleep 5;done"

// verify and follow the logs
kubectl logs --follow hello
```

### 141. Create the pod with this `kubectl create -f https://gist.githubusercontent.com/bbachi/212168375b39e36e2e2984c097167b00/raw/1fd63509c3ae3a3d3da844640fb4cca744543c1c/not-running.yml.` The pod is not in the running state. Debug it

```
// create the pod
kubectl create -f https://gist.githubusercontent.com/bbachi/212168375b39e36e2e2984c097167b00/raw/1fd63509c3ae3a3d3da844640fb4cca744543c1c/not-running.yml

// get the pod
kubectl get pod not-running
kubectl describe po not-running

// it clearly says ImagePullBackOff something wrong with image
kubectl edit pod not-running // it will open vim editor
                     
kubectl set image pod/not-running not-running=nginx
```

### 142. This following yaml creates 4 namespaces and 4 pods. One of the pod in one of the namespaces are not in the running state. Debug and fix it. `https://gist.githubusercontent.com/bbachi/1f001f10337234d46806929d12245397/raw/84b7295fb077f15de979fec5b3f7a13fc69c6d83/problem-pod.yaml`.

```
kubectl create -f https://gist.githubusercontent.com/bbachi/1f001f10337234d46806929d12245397/raw/84b7295fb077f15de979fec5b3f7a13fc69c6d83/problem-pod.yaml

// get all the pods in all namespaces
kubectl get po --all-namespaces

// find out which pod is not running
kubectl get po -n namespace2

// update the image
kubectl set image pod/pod2 pod2=nginx -n namespace2

// verify again
kubectl get po -n namespace2
```

### 143. Get the memory and CPU usage of all the pods and find out top 3 pods which have the highest usage and put them into the `cpu-usage.txt` file

```
// get the top 3 hungry pods
kubectl top pod --all-namespaces | sort --reverse --key 3 --numeric | head -3

// putting into file
kubectl top pod --all-namespaces | sort --reverse --key 3 --numeric | head -3 > cpu-usage.txt

// verify
cat cpu-usage.txt
```

## Services and Networking (13%)

Practice questions based on these concepts

* Understand Services
* Demonstrate a basic understanding of NetworkPolicies

### 144. Create an nginx pod with a yaml file with label my-nginx and expose the port 80

```
kubectl run nginx --image=nginx --restart=Never --port=80 --dry-run -o yaml > nginx.yaml

// edit the label app: my-nginx and create the pod
kubectl create -f nginx.yaml

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    app: my-nginx
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    ports:
    - containerPort: 80
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}
```

### 145. Create the service for this nginx pod with the pod selector `app: my-nginx`

```
// create the below service
kubectl create -f nginx-svc.yaml

apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app: my-nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 9376
```


### 146. Find out the label of the pod and verify the service has the same label

```
// get the pod with labels
kubectl get po nginx --show-labels

// get the service and chekc the selector column
kubectl get svc my-service -o wide
```

### 147. Delete the service and create the service with kubectl expose command and verify the label

```
// delete the service
kubectl delete svc my-service

// create the service again
kubectl expose po nginx --port=80 --target-port=9376

// verify the label
kubectl get svc -l app=my-nginx
```
### 148. Delete the service and create the service again with type NodePort

```
// delete the service
kubectl delete svc nginx

// create service with expose command
kubectl expose po nginx --port=80 --type=NodePort
```

### 149. Create the temporary busybox pod and hit the service. Verify the service that it should return the nginx page index.html.

```
// get the clusterIP from this command
kubectl get svc nginx -o wide

// create temporary busybox to check the nodeport
kubectl run busybox --image=busybox --restart=Never -it --rm -- wget -o- <Cluster IP>:80
```

### 150. Create a NetworkPolicy which denies all ingress traffic

```
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
spec:
  podSelector: {}
  policyTypes:
  - Ingress
```


