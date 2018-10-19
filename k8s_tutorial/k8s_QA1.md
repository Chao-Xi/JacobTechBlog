![Alt Image Text](images/qa/qa1.jpg "headline image")
# K8S Q&A Chapter one

## 1.污点和容忍

### kubernetes的污点（Taints）与容忍（tolerations) 

如果一个节点标记为`Taints`，除非`POD` 也被标识为可以容忍污点节点，否则该 `Taints` 节点不会被调度 `POD`.
 
比如用户希望把 `Master` 节点保留给 `Kubernetes` 系统组件使用，或者把一组具有特殊资源预留给某些`POD`，则污点就很有用了，`POD` 不会再被调度到`Taints` 标记过的节点。`Taints`标记节点举例如下： 

```
$kubectl taint nodes 192.168.1.40 key=value:NoSchedule 
node" 192.168.1.40" tainted 
```

如果仍然希望某个`POD`调度到`taint`节点上，则必须在`Spec`中做出`Toleration` 定义，才能调度到该节点，举例如下：

``` 
tolerations: 
  - key: "key" 
operator: "Equal" 
value: "value" 
effect: "NoSchedule" 
```
`effect`共有三个可选项，可按实际需求进行设置：
 
* `NoSchedule`: POD不会被调度到标 记为Taints节点。 
* `PreferNoSchedule`: NoSchedule 的软策略版本。 
* `No Execute`：该选项意味着一旦`Taint`生效，如该节点内正在运行的`POD`没有对应`Tolerate`设置，会直接被逐出。

## 2. 镜像时区问题

### 大家经常会遇到容器内的时区都是格林尼治时间，

与北京时间差8小时，这将导致容器内的日志和文件创建时间与实际时区不 符，有两种方式解决这个问题： 

1. 修改镜像中的时区配置文件，这需要自 己重新制作镜像，稍显麻烦 
2. 将宿主机的时区配置文件 `/etc/localtime` 使用`volume`方式挂载到容器中，这种方式最方便，只需要在应用的 `yaml`文件中增加如下配置即可：

``` 
volumeMounts: 
  - name: host-time 
    mountPath: /etc/localtime 
    readOnly: true
  volume: 
  - name: host-time
    hostPath:
      path: /etc/localtime
```

## 3. `kubelet sidecar`镜像问题

很多同学安装 `kubelet` 过后，启动 `pod` 一直被 `hang` 住，最主要的原因是因为墙的问题没有把`pod`的`边车镜像`拉下来，解决方案，执行下面两条`＃docker#`命令： 

```
docker pull cnych/pause-amd64:3.0 
docker tag cnych/pause-amd64:3.0 gcr.io/google_containers/ pause-a md 64:3.0 
```
然后重建pod即可


## 4. `kubernetes` 集群访问外部服务

### `kubernetes` 集群内部访问外部服务可以通过不指定`selectors` 的 `service` 来进行解藕，

如果以后你把外部服务迁移到`k8s` 集群内部的话只需要更改`service`的类型和 `selector`即可，不需要更改调用代码。 
在创建`service`的时候不指定`selectors`，用来将`service`转发到`kubernetes`集群外部的服务（而不是`Pod`)。目前支持两种方法： 

1. 自定义`endpoint`，即创建同名的 `service`和`endpoint`，在`endpoint`中设置 外部服务的IP和端口 
2. 通过`DNS`转发，在`service`定义中指定 `external Name`。此时`DNS`服务会给 `<service>.<namespace>.svc.cluster.local` 创建一个`CNAM`记录，其值为 ·my.database.example.com·。并且，该服务不会自动分配 `ClusterlP`，需要通过 `service`的`DNS`来访问。

``` 
kind: service 
apiVersion: vi 
metadata: 
  name: my-service 
  namespace: default 
spec: 
  type: ExternalName 
  externalName: my.database.example.com
```

 

