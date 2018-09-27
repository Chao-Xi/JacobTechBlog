![Alt Image Text](images/helm/helm1_0.jpg "Headline image")
# Kubernetes Helm 初体验

于单体服务，部署一套测试环境我相信还是非常快的，但是对于微服务架构的应用，要部署一套新的环境，就有点折磨人了，微服务越多、你就会越绝望的。虽然我们线上和测试环境已经都迁移到了`kubernetes`环境，但是每个微服务也得维护一套`yaml`文件，而且每个环境下的配置文件也不太一样，部署一套新的环境成本是真的很高。如果我们能使用类似于`yum`的工具来安装我们的应用的话是不是就很爽歪歪了啊？`Helm`就相当于`kubernetes`环境下的`yum`包管理工具


## 用途

做为 `Kubernetes` 的一个包管理工具，`Helm`具有如下功能：

* 创建新的 `chart`
* `chart` 打包成 `tgz` 格式
* 上传 `chart` 到 `chart` 仓库或从仓库中下载 `chart`
* 在`Kubernetes`集群中安装或卸载 `chart`
* 管理用`Helm`安装的 `chart` 的发布周期

## 重要概念

Helm 有三个重要概念：

### 1.`chart`：包含了创建`Kubernetes`的一个`应用实例的必要信息`
### 2.`config`：包含了`应用发布配置信息`
### 3.`release`：是一个 `chart` 及其`配置的一个运行实例`

## Helm组件

`Helm` 有以下两个组成部分：

`Helm Client` 是用户命令行工具，其主要负责如下：

* 本地 chart 开发
* 仓库管理
* 与 Tiller sever 交互
* 发送预安装的 chart
* 查询 release 信息
* 要求升级或卸载已存在的 release

`Tiller Server`是一个部署在`Kubernetes`集群内部的 `server`，其与 `Helm client`、`Kubernetes API server ` 进行交互。`Tiller server` 主要负责如下：

* 监听来自 `Helm client` 的请求
* 通过 `chart` 及其配置构建一次发布
* 安装 `chart` 到Kubernetes集群，并跟踪随后的发布
* 通过与`Kubernetes`交互升级或卸载 `chart`

### 简单的说，`client` 管理 `charts`，而 `server` 管理发布 `release`


## 安装

我们可以在**Helm Realese**页面下载二进制文件，这里下载的`2.9.1`版本，解压后将可执行文件`helm`拷贝到`/usr/local/bin`目录下即可，这样`Helm`客户端就在这台机器上安装完成了。

或者直接用`snap`直接安装

```
sudo snap install helm
```

现在我们可以使用`Helm`命令查看版本了，会提示无法连接到服务端`Tiller`或者会`hang`在那里：

```
$ helm version
Client: &version.Version{SemVer:"v2.9.1", GitCommit:"20adb27c7c5868466912eebdf6664e7390ebe710", GitTreeState:"clean"}
Error: cannot connect to Tiller
```

要安装 `Helm` 的服务端程序，我们需要使用到`kubectl`工具，所以先确保`kubectl`工具能够正常的访问 `kubernetes` 集群的`apiserver`哦。

然后我们在命令行中执行初始化操作：

```
$ helm init
```

我在安装过程中遇到了一些其他问题，比如初始化的时候出现了如下错误：

```
E0926 09:29:52.561078   10640 portforward.go:331] an error occurred forwarding 39588 -> 44134: 
error forwarding port 44134 to pod 
df458d7eeaab76e45d897be710ec27d589c3bb423125ea184fcec6e66551066e, uid : unable to do port 
forwarding: socat not found.
Error: transport is closing
```

解决方案：**在所有节点上安装`socat`可以解决**

```
$ kubectl get pod -n kube-system -l app=helm -o wide
NAME                             READY     STATUS    RESTARTS   AGE     IP           NODE
tiller-deploy-6d9f596465-zc7f9   1/1       Running   0          12m     172.17.0.8   192.168.1.138
```
先在`192.168.1.138`进行安装

```
$ sudo apt-get install -y socat
Reading package lists... Done
Building dependency tree
Reading state information... Done
The following NEW packages will be installed:
  socat
0 upgraded, 1 newly installed, 0 to remove and 130 not upgraded.
Need to get 321 kB of archives.
After this operation, 941 kB of additional disk space will be used.
Get:1 http://archive.ubuntu.com/ubuntu xenial/universe amd64 socat amd64 1.7.3.1-1 [321 kB]
Fetched 321 kB in 2s (126 kB/s)
Selecting previously unselected package socat.
(Reading database ... 38475 files and directories currently installed.)
Preparing to unpack .../socat_1.7.3.1-1_amd64.deb ...
Unpacking socat (1.7.3.1-1) ...
Processing triggers for man-db (2.7.5-1) ...
Setting up socat (1.7.3.1-1) ...
```

`Helm` 服务端正常安装完成后，`Tiller`默认被部署在`kubernetes`集群的`kube-system`命名空间下：

```
$ kubectl get pod -n kube-system -l app=helm
NAME                            READY     STATUS    RESTARTS   AGE
tiller-deploy-dccdb6fd9-4pfch   1/1       Running   0          16h
```

此时，我们查看 `Helm` 版本就都正常了：

```
$ helm version
Client: &version.Version{SemVer:"v2.9.1", GitCommit:"20adb27c7c5868466912eebdf6664e7390ebe710", GitTreeState:"clean"}
Server: &version.Version{SemVer:"v2.9.1", GitCommit:"20adb27c7c5868466912eebdf6664e7390ebe710", GitTreeState:"clean"}
```

另外一个值得注意的问题是`RBAC`，我们的 `kubernetes` 集群是`1.8.x`版本的，默认开启了`RBAC`访问控制，所以我们需要为`Tiller`创建一个`ServiceAccount`，让他拥有执行的权限，详细内容可以查看 `Helm` 文档中的[Role-based Access Control](https://docs.helm.sh/using_helm/#role-based-access-control)。 创建`rbac.yaml`文件：

```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system
```
然后使用`kubectl`创建：

```
$ kubectl create -f rbac-config.yaml
serviceaccount "tiller" created
clusterrolebinding "tiller" created
```


创建了`tiller`的 `ServceAccount` 后还没完，因为我们的 `Tiller` 之前已经就部署成功了，而且是没有指定 `ServiceAccount` 的，所以我们需要给 `Tiller` 打上一个 `ServiceAccount` 的补丁：

```
$ kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
```

**上面这一步非常重要，不然后面在使用 Helm 的过程中可能出现`Error: no available release name found`的错误信息。**


```
$  kubectl get deployment -n kube-system
NAME                         DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
tiller-deploy                1         1         1            0           16m
```

```
$ kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
deployment "tiller-deploy" patched
```

至此, `Helm`客户端和服务端都配置完成了，接下来我们看看如何使用吧。

```
$ sudo apt-get install tree
```

## 使用

我们现在了尝试创建一个 Chart：

```
$ helm create hello-helm
Creating hello-helm

$ tree hello-helm
hello-helm
├── charts
├── Chart.yaml
├── templates
│   ├── deployment.yaml
│   ├── _helpers.tpl
│   ├── ingress.yaml
│   ├── NOTES.txt
│   └── service.yaml
└── values.yaml

2 directories, 7 files
```

我们通过查看`templates`目录下面的`deployment.yaml`文件可以看出默认创建的 `Chart` 是一个 `ngin`x 服务，具体的每个文件是干什么用的，我们可以前往 [Helm 官方文档](https://docs.helm.sh/developing_charts/#charts)进行查看。

```
$ helm install ./hello-helm
E0926 09:29:52.561078   10640 portforward.go:331] an error occurred forwarding 39588 -> 44134: error forwarding port 44134 to pod df458d7eeaab76e45d897be710ec27d589c3bb423125ea184fcec6e66551066e, uid : unable to do port forwarding: socat not found.
Error: transport is closing
```


在`192.168.1.170`进行安装

```
$ sudo apt-get install -y socat
```

```
$ helm install ./hello-helm
NAME:   lanky-lion
LAST DEPLOYED: Wed Sep 26 09:30:34 2018
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/Service
NAME                   TYPE       CLUSTER-IP     EXTERNAL-IP  PORT(S)  AGE
lanky-lion-hello-helm  ClusterIP  10.254.155.61  <none>       80/TCP   0s

==> v1beta2/Deployment
NAME                   DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE
lanky-lion-hello-helm  1        1        1           0          0s

==> v1/Pod(related)
NAME                                    READY  STATUS             RESTARTS  AGE
lanky-lion-hello-helm-79cc567975-jmh6n  0/1    ContainerCreating  0         0s


NOTES:
1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace default -l "app=hello-helm,release=lanky-lion" -o jsonpath="{.items[0].metadata.name}")
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl port-forward $POD_NAME 8080:80
```

然后我们根据提示执行下面的命令：


在`node`上

```
$ screen
$ export POD_NAME=$(kubectl get pods --namespace default -l "app=hello-helm,release=kilted-bobcat" -o jsonpath="{.items[0].metadata.name}")
$ kubectl port-forward $POD_NAME 8080:80

ctrl+a+d
[detached from 26400.pts-0.kube-node2]

$ curl http://127.0.0.1:8080
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>


$ screen -list
There are screens on:
	26539.pts-0.kube-node2	(09/26/2018 09:36:49 AM)	(Detached)
	26400.pts-0.kube-node2	(09/26/2018 09:36:01 AM)	(Detached)
2 Sockets in /var/run/screen/S-vagrant.

$ screen -XS 26539.pts-0.kube-node2 quit
```


查看`release`：

```
$ helm list
NAME         REVISION	UPDATED                   STATUS    CHART             NAMESPACE
lanky-lion	1       	Wed Sep 26 09:30:34 2018  DEPLOYED  hello-helm-0.1.0. default
```
打包`chart`：

```
$ helm package hello-helm
Successfully packaged chart and saved it to: /home/vagrant/helm/hello-helm-0.1.0.tgz
```

```
$ ls
hello-helm-0.1.0.tgz
```
然后我们就可以将打包的`tgz`文件分发到任意的服务器上，通过`helm fetch`就可以获取到该 `Chart` 了。

删除`release`：

```
$ helm delete lanky-lion
release "lanky-lion" deleted
```

然后我们看到`kubernetes`集群上的该 `nginx` 服务也已经被删除了。

## Reference


[https://docs.helm.sh/](https://docs.helm.sh/)

