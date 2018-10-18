![Alt Image Text](images/prod/aligame1.jpg "Headline image")

# kubernetes生产案例之阿里云游戏业务分析

## 目标

我们游戏按照业务逻辑划分，服务器可分为三种类型，**前端服务器（客户端直接进行连接的）**、**后端服务器（只负责处理各种游戏逻辑不提供连接）**、**任务服务器（各种 cron、job 任务）**，

* 其中前端服务器按照功能划分为 `http` 短连接服务器和 `socket` 长连接服务器，
* 后端服务器按照业务划分 例如 `matching` 匹配服务器。

在部署这些服务器的同时，我需要使用 kubernetes 达到的目标有:

* 对于每种类型的服务器，需要同时存在若干个版本
* 对于无状态服务器如 `http`、`cron` 可以比较方便的更新、回滚
* 对于有状态服务器如 `socket`、`matching` 可以业务无间断的进行更新、回滚，用户不会掉线、无感知
* 可以进行灰度发布
* 当服务器的负载变化时，能够自动伸缩服务器数量
* 当服务器异常宕机时，能够自我修复

## 准备 Docker 镜像


* 使用阿里云容器镜像服务准备好 docker 远程仓库
* 在应用（服务器代码）准备好之后，使用 Docker 构建镜像，并打上版本号，Push 到远程仓库（这一步骤可以通过 Jekins 自动完成，后续实践的时候会更新文档，目前就以手工进行）

## 部署应用

1.因为使用的 Docker 远程仓库是私有仓库，部署应用时就需要添加 `imagePullSecrets`,首先使用 `kubectl` 在 `default` 命名空间里创建 `secret`,如需指定命名空间添加 `-n` 参数，后面命令类似

```
$ kubectl create secret docker-registry yourSecretName --docker-server=xxx.cn-hangzhou.aliyuncs.com --docker-username=xxx@aliyun.com --docker-password=xxxxxx --docker=email=xxx@aliyun.com
```

2.根据服务器的特点创建部署 `yaml` 文件

## http 无状态应用

```
apiVersion: extensions/v1beta1           # kubectl api的版本
kind:Deployment                          # kubernetes的资源类型 对于无状态应用 Deployment即可
metadata:
  name: http-prod-1.0.0000               # 部署的名称 不能重复 因为我需要多个版本共存因此使用 名称-环境-版本号的命名方式
spec:
   strategy:
     rollingUpdate:                      # 滚动更新策略
        maxSurge:10%                     # 数值越大，滚动更新时新创建的副本数量越多
        maxUnavailble:10%                # 数值越大 滚动更新时销毁的旧副本数量越多
     replicas: 3                         # 期待运行的Pod副本数量
     template:
       metadata:
         labels:                         # 自定义标签
           serverType: http
           env: production
           version: 1.0.0000
       spec:
         containers:
           - name: httpapp
             image: yourDockerRegistry:1.0.0000
             readinessProbe:             # 一种健康检查决定是否加入到service 对外服务 当接口返回200-400之外的状态码时，k8s会认为这个pod已经不可用，会从Service中移除
               httpGet:
                 scheme: HTTP            # 支持http https
                 path: /
                 port: 81
               initialDelaySeconds: 10   # 容器启动多久后开始检查
               periodSecods: 5           # 几秒检查一次
             env:                        # 镜像启动时的环境变量  
               - name: DEBUG
                 value: 'ccgame:*'
               - name: NODE_ENV
                 valueFrom:
                   fieldRef:
                     fieldPath: metadata.labels['env']   # 从labels中读取env
               - name: HTTP_PORT
                 value: '80'
               - name: SERVER_PORT
                 value: '80'
               - name: HEALTHY_CHECK_PORT 
                 value: '81' 
               - name: SERVER_TYPE
                 valueFrom:
                   fieldRef:
                     fieldPath: metadata.labels['serverType']  # 从labels中读取SERVER_TYPE
               - name: NATS_ADDRESS
                 value: 'nats://xxx:xxx@nats:4222'           # 使用的消息队列集群地址
               - name: VERSION
                 valueFrom:
                   fieldRef:
                     fieldPath: metadata.labels['version']     # 从labels中读取SERVER_TYPE
         imagePullSecrets:   
            - name: regsecret   
```            
                
* `strategy`: [Kubernetes Deployment滚动升级](k8s_adv3_Deployment.md)    
  *  `maxSurge`: 升级过程中最多可以比原先设置多出的POD数量, 例如：`maxSurage=10%，replicas=3`,则表示Kubernetes会先启动1一个新的Pod后才删掉一个旧的POD，整个升级过程中最多会有3+1个POD。
  *  `maxUnavaible`:  升级过程中最多有多少个POD处于无法提供服务的状态,当 `maxSurge`不为0时，该值也不能为0, `maxUnavaible=10%`，则表示Kubernetes整个升级过程中最多会有`1`个POD处于无法服务的状态。 


* `readinessProbe`: [健康检查 ](k8s_adv22_health_inspect.md)       
   *  根据 `periodSeconds` 属性我们可以知道`kubelet`需要每隔 `5` 秒执行一次`Readiness probe`，该探针将向容器中的 `server` 的 `81` 端口发送一个 `HTTP GET`请求。如果 server 的 `/ ` 路径的 `handler` 返回一个成功的返回码，`kubelet`就会认定该容器是否已经就绪可以接收流量过来了, 如果返回失败的返回码，`kubelet` 将杀掉该容器并重启它。`initialDelaySeconds` 指定kubelet在该执行第一次探测之前需要等待 `10` 秒钟。

* `valueFrom`:
   
   ```
   - name: NODE_ENV
     valueFrom:
       fieldRef:
       fieldPath: metadata.labels['env']   # 从labels中读取env
   ```  

### 创建对应的 service


```
apiVersion: v1                    # kubectl api的版本
kind: Service                     # kubernetes的资源类型 这里是Service
metadata:                         
  name: http-prod-v100000         # 服务的名称不能重复不能有. 因为我需要多个版本共存因此使用 名称-环境-版本号并去掉.的方式命名
spec:
  type:ClusterIP                  # service的类型 ClusterIp类型 只有Cluster内部节点和Pod可以访问 NodePort Cluster外部可以通过<NodeIp>:<NodePort>访问 LoadBalancer负载均衡
  selector:                       # 匹配pod的标签与上文Deployment中的labels一致
    serverType: http
    env: production
    version: 1.0.0000
  ports:
    - protocol: TCP              # 只有TCP 或 UDP
      port: 80                   # 服务监听的端口
      targetPort: 80             # Pod 监听的端口 对应上面的Deployment中的HTTP_PORT
```

* `ClusterIP`：通过集群的内部 `IP` 暴露服务，选择该值，服务只能够在集群内部可以访问，这也是默认的`ServiceType`

* [Service 的使用](k8s_adv2_service.md)


### 创建对应的 ingress（路由）对外提供服务

```
apiVersion: extensions/v1beta1             # kubectl api的版本
kind: Ingress                              # kubernetes的资源类型 这里是Ingress
metadata:
  name: https                              # 路由的名称
spec:
  rules:
    - host: xx.xxxx.com                    # 域名
      http:
        paths:
          - backend:
               serviceName:http-prod-v100000     # 转发的服务名
               servicePort: 80                   # 转发到服务的哪个端口 对应上文的service port
            path: /                              # 匹配路径
  tls:                                     # 开启tls          
    - hosts:
        - xx.xxxx.com
      secretName: yourSecretName           # 证书 可通过 kubectl create secret generic yourSecretName --from-file=tls.crt --from-file=tls.key -n kube-system创建
status:
  loadBalancer:
    ingress:
      - ip: x.x.x.x                       # 负载均衡的ip下文会讲
```

* [Ingress TLS 和 PATH 的使用](k8s_adv18_ingress2.md)

此时已经可以通过域名进行访问了，这就是我们想要的“最终状态”，而具体实现细节以及如何维持这个状态不变，我们无需再关心

### 为何不直接使用 Service 对外提供服务？

其实我们只需要把 `Service` 的类型改成 `LoadBlancer`，阿里云（其他云服务商类似）**会给 `Service` 添加一个监听的 `nodePort`，再自动创建一个负载均衡，通过 `tcp` 转发到 `Service` 的 `nodePort` 上**（这地方阿里云有个 bug 每次更新 `Service` 它都会把转发类型改成 `tcp`），可想而知，当我们的 `Service` 越来越多时，`nodePort` 的管理成本也就越来越高, `k8s` 提供了另外一个资源解决这种问题，就是 `Ingress`

### Ingress 工作机制

Ingress 其实就是从 kuberenets 集群外部访问集群的一个入口，将外部的请求根据配置的规则转发到集群内不同的 Service 上，其实就相当于 nginx、haproxy 等负载均衡代理服务器,我们直接使用 Nginx 也可以达到一样的目的，只是 nginx 这种方式当添加、移除 Service 时动态刷新会比较麻烦一点，Ingress 相当于都给你做好了，不需要再次实现一遍，**Ingress 默认使用的 Controller 就是 nginx**。

**`Ingress controller` 可以理解为一个`监听器`，通过不断地与 `kube-apiserver` 打交道，实时的感知后端 `service`、`pod` 的变化，当得到这些变化信息后，`Ingress controller` 再结合 `Ingress` 的配置，更新反向代理负载均衡器，达到服务发现的作用。**

### 配置 Ingress

可以通过 `annotations` 注解的方式告诉 `Ingress` 你的配置，例如：如果你使用的是 `Nginx-Ingress-Controller`，可以通过 `nginx.ingress.kubernetes.io/cors-allow-origin:*`来配置 `cors`，和配置 `Nginx` 几乎是一样的，只是名称不一样而已。

所有的 `Nginx-Ingress-Controller` 的注解可以在这里查询 传送门

可以进入 `nginx-Ingress-controller` 的 `pod` 中，添加一些注解，更新，会看到 `nginx` 重新生成了配置，并“重新启动”，对比注解和 `nginx.conf` 很快就能理解 `Ingress`

### Ingress 灰度发布

可以通过添加注解 `nginx.ingress.kubernetes.io/service-match:'test-svc: header("Version", "1.0.0000")'`，来进行灰度发布，比如匹配 `request headers`中 `Version=1.0.0000`的流量转发到 `test-svc`，可以匹配 `header、query、cookie`,同时还可以配置权重等,例如修复问题时只把 10%的流量切进来，待问题验证得到解决后再设置 `100`。

**我们每次游戏前端发布版本都会在 `header` 中添加一个 `Version` 参数，我设置灰度发布之后就可以把特定前端版本的流量自由的切到某个特定的服务中，比较灵活。**

### 滚动更新

当不需要灰度发布时，仅仅需要对某个 `Service` 的 `pod` 进行更新，只需要更改上文 `Deployment` 中镜像版本即可，当 `k8s` 检测到 `template` 字段更改时，会根据设置的 `rollingUpdate strategy `策略进行滚动更新，对于 `http` 这种无状态的服务，也能达到业务不间断更新


## 长连接 有状态应用

* **无状态:** 该服务运行的实例不会在本地存储需要持久化的数据，**并且多个实例对于同一个请求响应的结果是完全一致的**
* **有状态:** 和上面的概念是对立的了，**该服务运行的实例需要在本地存储持久化数据**,比如 `socket` 长连接

```
apiVersion: apps/v1beta1                          # kubectl api的版本
kind: StatefulSet                                 # kubernetes的资源类型 对于有状态应用选择StatefulSet
metadata:
  name: connector-prod-v100000                    # 部署的名称 不能重复 因为我需要多个版本共存因此使用 名称-环境-版本号的命名方式
spec:
  replicas: 3                                     # 运行的Pod副本数量
  template:
    metadata:
      labels:                                     # 自定义标签
        serverType: connector
        wsType: socket.io
        env: production
        version: 1.0.0000
    spec:
      containers:
         - name: connectorapp
           image: yourDockerRegistry:1.0.0000
           readinessProbe:                        # 一种健康检查决定是否加入到service 对外服务 当接口返回200-400之外的状态码时，k8s会认为这个pod已经不可用，会从Service中移除
               httpGet:
                 scheme: HTTP                    # 支持http https
                 path: /
                 port: 82
               initialDelaySeconds: 10   # 容器启动多久后开始检查
               periodSecods: 5           # 几秒检查一次
           env:                          # 镜像启动时的环境变量  
             - name: DEBUG
               value: 'ccgame:*'
             - name: NODE_ENV
               valueFrom:
                  fieldRef:
                    fieldPath: metadata.labels['env']   # 从labels中读取env
             - name: WS_PORT
               value: '80'
             - name: HEALTHY_CHECK_PORT
               value: '82'
             - name: SERVER_TYPE
               valueFrom:
                 fieldRef:
                   fieldPath: metadata.labels['serverType']  # 从labels中读取SERVER_TYPE
             - name: WS_TYPE
               valueFrom:
                 fieldRef:
                   fieldPath: metadata.labels['wsType']  
             - name: NATS_ADDRESS
               value: 'nats://xxx:xxx@nats:4222'           # 使用的消息队列集群地址
             - name: VERSION
               valueFrom:
                 fieldRef:
                   fieldPath: metadata.labels['version']   # 对于StatefulSet k8s会在metadata.name中自动加上一个序号，从0开始，如connector-prod-v100000-0,connector-prod-v100000-1
            - name: SERVER_ID
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
      imagePullSecrets:   
        - name: regsecret                                
```
`Service` 和 `Ingress` 与无状态 `http` 应用基本一致，参照上文部署即可。全部部署完成后，观察 k8s 后台可以看到，有 name 分别为 `connector-prod-v100000-0`、`connector-prod-v100000-1`、`connector-prod-v100000-2` 的三个 `pod` 正在运行，后面的 `-n` 是由于资源类型设置为 `StatefulSet k8s` 自动加上的以作区分。

### 在容器中获取 pod 信息

一般来说对于 `StatefulSet` 我们可能会在容器内知道这个 `pod` 的 `name`，这时候就可以采用类似于上面的方法，通过 `valueFrom fieldPath:metadata.name`把 `pod name `信息注入到容器的环境变量中，这种特殊的语法是 `Downward API`，帮助我们获取许多 `pod` 的信息

[Kubernetes Downward API 基本用法](k8s_adv6_Downward_API.md)

### 滚动更新

对于 `StatefulSe`t 默认的滚动更新策略是 `OnDelete`, 也就是当这个 `pod` 被删除后，k8s 再次创建时会更新镜像。即使我们改变这个策略，那么可以直接对齐进行更新吗？对于大多数 `StatefulSet` 是不太合适的（比如 pod 上面有用户的长连接 如果直接更新用户会断线 影响体验），或者说对于 `StatefulSet` 的滚动更新一直都是个很复杂的话题，所以如果要更新，推荐使用**灰度发布**。

灰度发布的过程与上文 `http` 一致，对于我们的业务来说，用户的下一次连接会切到指定的版本上


## matching 后端有状态应用

因为后端服务器不需要外界的访问，所以创建一个 `StatefulSet` 启动后端微服务就可以，启动后会监听消息队列进行处理并返回数据

```
apiVersion: apps/v1beta1                          # kubectl api的版本
kind: StatefulSet                                 # kubernetes的资源类型 对于有状态应用选择
metadata:
  name: matching-prod-v100000                     # 部署的名称 不能重复 因为我需要多个版本共存因此使用 名称-环境-版本号的命名方式
spec:
  replicas: 1                                     # 运行的Pod副本数量
  template:
    metadata:
      labels:                                     # 自定义标签
        serverType: matching
        env: production
        version: 1.0.0000 
    spec:
      containers: 
        - name: matchingapp
          image: yourDockerRegistry:1.0.0000
          readinessProbe:             # 一种健康检查决定是否加入到service 对外服务 
            httpGet:
              scheme: HTTP            # 支持http https
              path: /
              port: 80
            initialDelaySeconds: 10   # 容器启动多久后开始检查
            periodSecods: 5           # 几秒检查一次
          env:                        # 镜像启动时的环境变量  
            - name: DEBUG
              value: 'ccgame:*'
            - name: NODE_ENV
              valueFrom:
                fieldRef:
                  fieldPath: metadata.labels['env']   # 从labels中读取env
            - name: SERVER_TYPE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.labels['serverType']  # 从labels中读取SERVER_TYPE
            - name: HEALTHY_CHECK_PORT 
              value: '80' 
            - name: NATS_ADDRESS
              value: 'nats://xxx:xxx@nats:4222'           # 使用的消息队列集群地址
            - name: SERVER_ID
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: VERSION
              valueFrom:
                fieldRef:
                  fieldPath: metadata.labels['version']     # 从labels中读取SERVER_TYPE
      imagePullSecrets:   
        - name: regsecret                   
```

## RPC 设计


可以看到，我把许多 POD 信息注入到了容器中

* 环境变量 `SERVER_ID` 是名称-环境-版本号-序号命名的可以选择某一个服务器；
* 环境变量 `SERVER_TYPE` 可以选择某一类型的服务器；
* 环境变量 `VERSION` 可以选择某一版本的服务器。

因此就可以通过类似于标签选择的方式发送和接受消息队列,例如：

在代码中获取环境变量

```
get SERVER_ID() {
      return process.env.SERVER_ID;   
}
    
get VERSION()
{
     return process.env.VERSION || 'latest';
}
    
get SERVER_TYPE()
{
     return process.env.SERVER_TYPE;
}
```

如果想匹配某一个服务器：

```
 @MessagePattern({ serverId: Config.SERVER_ID, handler: 'some_string'})
 async rpcPush( d: PushDto) {
  // some code ...   
 }
```

如果想匹配某一类型的所有服务器：

```
  @MessagePattern({ serverId: Config.SERVER_TYPE, handler: 'boardcast'})
  async boardcast( d: BroadcastDto){
  // some code ...   
}
```
在其他应用内发送 `rpc`（如在 `http` 应用内调用 `matching` 应用），按照上面的标签格式发送消息即可：

```
this.rpcService
    .doRPC(
        {
            // rpc messagepattern
            serverId: 'matching-v100000-0',
            handler:  'user_join_matching',
        },
        {
            // some data ...
        },
    )
```

### 长连接客户端发送 rpc

和前端同学约定，在 socket 请求中按照 event 字段分为 4 个类型：`Push`、`Notify`、`Request`、`Response`

### Request-Response


客户端主动发起，要求有回应，类似于 http：

```
  export class GatewayMessageDto implements GateWayMessage{
      // 客户端发送的数据
      data: any;
      
      // 路由请求字符串 用来根据业务选择服务器 发起rpc
      @IsString()
      route: string;
      
      // 路由请求时间戳，在REQUEST下会带上
      @IsNumber()
      @IsOptional()
      timestamp: number;
     
     // 服务器版本号
     @IsString()
     @IsOptional()
     version: string;    
}
```

```
 
   @SubscribeMessage(EventType.REQUEST)
   async onRequest(socket: any, message: GatewayMessageDto) {
  
  // 按照业务逻辑最终生成 消息队列的 pattern和 data
  const result = await this.rpcBack(socket, message);
 
 // 返回时间戳和路由字符串 客户端会做 request-response的匹配
  socket.emit(EventType.RESPONSE, {
  route: message.route,
  timestamp: message.timestamp,
  data: result,
  });    
}
```

### Notify-Push

客户端主动发起，不要求回应

```  
 @SubscribeMessage(EventType.NOTIFY)
 async onRequest(socket: any, message: GatewayMessageDto){
 
 // 按照业务逻辑最终生成 消息队列的 pattern和 data
 this.rpcBack(socket , message);   
}
```

在服务器需要回应的地方发送 PUSH 事件

```
  socket.emit(EventType.PUSH, { //some data });
```

对于处理消息会发送到哪个后端服务器，写一个路由函数发起 rpc 即可

## "灰度发布"


同理，有状态后端服务器也不适用滚动更新，因为会丢失业务信息。因为后端服务器外界不可访问，也不能用 Ingress 路由灰度发布的方式来更新，怎么办呢？

其实按照上面的 rpc 设计已经解决了这个问题，例如现在匹配服是 1.0.0000 版本，如果想要发布 1.0.0001 版本，只需要部署一个 matching-v100001 的应用，客户端在配置文件里把 Version 改成 1.0.0001，那么下一次请求就会匹配到 matching-v100001 的应用上，这样可以根据客户端配置随时切换服务器版本号，达到了灰度发布的效果。

### cron 定时任务

```
apiVersion: batch/v1beta1                         # kubectl api的版本
kind: CronJob                                     # kubernetes的资源类型 这里选择CronJob 如果不需要定时选择Job
metadata:
   name: test-cron
spec:
   schedule: '0 0 * * *'                          # 每天晚上执行一次 cron表达式
   jobTemplate:
     spec:
       template:
         metadata:
            labels:
              serverType: cron
              env: production
              version: 1.0.0000
       spec:
          containers:
            - name: cronapp
              image: yourDockerRegistry:1.0.0000
              args:
                - npm
                - run
                - start:testCron
              env:      #
                - name: DEBUG
                  value: 'ccgame:*'
                - name: NODE_ENV
                  valueFrom:
                    fieldRef:
                      fieldPath: metadata.labels['env']
                - name: NATS_ADDRESS
                  value: 'nats://xxx:xxx@nats:4222'
       restartPolicy: OnFailure       
       imagePullSecrets:  
          - name: regsecret 
```

[Job和CronJob 的使用方法](k8s_adv11_job_cronjob.md)

部署之后定时器就开始运行了，非常简单。通过 `spec.successfulJobsHistoryLimit`和 `spec.failedJobsHistoryLimit`，表示历史限制，是可选的字段。它们指定了可以保留多少完成和失败的 Job，默认没有限制，所有成功和失败的 Job 都会被保留。然而，当运行一个 `Cron Job` 时，`Job` 可以很快就堆积很多，所以一般推荐设置这两个字段的值。如果设置限制的值为 `0`，那么相关类型的 Job 完成后将不会被保留。

## 更新

直接更改镜像版本号就可以了，下次运行的时候会以新的镜像版本运行
