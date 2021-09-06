# Kubernetes卷快GA及快速安装测试

Kubernetes卷快照特性现在在Kubernetes v1.20中是GA。它在Kubernetes v1.12中以alpha的形式引入，随后在Kubernetes v1.13中进行了第二次alpha，并在Kubernetes 1.17中升级为beta版本。这篇博客总结了从beta版到GA版的变化。



## 什么是卷快照？


许多存储系统（如谷歌云持久磁盘、Amazon弹性块存储和许多内部存储系统）都提供了创建持久卷的“快照”的能力。快照表示卷的时间点副本。快照可以用于重新生成新卷（用快照数据预填充），也可以用于将现有卷恢复到以前的状态（由快照表示）。

## 为什么要向Kubernetes添加卷快照？

Kubernetes的目标是在分布式应用程序和底层集群之间创建一个抽象层，以便应用程序可以不知道它们运行的集群的具体情况，并且应用程序部署不需要“特定于集群的”知识。

Kubernetes Storage SIG将快照操作识别为许多有状态工作负载的关键功能。例如，数据库管理员可能希望在启动数据库操作之前快照数据库的卷。

通过提供在Kubernetes中触发卷快照操作的标准方法，该特性允许Kubernetes用户以可移植的方式在任何Kubernetes环境中合并快照操作，而不管底层存储是什么。

此外，这些Kubernetes快照特性/原语（primitive）充当基本构建块，释放了为Kubernetes开发高级企业级存储管理特性（包括应用程序或集群级备份解决方案）的能力。

## beta之后有什么新特性吗？

随着卷快照提升到GA，该特性在标准Kubernetes部署中默认启用，并且不能关闭。

卷快照API和客户端库被移动到单独的Go模块。

添加了快照验证webhook来对卷快照对象执行必要的验证。更多细节可以在卷快照验证Webhook Kubernetes增强建议中找到。

与验证webhook一起，卷快照控制器将开始标记已经存在的无效快照对象。这允许用户识别、删除任何无效对象，并纠正他们的工作流。一旦API切换到v1类型，这些无效对象将不能从系统中删除。

为了更好地了解快照特性是如何执行的，在卷快照控制器中添加了一组初始操作指标。

还有更多（在GCP上运行的）端到端测试，可以在真正的Kubernetes集群中验证该特性。引入了压力测试（基于谷歌持久磁盘和hostPath CSI驱动程序）来测试系统的健壮性。

## 哪些CSI驱动程序支持卷快照？

快照只支持CSI驱动程序，不支持树内或FlexVolume驱动程序。确保集群上部署的CSI驱动程序实现了快照接口。有关更多信息，请参见Kubernetes GA的容器存储接口（CSI）。

目前有50多个CSI驱动程序支持卷快照特性。GCE持久磁盘CSI驱动程序已经通过了从卷快照beta升级到GA的测试。对其他CSI驱动程序的GA级支持应该很快就可以使用了。

## 谁使用卷快照构建产品？

以下来自Kubernetes数据保护工作组的参与者正在使用Kubernetes卷快照构建产品或已经构建了产品。

* Dell-EMC: PowerProtect
* Druva
* Kasten K10
* Pure Storage (Pure Service Orchestrator)
* Red Hat OpenShift Container Storage
* TrilioVault for Kubernetes
* Velero plugin for CSI

## 如何部署卷快照？

卷快照功能包含以下组件：

* Kubernetes Volume Snapshot CRDs
* Volume snapshot controller
* Snapshot validation webhook
* CSI Driver along with CSI Snapshotter sidecar

强烈建议Kubernetes发行商捆绑并部署卷快照控制器、CRD和验证webhook，作为Kubernetes集群管理进程的一部分（独立于任何CSI驱动程序）。

警告：快照验证webhook在从使用v1beta1平稳过渡到使用v1 API时起着关键作用。如果不安装快照验证webhook，就不可能阻止无效卷快照对象的创建/更新，这反过来会阻止无效卷快照对象在未来的升级中被删除。

如果你的集群没有预先安装正确的组件，你可以手动安装它们。详见CSI Snapshotter README。

https://github.com/kubernetes-csi/external-snapshotter/blob/master/README.md

Volume Snapshot feature contains the following components:

* Kubernetes Volume Snapshot CRDs
* Volume snapshot controller
* Snapshot validation webhook
* CSI Driver along with CSI Snapshotter sidecar

### Install Snapshot CRDs:

**Do this once per cluster**

```
cd external-snapshotter/client/config/crd

$ kubectl apply -f .
customresourcedefinition.apiextensions.k8s.io/volumesnapshotclasses.snapshot.storage.k8s.io created
customresourcedefinition.apiextensions.k8s.io/volumesnapshotcontents.snapshot.storage.k8s.io created
customresourcedefinition.apiextensions.k8s.io/volumesnapshots.snapshot.storage.k8s.io created
```


### Install Common Snapshot Controller:

* Update the namespace to an appropriate value for your environment (e.g. kube-system)

**Do this once per cluster**

```
cd deploy/kubernetes/snapshot-controller


$ kubectl apply -f .
serviceaccount/snapshot-controller created
clusterrole.rbac.authorization.k8s.io/snapshot-controller-runner created
clusterrolebinding.rbac.authorization.k8s.io/snapshot-controller-role created
role.rbac.authorization.k8s.io/snapshot-controller-leaderelection created
rolebinding.rbac.authorization.k8s.io/snapshot-controller-leaderelection created
deployment.apps/snapshot-controller created


$ kubectl get pod -n kube-system | grep snap
snapshot-controller-6984fdc566-b7x4v     1/1     Running   0          3m45s
snapshot-controller-6984fdc566-qdllg     1/1     Running   0          3m45s
```

### Install CSI Driver:

* Here is an example to install the **sample hostpath CSI driver**

```
cd deploy/kubernetes/csi-snapshotter

 kubectl apply -f .
serviceaccount/csi-snapshotter created
clusterrole.rbac.authorization.k8s.io/external-snapshotter-runner created
clusterrolebinding.rbac.authorization.k8s.io/csi-snapshotter-role created
role.rbac.authorization.k8s.io/external-snapshotter-leaderelection created
rolebinding.rbac.authorization.k8s.io/external-snapshotter-leaderelection created
serviceaccount/csi-provisioner created
clusterrole.rbac.authorization.k8s.io/external-provisioner-runner created
clusterrolebinding.rbac.authorization.k8s.io/csi-provisioner-role created
role.rbac.authorization.k8s.io/external-provisioner-cfg created
rolebinding.rbac.authorization.k8s.io/csi-provisioner-role-cfg created
clusterrolebinding.rbac.authorization.k8s.io/csi-snapshotter-provisioner-role created
rolebinding.rbac.authorization.k8s.io/csi-snapshotter-provisioner-role-cfg created
service/csi-snapshotter created
statefulset.apps/csi-snapshotter created
```

```
$ kubectl get sts
NAME              READY   AGE
csi-snapshotter   1/1     93s

$ kubectl get pod
NAME                READY   STATUS    RESTARTS   AGE
csi-snapshotter-0   3/3     Running   0          83s
```


## 如何使用卷快照？

假设所有必需的组件（包括CSI驱动程序）已经部署并运行在集群上，你可以使用VolumeSnapshot API对象创建卷快照，或者通过在PVC上指定VolumeSnapshot数据源，使用现有的VolumeSnapshot来恢复PVC。有关更多细节，请参阅卷快照文档。

**注意**：Kubernetes Snapshot API不提供任何应用程序一致性保证。在手动或使用更高级别的API/控制器进行快照之前，你必须准备好你的应用程序（暂停应用程序，冻结文件系统等等）。

### 动态创建卷快照

```
kubectlv create ns csi
```


```
kubectl get csidrivers --all-namespaces
```


要动态创建卷快照，首先创建一个VolumeSnapshotClass API对象。

```
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshotClass
metadata:
  name: test-snapclass
driver: testdriver.csi.k8s.io
deletionPolicy: Delete
parameters:
  csi.storage.k8s.io/snapshotter-secret-name: mysecret
  csi.storage.k8s.io/snapshotter-secret-namespace: mysecretnamespace
```

```
$ kubectl apply -f test-snapclass.yaml 
volumesnapshotclass.snapshot.storage.k8s.io/test-snapclass created

$ kubectl get VolumeSnapshotClass
NAME             DRIVER                  DELETIONPOLICY   AGE
test-snapclass   testdriver.csi.k8s.io   Delete           64s
```

然后通过指定卷快照类从PVC创建一个VolumeSnapshot API对象。

```
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: test-snapshot
  namespace: csi
spec:
  volumeSnapshotClassName: test-snapclass
  source:
    persistentVolumeClaimName: test-pvc
```

```
$ kubectl apply -f test-VolumeSnapshot.yaml 
volumesnapshot.snapshot.storage.k8s.io/test-snapshot created

$ kubectl get volumesnapshots -n csi
NAME            READYTOUSE   SOURCEPVC   SOURCESNAPSHOTCONTENT   RESTORESIZE   SNAPSHOTCLASS    SNAPSHOTCONTENT   CREATIONTIME   AGE
test-snapshot   false        test-pvc                                          test-snapclass                                    36s
```

然后创建一个指向VolumeSnapshotContent对象的VolumeSnapshot对象。




## 使用Kubernetes导入现有卷快照

要将预先存在的卷快照导入Kubernetes，请首先手动创建一个VolumeSnapshotContent对象。

```
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshotContent
metadata:
  name: test-content
spec:
  deletionPolicy: Delete
  driver: testdriver.csi.k8s.io
  source:
    snapshotHandle: 7bdd0de3-xxx
  volumeSnapshotRef:
    name: test-snapshot
    namespace: default
```

```
$ kubectl apply -f test-VolumeSnapshotContent.yaml 
volumesnapshotcontent.snapshot.storage.k8s.io/test-content created

$ kubectl get volumesnapshotcontent
NAME           READYTOUSE   RESTORESIZE   DELETIONPOLICY   DRIVER                  VOLUMESNAPSHOTCLASS   VOLUMESNAPSHOT   VOLUMESNAPSHOTNAMESPACE   AGE
test-content                              Delete           testdriver.csi.k8s.io                         test-snapshot    default                   28s
```

然后创建一个指向VolumeSnapshotContent对象的VolumeSnapshot对象。

```
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshotContent
metadata:
  name: test-content
spec:
  deletionPolicy: Delete
  driver: testdriver.csi.k8s.io
  source:
    snapshotHandle: 7bdd0de3-xxx
  volumeSnapshotRef:
    name: test-snapshot
    namespace: default
```

### 从快照创建新卷

绑定并准备就绪的VolumeSnapshot对象可用于通过快照数据预先填充的数据创建新卷，如下所示：

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-restore
  namespace: csi
spec:
  storageClassName: test-storageclass
  dataSource:
    name: test-snapshot
    kind: VolumeSnapshot
    apiGroup: snapshot.storage.k8s.io
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
 ```
 
 ```
 $ kubectl apply -f test-snapshot-pvc.yaml 
persistentvolumeclaim/pvc-restore created

$ kubectl get pvc -n csi 
NAME          STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS        AGE
pvc-restore   Pending                                      test-storageclass   38s
```

### 有什么限制？

不支持将现有PVC恢复到快照所表示的早期状态（只支持从快照中创建新卷）。



