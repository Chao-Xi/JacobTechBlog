# POD内部使用技巧

## 1. 在容器中获取 Pod 的IP

通过环境变量来实现，该环境变量直接引用 `resource` 的状态字段，示例如下：

```
apiVersion: v1
kind: ReplicationController
metadata:
  name: world-v2
spec:
  replicas: 3
  selector:
    app: world-v2
  template:
    metadata:
      labels:
        app: world-v2
    spec:
      containers:
      - name: service
        image: test
        env:
        - name: POD_IP                           
          valueFrom:
            fieldRef:
              fieldPath: status.podIP
        ports:
        - name: service
          containerPort: 777
```

容器中可以直接使用 **`POD_IP`** 环境变量获取容器的 IP。

## 2. 指定容器的启动参数

我们可以在 `Pod` 中为容器使用 `command` 为容器指定启动参数：

```
command: ["/bin/bash","-c","bootstrap.sh"]
```

看似很简单，使用数组的方式定义，所有命令使用跟 `Dockerfile` 中的 `CMD` 配置是一样的，但是有一点不同的是，`bootsttap.sh` 必须具有可执行权限，否则容器启动时会出错。

## 3. 让`Pod`调用宿主机的`docker`能力

我们可以想象一下这样的场景，让 `Pod` 来调用宿主机的 `docker` 能力，**只需要将宿主机的 `docker` 命令和 `docker.sock` 文件挂载到 `Pod` 里面即可**，如下

```
apiVersion: v1
kind: Pod
metadata:
 name: busybox-cloudbomb
spec:
 containers:
 - image: busybox
 command:
 - /bin/sh
 - "-c"
 - "while true; \
 do \
 docker run -d --name BOOM_$(cat /dev/urandom | tr -cd 'a-f0-9' | head -c 6) nginx ; \
 done"
 name: cloudbomb
 volumeMounts:
 - mountPath: /var/run/docker.sock
 name: docker-socket
 - mountPath: /bin/docker
 name: docker-binary
 volumes:
 - name: docker-socket
 hostPath:
 path: /var/run/docker.sock
 - name: docker-binary
 hostPath:
 path: /bin/docker
 
```
 
**参考**：[Architecture Patterns for Microservices in Kubernetes](https://www.infoq.com/presentations/patterns-microservices-kubernetes)
 
 
## 4. 使用`Init container`初始化应用配置

`Init container`可以在应用程序的容器启动前先按顺序执行一批初始化容器，只有所有`Init`容器都启动成功后，`Pod`才算启动成功。看下下面这个例子（来源：[kubernetes: mounting volume from within init container - Stack Overflow](https://stackoverflow.com/questions/44109308/kubernetes-mounting-volume-from-within-init-container)）：

 ```
 apiVersion: v1
kind: Pod
metadata:
  name: init
  labels:
    app: init
  annotations:
    pod.beta.kubernetes.io/init-containers: '[
        {
            "name": "download",
            "image": "axeclbr/git",
            "command": [
                "git",
                "clone",
                "https://github.com/mdn/beginner-html-site-scripted",
                "/var/lib/data"
            ],
            "volumeMounts": [
                {
                    "mountPath": "/var/lib/data",
                    "name": "git"
                }
            ]
        }
    ]'
spec:
  containers:
  - name: run
    image: docker.io/centos/httpd
    ports:
      - containerPort: 80
    volumeMounts:
    - mountPath: /var/www/html
      name: git
  volumes:
  - emptyDir: {}
    name: git
 ```
这个例子就是用来再应用程序启动前首先从GitHub中拉取代码并存储到共享目录下。

## 5. 使容器内时间与宿主机同步

我们下载的很多容器内的时区都是格林尼治时间，与北京时间差8小时，这将导致容器内的日志和文件创建时间与实际时区不符，有两种方式解决这个问题：

* **修改镜像中的时区配置文件**
* **将宿主机的时区配置文件`/etc/localtime`使用volume方式挂载到容器中**

第二种方式比较简单，不需要重做镜像，只要在应用的yaml文件中增加如下配置：

```
volumeMounts:
  - name: host-time
    mountPath: /etc/localtime
    readOnly: true
  volumes:
  - name: host-time
    hostPath:
      path: /etc/localtime
```

## 6. 在Pod中获取宿主机的主机名、namespace等

**这条技巧补充了第一条获取 podIP 的内容，方法都是一样的，只不过列出了更多的引用字段。**

参考下面的 `pod` 定义，每个 `pod` 里都有一个 {`.spec.nodeName`} 字段，通过 `fieldRef` 和`环境变量`，就可以在`Pod`中获取宿主机的主机名（访问环境变量`MY_NODE_NAME`）。

```
apiVersion: v1
kind: Pod
metadata:
  name: dapi-test-pod
spec:
  containers:
    - name: test-container
      image: busybox
      command: [ "/bin/sh", "-c", "env" ]
      env:
        - name: MY_NODE_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        - name: MY_POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: MY_POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: MY_POD_IP
          valueFrom:
            fieldRef:
              fieldPath: status.podIP
        - name: HOST_IP
          valueFrom:
           fieldRef:
             fieldPath: status.hostIP
        - name: MY_POD_SERVICE_ACCOUNT
          valueFrom:
            fieldRef:
              fieldPath: spec.serviceAccountName
  restartPolicy: Never
 
```
 
## 7. 配置Pod使用外部DNS


```
apiVersion: v1
kind: ConfigMap
metadata:
  name: kube-dns
  namespace: kube-system
data:
  stubDomains: |
    {"k8s.com": ["192.168.10.10"]}
  upstreamNameservers: |
    ["8.8.8.8", "8.8.4.4"]
```

## 8. 创建一个CentOS测试容器

有时我们可能需要在`Kubernete`s集群中创建一个容器来测试集群的状态或对其它容器进行操作，这时候我们需要一个操作节点，可以使用一个普通的`CentOS`容器来实现。yaml文件见[manifests/test/centos.yaml](https://github.com/rootsongjc/kubernetes-handbook/blob/master/manifests/test/centos.yaml)。

```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: test
  labels:
    app: test
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: test
    spec:
      containers:
      - image: harbor-001.jimmysong.io/library/centos:7.2.1511
        name: test
        command: ["/bin/bash","-c","while true; do sleep 1000; done"]
        imagePullPolicy: IfNotPresent
```

即使用一个 `while` 循环保证容器启动时拥有一个前台进程。

也可以直接使用`kubectl run`的方式来创建：

```
kubectl run --image=harbor-001.jimmysong.io/library/centos:7.2.1511 --command '/bin/bash -c "while true;do sleep 1000;done"' centos-test
```

### 9. 使用`kubectl`中的强制删除命令

```
kubectl delete pod $POD_ID --force --grace-period=0
```

```
--force
--grace-period=0
```

如果这种方式有效，那么恭喜你！如果仍然无效的话，请尝试下面第二种方法。

### 二、直接删除etcd中的数据

	这是一种最暴力的方式，我们不建议直接操作etcd中的数据，在操作前请确认知道你是在做什么。

假如要删除`default namespace`下的`pod`名为`pod-to-be-deleted-0`，在`etcd`所在的节点上执行下面的命令，删除`etcd`中保存的该`pod`的元数据：

```
ETCDCTL_API=3 etcdctl del /registry/pods/default/pod-to-be-deleted-0
```

这时`API server`就不会再看到该pod的信息。请参考：[使用etcdctl访问kubernetes数据](k8s_skill2_etcdctl.md)

















