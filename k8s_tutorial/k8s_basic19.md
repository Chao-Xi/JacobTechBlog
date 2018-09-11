# Kubernetes对象详解

## Network Policy

随着微服务的流行，越来越多的云服务平台需要大量模块之间的网络调用。Kubernetes在 1.3 引入了Network Policy，Network Policy提供了基于策略的网络控制，用于隔离应用并减 少攻击面。它使用标签选择器模拟传统的分段网络，并通过策略控制它们之间的流量以及 来自外部的流量。

在使用Network Policy时，需要注意

*  v1.6以及以前的版本需要在kube-apiserver中开启extensions/v1beta1/networkpolicies 
*  v1.7版本Network Policy已经GA，API版本为networking.k8s.io/v1
*  v1.8版本新增 Egress 和 IPBlock 的支持
*  网络插件要支持 Network Policy，如 Calico、Romana、Weave Net和trireme 等


## Namespace隔离

### 比如默认拒绝所有Pod之间Ingress通信

```
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
spec:
  podSelector: {}
  policyTypes:
  - Ingress
```

### 比如默认拒绝所有Pod之间Egress通信

```
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
spec:
  podSelector: {}
  policyTypes:
  - Egress 
```

## Pod隔离

* 通过使用标签选择器(包括`namespaceSelector`和`podSelector` )来控制`Pod`之间的流量。比如下面的`Network Policy`

* 允许`default namespace`中带有`role=frontend`标签的Pod访问 `default namespace`中带有`role=db`标签Pod的`6379端口`

* 允许带有`project=myprojects`标签的namespace中所有Pod访问`default namespace`中带有`role=db`标签Pod的`6379端口`

```
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: test-network-policy
  namespace: default
spec:
  podSelector:
    matchLabels:
      role: db
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          project: myproject
    - podSelector:
        matchLabels
          role: frontend
    ports:
    - protocol: tcp
      port: 6379
```

## 什么是Ingress

通常情况下，`service`和`pod`的IP仅可在集群内部访问。

### 集群外部的请求需要通过负载均衡转发到`service`在`Node`上暴露的`NodePort`上，然后再由`kube-proxy`通过边缘路由器(`edge router`)将其转发给相关的`Pod`或者`丢弃`。
###  而`Ingress`就是为进入集群的请求提供路由规则的集合。
###  `Ingress`可以给`service`提供集群外部访问的`URL`、`负载均衡`、`SSL终止`、`HTTP路由`等。为了配置这些Ingress规则，集群管理员需要部署一个`Ingress controller`，它`监听Ingress`和`service的变化`，并根据规则配置负载均衡并提供访问入口。


## Ingress示例

```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: test-ingress
spec:
  rules:
  - http:
      paths:
      - path: /testpath
        backend:
          serviceName: test
          servicePort: 80
```

## Ingress Controller职责范围

* 负载均衡配置 
 * 四层
 * 七层 
* DNS配置
* 边缘路由器配置


## PodPreset

`PodPreset`用来给指定标签的Pod注入额外的信息，如环境变量、存储卷等。这样，Pod模板就不需要为每个Pod都显式设置重复的信息。

## 增加环境变量和存储卷的PodPreset

```
kind: PodPreset
apiVersion: settings.k8s.io/v1alpha1
metadata:
  name: allow-database
  namespace: myns
spec:
  selector:
    matchLabels:
      role: frontend
  env:
    - name: DB_PORT
      value: "6379"
  volumeMounts:
    - mountPath: /cache
      name: cache-volume
  volumes:
    - name: cache-volume
      emptyDir: {}
```

## 用户提交Pod

```
apiVersion: v1
kind: Pod
metadata:
  name: website
  labels:
    app: website
    role: frontend
spec:  
  containers:
    - name: website
      image: ecorp/website
      ports:
        - containerPort: 80
```

## 结果

```
apiVersion: v1
kind: Pod
metadata:
  name: website
  labels:
    app: website
    role: frontend
  annotations:
    podpreset.admission.kubernetes.io/allow-database: "resource version"
spec:
  containers:
    - name: website
      image: ecorp/website
      volumeMounts:
        - mountPath: /cache
          name: cache-volume
      ports:
        - containerPort: 80
      env:
        - name: DB_PORT
          value: "6379"
  volumes:
    - name: cache-volume
      emptyDir: {}
```


## ThirdPartyResources
 
### `ThirdPartyResources(TPR)`是一种无需改变代码就可以扩展`Kubernetes API`的机制，可以用来管理自定义对象。每个`ThirdPartyResource`都包含以下属性

* metadata:跟`kubernetes metadata`一样
* kind:自定义的资源类型，采用<kind mame>.<domain>的格式
* description:资源描述
* versions:版本列表
* 其他:还可以保护任何其他自定义的属性

## 示例

```
apiVersion: extensions/v1beta1
kind: ThirdPartyResource
metadata:
  name: cron-tab.stable.example.com
description: "A specification of a Pod to run on a cron style schedule"
versions:
- name: v1
```

```
apiVersion: "stable.example.com/v1"
kind: CronTab
metadata:
  name: my-new-cron-object
cronSpec: "* * * * /5"
image: my-awesome-cron-image
```
## RBAC

注意`ThirdPartyResources`不是 `namespace-scoped`的资源，在普通用户使用之前需要绑定`ClusterRole` 权限。

```
$ cat cron-rbac.yaml

apiVersion: rbac.authorization.k8s.io/v1alpha1
kind: ClusterRole
metadata:
  name: cron-cluster-role
rules:
- apiGroups:
  - extensions
  resources:
  - thirdpartyresources
  verbs:
  - '*'
- apiGroups:
  - stable.example.com
  resources:
  - crontabs
  verbs:
  - "*"
```

## 迁移到CustomResourceDefinition

从kubernetes1.7开始ThirdPartyResources被替换为CustomResourceDefinition

* 1.7版本，两种资源同时支持
* 自1.8版本， ThirdPartyResources将被废弃
* 需要将已有资源做数据迁移

