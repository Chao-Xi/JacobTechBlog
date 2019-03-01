# Kubernetes service中的故障排查

### 查看某个资源的定义和用法

```
kubectl explain
```

### 查看`Pod`的状态

```
kubectl get pods
kubectl describe pods my-pod
```

### 监控Pod状态的变化

```
kubectl get pod -w
```

可以看到一个 `namespace` 中所有的 `pod` 的 `phase` 变化，[请参考 `Pod` 的生命周期]()。

### 查看 Pod 的日志

```
kubectl logs my-pod
kubectl logs my-pod -c my-container
kubectl logs -f my-pod
kubectl logs -f my-pod -c my-container
```

`-f` 参数可以 follow 日志输出。

### 交互式 debug

**exec**   //  **top**

```
kubectl exec my-pod -it /bin/bash
kubectl top pod POD_NAME --containers
```


## 强制删除一直处于`Terminating`状态的Pod

有时候当我们直接删除`Deployment/DaemonSets/StatefulSet`等最高级别的Kubernetes资源对象时，会发现有些改对象管理的Pod一直处于`Terminating`而没有被删除的情况，这时候我们可以使用如下方式来强制删除它：

### 一、使用`kubectl`中的强制删除命令

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

















