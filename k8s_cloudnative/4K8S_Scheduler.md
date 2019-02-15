# Kubernetes 调度器原理剖析

## 大纲

* K8S 调度机制介绍
* K8S 中的调度策略和算法
* K8S 高级调度特性详解

## K8S 调度机制介绍

### Scheduler: 为Pod找到一个合适的Node

![Alt Image Text](images/4_1.png "body image")

![Alt Image Text](images/4_2.png "body image")

### Kubernetes 的 default scheduler

* 基于队列的调度器
* 一次调度一个pod
* 调度时刻全局最优

![Alt Image Text](images/4_3.png "body image")

### 从外部流程看调度器

#### 从Pod创建开始， 到pod被bind结束

![Alt Image Text](images/4_4.png "body image")

### 掉度器内部流程

* 通过NodeLister获取所有节点的信息
* 整合`scheduled pods`和`assume pods`， 合并到`pods`, 作为所有已调度`pod`信息
* 从pods中整理出`node-pods`的对应关系表`nodeNameToInfo`
* 过滤掉不合适的节点
* 给剩下的节点依次打分
* 在分数最高的节点中选择一个node用于绑定。这是为了避免分数最高的节点被几次调度撞车

![Alt Image Text](images/4_5.png "body image")


## K8S 中的调度策略和算法

![Alt Image Text](images/4_6.png "body image")

### 通过Predicate策略选择符合条件的Node

![Alt Image Text](images/4_7.png "body image")

### 典型的Predicate 算法

![Alt Image Text](images/4_8.png "body image")


### 通过Priority策略给剩余的Node评分， 挑选最优的节点

![Alt Image Text](images/4_9.png "body image")

### 典型的priority 算法

![Alt Image Text](images/4_10.png "body image")

## K8S 高级调度特性详解

### K8S中的label和selector

* 任意的metadata
* 所有的API对象都有Label
* 通常用来标记“身份”
* 可以查询时用selector过滤
  * 类似于 SQL `select ... where ...`

![Alt Image Text](images/4_11.png "body image")

![Alt Image Text](images/4_12.png "body image")

![Alt Image Text](images/4_13.png "body image")


### Node Affinity 

#### 让pod在指定的node上运行

![Alt Image Text](images/4_14.png "body image")

![Alt Image Text](images/4_23.png "body image")

### Pod Affinity 

#### 让pod与指定的Service的一组Pod在相同的Node上运行

**`topologyKey: "zone"`**

![Alt Image Text](images/4_15.png "body image")

**`topologyKey: "hostname"`**

![Alt Image Text](images/4_16.png "body image")


![Alt Image Text](images/4_17.png "body image")

### Pod Anti-Affinity 

#### 让同一个Service的pod分散到不同的Node上来运行

![Alt Image Text](images/4_18.png "body image")

### Pod Anti-Affinity 具有对称性

![Alt Image Text](images/4_19.png "body image")

![Alt Image Text](images/4_24.png "body image")

### Taints-toleartions

#### 来自Node的反亲和配置

![Alt Image Text](images/4_20.png "body image")

![Alt Image Text](images/4_21.png "body image")

![Alt Image Text](images/4_22.png "body image")


## Practical Example

```
$ kubectl get node -o yaml | grep -A 11 labels
```

### install zsh auto-complete

```
source <(kubectl completion zsh>
```


