# PWC interview (K8S)

## k8s questions

### 1.Four types of k8s services

我们在定义`Service`的时候可以指定一个自己需要的类型的`Service`，如果不指定的**话默认是`ClusterIP`类型**。

我们可以使用的服务类型如下：

* `ClusterIP`：通过集群的**内部 IP 暴露服务**，选择该值，**服务只能够在集群内部可以访问，这也是默认的`ServiceType`**。
* `NodePort`：通过每个 **`Node节点上的IP`** 和 **`静态端口（NodePort）`** 暴露服务。NodePort 服务会路由到 ClusterIP 服务，这个 ClusterIP 服务会自动创建。通过请求 : **可以从集群的外部访问一个 NodePort 服务**。
* `LoadBalancer`：**使用云提供商的负载局衡器，可以向外部暴露服务**。外部的负载均衡器可以路由到 `NodePort` 服务和 `ClusterIP` 服务，这个需要结合具体的云厂商进行操作。
* `ExternalName`：**通过返回 CNAME 和它的值，可以将服务映射到 `externalName` 字段的内容**（例如， `foo.bar.example.com`）。没有任何类型代理被创建，这只有 Kubernetes 1.7 或更高版本的 kube-dns 才支持。


**`service-demo.yaml` => NodePort**

```
apiVersion: v1
kind: Service
metadata:
  name: myservice
spec:
  selector:
    app: myapp
  type: NodePort
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
    name: myapp-http
```

```
$ kubectl get svc
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
myservice    NodePort    10.254.203.104   <none>        80:32077/TCP   7s
```

**loadbalacner**

```
kind: Service 
apiVersion: v1 
metadata:
  name: my-service 
spec:
  selector:
    app: MyApp
  ports:
  - protocol: TCP
    port: 80
    targetPort: 9376
  clusterIP: 10.0.171.239
  loadBalancerIP: 78.11.24.19 #外部LB IP 
  type: LoadBalancer
```


**4.ExternalName**

**`ExternalName` 是 `Service` 的特例，它没有`selector`，也没有定义任何的`端口`和 `Endpoint`。** 对于运行在集群外部的服务，它通过返回该外部服务的别名这种方式来提供服务。

```
kind: Service
apiVersion: v1
metadata:
  name: my-service
  namespace: prod
spec:
  type: ExternalName
  externalName: my.database.example.com
```
当查询主机 `my-service.prod.svc.cluster.local` 时，集群的 `DNS` 服务将返回一个值为 `my.database.example.com` 的 CNAME 记录

### 2.How secrets and config works in k8s

`Secret` 和 `ConfigMap` 之间最大的区别就是 `Secret` 的数据是用`Base64`编码混淆过的，不过以后可能还会有其他的差异，对于比较机密的数据（如API密钥）使用 `Secret` 是一个很好的做法，但是对于一些非私密的数据（比如数据目录）用 `ConfigMap` 来保存就很好。

```
$ kubectl create secret generic token --from-literal=TOKEN=abcd123456000
```
```
$ kubectl create configmap language --from-literal=LANGUAGE=English
```

**`final-read-env.yaml`**

```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: envtest
  labels:
    name: envtest
spec:
  replicas: 1
  template:
    metadata:
      labels:
        name: envtest
    spec:
      containers:
      - name: envtest
        image: test/envtest
        ports:
        - containerPort: 5000
        env:
        - name: TOKEN
          valueFrom:
            secretKeyRef:
              name: token
              key: TOKEN
        - name: LANGUAGE
          valueFrom:
            configMapKeyRef:
              name: language
              key: LANGUAGE

```


**`env` : `valueFrom` : `secretKeyRef/configMapKeyRef` : `name:key:`**

#### Secret

pod一般3种方式使用secret

* 最为 `volume`中的文件挂载到`pod`中一个或多个容器
* 环境变量
* 当`kubelet`为`pod`拉取镜像时使用

**Secret - Opaque类型定义**

**`Opaque`类型数据是一个`map`类型， 要求`value`是`base64`编码格式**

```
apiVersion: v1
kind: Secret
metadata: 
  name: mysecret
type: Opaque
data:
	password: 
	username 
```
**`Secret` 挂载到 `Volume`**

**`secret` 做为环境变量**

```
env:
	ValueFrom:
		secretKeyRef:
			name: token
          key: TOKEN
```

**`dockerconfigjson`类型使用Secret使用**

```
apiVersion: v1 
kind: Pod 
metadata: 
  name: private-reg 
spec: 
  containers:  
  - name: private-reg-container 
    image: <your-private-image> 
  imagePullSecret:
  - name: regcred
```



### 3.Environment value in docker

**In docker env value**

**`Docker` 可以非常轻松的构建带有环境变量的容器，在`Dockerfile`文件中，我们可以通过`ENV`指令来设置容器的环境变量。**

```
FROM python:3.6.4

# 设置工作目录
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
# 安装依赖
RUN pip install flask
# 添加应用
ADD . /usr/src/app

# 设置环境变量
ENV TOKEN abcdefg0000
ENV LANGUAGE English

# 暴露端口
EXPOSE 5000
# 运行服务
CMD python read-env-app.py
```
**FROM**, **WORKDIR**, **RUN**, **ADD**, **ENV**, **EXPOSE**, **CMD**

```
$ docker build -t test/envtest .
```
```
$ docker run --name envtest --rm -p 5000:5000 -it test/envtest
* Running on http://0.0.0.0:5000/ (Press CTRL+C to quit)
```


### 4.How network works in K8S

* [k8s 的 service 和 ep(endpoints) 是如何关联和相互影响的。](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_adv33_interview.md#5k8s-%E7%9A%84-service-%E5%92%8C-ependpoints-%E6%98%AF%E5%A6%82%E4%BD%95%E5%85%B3%E8%81%94%E5%92%8C%E7%9B%B8%E4%BA%92%E5%BD%B1%E5%93%8D%E7%9A%84)
* [详述 `kube-proxy` 原理，一个请求是如何经过层层转发落到某个 `pod` 上的整个过程。请求可能来自 `pod` 也可能来自外部。](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_adv33_interview.md#5k8s-%E7%9A%84-service-%E5%92%8C-ependpoints-%E6%98%AF%E5%A6%82%E4%BD%95%E5%85%B3%E8%81%94%E5%92%8C%E7%9B%B8%E4%BA%92%E5%BD%B1%E5%93%8D%E7%9A%84)



### 5.How cloud EBS works in K8S

**For example: EKS**

1.Creating storage classes for EKS: **`gp-storage.yaml`**

```
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: gp2
  annotations:
    storageclass.kubernetes.io/is-default-class: 'true'. # set as default StorageClass
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
reclaimPolicy: Retain
mountOptions:
  - debug
```

* **provisioner: kubernetes.io/aws-ebs**
* **parameters: type: gp2**
* **parameters: type: io1, iopsPerGB: "100"**

```
$ kubectl apply -f gp-storage.yaml -f fast-storage.yaml
storageclass.storage.k8s.io/gp2 created
storageclass.storage.k8s.io/fast-100 created
```


```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: hostname-pvc
spec:
  storageClassName: gp2
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

**`storageClassName: gp2`**

```
$ kubecti get pv 
NAME                                      CAPACITY   ACCESS MODES   RECLAIM POLICY  STATUS CLAIM                STORAGECLASS  REASON   AGE
pvc-5631eea5—c823-11e8—a59d-0269164cebd2  1Gi        RWO            Retain          Bound  default/hostname—pvc gp2                     5s   
```

### 5.How cloud database works in K8S

#### 1).External Services with IP addresses

You can use static Kubernetes services to solve this problem. So in this example, **I created a MongoDB server.** 

##### Create Kubernetes Services

```
kind: Service 
apiVersion: v1
metadata: 
  name: mongo 
Spec: 
  type: ClusterIP 
  ports: 
  - port: 27017 
    targetPort: 27017 
```

This allows you to manually create the endpoints that'll receive traffic from the service

##### Create Kubernetes Endpoints

```
kind: Endpoints 
apiVersion: v1 
metadata: 
  name: mongo 
subsets: 
  - addresses: 
      - ip: 10.240.0.4   => mongo db private ip
    ports: 
      - port: 27017 
```

#### 2).External Services with Domain Names

```
kind: Service 
apiVersion: v1 
metadata: 
  name: mongo 
spec: 
  type: ExternalName 
  externalName: ds149763.mlab.com 
```


### 6.强制删除一直处于Terminating状态的Pod

```
kubectl delete pod $POD_ID --force --grace-period=0
```

### 7.Pod 自动扩缩容 HPA

#### Option1

```
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: hpa-nginx-deploy
  labels:
    app: nginx-demo
spec:
  revisionHistoryLimit: 15
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
```

```
$ kubectl autoscale deployment hpa-nginx-deploy --cpu-percent=10 --min=1 --max=10
deployment "hpa-nginx-deploy" autoscaled

$ kubectl get hpa
NAME               REFERENCE                     TARGETS           MINPODS   MAXPODS   REPLICAS   AGE
hpa-nginx-deploy   Deployment/hpa-nginx-deploy   <unknown> / 10%   1         10        0          22s
```

**autoscale deployment**

此命令创建了一个关联资源 `hpa-nginx-deploy` 的`HPA`，最小的 `pod` 副本数为1，最大为10。HPA会根据设定的 cpu使用率（10%）动态的增加或者减少pod数量。

**HorizontalPodAutoscaler**

```
$ kubectl get hpa hpa-nginx-deploy -o yaml
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  creationTimestamp: 2017-06-29T08:04:08Z
  name: nginxtest
  namespace: default
  resourceVersion: "951016361"
  selfLink: /apis/autoscaling/v1/namespaces/default/horizontalpodautoscalers/nginxtest
  uid: 86febb63-5ca1-11e7-aaef-5254004e79a3
spec:
  maxReplicas: 5 //资源最大副本数
  minReplicas: 1 //资源最小副本数
  scaleTargetRef:
    apiVersion: extensions/v1beta1
    kind: Deployment //需要伸缩的资源类型
    name: nginxtest  //需要伸缩的资源名称
  targetCPUUtilizationPercentage: 50 //触发伸缩的cpu使用率
status:
  currentCPUUtilizationPercentage: 48 //当前资源下pod的cpu使用率
  currentReplicas: 1 //当前的副本数
  desiredReplicas: 2 //期望的副本数
  lastScaleTime: 2017-07-03T06:32:19Z
 
```
 
 

