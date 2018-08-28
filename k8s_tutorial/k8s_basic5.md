# Kubernetes基础

## Kubernetes基本对象

### • Container
### • Pod
### • Node
### • Namespace 
### • Service
### • Label
### • Annotations


## Container

1. Container(容器)是一种便携式、轻量级的操作系统级虚拟化技术。它使用`namespace`隔离不同的软件运行环境，并通过镜像自包含软件的运行环境，从而使得容器可以很方便的在任何地方运行。
2. 由于容器体积小且启动快，因此可以在每个容器镜像中打包一个应用程序。这种一对一的 应用镜像关系拥有很多好处。使用容器，不需要与外部的基础架构环境绑定, 因为每一个应用程序都不需要外部依赖，更不需要与外部的基础架构环境依赖。完美解决了从开发到生 产环境的一致性问题。
3. 容器同样比虚拟机更加透明，这有助于监测和管理。尤其是容器进程的生命周期由基础设 施管理，而不是由容器内的进程对外隐藏时更是如此。最后，每个应用程序用容器封装， 管理容器部署就等同于管理应用程序部署。
4. 在`Kubernetes`必须要使用`Pod`来管理容器，**每个`Pod`可以包含一个或多个容器。**


## Pod

1. Pod是一组紧密关联的容器集合，它们共享`PID`、`IPC`、 `Network`和`UTS namespace`，是Kubernetes调度的基本单位。
2. Pod的设计理念是支持**多个容器在一个Pod中共享网络和文件系统**，可以通过进程间通信和文件共享这种简单高效的方式组合完成服务。
![Alt Image Text](images/basic5/1.jpg "body image")

```
apiVersion: v1 
kind: Pod 
metadata:
 name: nginx 
 labels:
  app: nginx 
spec:
 containers:
 - name: nginx
  image: nginx 
  ports:
  - containerPort: 80
```


## Node

Node是Pod真正运行的主机，可以物理机，也可以是虚拟机。为了管理Pod，每个Node节点上 至少要运行`container runtime`(比如`docker`或者`rkt`)、`kubelet`和`kube-proxy服务`。

![Alt Image Text](images/basic5/2.jpg "body image")

## Namespace

1. `Namespace`是对**一组资源和对象的抽象集合**，比如可以用来**将系统内部的对象划分为不同的项目组或用户组**。
2. 常见的`pods, services, replication controllers`和`deployments`等都是**属于某一个`namespace`的(默认是`default`)**，而`node, persistentVolumes`等则不属于任何`namespace`。

## Service

1. `Service`是应用服务的抽象，通过`labels`为应用提供负载均衡和服务发现。匹配`labels`的`Pod IP`和`端又列表`组成`endpoints`，由`kube-proxy`负责将`服务IP`负载均衡到这些`endpoints`上。

2. 每个`Service`都会自动分配一个`cluster IP`(仅在集群内部可访问的虚拟地址)和`DNS名`，其他容器可以通过该地址或 DNS来访问服务，而不需要了解后端容 器的运行

![Alt Image Text](images/basic5/3.jpg "body image")

```
apiVersion: v1 
kind: Service 
metadata:
 name: nginx
spec:
 ports:
 - port: 8078 # the port that this service should serve on
   name: http
   # the container on each pod to connect to, can be a name 
   # (e.g. 'www') or a number (e.g. 80)
   targetPort: 80
   protocol: TCP
 selector: 
   app: nginx
```

## Label

```
Label是识别Kubernetes对象的标签，以key/value的方式附加到对象上(key最长不能超过63 字节，value可以为空，也可
以是不超过253字节的字符串)。
```

```
Label不提供唯一性，并且实际上经常是很多对象(如Pods)都使用相同的label来标志具体的应用。
```

```
Label定义好后其他对象可以使用LabelSelector来选择一组相同label的对象(比如ReplicaSet和Service用label来选
择一组Pod)。Label Selector支持以下几种方式:
等式，如app=nginx和env!=production
集合，如env in (production, qa)
多个label(它们之间是AND关系)，如app=nginx,env=test
```


## Annotations

**Annotations是key/value形式附加于对象的注解**。**不同于Labels用于标志和选择对象**， **Annotations则是用来记录一些附加信息，用来辅助应用部署、安全策略以及调度策略等**。 比如**deployment**使用**annotations**来记录`rolling update`的状态。

## Try it

### 通过类似`docker run`的命令在k8s运行容器

```
• kubectl run --image=nginx:alpine nginx-app --port=80 
• kubectl get deployment
• kubectl describe deployment/rs/pod
```

**kubectl expose deployment nginx-app --port=80 --target-port=80**

```
• kubectl describe svc
• kubectl describe ep
```


