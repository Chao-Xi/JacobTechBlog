![Alt Image Text](images/qa/qa1.jpg "headline image")

# K8S Q&A Chapter two

## 1. Helm 安装问题

```
[root@masterl~]＃helm version 
Client: &version.Version{SemVer:"v2.1.3", GitCommit:"5cbc48fb305ca4bf 68c26eb8d2a7eb363227e9了3", GitTreeState:'clean'} 
E0319 16:26:12.318686 89356 portforward .go:329] an error occurred forwarding 39066一＞44134: error forwarding port 44134 to pod 79932b6561c3ca1a2c5c1515a7581e3943ee6777c1aa69187f34cd7018a44a16, uid:unable to do port forwarding: socat not found.Error: cannot connect to Tiller
``` 

解决方法：在节点上安装socat包 

```
$ sudo yum install -y socat 
```

## 2. nodeAffinity 问题

### 问题：通过 `annotations` 的形式来声明:

```
nodeAffinity('volume.alpha.kubernetes.io/node-affinity"）
```
的时候出现 `Storage node affinity is disabled by feature-gate` 错误 

### 解决方法：

现在 `kubernetes` 依然支持用 `annotations` 的形式来声明 `nodeAffinity`，只是已经是默认关闭的了，推荐还是使用 `pod.spec.affinity` 的声明方式，或者在`kubelet`上增加两个参数：

```
--feature-gates=PersistentLocalVolumes=true, VolumeScheduling=true
```

然后重启`kubelet`即可。

## 3. 怎样理解 `ingress` 和 `ingress-controller`

### `kubernetes` 问题：`ingress`怎么关联的 `ingress-controller`？ 通过什么关联的啊？怎样解决单点问题？
 
* `ingress` 包含 `ingress-controller` 和 `ingress`两部分，`ingress` 解决的是新的服务加入后，域名和服务的对应问题， 通过`yaml` 进行创建和更新进行加载。 

* `ingress-controller` 是将`ingress`这种变化生成一段 `Nginx` 或者 `traefik` 的配置，然后将这个配置通过`Kubernetes API`写到 `Nginx` 的 `Pod`中，然后 `reload`。他们是通过 `apiserver`进行关联的。 

另外关于 `ingress` 的单点问题，最好的解决方法是用一个 `VIP` 绑定任意一个 `node` 节点，然后域名解析到这个`VIP` 上，如果一个节点挂了，自动漂移到另外的节点上， 所以`ingress-controller` 最好的方式是用 `daemonset`启动，保证每个节点都运行一个 `controller`，因为每个`controller`的 `ingress` 里面包含了所有的`ingress`信息，所以 `VIP`绑定任意一个节点即可。 


## 4. `flannel` 网络问题

### 问题：使用`flannel`的网络，节点间互相可以 `ping`通，但是`pod` 之间不通 

解决方案：节点间互相能 `ping` 通，证明 `docker` 网络之间已经联通，`pod` 之间不通，一般是`iptables` 规则问题，可以使用`iptables -L -n`查看`forward chain`规则是否被改成了`drop`，可以用命令 `iptables -P FORWARD ACCEPT` 临时解决，最好的方法是开启系统的路由转发功能，修改 `／etc/sysctl.conf` 文件，添加`net.i pv4.ip_forward=1`，然后执行命令 `sysctl  -p` 生效，最好重启 `docker` 即可


## 5. 节点资源配置问题

问题：一位k友给 `pause` 镜像打了 `tag`, 

```
docker tag cnych/pause-amd64:3.0 gcr.io/google_containers/pause-amd64:3.0
```

，但是在这个`node` 节点通过`docker images`命令找不到 `pause-amd64:3.0` 了，这就很是奇怪了。

 
解决方法：这个问题主要是因为磁盘空间不足，`500G`硬盘还剩`90G`, `kubelet` 就以为空间不足，调低一点`nod efs.available` 的 `threshold` 值就可以了，而`docker images` 找不到相应的镜像是由于最开始镜像存在的，后来`kubelet` 为了节省空间，自动删除了镜像 


## 6. Helm 命令补全方法

`helm` 有很多子命令和参数，为了提高使用命令行的效率，通常建议安装 `helm` 的 `bash` 命令补全脚本，方法如下：

``` 
$ helm completion bash>.helm rc 
$ echo 'source .helmrc">>.bashrc 
```

重新登录后就可以通过 `Tab` 键补全 `helm` 子命令和参数了。

## 7. `docker` 启动 `jenkins` 问题 

启动 `jenkins`，如果需要在 `Jenkins` 内部使用 `docker`，则需要将宿主机的 `docker`挂载到容器中，需要增加两 个`volume`参数：

``` 
-v /var/run/docker.sock:/var/run/ docker.sock 
-v $(which docker):/usr/bin/docker 
```

之后直接在 `jenkins` 的 `project` 里面就可以使用 `docker` 命令了，比如使用 `maven` 的 `docker` 插件打包镜像。 

如果只挂载上面两个文件的话可能会报 `libltdl.s.7` 库不存在，解决方法也是将该库挂载到容器中去即可：

``` 
-v /usr/lib/x86_64-linux-gnu/libltd Iso.7:/usr/lib/x86_64-linux-gnu/libltdl.so7
``` 

