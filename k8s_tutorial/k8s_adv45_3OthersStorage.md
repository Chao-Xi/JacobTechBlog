# 3种K8S存储：emptyDir、hostPath、local

Kubernetes支持几十种类型的后端存储卷，其中有几种存储卷总是给人一种分不清楚它们之间有什么区别的感觉，尤其是**local**与**hostPath**这两种存储卷类型，**看上去都像是node本地存储方案嘛**。当然，还另有一种volume类型是**emptyDir**，也有相近之处。

在Docker容器时代，我们就对Volume很熟悉了，一般来说我们是通过创建Volume数据卷，然后挂载到指定容器的指定路径下，以实现容器数据的持久化存储或者是多容器间的数据共享，当然这里说的都是单机版的容器解决方案。

进入到容器集群时代后，我们看到Kubernetes按时间顺序先后提供了`emptyDir`、`hostPath`和`local`的本地磁盘存储卷解决方案。

`emptyDir`、`hostPath`都是`Kubernetes`很早就实现和支持了的技术，`local volume`方式则是从k8s **v1.7**才刚刚发布的`alpha`版本，目前在k8s **v1.10**中发布了`local volume`的**beta**版本，部分功能在早期版本中并不支持。


在展开之前，我们先讨论一个问题，就是既然都已经实现容器云平台了，

## 0. 我们为什么还要关注这几款本地存储卷的货呢？

粗略归纳了下，有以下几个原因：

* 特殊使用场景需求，**如需要个临时存储空间**，运行`cAdvisor`需要能访问到`node`节点`/sys/fs/cgroup`的数据，**做本机单节点的k8s环境功能测试等等**。
* 容器集群只是做小规模部署，满足开发测试、集成测试需求。
* 作为分布式存储服务的一种补充手段，比如我在一台`node`主机上插了块`SSD`，准备给某个容器吃小灶。
* 目前主流的两个容器集群存储解决方案是`ceph`和`glusterfs`，二者都是典型的网络分布式存储，**所有的数据读、写都是对磁盘IO和网络IO的考验**，所以部署存储集群时至少要使用万兆的光纤网卡和光纤交换机。如果你都没有这些硬货的话，强上分布式存储方案的结果就是收获一个以”慢动作”见长的容器集群啦.
* 分布式存储集群服务的规划、部署和长期的监控、扩容与运行维护是专业性很强的工作，需要有专职的技术人员做长期的技术建设投入。

我们并不是说分布式存储服务不好，很多公司在云平台建设的实践中，往往是需要结合使用几种通用的与专用的存储解决方案，才能最终满足大部分的使用需求。

所以，如果这里有一款场景适合你的话，不妨了解一下这几款本地存储卷的功能特点、使用技巧与异同。

## emptyDir

`emptyDir`类型的`Volume`在`Pod`分配到`Node`上时被创建，`Kubernetes`会在`Node`上自动分配一个目录，因此无需指定宿主机`Node`上对应的目录文件。 

这个目录的初始内容为空，当`Pod`从`Node`上移除时，`emptyDir`中的数据会被永久删除。

> 注：容器的crashing事件并不会导致emptyDir中的数据被删除。

### 最佳实践

根据官方给出的最佳使用实践的建议，emptyDir可以在以下几种场景下使用：

* 临时空间，例如基于磁盘的合并排序
* 设置检查点以从崩溃事件中恢复未执行完毕的长计算
* 保存内容管理器容器从Web服务器容器提供数据时所获取的文件

默认情况下，`emptyDir`可以使用任何类型的由`node`节点提供的后端存储。

>如果你有特殊的场景，需要使用`tmpfs`作为`emptyDir`的可用存储资源也是可以的，只需要在创建`emptyDir`卷时增加一个`emptyDir.medium`字段的定义，并赋值为"Memory"即可。

> 注：在使用`tmpfs`文件系统作为`emptyDir`的存储后端时，如果遇到`node`节点重启，则`emptyDir`中的数据也会全部丢失。同时，你编写的任何文件也都将计入`Container`的内存使用限制。

### emptyDir volume 实验

我们在测试k8s环境中创建一个emptyDir volume的使用示例。

```
apiVersion: v1
kind: Pod
metadata:
	 name: test-pod
spec:
	containers:
	- image: busybox
	  name: test-emptydir
	  command: [ "sleep", "3600"]
	  volumeMounts:
	  - mountPath: /data
	    name: data-volum
	volumes:
	- name: data-volume
	  emptyDir: {}
```

查看下创建出来的pod，这里只截取了与`volume`有关的部分，其他无关内容直接省略：

```
# kubectl describe pod test-pod

Name:         test-pod
Namespace:    default
Node:         kube-node2/172.16.10.102
......
	Environment:    <none>
	Mounts:	
		/data from data-volume (rw)
......
Volumes:
	data-volume:
		Type:    EmptyDir(a temporary directory that shares a pod's lifetime)
		Medium:
......
```
可以进入到容器中查看下实际的卷挂载结果：

```
# kubectl exec -it test-pod -c test-emptydir /bin/sh
```

## hostPath

**`hostPath`类型则是映射`node`文件系统中的文件或者目录到`pod`里。**

在使用`hostPath`类型的存储卷时，也可以设置`type`字段，**支持的类型有文件、目录、File、Socket、CharDevice和BlockDevice。**

### 来自官网对hostPath的使用场景和注意事项的介绍

**使用场景：**

* 当运行的容器需要访问`Docker`内部结构时，如使用`hostPath`映射`/var/lib/docker`到容器；
* 当在容器中运行`cAdvisor`时，可以使用`hostPath`映射`/dev/cgroups`到容器中；

**注意事项：**

* 配置相同的`pod`（如通过podTemplate创建），**可能在不同的Node上表现不同，因为不同节点上映射的文件内容不同**
* 当`Kubernetes`增加了资源敏感的调度程序，`hostPath`使用的资源不会被计算在内
* 宿主机下创建的目录只有`root`有写权限。你需要让你的程序运行在`privileged container`上，或者修改宿主机上的文件权限。

### hostPath volume 实验

下面我们在测试k8s环境中创建一个hostPath volume使用示例。

```
apiVersion: v1
kind: Pod
metadata:
  name: test-pod2
spec:
  containers:
  - image: busybox
    name: test-hostpath
    command: [ "sleep", "3600" ]
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

查看下`pod`创建结果，观察`volumes`部分：

```
# kubectl describe pod test-pod2
Name:         test-pod2
Namespace:    default
Node:         kube-node2/172.16.10.102
......
    Mounts:
      /test-data from test-volume (rw)
......
Volumes:
  test-volume:
    Type:          HostPath (bare host directory volume)
    Path:          /data
    HostPathType:  Directory
......
```

我们登录到容器中，进入挂载的`/test-data`目录中，创建个测试文件。

```
# kubectl exec  -it test-pod2 -c test-hostpath /bin/sh
/ # echo 'testtesttest' > /test-data/test.log
/ # exit
```

我们在运行该`pod`的`node`节点上，可以看到如下的文件和内容。

```
[root@kube-node2 test-data]# cat /test-data/test.log
testtesttest
```

现在，我们把该pod删除掉，再看看node节点上的hostPath使用的目录与数据会有什么变化。

```
[root@kube-node1 ~]# kubectl delete pod test-pod2
pod "test-pod2" deleted
```

到运行原pod的node节点上查看如下。

```
[root@kube-node2 test-data]# ls -l
total 4
-rw-r--r-- 1 root root 13 Nov 14 00:25 test.log
[root@kube-node2 test-data]# cat /test-data/test.log
testtesttest
```

**在使用`hostPath volume`卷时，即便`pod`已经被删除了，`volume`卷中的数据还在！**

## 单节点的k8s本地测试环境与`hostPath volume`

有时我们需要搭建一个单节点的`k8s`测试环境，就利用到`hostPath`作为后端的存储卷，模拟真实环境提供`PV`、`StorageClass`和`PVC`的管理功能支持。

```
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  namespace: kube-system
  name: standard
  annotations:
    storageclass.beta.kubernetes.io/is-default-class: "true"
  labels:
    addonmanager.kubernetes.io/mode: Reconcile
provisioner: kubernetes.io/host-path
```

**该场景仅能用于单节点的k8s测试环境中**

## `emptyDir`和`hostPath`在功能上的异同分析

* 二者都是node节点的本地存储卷方式；
* `emptyDir`可以选择把数据存到tmpfs类型的本地文件系统中去，`hostPath`并不支持这一点；
* `hostPath`除了支持挂载目录外，还支持`File`、`Socket`、`CharDevice`和`BlockDevice`，**既支持把已有的文件和目录挂载到容器中，也提供了“如果文件或目录不存在，就创建一个”的功能**；
* emptyDir是临时存储空间，完全不提供持久化支持；
* **`hostPath`的卷数据是持久化在`node`节点的文件系统中的，即便`pod`已经被删除了，`volume`卷中的数据还会留存在`node`节点上；**

## `local volume`的概念

这是一个很新的存储类型，建议在k8s v1.10+以上的版本中使用。该local volume类型目前还只是beta版。

* `Local volume` 允许用户通过标准`PVC`接口以简单且可移植的方式访问`node`节点的本地存储。
* `PV`的定义中需要包含描述节点亲和性的信息，`k8s`系统则使用该信息将容器调度到正确的node节点。


### 配置要求

* 使用`local-volume`插件时，要求使用到了存储设备名或路径都相对固定，不会随着系统重启或增加、减少磁盘而发生变化。
* 静态`provisioner`配置程序仅支持发现和管理挂载点（对于Filesystem模式存储卷）或符号链接（对于块设备模式存储卷）。 对于基于本地目录的存储卷，必须将它们通过`bind-mounted`的方式绑定到发现目录中。


### StorageClass与延迟绑定

官方推荐在使用`local volumes`时，创建一个`StorageClass`并把`volumeBindingMode`字段设置为**`“WaitForFirstConsumer”`**。

虽然`local volumes`还不支持动态的`provisioning`管理功能，但我们仍然可以创建一个`StorageClass`并使用延迟卷绑定的功能，将`volume binding`延迟至`pod scheduling`阶段执行。

这样可以确保`PersistentVolumeClaim`绑定策略将`Pod`可能具有的任何其他`node`节点约束也进行评估，**例如节点资源要求、节点选择器、Pod亲和性和Pod反亲和性**。

```
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
```

* `provisioner: kubernetes.io/no-provisioner` 还不支持动态的`provisioning`管理功能
* `volumeBindingMode: WaitForFirstConsumer` 使用延迟卷绑定的功能，将`volume binding`延迟至`pod scheduling`阶段执行

### 外部static provisioner

配置`local volume`后，**可以使用一个外部的静态配置器来帮助简化本地存储的管理**。 

`Provisioner` 配置程序将通过为每个卷创建和清理`PersistentVolumes`来管理发现目录下的卷。

`Local storage provisioner`要求管理员在每个节点上预配置好`local volumes`，并指明该`local volume`是属于以下哪种类型：

* `Filesystem volumeMode (default) PVs` - **需要挂载到发现目录下面**。
* `Block volumeMode PVs` - 需要在发现目录下创建一个指向节点上的块设备的符号链接。

一个`local volume`，可以是挂载到node本地的磁盘、磁盘分区或目录。

**`Local volumes`虽然可以支持创建静态`PersistentVolume`，但到目前为止仍不支持动态的PV资源管理**。

这意味着，你需要自己手动去处理部分`PV`管理的工作，但考虑到至少省去了在创建`pod`时手写`PV YAML`配置文件的工作，这个功能还是很值得的。

### 创建基于Local volumes的PV的示例

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: example-pv
spec:
  capacity:
    storage: 100Gi
  volumeMode: Filesystem
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  storageClassName: local-storage
  local:
    path: /mnt/disks/ssd1
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - example-node
```

* **`nodeAffinity`字段是必须配置的**，`k8s`依赖于这个标签为你定义的`Pods`在正确的`nodes`节点上找到需要使用的`local volumes`。
* 使用`volumeMode`字段时，需要启用`BlockVolume` 这一Alpha feature特性。
* `volumeMode`字段的默认值是`Filesystem`，但也支持配置为`Block`，这样就会把`node`节点的`local volume`作为容器的一个裸块设备挂载使用。

### 数据安全风险

`local volume`仍受node节点可用性方面的限制，因此并不适用于所有应用程序。 **如果node节点变得不健康，则`local volume`也将变得不可访问，使用这个`local volume`的Pod也将无法运行。** 

使用`local volumes`的应用程序必须能够容忍这种降低的可用性以及潜在的数据丢失，是否会真得导致这个后果将取决于`node`节点底层磁盘存储与数据保护的具体实现了。

## `hostPath`与`local volume`在功能上的异同分析

* 二者都基于node节点本地存储资源实现了容器内数据的持久化功能，都为某些特殊场景下提供了更为适用的存储解决方案；
* 前者时间很久了，所以功能稳定，而后者因为年轻，所以功能的可靠性与稳定性还需要经历时间和案例的历练，尤其是对Block设备的支持还只是alpha版本；
* 二者都为k8s存储管理提供了PV、PVC和StorageClass的方法实现；
* **`local volume`实现的`StorageClass`不具备完整功能，目前只支持卷的延迟绑定；**
* **`hostPath`是单节点的本地存储卷方案，不提供任何基于`node`节点亲和性的`pod`调度管理支持；**
* **`local volume`适用于小规模的、多节点的`k8s`开发或测试环境，尤其是在不具备一套安全、可靠且性能有保证的存储集群服务时；**


## local volume的安装配置方法

local-volume项目及地址：[https://github.com/kubernetes-incubator/external-storage/tree/master/local-volume](https://github.com/kubernetes-incubator/external-storage/tree/master/local-volume)

### Step 1：配置k8s集群使用本地磁盘存储

如果使用block块设备，则需要启用Alpha的功能特性：`k8s v1.10+`

```
$ export KUBE_FEATURE_GATES="BlockVolume=true"
```

> 注：如果是已经部署好的k8s v1.10+集群，需要为几个主要组件均开启对该特性的支持后，才能使用block块设备功能。如果k8s是低于1.10版本，则还需要启用其它的几个功能特性，因为在低版本中这些功能特性还都是alpha版本的。

根据大家搭建k8s的方法的不同，下面提供了四种情况下的配置说明。



#### Option 1: GCE（Google Compute Engine）集群

使用`kube-up.sh`启动的`GCE`集群将自动格式化并挂载所请求的`Local SSDs`，因此您可以使用预先生成的部署规范部署配置器并跳至步骤4，除非您要自定义配置器规范或存储类。

```
$ NODE_LOCAL_SSDS_EXT=<n>,<scsi|nvme>,fs cluster/kube-up.sh
$ kubectl create -f provisioner/deployment/kubernetes/gce/class-local-ssds.yaml
$ kubectl create -f provisioner/deployment/kubernetes/gce/provisioner_generated_gce_ssd_volumes.yaml
```

#### Option 2: GKE（Google Kubernetes Engine）集群

GKE集群将自动格式化并挂载所请求的Local SSDs。在[`GKE document`](https://blog.csdn.net/watermelonbig/article/details/84108424#https://cloud.google.com/kubernetes-engine/docs/concepts/local-ssd)中有更详细的说明。
然后，跳至步骤4。

#### Option 3: 使用裸机环境搭建的集群

1. 根据应用程序的使用要求对每个节点上的本地数据磁盘进行分区和格式化。
2. 定义一个`StorageClass`，并在一个发现目录下挂载所有要使用的存储文件系统。 发现目录是在`configmap`中指定，见下文。
3. 如上所述，使用`KUBE_FEATURE_GATES`配置`Kubernetes API Server`, `controller-manager`, `scheduler`, 和所有节点上的 `kubelets`。
4. 如果没有使用默认的Kubernetes调度程序策略，则必须启用以下特性：
  * (1) `Pre-1.9: NoVolumeBindConflict`
  * (2) `1.9+: VolumeBindingChecker`

> 说明：在我们使用测试环境中，是一套3节点的k8s测试环境，为了模拟测试`local volume`功能，直接结合使用了下面option4中提供的`ram disks`测试方法，创建了3个tmpfs格式的文件系统挂载资源。

#### Option 4: 使用一个本机单节点的测试集群

* （1）创建`/mnt/disks`目录，并在该目录下挂载几个子目录。下面是使用三个`ram disks`做一个真实存储卷的模拟测试。

```
$ mkdir /mnt/fast-disks
$ for vol in vol1 vol2 vol3;
do
    mkdir -p /mnt/fast-disks/$vol
    mount -t tmpfs $vol /mnt/fast-disks/$vol
done
```

* （2）创建单机k8s本地测试集群

```
$ ALLOW_PRIVILEGED=true LOG_LEVEL=5 FEATURE_GATES=$KUBE_FEATURE_GATES hack/local-up-cluster.sh
```

### Step 2: 创建一个StorageClass (1.9+)

要延迟卷绑定直到`pod`调度并处理单个`pod`中的多个本地`PV`，必须创建`StorageClass`并将`volumeBindingMode`设置为`WaitForFirstConsumer`。

```
# Only create this for K8s 1.9+
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-disks
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
# Supported policies: Delete, Retain
reclaimPolicy: Delete
```

```
$ kubectl create -f provisioner/deployment/kubernetes/example/default_example_storageclass.yaml
```

* `default_example_storageclass.yaml`文件请到`local volume`项目文件中查找需要使用的`yaml`文件

### Step 3: 创建local persistent volumes

#### Option 1: local volume static provisioner 方式

配置一个外部的静态配置器。

* （1）生成`Provisioner`的`ServiceAccount`，`Roles`，`DaemonSet`和`ConfigMap`规范，并对其进行自定义配置。此步骤使用helm模板生成需要的配置规格。 有关设置说明，请参阅[`helm README`](https://github.com/kubernetes-incubator/external-storage/tree/master/local-volume/helm)。
使用默认值生成`Provisioner`的配置规格，请运行：

```
helm template ./helm/provisioner > ./provisioner/deployment/kubernetes/provisioner_generated.yaml
```

* 这里是将模板经过渲染后得到最终使用的各项资源定义文件。

如果是使用自定义的配置文件的话：

```
helm template ./helm/provisioner --values custom-values.yaml > ./provisioner/deployment/kubernetes/provisioner_generated.yaml
```

* （2）部署Provisioner

如果用户对`Provisioner`的`yaml`文件的内容感到满意，就可以使用`kubectl`创建`Provisioner`的`DaemonSet`和`ConfigMap`了。

```
# kubectl create -f ./provisioner/deployment/kubernetes/provisioner_generated.yaml
configmap "local-provisioner-config" created
daemonset.extensions "local-volume-provisioner" created
serviceaccount "local-storage-admin" created
clusterrolebinding.rbac.authorization.k8s.io "local-storage-provisioner-pv-binding" created
clusterrole.rbac.authorization.k8s.io "local-storage-provisioner-node-clusterrole" created
clusterrolebinding.rbac.authorization.k8s.io "local-storage-provisioner-node-binding" created
```

* （3）检查已自动发现的local volumes

一旦启动，外部`static provisioner`将发现并自动创建出 `local-volume PVs`。
我们查看下上面测试中创建出的PVs有哪些：

```
# kubectl get pv
NAME                CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM     STORAGECLASS   REASON    AGE
local-pv-436f0527   495Mi      RWO            Delete           Available             fast-disks               2m
local-pv-77a4ffb0   495Mi      RWO            Delete           Available             fast-disks               2m
local-pv-97f7ec5c   495Mi      RWO            Delete           Available             fast-disks               2m
local-pv-9f0ddba3   495Mi      RWO            Delete           Available             fast-disks               2m
local-pv-a0dfdc91   495Mi      RWO            Delete           Available             fast-disks               2m
local-pv-a52333e3   495Mi      RWO            Delete           Available             fast-disks               2m
local-pv-bed86926   495Mi      RWO            Delete           Available             fast-disks               2m
local-pv-d037a0d1   495Mi      RWO            Delete           Available             fast-disks               2m
local-pv-d26c3252   495Mi      RWO            Delete           Available             fast-disks               2m
```

* 因为是有3个`node`节点，每个上面的`/mnt/fast-disks`自动发现目录下挂载了`3`个文件系统，所以这里查询的结果是生成了`9`个PVs

查看某一个PV的详细描述信息：

```
# kubectl describe pv local-pv-436f0527
Name:              local-pv-436f0527
Labels:            <none>
Annotations:       pv.kubernetes.io/provisioned-by=local-volume-provisioner-kube-node2-c3733876-b56f-11e8-990b-080027395360
Finalizers:        [kubernetes.io/pv-protection]
StorageClass:      fast-disks
Status:            Available
Claim:             
Reclaim Policy:    Delete
Access Modes:      RWO
Capacity:          495Mi
Node Affinity:     
  Required Terms:  
    Term 0:        kubernetes.io/hostname in [kube-node2]
Message:           
Source:
    Type:  LocalVolume (a persistent volume backed by local storage on a node)
    Path:  /mnt/fast-disks/vol2
Events:    <none>
```

此时就可以直接通过引用名为`fast-disks`的`storageClassName`名称来声明使用上述`PV`并将其绑定到`PVC`。

#### Option 2: 手动创建 local persistent volume

参照前文介绍`local volume`概念的章节中已经讲解过的`PersistentVolume`使用示例。

### Step 4: 创建 local persistent volume claim

```
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: example-local-claim
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 50Mi
  storageClassName: fast-disks
```

* 请在使用时替换为您实际的存储容量需求和`storageClassName`值。

```
# kubectl create -f local-pvc.yaml
persistentvolumeclaim "example-local-claim" created

# kubectl get pvc
NAME                  STATUS    VOLUME    CAPACITY   ACCESS MODES   STORAGECLASS   AGE
example-local-claim   Pending  

 # kubectl describe pvc example-local-claim
Name:          example-local-claim
Namespace:     default
StorageClass:  fast-disks
Status:        Pending
Volume:        
Labels:        <none>
Annotations:   <none>
Finalizers:    [kubernetes.io/pvc-protection]
Capacity:      
Access Modes:  
Events:
  Type    Reason                Age               From                         Message
  ----    ------                ----              ----                         -------
  Normal  WaitForFirstConsumer  6s (x6 over 59s)  persistentvolume-controller  waiting for first consumer to be created before binding
```

我们可以看到存储卷延迟绑定的效果，在绑定到容器前，该`PVC`的状态会是`pending`

### Step 5：创建一个测试Pod并引用上面创建的PVC

```
apiVersion: v1
kind: Pod
metadata:
  name: local-pvc-pod
spec:
  containers:
  - image: busybox
    name: test-local-pvc
    command: [ "sleep", "3600" ]
    volumeMounts:
    - mountPath: /data
      name: data-volume
  volumes:
  - name: data-volume
    persistentVolumeClaim:
      claimName: example-local-claim
```

创建并查看：

```
# kubectl create -f example-local-pvc-pod.yaml
pod "local-pvc-pod" created

# kubectl get pods -o wide
NAME                             READY     STATUS    RESTARTS   AGE       IP            NODE
client1                          1/1       Running   67         64d       172.30.80.2   kube-node3
local-pvc-pod                    1/1       Running   0          2m        172.30.48.6   kube-node1
```

查看`pod`中容器挂载`PVC`的配置详情，这里只截取了部分信息：

```
# kubectl describe pod local-pvc-pod
Name:         local-pvc-pod
Namespace:    default
Node:         kube-node1/172.16.10.101
Start Time:   Thu, 15 Nov 2018 16:39:30 +0800
Labels:       <none>
Annotations:  <none>
Status:       Running
IP:           172.30.48.6
Containers:
  test-local-pvc:
......
    Mounts:
      /data from data-volume (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-qkhcf (ro)
Conditions:
  Type           Status
  Initialized    True
  Ready          True
  PodScheduled   True
Volumes:
  data-volume:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  example-local-claim
    ReadOnly:   false
......
```

进入容器中查看挂载的数据卷：

```
[root@kube-node1 ~]# kubectl exec -it local-pvc-pod -c test-local-pvc /bin/sh
/ # ls
bin   data  dev   etc   home  proc  root  sys   tmp   usr   var
/ # df -h
Filesystem                Size      Used Available Use% Mounted on
overlay                  41.0G      8.1G     32.8G  20% /
tmpfs                    64.0M         0     64.0M   0% /dev
tmpfs                   495.8M         0    495.8M   0% /sys/fs/cgroup
vol3                    495.8M         0    495.8M   0% /data
--------------------- 
```

再回过头来看下PVC的状态，已经变成了Bound：

```
# kubectl get pvc
NAME                        STATUS    VOLUME              CAPACITY   ACCESS MODES   STORAGECLASS   AGE
example-local-claim         Bound     local-pv-a0dfdc91   495Mi      RWO            fast-disks     1h
```

## 一个关于`local volume`功能局限性问题的讨论

在上面的实验过程中不知道大家有没有发现一处问题，就是我们在定义PVC时是指定的申请`50Mi`的空间，而实际挂载到测试容器上的存储空间是`495.8M`，刚好是我们在某个node节点上挂载的一个文件系统的全部空间。

为什么会这样呢？这就是我们所使用的这个`local persistent volume`外部静态配置器的功能局限性所在了。它不支持动态的PV空间申请管理。


也就是说，虽然通过这个静态PV配置器，我们省去了手写PV YAML文件的痛苦，但仍然需要手工处理这项工作：

* 手工维护在`ConfigMap`中指定的自动发现目录下挂载的文件系统资源，或者是`block`设备的符号链接；
* 我们需要对能够使用的本地存储资源提前做一个全局的规划，然后划分为各种尺寸的卷后挂载到自动发现目录下，当然了只要是还有空闲存储资源，现有现挂载也是可以的。

**那如果以前给某容器分配的一个存储空间不够用了怎么办？**

给大家的一个建议是使用Linux下的LVM（逻辑分区管理）来管理每个node节点上的本地磁盘存储空间。

* 创建一个大的VG分组，把一个node节点上可以使用的存储空间都放进去；
* 按未来一段时间内的容器存储空间使用预期，提前批量创建出一部分逻辑卷LVs，都挂载到自动发现目录下去；
* 不要把VG中的存储资源全部用尽，预留少部分用于未来给个别容器扩容存储空间的资源；
* 使用lvextend为特定容器使用的存储卷进行扩容；

 
### 如果容器需要使用block块设备怎么配置

有几点会与上面的配置方法上不同。

**首先，是要在k8s主要的组件上均开启用于支持block块设备的特性。**

```
KUBE_FEATURE_GATES="BlockVolume=true"
```

其次是，定义一个`"Block"`类型的`volumeMode PV`C，为容器申请一个`"Block"`类型的`PV`。

```
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: example-block-local-claim
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 50Mi
  volumeMode: Block
  storageClassName: fast-disks
```

请特别注意，在上面的`yaml`文件中使用的`volumeMode`字段。

## Local volumes的最佳实践

* 为了更好的IO隔离效果，建议将一整块磁盘作为一个存储卷使用；
* 为了得到存储空间的隔离，建议为每个存储卷使用一个独立的磁盘分区；
* 在仍然存在指定了某个node节点的亲和性关系的旧PV时，要避免重新创建具有相同节点名称的node节点。 否则，系统可能会认为新节点包含旧的PV。
* 对于具有文件系统的存储卷，建议在fstab条目和该卷的mount安装点的目录名中使用它们的UUID（例如`ls -l /dev/disk/by-uuid`的输出）。 这种做法可确保不会安装错误的本地卷，即使其设备路径发生了更改（例如，如果`/dev/sda1`在添加新磁盘时变为`/dev/sdb1`）。 此外，这种做法将确保如果创建了具有相同名称的另一个节点时，该节点上的任何卷仍然都会是唯一的，而不会被误认为是具有相同名称的另一个节点上的卷。
* 对于没有文件系统的原始块存储卷，请使用其唯一ID作为符号链接的名称。 根据您的环境，/dev/disk/by-id/中的卷ID可能包含唯一的硬件序列号。 否则，应自行生成一个唯一ID。 符号链接名称的唯一性将确保如果创建了另一个具有相同名称的节点，则该节点上的任何卷都仍然是唯一的，而不会被误认为是具有相同名称的另一个节点上的卷。

## 停用local volume的方法

当您想要停用本地卷时，这是一个可行的工作流程。

* 关闭使用这些卷的Pods；
* 从`node`节点上移除`local volumes`（比如`unmounting`, 拔出磁盘等等）；
* 手动删除相应的PVCs对象；
* Provisioner将尝试清理卷，但会由于卷不再存在而失败；
* 手动删除相应的PVs对象。
  * 注：以上工作也是拜我们所使用的外部静态配置器所赐。

