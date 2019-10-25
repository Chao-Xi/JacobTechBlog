# K8S Q&A Chapter Six


## 1. 如果`pod`长期不重启，容器输出到 `emptydir` 的日志文件，有什么好的清理办法呢？

`v1.7 +` 支持对基于本地存储（如 `hostPath`,` emptyDir`, `gitRepo` 等）的容量进行调度限额。为了支持这个特性，`Kubernetes` 将本地存储分为两类：

`storage.kubernetes.io/overlay`，即 `/var/lib/docker` 的大小`storage.kubernetes.io/scratch`，即 `/var/lib/kubelet` 的大小


`Kubernetes` 根据 `storage.kubernetes.io/scratch` 的大小来调度本地存储空间，而根据 `storage.kubernetes.io/overlay` 来调度容器的存储。

比如为容器请求 `64MB` 的可写层存储空间：


```
apiVersion: v1
kind: Pod
metadata:
  name: ls1
spec:
  restartPolicy: Never
  containers:
  - name: hello
    image: busybox
    command: ["df"]
    resources:
      requests:
        storage.kubernetes.io/overlay: 64Mi
```

**为 `emptyDir` 请求 `64MB` 的存储空间**：

```
apiVersion: v1
kind: Pod
metadata:
  name: ls1
spec:
  restartPolicy: Never
  containers:
  - name: hello
    image: busybox
    command: ["df"]
    volumeMounts:
    - name: data
      mountPath: /data
  volumes:
  - name: data
    emptyDir:
      sizeLimit: 64Mi
```

## 2. `kubeadm` 搭建集群忘记了 `join` 的命令


在使用 `kubeadm` 初始化集群的时候，有时可能会忘记保存 `join` 命令，或者在添加节点的时候 `token` 失效了，要重新获取 `join` 命令有两种方法：

第一种方法：可以通过 `kubeadm token create` 重新创建一个新的 `token值<new-token>`；然后通过 `openssl` 命令或者 `CA` 证书的 `hash` 值：

```

$ openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'
<ca-cert-hash>
```

最终新的 `join` 命令为：

```
kubeadm join <apiserver> --token <new-token> --discovery-token-ca-cert-hash sha256:<ca-cert-hash>
```

第二种方法：新版本(>1.10)的 `kubeadm` 支持直接获取 `join` 命令：

```
kubeadm token create --print-join-command
```

## 3. `ServiceAccount` 如何进行权限控制

我们知道 `ServiceAccount` 是通过 `Role` 或者 `ClusterRole` 里面的权限声明来进行权限控制的，那么是怎样来实现的呢？

我们如果在使用 `ServiceAccount` 来进行权限控制了，那么肯定是我们当前的 `Pod` 需要去访问 `Kubernetes` 集群中的某些资源，比如 `Pod` 的 `CRUD` 操作，这个时候就需要我们有 `CRUD Pod` 的权限，而我们当前的 `Pod` 就是通过 `ServiceAccount` 对应的 `token` 文件和自动注入到 `Pod` 中的 `ca.crt` 文件去连接的 `APIServer`，而这个 `token` 又是绑定了相关权限的，所以我们在 `Pod` 中去访问 `APIServer` 的时候就知道当前的操作是否有对应的权限了。

如果集群使用 `TLS` 认证方式，则我们可以在 `client-go` 当中通过 `InCluster` 的方式自动去读取集群内部的 `tokenFile` 和 `CAFile`：

```

// tokenFile = "/var/run/secrets/kubernetes.io/serviceaccount/token"
// rootCAFile = "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
config, _ := rest.InClusterConfig()

// 根据指定的 config 创建一个新的 clientset
clientset, _ := kubernetes.NewForConfig(config)
// 然后通过 clientset 去操作集群资源
......
```

**如果我们没有给 `Pod` 指定一个 `ServiceAccount` 的话，则会使用默认的名为 `default` 的这个 `ServiceAccount`，当然他也有一个 `token` 会被自动注入到 `Pod` 中，但是就不一定有我们想要的访问集群资源的权限了，所以我们需要自定义一个 `ServiceAccount` 绑定到 `Pod` 上面去。**


## 4.  `Docerfile` 中添加交互式命令


一个有趣的问题，需要在 `Dockerfile` 里面添加交互式的命令，类似于我们平时安装软件的时候输入 `yes`，我们可以通过 `yum install -y` 来默认安装，避免用户输入，但是有的时候没办法避免的时候，一定需要输入交互命令的时候应该咋办呢？

能想到的一个比较好的办法是暂时在 `Dockerfile` 中不添加这条交互式命令，**先制作一个镜像，然后使用这个镜像运行一个容器，然后到容器中去运行这个交互式命令，然后配置完后 `commit` 下这个容器成一个新的镜像即可**。

但是上面这种方式不具有通用性，在 `docker` 官方论坛中有关于这个问题的解答：[https://forums.docker.com/t/dockerfile-how-to-answer-install-question-from-application/5240/2](https://forums.docker.com/t/dockerfile-how-to-answer-install-question-from-application/5240/2) 通过安装 `expect` 工具来实现交互功能：

```
RUN apt-get install expect
ADD install_script
RUN install_script
```

安装脚本如下：

```
#!/usr/bin/expect
set timeout 2
spawn "./your_script"
expect “Question 1 :” { send “yes\n” }
expect “Question 2 :” { send “no\n” }
interact
```

## 5. kubeadm 升级集群配置

昨天升级了下集群到 `v1.14.5` 版本，升级过程很顺畅，但是今天发现 `apiserver` 中出现大量的 `tls bad` 的错误日志，而且内部服务解析都失败，第一反应说 `dns` 的问题，但是 `CoreDNS` 也没任何错误日志信息，然后再看 `kube-proxy` 日志，才发现出现了大量的连接 `apiserver` 失败的错误，仔细一看连接的居然还是 `apiserver` 节点的外网 `IP`，这就奇怪了，之前升级都是正常的，这次居然读取到了外网 `IP`，对应多网卡的节点，在使用 `kubeadm` 安装或者升级的使用要注意指定下使用的 `apiserver` 地址，否则可能就会读取到外网 `IP`了，下面说创建或升级 `kubernetes` 的 `kubeadm` 配置文件


```

apiVersion: kubeadm.k8s.io/v1beta1
kind: ClusterConfiguration
networking:
  dnsDomain: cluster.local
  podSubnet: 10.244.0.0/16
  serviceSubnet: 10.96.0.0/12
kubernetesVersion: v1.15.2
imageRepository: gcr.azk8s.cn/google_containers

---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: "ipvs"

---
apiVersion: kubeadm.k8s.io/v1beta1
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: 10.151.30.11
  bindPort: 6443
```

主要修改的参数就是 `InitConfiguration` 中的 `advertiseAddress` 地址为内网网卡的 `IP` 地址，然后使用 `kubeadm` 命令安装或更新即可。

对于 `kubeadm` 初始化集群的配置可以通过如下命令获取：

```
kubeadm config print init-defaults
```

但是要想完整了解上面的资源对象对应的属性，可以查看对应的 godoc 文档，地址: https://godoc.org/k8s.io/kubernetes/cmd/kubeadm/app/apis/kubeadm/v1beta2。


## 6. Pod 时区同步


往往都会遇到修改 `Pod` 时区的需求，更多的需求是要求所有的 `Pod` 都在同一个时区，比如我们所在的东8区，一般我们可以通过环境变量或者挂载主机的时区文件到 `Pod` 中来实现同步，但是这样需要我们对每一个 `Pod` 手动做这样的操作，

* **一个更好的方式就是利用 `PodPreset` 来预设。首先启用 `PodPreset`：在 `kube-apiserver` 启动参数 `-runtime-config` 增加 `settings.k8s.io/v1alpha1=true;`**
* 然后在 `--admission-control` 增加 `PodPreset` 启用。最后重启 `kube-apiserver` 即表示启用成功。可以通过如下命令查看是否启用成功：

```
$ kubectl get podpresets
```

然后创建一个 `PodPresents` 资源对象：

```
apiVersion: settings.k8s.io/v1alpha1
kind: PodPreset
metadata:
  name: tz-env
spec:
  selector:
    matchLabels:
  env:
  - name: TZ
    values: Asia/Shanghai
```

这里需要注意的地方是，

**一定需要写 `selector...matchLabels`，但是 `matchLabels` 为空，表示应用于所有容器，这个就是我们想要的，创建上面这个资源对象，然后我们去创建一个普通的 `Pod` 可以查看下是否注入了上面的 `TZ` 这个环境变量。需要注意的是，`PodPreset` 是 `namespace` 级别的对象，其作用范围只能是同一个命名空间下的容器**。



## 7. `Prometheus` 采集 `Kubelet` 指标

在`kubernetes 1.11` 版本以后 `kubelet` 去掉了 `10255` 端口，所以在使用 `prometheus` 监控 `kubelet` 的时候就只需要使用自动发现角色为 `node` 类型的即可，但是要注意需要使用 `https` 的协议，而且有一个经常遇到的问题是访问 `metrics` 接口的时候出现 `403` 错误。遇到这种情况需要确保 `kubelet` 开启了下面两个参数：

```
--authentication-token-webhook
--authorization-mode=Webhook
```

此外在给 `prometheus` 指定 `rbac` 权限的时候需要绑定下面的权限：

```
- apiGroups:
  - ""
  resources:
  - nodes/metrics
  verbs:
  - get
```

## 8. Lease API

`1.14版本+` 中多了一个名为 `kube-node-lease` 的命名空间，不知道这个是干嘛使用的，不知道能不能删除呢？

```

$ kubectl get ns
NAME                  STATUS   AGE
default               Active   10d
kube-node-lease       Active   10d
kube-public           Active   10d
kube-system           Active   10d
```

**实际上 `kube-node-lease` 命名空间里面包含 `kubelet` 用来确定节点运行状况的租约对象，`kubelet` 会创建并定期更新节点上的租约，`kubelet` 使用新的 `Lease API` 报告节点心跳，节点生命周期控制器使用这些心跳作为节点健康信号**。


## 9. Prometheus 报警规则

在群里面看到群友分享的一个收集 Prometheus 各种报警规则的项目，都是比较通用的报警规则配置

[https://github.com/samber/awesome-prometheus-alerts](https://github.com/samber/awesome-prometheus-alerts)

## 10.启动探针

在 `Kubernetes 1.16` 版本中为缓慢启动的 `Pod` 添加了一个 `startupProbe` 的启动探针来延迟其他探针检测。我们知道探针可以让 `Kubernetes` 监视您的应用程序状态。您可以使用`livenessProbe `定期检查应用程序是否仍在运行。下面是一个示例容器定义了此探针：

```
livenessProbe:
  httpGet:
    path: /healthz
    port: liveness-port
  failureThreshold: 3
  periodSeconds: 10
```

如果在`30`秒内失败`3`次，则容器将重新启动。

但是由于该容器很慢并且需要`30`秒钟以上才能启动，那么该探针肯定就会失败，并且容器将再次重新启动，这样就陷入一个死循环当中了，之前我们大部分情况是配置的一个 `initialDelaySeconds` 的参数来延迟第一次检测的时间，但是这个参数毕竟是写死的，不够准确。

`startupProbe` 这项新功能可以使您可以定义一个启动探针，该探针将推迟所有其他探针，直到 Pod 完成启动为止：

```
startupProbe:
  httpGet:
    path: /healthz
    port: liveness-port
  failureThreshold: 30
  periodSeconds: 10
```

现在，我们的慢速容器最多可以有5分钟（`30个检查* 10秒= 300s`）完成启动了

