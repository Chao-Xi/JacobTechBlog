# Preparation for Microsoft interviews on May 14, 2019

## 持久化存储

### 搞定持久化存储

* `PV`在最一开始是设计成了一个需要管理员预先分配的存储块。**引入`Storage Class`和`Provisioner`之后，用户可以动态地供应`PV`。**
* `PVC`是对`PV`的请求，**当和`Storage Class`一起使用时，它将触发与相匹配PV的动态供应。**
* `PV`和`PVC`总是一一对应的。
* **`Provisioner`是给用户提供`PV`的插件。它可以把管理员从为持久化创建工作负载的繁重角色中解脱出来。**
* `Storage Class`是`PV`的分类器。相同的`Storage Class`中的`PV`可以共享一些属性。**在大多数情况下，`Storage Class`和`Provisioner`一起使用时，可以把它当作具有预定义属性的`Provisioner`。** 因此，当用户请求它时，它能够用这些预定义的属性动态地提供PV。


**持久化数据的多种方式**

* Volume方式
* PV方式
* Provisioner方式: `kubernetes.io/aws-ebs`是一个Kubernetes中用于EBS的内置`Provisioner`。

**你可以用`Provisioner kubernetes.io/aws-ebs`来创建一个`Storage Class`，通过`Storage Class`创建`PVC`。`Kubernetes`会自动为你创建相对应的`PV`。** 接下来指定PVC为volume就可以在pod中使用了。

**Provisioner(storageclass) > Persistent Volume > Volume**

**详细来说：**

* **对于`Config Map`、`Downward API`、`Secret`或者`Projected`，请使用`Volume`，因为PV不支持它们。**
* 对于`EmptyDir`，直接使用`Volume`，或者使用`Host Path`来代替。
* 对于`Host Path`，通常是直接使用`Volume`，因为它绑定到一个特定的节点，并且节点之间它是同构的。

### PV and PVC

`PV` 的全称是：`PersistentVolume（持久化卷`，是对**底层的共享存储的一种抽象**，`PV` 由管理员进行`创建和配置`，它和具体的底层的共享存储技术的实现方式有关，比如 `Ceph`、`GlusterFS`、`NFS` 等，**都是通过插件机制完成与共享存储的对接。**

`PVC` 的全称是：`PersistentVolumeClaim`（持久化卷声明），`PVC` 是用户存储的一种声明，`PVC` 和 `Pod` 比较类似，`Pod` 消耗的是节点，`PVC` 消耗的是 `PV` 资源，`Pod` 可以请求 `CPU` 和`内存`，而 `PVC` 可以请求特定的存储空间和访问模式。对于真正使用存储的用户不需要关心底层的存储实现细节，只需要直接使用 `PVC` 即可。

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name:  pv1
spec:
  capacity:
    storage: 1Gi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Recycle
  nfs:
    path: /data/k8s
    server: 192.168.1.138
```

* **Capacity（存储能力）**
* **AccessModes（访问模式）: ReadWriteOnce（RWO),ReadWriteMany（RWX)**
* **persistentVolumeReclaimPolicy（回收策略）**
  * Retain **（保留）**- **保留数据，需要管理员手工清理数据**
  * Recycle（**回收**）- **清除 PV 中的数据，效果相当于执行 `rm -rf /thevolume/*`**
  * Delete（**删除**）- **与 PV 相连的后端存储完成 volume 的删除操作**，当然这常见于云服务商的存储服务，比如 AWS EBS。
* `PV`状态
  * Available（可用）：表示可用状态，还未被任何 PVC 绑定
  * Bound（已绑定）：**表示 PV 已经被 PVC 绑定**
  * Released（已释放）：**PVC 被删除，但是资源还未被集群重新声明**
  * Failed（失败）： 表示该 PV 的自动回收失败

**pvc**

```
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: pvc-nfs
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi

```

**pv和pvc的挂载**

* PVC会和PV自动匹配，去寻找available的pv
* 用label和selector

```
 selector:
    matchLabels:
      app: nfs
```

### StorageClass 的使用

* 创建 Provisioner

> 要使用 StorageClass，我们就得安装对应的自动配置程序，比如我们这里存储后端使用的是 nfs，那么我们就需要使用到一个 nfs-client 的自动配置程序，我们也叫它 Provisioner，这个程序使用我们已经配置好的 nfs 服务器，来自动创建持久卷，也就是自动帮我们创建 PV。

* 第一步：配置 `Deployment`，将里面的对应的参数替换成我们自己的 `nfs` 配置（nfs-client.yaml）

```
spec:
      serviceAccountName: nfs-client-provisioner
      containers:
        - name: nfs-client-provisioner
```

* 第二步：将环境变量 `NFS_SERVER` 和 `NFS_PATH` 替换，当然也包括下面的 `nfs` 配置，我们可以看到我们这里使用了一个名为 `nfs-client-provisioner` 的`serviceAccount`，所以我们也需要创建一个 sa，然后绑定上对应的权限

```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: nfs-client-provisioner
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
--- 
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
```

* 第三步：`nfs-client` 的 `Deployment` 声明完成后，我们就可以来创建一个`StorageClass`对象了

```
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: course-nfs-storage
provisioner: fuseim.pri/ifs #
```

**在这个PVC对象中添加一个声明StorageClass对象的标识，这里我们可以利用一个annotations属性来标识，如下**

```
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: test-pvc
  annotations:
    volume.beta.kubernetes.io/storage-class: "course-nfs-storage"
```

**对于 StorageClass 多用于 StatefulSet 类型的服务。**

### Pod 中挂载单个文件的方法

**我们希望将文件挂载到某个目录，但希望只是挂载该文件，不要影响挂载目录下的其他文件。**

**可以用`subPath`，`subPath`的目的是为了在单一`Pod`中多次使用同一个`volume`而设计的。**

* 比如我们要通过`ConfigMap`的形式挂载 `Nginx` 的配置文件
* 通过文件创建`ConfigMap`对象：`$ kubectl create configmap confnginx --from-file=nginx.conf
`
* 创建一个 `nginx` 的 `Pod`，通过上面的 `configmap` 挂载 `nginx.conf` 配置文件，保存为 `nginx.yaml`：

```
  spec:
  	volumeMounts:
    	- name: nginx-config
       mountPath: /etc/nginx/nginx.conf
       subPath: nginx.conf
   volumes:
     - name: nginx-config
       configMap:
         name: confnginx
```

### 几款本地存储卷

### 1.emptyDir

`emptyDir`类型的`Volume`在`Pod`分配到`Node`上时被创建，`Kubernetes`会在`Node`上自动分配一个目录，因此无需指定宿主机`Node`上对应的目录文件。 

这个目录的初始内容为空，当`Pod`从`Node`上移除时，`emptyDir`中的数据会被永久删除。

> 注：容器的crashing事件并不会导致emptyDir中的数据被删除。

```
spec:
	volumeMounts:
	- mountPath: /data
	  name: data-volum
volume:
	- name: data-volume
	  emptyDir: {}
```

### 2.hostPath


**`hostPath`类型则是映射`node`文件系统中的文件或者目录到`pod`里。**

在使用`hostPath`类型的存储卷时，也可以设置`type`字段，**支持的类型有文件、目录、File、Socket、CharDevice和BlockDevice。**

### 来自官网对hostPath的使用场景和注意事项的介绍

**使用场景：**

* 当运行的容器需要访问`Docker`内部结构时，如使用`hostPath`映射`/var/lib/docker`到容器；
* 当在容器中运行`cAdvisor`时，可以使用`hostPath`映射`/dev/cgroups`到容器中；

```
	volumeMounts:
	    - mountPath: /test-data
	      name: test-volume
volumes:
- name: test-volume
 hostPath:
  # directory location on host
  path: /data
  # this field is optional
  type: Directory
```
**在使用`hostPath volume`卷时，即便`pod`已经被删除了，`volume`卷中的数据还在！**


### emptyDir和hostPath在功能上的异同分析

* `emptyDir`是临时存储空间，完全不提供持久化支持；
* **`hostPath`的卷数据是持久化在node节点的文件系统中的，即便`pod`已经被删除了，volume卷中的数据还会留存在node节点上；**

### local volume的概念

这是一个很新的存储类型，建议在`k8s v1.10+`以上的版本中使用。该`local volume`类型目前还只是beta版。

* **Local volume 允许用户通过标准PVC接口以简单且可移植的方式访问node节点的本地存储。**
* **PV的定义中需要包含描述节点亲和性的信息，k8s系统则使用该信息将容器调度到正确的node节点。**


## 深入理解 POD

1. **apiVersion**，这里它的值是v1，这个版本号需要根据我们安装的kubernetes版本和资源类型进行变化的，记住不是写死的
2. **kind**，这里我们创建的是一个 Pod，当然根据你的实际情况，这里资源类型可以是 Deployment、Job、Ingress、Service 等待。
3. **metadata**：包含了我们定义的 Pod 的一些 meta 信息，比如名称、namespace、标签等等信息。
4. **spec**：包括一些 containers，storage，volumes，或者其他Kubernetes需要知道的参数，以及诸如是否在容器失败时重新启动容器的属性。你可以在特定Kubernetes API找到完整的Kubernetes Pod的属性。

### 静态 Pod

1. 静态 Pod 直接由特定节点上的`kubelet`进程来管理，不通过 `master` 节点上的`apiserver`。
2. **无法与我们常用的控制器`Deployment`或者`DaemonSet`进行关联**，**它由`kubelet`进程自己来监控，当`pod`崩溃时重启该`pod`，`kubelet`也无法对他们进行健康检查**。
3. **静态 `pod` 始终绑定在某一个`kubelet`，并且始终运行在同一个节点上。** `kubelet`会自动为每一个静态 pod 在 `Kubernetes` 的 `apiserver` 上创建一个镜像 `Pod（Mirror Pod`），因此我们可以在 `apiserver `中查询到该 pod，但是不能通过 apiserver 进行控制（例如不能删除

**创建静态 Pod 有两种方式：`配置文件` 和 `HTTP` 两种方式**

* 配置文件

```
kubelet --pod-manifest-path=<the directory>
```

来启动`kubelet`进程，`kubelet` 定期的去扫描这个目录，根据这个目录下出现或消失的 `YAML/JSON` 文件来创建或删除静态 `pod`。

```
$ sudo vi /etc/systemd/system/kubelet.service

--experimental-bootstrap-kubeconfig=/etc/kubernetes/bootstrap.kubeconfig \
  --kubeconfig=/etc/kubernetes/kubelet.kubeconfig \
  --pod-manifest-path=/etc/kubernetes/manifests \
```

```
$ sudo systemctl daemon-reload
$ sudo systemctl enable kubelet
$ sudo systemctl restart kubelet
```

### Pod Hook

实际上 `Kubernetes` 为我们的容器提供了生命周期钩子的，就是我们说的`Pod Hook`，`Pod Hook` 是由 `kubelet` 发起的，**当容器中的进程启动前或者容器中的进程终止之前运行，这是包含在容器的生命周期之中**。我们可以同时为 `Pod` 中的所有容器都配置 `hook`。

`Kubernetes` 为我们提供了两种钩子函数：

* `PostStart`：**这个钩子在容器创建后立即执行**。但是，并不能保证钩子将在容器`ENTRYPOINT`之前运行，因为没有参数传递给处理程序。主**要用于资源部署、环境准备等**。不过需要注意的是如果钩子花费太长时间以至于不能运行或者挂起， 容器将不能达到running状态。

* `PreStop`：**这个钩子在容器终止之前立即被调用**。**它是阻塞的，意味着它是同步的， 所以它必须在删除容器的调用发出之前完成。主要用于优雅关闭应用程序、通知其他系统等。** **如果钩子在执行期间挂起， Pod阶段将停留在`running`状态并且永不会达到failed状态。**


**如果`PostStart`或者`PreStop`钩子失败，它会杀死容器。** 所以我们应该让钩子函数尽可能的轻量。当然有些情况下，长时间运行命令是合理的， 比如在停止容器之前预先保存状态。

另外我们有两种方式来实现上面的钩子函数：

* `Exec` - **用于执行一段特定的命令，不过要注意的是该命令消耗的资源会被计入容器**。
* `HTTP` - **对容器上的特定的端点执行HTTP请求。**

**即在容器创建成功后，写入一句话到`/usr/share/message`文件中。**


```
lifecycle:
      postStart:
        exec:
          command: ["/bin/sh", "-c", "echo Hello from the postStart handler > /usr/share/message"]
```

**优雅删除资源对象**

```
lifecycle:
      preStop:
        exec:
          command: ["/usr/sbin/nginx","-s","quit"]
```

**`lifecycle => preStop => exec => command [""]`**


### Pod 的生命周期

`Pod` 的相位（`phase`）是 `Pod` 在其生命周期中的简单宏观概述。该阶段并不是对容器或 Pod 的综合汇总，也不是为了做为综合状态机。

下面是 `phase` 可能的值：

* 挂起（Pending）: `Pod` 已被 `Kubernetes` 系统接受，但有一个或者多个容器镜像尚未创建。
* 运行中（Running）
* 成功（Succeeded）
* 失败（Failed）
* 未知（Unknown）：**因为某些原因无法取得 `Pod` 的状态，通常是因为与 `Pod` 所在主机通信失败。**

**`Kubelet` 可以选择是否执行在容器上运行的两种探针执行和做出反应：**

* `livenessProbe`：**指示容器是否正在运行**。**如果存活探测失败，则 kubelet 会杀死容器，并且容器将受到其 `重启策略` 的影响**。如果容器不提供存活探针，则默认状态为 `Success`。
* `readinessProbe`：**指示容器是否准备好服务请求。如果就绪探测失败，端点控制器将从与 Pod 匹配的所有 Service 的端点中删除该 Pod 的 IP 地址。** 初始延迟之前的就绪状态默认为 `Failure`。如果容器不提供就绪探针，则默认状态为 `Success`。
* **如果您希望容器在探测失败时被杀死并重新启动，那么请指定一个存活探针**，并指定 `restartPolicy` 为 `Always` 或 `OnFailure`。
* 如果您希望容器能够自行维护，您可以指定一个`就绪探针`

#### 重启策略

**`PodSpec` 中有一个 `restartPolicy` 字段，可能的值为 `Always`、`OnFailure` 和 `Never`。默认为 `Always`。 `restartPolicy` 适用于 `Pod` 中的所有容器。**

**高级 `liveness` 探针示例**

```
livenessProbe:
      httpGet:
        # when "host" is not defined, "PodIP" will be used
        # host: my-host
        # when "scheme" is not defined, "HTTP" scheme will be used. Only "HTTP" and "HTTPS" are allowed
        # scheme: HTTPS
        path: /healthz
        port: 8080
        httpHeaders:
        - name: X-Custom-Header
          value: Awesome
      initialDelaySeconds: 15
      timeoutSeconds: 1
```

kubelet 通过使用 liveness probe 来确定你的应用程序是否正在运行，通俗点将就是是否还活着。一般来说，如果你的程序一旦崩溃了， Kubernetes 就会立刻知道这个程序已经终止了，然后就会重启这个程序。**而我们的 `liveness probe` 的目的就是来捕获到当前应用程序还没有终止，还没有崩溃，如果出现了这些情况，那么就重启处于该状态下的容器，使应用程序在存在 `bug` 的情况下依然能够继续运行下去。**

**kubelet 使用 `readiness probe` 来确定容器是否已经就绪可以接收流量过来了。这个探针通俗点讲就是说是否准备好了，现在可以开始工作了。** 只有当 Pod 中的容器都处于就绪状态的时候 kubelet 才会认定该 Pod 处于就绪状态，**因为一个 `Pod` 下面可能会有多个容器。当然 `Pod` 如果处于非就绪状态，那么我们就会将他从我们的工作队列(实际上就是我们后面需要重点学习的 Service)中移除出来，这样我们的流量就不会被路由到这个 Pod 里面来了。**

* **exec**：执行一段命令
* **http**：检测某个 http 请求
* **tcpSocket**：使用此配置， kubelet 将尝试在指定端口上打开容器的套接字。

```
livenessProbe:
      exec:
        command:
```
```
readinessProbe:
      tcpSocket:
        port: 8080
      initialDelaySeconds: 5
      periodSeconds: 10
    livenessProbe:
      tcpSocket:
        port: 8080
      initialDelaySeconds: 15
      periodSeconds: 20
```

* `timeoutSeconds`：**探测超时时间，默认1秒，最小1秒。**
* `successThreshold`：**探测失败后，最少连续探测成功多少次才被认定为成功。默认是 1，但是如果是liveness则必须是 1。最小值是 1**。
* `failureThreshold`：**探测成功后，最少连续探测失败多少次才被认定为失败。默认是 `3`，最小值是 `1`**


### Pod Init Container 详解

**`Init Container`就是用来做初始化工作的容器，可以是一个或者多个，如果有多个的话，这些容器会按定义的顺序依次执行，只有所有的`Init Container`执行完后，主容器才会被启动。** 我们知道一个Pod里面的所有容器是共享数据卷和网络命名空间的，所以`Init Container`里面产生的数据可以被主容器使用到的。

* 从上面这张图我们可以直观的看到`PostStart`和`PreStop`包括`liveness`和`readiness`是属于**主容器**的生命周期范围内的，
* 而`Init Container`是独立于主容器之外的，**当然他们都属于Pod的生命周期范畴之内的，现在我们应该明白`Init Container`和`钩子函数`之类的区别了吧。**

```
initContainers:
  - name: init-myservice
    image: busybox
    command: ['sh', '-c', 'until nslookup myservice; do echo waiting for myservice; sleep 2; done;']
```

**infra(pause container) + init container**  => **container lifecycle(poststart hook -> readiness+liveness probe -> prestop hook)**


## 理解 Kubernetes 的亲和性调度

**`nodeSelector`、`nodeAffinity`、`podAffinity`、`Taints`以及`Tolerations`用法**

```
$ kubectl get nodes --show-labels
$ kubectl label nodes 192.168.1.170 source=qikqiak

 nodeSelector:
    source: qikqiak
```
 
**`nodeAffinity`就是节点亲和性，相对应的是`Anti-Affinity`，就是反亲和性，这种方法比上面的`nodeSelector`更加灵活，它可以进行一些简单的逻辑组合了，**

不只是简单的相等匹配。 调度可以分成**软策略**和**硬策略**两种方式，

* **软策略**就是如果你没有满足调度要求的节点的话，POD 就会忽略这条规则，继续完成调度过程，**说白了就是满足条件最好了，没有的话也无所谓了的策略；**
* **硬策略**就比较强硬了，**如果没有满足条件的节点的话，就不断重试直到满足条件为止**，简单说就是你必须满足我的要求，不然我就不干的策略。

`nodeAffinity`就有两上面两种策略:

* `preferredDuringSchedulingIgnoredDuringExecution`: **软策略 preferred**
* `requiredDuringSchedulingIgnoredDuringExecution`: **硬策 required**

```
affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:          # 硬策略
        nodeSelectorTerms:
        - matchExpressions:
          - key: kubernetes.io/hostname
            operator: NotIn
            values:
            - 192.168.1.140
```

### podAffinity and podAntiAffinity


和nodeAffinity类似，podAffinity也有requiredDuringSchedulingIgnoredDuringExecution 和 preferredDuringSchedulingIgnoredDuringExecution 两种调度策略，**唯一不同的是如果要使用互斥性，我们需要使用`podAntiAffinity`字段**

```
podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        podAffinityTerm:
          labelSelector:
            matchExpressions:
            - key: app
              operator: In
              values:
              - node-affinity-pod
```

### 污点（Taints）与容忍（tolerations）

对于`nodeAffinity`无论是硬策略还是软策略方式，都是调度 `POD` 到预期节点上，而`Taints`恰好与之相反，如果一个节点标记为` Taints` ，除非 `POD` 也被标识为可以容忍污点节点，否则该 `Taints` 节点不会被调度pod。

```
$ kubectl taint nodes node02 test=node02:NoSchedule
node "node02" tainted
```

```
tolerations:
- key: "node-role.kubernetes.io/master"
  operator: "Exists"
  effect: "NoSchedule"
```

## K8S 伸缩问题

### HPA

**HPA在`kubernetes`集群中被设计成一个`controller`，我们可以简单的通过`kubectl autoscale`命令来创建一个HPA资源对象，`HPA Controller`默认`30`s轮询一次（可通`过kube-controller-manager`的标志`--horizontal-pod-autoscaler-sync-period`进行设置），查询指定的资源（RC或者Deployment）中Pod的资源使用率，并且与创建时设定的值和指标做对比，从而实现自动伸缩的功能**

```
$ sudo vi /etc/systemd/system/kube-controller-manager.service
```

**当你创建了HPA后，`HPA`会从`Heapster`或者用户自定义的`RESTClient`端获取每一个一个`Pod`利用率或原始值的平均值，然后和`HP`A中定义的指标进行对比，同时计算出需要伸缩的具体值并进行相应的操作**

* Heapster：仅支持CPU使用率
* 自定义监控

```
$ kubectl autoscale deployment hpa-nginx-deploy --cpu-percent=10 --min=1 --max=10
deployment "hpa-nginx-deploy" autoscaled
```

HPA 内部实现原理， 

**Heapster**  `- collect metrcis ->` **Pods(`kubelet/cadvisor`)**  `<---` **RC/Deplpoyment** `<---` **HPA**

**`HPA一Metrics Server` 的`API` 注册方式**

```
apiVersion: apiregistration.k8s.io/v1betal
kind: APIService
metadata: 
  name: v1beta1.metrics.k8s.io 
spec:
  service: 
    name: metrics-server
    namespace: kube-system
  group: metrics.k8s.io
  version: v1beta1
  insecureSkipTLSVerify: true
  groupPriorityMinimum: 100 
  versionPriority: 100 
```

### Cluster - Autoscaler

**`ClusterAutoscaler` - 集群节点伸缩的组件**

* `Cluster-Autoscaler`**扩容的条件是存在未调度的Pod**
* `Cluster-Autoscaler`**缩容的条件是节点利用率低于阈值**


## 常用对象操作:

### Service

* `ClusterIP`：通过集群的**内部 IP 暴露服务**，选择该值，**服务只能够在集群内部可以访问，这也是默认的`ServiceType`**。
* `NodePort`：通过每个 **`Node节点上的IP`** 和 **`静态端口（NodePort）`** 暴露服务。NodePort 服务会路由到 ClusterIP 服务，这个 ClusterIP 服务会自动创建。通过请求 : **可以从集群的外部访问一个 NodePort 服务**。
* `LoadBalancer`：**使用云提供商的负载局衡器，可以向外部暴露服务**。外部的负载均衡器可以路由到 `NodePort` 服务和 `ClusterIP` 服务，这个需要结合具体的云厂商进行操作。
* `ExternalName`：**通过返回 CNAME 和它的值，可以将服务映射到 `externalName` 字段的内容**（例如， `foo.bar.example.com`）。没有任何类型代理被创建，这只有 Kubernetes 1.7 或更高版本的 kube-dns 才支持。

```
  type: NodePort
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
    name: myapp-http
```
```
ports:
  - protocol: TCP
    port: 80
    targetPort: 9376
  clusterIP: 10.0.171.239
  loadBalancerIP: 78.11.24.19 #外部LB IP 
  type: LoadBalancer
```

```
spec:
  type: ExternalName
  externalName: my.database.example.com
```
当查询主机 `my-service.prod.svc.cluster.local` 时，集群的 `DNS` 服务将返回一个值为 `my.database.example.com` 的 CNAME 记录

### Kubernetes Deployment滚动升级

每一次对`Deployment`的操作，都会保存下来，变能方便的进行回滚操作了，另外对于每一次升级都可以随时暂停和启动，拥有多种升级方案：**`Recreate`删除现在的`Pod`，重新创建；`RollingUpdate`滚动升级，逐步替换现有`Pod`，对于生产环境的服务升级，显然这是一种最好的方式**

#### 滚动升级Deployment

```
minReadySeconds: 5
strategy:
  # indicate which strategy we want for rolling update
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1
    maxUnavailable: 1
```

* `minReadySeconds`: `Kubernetes`在等待设置的时间后才进行升级
* `maxSurge`: 升级过程中最多可以比原先设置多出的`POD`数量
* `maxUnavaible`: **升级过程中最多有多少个POD处于无法提供服务的状态**

* 查看状态：

```
$  kubectl rollout status deployment/nginx-deploy
```

* 暂停升级:

```
$ kubectl rollout pause deployment <deployment>
```

* 继续升级

```
$ kubectl rollout resume deployment <deployment>
```

* 回滚 Deployment

**首先，查看Deployment的升级历史：**

```
$ kubectl rollout history deployment nginx-deploy
$ kubectl rollout history deployment nginx-deploy --revision=2
```

**假如现在要直接回退到当前版本的前一个版本**

```
$ kubectl rollout undo deployment nginx-deploy
$ kubectl rollout undo deployment nginx-deploy --to-revision=2
```

### How secrets and configmap works in k8s

`Secret` 和 `ConfigMap` 之间最大的区别就是 `Secret` 的数据是用`Base64`编码混淆过的，不过以后可能还会有其他的差异，对于比较机密的数据（如API密钥）使用 `Secret` 是一个很好的做法，但是对于一些非私密的数据（比如数据目录）用 `ConfigMap` 来保存就很好。

```
$ kubectl create secret generic token --from-literal=TOKEN=abcd123456000
```

```
$ kubectl create configmap language --from-literal=LANGUAGE=English
```

**`env` : `valueFrom` : `secretKeyRef/configMapKeyRef` : `name:key:`**

#### Secret

pod一般3种方式使用secret

* 最为 `volume`中的文件挂载到`pod`中一个或多个容器
* 环境变量
* 当`kubelet`为`pod`拉取镜像时使用

**Secret - Opaque类型定义**

**`Opaque`类型数据是一个`map`类型， 要求`value`是`base64`编码格式**

```
apiVersion: v1
kind: Secret
metadata: 
  name: mysecret
type: Opaque
data:
	password: 
	username
```

**`Secret` 挂载到 `Volume`**

**`secret` 做为环境变量**

```
env:
	ValueFrom:
		secretKeyRef:
			name: token
          key: TOKEN
```

* **`dockerconfigjson`类型使用Secret使用**

```
apiVersion: v1 
kind: Pod 
metadata: 
  name: private-reg 
spec: 
  containers:  
  - name: private-reg-container 
    image: <your-private-image> 
  imagePullSecret:
  - name: regcred
```

### 使用 Docker 的环境变量

```
# 设置环境变量
ENV TOKEN abcdefg0000
ENV LANGUAGE English
```
### 使用 Kubernetes 的环境变量

```
 env:
        - name: TOKEN
          value: "abcd123456"
        - name: LANGUAGE
          value: "English"
```
 
### Kubernetes Downward API 基本用法

**如何在容器中获取 POD 的基本信息，其实kubernetes原生就提供了支持的，那就是`Downward API`。**

**`Downward API`提供了两种方式用于将 `POD` 的信息注入到容器内部：**

* **环境变量**：**用于单个变量，可以将 POD 信息和容器信息直接注入容器内部**。
* **Volume挂载**：**将 `POD` 信息生成为文件，直接挂载到容器内部中去**。

#### 环境变量的方式

```
 env:
      - name: POD_NAME
        valueFrom:
          fieldRef:
            fieldPath: metadata.name
      - name: POD_NAMESPACE
        valueFrom:
          fieldRef:
            fieldPath: metadata.namespace
```

```
$ kubectl logs test-env-pod -n kube-system | grep POD
POD_IP=172.17.0.15
POD_NAME=test-env-pod
POD_NAMESPACE=kube-system
```

#### Volume挂载

```
 volumeMounts:
      - name: podinfo
        mountPath: /etc/podinfo
    volumes:
    - name: podinfo
      downwardAPI:
        items:
        - path: "labels"
          fieldRef:
            fieldPath: metadata.labels
        - path: "annotations"
          fieldRef:
            fieldPath: metadata.annotations
```

### kubernetes 的资源配额控制器 `资源配额控制器(ResourceQuotaController)`


kubernetes主要有3个层级的资源配额控制：

* `容器`：可以对 `CPU` 和 `Memory` 进行限制
* `POD`：可以对一个 `POD` 内所有容器的的资源进行限制
* `Namespace`：为一个命名空间下的资源进行限制

`ResourceQuotaController`支持的配额控制资源主要包括：

**计算资源配额、存储资源配额、对象数量资源配额以及配额作用域，**

### RC、RS 使用方法

```
kind: ReplicationController
spec:
  replicas: 3
  selector:
    name: rc
```

### Job和CronJob 的使用方法

**注意`Job`的`RestartPolicy`仅支持`Never`和`OnFailure`两种，不支持`Always`，** 我们知道Job就相当于来执行一个批处理任务，执行完就结束了，如果支持Always的话是不是就陷入了死循环了？

**Job**

```
 spec:
      restartPolicy: Never
```

**CronJob**

CronJob其实就是在Job的基础上加上了时间调度，我们可以：在给定的时间点运行一个任务，也可以周期性地在给定时间点运行。这个实际上和我们Linux中的crontab就非常类似了。


```
spec:
  successfulJobsHistoryLimit: 10
  failedJobsHistoryLimit: 10
  schedule: "*/1 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
```

### Kubernetes RBAC

RBAC - 基于角色的访问控制

```
--authorization-mode=RBAC
```
```
$ vi /etc/systemd/system/kube-apiserver.service

 --authorization-mode=Node,RBAC \
```

#### RBAC API 对象

`Pods / ConfigMaps / Deployments / Nodes / Secrets / Namespaces`

**操作:**

`create / get / delete / list / update / edit / watch / exec`

`RoleBinding` 和 `ClusterRoleBinding`：角色绑定和集群角色绑定，**简单来说就是把声明的 `Subject` 和我们的 `Role` 进行绑定的过程(给某个用户绑定上操作的权限)，**

二者的区别也是作用范围的区别：RoleBinding 只会影响到当前 namespace 下面的资源操作权限，而 ClusterRoleBinding 会影响到所有的 namespace

```
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: nyjxi-role
  namespace: kube-system
rules:
- apiGroups: ["", "extensions", "apps"]
  resources: ["deployments", "replicasets", "pods"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"] # 也可以使用['*']
```

```
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: nyjxi-rolebinding
  namespace: kube-system
subjects:
- kind: User
  name: nyjxi
  apiGroup: ""
roleRef:
  kind: Role
  name: nyjxi-role
  apiGroup: ""
```

#### 创建一个只能访问某个 `namespace` 的`ServiceAccount`

```
$ kubectl create sa haimaxy-sa -n kube-system
```

```
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: haimaxy-sa-role
  namespace: kube-system
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
```

```
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: haimaxy-sa-rolebinding
  namespace: kube-system
subjects:
- kind: ServiceAccount
  name: haimaxy-sa
  namespace: kube-system
roleRef:
  kind: Role
  name: haimaxy-sa-role
  apiGroup: rbac.authorization.k8s.io
```

### Kubernetes 服务质量 Qos 解析

Pod 资源 requests 和 limits 如何配置?

**`QoS`是 `Quality of Service` 的缩写，即服务质量。**


**`QoS` 主要分为`Guaranteed`、`Burstable` 和 `Best-Effort`三类，优先级从高到低。**

* **Guaranteed(有保证的)**
  * Pod中的所有容器都且仅设置了 CPU 和内存的 limits
  * pod中的所有容器都设置了 CPU 和内存的 requests 和 limits ，且单个容器内的`requests==limits`（requests不等于0）

* **Burstable(不稳定的)**
  *  pod中只要有一个容器的`requests`和`limits`的设置不相同，该`pod`的`QoS`即为`Burstable`。

* **Best-Effort(尽最大努力)**
 * **如果Pod中所有容器的`resources`均未设置`requests`与`limits`，该`pod`的`QoS`即为`Best-Effort`。**

### namespace

* 将命名空间映射到团队或项目上
* 使用命名空间对生命周期环境进行分区
* 使用命名空间隔离不同的使用者


理解预配置的Kubernetes命名空间

* default：向集群中添加对象而不提供命名空间，这样它会被放入默认的命名空间中。
* kube-public：kube-public命名空间的目的是让所有具有或不具有身份验证的用户都能全局可读。
* kube-system：kube-system命名空间用于Kubernetes管理的Kubernetes组件，一般规则是，避免向该命名空间添加普通的工作负载。

**通过设置`Context`选择命名空间**

```
$ kubectl config get-contexts
CURRENT   NAME                          CLUSTER      AUTHINFO           NAMESPACE
*         kubernetes-admin@kubernetes   kubernetes   kubernetes-admin
```

```
$ kubectl config set-context $(kubectl config current-context) --namespace=demo-namespace
```

## K8S故障排查实训

* E2E测试及结果分析

### APIServer、ETCD异常

* **无法创建、更新、删除资源对象**
* 节点正常工作
* 已有资源对象正常工作，不受影响

* 1.`Check kube-apiserver log`

```
$ ps -elf | grep kube-apiserver | grep log
```

* 2.`check kube-apiserver docker process`

```
$ docker ps | grep kube-apiserver
```

* 3.Check **clusterStatus**

```
$ kubectl get cs
```

* 4.Check etcd status

```
$ docker ps | grep etcd
```

### Controller异常

* `deployment`、`rs`、`ds`等对象操作请求处理正常，但实际未生效
* **`Service`关联的后端pod变化，但`endpoint`不更新**

### Scheduler异常

**Pod长时间Pending，且无调度失败event信息**

### Master组件状态查询:`kubectl get cs`

### 节点异常原因排查

* 节点状态查询:`kubectl get nodes`

**定位方式**

* `kubectl describe node`查看异常事件
* `service status`查看系统进程状态
* `journalctl` 查看系统组件日志
* `top`查看系统`cpu`、内存
* du、df查看磁盘使用情况

```
kubectl describe node ecs-node-001
```

### 应用异常原因排查

* 已存在的POD数超过`resource-quota`限制

```
kubectl describe quota –n ${ns}
```

#### POD实例异常

1.状态检查

```
kubectl get/describe pod
```

2.Pending

* 可用资源不足:`describe pod`可看到调度失败`event`
* **不满足亲和性策略**
* **节点有`taints`**

3.Waiting

* 镜像下载失败
* 配置的`imagePullSecret`无法通过认证，查看环境是否存在可用的`dockerconfigjson`类型的secret
* **`imagePullPolicy`配置是否正确**


4.CrashBackoff

* **`kubectl logs` 查看容器日志**
* **`kubectl/docker exec`登录容器验证功能**
* 检查pod配置是否正确:command、liveness、readiness

### Service访问异常原因排查

**通过域名访问Service**

`nslookup`判断域名解析是否正常


**Service访问异常原因排查**

```
$ kubectl get svc -n test-service
$ kubectl get endpoints clusterip -n test-service
$ kubectl describe endpoints clusterip -n test-service
$ kubectl descibe svc clusterip -n test-service
$ kubectl get pods --selector=app=non-exist -n test-service
No resources found
$ kubectl get pods --show-labels -n test-service
```

### 常用kubectl命令行

```
$ kubectl -h
$ kubectl explain
```

#### 查看某个资源的定义和用法

```
$ kubectl explain
```

#### 查看Pod的状态

```
kubectl get pods
kubectl describe pods my-pod
```

#### 监控Pod状态的变化

```
kubectl get pod -w
```

#### 查看 Pod 的日志

```
$ kubectl logs my-pod -c my-container
$ kubectl logs -f my-pod -c my-container
```

#### 交互式 debug `exec // top`

```
kubectl exec my-pod -it /bin/bash
kubectl top pod POD_NAME --containers
```

### 强制删除一直处于Terminating状态的Pod

```
kubectl delete pod $POD_ID --force --grace-period=0
```

**二、直接删除etcd中的数据**

```
ETCDCTL_API=3 etcdctl del /registry/pods/default/pod-to-be-deleted-0
```


## K8S集训运维实训

### 控制节点滚动升级

* 升级`kubelet`
* 通过更新`manifest`升级控制组件

### 计算节点升级

```
kubectl drain

kubectl uncordon
```

**how to drain a node**

```
$ kubectl drain node-name --ignore-dameonsets=true

```

* **revoke the drained node "uncordon"**

```
$ kuectl uncordon node-name 
```

### 备份恢复

**周期性备份`ETCD`数据 => 生成snapshot**


## 服务发现

### 内部服务发现 kube-proxy 实现原理

`kube-proxy`的作用主要是负责`service`的实现，

**每台机器上都运行一个`kube-proxy`服务，它监听`API server`中`service`和`endpoint`的变化情况，并通过`iptables`等来为服务配置负载均衡(仅支持TCP和UDP)**


`kube-proxy`可以直接运行在物理机上，也可以以`static pod`或者`daemonset`的方式运行。

**具体来说，就是实现了内部从`pod`到`service`和外部的从`node port`向`service`的访问。**

```
ports:
    - port: 3306
      targetPort: 3306
      nodePort: 30964
  type: NodePort
  selector:
    mysql-service: "true"
```

kube-proxy当前支持一下几种实现:

* `userspace`:最早的负载均衡方案，
* `iptables`:目前推荐的方案，完全以`iptables`规则的方式来实现`service`负载均衡。**该方式最主要的问题是在服务多的时候产生太多的iptables规则，非增量式更新会引入一定的时延，大规模情况下有明显的性能问题**
* `ipvs`:为解决iptables模式的性能问题，v1.8新增了ipvs模式，**采用增量式更新，并可以保证service 更新期间连接保持不断开**


**`iptables`的方式则是利用了`linux`的`iptables`的`nat`转发进行实现。**

### 如何在 `kubernetes` 中开启 `ipvs` 模式

* ipvs 为大型集群提供了更好的可扩展性和性能
* ipvs 支持比 iptables 更复杂的复制均衡算法（最小负载、最少连接、加权等等）
* ipvs 支持服务器健康检查和连接重试等功能

`ipvs` 会使用 `iptables` 进行包过滤、SNAT、masquared(伪装)。

**具体来说，`ipvs` 将使用 `ipset` 来存储需要 `DROP`或 `masquared`的流量的源或目标地址，以确保 `iptables` 规则的数量是恒定的**，这样我们就不需要关心我们有多少服务了

1. `kube-proxy` 配置参数 `--masquerade-all=true`
2.  在 `kube-proxy` 启动时指定集群 `CIDR`
3. `kube-proxy` 使用 `ipvs` 模式
   * 确保 ipvs 需要的内核模块，需要下面几个模块：`ip_vs`、`ip_vs_rr`、`ip_vs_wrr`、`ip_vs_sh`、`nf_conntrack_ipv4`
   * **本地集群**: `export KUBE_PROXY_MODE=ipvs`
 
### 集群内部服务发现之 DNS

DNS 服务不是一个独立的系统服务，**而是作为一种 addon 插件而存在，也就是说不是 Kubernetes 集群必须安装的**，

现在比较推荐的两个插件：`kube-dns` 和 `CoreDNS`

```
$ kubeadm init --feature-gates=CoreDNS=true
```

* kubedns: kubedns 基于 SkyDNS 库，**通过 `apiserver` 监听 `Service` 和 `Endpoints` 的变更事件同时也同步到本地 `Cache`，实现了一个实时的 `Kubernetes` 集群内 `Service` 和 `Pod` 的 DNS服务发现**
* dnsmasq: `dsnmasq` 容器则实现了 DNS 的缓存功能(在内存中预留一块默认大小为 1G 的地方，保存当前最常用的 DNS 查询记录，如果缓存中没有要查找的记录，它会到 kubedns 中查询，并把结果缓存起来)，通过监听 ConfigMap 来动态生成配置
* sidecar: **`sidecar` 容器实现了可配置的 `DNS` 探测，并采集对应的监控指标暴露出来供 `prometheus` 使用**


#### 域名格式

**普通的 Service：** `servicename.namespace.svc.cluster.local` 会解析到 `Service` 对应的 `ClusterIP` 上

#### Headless Service：

`无头服务`，就是把 `clusterIP` 设置为 `None` 的，会被解析为指定 `Pod` 的 `IP` 列表，同样还可以通过**`podname.servicename.namespace.svc.cluster.local`**访问到具体的某一个 Pod。


## 外部服务发现
**`Ingress controller` 可以理解为一个监听器，通过不断地与 `kube-apiserver` 打交道，实时的感知后端 `service`、`pod` 的变化，当得到这些变化信息后，`Ingress controller` 再结合 `Ingress` 的配置，更新反向代理负载均衡器，达到服务发现的作用。**

```
kind: Ingress
spec:
  rules:
  - host: traefik.haimaxy.com
    http:
      paths:
      - backend:
          serviceName: traefik-ingress-service
          servicePort: 8080
```

### Ingress TLS 和 PATH 的使用

```
 rules:
  - host: example.haimaxy.com
    http:
      paths:
      - path: /s1
        backend:
          serviceName: svc1
          servicePort: 8080
      - path: /s2
        backend:
          serviceName: svc2
          servicePort: 8080
      - path: /
        backend:
          serviceName: svc3
          servicePort: 8080
```
 
**paths -> path**

### `Kubernetes Ingress` 使用 `Let's Encrypt` 自动化 `HTTPS`

**我们这里用来管理 `SSL/TLS` 证书的组件是 `Cert manager`，它对于每一个 `ingress endpoint` 将会自动创建一个新的证书，当 `certificates` 过期时还能自动更新，除此之外，`Cert manager` 也可以和其它的 `providers` 一起工作，例如 `HashiCorp Vault`。为了方便我们这里使用Helm来部署即**可。

### `nginx-ingress` 的安装使用

相对于 `traefik` 来说，`nginx-ingress` 性能更加优秀，但是配置比 `traefik` 要稍微复杂一点，当然功能也要强大一些，支持的功能多许多

注意我们在 Ingress 资源对象中添加了一个 `annotations：kubernetes.io/ingress.class: "nginx"`，这就是指定让这个 Ingress 通过 nginx-ingress 来处理。

```
annotations:
    kubernetes.io/ingress.class: "nginx"
```

