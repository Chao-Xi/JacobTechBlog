![Alt Image Text](images/adv/adv20_0.jpg "Headline image")
# 静态 Pod

### 1.静态 `Pod` 直接由特定节点上的`kubelet`进程来管理，不通过 `master` 节点上的`apiserver`。

### 2.无法与我们常用的控制器`Deployment`或者`DaemonSet`进行关联，它由`kubelet`进程自己来监控，当`pod`崩溃时重启该`pod`，`kubelete`也无法对他们进行健康检查。

### 3.静态 `pod` 始终绑定在某一个`kubelet`，并且始终运行在同一个节点上。 `kubelet`会自动为每一个静态 `pod` 在 `Kubernetes` 的 `apiserver` 上创建一个镜像 `Pod（Mirror Pod`），因此我们可以在 `apiserver` 中查询到该 `pod`，但是不能通过 `apiserver` 进行控制（例如不能删除）。

### 创建静态 Pod 有两种方式：`配置文件` 和 `HTTP` 两种方式


## 配置文件

配置文件就是放在特定目录下的标准的 `JSON` 或 `YAML` 格式的 `pod` 定义文件:

### 用`kubelet --pod-manifest-path=<the directory>`

来启动`kubelet`进程，`kubelet` 定期的去扫描这个目录，根据这个目录下出现或消失的 `YAML/JSON` 文件来创建或删除静态 `pod`。

比如我们在 `node01` 这个节点上用静态 `pod` 的方式来启动一个 `nginx` 的服务。我们登录到`node01(192.168.33.170)`节点上面，可以通过下面命令找到`kubelet`对应的启动配置文件

```
$ systemctl status kubelet
```

配置文件路径为：

```
/etc/systemd/system/kubelet.service
```
打开这个文件我们可以看到其中如下的环境变量配置：

```
--experimental-bootstrap-kubeconfig=/etc/kubernetes/bootstrap.kubeconfig \
  --kubeconfig=/etc/kubernetes/kubelet.kubeconfig \
  --require-kubeconfig \
  --cert-dir=/etc/kubernetes/ssl \
  --cluster-dns=10.254.0.2 \
  --cluster-domain=cluster.local. \
  --hairpin-mode promiscuous-bridge \
  --allow-privileged=true
```

并没有关于静态 `Pod` 文件的路径, 你的 kubelet 启动参数中没有配置上面的`--pod-manifest-path`参数的话，那么添加上这个参数然后重启 `kubelet` 即可。

```
$ sudo vi /etc/systemd/system/kubelet.service
```

```
--experimental-bootstrap-kubeconfig=/etc/kubernetes/bootstrap.kubeconfig \
  --kubeconfig=/etc/kubernetes/kubelet.kubeconfig \
  --pod-manifest-path=/etc/kubernetes/manifests \
```

```
$ sudo systemctl daemon-reload
$ sudo systemctl enable kubelet
$ sudo systemctl restart kubelet
```

```
$ sudo vi /etc/kubernetes/manifests/static-web.yaml

apiVersion: v1
kind: Pod
metadata:
  name: static-web
  labels:
    app: static
spec:
  containers:
    - name: web
      image: nginx
      ports:
        - name: web
          containerPort: 80
```


## 通过 `HTTP` 创建静态 `Pods`

`kubelet` 启动时，由`--pod-manifest-path=` or `--manifest-url=` 参数指定的目录下定义的所有 `pod` 都会自动创建，例如，我们示例中的 `static-web`。（可能要花些时间拉取nginx 镜像，耐心等待…）

```
$ docker ps
CONTAINER ID        IMAGE      COMMAND                  CREATED              STATUS              PORTS     NAMES
97fac6c93653        nginx      "nginx -g 'daemon of…"   About a minute ago   Up About a minute             k8s_web_static-web-192.168.1.170_default_30fc054096339ad32eda4306892b37d0_0
```

现在我们通过`kubectl`工具可以看到这里创建了一个新的镜像 `Pod`

```
$ kubectl get pods
NAME                            READY     STATUS    RESTARTS   AGE
static-web-192.168.1.170        1/1       Running   0          3m
```

### 静态 `pod `的标签会传递给镜像 `Pod`，可以用来过滤或筛选。 需要注意的是，我们不能通过 `API` 服务器来删除静态 pod（例如，通过kubectl命令），`kebelet` 不会删除它。

我们尝试手动终止容器，可以看到kubelet很快就会自动重启容器。

```
$ docker ps
CONTAINER ID        IMAGE         COMMAND                CREATED       ...
5b920cbaf8b1        nginx:latest  "nginx -g 'daemon of   2 seconds ago ...
```

## 静态pods的动态增加和删除

运行中的`kubelet`周期扫描配置的目录（我们这个例子中就是`/etc/kubernetes/manifests`）下文件的变化，当这个目录中有文件出现或消失时创建或删除`pods`。

```
$ sudo mv /etc/kubernetes/manifests/static-web.yaml /tmp 
$ sleep 20
$ docker ps

// no nginx container is running

$ sudo mv /tmp/static-web.yaml  /etc/kubernetes/manifests
$ sleep 20
$ docker ps

docker ps
CONTAINER ID        IMAGE         COMMAND                  CREATED             STATUS              PORTS      NAMES
ce7d234cfdd2        nginx         "nginx -g 'daemon of…"   50 seconds ago      Up 49 sec                      ...
```
其实如果我们用 `kubeadm` 安装的集群，`master` 节点上面的几个重要组件都是用静态 `Pod` 的方式运行的，我们登录到 `master` 节点上查看`/etc/kubernetes/manifests`目录：

```
ls /etc/kubernetes/manifests/
etcd.yaml  kube-apiserver.yaml  kube-controller-manager.yaml  kube-scheduler.yaml
```

**现在明白了吧，这种方式也为我们将集群的一些组件容器化提供了可能**，因为这些 `Pod` 都不会受到 `apiserver` 的控制，不然我们这里`kube-apiserver`怎么自己去控制自己呢？万一不小心把这个 `Pod` 删掉了呢？所以只能有`kubelet`自己来进行控制，这就是我们所说的静态 `Pod`。



