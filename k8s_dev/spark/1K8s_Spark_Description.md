# Spark 概念说明以及K8S+Spark架构设计


目前运行支持 kubernetes 原生调度的 spark 程序项目由 Google 主导，fork 自 spark 的官方代码库，见 [GitHub - spark-on-k8s](https://github.com/apache-spark-on-k8s/spark/) ，属于**Big Data SIG**。

[Apache Spark](http://spark.apache.org/) 是一个围绕速度、易用性和复杂分析构建的大数据处理框架。最初在2009年由加州大学伯克利分校的AMPLab开发，并于2010年成为Apache的开源项目之一。


## 在 `Spark` 中包括如下组件或概念：

### Application

**`Spark Application` 的概念和 `Hadoop` 中的 `MapReduce` 类似**，指的是用户编写的 `Spark` 应用程序，包含了**一个 `Driver` 功能的代码**和**分布在集群中多个节点上运行的 `Executor` 代码**；

### Driver
 
 **`Spark` 中的 `Driver` 即运行上述 `Application` 的 `main()` 函数并且创建 `SparkContext`，其中创建 `SparkContext` 的目的是为了准备Spark应用程序的运行环境。** 
 
 在 `Spark` 中由 `SparkContext` 负责和 `ClusterManager` 通信，进行资源的申请、任务的分配和监控等；当 `Executor` 部分运行完毕后，`Driver`负责将`SparkContext` 关闭。通常用 `SparkContext` 代表 `Driver`；
 
### Executor

**`Application`运行在`Worker` 节点上的一个进程，该进程负责运行`Task`，并且负责将数据存在内存或者磁盘上，每个`Application`都有各自独立的一批`Executor`。** 

在`Spark on Yarn`模式下，其进程名称为`CoarseGrainedExecutorBackend`，类似于 `Hadoop MapReduc`e 中的 `YarnChild`。一个 `CoarseGrainedExecutorBackend` 进程有且仅有一个` executor` 对象，它负责将 `Task `包装成 `taskRunner`，并从线程池中抽取出一个空闲线程运行 `Task`。每个 `CoarseGrainedExecutorBackend` 能并行运行 `Task` 的数量就取决于分配给它的 `CPU` 的个数了；


### Cluster Manager

指的是在集群上获取资源的外部服务，目前有：

* `Standalone`：`Spark`原生的资源管理，由`Master`负责资源的分配；
* `Hadoop Yarn`：由`YARN`中的`ResourceManager`负责资源的分配；


### Worker

集群中任何可以运行`Application`代码的节点，类似于`YARN`中的`NodeManager`节点。在`Standalone`模式中指的就是通过`Slave`文件配置的`Worker`节点，在`Spark on Yarn`模式中指的就是`NodeManager`节点；

### 作业（Job)

包含多个`Task`组成的并行计算，往往由`Spark Action`催生，一个`JOB`包含多个`RDD`及作用于相应RDD上的各种Operation；

### 阶段（Stage）

每个`Job`会被拆分很多组 `Task`，每组任务被称为`Stage`，也可称`TaskSet`，一个作业分为多个阶段，每一个`stage`的分割点是`action`。

```
Job -> Tasks -> Stage(TaskSet) -> action 
```

比如一个job是：

`transformation1 -> transformation1 -> action1 -> transformation3 -> action2）`

这个job就会被分为两个`stage`，分割点是`action1`和`action2`。


### 任务（Task) 

被送到某个`Executor`上的工作任务；


### Context

启动`spark application`的时候创建，作为`Spark` 运行时环境。

### Dynamic Allocation（动态资源分配）：

一个配置选项，可以将其打开。从`Spark1.2`之后，对于`On Yarn`模式，已经支持动态资源分配`（Dynamic Resource Allocation）`，这样，就可以根据`Application`的负载（Task情况），动态的增加和减少`executors`，这种策略非常适合在`YARN`上使用`spark-sql`做数据开发和分析，以及将`spark-sql`作为长服务来使用的场景。`Executor` 的动态分配需要在 `cluster mode` 下启用 “external shuffle service”。



## 动态资源分配策略

开启动态分配策略后，`application`会在`task`因没有足够资源被挂起的时候去动态申请资源，这意味着该`application`现有的`executor`无法满足所有`task`并行运行。`spark`一轮一轮的申请资源，当有`task`挂起或等待

```
spark.dynamicAllocation.schedulerBacklogTimeout
```

(默认1s)时间的时候，会开始动态资源分配；之后会每隔

```  
spark.dynamicAllocation.sustainedSchedulerBacklogTimeout
```

**(默认1s)时间申请一次，直到申请到足够的资源。**

每次申请的资源量是指数增长的，即`1,2,4,8`等。之所以采用指数增长，出于两方面考虑：

* 其一，开始申请的少是考虑到可能`application`会马上得到满足；
* 其次要成倍增加，是为了防止`application`需要很多资源，而该方式可以在很少次数的申请之后得到满足。


## 架构设计

关于 `spark standalone` 的局限性与 `kubernetes native spark` 架构之间的区别请参考 `Anirudh Ramanathan` 在 2016年10月8日提交的 [issue Support Spark natively in Kubernetes #34377](https://github.com/kubernetes/kubernetes/issues/34377)。


简而言之，`spark standalone on kubernetes` 有如下几个缺点：

* 无法对于多租户做隔离，每个用户都想给 `pod` 申请 `node` 节点可用的最大的资源。
* `Spark` 的 `master／worker` 本来不是设计成使用 `kubernetes` 的资源调度，**这样会存在两层的资源调度问题，不利于与 `kuberentes` 集成**。


而 `kubernetes native spark` 集群中，`spark` 可以调用 `kubernetes API` 获取集群资源和调度。

**要实现 `kubernetes native spark` 需要为 `spark` 提供一个集群外部的 `manager` 可以用来跟 `kubernetes API` 交互。**

## 调度器后台

使用 `kubernete`s 原生调度的 `spark` 的基本设计思路是将 `spark` 的 `driver` 和 `executor` 都放在 `kubernetes` 的 `pod` 中运行，另外还有两个附加的组件：`ResourceStagingServer` 和 `KubernetesExternalShuffleService`。

![Alt Image Text](images/1_3.png "Body image")

#### `Spark driver` 其实可以运行在 `kubernetes` 集群内部（`cluster mode`）可以运行在外部（`client mode`），

#### `executor` 只能运行在集群内部，当有 `spark` 作业提交到 `kubernetes` 集群上时，调度器后台将会为 `executor pod` 设置如下属性：

* 使用我们预先编译好的包含 `kubernetes` 支持的 `spark` 镜像，然后调用 `CoarseGrainedExecutorBackend main class` 启动 `JVM`。
* 调度器后台为 `executor pod` 的运行时注入环境变量，例如各种 `JVM` 参数，包括用户在 `spark-submit` 时指定的那些参数。
* `Executor` 的 `CPU`、内存限制根据这些注入的环境变量保存到应用程序的 `SparkConf` 中。
* 可以在配置中指定 `spark` 运行在指定的 `namespace` 中。


参考：[Scheduler backend 文档](https://github.com/apache-spark-on-k8s/spark/blob/branch-2.2-kubernetes/resource-managers/kubernetes/architecture-docs/scheduler-backend.md)















