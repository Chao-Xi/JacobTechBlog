# `Kubernetes Namespace`命名空间详解

## 介绍

`Kubernetes`集群可以同时管理大量互不相关的工作负载，而组织通常会选择将不同团队创建的项目部署到共享集群上。随着数量的增加，部署对象常常很快就会变得难以管理，拖慢操作响应速度，并且会增加危险错误出现的概率。

**`Kubernetes`使用命名空间的概念帮助解决集群中在管理对象时的复杂性问题**。命名空间允许将对象分组到一起，便于将它们作为一个单元进行筛选和控制。无论是应用自定义的访问控制策略，还是为了测试环境而分离所有组件，命名空间都是一个按照组来处理对象、强大且灵活的概念。

在本文中，我们会讨论命名空间的工作原理，介绍一些常用实例，并分享如何使用命名空间来管理Kubernetes对象

## 什么是命名空间，为什么它很重要？

**命名空间（`namespace`）**是`Kubernetes`提供的组织机制，用于给集群中的任何对象组进行分类、筛选和管理。每一个添加到Kubernetes集群的工作负载必须放在一个命名空间中。

**命名空间为集群中的对象名称赋予作用域**。虽然在命名空间中名称必须是唯一的，**但是相同的名称可以在不同的命名空间中使用**。这对于某些场景来说可能帮助很大。例如，如果使用命名空间来划分应用程序生命周期环境（如开发、staging、生产），则可以在每个环境中维护利用同样的名称维护相同对象的副本。


命名空间还可以让用户轻松地将策略应用到集群的具体部分。你可以通过定义`ResourceQuota`对象来控制资源的使用，该对象在每个命名空间的基础上设置了使用资源的限制。类似地，当在集群上使用支持网络策略的`CNI`（容器网络接口）时，比如`Calico`或`Canal`（`calico`用于策略，`flannel`用于网络）。**你可以将`NetworkPolicy`应用到命名空间，其中的规则定义了`pod`之间如何彼此通信。不同的命名空间可以有不同的策略。**

使用命名空间最大的好处之一是能够利用`Kubernetes RBAC`（基于角色的访问控制）。`RBAC`允许您在单个名称下开发角色，这样将权限或功能列表分组。`ClusterRole`对象用于定义集群规模的使用模式，而角色对象类型（`Role object type`）**应用于具体的命名空间，从而提供更好的控制和粒度**。在角色创建后**，`RoleBinding`可以将定义的功能授予单个命名空间上下文中的具体具体用户或用户组**。通过这种方式，命名空间可以使得集群操作者能够将相同的策略映射到组织好的资源集合。


## 常见的命名空间使用模式

命名空间是一种非常灵活的特性，它不强制使用特定的结构或组织模式。不过尽管如此，还是有许多在团队内常使用的模式。

### 将命名空间映射到团队或项目上

**在设置命名空间时有一个惯例是，为每个单独的项目或者团队创建一个命名空间**。这和我们前面提到的许多命名空间的特性很好的结合在了一起。

通过给团队提供专门的命名空间，你可以用`RBAC`策略委托某些功能来实现自我管理和自动化。**比如从命名空间的`RoleBinding`对象中添加或删除成员就是对团队资源访问的一种简单方法**。除此之外，给团队和项目设置资源配额也非常有用。有了这种方式，你可以根据组织的业务需求和优先级合理地访问资源。
                       
### 使用命名空间对生命周期环境进行分区

命名空间非常适合在集群中划分开发、`staging`以及生产环境。通常情况下我们会被建议将生产工作负载部署到一个完全独立的集群中，来确保最大程度的隔离。不过对于较小的团队和项目来说，命名空间会是一个可行的解决方案。

和前面的用例一样，网络策略、RBAC策略以及配额是实现用例的重要因素。在管理环境时，通过将网络隔离来控制和组件之间的通信能力是很有必要的。同样，命名空间范围的RBAC策略允许运维人员为生产环节设置严格的权限。配额能够确保对最敏感环境的重要资源的访问。

重新使用对象名称的能力在这里很有帮助。在测试和发布对象时，可以把它们放到新环境中，同时保留其命名空间。这样可以避免因为环境中出现相似的对象而产生的混淆，并且减少认知开销。

### 使用命名空间隔离不同的使用者

另一个命名空间可以解决的用例是根据使用者对工作负载进行分段。比如，如果你的集群为多个客户提供基础设施，那么按命名空间进行分段就能够实现管理每个客户，同时跟踪账单的去向。

另外，命名空间的特性可以让你控制网络和访问策略，为你的使用者定义不同的配额。在通用的情况下，命名空间允许你为每个用户开发和部署相同模板化环境的不同实例。这种一致性可以大大简化管理和故障诊断的过程。


## 理解预配置的`Kubernetes`命名空间

在我们进行创建命名空间之前，先讨论一下Kubernetes是如何自动设置它的。在默认情况下，新的集群上有三个命名空间：

* **default**：**向集群中添加对象而不提供命名空间，这样它会被放入默认的命名空间中**。在创建替代的命名空间之前，该命名空间会充当用户新添加资源的主要目的地，无法删除。

* **kube-public**：**`kube-public`命名空间的目的是让所有具有或不具有身份验证的用户都能全局可读**。这对于公开`bootstrap`组件所需的集群信息非常有用。它主要是由Kubernetes自己管理。

* **kube-system**：**`kube-system`命名空间用于`Kubernetes`管理的`Kubernetes`组件，一般规则是，避免向该命名空间添加普通的工作负载**。它一般由系统直接管理，因此具有相对宽松的策略。
 
虽然这些命名空间有效地将用户工作负载与系统管理的工作负载隔离，但它们并不强制使用任何额外的结构对应用程序进行分类和管理。比较友好的是，创建和使用额外的命名空间非常简单


## 使用命名空间


使用kubectl管理命名空间及其包含的资源相当简单。在这一节中，我们将演示一些最常见的命名空间操作，便于你开始有效地分割资源。

### 查看现有的命名空间

要显示集群中可用的所有命名空间，使用`kubectl get namespaces` or `kubectl get ns`命令：

```
$ kubectl get namespace

NAME          STATUS    AGE
default       Active    3h
kube-public   Active    3h
kube-system   Active    3h
```
该命令显示了所有可用的命名空间，无论它们是否是活跃的。此外还有资源的时长（age）。

如果想获得更详细的信息，使用`kubectl describe`命令：

```
Name:         default 
Labels:       field.cattle.io/projectId=p-cmn9g 
Annotations:  cattle.io/status={"Conditions":[{"Type":"ResourceQuotaInit","Status":"True","Message":"","LastUpdateTime":"2018-12-17T23:17:48Z"},{"Type":"InitialRolesPopulated","Status":"True","Message":"","LastUpda...              field.cattle.io/projectId=c-7tf7d:p-cmn9g              lifecycle.cattle.io/create.namespace-auth=true
Status:       Active
No resource quota.
No resource limits.
```
该命令用于显示与命名空间关联的标签和注释，**以及已经应用了的所有配额或资源限制。**


### 创建命名空间

我们使用`kubectl create namespace`命令来创建命名空间。用命名空间的名称作为该命令的参数。

```
$ kubectl create namespace demo-namespace
namespace/demo-namespace created
```

你还可以通过文件，使用manifest来创建命名空间。例如，下面的文件定义了我们和上面一模一样的命名空间。

**`demo-namespace.yml`**

```
apiVersion: v1 
kind: Namespace 
metadata:
 name: demo-namespace 
```

假设上面的规范保存在`demo-namespace.yml`文件中。你可以输入指令来使用它：

```
$ kubectl create -f demo-namespace.yml
```

无论我们采用哪种方法创建命名空间，在我们再次检查可用命名空间时，应该能列出新的命名空间（我们使用ns——命名空间的缩写，第二次进行查询）：

```
$ kubectl get ns
NAME             STATUS    AGE
default          Active    3h
demo-namespace   Active    4m
kube-public      Active    3h
kube-system      Active    3h
```
我们新创建的命名空间已经变为可使用。

### 根据命名空间筛选和执行操作

如果我们将一个工作负载对象部署到集群而不指定命名空间，它将被添加到默认命名空间：

```
$ kubectl create deployment --image nginx demo-nginx
deployment.apps/demo-nginx created
```

我们可以使用`kubectl`来验证部署是否创建在默认的命名空间：

```
$ kubectl describe deployment demo-nginx | grep Namespace
Namespace:              default
```

如果我们尝试再次使用相同的名称创建部署，会得到命名空间冲突的错误。

```
$ kubectl create deployment --image nginx demo-nginx
Error from server (AlreadyExists): deployments.apps "demo-nginx" already exists
```

要将操作应用于不同的命名空间，我们必须在命令中包含`—namespace=`这一选项。下面我们在`demo-namespace`命名空间上创建具有相同名称的部署：

```
$ kubectl create deployment --image nginx demo-nginx --namespace=demo-namespace
deployment.apps/demo-nginx created
```

这次部署成功了，尽管我们仍然使用的是相同的部署名称。命名空间为资源名称提供了不同的作用域，避免了前面所经历的命名冲突。

如果想查看新部署的详细信息，我们再次使用`—namespace=选项`指定命名空间：

```
$ kubectl describe deployment demo-nginx --namespace=demo-namespace | grep Namespace
Namespace:              demo-namespace
```

这说明我们已经在`demo-namespace`命名空间创建了另一个名为`demo-nginx`的部署。

### 通过设置`Context`选择命名空间

如果希望避免为每个命令提供同样的命名空间，可以通过配置`kubectl`的`context`来改变命令作用的默认命名空间。这会修改操作在`context`活跃时应用到的命名空间。

列出`context`配置的细节，输入：

```
$ kubectl config get-contexts
CURRENT   NAME                          CLUSTER      AUTHINFO           NAMESPACE
*         kubernetes-admin@kubernetes   kubernetes   kubernetes-admin
```

上图说明我们使用了一个名为`Default`的`context`，`context`没有指定命名空间，因此使用了默认命名空间。

想要将该`context`使用的命名空间修改成`demo-context`，我们输入：

```
$ kubectl config set-context $(kubectl config current-context) --namespace=demo-namespace
Context "kubernetes-admin@kubernetes" modified.
```

我们可以在此查看`context`配置来验证当前是否选择了`demo-namespace`：

```
$ kubectl config get-contexts
CURRENT   NAME                          CLUSTER      AUTHINFO           NAMESPACE
*         kubernetes-admin@kubernetes   kubernetes   kubernetes-admin   demo-namespace
```

验证我们的`kubectl describe`命令现在默认使用`demo-namespace`，它会请求我们的`demo-nginx`部署而不需要指定命名空间：

```
$ kubectl describe deployment demo-nginx | grep Namespace
Namespace:              demo-namespace
```

### 删除命名空间并清理

如果不需要命名空间了，我们可以删除它。

删除命名空间这一功能非常强大，因为它不仅删除命名空间，还会清理其中部署了的所有资源。这一功能非常方便，但是同时如果你一不小心，也会非常危险。

在删除之前，最好列出和命名空间相关的资源，确定想要删除的对象：

```
$ kubectl get all --namespace=demo-namespace
NAME                              READY     STATUS    RESTARTS   AGE
pod/demo-nginx-676fc7d85d-t4ktg   1/1       Running   0          11m

NAME                         DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/demo-nginx   1         1         1            1           11m

NAME                                    DESIRED   CURRENT   READY     AGE
replicaset.apps/demo-nginx-676fc7d85d   1         1         1         11m
```

一旦确定了要操作的范围，可以输入下面的命令删除demo-namespace命名空间和其中的所有资源：

```
$ kubectl delete namespace demo-namespace
namespace "demo-namespace" deleted
```
命名空间及其资源将从集群中删除

```
$ kubectl get ns
NAME          STATUS    AGE
default       Active    3h
kube-public   Active    3h
kube-system   Active    3h
```

如果你之前在kubectl上下文中更改了所选的命名空间，那么输入下面的命令清除所选的命名空间：

```
$ kubectl config set-context $(kubectl config current-context) --namespace=
Context "kubernetes-admin@kubernetes" modified.
```

在清理demo资源时，请记住删除我们最初提供给默认命名空间的原始`demo-nginx`部署：

```
$ kubectl delete deployment demo-nginx
deployment.extensions "demo-nginx" deleted
```

现在你的集群应该处于一开始的状态了。                                         
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      