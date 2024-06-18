# 2024 Kubernetes 基础知识：Finalizers 是什么？

大家是否经历过这种情况：资源的删除卡住、挂起或需要很长时间（例如执行 kubectl delete po）？

也许 `kubectl delete ... --force --grace-period=0` 可以解决， 可能是容器需要比较多的时间做优雅关闭，或者容器 hang 住（主进程处于 D 状态）。

**我们也许需要通过删除 Finalizer 来删除相关资源。**

Kubernetes 对象删除并不像表面上看起来那么简单。删除对象是一个复杂的过程，其中包括条件检查以确定是否可以安全删除。这是通过称为 Finalizers 的 API 对象来实现的。

在本文中，我们将了解 Finalizers 是什么、它们的管理方式以及当我们想要删除对象时它们可能带来的挑战。更好地了解删除过程可以帮助我们调试资源似乎未及时终止的问题。

## 什么是 Finalizers？

Finalizers 属于资源元数据，表示所需的预删除操作 - 它们告诉资源控制器在删除对象之前需要执行哪些操作。例如比较常见的有：

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
  finalizers:
  - kubernetes.io/pvc-protection
...
```

实际的删除过程如下所示

* 发出删除命令：Kubernetes 将对象标记为待删除。这会使资源处于只读“Terminating”状态。
* 运行与对象的 Finalizers 相关的每个操作：每次 Finalizer 操作完成时，Finalizer都会与资源对象分离，因此它将不再会出现在 metadata.finalizers 字段中。
* **Kubernetes 持续监控附加到对象的 Finalizers 字段：一旦 metadata.finalizers 为空，该对象将被删除，因为所有 Finalizers 都已完成其操作并被删除了**。

Finalizers 通常用于在从集群中删除对象之前执行清理和垃圾收集。我们可以使用 Kubernetes API 添加自己的终结器；内置终结器也会自动应用于某些类型的对象（例如 kubernetes.io/pvc-protection）。



![Alt Image Text](images/adv/adv158_1.png "Body image")


## 挑战

**如果 Finalizers 需要等待其他相关资源的特定状态，可能会运行时间过长（或者一直运行）**，从而会导致资源删除操作卡在 Terminating 状态。**我们还可能会遇到 Finalizers 阻止依赖对象被删除，从而导致其父对象无法成功终止**。

这些问题经常引起混乱 - 开发人员和操作人员倾向于将删除视为简单的过程，而实际上该过程是微妙且可变的。成功删除的先决条件取决于资源的关系及其 Finalizers，并不仅仅是目标对象本身。

**当对象卡在 Terminating 时间过长时，请通过检查 metadata.finalizers 其 YAML 中的字段来检查 Finalizers：**

```
kubectl get pod example-pod --namespace example -o json | jq
```

![Alt Image Text](images/adv/adv158_2.png "Body image")

一旦知道定义了哪些终结器，我们就可以开始识别可能阻止删除的 Finalizers。

**查看对象的事件和条件更改可以通过显示自发出删除命令以来发生的操作来帮助调试。**

条件在 YAML 字段中 `spec.status.conditions`；查看事件可用 `kubectl describe pod example-pod`（Kubernetes 小技巧 - 通过 Events 发现问题）。

**我们可以通过将 `spec.finalizers` 设置为null 来手动删除对象的 Finalizers。除非绝对必要，否则不应使用此方法。终结器是旨在保护您的集群的保障措施；覆盖它们可能会导致孤立对象和破坏的依赖链。**

```
kubectl patch pod example-pod -p '{"metadata: {"finalizers": null}}'
```

## 所有者和传播策略（Propagation Policies）

所有者引用（Owner references）定义了对象之间的关系。它们用于在删除父对象时删除整个对象树。举个例子，如果删除一个 Deployment，Kubernetes 还会删除该 Deployment 中的 Pod。

所有者引用是通过对象上的 metadata.ownerReferences 字段定义的。每个引用都包含当前资源的父对象的 kind 和 name。

使用所有者引用时，删除父资源会自动删除其所有子资源。这称为级联删除。可以通过将--cascade=orphan标志添加到 kubectl delete 来禁用级联删除。Kubernetes 将允许对象的子对象保留在集群中，使它们会成为孤儿资源。

Kubernetes 还支持不同的删除“传播策略”。这些定义是否首先删除父项或其子项。默认 Foreground 策略会删除子级，然后删除父级，以确保不会发生孤儿现象。Background反转顺序，以便首先删除父级。第三个策略Orphan指示 Kubernetes 完全忽略所有者引用。

kubectl delete 命令不支持传播策略。如果您想要更改删除操作的策略，必须直接使用 API 方式：

```

curl -X DELETE localhost/api/v1/namespaces/default/deployments/example

-d '{"apiVersion": "v1", "kind": "DeleteOptions", "propagationPolicy": "Background"}'

-H "Content-Type: application/json"
```

当删除传播或级联到相关对象时，Finalizers 会受到尊重。

就 Foreground 策略而言，这意味着所有子级上的所有终结器都需要在父级终止之前完成。对于Background 策略，子 Finalizers 将保持活动状态，直到其父级的 Finalizers 完成为止。


## 结论


Finalizers 影响了进行删除 Kubernetes 对象的生命周期。它们用于实现垃圾收集，通知控制器即将删除，并防止意外删除仍在被其他资源引用的对象。


由于终结器可以在任意长时间内阻止对象删除，因此在执行删除操作的时候，我们要检查受影响的资源，查看哪些 Finalizers 处于活动状态，并调查可能充当阻塞依赖关系的对象间关系。如果我们必须立即删除终止对象或者已用尽所有其他选项，则强制删除 Finalizers 应该是最后的选择。
