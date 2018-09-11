# Kubernetes对象详解

## Resource Quotas

**资源配额(Resource Quotas)是用来限制用户资源用量的一种机制**

### 它的工作原理为:

1. **资源配额应用在Namespace上，并且每个Namespace最多只能有一个ResourceQuota对象**
2. 开启计算资源配额后，**创建容器时必须配置计算资源请求或限制(也可以用LimitRange设 置默认值) **
3. 用户超额后禁止创建新的资源


## 开启资源配额功能

###  首先，在`API Server`启动时配置`ResourceQuota adminssion control`
###  然后，在`namespace`中创建一个`ResourceQuota`对象

## 资源配额的类型

### 计算资源，包括cpu和memory

1. cpu, limits.cpu, requests.cpu
2. memory,limits.memory,requests.memory

### 存储资源，包括存储资源的总量以及指定storage class的总量

1. requests.storage:存储资源总量，如500Gi
2. persistentvolumeclaims:pvc的个数
3. .storageclass.storage.k8s.io/requests.storage
4. .storageclass.storage.k8s.io/persistentvolumeclaims
5. requests.ephemeral-storage和limits.ephemeral-storage(需要v1.8+)

### 对象数，即可创建的对象的个数

1. pods,replicationcontrollers,configmaps,secrets
2. resourcequotas,persistentvolumeclaims
3. services,services.loadbalancers,services.nodeports

## 示例

```
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-resources
spec:
  hard:
    pods: "4"
    requests.cpu: "1"
    requests.memory: 1Gi
    limits.cpu: "2"
    limits.memory: 2Gi
```

```
apiVersion: v1
kind: ResourceQuota
metadata:
  name: object-counts
spec:
  hard:
    configmaps: "10" 
    persistentvolumeclaims: "4" 
    replicationcontrollers: "20" 
    secrets: "10"
    services: "10" 
    services.loadbalancers: "2"
```

## LimitRange

### 默认情况下，`Kubernetes`中所有容器都没有任何`CPU`和`内存限制`。`LimitRange`用来给 `Namespace`增加一个资源限制，包括`最小`、`最大`和`默认资源`。比如


```
apiVersion: v1
kind: LimitRange
metadata:
  name: mylimits
spec:
  limits:
  - max:
      cpu: "2"
      memory: 1Gi
    min:
      cpu: 200m
      memory: 6Mi
    type: Pod
  - default:
      cpu: 300m
      memory: 200Mi
    defaultRequest:
      cpu: 200m
      memory: 100Mi
    max:
      cpu: "2"
      memory: 1Gi
    min:
      cpu: 100m
      memory: 3Mi
    type: Container
```

## Horizontal Pod Autoscaling

* `Horizontal Pod Autoscaling (HPA)` 可以根据`CPU使用率`或应用自定义`metrics`自动扩展 Pod 数 量(支持 `replication controller`、`deployment` 和 `replica set` )。

控制管理器每隔30s(可以通过`--horizontal-pod-autoscaler-sync-period`修改)查询metrics的资源使用情况

### 支持三种metrics类型

* 预定义metrics(比如Pod的CPU)以利用率的方式计算
* 自定义的Podmetrics，以原始值(rawvalue)的方式计算
* 自定义的objectmetrics

支持两种`metrics`查询方式:`Heapster`和自定义的`REST API`

**支持多metrics**

## 简单用法

```
$ kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10
```

## 完整的HPA示例

### 比如`HorizontalPodAutoscaler`保证每个 `Pod`占用`50% CPU`、`1000pps`以及`10000 请求/s`

```
apiVersion: autoscaling/v2alpha1
kind: HorizontalPodAutoscaler
metadata:
  name: php-apache
  namespace: default
spec:
  scaleTargetRef:
    apiVersion: apps/v1beta1
    kind: Deployment
    name: php-apache
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      targetAverageUtilization: 50
  - type: Pods
    pods:
      metricName: packets-per-second
      targetAverageValue: 1k
  - type: Object
    object:
      metricName: requests-per-second
      target:
        apiVersion: extensions/v1beta1
        kind: Ingress
        name: main-route
      targetValue: 10k
```
 
 
## 状态条件

v1.7+可以在客户端中看到Kubernetes为`HorizontalPodAutoscaler`设置的状态条件`status.conditions`，用 来判断`HorizontalPodAutoscaler`是否可以扩展(`AbleToScale`)、是否开启扩展(`ScalingActive`)以及是否受到限制(`ScalingLimitted`)。 

```
$ kubectl get hpa --show-all
No resources found.
```

```
$ kubectl describe hpa cm-test
```
   
   
   