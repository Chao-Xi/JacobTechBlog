# 图解 Kubernetes Service —— 技术详解

在 Kubernetes 中 Service 主要有4种不同的类型，其中的 ClusterIP 是最基础的。

![Alt Image Text](images/adv/adv106_1.png "Body image")

上图解释了 Kubernetes 的 Service 的基本关系，

* **当我们创建一个 `NodePort` 的 `Service` 时，它也会创建一个 `ClusterIP`**
* **而如果你创建一个 `LoadBalancer`，它就会创建一个 `NodePort`，然后创建一个 `ClusterIP`**

此外我们还需要明白 Service 是指向 pods 的，Service 不是直接指向 Deployments 或 ReplicaSets，**而是直接使用 labels 标签指向 Pod，这种方式就提供了极大的灵活性，因为通过什么方式创建的 Pod 其实并不重要**。接下来我们通过一个简单的例子开始，我们用不同的 Service 类型来逐步扩展，看看这些 Service 是如何建立的。

## No Services

最开始我们没有任何的 Services。

![Alt Image Text](images/adv/adv106_2.png "Body image")

我们有两个节点，一个 Pod，节点有外网（4.4.4.1、4.4.4.2）和内网（1.1.1.1、1.1.1.2）的 IP 地址，**`pod-python` 这个 Pod 只有一个内部的 IP 地址。**

![Alt Image Text](images/adv/adv106_3.png "Body image")

现在我们添加第二个名为 `pod-nginx` 的 `Pod`，它被调度在 `node-1` 节点上。

在 Kubernetes 中，所有的 Pod 之间都可以通过 Pod 的 IP 进行通信，不管它们运行在哪个节点上。

**这意味着 `pod-nginx` 可以使用其内部`IP 1.1.1.3` 来` ping `和连接 `pod-python` 这个 Pod。**

![Alt Image Text](images/adv/adv106_4.png "Body image")

现在如果 `pod-python` 挂掉了重新创建了一个新的 `pod-python` 出来（本文不涉及如何管理和控制 pods），**重新分配了一个新的 `1.1.1.5` 的 `Pod IP` 地址，这个时候 `pod-nginx` 就无法再达到 `1.1.1.3` 这个之前的地址了，为了防止这种情况发生，我们就需要创建一个 Service 服务了！**


## ClusterIP

![Alt Image Text](images/adv/adv106_5.png "Body image")

和上面同样的场景，**但是我们创建了一个名为 `service-python` 类型为 ClusterIP 的 Service 服务，一个 Service 并不像 Pod 那样运行在一个特定的节点上**，

这里我们可以假设一个 Service 只是在整个集群内部的内存中可用就可以了。

**`pod-nginx` 可以安全地连接到 `1.1.10.1` 这个` ClusterIP` 或直接通过 `dns` 名`service-python` 进行通信，并被重定向到后面一个可用的 `Pod` 上去。**

![Alt Image Text](images/adv/adv106_6.png "Body image")

现在我们来稍微扩展下这个示例，启动3个 python 实例，现在我们来显示所有 Pod 和 Service 内部 IP 地址的端口。

**集群内部的所有 Pods 都可以通过 `http://1.1.10.1:3000` 或者` http://service-python:3000` 来访问到后面的 python pods 的443端口。**

**`service-python` 这个 `Service` 是随机或沦陷的方式来转发请求的，这个就是 `ClusterIP Service` 的作用，它通过一个名称和一个 `IP `让集群内部的 `Pods` 可用。**

上图中的 service-python 这个 Service 可以用下面的 yaml 文件来创建：

```
apiVersion: v1
kind: Service
metadata:
  name: service-python
spec:
  ports:
  - port: 3000
    protocol: TCP
    targetPort: 443
  selector:
    run: pod-python
  type: ClusterIP
```
创建后，可以用 kubectl get svc 命令来查看：


![Alt Image Text](images/adv/adv106_7.png "Body image")

## NodePort

现在我们想让 `ClusterIP Service` 可以从集群外部进行访问，为此我们需要把它转换成 `NodePort` 类型的 Service，在我们的例子中，我们只需要简单修改上面的 `service-python` 这个 `Service` 服务即可：

```
apiVersion: v1
kind: Service
metadata:
  name: service-python
spec:
  ports:
  - port: 3000
    protocol: TCP
    targetPort: 443
    nodePort: 30080
  selector:
    run: pod-python
  type: NodePort
```

更新完成后，如下图所示：

![Alt Image Text](images/adv/adv106_8.png "Body image")

> 外部通过 node-2 节点进行请求

集群内部的 Pod 也可以通过内网节点 IP 连接到 30080 端口。

![Alt Image Text](images/adv/adv106_9.png "Body image")

运行 `kubectl get svc` 命令来查看这个 `NodePort` 的 `Service`，可以看到同样有一个 `ClusterIP`，只是类型和额外的节点端口不同。在内部，`NodePort` 服务仍然像之前的 `ClusterIP` 服务一样。

![Alt Image Text](images/adv/adv106_10.png "Body image")

## LoadBalancer

如果我们希望有一个单独的 IP 地址，将请求分配给所有的外部节点IP（比如使用 `round robin`），我们就可以使用 `LoadBalancer` 服务，所以它是建立在 NodePort 服务之上的。

![Alt Image Text](images/adv/adv106_11.png "Body image")

一个 LoadBalancer 服务创建了一个 NodePort 服务，NodePort 服务创建了一个 ClusterIP 服务。我们也只需要将服务类型更改为 LoadBalancer 即可。

```
apiVersion: v1
kind: Service
metadata:
  name: service-python
spec:
  ports:
  - port: 3000
    protocol: TCP
    targetPort: 443
    nodePort: 30080
  selector:
    run: pod-python
  type: LoadBalancer
```

LoadBalancer 服务所做的就是创建一个 NodePort 服务，此外，它还会向托管 Kubernetes 集群的提供商发送一条消息，要求设置一个指向所有外部节点 IP 和特定 nodePort 端口的负载均衡器，当然前提条件是要提供商支持。

现在运行 `kubectl get svc` 可以看到新增了 `external-IP` 和` LoadBalancer` 的类型。

![Alt Image Text](images/adv/adv106_12.png "Body image")

**LoadBalancer 服务仍然像和以前一样在节点内部和外部 IP 上打开 30080 端口。**

## ExternalName

最后是 ExternalName 服务，这个服务和前面的几种类型的服务有点分离。它创建一个内部服务，其端点指向一个 DNS 名。

我们假设 pod-nginx 运行在 Kubernetes 集群中，但是 python api 服务在集群外部。

![Alt Image Text](images/adv/adv106_13.png "Body image")


这里 pod-nginx 这个 Pod 可以直接通过 `http://remote.server.url.com` 连接到外部的 `python api `服务上去，但是如果我们考虑到以后某个时间节点希望把这个 `python api `服务集成到` Kubernetes` 集群中去，还不希望去更改连接的地址，这个时候我们就可以创建一个 ExternalName 类型的 Service 服务了。

![Alt Image Text](images/adv/adv106_14.png "Body image")

对应的 YAML 资源清单文件如下所示：

```
kind: Service
apiVersion: v1
metadata:
  name: service-python
spec:
  ports:
  - port: 3000
    protocol: TCP
    targetPort: 443
  type: ExternalName
  externalName: remote.server.url.com
```

现在 pod-nginx 就可以很方便地通过 http://service-python:3000 进行通信了，就像使用 ClusterIP 服务一样，当我们决定将 python api 这个服务也迁移到我们 Kubernetes 集群中时，我们只需要将服务改为 ClusterIP 服务，并设置正确的标签即可，其他都不需要更改了。

 ![Alt Image Text](images/adv/adv106_15.png "Body image") 


