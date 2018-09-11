# Kubernetes对象详解 

## Kubernetes存储卷

我们知道默认情况下**容器的数据都是非持久化的**，在容器消亡以后数据也跟着丢失，所以 Docker提供了Volume机制以便将数据持久化存储。类似的，**Kubernetes提供了更强大的 Volume机制和丰富的插件，解决了容器数据持久化和容器间共享数据的问题**。

与`Docker`不同，`Kubernetes Volume`的生命周期与`Pod`绑定

### 容器挂掉后`Kubelet`再次重启容器时，`Volume`的数据依然还在
### 而`Pod`删除时，`Volume`才会清理。数据是否丢失取决于具体的`Volume`类型，比如`emptyDir`的数据会丢失，而`PV`的数据则不会丢

## Volume类型

```
emptyDir
hostPath 
gcePersistentDisk 
awsElasticBlockStore 
nfs
iscsi 
flocker 
glusterfs 
rbd 
cephfs 
gitRepo

secret 
persistentVolumeClaim 
downwardAPI 
azureFileVolume 
azureDisk 
vsphereVolume 
Quobyte
PortworxVolume 
ScaleIO
FlexVolume
StorageOS
local
```

## emptyDir

如果`Pod`设置了`emptyDir`类型`Volume`， Pod 被分配到Node上时候，会创建`emptyDir`，只要Pod运行在Node上，`emptyDir`都会存在(容 器挂掉不会导致emptyDir丢失数据)，**但是如果Pod从Node上被删除(Pod被删除，或者 Pod发生迁移)，emptyDir也会被删除，并且永久丢失。**

```
apiVersion: v1
kind: Pod
metadata:
  name: test-pd
spec:
  containers:
  - image:gcr.io/google_containers/test-webserver
    name: test-container
    volumeMounts:
    - mountPath: /cache
      name: cache-volume
  volumes:
  - name: cache-volume
    emptyDir: {}
```

## hostPath
  
**`hostPath`允许挂载`Node上的文件`系统到Pod里面去。如果`Pod`需要使用`Node上`的文件，可以使用`hostPath`。**

```
apiVersion: v1
kind: Pod
metadata:
  name: test-pd
spec:
  containers:
  - image:gcr.io/google_containers/test-webserver
    name: test-container
    volumeMounts:
    - mountPath:/test-pd
      name: test-volume
  volumes:
  - name: cache-volume
    hostPath:
      path: /data
```

## NFS

**`NFS` 是`Network File System`的缩写，即`网络文件系统`。Kubernetes中通过简单地配置就可以挂载`NFS`到Pod中，而`NFS`中的数据是可以永久保存的，同时NFS支持同时写操作。**

```
volumes:
- name: nfs
  nfs:
    # FIXME: use the right hostname
    server: 10.254.234.223
    path: "/"
```


## gcePersistentDisk

**`gcePersistentDisk`可以挂载`GCE`上的永久磁盘到容器，需要`Kubernetes`运行在`GCE`的VM中**。

```
volumes:
  - name: test-volume
    # This GCE PD must already exist
    gcePersistentDisk:
      pdName: my-data-disk
      fsType: ext4
```

## awsElasticBlockStore

**`awsElasticBlockStore`可以挂载`AWS`上的`EBS`盘到容器，需要`Kubernetes`运行在 `AWS`的`EC2`上。**

```
volumes:
  - name: test-volume
    # This AWS EBS volume must already exist.
    awsElasticBlockStore:
      volumeID: <volume-id>
      fsType: ext4
```

## gitRepo

**`gitRepo volume`将git代码下拉到指定的容器路径中**

```
volumes:
  - name: git-volume
    gitRepo:
      repository: "git@somewhere:me/my-git-repository.git"
      revision: "22f1d8406d464b0c0874075539c1f2e96c253775"
```


## 使用subPath

### `subpath`可以指定在共享`volume`里的子目录

### `Pod`的多个容器使用同一个`Volume`时， `subPath`非常有用，避免互相影响

```
apiVersion: v1 
kind: Pod 
metadata:
  name: my-lamp-site
spec:
  containers:
  - name: mysql
    image: mysql
    volumeMounts:
    - mountPath: /var/lib/mysql
      name: site-data
      subPath: mysql
  - name: php
    image: php
    volumeMounts:
    - mountPath: /var/www/html
      name: site-data
      subPath: html
volumes:
- name: site-data
  persistentVolumeClaim:
    claimName: my-lamp-site-data  
```


## FlexVolume

如果内置的这些`Volume`不满足要求，则可以 使用`FlexVolume`实现自己的Volume插件。注意要把`volume plugin`放到

```
/usr/libexec/kubernetes/kubelet- plugins/volume/exec/<vendor~driver>/<driver>
```

`plugin`要实现  **init/attach/detach/mount/umount等命令**

```
- name: test
    flexVolume:
      driver: "kubernetes.io/lvm"
      fsType: "ext4"
      options:
        volumeID: "vol1"
        size: "1000m"
        volumegroup: "kube_vg"
```

## Projected Volume

`Projectedvolume`将多个`Volume`源映射到同一个目录中， 支持`secret`、 `downwardAPI`和 `configMap`。

```
apiVersion: v1
kind: Pod
metadata:
  name: volume-test
spec:
  containers:
  - name: container-test
    image: busybox
    volumeMounts:
    - name: all-in-one
      mountPath: "/projected-volume"
      readOnly: true
volumes:
- name: all-in-one
  projected:
    sources:
    - secret:
        name: mysecret
        items:
          - key: username
            path: my-group/my-username
    - downwardAPI:
        items:
          - path: "labels"
            fieldRef:
              fieldPath: metadata.labels
          - path: "cpu_limit"
            resourceFieldRef:
              containerName: container-test
              resource: limits.cpu
    - configMap:
        name: myconfigmap
        items:
          - key: config
            path: my-group/my-config
```
 

## 本地存储限额 
 
`v1.7+`支持对基于本地存储(如`hostPath`, `emptyDir`, `gitRepo`等)的容量进行调度限额，可以通过`--feature-gates=LocalStorageCapacity Isolation=true`来开启这个特性。

为了支持这个特性，Kubernetes将本地存储分为两类

* `storage.kubernetes.io/overlay`，即`/var/lib/docker`的大小
* `storage.kubernetes.io/scratch`，即/`var/lib/kubelet`的大小


## 本地存储配额

`Kubernetes`根据`storage.kubernetes.io/scratch`的大小来调度本地存储空间，而根据 `storage.kubernetes.io/overlay`来调度容器的存储。比如

### 为容器请求64MB的可写层存储空间

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

### 为empty请求64MB的存储空间

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

## Mount传递

### 在`Kubernetes`中，`Volume Mount`默认是私有的，但从`v1.8`开始，`Kubernetes`支持配置`Mount` 传递`(mountPropagation)`。

**它支持两种选项:**

* `HostToContainer`:这是开启`MountPropagation=true`时的默认模式，等效于`rslave`模式，即容器可以看到`Host`上面在该`volume`内的任何新`Mount`操作

* `Bidirectional`:等效于`rshared`模式，即`Host`和容器都可以看到对方在该`Volume`内的任何新 `Mount`操作。该模式要求容器必须运行在特权模式(即`securityContext.privileged=true`)

**注意:**

**使用Mount传递需要开启`--feature-gates=MountPropagation=true`**

## 持久化卷

`PersistentVolume (PV)` 和 `PersistentVolumeClaim (PVC)` 提供了方便的持久化卷:

### PV 提供`网络存储资源`，而 PVC 请求`存储资源`。

这样，设置持久化的工作流包括配置底层文件系统或者云数据卷、创建持久性数据卷、最后创建 PVC 来将 Pod 跟数据卷关联起来。PV 和 PVC 可以将 pod 和数据卷解耦，pod 不需要知道确切的文件系统或者支持它的持久化引擎。


## Volume生命周期

**Volume的生命周期包括5个阶段:**

### - `Provisioning`，即`PV`的创建，可以直接创建`PV`(静态方式)，也可以使用`StorageClass`动态创建
### - `Binding`，将`PV`分配给`PVC`
### - `Using`，`Pod`通过`PVC`使用该`Volume`
### - `Releasing`，`Pod`释放`Volume`并删除`PVC`
### - `Reclaiming`，回收`PV`，可以保留`PV`以便下次使用，也可以直接从云存储中删除

## Volume的状态

**根据这5个阶段，Volume的状态有以下4种**

*  Available:可用
*  Bound:已经分配给PVC
*  Released:PVC解绑但还未执行回收策略 
*  Failed:发生错误

## PV

`PersistentVolume(PV)`是集群之中的一块网络存储。跟 `Node` 一样，也是集群的资源。`PV` 跟 `Volume` (卷) 类似，不过会有独立于 `Pod` 的生命周期。比如一个`NFS`的`PV`可以定义为:

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv0003
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Recycle
  nfs:
    path: /tmp
    server: 172.17.0.2
```

## 访问模式与回收策略

PV的访问模式(accessModes)有三种:

* ReadWriteOnce(RWO):是最基本的方式，可读可写，但只支持被单个Pod挂载。
* ReadOnlyMany(ROX):可以以只读的方式被多个Pod挂载。
* ReadWriteMany(RWX):这种存储可以以读写的方式被多个Pod共享。不是每一种存储都支持 这三种方式，像共享方式，目前支持的还比较少，比较常用的是NFS。在PVC绑定PV时通常根据 两个条件来绑定，一个是存储的大小，另一个就是访问模式。

PV的回收策略(persistentVolumeReclaimPolicy，即PVC释放卷的时候PV该如何操作)也有三种

### `Retain`，不清理,保留Volume(需要手动清理)
### `Recycle`，删除数据，即rm-rf/thevolume/*(只有NFS和HostPath支持)
### `Delete`，删除存储资源，比如删除AWSEBS卷(只有AWSEBS,GCEPD,AzureDisk和Cinder支持)


## StorageClass

上面通过手动的方式创建了一个`NFS Volume`，这在管理很多`Volume`的时候不太方便。 

### Kubernetes还提供了`StorageClass`来动态创建`PV`，不仅节省了管理员的时间，还可以封装不同类型的存储供`PVC`选用。

**StorageClass包括四个部分:**

* `provisioner`:指定Volume插件的类型，包括内置插件(如`kubernetes.io/glusterfs`)和外部插件(如`external-storage`提供的`ceph.com/cephfs`)。
* `mountOptions`:指定挂载选项，当PV不支持指定的选项时会直接失败。比如`NFS`支持`hard`和
 `nfsvers=4.1`等选项。
* `parameters`:指定`provisioner`的选项，比如`kubernetes.io/aws-ebs`支持`type`、`zone`、`iopsPerGB`等参数。
* `reclaimPolicy`:指定回收策略，同PV的回收策略。

在使用PVC时，可以通过`DefaultStorageClass`准入控制设置默认`StorageClass`, 即给未设置 `storageClassName`的PVC自动添加默认的`StorageClass`。而默认的`StorageClass`带有 `annotation storageclass.kubernetes.io/is-default-class=true`。

## 修改默认StorageClass

### 取消原来的默认StorageClass

```
kubectl patch storageclass <default-class-name> -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
```

### 标记新的默认StorageClass

```
kubectl patch storageclass <your-class-name> -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

## OpenStack Cinder示例

```
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: gold
provisioner: kubernetes.io/cinder
parameters:
  type: fast
  availability: nova
```

## PVC

### `PV`是存储资源，而`PersistentVolumeClaim (PVC)` 是对 `PV` 的请求。

**`PVC` 跟 `Pod` 类似:**

### `Pod` 消费 `Node` 的源，而 `PVC` 消费 `PV` 资源;
### `Pod` 能够请求 `CPU` 和`内存资源`，而 `PVC` 请求`特定大小`和`访问模式`的数据卷。

```
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: myclaim
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 8Gi
  storageClassName: slow
  selector:
    matchLabels:
      release: "stable"
    matchExpressions:
      - {key: environment, operator: In, values: [dev]}
```

## 本地数据卷

* 本地数据卷(`Local Volume`)代表一个本地存储设备，比如磁盘、分区或者目录等。主要的 应用场景包括分布式存储和数据库等需要高性能和高可靠性的环境里。本地数据卷同时支 持块设备和文件系统，通过`spec.local.path`指定;但对于文件系统来说，kubernetes v1.7之前 并不会限制该目录可以使用的存储空间大小。
* 本地数据卷只能以静态创建的PV使用。相对于`HostPath`，本地数据卷可以直接以持久化的 方式使用(它总是通过`NodeAffinity`调度在某个指定的节点上)。
* 另外，社区还提供了一个 `local-volume-provisioner`，用于自动创建和清理本地数据卷。

## 示例

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: example-local-pv 
  annotations:
    "volume.alpha.kubernetes.io/node-affinity": '{
       "requiredDuringSchedulingIgnoredDuringExecution": {
          "nodeSelectorTerms": [
             { "matchExpressions": [
               { "key": "kubernetes.io/hostname",
                 "operator": "In",
                 "values": ["example-node"]
                }
              ]}
             ]}
            }',
spec:
  capacity:
    storage: 5Gi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  storageClassName: local-storage
  local:
    path: /mnt/disks/ssd1
```


## 创建PVC:

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
      storage: 5Gi
  storageClassName: local-storage
```

## 创建Pod，引用PVC:

```
kind: Pod
apiVersion: v1
metadata:
  name: mypod
spec:
  containers:
    - name: myfrontend
      image: nginx
      volumeMounts:
      - mountPath: "/var/www/html"
        name: mypd
  volumes:
    - name: mypd
      persistentVolumeClaim:
        claimName: example-local-claim
```

## 最佳实践

* 推荐为**每个存储卷分配独立的磁盘**，以便隔离IO请求
* 推荐为**每个存储卷分配独立的分区**，以便隔离存储空间
* **避免重新创建同名的Node**，否则会导致新Node无法识别已绑定旧Node的PV
* **推荐使用UUID而不是文件路径**，以避免文件路径误配的问题
* 对于不带文件系统的块存储，**推荐使用唯一ID(如/dev/disk/by-id/)**，以避免块设备路径误配的问题