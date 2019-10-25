# 17 使用Fluentd输出日志 

介绍了向`Mixer Telemetry`的`stdio`输出日志的方法，然而`Mixer`本身已经是个重负载组件，如果日志输出量较大，则会造成大量的`I/O`负载。因此，将输出日志的工作交给`Fluentd`可能是个更好的选择。 

这里做一个简单的`Fluentd`的`Deployment`和`Service`部署，尝试将自定义日志输出到`Fluent`d中。 

## 17.1 部署`Fluentd` 

首先创建`Fluentd`的`Deployment`和`Service`，用于接收日志： 

```
# Fluentd Service
apiVersion: v1
kind: Service
metadata:
  name: fluentd-listener
  labels:
    app: fluentd-listener
spec:
  ports:
  - name: fluentd-tcp
    port: 24224
    protocol: TCP
    targetPort: 24224
  - name: fluentd-udp
    port: 24224
    protocol: UDP
    targetPort: 24224
  selector:
    app: fluentd-listener
---
# Fluentd Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: fluentd-listener
  labels:
    app: fluentd-listener
spec:
  replicas: 1
  selector:
    matchLabels:
      app: fluentd-listener
  template:
    metadata:
      labels:
        app: fluentd-listener
      annotations:
        sidecar.istio.io/inject: "false"
    spec:
      containers:
      - name: fluentd-listener
        image: rocklviv/fluentd
```

```
$ kubectl get pod | grep fluentd
fluentd-listener-76dcb45f49-74pqz   1/1     Running            0          63s
```

```
apiVersion: config.istio.io/v1alpha2
kind: fluentd
metadata:
  name: handler
spec:
  address: "fluentd-listener:24224"
```

```
$ kubectl apply -f fluentd.handler.yaml
fluentd.config.istio.io/handler created
```

将保存为`fluentd.handler.yaml`，并提交到`Kubernetes`集群。 

可以看到这个适配器的配置很简单， 只要指定一 个地址即可，这里使用了我们 

然后直接使用在上一节中定义的`logentry.yaml`

```
$ kubectl apply -f logentry.yaml 
logentry.config.istio.io/sleep-log created
```

最后使用`Rule`对象将`handler`和`sleep-log`两个对象连接起来： 

```
apiVersion: config.istio.io/v1alpha2 
kind: rule 
metadata: 
  name: fluentd
spec: 
  actions:
  - handler: handler.fluentd 
    instances: 
    - sleep-log.logentry
  match: context.protocol == "http" && sourceLabel["app"] == "sleep" 
```

`fluentd-rule.yaml`

```
$ kubectl apply -f fluentd-rule.yaml 
rule.config.istio.io/fluentd created
```

## 17.2 测试输出 

接下来验证日志是否能够成功输出： 

### Source `sleep-v1`:

```
kubectl exec sleep-v1-548d87cc5c-92lqk -it bash -c sleep
bash-4.4# http --body http://httpbin:8000/ip
{
    "origin": "127.0.0.1"
}
```

这里在`sleep Pod`中发出`HTT`P请求，该通信符合`Rule`对象的要求，应该出现在日志中。 

接下来查看`Fluentd Pod`中的输出： 

```
$ kuebctl logs fluentd-listener-76dcb45f49-74pqz 
...
1 2018-12-27 19:54:44.000000000 +0000 sleep-log.logentry.default: {"severity":"info","destinationName":"httpbin-7d67ccc9b-sdp8n","destinatio Namespace":"default","destinationWorkload":"httpbin","destinationApp":"htt bin","destinationIp":[0,0,0,0,0,0,0,0,0,0,255,255,10,244,30,9]} 
```

可以看到, `Fluentd`成功接收到了日志内容，其中的内容也符合我们对`logentry`对象的定义, 所以，使用`Fluentd`代替`Mixer Telementry`进行日志采集是完全可行的

 

