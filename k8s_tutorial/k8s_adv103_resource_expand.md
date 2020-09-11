# 为 Kubernetes 节点发布扩展资源

扩展资源允许集群管理员发布节点级别的资源，扩展资源类似于内存和 CPU 资源，比如一个节点拥有一定数量的内存和 CPU 资源，它们被节点上运行的所有组件共享，该节点也可以拥有一定数量的其他资源，这些资源同样被节点上运行的所有组件共享。此外，除了可以创建请求一定数量的内存和 CPU 资源的 Pod 之外， 同样也可以创建请求一定数量的扩展资源的 Pod。

但是扩展资源对 Kubernetes 是不透明的，Kubernetes 是不知道扩展资源的相关含义的，它只了解一个节点拥有一定数量的扩展资源。扩展资源必须以整形数量进行发布。例如，一个节点可以发布 4 个某种扩展资源，但是不能发布 4.5 个。


## 发布扩展资源

为在一个节点上发布一种新的扩展资源，需要发送一个 `HTTP PATCH` 请求到 `Kubernetes API server`。例如：假设你的一个节点上带有四个 `dongle` 资源。下面是一个 `PATCH` 请求的示例，该请求为你的节点发布四个 `dongle ` 资源。

```
PATCH /api/v1/nodes/<your-node-name>/status HTTP/1.1
Accept: application/json
Content-Type: application/json-patch+json
Host: k8s-master:8080

[
  {
    "op": "add",
    "path": "/status/capacity/example.com~1dongle",
    "value": "4"
  }
]
```

> 注意：Kubernetes 不需要了解 dongle 资源的含义和用途，前面的 PATCH 请求仅仅告诉 Kubernetes 你的节点拥有四个你称之为 dongle 的东西。


然后在终端中启动一个代理，然后我们就可以向 Kubernetes API server 发送请求了：

```
$ kubectl proxy
```

在另一个命令窗口中，发送 `HTTP PATCH` 请求。用你的节点名称替换 `<your-node-name>`：

```
$ curl --header "Content-Type: application/json-patch+json" \
  --request PATCH \
  --data '[{"op": "add", "path": "/status/capacity/example.com~1dongle", "value": "4"}]' \
  http://localhost:8001/api/v1/nodes/<your-node-name>/status
```

> 说明： 在前面的请求中，~1 为 patch 路径中 “/” 符号的编码。

输出显示该节点的 dongle 资源容量为 4：

```
"capacity": {
  "cpu": "2",
  "memory": "2049008Ki",
  "example.com/dongle": "4",
```

描述你的节点：

```
$ kubectl describe node <your-node-name>
```

我们就可以看到关于我们发布的 dongle 这种扩展资源的信息了：

```
Capacity:
 cpu:  2
 memory:  2049008Ki
 example.com/dongle:  4
```

## 分配扩展资源

扩展资源发布后，我们就可以把这种资源当成 CPU 或内存在 Pod 中请求使用了，要请求扩展资源，需要在 Pod 容器的资源清单中包括 `resources:requests` 字段。如下所示的资源清单文件，我们请求了`3`个发布的 `dongle `扩展资源：

```
# extended-resource-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: extended-resource-demo
spec:
  containers:
  - name: extended-resource-demo
    image: nginx:1.7.9
    resources:
      requests:
        example.com/dongle: 3
      limits:
        example.com/dongle: 3
```

然后和平时一样创建 Pod：

```
$ kubectl apply -f extended-resource-pod.yaml
```

当 Pod 运行成功后，描述 Pod 可以看到关于 dongle 的相关信息：

```
$ kubectl describe pod extended-resource-demo
......
Limits:
  example.com/dongle: 3
Requests:
  example.com/dongle: 3
......
```

接下来我们再创建一个 Pod 请求 2 个 dongle 扩展资源，资源清单文件如下所示：

```
# extended-resource-pod-2.yaml
apiVersion: v1
kind: Pod
metadata:
  name: extended-resource-demo-2
spec:
  containers:
  - name: extended-resource-demo-2-ctr
    image: nginx
    resources:
      requests:
        example.com/dongle: 2
      limits:
        example.com/dongle: 2
```
现在我们来创建这个 Pod，明显不能满足 2 个 dongles 的请求，因为第一个 Pod 已经使用了 3 个，而我们一共才 4 个这个扩展资源：

```
$ kubectl apply -f extended-resource-pod-2.yaml
```

创建后，查看 Pod 信息可以看到 Pod 不能被调度了，因为没有一个节点上存在两个可用的 dongle 资源：

```
$ kubectl describe pod extended-resource-demo-2
......
Conditions:
  Type    Status
  PodScheduled  False
...
Events:
  ...
  ... Warning   FailedScheduling  pod (extended-resource-demo-2) failed to fit in any node
fit failure summary on nodes : Insufficient example.com/dongle (1)
```

查看 Pod 的状态：

```
$ kubectl get pod extended-resource-demo-2
```

输出结果表明 Pod 虽然被创建了，但没有被调度到节点上正常运行。Pod 的状态为 Pending：

```
NAME                       READY     STATUS    RESTARTS   AGE
extended-resource-demo-2   0/1       Pending   0          6m
```

## 清理

首先删除上面创建的示例 Pod：

```
$ kubectl delete pod extended-resource-demo
$ kubectl delete pod extended-resource-demo-2
```

然后要移除发布的扩展资源，同样需要通过 PATCH 请求来执行：

```
PATCH /api/v1/nodes/<your-node-name>/status HTTP/1.1
Accept: application/json
Content-Type: application/json-patch+json
Host: k8s-master:8080

[
  {
    "op": "remove",
    "path": "/status/capacity/example.com~1dongle",
  }
]
```

启动一个代理：

```
$ kubectl proxy
```

在另一个命令窗口中，发送 HTTP PATCH 请求。用你的节点名称替换 `<your-node-name>`：

```
$ curl --header "Content-Type: application/json-patch+json" \
--request PATCH \
--data '[{"op": "remove", "path": "/status/capacity/example.com~1dongle"}]' \
http://localhost:8001/api/v1/nodes/<your-node-name>/status
```

验证 dongle 资源的发布已经被移除，正常看不到任何相关信息：




