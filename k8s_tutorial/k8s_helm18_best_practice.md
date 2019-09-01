# 在Kubernetes平台上如何使用Helm部署以获得最佳体验？

`Helm`是Kubernetes软件生态中的一个软件包管理器，提供了一种“简单的方法来查找、共享和使用为 Kubernetes 而构建的软件”，因此它是常用的管理应用程序部署的工具之一。需要注意的是，`Helm`是一种打包格式，而非将代码部署到`Kubernetes`上的工作流程。


`Helm`是围绕`chart`构建的。从根本上来说，这些`chart`是一系列定义Kubernetes资源相关的`YAML`文件，是`Helm`用于打包`Kubernetes`资源的方式。`chart`可以让我们给`Kubernetes`构建模块.

### 一个基本的`Helm chart`

```
~/charts/app
├── Chart.yaml
├── README.md
├── templates
│   ├── NOTES.txt
│   ├── _helpers.tpl
│   ├── deployment.yaml
│   ├── ingress.yaml
│   ├── secret.yaml
│   └── service.yaml
└── values.yaml
```

一个最简单的`Helm chart`由一个`chart`元数据（`Chart.yaml`和`values.yaml`）和组成主要`chart`的`template`构成。主要的`chart`配置包括`chart`的命名和版本控制。`values`文件中提供安装`chart`时配置参数的默认值。

`Helm`作为一个抽象层，简化了一组可以扩展为多个`Kubernetes`资源清单的值

### Deployment、Service和Ingress

大多数`Helm chart`的核心工作是发布联网的应用程序。有3种资源是部署应用程序的关键，同时还能够从外部集群与之进行通信：

* **`Deployment`发布你的代码**
* **`Service`将流量从内部路由到你的代码**
* **`Ingress`将外部流量路由到集群中的代码**

现在让我们来看一个关于在`Helm chart`中`service`的例子以及template如何让我们重定义选项：

```

apiVersion: v1
kind: Service
metadata:
  name: {{ include "app.fullname" . }}
  labels:
{{ include "app.labels" . | indent 4 }}
spec:
  type: {{ .Values.service.type }}
```

这一简单的service资源示例显示了一些模板工具，可用于创建帮助程序以指定资源的全名。创建此服务的相应值如下所示：

```
service:
  type: ClusterIP
  port: 80
```

这是使用Helm抽象出底层资源的一个简单示例。

## 固定的工作发布流程

`Helm`旨在减少分散的资源管理以安装软件到你的集群中。在选择`Helm`发布代码时，这里有两套工作流程：


1. 发布第三方代码到集群。此代码通常是语义版本，并以较慢的节奏发布，可能是每月或每年，具体取决于更新周期。
2. 持续部署到你的Kubernetes集群。这类代码常常每日发布，或者更频繁。

第一种情况是`Helm`最初的设计目的，它要求`chart`实现语义版本并使`chart`升级相对简单。使用Helm最有效的方法是配合第三方程序一起使用，如`Terraform`。这组合可以在集群中实现稳定且一致的发布流程。这通常与你的基础架构的其余部分一起作为代码工作流程。

本文的主要目的是了解在持续部署过程中如何使用Helm。在开始时，有效地执行此操作可能看起来很简单，但要确保部署有效，还是需要注意一些事项。

使用`Helm`和`CLI`一起部署会相对简单，指定以下命令集以使用生产`value`文件中的值在默认命名空间中发布新的chart：

```
helm upgrade --install release-name \
  --namespace default \
  --values ./production.yml
```

当我运行这一命令时会发生什么呢？

`Helm`有一个称为`Tiller`的服务端，`Helm`打开与`Kubernetes`集群的连接，并将你的`Helm chart与`作为参数传递的值一起写入此连接。服务端组件将这些值发送给模板，并将它们应用到`Kubernetes`集群中。

这些是`Helm`运行部署的基础知识。固定的部分和工作流程包括确定作为参数传递的值以及何时运行`Helm`升级命令。接下来，我们将讨论在企业内执行这些操作的正确方式。


## 避免在每个service都创建一个chart

使用`Helm chart`的一个好处是你可以跨组织或跨项目使用一个通用的配置也能够保持一致，还能将配置合并到一个`chart`中。

虽然将单个`chart`放在要部署的每个`repository`中更简单，但是还是需要花费一些时间来构建一组核心`chart`，这些`chart`可用于整个组织的`service`。

这可以加快诸如标准化健康检查路径之类的速度，并保持跨资源配置的一致。此外，如果你想在`Kubernetes`资源成熟时采用更新的api版本，你可以从中心位置执行此操作。


但是目前`Helm chart`逐渐变得冗长，因此在实际操作中创建十分困难。你需要确保未定义的变量不会出错，同时标签是一致的，并且不会有任何Yaml缩进错误。然后最好将Helm chart交给那些使用Kubernetes方面经验丰富的人进行创建，开发人员可以将其作为模板。


## 分离生产和`staging`配置值

你推送到`chart`中的配置值能在环境之间分离开。构建简单的可扩展的`chart`可以覆盖每个环境。

例如，一个优秀的工作流程为每个环境提供不同的`value`文件，并且文件之间有特定区别：

```
~/myapp
└── config
    ├── production.yml
    └── staging.yml
```

根据部署环境使用每个`value`文件，这与使用`if`语句或其他逻辑将配置`bake`到`Helm chart`相反。

`Helm`可以抽象出`Kubernetes`资源，而`value`文件是传递环境和应用程序特定信息的方式。

**请使用`“require”`语句和`linting`工具以确保在部署时没有未定义的值**。

如果以下变量未定义，可能会导致相对严重的配置问题：

```
host: {{ .Values.hostPrefix }}.example.com
```

## `Secret` 管理

`Kubernetes secret`是管理应用程序`secret`最简单的方式之一。`Helm`不会尝试以任何方式管理`secret`而你可能会陷入配置复杂工作流程的困境。

### 这里有一个`secret`管理的简单的建议：

* 使用你的`CI/CD`在它们的`dashboard`中存储`secret`
* 传递`secret value`到在`deployment`上的`chart value`
* 当这些`secret value`发生变化时，使用校验来`roll out` 这些`pod`

我们想在集群中发布一个新的secret，以便在我们的deployment流水线中可审计和可见，同时我们希望开发人员也可以访问它。

**这里推荐一个十分好用的`secret`管理的工具——`vault`，它深度集成了`Kubernetes`以提供更进一步的安全性**。

它可能需要花费更长的时间设置，但它提供了一些企业可以使用的高级功能。


## 编辑 `value`

确保在使用`Helm CLI`时，只有`Helm`可以更改`Kubernetes`资源清单中的值。

**例如，不要在`Helm`的外部修改`deployment`的副本并且使用`Helm`来更改`value`。**

如果你之前使用过`Kubernetes`，你可能使用过`kubectl apply`这个工具。

这是应用基础设施到集群中最简单的方式之一。但`Helm`不与`kubectl`使用相同的技术。这意味着如果你在`Helm`外部编辑基础设施，下次运行`Helm`命令时可能会导致问题。


## Helm chart repository

**`Helm chart repository`本质上是一个`web`服务器，提供`chart`资源。**

你可以`github.com/helm/charts`上查看官方提供的chart资源。

`chart repository`最初是为了语义版本`chart`而设计的。因此，`chart repository`无法很好地处理并发更新。


`Helm chart` 应该是语义版本的模块，它们代表底层基础架构以部署应用程序。将它们视为一个用于抽象Kubernetes复杂性的库。

将`chart`存储在整个组织可访问的`repository`中，并允许开发人员使用这些`chart`来在企业中进行部署。

在整个组织中分发`chart`的简单方式是使用`S3`甚至`GitHub`版本作为`chart`的存储。还有一个简单的模式是拥有一个共同的`myorg/charts repository`，其中包含您的团队已经策划和构建的所有`chart`，都可以安装到`Kubernetes`中。


## 保护你的Tiller

如果你的`Kubernetes`集群有严格的访问控制，你可能会被`Tiller`（Helm的服务器端组件）作为`Kubernetes`集群中的超级用户运行的问题难住。对于此，有一些解决方法但需要使用一些更复杂的配置。

而对于大多数团队而言，默认的配置是连接到Helm时具有集群的管理员访问权限，因此太过复杂的配置不太适合。

一个常见的修复这一问题的方法是在不同的命名空间中创建一个不同的`Tiller`实例。如果你的`Kubernetes`集群规模很大，这可能是一种将特定团队细分为只能访问单个`Tiller`的方法。











