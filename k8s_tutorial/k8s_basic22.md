# Kubernetes高阶(设计和实现)

## kube-scheduler

### `kube-scheduler`负责分配调度`Pod`到集群内的节点上，它监听`kube-apiserver`，查询还未分配 `Node`的`Pod`，然后根据调度策略为这些`Pod`分配节点(更新Pod的NodeName字段)。


## 调度器需要充分考虑诸多的因素:

### • 公平调度
### • 资源高效利用
### • QoS
### • `affinity`和`anti-affinity`
### • 数据本地化(`data locality`)
### • 内部负载干扰(`inter-workload interference`) 
### • `deadlines`

## 把pod调度到指定node上

1.**可以通过`nodeSelector`、`nodeAffinity`、`podAffinity`以及 `Taints`和`tolerations`等来将`Pod`调度到需要的Node上。**

2.也可以通过设置`nodeName`参数，将`Pod`调度到指定`node`节点上。

3.比如，**使用`nodeSelector`**，首先给Node加上标签:

4.

```
kubectl label nodes <your-node-name> disktype=ssd
```

5.接着，指定该`Pod`只想运行在带有`disktype=ssd`标签的 Node上:

```
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    env: test
spec:
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
  nodeSelector:
    disktype: ssd
```

```
kubectl get nodes
NAME            STATUS    ROLES     AGE       VERSION
192.168.1.170   Ready     <none>    13d       v1.8.2
```

## nodeSelector

### 首先给Node打上标签

```
kubectl label nodesnode-01 disktype=ssd
```

### 然后在`daemonset`中指定`nodeSelector`为`disktype=ssd`:

```
spec:
  nodeSelector: 
    disktype: ssd
```

## nodeAffinity

`nodeAffinity`目前支持两种:
`requiredDuringSchedulingIgnoredDuringExecution`和 `preferredDuringSchedulingIgnoredDuringExecution`，分别代表必须满足条件和优选条件。

比如下面的例子代表调度到包含标签`kubernetes.io/e2e-az-name`并且值为`e2e-az1`或`e2e-az2`的 `Node`上，并且优选还带有标签`another-node-label-key=another-node-label-value`的Node。

```
apiVersion: v1
kind: Pod
metadata:
  name: with-node-affinity
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: kubernetes.io/e2e-az-name
            operator: In
            values:
            - e2e-az1
            - e2e-az2
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        preference:
          matchExpressions:
          - key: another-node-label-key
            operator: In
            values:
            - another-node-label-value
containers:
- name: with-node-affinity
  image: gcr.io/google_containers/pause:2.0    
```

## podAffinity

1. `podAffinity`基于`Pod`的标签来选择`Node`，仅调度到满足条件Pod所在的Node上，支持 `podAffinity`和`podAntiAffinity`。这个功能比较绕，以下面的例子为例:

2. 如果一个“Node所在Zone中包含至少一个带有security=S1标签且运行中的Pod”，那么可以调 度到该Node
3. 不调度到“**包含至少一个带有`security=S2`标签且运行中Pod**”的Node上

## podAffinity示例

```
apiVersion: v1
kind: Pod
metadata:
  name: with-pod-affinity
spec:
  affinity:
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution
      - labelSelector:
          matchExpressions:
          - key: security
            operator: In
            values:
            - S1
        topologyKey: failure-domain.beta.kubernetes.io/zone
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
            - key: security
              operator: In
              values
              - S2
        topologyKey: kubernetes.io/hostname
containers:
- name: with-pod-affinity
  image: gcr.io/google_containers/pause:2.0     
```

## Taints和tolerations
 
### `Taints`和`tolerations`用于保证`Pod`不被调度到不合适的`Node上`，

### 1. 其中`Taint`应用于`Node`上，
### 2. 而 `toleration`则应用于`Pod`上。

### 目前支持的taint类型

* `NoSchedule`:新的Pod不调度到该Node上，不影响正在运行的Pod
* `PreferNoSchedule`:`soft`版的`NoSchedule`，尽量不调度到该Node上
* `NoExecute`:新的`Pod`不调度到该`Node`上，并且删除(`evict`)已在运行的Pod。Pod可以增加一个时间(`tolerationSeconds`)，


### 然而，当`Pod`的`Tolerations`匹配`Node`的所有`Taints`的时候可以调度到该`Node`上;

### 当Pod是已经运行的时候，也不会被删除(`evicted`)。另外对于`NoExecute`，如果Pod增加了一个 `tolerationSeconds`，则会在该时间之后才删除Pod。

## 优先级调度


从v1.8开始，`kube-scheduler`支持定义`Pod的优先级`，从而保证高优先级的Pod优先调度。开启方法为

### `apiserver`配置`--feature-gates=PodPriority=true`和`--runtime-config=scheduling.k8s.io/v1alpha1=true`

### `kube-scheduler`配置`--feature-gates=PodPriority=true`

## PriorityClass

在指定Pod的优先级之前需要先定义一个`PriorityClass`(`非namespace资源`)，如

```
apiVersion: v1 
kind: PriorityClass 
metadata:
  name: high-priority
value: 1000000
globalDefault: false
description: "This priority class should be used for XYZ service pods only."
```

## 为pod设置priority

```
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    env: test
 spec:
   containers:
   - name: nginx
     image: nginx
     imagePullPolicy: IfNotPresent
priorityClassName: high-priority
```

## 多调度器

如果默认的调度器不满足要求，还可以部署自定义的调度器。并且，在整个集群中还可以同时运行多个调度器实例，通过`podSpec.schedulerNam`e来选择使用哪一个调度器(默认使用内置的调度器)。


## 调度器

### `kube-scheduler`调度分为两个阶段，`predicate`和`priority`

* `predicate`:过滤不符合条件的节点
* `priority`:优先级排序，选择优先级最高的节点

## predicates策略


* PodFitsPorts:同PodFitsHostPorts
* PodFitsHostPorts:检查是否有Host Ports冲突
* PodFitsResources:检查Node的资源是否充足，包括允许的Pod数量、CPU、内存、GPU个数以及其他的OpaqueIntResources
* HostName:检查pod.Spec.NodeName是否与候选节点一致
* MatchNodeSelector:检查候选节点的pod.Spec.NodeSelector是否匹配
* NoVolumeZoneConflict:检查volume zone是否冲突
* MaxEBSVolumeCount:检查AWS EBS Volume数量是否过多(默认不超过39)
* MaxGCEPDVolumeCount:检查GCE PD Volume数量是否过多(默认不超过16)
* MaxAzureDiskVolumeCount:检查Azure Disk Volume数量是否过多(默认不超过16)
* MatchInterPodAffinity:检查是否匹配Pod的亲和性要求
* NoDiskConflict:检查是否存在Volume冲突，仅限于GCE PD、AWS EBS、Ceph RBD以及ISCSI
* GeneralPredicates:分为noncriticalPredicates和EssentialPredicates。noncriticalPredicates中包含PodFitsResources，EssentialPredicates中包含PodFitsHost， PodFitsHostPorts和PodSelectorMatches。
* PodToleratesNodeTaints:检查Pod是否容忍Node Taints
* CheckNodeMemoryPressure:检查Pod是否可以调度到MemoryPressure的节点上
* CheckNodeDiskPressure:检查Pod是否可以调度到DiskPressure的节点上
* NoVolumeNodeConflict:检查节点是否满足Pod所引用的Volume的条件

## priorities策略

* SelectorSpreadPriority:优先减少节点上属于同一个Service或ReplicationController的Pod数量
* InterPodAffinityPriority:优先将Pod调度到相同的拓扑上(如同一个节点、Rack、Zone等)
* LeastRequestedPriority:优先调度到请求资源少的节点上
* BalancedResourceAllocation:优先平衡各节点的资源使用
* NodePreferAvoidPodsPriority:alpha.kubernetes.io/preferAvoidPods字段判断,权重为10000，避免 其他优先级策略的影响
* NodeAffinityPriority:优先调度到匹配NodeAffinity的节点上
* TaintTolerationPriority:优先调度到匹配TaintToleration的节点上
* ServiceSpreadingPriority:尽量将同一个service的Pod分布到不同节点上，已经被 SelectorSpreadPriority替代[默认未使用]
* EqualPriority:将所有节点的优先级设置为1[默认未使用]
* ImageLocalityPriority:尽量将使用大镜像的容器调度到已经下拉了该镜像的节点上[默认未使用]
* MostRequestedPriority:尽量调度到已经使用过的Node上，特别适用于cluster-autoscaler[默认未使用]


## Controller Manager

* Replication Controller 
* Node Controller 
* CronJob Controller 
* Daemon Controller 
* Deployment Controller 
* Endpoint Controller 
* Garbage Collector 
* Namespace Controller 
* Job Controller
* Pod AutoScaler 
* RelicaSet
* Service Controller 
* ServiceAccount Controller 
* StatefulSet Controller 
* Volume Controller 
* Resource quota Controller