# Kubernetes对象详解 
## Namespace操作

### `kubectl`可以通过`--namespace`或者`-n`选项指定`namespace`。如果不指定，默认为`default`。查看操作下,也可以通过设置`--all-namespace=true`来查看所有namespace下的资源。


### 查询

```
$ kubectl get namespaces

NAME          STATUS    AGE
default       Active    10d
kube-ops      Active    4d
kube-public   Active    10d
kube-system   Active    10d

```

注意:`namespace`包含两种状态**"Active"**和**"Terminating"**。**在namespace删除过程中，namespace状态被 设置成"Terminating"**。

### 创建

1. 命令行直接创建

```
 $ kubectl create namespace new-namespace
```

2. 通过文件创建

```
$ cat my-namespace.yaml

apiVersion:v1
kind: Namespace
metadata:
  name: new-namespace
```
```
$ kubectl create -f ./my-namespace.yaml
```

### 删除

```
$ kubectl delete namespaces new-namespace
```
1. **删除一个`namespace`会自动删除所有属于该`namespace`的资源。**
2. **`default`和`kube-system`命名空间不可删除。**
3. **`PersistentVolume`是不属于任何namespace的，但`PersistentVolumeClaim`是属于某个特定 `namespace`的**。
4. **`Event`是否属于`namespace`取决于产生`event`的对象。**
5. v1.7版本增加了kube-public命名空间，该命名空间用来存放公共的信息，一般以ConfigMap
的形式存放

```
kubectl get configmap -n=kube-public
```

