![Alt Image Text](images/adv/adv19_0.jpg "Headline image")
# Kubernetes 服务质量 `Qos` 解析
# `Pod` 资源 `requests` 和 `limits` 如何配置?

### `QoS`是 `Quality of Service` 的缩写，即服务质量。

为了实现资源被有效调度和分配的同时提高资源利用率，`kubernetes`针对不同服务质量的预期，通过 `QoS（Quality of Service` 来对 `pod` 进行服务质量管理。对于一个 `pod` 来说，服务质量体现在两个具体的指标：`CPU` 和`内存`。当节点上内存资源紧张时，`kubernetes` 会根据预先设置的不同 `QoS` 类别进行相应处理。

### `QoS` 主要分为`Guaranteed`、`Burstable` 和 `Best-Effort`三类，优先级从高到低。

## Guaranteed(有保证的)

属于该级别的`pod`有以下两种：

* `Pod`中的所有容器都且仅设置了 `CPU` 和内存的 `limits`
* `pod`中的所有容器都设置了 `CPU` 和内存的 `requests` 和 `limits` ，且单个容器内的`requests==limits`（`requests不等于0`）

`pod`中的所有容器都且仅设置了`limits`：

```
containers:
  name: foo
    resources:
      limits:
        cpu: 10m
        memory: 1Gi
  name: bar
    resources:
      limits:
        cpu: 100m
        memory: 100Mi
 ```
 
 pod 中的所有容器都设置了 `requests` 和 `limits`，且单个容器内的`requests==limits`：
 
 ```
 containers:
  name: foo
    resources:
      limits:
        cpu: 10m
        memory: 1Gi
      requests:
        cpu: 10m
        memory: 1Gi

  name: bar
    resources:
      limits:
        cpu: 100m
        memory: 100Mi
      requests:
        cpu: 100m
        memory: 100Mi
 ```
 
 容器`foo`和`bar`内`resources`的`requests`和`limits`均相等，该`pod`的`QoS`级别属于`Guaranteed`。
 
##  Burstable(不稳定的)

pod中只要有一个容器的`requests`和`limits`的设置不相同，该`pod`的`QoS`即为`Burstable`。

容器`foo`指定了`resource`，而容器`bar`未指定：

```
containers:
  name: foo
    resources:
      limits:
        cpu: 10m
        memory: 1Gi
      requests:
        cpu: 10m
        memory: 1Gi

  name: bar
```

容器`foo`设置了内存`limits`，而容器`bar`设置了`CPU limits`：

```
containers:
  name: foo
    resources:
      limits:
        memory: 1Gi

  name: bar
    resources:
      limits:
        cpu: 100m
```

### 注意：
* 若容器指定了`requests`而未指定`limits`，则`limits`的值等于节点`resource`的最大值；
* 若容器指定了`limits`而未指定`requests`，则`requests`的值等于`limits`。

## Best-Effort(尽最大努力)

如果`Pod`中所有容器的`resources`均未设置`requests`与`limits`，该`pod`的`QoS`即为`Best-Effort`。

容器`foo`和容器`bar`均未设置`requests`和`limits`：

```
containers:
  name: foo
    resources:
  name: bar
    resources:
```

## 根据QoS进行资源回收策略

**`Kubernetes` 通过`cgroup`给`pod`设置`QoS`级别，**当资源不足时先`kill`优先级低的 `pod`，在实际使用过程中，通过`OOM`分数值来实现，`OOM`分数值范围为`0-1000`。`OOM` 分数值根据`OOM_ADJ`参数计算得出。

* 对于`Guaranteed`级别的 `Pod`，`OOM_ADJ`参数设置成了`-998`，
* 对于`Best-Effort`级别的 `Pod`，`OOM_ADJ`参数设置成了`1000`，
* 对于`Burstable`级别的 `Pod`，`OOM_ADJ`参数取值从`2`到`999`。

### 1. 对于 `kuberntes` 保留资源，比如`kubelet`，`docker`，`OOM_ADJ`参数设置成了`-999`，表示不会被`OOM kill`掉。
### 2. `OOM_ADJ`参数设置的越大，计算出来的`OOM`分数越高，表明该`pod`优先级就越低，当出现资源竞争时会越早被`kill`掉，

### 3. 对于`OOM_ADJ`参数是`-999`的表示`kubernetes`永远不会因为`OOM`将其`kill`掉。

## `QoS pods`被`kill`掉场景与顺序

* `Best-Effort pods`：系统用完了全部内存时，该类型 `pods` 会最先被`kill`掉。
* `Burstable pods`：系统用完了全部内存，且没有 `Best-Effort` 类型的容器可以被 `kill` 时，该类型的 `pods` 会被 `kill` 掉。
* `Guaranteed pods`：系统用完了全部内存，且没有 `Burstable` 与 `Best-Effort` 类型的容器可以被 `kill `时，该类型的 `pods` 会被 `kill` 掉。

## QoS使用建议


**如果资源充足，可将 `QoS pods` 类型均设置为`Guaranteed`。用计算资源换业务性能和稳定性，减少排查问题时间和成本。**

如果想更好的提高资源利用率，业务服务可以设置为`Guaranteed`，而其他服务根据重要程度可分别设置为`Burstable`或`Best-Effort`。
