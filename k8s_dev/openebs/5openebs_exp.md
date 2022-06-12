# **4 OpenEBS 落地实践**

OpenEBS的cStor与Jiva引擎由于组件过多，配置相较其他存储方案繁琐，生产环境不建议使用，**这里我们仅论述Local PV引擎**。


Local PV引擎不具备存储级复制能力，**适用于k8s有状态服务的后端存储（如: es、redis等）**

## **Local PV Hostpath实践**

对比Kubernetes Hostpath卷相比，OpenEBS本地PV Hostpath卷具有以下优势:

* OpenEBS本地PV Hostpath允许您的应用程序通过StorageClass、PVC和PV访问Hostpath。 这为您提供了更改PV提供者的灵活性，而无需重新设计应用程序YAML
* 使用Velero备份和恢复进行数据保护
* 通过对应用程序YAML和pod完全屏蔽主机路径来防范主机路径安全漏洞

环境依赖:

* k8s 1.12以上
* OpenEBS 1.0以上

**实践环境:**

* docker 19.03.8
* k8s 1.18.6
* CentOS7

```
NAME    STATUS   ROLES           AGE     VERSION
node1   Ready    master,worker   8m8s    v1.18.6
node2   Ready    master,worker   7m15s   v1.18.6
node3   Ready    master,worker   7m15s   v1.18.6
```

### **创建数据目录**

在将要创建Local PV Hostpaths的节点上设置目录。这个目录将被称为BasePath。默认位置是`/var/openebs/local`

节点node1、node2、node3创建`/data/openebs/local`目录 （**`/data`可以预先挂载数据盘，如未挂载额外数据盘，则使用操作系统'/'挂载点存储空间**）

```
mkdir -p /data/openebs/local
```

### **下载应用描述文件**

[https://openebs.github.io/charts/openebs-operator-lite.yaml](https://openebs.github.io/charts/openebs-operator-lite.yaml)

### **发布openebs应用**

根据上述配置文件，保证k8s集群可访问到如下镜像（建议导入本地私有镜像库，如: harbor）

```
openebs/node-disk-manager:1.5.0
openebs/node-disk-operator:1.5.0
openebs/provisioner-localpv:2.10.0
```

更新`openebs-operator.yaml`中镜像tag为实际tag

```
image: openebs/node-disk-manager:1.5.0
image: openebs/node-disk-operator:1.5.0
image: openebs/provisioner-localpv:2.10.0
```
发布

```
kubectl apply -f openebs-operator.yaml
```

查看发布状态

```
[root@localhost openebs]# kubectl get pod -n openebs -w
NAME                                           READY   STATUS    RESTARTS   AGE
openebs-localpv-provisioner-6d6d9cfc99-4sltp   1/1     Running   0          10s
openebs-ndm-85rng                              1/1     Running   0          10s
openebs-ndm-operator-7df6668998-ptnlq          0/1     Running   0          10s
openebs-ndm-qgqm9                              1/1     Running   0          10s
openebs-ndm-zz7ps                              1/1     Running   0          10s
```

### **创建存储类**

更改配置文件中的内容

```
value: "/var/openebs/local/"
```

发布创建存储类

```
cat > openebs-hostpath-sc.yaml <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: openebs-hostpath
  annotations:
    openebs.io/cas-type: local
    cas.openebs.io/config: |
      #hostpath type will create a PV by
      # creating a sub-directory under the
      # BASEPATH provided below.
      - name: StorageType
        value: "hostpath"
      #Specify the location (directory) where
      # where PV(volume) data will be saved.
      # A sub-directory with pv-name will be
      # created. When the volume is deleted,
      # the PV sub-directory will be deleted.
      #Default value is /var/openebs/local
      - name: BasePath
        value: "/data/openebs/local/"
provisioner: openebs.io/local
volumeBindingMode: WaitForFirstConsumer
reclaimPolicy: Delete
EOF

kubectl apply -f openebs-hostpath-sc.yaml
```

### **创建pvc验证可用性**

```
cat > local-hostpath-pvc.yaml <<EOF
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: local-hostpath-pvc
spec:
  storageClassName: openebs-hostpath
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5G
EOF

kubectl apply -f local-hostpath-pvc.yaml
```

查看pvc状态

```
[root@localhost openebs]# kubectl get pvc
NAME                 STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS       AGE
local-hostpath-pvc   Pending                                      openebs-hostpath   2m15s
```

输出显示STATUS为Pending。这意味着PVC还没有被应用程序使用。

### **创建pod**

```
cat > local-hostpath-pod.yaml <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: hello-local-hostpath-pod
spec:
  volumes:
  - name: local-storage
    persistentVolumeClaim:
      claimName: local-hostpath-pvc
  containers:
  - name: hello-container
    image: busybox
    command:
       - sh
       - -c
       - 'while true; do echo "`date` [`hostname`] Hello from OpenEBS Local PV." >> /mnt/store/greet.txt; sleep $(($RANDOM % 5 + 300)); done'
    volumeMounts:
    - mountPath: /mnt/store
      name: local-storage
EOF
```

发布创建

```
kubectl apply -f local-hostpath-pod.yaml
```

### **验证数据是否写入卷**

```
[root@localhost openebs]# kubectl exec hello-local-hostpath-pod -- cat /mnt/store/greet.txt
Thu Jun 24 15:10:45 CST 2021 [node1] Hello from OpenEBS Local PV.
```

### **验证容器是否使用Local PV Hostpath卷**

```
[root@localhost openebs]# kubectl describe pod hello-local-hostpath-pod
Name:         hello-local-hostpath-pod
Namespace:    default
Priority:     0
...
Volumes:
  local-storage:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  local-hostpath-pvc
    ReadOnly:   false
  default-token-98scc:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-98scc
    Optional:    false
...
```

### **查看pvc状态**

```
[root@localhost openebs]# kubectl get pvc local-hostpath-pvc
NAME                 STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS       AGE
local-hostpath-pvc   Bound    pvc-6eac3773-49ef-47af-a475-acb57ed15cf6   5G         RWO            openebs-hostpath   10m
```

### **查看该pv卷数据存储目录为**

```
[root@localhost openebs]# kubectl get -o yaml pv pvc-6eac3773-49ef-47af-a475-acb57ed15cf6|grep 'path:'
          f:path: {}
    path: /data/openebs/local/pvc-6eac3773-49ef-47af-a475-acb57ed15cf6
```

### **查看该pv卷数据存储目录为**

```
[root@localhost openebs]# kubectl get -o yaml pv pvc-6eac3773-49ef-47af-a475-acb57ed15cf6|grep 'path:'
          f:path: {}
    path: /data/openebs/local/pvc-6eac3773-49ef-47af-a475-acb57ed15cf6
```

并且pv配置了亲和性，制定了调度节点为node2

```
spec:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 5G
  claimRef:
    apiVersion: v1
    kind: PersistentVolumeClaim
    name: local-hostpath-pvc
    namespace: default
    resourceVersion: "9034"
    uid: 6eac3773-49ef-47af-a475-acb57ed15cf6
  local:
    fsType: ""
    path: /data/openebs/local/pvc-6eac3773-49ef-47af-a475-acb57ed15cf6
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - node2
  persistentVolumeReclaimPolicy: Delete
  storageClassName: openebs-hostpath
  volumeMode: Filesystem
```

验证三个节点存储目录下

结果证明数据仅存在于node2下

清理pod

```
kubectl delete pod hello-local-hostpath-pod
```

### **基准测试**

下载基准[测试Job声明文件](https://github.com/openebs/performance-benchmark/blob/master/fio-benchmarks/fio-deploy.yaml)

调整以下内容

```
image: openebs/perf-test:latest # 调整为内网镜像库tag
claimName: dbench # 调整为local-hostpath-pvc
```

发布运行

```
kubectl create -f fio-deploy.yaml 
```

查看运行状态

```
[root@node1 openebs]# kubectl get pod
NAME                 READY   STATUS    RESTARTS   AGE
dbench-729cw-nqfpt   1/1     Running   0          24s
```

查看基准测试结果

```
[root@node1 openebs]# kubectl logs -f dbench-729cw-nqfpt
...
All tests complete.

==================
= Dbench Summary =
==================
Random Read/Write IOPS: 2144/6654. BW: 131MiB/s / 403MiB/s
Average Latency (usec) Read/Write: 4254.08/3661.59
Sequential Read/Write: 1294MiB/s / 157MiB/s
Mixed Random Read/Write IOPS: 1350/443
```

```
kubectl delete pvc local-hostpath-pvc
kubectl delete sc openebs-hostpath
```

## **Local PV Device实践**


对比Kubernetes本地持久卷，OpenEBS本地PV设备卷有以下优点:

* OpenEBS本地PV设备卷provider是动态的，Kubernetes设备卷provider是静态的
* OpenEBS NDM更好地管理用于创建本地pv的块设备。 NDM提供了发现块设备属性、设置设备筛选器、度量集合以及检测块设备是否已经跨节点移动等功能

**环境依赖:**

* k8s 1.12以上
* OpenEBS 1.0以上

**实践环境:**

* docker 19.03.8
* k8s 1.18.6
* CentOS7

```
[root@localhost ~]# kubectl get node
NAME    STATUS   ROLES           AGE     VERSION
node1   Ready    master,worker   8m8s    v1.18.6
node2   Ready    master,worker   7m15s   v1.18.6
node3   Ready    master,worker   7m15s   v1.18.6
```

三个节点上的`/dev/sdb`作为块设备存储

```
[root@node1 ~]# lsblk
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda               8:0    0  400G  0 disk
├─sda1            8:1    0    1G  0 part /boot
└─sda2            8:2    0  399G  0 part
  └─centos-root 253:0    0  399G  0 lvm  /
sdb               8:16   0   20G  0 disk
sr0              11:0    1  4.4G  0 rom

[root@node2 ~]# lsblk
    NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
    sda               8:0    0  400G  0 disk
    ├─sda1            8:1    0    1G  0 part /boot
    └─sda2            8:2    0  399G  0 part
      └─centos-root 253:0    0  399G  0 lvm  /
    sdb               8:16   0   20G  0 disk
    sr0              11:0    1  4.4G  0 rom

[root@node3 ~]# lsblk
    NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
    sda               8:0    0  400G  0 disk
    ├─sda1            8:1    0    1G  0 part /boot
    └─sda2            8:2    0  399G  0 part
      └─centos-root 253:0    0  399G  0 lvm  /
    sdb               8:16   0   20G  0 disk
    sr0              11:0    1  4.4G  0 rom
```

### **创建数据目录**

创建数据目录

在将要创建Local PV Hostpaths的节点上设置目录。这个目录将被称为BasePath。默认位置是`/var/openebs/local`

节点node1、node2、node3创建`/data/openebs/local`目录 （/data可以预先挂载数据盘，如未挂载额外数据盘，则使用操作系统'/'挂载点存储空间）

```
mkdir -p /data/openebs/local
```

### **下载应用描述文件**

[yaml文件](https://openebs.github.io/charts/openebs-operator.yaml)

### **发布openebs应用**

根据上述配置文件，保证k8s集群可访问到如下镜像（建议导入本地私有镜像库，如: harbor）

```
openebs/node-disk-manager:1.5.0
openebs/node-disk-operator:1.5.0
openebs/provisioner-localpv:2.10.0
```
更新`openebs-operator.yaml`中镜像tag为实际tag

```
image: openebs/node-disk-manager:1.5.0
image: openebs/node-disk-operator:1.5.0
image: openebs/provisioner-localpv:2.10.0
```

发布

```
kubectl apply -f openebs-operator.yaml
```

查看发布状态

```
[root@localhost openebs]# kubectl get pod -n openebs -w
NAME                                           READY   STATUS    RESTARTS   AGE
openebs-localpv-provisioner-6d6d9cfc99-4sltp   1/1     Running   0          10s
openebs-ndm-85rng                              1/1     Running   0          10s
openebs-ndm-operator-7df6668998-ptnlq          0/1     Running   0          10s
openebs-ndm-qgqm9                              1/1     Running   0          10s
openebs-ndm-zz7ps                              1/1     Running   0          10s
```

### **创建存储类**

```
cat > local-device-sc.yaml <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-device
  annotations:
    openebs.io/cas-type: local
    cas.openebs.io/config: |
      - name: StorageType
        value: device
provisioner: openebs.io/local
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
EOF

kubectl apply -f local-device-sc.yaml
```

### **创建pod及pvc**

```
cat > local-device-pod.yaml <<EOF
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: local-device-pvc
spec:
  storageClassName: local-device
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5G
---
apiVersion: v1
kind: Pod
metadata:
  name: hello-local-device-pod
spec:
  volumes:
  - name: local-storage
    persistentVolumeClaim:
      claimName: local-device-pvc
  containers:
  - name: hello-container
    image: busybox
    command:
       - sh
       - -c
       - 'while true; do echo "`date` [`hostname`] Hello from OpenEBS Local PV." >> /mnt/store/greet.txt; sleep $(($RANDOM % 5 + 300)); done'
    volumeMounts:
    - mountPath: /mnt/store
      name: local-storage
EOF
```

发布

```
kubectl apply -f local-device-pod.yaml
```

查看pod状态

```
[root@node1 openebs]# kubectl get pod hello-local-device-pod -w
NAME                     READY   STATUS    RESTARTS   AGE
hello-local-device-pod   1/1     Running   0          9s
```

确认pod关联pvc是否为`local-device-pvc`

```
[root@node1 openebs]# kubectl describe pod hello-local-device-pod
Name:         hello-local-device-pod
Namespace:    default
Node:         node2/192.168.1.112
...
Volumes:
  local-storage:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  local-device-pvc
    ReadOnly:   false
...
```

观察到调度的节点为node2，确认node2节点/dev/sdb是否被使用

```
[root@node2 ~]# lsblk
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda               8:0    0  400G  0 disk
├─sda1            8:1    0    1G  0 part /boot
└─sda2            8:2    0  399G  0 part
  └─centos-root 253:0    0  399G  0 lvm  /
sdb               8:16   0   20G  0 disk
sr0              11:0    1  4.4G  0 rom
[root@node2 ~]# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0  400G  0 disk
├─sda1   8:1    0    1G  0 part /boot
└─sda2   8:2    0  399G  0 part
  └─centos-root
       253:0    0  399G  0 lvm  /
sdb      8:16   0   20G  0 disk /var/lib/kubelet/pods/266b7b14-5eb7-40ec-bccb-3ac189acf939/volumes/kubernetes.io~local-volume/pvc-9bd89019-13dc-4
sr0     11:0    1  4.4G  0 rom
```

确实被使用，OpenEBS强大之处则在于此，极致的简洁。 如上文我们讨论的那样，NDM负责发现块设备并过滤掉不应该被OpenEBS使用的设备，例如，检测有OS文件系统的磁盘。

### **基准测试**

创建基准测试pvc

```
cat > dbench-pvc.yaml <<EOF
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: dbench
spec:
  storageClassName: local-device
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5G

EOF
```

下载[基准测试Job声明文件](https://github.com/openebs/performance-benchmark/blob/master/fio-benchmarks/fio-deploy.yaml)

### **调整以下内容**

```
image: openebs/perf-test:latest # 调整为内网镜像库tag    
```

发布运行

```
kubectl create -f dbench-pvc.yaml
kubectl create -f fio-deploy.yaml 
```

查看运行状态

```
[root@node1 openebs]# kubectl get pod
NAME                 READY   STATUS    RESTARTS   AGE
dbench-vqk68-f9877   1/1     Running   0          24s
```
查看基准测试结果

```
[root@node1 openebs]# kubectl logs -f dbench-vqk68-f9877
...

All tests complete.

==================
= Dbench Summary =
==================
Random Read/Write IOPS: 3482/6450. BW: 336MiB/s / 1017MiB/s
Average Latency (usec) Read/Write: 2305.77/1508.63
Sequential Read/Write: 6683MiB/s / 2312MiB/s
Mixed Random Read/Write IOPS: 3496/1171
```

从结果来看，相较Local PV HostPath模式性能翻倍

## **总结**

但OpenEBS现阶段也存在一些不足：

* cStor与Jiva数据面组件较多，配置较为繁琐（第一感觉概念性的组件过多，）
* cStor与Jiva部分组件创建依赖内部定义的镜像tag，在离线环境下无法通过调整为私有库tag导致组件无法成功运行
* 存储类型单一，多个引擎仅支持块存储类型，不支持原生多节点读写（需结合NFS实现），对比ceph等稍显逊色

建议以下场景使用OpenEBS作为后端存储：


* 单机测试环境
* 多机实验/演示环境