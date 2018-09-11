# Kubernetes案例分析 

# 网络

## 基于三层的网络

### 通过物理防火墙隔离不通网络分区(Dev/Prod)

![Alt Image Text](images/ins4/1.jpg "body image")

## Kubernetes部署

* 对于`overlay`网络环境，
* `kubernetes`网络也采用`overlay`
* `Pod`和`pod`之间的访问无限制
*  跨`zone`访问需要通过防火墙

![Alt Image Text](images/ins4/2.jpg "body image")

## 网络分区

* 定义新的`kubernetes`对象`NetworkZone` 
* 一个`NetworkZone`对象可以跨不同地理位置的多个集群

![Alt Image Text](images/ins4/3.jpg "body image")

## 对集群的抽象
 
![Alt Image Text](images/ins4/4.jpg "body image")

## Kubenet 插件

![Alt Image Text](images/ins4/5.jpg "body image")

## kubenet – 网桥模式

![Alt Image Text](images/ins4/6.jpg "body image")

## kubeNet – 路由模式 Network

![Alt Image Text](images/ins4/7.jpg "body image")
 
## 基于`OVS`的`kubernetes`网络

![Alt Image Text](images/ins4/8.jpg "body image")

## 基于`calico`的`kubernetes`网络

![Alt Image Text](images/ins4/9.jpg "body image")


## Kubernetes NetworkPolicy

```
apiVersion:networking/v1
kind:NetworkPolicy
metadata:
  name:test-network-policy
  namespace:default
spec:
  podSelector：
    matchLabels：
      role:db
  ingress:
  - from:
    - namespaceSelector:
        matchLabels
          project:myproject
    - podSelector:
        matchLabels:
          role:frontend
  ports:
  - protocol:tcp
    port:6379    
```

[https://kubernetes.io/docs/concepts/services-networking/networkpolicies/](https://kubernetes.io/docs/concepts/services-networking/networkpolicies/)



