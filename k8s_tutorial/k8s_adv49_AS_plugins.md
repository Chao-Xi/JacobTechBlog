# 6个与弹性伸缩、调度相关的Kubernetes附加组件

## 文章楔子

我认为部署一个可以使用的Kubernetes集群是非常轻松的任务。相比之下，在Kubernetes上运行你的容器才是更加消耗精力的任务，尤其对容器技术的初学者来说会更加艰难。如果你已经拥有一定的Docker使用经验，这个任务对你来说可能会稍稍简单一些，不过你依然需要掌握一些新的工具，例如Helm。 最后当我们自以为已经完成了所有的工作，并且终于在生产环境上部署了自己的应用后，就会发现其实我们依然有很多遗漏的工作需要补充。

可能Kubernetes并没有完美到把所有事情都照顾好，但Kubernetes是可以扩展的，**适当的引入一些插件和`Add-ons`可能会让你的生活没有那么痛苦。**

## `Kubernetes Add-ons`是什么？

一言以蔽之：`add-ons`完善和扩展了`Kubernetes`的功能。

**`Kubernetes`有很多`Add-ons`，并且你很可能已经使用了它们中的若干个。比如，网络插件`Calico`、`Flannel`，集群`DNS CoreDNS`。**

它们都是必要的`Kubernetes`插件，对于一个完整且能正常运行的`Kubernetes`集群来说，它们是不可或缺的。再比如知名的`Kubernetes Dashboard`，说它知名是因为这可能会是你在`Kubernetes`可以运行后第一时间想要尝试的插件。


但除此之外，还有很多其他插件可以帮助你更好的与`Kubernetes`一起工作，本文将会列举并介绍一些可以帮助你更好的部署应用的集群插件，下面将开始正文。

## 集群伸缩`Cluster Autoscaler`

`Cluster Autoscaler` 能根据资源利用率扩展你的群集节点。 

如果集群中有待调度的`pod`，`CA`将扩展群集，如果有未被充分利用的节点，则将集群缩小（可以通过配置`--scale-down-utilization-threshold`定义使用率低至几何时释放节点，默认值为`0.5`）。

毕竟任何人都不希望集群无法运行必要的容器，也不希望节点资源被白白浪费。

这个功能通常是需要配合云服务商的服务来运行的，如果需要了解更多，可以参考`Kubernetes Cluster Autoscaling on AWS`([https://akomljen.com/kubernetes-cluster-autoscaling-on-aws/](https://akomljen.com/kubernetes-cluster-autoscaling-on-aws/))。本文不再对该插件做过多介绍。

## 容器水平伸缩`Horizontal Pod Autoscaler`

`Horizontal Pod Autoscaler` 根据`CPU`使用率自动地调整`replication controller`、`replica set`或`deployment`中pod的数量，也可以借助`custom metrics` 支持利用更多资源指标进行伸缩。

`HPA`在`Kubernetes`中并不是一个新的功能，但`Banzai Cloud` 最近开源了`HPA Operator`项目，使得`HPA`变得更加易用。你只需要在`Deployment`或`StatefulSet`中添加特定的`annotation`，`HPA operator`就会处理好剩下的事情。你可以在这里查看支持的`annotation`。

`HPA operator`可以很方便的用Helm进行安装：

```
$ helm repo add akomljen-charts https://raw.githubusercontent.com/komljen/helm-charts/master/charts/
$ helm install --name hpa --namespace kube-system akomljen-charts/hpa-operator
$ kubectl get po --selector=release=hpa -n kube-system
$ kubectl get po --selector=release=hpa -n kube-system
NAME                                  READY     STATUS    RESTARTS   AGE
hpa-hpa-operator-7c4d47dd4-9khp       1/1       Running   0          1m
hpa-metrics-server-7766d7bc78-lnhn8   1/1       Running   0          1m
```

**`HPA-operator`会附加的安装`metrics-server`，安装了`Metrics Server`后`kubectl top pods` 命令也会变得可用，它在用户需要检查集群状态时是十分好用的。**

* `HPA`从一系列集成的`API`( `metrics.k8s.io`, `custom.metrics.k8s.io`, and `external.metrics.k8s.io`)获取`metrics`数据。

* 但通常`HPA`使用的是`metrics.k8s.io API`。这个`API`中的数据由`Heapster` (从Kubernetes 1.11开始弃用)或者`Metrics Server`产生。

* 在为`Deployment`添加了特定的`annotation`后，用户将能够通过下面的命令监控这个`Deployment`。

```
$ kubectl get hpa

NAME       REFERENCE             TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
test-app   Deployment/test-app   0%/70%    1         4         1          10m
```

**请记住，上面看到的`CPU Targets`的百分比是该`pod`已使用的`CPU`相对于`Pod`的`CPU request的`百分比，而不是对于节点上总的可用`CPU`的百分比。**

## 垂直伸缩`Vertical Pod Autoscaler - VPA`

通常我们需要为将在Kubernetes上部署的服务定义CPU和内存的request值。如果没有默认的CPU请求，则`kube-scheduler`将其视为请求`100m`或`0.1`可用的CPU，随后根据这些资源请求量决定运行该`pod`的节点。

但是，定义足够合适的请求值对用户来说并不是一个容易的任务。

**`VPA`可以根据`pod`使用的资源自动调整`CPU`和内存请求量。它参考`Metrics Server`来获取`pod`的资源用量。请记住，`VPA`只会管理request，您仍然需要手动定义`limit`。**

本文不会讨论VPA的细节，VPA需要一个专门的篇幅来进行讲解，但是有一些关于VPA的事实需要额外说明：

* VPA目前处于早期阶段，所以谨慎地使用它
* VPA只能运行在支持MutatingAdmissionWebhooks的集群中，这个特性从Kubernetes 1.9开始默认开启
* VPA不能和HPA一起工作
* **`VPA`动态调整`pod`的`request`值后，`pod`将重启。不过对于`kubernetes`用户来说，这是一个符合直觉的行为。**

## 插件伸缩`Addon Resizer Addon resizer`

是一个很有趣的小插件。**如果用户在上述的场景中使用了`Metrics Server`，`Metrics Server`的资源占用量会随着集群中的`Pod`数量的不断增长而不断上升。**


`Addon resizer` 容器会以`Sidecar`的形式监控与自己同一个`Pod`内的另一个容器（在本例中`Metrics Server`）并且垂直的扩展或收缩这个容器。

`Addon resizer`能依据集群中节点的数量线性地扩展`Metrics Server`，以保证其能够有能力提供完整的`metrics API`服务。更多的细节请参考官方文档。

[https://github.com/kubernetes/autoscaler/tree/master/addon-resizer](https://github.com/kubernetes/autoscaler/tree/master/addon-resizer)

## 撤销调度`Descheduler`

**`kube-scheduler`是`Kubernetes`中负责做工作负载调度的模块。**

但由于`Kubernetes`集群状态一直在变化，有时`Pod`也会被调度到并不适合它的节点上。 你可能在修改现有的资源，或者为节点或`pod`增加`affinity`定义，又或者你的某些节点忙到窒息，另一些又闲的发慌。

`kube-scheduler`不会尝试重新调度这些已经运行起来的容器。因此根据集群的大小你或许需要手动进行相当多的工作负载的转移工作。

**`Descheduler`会检查是否有可以移动的`Pod`，并将它们从当前的节点驱逐。**

`Descheduler`的正常工作依赖于默认调度器，因此它不能取代默认调度器的位置。 该项目目前从属于Kubernetes孵化阶段，还没有为生产做好准备。但它已经十分稳定并且起到了很好的作用。`Descheduler`被以`CronJob`的形式部署到集群中。

这里有一篇专题文章Meet a Kubernetes Descheduler([https://akomljen.com/meet-a-kubernetes-descheduler/](https://akomljen.com/meet-a-kubernetes-descheduler/))包含了这个插件的更多细节。


## 重调度器`k8s Spot Rescheduler`

我在AWS有两个弹性节点`group`（AWS和GCE中为虚拟主机分组的概念），**一组是长期固定(spot)的，另一组是按需启动(on-demand)的**，我一直在寻找管理他们的办法。

问题在于一旦我想要扩大固定组的节点数量我就需要把一部分Pod从按需启动的组中移出，以便将其缩小。

**`k8s spot rescheduler` 会不断尝试降低按需启动的实例上的负载，并在资源允许的情况下将pod驱逐到固定组中。** 在实际使用中，重调度器可以将Pod从任意一组节点转移到任意一组节点中。


这个工具可以使用helm进行部署:

```
$ helm repo add akomljen-charts https://raw.githubusercontent.com/komljen/helm-charts/master/charts/

$ helm install --name spot-rescheduler \
    --namespace kube-system \
    --set image.tag=v0.2.0 \
    --set cmdOptions.delete-non-replicated-pods="true" \
    akomljen-charts/k8s-spot-rescheduler
```

该工具的完整命令行选项可以在这里([https://github.com/pusher/k8s-spot-rescheduler#flags](https://github.com/pusher/k8s-spot-rescheduler#flags))找到

为了让Rescheduler正常工作，你需要为节点添加特定的label:

* `on-demand nodes – node-role.kubernetes.io/worker: "true"`
* `spot nodes – node-role.kubernetes.io/spot-worker: "true"`

并且添加`PreferNoSchedule` 污点在按需启动(on-demand)的节点上以确保`k8s spot rescheduler`更倾向于将`Pod`调度到固定组(`spot`)