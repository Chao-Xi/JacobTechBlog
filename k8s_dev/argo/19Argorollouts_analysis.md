# **Argo Rollouts 基于 Analysis 的渐进式发布**

前面我们介绍了使用手动的方式来控制 Argo Rollouts 进行应用交付，此外我们还可以利用 Argo Rollouts 提供的分析(Analysis)来执行自动交付。

Argo Rollouts 提供了几种执行分析(Analysis)的方法来推动渐进式交付，首先需要了解几个 CRD 资源：

* Rollout：Rollout 是 Deployment 资源的直接替代品，**它提供额外的 blueGreen 和 canary 更新策略**，**这些策略可以在更新期间创建 AnalysisRuns 和 Experiments**，可以推进更新，或中止更新。
* AnalysisTemplate：AnalysisTemplate 是一个模板，它定义了如何执行金丝雀分析，例如它应该执行的指标、频率以及被视为成功或失败的值，AnalysisTemplate 可以用输入值进行参数化。
* **ClusterAnalysisTemplate：ClusterAnalysisTemplate 和 AnalysisTemplate 类似，但它是全局范围内的，它可以被整个集群的任何 Rollout 使用**。
* **AnalysisRun：AnalysisRun 是 AnalysisTemplate 的实例化**。**AnalysisRun 就像 Job 一样，它们最终会完成，完成的运行被认为是成功的、失败的或不确定的，运行的结果分别影响 Rollout 的更新是否继续、中止或暂停。**

## 后台分析

金丝雀正在执行其部署步骤时，分析可以在后台运行。

以下示例是每 10 分钟逐渐将 `Canary` 权重增加 20%，直到达到 100%。

在后台，基于名为 `success-rate` 的 `AnalysisTemplate` 启动 `AnalysisRun`，`success-rate` 模板查询 `Prometheus` 服务器，以 5 分钟间隔/样本测量 HTTP 成功率，它没有结束时间，一直持续到停止或失败。

* 如果测量到的指标小于 95%，并且有三个这样的测量值，则分析被视为失败。
* 失败的分析会导致 Rollout 中止，将 Canary  权重设置回零，并且 Rollout 将被视为降级。
* 否则，如果  rollout 完成其所有 Canary 步骤，则认为 rollout 是成功的，并且控制器将停止运行分析。

如下所示的 Rollout 资源对象：

```
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: guestbook
spec:
...
  strategy:
    canary:
      analysis:
        templates:
        - templateName: success-rate
        startingStep: 2 # 延迟开始分析，到第3步开始
        args:
        - name: service-name
          value: guestbook-svc.default.svc.cluster.local
      steps:
      - setWeight: 20
      - pause: {duration: 10m}
      - setWeight: 40
      - pause: {duration: 10m}
      - setWeight: 60
      - pause: {duration: 10m}
      - setWeight: 80
      - pause: {duration: 10m}
```

上面我们引用了一个 `success-rate` 的模板：

```
apiVersion: argoproj.io/v1alpha1
kind: AnalysisTemplate
metadata:
  name: success-rate
spec:
  args:
  - name: service-name
  metrics:
  - name: success-rate
    interval: 5m
    # NOTE: prometheus queries return results in the form of a vector.
    # So it is common to access the index 0 of the returned array to obtain the value
    successCondition: result[0] >= 0.95
    failureLimit: 3
    provider:
      prometheus:
        address: http://prometheus.example.com:9090
        query: |
          sum(irate(
            istio_requests_total{reporter="source",destination_service=~"{{args.service-name}}",response_code!~"5.*"}[5m]
          )) /
          sum(irate(
            istio_requests_total{reporter="source",destination_service=~"{{args.service-name}}"}[5m]
          ))
```

## 内联分析

分析也可以作为内嵌“分析”步骤来执行，当分析以 "内联 "方式进行时，在到达该步骤时启动 AnalysisRun，并在运行完成之前阻止其推进。

分析运行的成功或失败决定了部署是继续进行下一步，还是完全中止部署。

**如下所示的示例中我们将 Canary 权重设置为 20%，暂停 5 分钟，然后运行分析**。如果分析成功，则继续发布，否则中止。

```
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: guestbook
spec:
...
  strategy:
    canary:
      steps:
      - setWeight: 20
      - pause: {duration: 5m}
      - analysis:
          templates:
          - templateName: success-rate
          args:
          - name: service-name
            value: guestbook-svc.default.svc.cluster.local
```


上面的对象中我们将 analysis 作为一个步骤内联到了 Rollout 步骤中，当20%流量暂停5分钟后，开始执行 `success-rate` 这个分析模板。


这里 AnalysisTemplate 与上面的后台分析例子相同，但由于没有指定间隔时间，分析将执行一次测量就完成了。

```
apiVersion: argoproj.io/v1alpha1
kind: AnalysisTemplate
metadata:
  name: success-rate
spec:
  args:
  - name: service-name
  - name: prometheus-port
    value: 9090
  metrics:
  - name: success-rate
    successCondition: result[0] >= 0.95
    provider:
      prometheus:
        address: "http://prometheus.example.com:{{args.prometheus-port}}"
        query: |
          sum(irate(
            istio_requests_total{reporter="source",destination_service=~"{{args.service-name}}",response_code!~"5.*"}[5m]
          )) /
          sum(irate(
            istio_requests_total{reporter="source",destination_service=~"{{args.service-name}}"}[5m]
          ))
```

**此外我们可以通过指定 count 和 interval 字段，可以在一个较长的时间段内进行多次测量。**

```
metrics:
  - name: success-rate
    successCondition: result[0] >= 0.95
    interval: 60s
    count: 5
    provider:
      prometheus:
        address: http://prometheus.example.com:9090
        query: ...
```

## 多个模板的分析

**Rollout 在构建 AnalysisRun 时可以引用多个 AnalysisTemplate。**

这样我们就可以从多个 AnalysisTemplate 中来组成分析，如果引用了多个模板，那么控制器将把这些模板合并在一起，控制器会结合所有模板的指标和 args 字段。如下所示：


```
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: guestbook
spec:
...
  strategy:
    canary:
      analysis:
        templates:
        - templateName: success-rate
        - templateName: error-rate
        args:
        - name: service-name
          value: guestbook-svc.default.svc.cluster.local

---

apiVersion: argoproj.io/v1alpha1
kind: AnalysisTemplate
metadata:
  name: success-rate
spec:
  args:
  - name: service-name
  metrics:
  - name: success-rate
    interval: 5m
    successCondition: result[0] >= 0.95
    failureLimit: 3
    provider:
      prometheus:
        address: http://prometheus.example.com:9090
        query: |
          sum(irate(
            istio_requests_total{reporter="source",destination_service=~"{{args.service-name}}",response_code!~"5.*"}[5m]
          )) /
          sum(irate(
            istio_requests_total{reporter="source",destination_service=~"{{args.service-name}}"}[5m]
          ))
---
apiVersion: argoproj.io/v1alpha1
kind: AnalysisTemplate
metadata:
  name: error-rate
spec:
  args:
  - name: service-name
  metrics:
  - name: error-rate
    interval: 5m
    successCondition: result[0] <= 0.95
    failureLimit: 3
    provider:
      prometheus:
        address: http://prometheus.example.com:9090
        query: |
          sum(irate(
            istio_requests_total{reporter="source",destination_service=~"{{args.service-name}}",response_code=~"5.*"}[5m]
          )) /
          sum(irate(
            istio_requests_total{reporter="source",destination_service=~"{{args.service-name}}"}[5m]
          ))
```

* AnalysisTemplate	
	* templateName: success-rate
	* templateName: error-rate

当执行的分析的时候，控制器会将上面的 `success-rate` 和 `error-rate` 两个模板合并到一个 AnalysisRun 对象中去。

需要注意的是如果出现以下情况，控制器在合并模板时将出错：

* **模板中的多个指标具有相同的名称**
* **两个同名的参数都有值**

## 分析模板参数

`AnalysisTemplates` 可以声明一组参数，这些参数可以由 Rollouts 传递。

然后，这些参数可以像在 metrics 配置中一样使用，并在 `AnalysisRun` 创建时被实例化，参数占位符被定义为 `{{ args.<name> }}`，如下所示：

```
apiVersion: argoproj.io/v1alpha1
kind: AnalysisTemplate
metadata:
  name: args-example
spec:
  args:
  # required
  - name: service-name
  - name: stable-hash
  - name: latest-hash
  # optional
  - name: api-url
    value: http://example/measure
  # from secret
  - name: api-token
    valueFrom:
      secretKeyRef:
        name: token-secret
        key: apiToken
  metrics:
  - name: webmetric
    successCondition: result == 'true'
    provider:
      web:
        # placeholders are resolved when an AnalysisRun is created
        url: "{{ args.api-url }}?service={{ args.service-name }}"
        headers:
          - key: Authorization
            value: "Bearer {{ args.api-token }}"
        jsonPath: "{$.results.ok}"
```

在创建 `AnalysisRun` 时，`Rollout `中定义的参数与 `AnalysisTemplate` 的参数会合并，如下所示：

```
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: guestbook
spec:
...
  strategy:
    canary:
      analysis:
        templates:
        - templateName: args-example
        args:
        # required value
        - name: service-name
          value: guestbook-svc.default.svc.cluster.local
        # override default value
        - name: api-url
          value: http://other-api
        # pod template hash from the stable ReplicaSet
        - name: stable-hash
          valueFrom:
            podTemplateHashValue: Stable
        # pod template hash from the latest ReplicaSet
        - name: latest-hash
          valueFrom:
            podTemplateHashValue: Latest
```

此外分析参数也支持 `valueFrom`，用于读取 `meta` 数据并将其作为参数传递给 `AnalysisTemplate`，如下例子是引用元数据中的 `env` 和 `region` 标签，并将它们传递给 `AnalysisTemplate`。

```
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: guestbook
  labels:
    appType: demo-app
    buildType: nginx-app
    ...
    env: dev
    region: us-west-2
spec:
...
  strategy:
    canary:
      analysis:
        templates:
        - templateName: args-example
        args:
        ...
        - name: env
          valueFrom:
            fieldRef:
              fieldPath: metadata.labels['env']
        # region where this app is deployed
        - name: region
          valueFrom:
            fieldRef:
              fieldPath: metadata.labels['region']
```

## 蓝绿预发布分析

**使用 BlueGreen 策略的 Rollout 可以在使用预发布将流量切换到新版本之前启动一个 AnalysisRun**。

**分析运行的成功或失败决定 Rollout 是否切换流量，或完全中止 Rollout**，如下所示：

```
kind: Rollout
metadata:
  name: guestbook
spec:
...
  strategy:
    blueGreen:
      activeService: active-svc
      previewService: preview-svc
      prePromotionAnalysis:
        templates:
        - templateName: smoke-tests
        args:
        - name: service-name
          value: preview-svc.default.svc.cluster.local
```

上面我们的示例中一旦新的 `ReplicaSet` 完全可用，`Rollout` 会创建一个预发布的 `AnalysisRun`，Rollout 不会将流量切换到新版本，而是会等到分析运行成功完成。


注意：如果指定了 `autoPromotionSeconds` 字段，并且 `Rollout` 已经等待了 `auto promotion seconds` 的时间，`Rollout` 会标记 `AnalysisRun` 成功，并自动将流量切换到新版本。


如果 `AnalysisRun` 在此之前完成，`Rollout `将不会创建另一个 `AnalysisRun`，并等待 `autoPromotionSeconds` 的剩余时间。

## 蓝绿发布后分析

使用 BlueGreen 策略的 Rollout 还可以在流量切换到新版本后使用发布后分析。

如果发布后分析失败或出错，`Rollout `则进入中止状态，并将流量切换回之前的稳定 `Replicaset`，当后分析成功时，`Rollout` 被认为是完全发布状态，新的 `ReplicaSet `将被标记为稳定，然后旧的 `ReplicaSet` 将根据 `scaleDownDelaySeconds`（默认为30秒）进行缩减。

```
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: guestbook
spec:
...
  strategy:
    blueGreen:
      activeService: active-svc
      previewService: preview-svc
      scaleDownDelaySeconds: 600 # 10 minutes
      postPromotionAnalysis:
        templates:
        - templateName: smoke-tests
        args:
        - name: service-name
          value: preview-svc.default.svc.cluster.local
```

## 失败条件

`failureCondition` 可以用来配置分析运行失败，下面的例子是每隔5分钟持续轮询 `Prometheus` 服务器来获得错误总数，如果遇到10个或更多的错误，则认为分析运行失败。

```
  metrics:
  - name: total-errors
    interval: 5m
    failureCondition: result[0] >= 10
    failureLimit: 3
    provider:
      prometheus:
        address: http://prometheus.example.com:9090
        query: |
          sum(irate(
            istio_requests_total{reporter="source",destination_service=~"{{args.service-name}}",response_code~"5.*"}[5m]
          ))
```


## 无结果的运行

分析运行j结果也可以被认为是不确定的，这表明运行既不成功，也不失败。

无结果的运行会导致发布在当前步骤上暂停。

这时需要人工干预，以恢复运行，或中止运行。当一个指标没有定义成功或失败的条件时，分析运行可能成为无结果的一个例子。

```
  metrics:
  - name: my-query
    provider:
      prometheus:
        address: http://prometheus.example.com:9090
        query: ...
```

此外当同时指定了成功和失败的条件，但测量值没有满足任何一个条件时，也可能发生不确定的分析运行。

```
  metrics:
  - name: success-rate
    successCondition: result[0] >= 0.90
    failureCondition: result[0] < 0.50
    provider:
      prometheus:
        address: http://prometheus.example.com:9090
        query: ...
```

不确定的分析运行的一个场景是使 Argo Rollouts 能够自动执行分析运行，并收集测量结果，但仍然允许我们来判断决定测量值是否可以接受，并决定继续或中止。

## 延迟分析运行

**如果分析运行不需要立即开始（即给指标提供者时间来收集金丝雀版本的指标），分析运行可以延迟特定的指标分析。**

每个指标可以被配置为有不同的延迟，除了特定指标的延迟之外，具有后台分析的发布可以延迟创建分析运行，直到达到某个步骤为止

如下所示延迟一个指定的分析指标:

```
  metrics:
  - name: success-rate
    # Do not start this analysis until 5 minutes after the analysis run starts
    initialDelay: 5m
    successCondition: result[0] >= 0.90
    provider:
      prometheus:
        address: http://prometheus.example.com:9090
        query: ...
```

延迟开始后台分析运行，直到步骤3（设定重量40%）。

```
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: guestbook
spec:
  strategy:
    canary:
      analysis:
        templates:
        - templateName: success-rate
        startingStep: 2
      steps:
      - setWeight: 20
      - pause: {duration: 10m}
      - setWeight: 40
      - pause: {duration: 10m}
```

## 引用 Secret


AnalysisTemplate 和 AnalysisRun 可以在 `.spec.args` 中引用 Secret 对象，这允许用户安全地将认证信息传递给指标提供方，如登录凭证或 API 令牌。

需要注意一个 AnalysisRun 只能引用它所运行的同一命名空间的 Secret。
如下所示的例子中，一个 AnalysisTemplate 引用了一个 API 令牌，并把它传递给一个Web 指标提供者。

```
apiVersion: argoproj.io/v1alpha1
kind: AnalysisTemplate
spec:
  args:
  - name: api-token
    valueFrom:
      secretKeyRef:
        name: token-secret
        key: apiToken
  metrics:
  - name: webmetric
    provider:
      web:
        headers:
        - key: Authorization
          value: "Bearer {{ args.api-token }}"
```
