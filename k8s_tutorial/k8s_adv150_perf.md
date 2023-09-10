# Kubernetes 资源管理：最大化集群性能

Kubernetes 资源管理是部署和管理容器化应用程序的一个关键方面。它允许管理员控制系统不同部分之间计算资源的分配，**例如CPU、内存和存储**。

有效的资源管理可确保应用程序获得正确运行所需的资源，同时最大限度地提高集群利用率并降低成本。

在 Kubernetes 中，有两种类型的资源：**计算资源和非计算资源**。

* **CPU（中央处理单元）**：这是指容器或 Pod 所需的计算能力。它包括核心数量、时钟速度和其他与处理器相关的指标
* **内存**：这是指容器或 Pod 可用的随机存取内存 (RAM) 量。内存用于存储需要快速访问的数据和程序指令
* **临时存储**：指容器或 Pod 运行的节点提供的临时存储空间。临时存储用于保存不需要在重新启动或重新引导后保留的文件

非计算资源是指运行容器或 Pod 所需的所有其他资源：


* **网络带宽**：容器或 Pod 与其他容器、Pod 和服务通信时可用的网络带宽量。这包括在给定时间段内可以通过网络传输的数据量
* **磁盘 IOPS**：容器或 Pod 可以在磁盘存储上执行的每秒输入/输出操作数 (IOPS)。这会影响涉及向磁盘读取和写入数据的任务的性能
* **GPU 加速**：使用图形处理单元 (GPU) 来加速计算密集型任务，例如机器学习、科学模拟和视频渲染。需要 GPU 加速的容器或 Pod 可以请求访问 GPU 资源以提高其性能

这些资源通常使用单独的 API 和工具进行管理。


## 资源管理的重要性

* 确保您的应用程序有足够的资源来平稳运行并满足其性能目标
* 防止您的应用程序消耗超出其需要的资源，这可能会影响其他应用程序或导致资源匮乏
* 使 Kubernetes 能够根据应用程序和节点的资源需求以及可用性做出调度决策
* 允许您通过优化集群的资源利用率和分配来控制基础设施的成本和效率

### Kubernetes资源

**集群资源**

集群资源是整个Kubernetes集群的共享资源。

这些资源由集群本身管理，它们不依赖于任何特定的 Pod 或部署：

* CPU：集群中节点的处理能力，以毫核（mCPU）为单位测量
* 内存：集群中节点上可用的 RAM 量，以字节为单位
* Storage：集群中可用的持久存储量，以字节为单位
* 网络带宽：集群中可用的网络带宽量，以每秒位数 (bps) 为单位

**Pod资源**

Pod 资源是分配给集群上运行的各个 Pod 的资源。

每个 Pod 都有自己的一组资源，可以独立定义和请求

* CPU：pod 请求的 CPU 量，以毫核 (mCPU) 为单位测量
* Memory : Pod 请求的内存量，以字节为单位
* Volume Storage : Pod 请求的持久存储量，以字节为单位

## **Kubernetes 如何管理资源？**

Kubernetes 有几个与资源管理相关的概念：

* **资源配额(Resource quota)**：一种限制 pod 或命名空间中其他对象可以请求或消耗的资源总量的机制。
	* **资源配额由准入控制器强制执行，该控制器拒绝超出配额的请求**
* **限制范围(Limit range)**：**一种指定命名空间中 pod 或容器的默认或最大请求和限制的机制**。限制范围由准入控制器强制执行，该控制器根据限制范围配置设置或拒绝请求和限制
* **Pod 拓扑分布约束(Pod topology spread constraints)**：**一种根据标签控制 Pod 如何跨节点或区域分布的机制**。Pod 拓扑分布约束有助于提高可用性并平衡节点或区域之间的资源利用率
* **污点和容忍度(Taints and tolerations**)：一种用属性标记节点的机制，这些属性会拒绝在节点上调度 pod，除非它们具有匹配的容忍度。污点和容忍有助于隔离用于专用目的的节点或避免来自其他 Pod 的干扰
* **节点亲和性和反亲和性(Node affinity and anti-affinity)**：一种根据标签来约束 pod 可以调度到哪些节点的机制。节点亲和性和反亲和性有助于确保 Pod 放置在满足特定标准（例如性能、可用性或邻近性）的节点上
* **Pod 亲和性和反亲和性(Pod affinity and anti-affinity)**：一**种根据标签限制哪些 pod 可以共存于同一节点上的机制**。Pod 亲和性和反亲和性有助于确保 Pod 根据其要求（例如通信、安全性或资源消耗）放置在一起或分开
* **Pod 优先级和抢占(Pod priority and preemption)**：一种为 Pod 分配优先级值的机制，如果节点上没有足够的资源，则允许较高优先级的 Pod 抢占较低优先级的 Pod。Pod 优先级和抢占有助于确保重要的 Pod 在不太重要的 Pod 之前调度和运行
* **Pod 过量使用(Pod overcommit)**：**一种允许在节点上调度比其可分配资源更多的 pod 的机制**。Pod 过度使用可以提高资源利用率和密度，但也会增加争用和驱逐的风险。
	* **Pod 过量使用由 pod 的 QoS 类别和 kubelet 的驱逐策略控制**

## 资源监控

* **kubectl top**
	* Command-line tool that displays current CPU and memory usage of pods or nodes in a cluster 显示集群中 pod 或节点当前 CPU 和内存使用情况的命令行工具
	* Pros: Easy to use, no additional setup required易于使用，无需额外设置
	* Cons: Limited functionality, only shows current usage 功能有限，仅显示当前使用情况

* **Grafana**	
	* Open-source analytics and visualization platform that integrates with Prometheus and other data sources to create dashboards and alerts for monitoring cluster resources and performance
开源分析和可视化平台，与 Prometheus 和其他数据源集成，创建用于监控集群资源和性能的仪表板和警报	
	* **Pros**:  Highly flexible and customizable, supports multiple data sources
高度灵活可定制，支持多种数据源	
	* **Cons**: Can be complex to set up and configure, especially for larger deployments 设置和配置可能很复杂，特别是对于大型部署

* **Metrics Server**	
	* Cluster-wide aggregator of resource usage data that collects metrics from the kubelet on each node and exposes them through the Metrics API 集群范围内的资源使用数据聚合器，从每个节点上的 kubelet 收集指标并通过 Metrics API 公开它们	
	* 	**Pros**:  Provides detailed usage statistics across all nodes and pods 提供所有节点和 Pod 的详细使用统计信息
	* **Cons**: 	Requires additional setup and configuration
需要额外的设置和配置

* **Prometheus**
	* Open-source monitoring system that collects and stores metrics from various sources, including Kubernetes nodes and pods, using a pull modelAlso provides a query language and visualization tools for analyzing the metrics 开源监控系统，使用拉模型收集和存储来自各种来源（包括 Kubernetes 节点和 Pod）的指标，还提供用于分析指标的查询语言和可视化工具	
	* 	**Pros**: Highly customizable, can be integrated with other systems 高度可定制，可与其他系统集成
	* **Cons**: Steep learning curve, requires significant setup and maintenance efforts 学习曲线陡峭，需要大量的设置和维护工作


## 资源优化

**Cluster Autoscaler**

* Automatically adjusts the size of a node pool based on the demand for resources by the podsCluster autoscaler can also scale down nodes that are underutilized or have low-priority pods
	* podsCluster autoscaler 根据资源需求自动调整节点池的大小，还可以缩减未充分利用或具有低优先级 pod 的节点
 
* Scale the cluster up or down based on changing resource demands, reducing costs when possible
	* 根据不断变化的资源需求扩展或缩小集群，尽可能降低成本


**Horizontal Pod Autoscaler (HPA) 水平 Pod 自动缩放器 (HPA)**	

* Automatically scales the number of pods in a deployment, replica set, stateful set, or HPA based on observed CPU or memory utilization, or custom metrics 根据观察到的 CPU 或内存利用率或自定义指标，自动扩展部署、副本集、有状态集或 HPA 中的 Pod 数量

* Improve resource utilization and availability by scaling pods horizontally 通过水平扩展 Pod 提高资源利用率和可用性


**Pod Topology Spread Constraints Pod 拓扑传播约束**

* Improves resource utilization and balance across nodes or zones by spreading pods evenly based on labels
通过基于标签均匀分布 Pod，提高资源利用率和跨节点或区域的平衡
* Ensure that pods are distributed evenly across available resources, improving overall efficiency and reliability 确保 Pod 均匀分布在可用资源中，从而提高整体效率和可靠性

**Resource Bin Packing 资源箱包装**	

* Scheduling strategy that places pods with complementary resource demands on the same nodeAchieved by using appropriate requests and limits, pod affinity and anti-affinity, and pod priority and preemption
将资源需求互补的 pod 放置在同一节点上的调度策略通过使用适当的请求和限制、pod 亲和性和反亲和性、pod 优先级和抢占来实现
* Maximizes resource utilization within a node by filling it with pods that fit well together
通过用能够很好地配合在一起的 Pod 填充节点，最大限度地提高节点内的资源利用率


**Vertical Pod Autoscaler (VPA)垂直 Pod 自动缩放器 (VPA)**

* Automatically adjusts the CPU and memory requests and limits of pods based on historical usage or recommendationsVPA can also evict and restart pods with new resource settings if needed
根据历史使用情况或建议自动调整 Pod 的 CPU 和内存请求和限制 VPA 还可以根据需要使用新的资源设置驱逐和重新启动 Pod
* Optimize resource allocation and reduce waste by adjusting pod resource requests and limits vertically
通过垂直调整 pod 资源请求和限制来优化资源分配并减少浪费