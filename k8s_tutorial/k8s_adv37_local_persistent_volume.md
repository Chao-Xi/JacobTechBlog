# Kubernetes Local Persistent Volume

本文分析了`hostPath volume`缺陷，然后对`local persistent volume`的使用场景、基本的工作机制进行了分析，介绍了使用时的注意事项，并简单介绍`local volume manager`如何帮助`administrator`进行`local persistent volume`的生命周期管理的。

## hostPath volume 存在的问题

过去我们经常会通过 `hostPath volume` 让Pod能够使用本地存储，将Node文件系统中的文件或者目录挂载到容器内，但是`hostPath volume` 的使用是很难受的，并不适合在生产环境中使用。

我们先看看`hostPath Type`有哪些类型：

Value  | Behavior
------------- | -------------
 | Empty string (default) is for backward compatibility, which means that no checks will be performed before mounting the hostPath volume.
DirectoryOrCreate | If nothing exists at the given path, an empty directory will be created there as needed with permission set to 0755, having the same group and ownership with Kubelet.
Directory | A directory must exist at the given path
FileOrCreate | If nothing exists at the given path, an empty file will be created there as needed with permission set to 0644, having the same group and ownership with Kubelet.
File | A file must exist at the given path
Socket | A UNIX socket must exist at the given path
CharDevice | A character device must exist at the given path
BlockDevice | A block device must exist at the given path


看起来支持这么多`type`还是挺好的，但为什么说不适合在生产环境中使用呢？

* 由于集群内每个节点的差异化，要使用`hostPath Volume`，我们需要通过`NodeSelector`等方式进行精确调度，这种事情多了，你就会不耐烦了。
* 注意**`DirectoryOrCreate`**和**`FileOrCreate`**两种类型的`hostPath`，当`Node`上没有对应的`File/Directory`时，你需要保证`kubelet`有在`Node`上`Create File/Directory`的权限。
* 另外，如果`Node`上的文件或目录是由`root`创建的，挂载到容器内之后，你通常还要保证容器内进程有权限对该文件或者目录进行写入，比如你需要以`root`用户启动进程并运行于`privileged`容器，或者你需要事先修改好`Node`上的文件权限配置。
* **`Scheduler`并不会考虑`hostPath volume`的大小**，`hostPath`也不能申明需要的`storage size`，这样调度时存储的考虑，就需要人为检查并保证。
* `StatefulSet`无法使用`hostPath volume`，已经写好的使用共享存储的`Helm Chart`不能兼容`hostPath volume`，需要修改的地方还不少，这也挺难受的。

## local persistent volume 工作机制

`Local persistent volume` 就是用来解决 `hostPath volume`面临的 **portability, disk accounting,and scheduling** 的缺陷。`PV Controller` 和 `Scheduler` 会对 `local PV`做特殊的逻辑处理，以实现`Pod`使用本地存储时发生`Pod re-schedule的`情况下能再次调度到`local volume`所在的`Node`。


`local pv`在生产中使用，也是需要谨慎的，**毕竟它本质上还是使用的是节点上的本地存储，如果没有相应的存储副本机制，那意味着一旦节点或者磁盘异常，使用该`volume`的`Pod`也会异常，甚至出现数据丢失**，除非你明确知道这个风险不会对你的应用造成很大影响或者允许数据丢失。

那么通常什么情况会使用`Local PV`呢？

* 比如节点上的目录数据是从远程的网络存储上挂载或者预先读取到本地的，为了能加速`Pod`读取这些数据的速度，相当于起`Cache`作用，**这种情况下因为只读**，不存在惧怕数据丢失。**这种AI训练中存在需要重复利用并且训练数据巨大的时候可能会采取的方式**。
* 如果本地节点上目录/磁盘实际是具有副本/分片机制的分布式存储(比如`gluster, ceph`等)挂载过来的，这种情况也可以使用`local pv`。

**`Local volume` 允许挂载本地的`disk`,`partition`, `directory`到容器内某个挂载点。在`Kuberentes 1.11`仍然仅支持`local pv`的`static provision`，不支持`dynamic provision`。**

* `Kubernetes`使用`PersistentVolume`的`.spec.nodeAffinityfield`来描述`local volume`与`Node`的绑定关系。

* 使用 `volumeBindingMode: WaitForFirstConsumer` 的 `local-storage StorageClass` 来实现`PVC`的延迟绑定，使得`PV Controller`并不会立刻为`PVC`做`Bound`，而是等待某个需要使用该`local pv`的`Pod`完成调度后，才去做`Bound`。


下面是定义`local pv`的`Sample`：

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: example-pv
spec:
  capacity:
    storage: 100Gi
    # volumeMode field requires BlockVolume Alpha feature gate to be enabled.
    volumeMode: Filesystem
    accessModes:
    - ReadWriteOnce
    persistentVolumeReclaimPolicy: Retain
    storageClassName: local-storage
    local:
      path: /mnt/disks/ssd1
    nodeAffinity:
      required:
        nodeSelectorTerms
        - matchExpressions:
          - key: kubernetes.io/hostname
            operator: In
            values:
            - example-node
```

对应的	`local-storage storageClass` 定义如下：

```
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
```

## 使用`local persistent volume`注意事项

* 使用`local pv`时必须定义`nodeAffinity`，`Kubernetes Scheduler`需要使用`PV`的`nodeAffinity`描述信息来保证`Pod`能够调度到有对应`local volume`的`Node`上。
* `volumeMode`可以是`FileSystem（Default`）和`Block`，并且需要`enable BlockVolume Alpha feature gate`。
* **创建`local PV`之前，你需要先保证有对应的`storageClass`已经创建。**
* 且该`storageClass`的`volumeBindingMode` 必须是`WaitForFirstConsumer` 以标识延迟`Volume Binding`。
* `WaitForFirstConsumer`可以保证正常的`Pod`调度要求（`resource requirements`, `node selectors`, `Pod affinity`, and` Pod anti-affinity`等），又能保证`Pod`需要的`Local PV`的`nodeAffinity`得到满足，实际上，一共有以下两种`volumeBindingMode`：

```
// VolumeBindingImmediate indicates that PersistentVolumeClaims should be
// immediately provisioned and bound.
VolumeBindingImmediate VolumeBindingMode = "Immediate"

// VolumeBindingWaitForFirstConsumer indicates that PersistentVolumeClaims
// should not be provisioned and bound until the first Pod is created that
// references the PeristentVolumeClaim.  The volume provisioning and
// binding will occur during Pod scheduing.
VolumeBindingWaitForFirstConsumer VolumeBindingMode = "WaitForFirstConsumer"
```

* 节点上`local volume`的初始化需要我们人为去完成（比如`local disk`需要`pre-partitioned`, `formatted,` and `mounted`. 共享存储对应的`Directories`也需要`pre-created`），并且人工创建这个`local PV`，**当`Pod`结束，我们还需要手动的清理`local volume`，然后手动删除该`local PV`对象。因此，`persistentVolumeReclaimPolicy`只能是`Retain`。**


## local volume manager


上面这么多事情需要人为的去做预处理的工作，我们必须要有解决方案帮我们自动完成`local volume`的`create`和`cleanup`的工作。官方给出了一个简单的 [local volume manager](https://github.com/kubernetes-incubator/external-storage/tree/master/local-volume)，注意它仍然只是一个`static provisioner`，目前主要帮我们做两件事：

* `local volume manager` 监控配置好的 `discovery directory` 的新的挂载点，并为每个挂载点根据对应的`storageClassName`, `path`, `nodeAffinity`, and `capacity`创建`PersistentVolume object`。

* 当`Pod`结束并删除了使用`local volume`的`PVC`，`local volume manager`将自动清理该`local mount`上的所有文件, 然后删除对应的`PersistentVolume object`.

因此，除了需要人为的完成`local volume`的`mount`操作，`local PV`的生命周期管理就全部交给`local volume manager`了。



















