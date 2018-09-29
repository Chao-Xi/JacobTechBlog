![Alt Image Text](images/adv/adv24_0.jpg "Headline image")
# `DaemonSet` 与 `StatefulSet` 的使用

我们前面主要讲解的是`Deployment`这种对象资源的使用，接下来我们要讲解的是在特定场合下使用的控制器：`DaemonSet`与`StatefulSet`。

## `DaemonSet` 的使用

通过该控制器的名称我们可以看出它的用法：

### `Daemon`，就是用来`部署守护进程的`，`DaemonSet`用于在每个`Kubernetes`节点中将`守护进程的副本作为后台进程运行`，说白了就是在每个节点部署一个`Pod`副本，当节点加入到`Kubernetes`集群中，`Pod`会被调度到该节点上运行，当节点从集群只能够被移除后，该节点上的这个`Pod`也会被移除，当然，如果我们删除`DaemonSet`，所有和这个对象相关的`Pods`都会被删除。


在哪种情况下我们会需要用到这种业务场景呢？其实这种场景还是比较普通的，比如

* `集群存储守护程序`，如`glusterd`、`ceph`要部署在每个节点上以**提供持久性存储**；
* `节点监视守护进程`，如`Prometheus`监控集群，可以在每个节点上运行一个`node-exporter`进程来**收集监控节点的信息；**
* `日志收集守护程序`，如`fluentd`或`logstash`，**在每个节点上运行以收集容器的日志**

这里需要特别说明的一个就是关于`DaemonSet`运行的`Pod`的调度问题，正常情况下，`Pod`运行在哪个节点上是由`Kubernetes`的调度器策略来决定的，然而，由`DaemonSet`控制器创建的`Pod`实际上提前已经确定了在哪个节点上了（`Pod`创建时指定了`.spec.nodeName`），所以：

* `DaemonSet`并不关心一个节点的`unshedulable`字段，
* `DaemonSet`可以创建`Pod`，即使调度器还没有启动，这点非常重要。

下面我们直接使用一个示例来演示下，在每个节点上部署一个`Nginx Pod`：(`nginx-ds.yaml`)

```
kind: DaemonSet
apiVersion: extensions/v1beta1
metadata:
  name: nginx-ds
  labels:
    k8s-app: nginx
spec:
  template:
    metadata:
      labels:
        k8s-app: nginx
    spec:
      containers:
      - image: nginx:1.7.9
        name: nginx
        ports:
        - name: http
          containerPort: 80
```
然后直接创建即可：

```
$ kubectl create -f nginx-ds.yaml

```
然后我们可以观察下Pod是否被分布到了每个节点上：

```
$ kubectl get nodes
NAME            STATUS    ROLES     AGE       VERSION
192.168.1.138   Ready     <none>    15d       v1.8.2
192.168.1.170   Ready     <none>    17d       v1.8.2
```

```
$ kubectl get pods -o wide
NAME               READY     STATUS    RESTARTS   AGE       IP            NODE
nginx-ds-g7t8b     1/1       Running   0          17d       172.17.0.2    192.168.1.170
nginx-ds-mk9kl     1/1       Running   0          15d       172.17.0.2    192.168.1.138
```

## StatefulSet 的使用

### 先弄明白一个概念：什么是`有状态服务`？什么是`无状态服务`？

* `无状态服务（Stateless Service）`：**该服务运行的实例不会在本地存储需要持久化的数据，并且多个实例对于同一个请求响应的结果是完全一致的**，比如前面我们讲解的WordPress实例，我们是不是可以同时启动多个实例，但是我们访问任意一个实例得到的结果都是一样的吧？因为他唯一需要持久化的数据是存储在MySQL数据库中的，所以我们可以说WordPress这个应用是无状态服务，但是MySQL数据库就不是了，因为他需要把数据持久化到本地。

* `有状态服务（Stateful Service）`：就和上面的概念是对立的了，**该服务运行的实例需要在本地存储持久化数据，比如上面的MySQL数据库，你现在运行在节点A，那么他的数据就存储在节点A上面的，如果这个时候你把该服务迁移到节点B去的话，那么就没有之前的数据了，因为他需要去对应的数据目录里面恢复数据，而此时没有任何数据。**


现在大家对有状态和无状态有一定的认识了吧，比如我们常见的 `WEB` 应用，是通过`session`来保持用户的登录状态的，如果我们将`session`持久化到节点上，那么该应用就是一个**有状态的服务**了，因为我现在登录进来你把我的`session`持久化到`节点A`上了，下次我登录的时候可能会将请求路由到`节点B`上去了，但是节点B上根本就没有我当前的session数据，就会被认为是未登录状态了，这样就导致我前后两次请求得到的结果不一致了。

### 所以一般为了横向扩展，我们都会把这类 `WEB` 应用改成`无状态的服务`，怎么改？将`session`数据存入一个公共的地方，比如`redis`里面，是不是就可以了，对于一些`客户端请求API`的情况，我们就不使用`session`来保持用户状态，改成用`token`也是可以的。

无状态服务利用我们前面的`Deployment`或者`RC`都可以很好的控制，对应有状态服务，需要考虑的细节就要多很多了，**容器化应用程序最困难的任务之一，就是设计有状态分布式组件的部署体系结构**。

由于无状态组件可能没有预定义的`启动顺序`、`集群要求`、`点对点 TCP 连接`、`唯一的网络标识符`、`正常的启动`和`终止`要求等，因此可以很容易地进行容器化。**但是诸如`数据库`，`大数据分析系统`，`分布式 key/value 存储`和 m`essage brokers` 可能有复杂的分布式体系结构，都可能会用到上述功能。为此，`Kubernetes`引入了`StatefulSet`资源来支持这种复杂的需求。**

* 稳定的、唯一的网络标识符
* 稳定的、持久化的存储
* 有序的、优雅的部署和缩放
* 有序的、优雅的删除和终止
* 有序的、自动滚动更新

## 创建StatefulSet

接下来我们来给大家演示下`StatefulSet`对象的使用方法，在开始之前，我们先准备两个`1G`的存储卷（`PV`），在后面的课程中我们也会和大家详细讲解 `PV` 和 `PVC` 的使用方法的，这里我们先不深究：（`pv001.yaml`）

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv001
  labels:
    release: stable
spec:
  capacity:
    storage: 1Gi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Recycle
  hostPath:
    path: /tmp/data
```

另外一个只需要把 `name` 改成 `pv002`即可，然后创建：

```
$ kubectl create -f pv001.yaml && kubectl create -f pv002.yaml
persistentvolume "pv001" created
persistentvolume "pv002" created
$ kubectl get pv
kubectl get pv
NAME      CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM     STORAGECLASS   REASON    AGE
pv001     1Gi        RWO            Recycle          Available                                      12s
pv002     1Gi        RWO            Recycle          Available  
```

可以看到成功创建了两个 PV对象，状态是：`Available`。

然后我们使用`StatefulSet`来创建一个 `Nginx` 的 `Pod`，对于这种类型的资源，我们一般是通过创建一个`Headless Service`类型的服务来暴露服务，将`clusterIP`设置为`None`就是一个无头的服务：（`statefulset-demo.yaml`）

```
apiVersion: v1
kind: Service
metadata:
  name: nginx
spec:
  ports:
  - port: 80
    name: web
  clusterIP: None
  selector:
    app: nginx
    role: stateful

---
apiVersion: apps/v1beta1
kind: StatefulSet
metadata:
  name: web
spec:
  serviceName: "nginx"
  replicas: 2
  template:
    metadata:
      labels:
        app: nginx
        role: stateful
    spec:
      containers:
      - name: nginx
        image: cnych/nginx-slim:0.8
        ports:
        - containerPort: 80
          name: web
        volumeMounts:
        - name: www
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
  - metadata:
      name: www
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi
```

注意上面的 `YAML` 文件中和`volumeMounts`进行关联的是一个新的属性：`volumeClaimTemplates`，该属性会自动声明一个 `pvc` 对象和 `pv` 进行管理： 

然后这里我们开启两个终端窗口。在第一个终端中，使用 `kubectl get` 来查看 `StatefulSet` 的 `Pods` 的创建情况。

```
$ kubectl get pods -w -l role=stateful
```

在另一个终端中，使用 `kubectl create `来创建定义在 `statefulset-demo.yaml` 中的 `Headless Service` 和 `StatefulSet`。

```
$ kubectl create -f statefulset-demo.yaml
service "nginx" created
statefulset.apps "web" created
```

## 检查 Pod 的顺序索引

对于一个拥有 `N` 个副本的 `StatefulSet`，`Pod` 被部署时是按照 `{0..N-1}`的序号顺序创建的。在第一个终端中我们可以看到如下的一些信息：

```
$ kubectl get pods -w -l role=stateful
NAME      READY     STATUS    RESTARTS   AGE
web-0     0/1       Pending   0          0s
web-0     0/1       Pending   0         0s
web-0     0/1       ContainerCreating   0         0s
web-0     1/1       Running   0         19s
web-1     0/1       Pending   0         0s
web-1     0/1       Pending   0         0s
web-1     0/1       ContainerCreating   0         0s
web-1     1/1       Running   0         18s
```

请注意在 `web-0 Pod` 处于 `Running` 和 `Ready` 状态后 `web-1 Pod` 才会被启动。

同 `StatefulSets` 概念中所提到的， `StatefulSet` 中的 `Pod` 拥有一个具有稳定的、独一无二的身份标志。这个标志基于 `StatefulSet` 控制器分配给每个 `Pod` 的唯一顺序索引。 `Pod `的名称的形式为`<statefulset name>-<ordinal index>`。`web StatefulSet` 拥有两个副本，所以它创建了两个 `Pod：web-0` 和 `web-1`。
 

上面的命令创建了两个 `Pod`，每个都运行了一个 `NGINX web` 服务器。获取 `nginx Service` 和 `web StatefulSet` 来验证是否成功的创建了它们。

```
$ kubectl get service nginx
NAME      CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
nginx     None         <none>        80/TCP    12s
$ kubectl get statefulset web
NAME      DESIRED   CURRENT   AGE
web       2         1         20s
```

## 使用稳定的网络身份标识

每个 `Pod` 都拥有一个基于其顺序索引的稳定的主机名。使用 `kubectl exec` 在每个 `Pod` 中执行 `hostname` 。

```
$ for i in 0 1; do kubectl exec web-$i -- sh -c 'hostname'; done
web-0
web-1
```

然后我们使用 `kubectl run` 运行一个提供 `nslookup` 命令的容器。通过对 `Pod` 的主机名执行 `nslookup`，你可以检查他们在集群内部的 `DNS` 地址。

```
$ kubectl run -i --tty --image busybox dns-test --restart=Never --rm /bin/sh 
nslookup web-0.nginx
Server:    10.0.0.10
Address 1: 10.0.0.10 kube-dns.kube-system.svc.cluster.local

Name:      web-0.nginx
Address 1: 10.244.1.6

nslookup web-1.nginx
Server:    10.0.0.10
Address 1: 10.0.0.10 kube-dns.kube-system.svc.cluster.local

Name:      web-1.nginx
Address 1: 10.244.2.6
```

`headless service` 的 `CNAME` 指向 `SRV` 记录（记录每个 `Running` 和 `Ready` 状态的 `Pod`）。`SRV` 记录指向一个包含 `Pod IP` 地址的记录表项。

然后我们再来看下删除 `StatefulSet` 下面的 `Pod`：

在一个终端中查看 `StatefulSet` 的 `Pod`：

```
$ kubectl get pod -w -l role=stateful
```

在另一个终端中使用 `kubectl delete` 删除 `StatefulSet` 中所有的 `Pod`。

```
$ kubectl delete pod -l role=stateful
pod "web-0" deleted
pod "web-1" deleted
```

等待 `StatefulSet` 重启它们，并且两个 `Pod` 都变成 `Running` 和 `Ready` 状态。

```
$ kubectl get pod -w -l app=nginx
NAME      READY     STATUS              RESTARTS   AGE
web-0     0/1       ContainerCreating   0          0s
web-0     1/1       Running   0          2s
web-1     0/1       Pending   0         0s
web-1     0/1       Pending   0         0s
web-1     0/1       ContainerCreating   0         0s
web-1     1/1       Running   0         34s
```
然后再次使用 `kubectl exec` 和 `kubectl run` 查看 `Pod` 的主机名和集群内部的 `DNS` 表项。

```
$ for i in 0 1; do kubectl exec web-$i -- sh -c 'hostname'; done
web-0
web-1
$ kubectl run -i --tty --image busybox dns-test --restart=Never --rm /bin/sh 
nslookup web-0.nginx
Server:    10.0.0.10
Address 1: 10.0.0.10 kube-dns.kube-system.svc.cluster.local

Name:      web-0.nginx
Address 1: 10.244.1.7

nslookup web-1.nginx
Server:    10.0.0.10
Address 1: 10.0.0.10 kube-dns.kube-system.svc.cluster.local

Name:      web-1.nginx
Address 1: 10.244.2.8
```

我们可以看到Pod 的序号、主机名、SRV 条目和记录名称没有改变，但和 Pod 相关联的 IP 地址可能会发生改变。所以说这就是为什么不要在其他应用中使用 `StatefulSet` 中的 `Pod` 的 `IP` 地址进行连接，这点很重要。一般情况下我们直接通过 SRV 记录连接就行：`web-0.nginx、web-1.nginx`，因为他们是稳定的，并且当你的 `Pod` 的状态变为 `Running `和` Ready` 时，你的应用就能够发现它们的地址。

同样我们可以查看 PV、PVC的最终绑定情况：


```
$ kubectl get pv
NAME      CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS    CLAIM               STORAGECLASS   REASON    AGE
pv001     1Gi        RWO            Recycle          Bound     default/www-web-0                            1h
pv002     1Gi        RWO            Recycle          Bound     default/www-web-1                            1h
$ kubectl get pvc
NAME        STATUS    VOLUME    CAPACITY   ACCESS MODES   STORAGECLASS   AGE
www-web-0   Bound     pv001     1Gi        RWO                           22m
www-web-1   Bound     pv002     1Gi        RWO                           22m
```

当然 `StatefulSet` 还拥有其他特性，在实际的项目中，我们还是很少回去直接通过 `StatefulSet` 来部署我们的有状态服务的，除非你自己能够完全能够 hold 住，对于一些特定的服务，我们可能会使用更加高级的 Operator 来部署，

### 比如 `etcd-operator`、`prometheus-operator `等等，这些应用都能够很好的来管理有状态的服务，而不是单纯的使用一个 `StatefulSet` 来部署一个 `Pod`就行，因为对于有状态的应用最重要的还是数据恢复、故障转移等等。












