![Alt Image Text](images/qa/qa1.jpg "headline image")

# K8S Q&A Chapter three

## 1. 节点资源驱逐问题

### 节点一直报`DiskPressure` 或者部署`Pod`的时候报`nodefs`资源太低，该怎么办？ 

解答：出现这个问题只会是你的节点磁盘空间或者 `docker` 的数据库目录磁盘空间太低了，用命令查看节点磁盘空间占用情 况，然后逐一排查： 

```
$ df -h 
```

另外仔细检查 `docker` 的数据目录 `／var/lib/docker`（默认）的挂载点是否有足够的空间，如果没有足够的空间可以更改数据 目录到一个更大的数据目录下面：

``` 
/usr/bin/dockerd --graph=/run/ data/docker
```
 
如果想修改 `kubelet` 默认的驱逐策略可以增加如下参数，然后重启`kubelet`服务即可：

``` 
--eviction-hard=imagefs.available<lGi, memory.available< 256Mi, nodefs.available<1Gi 
--eviction-minimum-reclaim=memory.available=100Mi, nodefs.available=500Mi, 
imagefs.avaiLabLe=500Mi 
```


## 2. 集群部署方式的选择

关于本地机器部署`k8s` 的方法选择，通 `juju/maas` 等工具，还是像博客上写的那样手动部署？选择依据是什么，两种方法的利弊？ 

1. 如果有5台机器 
2. 如果有500台机器 

本地机器部署是用于测试还是干嘛的？如 果是用于测试的并且有5台或更多机器的话 我建议是用二进制的方式安装，这样可以 让你深入理解下`kubernetes`集群各个组件是如何结合起来工作的。 

如果是机器较多的话可以先手动搭建一个小规模的集群，然后在这个基础上写自动部署的脚本，当然`kubernetes`官方也有用 `ansible`之类部署的工具

## 3. `kubectl` 出现 `no such host` 的错误


在用 `kubectl` 执行操作的 时候出现类似

```
error dialing backend: dial tcp: lookup nodeOl on x.x.x.x: 53: no such host,，
```
的错误。 
这是因为我们在安装 `kubelet` 节点的时候没有覆盖 `hostname` 的名字，则默认 `kubelet` 会把`node`节点的`hostname` 作为名词注册上，可以通过`kubectl get nodes`查看。 

要解决这个问题，只需要在`apiserver` 所在节点的 `/etc/hosts` 文件中添加上所有 `node`节点的 `IP`即可。 
 
