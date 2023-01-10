# K8s 原生支持的准入策略管理

在 Kubernetes 1.26 发布的 changelog 中，发现了一个 alpha 版本的验证准入策略的更新，其实就是可以用一种特定的语言来进行准入控制，以前我们介绍过可以通过 OPA、kyverno 等方式来进行策略管理，但是这些方式并非官方默认的方式，而现在官方提供了一种自带的方式，在验证准入策略时可以使用一种通用的表达式语言（CEL）来提供声明的、进程内的替代方法来验证 validating admission webhook

**CEL 最开始被引入到 Kubernetes 中来是用于 CustomResourceDefinitions 的验证规则，此次改进则大大扩展了 CEL 在 Kubernetes 中的使用，可以支持更广泛的准入用例场景**。

## 什么是 CEL

CEL 是一种非图灵的完整表达式语言，被设计为快速、可移植和安全执行，CEL 可以单独使用，也可以嵌入到一个更大的产品中。

CEL 被设计成一种可以安全执行用户代码的语言，虽然在用户的 python 代码上盲目地调用 `eval()` 是危险的，但你可以安全地执行用户的 CEL 代码。因为 CEL 防止了会使其性能降低的行为，它可以在纳秒到微秒的时间内安全地进行评估；它是性能关键型应用的理想选择。CEL 评估表达式，这类似于单行函数或 lambda 表达式。虽然 CEL 通常用于布尔决策，但它也可用于构建更复杂的对象，如 JSON 或 protobuf 消息。

CEL 的类 C 语法看起来与 C++、Go、Java 和 TypeScript 中的等价表达式几乎是相同的。

```
resource.name.startWith("/groups/" + auth.claims.group) // 检测resource.name是否以group开头
```

## 准入策略

我们知道准入控制器的开发和操作是非常繁琐的，除了要开发 Webhook 程序之外，还需要维护 Webhook 二进制文件来处理准入请求，admission webhook 的操作也都很复杂，每个 webhook 都必须部署、监控，并要有一个明确的升级和回滚计划，如果你的 webhook 超时或不可用了，那么 Kubernetes 控制平面可能会变得不可用，影响面非常大。

现在我们可以通过将 CEL 表达式嵌入到 Kubernetes 资源中，而不是调用远程 webhook 程序来实现准入策略，这样就大大降低了 admission webhook 的复杂性。

策略管理通常由三个资源组成：

* `ValidatingAdmissionPolicy `描述了策略的抽象逻辑。
* `ValidatingAdmissionPolicyBinding` 将上述资源链接在一起并提供范围界定。
* 参数资源向 `ValidatingAdmissionPolicy` 提供信息以使其成为具体声明。`ConfigMap` 或 `CRD` 等类型定义了参数资源的 schema，`ValidatingAdmissionPolicy` 对象指定他们期望参数资源的种类。

**至少必须定义一个 `ValidatingAdmissionPolicy` 和一个相应的 `ValidatingAdmissionPolicyBinding` 才能使策略生效**。


如果不需要通过参数配置 `ValidatingAdmissionPolicy`，只不设置 `ValidatingAdmissionPolicy` 中的 `spec.paramKind` 即可。

**一个很简单例子，例如我们要设置 Deployment 可以拥有的副本数量限制，那么可以定义如下所示的验证策略资源对象**

```
apiVersion: admissionregistration.k8s.io/v1alpha1
kind: ValidatingAdmissionPolicy
metadata:
  name: "demo-policy.example.com"  # 策略对象
spec:
  matchConstraints:
    resourceRules:
    - apiGroups:   ["apps"]
      apiVersions: ["v1"]
      operations:  ["CREATE", "UPDATE"]
      resources:   ["deployments"]
  validations:
    - expression: "object.spec.replicas <= 5"
```

该对象中的 expression 字段的值就是用于验证准入请求的 CEL 表达式，我们这里配置的 `object.spec.replicas <= 5`，就表示要验证对象的 `spec.replicas` 属性值是否大于 5，而 `matchConstraints` 属性则声明了该 `ValidatingAdmissionPolicy` 对象可以验证哪些类型的请求，我们这里是针对 Deployment 资源对象。

接下来我们可以将该策略绑定到合适的资源：

```
apiVersion: admissionregistration.k8s.io/v1alpha1
kind: ValidatingAdmissionPolicyBinding
metadata:
  name: "demo-binding-test.example.com"
spec:
  policy: "demo-policy.example.com"
  matchResources:
    namespaceSelector:
    - key: environment,
      operator: In,
      values: ["test"]
```

此 `ValidatingAdmissionPolicyBinding` 资源会将上面声明的 `demo-policy.example.com` 策略绑定到 environment 标签设置为 test 的命名空间，一旦创建该绑定对象后，`kube-apiserver` 将开始执行这个准入策略。

我们可以简单对比下，如果是通过开发 admission webhook 来实现上面的功能，那么我们就需要开发和维护一个程序来执行 `<=` 的检查，虽然是一个非常简单的功能，但是要做非常多的其他工作，而且在实际工作中，绝大多数也是执行一些相对简单的检查，这些我们都可以很容易使用 CEL 来进行表达。

此外验证准入策略是高度可配置的，我们可以根据需要定义策略，可以根据集群管理员的需求对资源进行参数化，例如我们可以修改上面的准入策略以使其具有可配置性：

```
apiVersion: admissionregistration.k8s.io/v1alpha1
kind: ValidatingAdmissionPolicy
metadata:
  name: "demo-policy.example.com"
spec:
  paramKind:
    apiVersion: rules.example.com/v1 # 需要一个 CRD
    kind: ReplicaLimit
  matchConstraints:
    resourceRules:
    - apiGroups:   ["apps"]
      apiVersions: ["v1"]
      operations:  ["CREATE", "UPDATE"]
      resources:   ["deployments"]
  validations:
    - expression: "object.spec.replicas <= params.maxReplicas"
```

在该准入策略对象中，paramKind 属性定义了用于配置策略的资源，在 expression 属性中我们使用了 params 变量来访问参数资源。

然后我们可以定义多个绑定，每个绑定都可以有不同的配置。

```
apiVersion: admissionregistration.k8s.io/v1alpha1
kind: ValidatingAdmissionPolicyBinding
metadata:
  name: "demo-binding-production.example.com"
spec:
  policy: "demo-policy.example.com"
  paramsRef:
    name: "demo-params-production.example.com"
  matchResources:
    namespaceSelector:
    - key: environment,
      operator: In,
      values: ["production"]
---
apiVersion: rules.example.com/v1 
kind: ReplicaLimit
metadata:
  name: "demo-params-production.example.com"
maxReplicas: 1000
```

这里我们通过 `paramsRef` 属性关联了一个 CRD 对象，这样在策略对象中我们就可以通过 `params.maxReplicas `获取到该对象的 `maxReplicas` 属性值了，


这里我们将 environment 标签设置为 production 的命名空间的 Deployments 限制为最多 1000 个副本，当然我们还可以创建另外的绑定对象，为其他命名空间进行不同的限制

```
apiVersion: admissionregistration.k8s.io/v1alpha1
kind: ValidatingAdmissionPolicyBinding
metadata:
  name: "replicalimit-binding-test.example.com"
spec:
  policyName: "replicalimit-policy.example.com"
  paramRef:
    name: "replica-limit-test.example.com"
  matchResources:
    namespaceSelector:
      matchLabels:
        environment: test
---
apiVersion: rules.example.com/v1
kind: ReplicaLimit
metadata:
  name: "replica-limit-test.example.com"
maxReplicas: 3
```

此策略参数资源将部署限制为测试环境中所有名称空间中最多 3 个副本，准入政策可能有多个绑定。

要将所有其他环境绑定到 `maxReplicas` 限制为 100，则可以创建另一个 `ValidatingAdmissionPolicyBinding` 对象：

```
apiVersion: admissionregistration.k8s.io/v1alpha1
kind: ValidatingAdmissionPolicyBinding
metadata:
  name: "replicalimit-binding-nontest"
spec:
  policyName: "replicalimit-policy.example.com"
  paramRef:
    name: "replica-limit-clusterwide.example.com"
  matchResources:
    namespaceSelector:
      matchExpressions:
      - key: environment,
        operator: NotIn,
        values: ["test"]
---
apiVersion: rules.example.com/v1
kind: ReplicaLimit
metadata:
  name: "replica-limit-clusterwide.example.com"
maxReplicas: 100
```

此外在策略对象中我们还可以通过 failurePolicy 来定义如何处理错误配置和 CEL 表达式从准入策略评估为错误，该属性允许的值包括 Ignore、Fail。

* Ignore 表示忽略调用 ValidatingAdmissionPolicy 的错误，允许 API 请求继续。
* Fail 表示调用 ValidatingAdmissionPolicy 出错导致准入失败，API 请求被拒绝。

**需要注意的是 `failurePolicy` 是在 `ValidatingAdmissionPolicy` 对象中定义的，如下所示：**

```
apiVersion: admissionregistration.k8s.io/v1alpha1
kind: ValidatingAdmissionPolicy
spec:
...
failurePolicy: Ignore # 默认值为 "Fail"
validations:
- expression: "object.spec.xyz == params.x"
```

通过前面的示例我们知道在策略对象中是通过 `spec.validations[i].expression` 来表示由 CEL 进行评估的表达式的，通过 CEL 表达式我们可以访问准入请求/响应的内容，可以组织成 CEL 变量以及一些其他变量：

* object - 来自传入请求的对象，对于 DELETE 请求，该值为 null。
* oldObject - 现有对象，对于 CREATE 请求，该值为 null。
* request - 准入请求的属性。
* params - 正在评估的策略绑定引用的参数资源，如果未设置 ParamKind，则值为 null。

`apiVersion`、`kind`、`metadata.name` 和 `metadata.generateName` 这些属性我们始终可以从对象的根进行访问，没有其他元数据属性可访问。

参考资料：[https://kubernetes.io/blog/2022/12/20/validating-admission-policies-alpha/](https://kubernetes.io/blog/2022/12/20/validating-admission-policies-alpha/)

