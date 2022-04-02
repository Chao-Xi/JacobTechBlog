# Kind：一个容器创建K8S开发集群

## 什么是 Kind

kind：是一种使用Docker容器节点运行本地Kubernetes集群的工具。该类型主要用于测试Kubernetes，但可用于本地开发或CI。

Kind 是 Kubernetes SIG 的另一种用于本地部署集群的方法。**他的核心实现是让整个集群运行在 Docker 容器中。** 因此，它比 Minikube 更容易设置和更快启动。它支持单个节点或多 master 以及多工作节点。

Kind 是为一致性测试和用于 CI 管道而创建的，提供了一些不错的功能，比如可以直接在集群内部加载 Docker 镜像，而不需要推送到外部镜像仓库。


## 部署

### Mac & Linux

```
$ curl -Lo ./kind "https://kind.sigs.k8s.io/dl/v0.9.0/kind-$(uname)-amd64"
$ chmod +x ./kind
$ mv ./kind /some-dir-in-your-PATH/kind
```

```
$ curl -Lo . "https://kind.sigs.k8s.io/dl/v0.9.0/kind-$(uname)-amd64"
$ chmod +x ./kind
$ sudo mv ./kind /usr/local/bin/kind
```

### Mac 上使用 brew 安装

```
$ brew install kind
```

### Windows

```
$ curl.exe -Lo kind-windows-amd64.exe https://kind.sigs.k8s.io/dl/v0.9.0/kind-windows-amd64
Move-Item .\kind-windows-amd64.exe c:\some-dir-in-your-PATH\kind.exe

# OR via Chocolatey (https://chocolatey.org/packages/kind)
$ choco install kind
```

## K8S集群创建与删除

```
$ kind create cluster
Creating cluster "kind" ...
 ✓ Ensuring node image (kindest/node:v1.19.1) 🖼 
 ✓ Preparing nodes 📦  
 ✓ Writing configuration 📜 
 ✓ Starting control-plane 🕹️ 
 ✓ Installing CNI 🔌 
 ✓ Installing StorageClass 💾 
Set kubectl context to "kind-kind"
You can now use your cluster with:

kubectl cluster-info --context kind-kind

Thanks for using kind! 😊
```

```
$ kind get clusters
kind
```

一个 Docker 容器创建的 K8S 集群

```
$ docker ps | grep kind
7bb7bf3a3539        kindest/node:v1.19.1                                  "/usr/local/bin/entr…"   2 minutes ago       Up 2 minutes        127.0.0.1:36842->6443/tcp          kind-control-plane
```

安装kubectl

```
$ curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"

$ chmod +x ./kubectl
$ sudo mv ./kubectl /usr/local/bin/kubectl

$ kubectl version --client
Client Version: version.Info{Major:"1", Minor:"19", GitVersion:"v1.19.3", GitCommit:"1e11e4a2108024935ecfcb2912226cedeafd99df", GitTreeState:"clean", BuildDate:"2020-10-14T12:50:19Z", GoVersion:"go1.15.2", Compiler:"gc", Platform:"linux/amd64"}
```

```
$ docker images | grep kind
kindest/node                                    <none>              37ddbc9063d2        6 weeks ago         1.33GB
```

列出K8S集群pods

```
kubectl get pods -o wide -A
NAMESPACE            NAME                                         READY   STATUS    RESTARTS   AGE   IP           NODE                 NOMINATED NODE   READINESS GATES
kube-system          coredns-f9fd979d6-pbrxj                      1/1     Running   0          10m   10.244.0.3   kind-control-plane   <none>           <none>
kube-system          coredns-f9fd979d6-zqjwp                      1/1     Running   0          10m   10.244.0.4   kind-control-plane   <none>           <none>
kube-system          etcd-kind-control-plane                      1/1     Running   0          10m   172.18.0.2   kind-control-plane   <none>           <none>
kube-system          kindnet-pl5vc                                1/1     Running   0          10m   172.18.0.2   kind-control-plane   <none>           <none>
kube-system          kube-apiserver-kind-control-plane            1/1     Running   0          10m   172.18.0.2   kind-control-plane   <none>           <none>
kube-system          kube-controller-manager-kind-control-plane   1/1     Running   0          10m   172.18.0.2   kind-control-plane   <none>           <none>
kube-system          kube-proxy-fb559                             1/1     Running   0          10m   172.18.0.2   kind-control-plane   <none>           <none>
kube-system          kube-scheduler-kind-control-plane            1/1     Running   0          10m   172.18.0.2   kind-control-plane   <none>           <none>
local-path-storage   local-path-provisioner-78776bfc44-85lbl      1/1     Running   0          10m   10.244.0.2   kind-control-plane   <none>           <none>
```

```
# 定义集群名称
$ kind create cluster --name kind-2

# 查询集群
$ kind get clusters

# 删除集群
$ kind delete cluster
```

## 其它操作

```
# 列出集群镜像
$ docker exec -it my-node-name crictl images
```

```
$ docker exec -it kind-control-plane crictl images
IMAGE                                      TAG                  IMAGE ID            SIZE
docker.io/kindest/kindnetd                 v20200725-4d6bea59   b77790820d015       119MB
docker.io/rancher/local-path-provisioner   v0.0.14              e422121c9c5f9       42MB
k8s.gcr.io/build-image/debian-base         v2.1.0               c7c6c86897b63       53.9MB
k8s.gcr.io/coredns                         1.7.0                bfe3a36ebd252       45.4MB
k8s.gcr.io/etcd                            3.4.13-0             0369cf4303ffd       255MB
k8s.gcr.io/kube-apiserver                  v1.19.1              8cba89a89aaa8       95MB
k8s.gcr.io/kube-controller-manager         v1.19.1              7dafbafe72c90       84.1MB
k8s.gcr.io/kube-proxy                      v1.19.1              47e289e332426       136MB
k8s.gcr.io/kube-scheduler                  v1.19.1              4d648fc900179       65.1MB
k8s.gcr.io/pause                           3.3                  0184c1613d929       686kB
```

参考链接

* https://github.com/kubernetes-sigs/kind
* https://kind.sigs.k8s.io/docs/user/quick-start/#installation