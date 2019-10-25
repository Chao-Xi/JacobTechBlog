# 19. Istio的安全加固 

## 19.1设置`RBAC`

`RBAC(Role Based Access Control）`是目前较为通用的一种访问控制方法。`Istio`也提供了这样的方式来支持服务间的授权和鉴权。

 注意，在开始之前，首先要在`values.yaml`中设置： 

```
apiVersion: "authentication.istio.io/v1alpha1"
kind: "MeshPolicy"
metadata:
  name: "default"
  namespace: "default"
spec:
  peers:
  - mtls: {}
```

在部署成功后，就可以在网格中启动我们的`sleep`应用和`httpbin`应用了。在启动完成后， 尝试使用`sleep Pod`访问`httpbin`服务： 

```
$ kubectl apply -f meshpolicy.yaml
meshpolicy.authentication.istio.io/default configured
```

```
$ kubectl exec -it sleep-6c9c898f6c-448v6 -c sleep bash
bash-4.4# http http://httpbin:8000/ip
HTTP/1.1 200 OK
access-control-allow-credentials: true
...
```

**`defa-destinationrule.mtls.yaml `**


```
apiVersion: networking.istio.io/v1alpha3
kind: "DestinationRule"
metadata:
  name: "httpbin"
  namespace: default
spec:
  host: httpbin.default.svc.cluster.local
  trafficPolicy:
    tls:
      mode: ISTIO_MUTUAL
```


不出意外访问可以正常完成 

下面启动一个策略， 启动`RBAC`

```
apiVersion: "rbac.istio.io/v1alpha1" 
kind: RbacConfig 
metadata: 
  name: default 
spec: 
  mode: 'ON_WITH_INCLUSION' 
  inclusion: 
    namespaces: ["default"]
```
```
$ kubectl apply -f rbac.yaml 
rbacconfig.rbac.istio.io/default created
```

将上述内容保存为`rbac.yaml`，并提交到`Kubernetes`集群, 这一规则的意义在于，为所有`default`命名空间中的服务都启动RBAC策略。 

再次启动测试： 


```
$ kubectl exec -it sleep-6c9c898f6c-448v6 -c sleep bash
bash-4.4# http http://httpbin:8000/ip
HTTP/1.1 403 Forbidden
content-length: 19
content-type: text/plain
date: Tue, 05 Nov 2019 06:23:03 GMT
server: envoy
x-envoy-upstream-service-time: 1

RBAC: access denied
```

问题出现了，在`RBAC`启动之后，在默认情况下，所有服务的调用都会被拒绝。接下来需要做的就是制定策略，开放对`httpbin`服务的访问。 

一般来说，`RBAC`系统中的授权过程都是通过以下几步进行设置的：
 
1. 在系统中定义原子粒度的权限； 
2. 将一个或者多个权限组合为角色； 
3. 将角色和用户进行绑定，从而让用户具备绑定的角色所拥有的权限。 

**在`Istio`中使用在提到的`ServiceRole`和`ServiceRoleBinding`这两个对象来完成这一过程。**

首先定义一个可以使用`HTTP GET`访问所有服务的`ServiceRole`: 

```
apiVersion: "rbac.istio.io/v1alpha1" 
kind: ServiceRole 
metadata: 
  name: service-viewer 
spec: 
  rules: 
  - services: ["*"] 
    methods: ["GET"] 
```

```
$ kubectl apply -f servicerole.yaml 
servicerole.rbac.istio.io/service-viewer created
```

将其保存为`servicerole.yaml` 

这里定义了一个名称为`service-viewer`的角色，在`rules`字段中进行授权，允许该角色使用`GET`方法访问所有服务。 

然后定义一个`ServiceRoleBinding`，将上面的角色绑定到所有`default`命名空间的`ServiceAccount`上： 

```
apiVersion: "rbac.istio.io/v1alpha1" 
kind: ServiceRoleBinding 
metadata: 
  name: bind-service-viewer 
spec: 
  subjects: 
  - properties: 
      source.namespace: "default" 
  roleRef: 
    kind: ServiceRole 
    name: "service-viewer" 
```

```
$ kubectl apply -f servicerolebinding.yaml 
servicerolebinding.rbac.istio.io/bind-service-viewer created
```

将其保存为`servicerolebinding.yaml`。 

这里的`subject`用了一个属性限制来指定绑定目标：所有来自`default`命名空间的调用者。

符合这一条件的用户都被绑定到`service-viewer`这个角色上。 


我们将这两个文件提交到`Kubernetes`集群： 

```
$ kubectl exec -it sleep-6c9c898f6c-448v6 -c sleep bash
bash-4.4# http http://httpbin:8000/ip
HTTP/1.1 200 OK
access-control-allow-credentials: true
access-control-allow-origin: *
content-length: 28
content-type: application/json
date: Tue, 05 Nov 2019 07:24:53 GMT
...
```

进一步尝试`post`方式

```
bash-4.4# http -f POST http://httpbin:8000/post name=ja
HTTP/1.1 403 Forbidden
content-length: 19
content-type: text/plain
date: Tue, 05 Nov 2019 07:27:01 GMT
server: envoy
x-envoy-upstream-service-time: 0

RBAC: access denied
```


因为在`ServiceRole`中仅设置了`GET`方法的授权，因此`POST`方法还是无法通过。 

下面将这个角色进行细化。假设我们的两个版本的`sleep`应用使用不同的 `ServiceAccount`运行：	`v1`版本使用`sleep`, `v2`版本使用`sleep-v2`。我们对`sleep`服务的`v1`版本开放`POST`方法。 首先创建新的`Service Account`: 

```
$ kubectl create sa sleep
serviceaccount/sleep created

$ kubectl create sa sleep-v2
serviceaccount/sleep-v2 created
```

接下来更新`sleep.yaml`，在其中增加`ServiceAccount`: 

```
...
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: sleep-v1
  # annotations: 
  #   traffic.sidecar.istio.io/includeOutboundIPRanges: 10.96.0.0/12
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: sleep
        version: v1
    spec:
      ServiceAccountName: sleep
      containers:
      - name: sleep
        image: dustise/sleep
        imagePullPolicy: Always
---
...
      labels:
        app: sleep
        version: v2
    spec:
      ServiceAccountName: sleep-v2
      containers:
      ...
```

删除原有部署，重新启动并注人`sleep`应用，继续后续的测试操作： 

```
$ kubectl exec -it sleep-v2-6b7d67797b-48pk6 -c sleep bash

http -f POST http://httpbin:8000/post name=ja
HTTP/1.1 403 Forbidden
content-length: 19
content-type: text/plain
date: Tue, 05 Nov 2019 08:01:33 GMT
server: envoy
x-envoy-upstream-service-time: 5

RBAC: access denied




http -f  http://httpbin:8000/ip
HTTP/1.1 200 OK
access-control-allow-credentials: true
access-control-allow-origin: *
content-length: 28
content-type: application/json
date: Tue, 05 Nov 2019 08:02:05 GMT
server: envoy
x-envoy-upstream-service-time: 2

{
    "origin": "127.0.0.1"
}
```

可以看到， `sleep`服务的`v2`版本目前和其他服务权限是一致的。
接下来创建一个新的`Service Role`: 

```
apiVersion: "rbac.istio.io/v1alpha1" 
kind: ServiceRole 
metadata: 
  name: service-owner 
spec: 
  rules: 
  - services: ["*"] 
    methods: ["GET","POST"] 
```

* **`servicerole-owner.yaml`**

```
$ kubectl apply -f servicerole-owner.yaml 
servicerole.rbac.istio.io/service-owner created
```

然后创建新的`servicerolebinding.yaml`的绑定关系, ，将`sleep-v2`和`service-owner` 关联起来：

```
apiVersion: "rbac.istio.io/v1alpha1" 
kind: ServiceRoleBinding 
metadata: 
  name: bind-service-owner 
spec: 
  subjects: 
  - user: "cluster.local/ns/default/sa/sleep" 
  roleRef: 
    kind: ServiceRole 
    name: "service-owner" 
``` 

```
$ kubectl apply -f servicerolebinding-owner.yaml 
servicerolebinding.rbac.istio.io/bind-service-owner created
```

```
$ kubectl exec -it sleep-v2-6b7d67797b-48pk6 -c sleep bash 
bash-4.4# http -f POST http://httpbin:8000/post name=ja
HTTP/1.1 403 Forbidden
content-length: 19
content-type: text/plain
...

RBAC: access denied
```


```
$ kubectl exec -it sleep-v1-64fddd5d85-nmgl5  -c sleep bash

bash-4.4# http -f POST http://httpbin:8000/post name=ja
HTTP/1.1 200 OK
access-control-allow-credentials: true
access-control-allow-origin: *
content-length: 793
...
```

如此一来，使用不同`Service Account`运行的服务版本，就分别具备了不同的权限。因为服务和`ServiceAccount`的关系可以由管理员进行指定有非常大的灵活性，所以在授权方面会 

## 19.2 `RBAC`的除错过程 

`RBAC`的设置过程是非常容易出错的，这里可以使用自定义日志的方式，在`Mixer Telemetry`中监控日

这里给出一个简单样例： 

```
apiVersion: "config.istio.io/v1alpha2" 
kind: logentry 
metadata: 
  name: rbaclog 
spec: 
  severity: '"warning"' 
  timestamp: request.time 
  variables: 
    source: source.labels["app"] | source.workload.name | "unknown" 
    user: source.user | "unknown" 
    destination: destination.labels["app"] | destination.workload.name | "unknown" 
    responseCode: response.code | 0 
    responseSize: response.size | 0 
    latency: response.duration |  "Oms" 
  monitored_resource_type: '"UNSPECIFIED"' 
---
apiVersion: "config.istio.io/v1alpha2" 
kind: stdio 
metadata: 
  name: rbachandler 
spec: 
  outputAsJson: true 
---
apiVersion: "config.istio.io/v1alpha2" 
kind: rule 
metadata: 
  name: rabcstdio 
spec: 
  actions: 
  - handler: rbachandler.stdio 
    instances: 
    - rbaclog.logentry 
```

```
$ kubectl apply -f rbaclog.yaml 
logentry.config.istio.io/rbaclog unchanged
stdio.config.istio.io/rbachandler unchanged
rule.config.istio.io/rabcstdio created
```

```
kubectl logs -n  istio-system istio-telemetry-7d7845478d-d2h5f -c mixer | grep rbaclog
...

```

根据日志内容中的`source`、 `destination`等进行过滤，就可以清楚地看到在访问过程中出现的问题了。 

