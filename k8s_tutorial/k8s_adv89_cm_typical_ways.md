# ConfigMap三种使用方法

### ConfigMap概述

`ConfigMap`供容器使用的典型用法如下：

* 生成为容器内的环境变量；
* **设置容器启动命令的启动参数（需设置为环境变量）；**
* 以`Volume`的形式挂载为容器内部的文件或目录。

### 通过yaml配置文件方式创建

下面的例子`cm-appvars.yaml`描述了将几个应用所需的变量定义为ConfigMap的用法：

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: cm-appvars
data:
  apploglevel: info
  appdatadir: /var/data
```

```
data:
  apploglevel: info
  appdatadir: /var/data
```

### 通过`kubectl`命令行方式创建

不使用yaml文件，直接通过`kubectl create configmap`也可以创建ConfigMap，可以使用参数`--from-file`或`--from-literal`指定内容，并且可以在一行命令中指定多个参数。

* （1）通过`--from-file`参数从**文件中进行创建**，可以指定`key`的名称，也可以在一个命令行中创建包含多个`key`的`ConfigMap`，语法为：

```
kubectl create configmap NAME --from-file=[key=]source --from-file=[key=]source
```

* （2）通过`--from-file`参数从目录中进行创建，**该目录下的每个配置文件名称都被设置为`key`，文件的内容被设置为`value`**，语法为：

```
kubectl create configmap NAME  --from-file=config-files-dir
```

* 配置文件名称: `key`
* 文件的内容: `value`

* (3) `--from-literal`从文本中进行创建，直接将指定的`key-value`对创建为`ConfigMap`的内容，语法为：

```
kubectl create configmap NAME --from-literal=key1=value1 --from-literal=key2=value2
```

## 使用ConfigMap

容器应用对ConfigMap的使用有以下两种方法：

* 通过环境变量获取ConfigMap
* 通过`Volume`挂载的方式将`ConfigMap`中的内容挂载为容器内部的文件或目录

### 在Pod中使用ConfigMap

* （1）通过环境变量方式使用ConfigMap

以前面创建的`ConfigMap “cm-appvars”` 为例：

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: cm-appvars
data:
  apploglevel: info
  appdatadir: /var/data
```

在Pod `cm-test-pod` 的定义中，将ConfigMap `cm-appvars` 中的内容以环境变量（`APPLOGLEVEL`和`APPDATADIR`）设置为容器内部的环境变量，容器的启动命令将显示这两个环境变量的值（`"env | grep APP"`）：

```

apiVersion: v1
kind: Pod
metadata:
  name: cm-test-pod
spec:
  containers:
  - name: cm-test
    image: busybox
    command: ["/bin/sh", "-c", "env | grep APP"]
    env:
    - name: APPLOGLEVEL
       valueFrom:
       	configMapKeyRef:
       		name: cm-appvars
       		key: apploglevel
    - name: APPDATADIR
       valueFrom: 
       	configMapKeyRef:
       		name: cm-appvars
       		key: appdatadir
    restartPolicy: Never
```

使用`kubectl create -f`命令创建该Pod，由于是测试Pod，所以该Pod在执行完启动命令后将会退出，并且不会被系统自动重启（`restartPolicy: Never`）：

使用`kubectl get pods --show-all` 查看已经停止的Pod
查看该`Pod`的日志，可以看到启动命令`“env | grep APP”`的执行结果如下：

```
$ kubectl logs cm-test-pod
APPDATADIR=/var/data
APPLOGLEVEL=info
```

从Kubernetes v1.6开始，**引入了一个新的字段 `envFrom` ，实现在`Pod`环境内将`ConfigMap`（也可用于Secret资源对象）中所定义的`key=value`自动生成为环境变量**：

```
apiVersion: v1
kind: Pod
metadata:
  name: cm-test-pod
spec:
  containers:
    - name: test-container
      image: busybox
      command: [ "/bin/sh", "-c", "env" ]
      envFrom:
      - configMapRef:
          name: cm-appvars
  restartPolicy: Never
```

```
envFrom:
- configMapRef:
	name: key
```

通过这个定义，在容器内部将生成如下环境变量：

```
$ kubectl logs cm-test-pod

apploglevel=info
appdatadir=/var/data
```

需要说明的是，环境变量的名称受POSIX命名规范`（[a-zA-Z_][a-zA-Z0-9_]*）`约束，不能以数字开头。
如果包含非法字符，则系统将跳过该条环境变量的创建，并记录一个Event来描述环境变量无法生成，但不会阻止Pod的启动。

### 在 Pod 命令里使用 ConfigMap 定义的环境变量

我们可以利用`$(VAR\_NAME)`这个 `Kubernetes` 替换变量，在 Pod 的配置文件的 `command` 段使用 `ConfigMap` 定义的环境变量。

例子如下:

下面的 Pod 配置

```
apiVersion: v1
kind: Pod
metadata:
  name: cm-test-pod
spec:
  containers:
    - name: test-container
      image: busybox
      command: [ "/bin/sh", "-c", "echo $(APPLOGLEVEL) $(APPDATADIR)" ]
      env:
        - name: APPLOGLEVEL
          valueFrom:
            configMapKeyRef:
              name: cm-appvars
              key: apploglevel
        - name: APPDATADIR
          valueFrom:
            configMapKeyRef:
              name: cm-appvars
              key: appdatadir
  restartPolicy: Never
```

### 通过`volumeMount`使用`ConfigMap`

当您使用 `--from-file` 创建 `ConfigMap` 时， **文件名将作为键名保存在 `ConfigMap` 的 `data` 段，文件的内容变成键值**。

**从 `ConfigMap` 里的数据生成一个卷**

下面的例子展示了一个名为 `special-config` 的 `ConfigMap` 的配置：

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: special-config
  namespace: default
data:
  special.level: very
  special.type: charm
```

在 Pod 的配置文件里的 `volumes` 段添加 `ConfigMap` 的名字。

这会将 `ConfigMap` 数据添加到 `volumeMounts.mountPath` 指定的目录里面（在这个例子里是 `/etc/config`）。`command `段引用了 `ConfigMap` 里的 `special.level`.

```
apiVersion: v1
kind: Pod
metadata:
  name: dapi-test-pod
spec:
  containers:
    - name: test-container
      image: gcr.io/google_containers/busybox
      command: [ "/bin/sh", "-c", "ls /etc/config/" ]
      volumeMounts:
      - name: config-volume
        mountPath: /etc/config
  volumes:
    - name: config-volume
      configMap:
        # Provide the name of the ConfigMap containing the files you want
        # to add to the container
        name: special-config
  restartPolicy: Never
```

```
volumes:
  - name: config-volume
     configMap:
       name: special-config
```

Pod 运行起来后, 执行这个命令 `("ls /etc/config/")` 将产生如下的输出：

```
special.level
special.type
```

**添加 `ConfigMap` 数据到卷里指定路径**

使用 `path` 变量定义 `ConfigMap` 数据的文件路径。在我们这个例子里，`special.level` 将会被挂载在 `config-volume` 的文件 `/etc/config/keys` 下.

```
apiVersion: v1
kind: Pod
metadata:
  name: dapi-test-pod
spec:
  containers:
    - name: test-container
      image: gcr.io/google_containers/busybox
      command: [ "/bin/sh","-c","cat /etc/config/keys" ]
      volumeMounts:
      - name: config-volume
        mountPath: /etc/config
  volumes:
    - name: config-volume
      configMap:
        name: special-config
        items:
        - key: special.level
          path: keys
  restartPolicy: Never
```

`Pod` 运行起来后，执行命令`("cat /etc/config/keys")`将产生下面的结果：

```
very
```

## 使用ConfigMap的限制条件

使用`ConfigMap`的限制条件如下：

* `ConfigMap`必须在`Pod`之前创建（除非您把 `ConfigMap` 标志成`”optional”`）。如果您引用了一个不存在的 `ConfigMap`， 那这个`Pod`是无法启动的。就像引用了不存在的` Key` 会导致 `Pod` 无法启动一样。
* **`ConfigMap`受`Namespace`限制**，只有处于相同的`Namespace`中的`Pod`可以引用它；
* ConfigMap中的配额管理还未能实现；
* kubelet值支持可以被`API Server`管理的`Pod`使用`ConfigMap`。`kubelet`在当前`Node`上通过 `--manifest-url`或 `--config` 自动创建的静态Pod将无法引用`ConfigMap`；
* 在`Pod`对`ConfigMap`进行挂载（`volumeMount`）操作是，容器内部只能挂载为目录，无法挂载为文件。
* 在挂载到容器内部后，目录中将包含`ConfigMap`定义的每个`item`，如果该目录下原理还有其他文件，则容器内的该目录会被挂载的`ConfigMap`覆盖。




