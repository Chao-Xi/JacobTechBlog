![Alt Image Text](images/adv/adv6_0.jpg "Body image")
# Kubernetes Downward API 基本用法

### 如何在容器中获取 `POD` 的基本信息，其实`kubernetes`原生就提供了支持的，那就是`Downward API`。

## 介绍

`Downward API`提供了两种方式用于将 `POD` 的信息注入到容器内部：

* 环境变量：用于单个变量，可以将 `POD` 信息和容器信息直接注入容器内部。
* `Volume`挂载：将 `POD` 信息生成为文件，直接挂载到容器内部中去。

## 环境变量的方式

我们通过`Downward API`来将 `POD` 的 `IP`、`名称`以及所对应的 `namespace` 注入到容器的环境变量中去，然后我们在容器中打印全部的环境变量来进行验证，对应的`yaml`文件如下：(**test-env-pod.yaml**)

```
apiVersion: v1
kind: Pod
metadata:
    name: test-env-pod
    namespace: kube-system
spec:
    containers:
    - name: test-env-pod
      image: busybox:latest
      command: ["/bin/sh", "-c", "env"]
      env:
      - name: POD_NAME
        valueFrom:
          fieldRef:
            fieldPath: metadata.name
      - name: POD_NAMESPACE
        valueFrom:
          fieldRef:
            fieldPath: metadata.namespace
      - name: POD_IP
        valueFrom:
          fieldRef:
            fieldPath: status.podIP
```

我们可以看到上面我们使用了一种新的方式来设置`env`的值：`valueFrom`。另外我们需要注意的是 `POD` 的 `name` 和 `namespace` 属于元数据，是在 `POD` 创建之前就已经定下来了的，所以我们使用 `metata` 获取就可以了，但是对于 `POD` 的 `IP` 则不一样，因为我们知道 `POD IP` 是不固定的，`POD` 重建了就变了，它属于状态数据，所以我们使用 `status` 去获取。

### 除了使用`fieldRef`获取 `POD` 的基本信息外，还可以通过`resourceFieldRef`去获取容器的资源请求和资源限制信息。

### 接下来我们利用`kubectl`工具创建上面的 `POD`

```
$ kubectl create -f test-env-pod.yaml
pod "test-env-pod" created
```

`POD` 创建成功后，我们可以查看日志：

```
$ kubectl logs test-env-pod -n kube-system | grep POD
POD_IP=172.17.0.15
POD_NAME=test-env-pod
POD_NAMESPACE=kube-system
```

我们可以看到 `POD` 的 `IP`、`NAME`、`NAMESPACE` 都通过环境变量打印出来了。


## `Volume`挂载

`Downward API`除了提供环境变量的方式外，还提供了通过`Volume`挂载的方式去获取 `POD` 的基本信息。接下来我们通过`Downward API`将 `POD` 的 `Label`、`Annotation` 等信息通过 `Volume` 挂载到容器的某个文件中去，然后在容器中打印出该文件的值来验证。 新建文件 `yaml` 文件：(**test-volume-pod.yaml**)

```
apiVersion: v1
kind: Pod
metadata:
    name: test-volume-pod
    namespace: kube-system
    labels:
        k8s-app: test-volume
        node-env: test
    annotations:
        build: test
        own: qikqiak
spec:
    containers:
    - name: test-volume-pod-container
      image: busybox:latest
      command: ["sh", "-c"]
      args:
      - while true; do
          if [[ -e /etc/podinfo/labels ]]; then
            echo -en '\n\n'; cat /etc/podinfo/labels; fi;
          if [[ -e /etc/podinfo/annotations ]]; then
            echo -en '\n\n'; cat /etc/podinfo/annotations; fi;
          sleep 3600;
        done;
      volumeMounts:
      - name: podinfo
        mountPath: /etc/podinfo
    volumes:
    - name: podinfo
      downwardAPI:
        items:
        - path: "labels"
          fieldRef:
            fieldPath: metadata.labels
        - path: "annotations"
          fieldRef:
            fieldPath: metadata.annotations
```


我们将元数据 `labels` 和 `annotaions` 以文件的形式挂载到了`/etc/podinfo`目录下，创建上面的 POD ：

```
volumeMounts:
- name: podinfo
  mountPath: /etc/podinfo
```

```
volumes:
    - name: podinfo
      downwardAPI:
        items:
        - path: "labels"
          fieldRef:
            fieldPath: metadata.labels
        - path: "annotations"
          fieldRef:
            fieldPath: metadata.annotations
```


```
$ kubectl create -f test-volume-pod.yaml
pod "test-volume-pod" created
```

```
$ kubectl get pods -o wide -n=kube-system
NAME                 READY     STATUS    RESTARTS   AGE       IP            NODE
test-volume-pod      1/1       Running   0          15s       172.17.0.15   192.168.1.170
```

然后查看日志：

```
$ kubectl logs test-volume-pod -n kube-system


k8s-app="test-volume"
node-env="test"

build="test"
kubernetes.io/config.seen="2018-09-13T07:14:00.518067017Z"
kubernetes.io/config.source="api"
```


我们通过打印出来的日志可以看到 `POD` 的 `Labels` 和 `Annotations` 信息都被挂载到 `/etc/podinfo`目录下面的 `lables` 和 `annotations` 文件了。

在实际应用中，如果你的应用有获取 `POD` 的基本信息的需求，一般我们就可以利用`Downward API`来获取基本信息，然后编写一个启动脚本或者利用`initContainer`将 `POD` 的信息注入到我们容器中去，然后在我们自己的应用中就可以正常的处理相关逻辑了。

