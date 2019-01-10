# K8S Q&A Chapter Four

## 1. kubeadm 证书有效期问题

`kubeadm` 搭建集群的时候遇到一个很坑的问题就是**默认情况下集群证书只有一年有效期**，也就是一年后你的集群将不可用了，**这是因为 `kubeadm` 官方认为一个集群到了一年了就应该升级了**，但是往往我们在生产环境中的集群不可能频繁升级的，要解决这个证书的问题有两种方

* 当然是**直接去修改 `kubeadm` 的源码**，将默认的证书有效期时长尽量改长一点，然后重新编译打包，使用这个包来进行初始化集群
* 默认情况下，`kubeadm` 会生成集群运行所需的所有证书。我们也可以通过提供自己的证书来覆盖此行为。要做到这一点，您必须把它们放在 `--cert-dir` 参数或者配置文件中的 `CertificatesDir` 指定的目录（默认目录为 `/etc/kubernetes/pki`），**如果存在一个给定的证书和密钥对，`kubeadm` 将会跳过生成步骤并且使用已存在的文件**。例如，您可以拷贝一个已有的 `CA` 到 `/etc/kubernetes/pki/ca.crt` 和 `/etc/kubernetes/pki/ca.key`，**`kubeadm` 将会使用这个 `CA` 来签署其余的证书**。所以只要我们自己提供了一个有效期很长的证书去覆盖掉默认的证书也可以来避免这个坑人的问题。


## 2. 关于`java`应用中资源限制的问题

### 1.内存

时至今日，绝大多数产品级应用仍然在使用 `Java 8`（或者更旧的版本），而这可能会带来问题。`Java 8`（`update 131`之前的版本）跟 `Docker` 无法很好地一起工作。问题是在你的机器上，`JVM` 的可用内存和 `CPU` 数量并不是 `Docker` 允许你使用的可用内存和 `CPU` 数量。

**比如，如果你限制了你的 `Docker` 容器只能使用 `100MB` 内存，但是呢，旧版本的 `Java` 并不能识别这个限制。`Java` 看不到这个限制。`JVM` 会要求更多内存，而且远超这个限制。如果使用太多内存，`Docker` 将采取行动并杀死容器内的进程！`JAVA` 进程被干掉了，很明显，这并不是我们想要的。**

**为了解决这个问题，你需要给 `Java` 指定一个最大内存限制。在旧版本的 `Java`（`8u131`之前），你需要在容器中通过设置 `-Xmx `来限制堆大小。这感觉不太对，你可不想定义这些限制两次，也不太想在你的容器中来定义。**


幸运的是我们现在有了更好的方式来解决这个问题。从 `Java 9`之后（`8u131+`），`JVM` 增加了如下标志：


```
-XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap
```

这些标志强制 `JVM` 检查 `Linux` 的 `cgroup` 配置，**`Docker` 是通过 `cgroup` 来实现最大内存设置的**。现在，如果你的应用到达了 `Docker` 设置的限制（比如`500MB`），`JVM ` 是可以看到这个限制的。`JVM` 将会尝试 `GC` 操作。**如果仍然超过内存限制，`JVM` 就会做它该做的事情，抛出 `OutOfMemoryException`。也就是说，JVM 能够看到 `Docker` 的这些设置。**


**从 `Java 10` 之后，这些体验标志位是默认开启的，也可以使用 `-XX:+UseContainerSupport`来使能（你可以通过设置 `-XX:-UseContainerSupport` 来禁止这些行为)。**


### 2. CPU

第二个问题是类似的，但它与 `CPU` 有关。简而言之，`JVM` 将查看硬件并检测 `CPU` 的数量。它会优化你的 `runtime` 以使用这些 `CPUs`。但是同样的情况，这里还有另一个不匹配， `Docker` 可能不允许你使用所有这些 `CPUs`。可惜的是，这在 `Java 8`或 `Java 9`中并没有修复，但是在 `Java 10`中得到了解决。

**从 `Java 10`开始，可用的 `CPUs` 的计算将采用以不同的方式（默认情况下）解决此问题（同样是通过 `UseContainerSupport`）。**

## 3. Critical Pod 的使用

除了 `Kubernetes` 核心组件 `apiserver`、`scheduler`、`controller-manager` 之外，还有很多插件必须运行在一个普通的集群节点上。这些插件对于一个功能完备的集群来说是非常关键的，例如 `Heapster`、`DNS` 以及 `Dashboard` 等等。 **如果一个关键的插件被移除（类似升级这样具有副作用的其它操作）、或者变成挂起状态（例如当集群利用率过高，或者由于其它原因导致节点上可用资源的总量发生变化）、集群可能会停止正常工作。**


**为了保证核心组件的运行优先级最大化**，就需要用到 `CriticalPod`，即标记为**关键插件**，这样就可以保证关键插件的最优先调度，标记为关键插件的方法如下：


1. 需要在 `apiserver` 参数中启用 `ExperimentalCriticaPodAnnotatio` n这个 `Feature Gate`

2. `Pod` 必须隶属于`kube-system` 这个 `namespace`

3. 必须加上 `scheduler.alpha.kubernetes.io/critical-pod=""` 这个 `Annotation`

## 4. Prometheus 管理数据指标的方法

有的时候我们可能希望从 `Prometheus` 中删除一些不需要的数据指标，或者只是单纯的想要释放一些磁盘空间。`Prometheus` 中的时间序列只能通过 `HTTP API` 来进行管理。

**默认情况下，管理时间序列的 `API` 是被禁用的，要启用它，我们需要在 `Prometheus` 的启动参数中添加 `--web.enable-admin-api` 这个参数。**

如果你使用的是 `Prometheus Operator` 部署的话，貌似官方没有给出这个参数的配置，可以通过编辑对应的 `Staefulset` 资源对象来添加该参数。

控制管理 `API` 启用后，可以使用下面的语法来删除与某个标签匹配的所有时间序列指标：（将 `localhost` 替换成你自己的 `Prometheus` 的访问地址即可。）

```
$ curl -X POST -g 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]={kubernetes_name="redis"}'
```

上面命令就可以用于删除具有标签 `kubernetes_name="redis"` 的时间序列指标。

**如果要删除一些 `job` 任务或者 `instance` 的数据指标，则可以使用下面的命令：**

```
$ curl -X POST -g 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]={job="kubernetes-service-endpoints"}'
$ curl -X POST -g 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]={instance="10.244.2.158:9090"}'
```

要从 `Prometheus` 中删除所有的数据，可以使用如下命令：

**不过需要注意的是上面的 `API` 调用并不会立即删除数据，实际数据任然还存在磁盘上，会在后面进行数据清理。**

**要确定何时删除旧数据，可以使用 `--storage.tsdb.retention` 参数进行配置（默认情况下，`Prometheus` 会将数据保留`15`天）。**

## 5. Statefulset Pod 的管理策略

`Statefulset Pod` 的管理策略，对于某些分布式系统来说，`StatefulSet` 的顺序性保证是**不必要和/或者不应该的**。**这些系统仅仅要求唯一性和身份标志**。为了解决这个问题，在 `Kubernetes 1.7` 中我们针对 `StatefulSet API Object` 引入了 `.spec.podManagementPolicy:`

1. `OrderedReady Pod` 管理策略 `OrderedReady pod` 管理策略是 `StatefulSets` 的默认选项。它告诉 `StatefulSet` 控制器遵循上文展示的顺序性保证。
2. `Parallel Pod` 管理策略 `Parallel pod` 管理策略告诉 `StatefulSet` 控制器并行的终止所有 `Pod`，在启动或终止另一个 `Pod` 前，不必等待这些 `Pod` 变成 `Running` 和 `Ready` 或者完全终止状态。

## 6. kubectl exec 参数问题

在使用 `kubectl exec`执行命令的时候如果有参数该怎么执行呢？比如 `kubectl exec date--date=5/5/1925` 就会报 `--date` 是无效的参数。

回答：可以 `--` 用来将你传递给 `kubectl exec` 的参数与你想要传递给你要执行的命令的参数分开，例如

```
kubectl exec mypod --date --date=5/5/1925
```




