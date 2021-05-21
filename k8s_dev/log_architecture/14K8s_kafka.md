## 在 Kubernetes 集群上部署 Kafka

最近在测试日志采集的时候，发现日志数据量稍微大一点，`Elasticsearch` 就有点抗不住了，对于 `ES` 的优化可能不是一朝一夕能够完成的，**<span style="color:red">所以打算加一个中间层，将日志输出到 `Kafka`，然后通过 `Logstash` 从 `Kafka` 里面去消费日志存入 `Elasticsearch`**</span>。在测试环境现在并没有一套 `Kafk`a 集群，所以我们来先在测试环境搭建一套 `Kafka` 集群。

本文使用到的相关环境版本如下：

```
$ kubectl version
Client Version: version.Info{Major:"1", Minor:"17", GitVersion:"v1.17.3", GitCommit:"06ad960bfd03b39c8310aaf92d1e7c12ce618213", GitTreeState:"
clean", BuildDate:"2020-02-13T18:08:14Z", GoVersion:"go1.13.8", Compiler:"gc", Platform:"darwin/amd64"}
Server Version: version.Info{Major:"1", Minor:"16+", GitVersion:"v1.16.6-beta.0", GitCommit:"e7f962ba86f4ce7033828210ca3556393c377bcc", GitTre
eState:"clean", BuildDate:"2020-01-15T08:18:29Z", GoVersion:"go1.13.5", Compiler:"gc", Platform:"linux/amd64"}

$ helm version
version.BuildInfo{Version:"v3.1.1", GitCommit:"afe70585407b420d0097d07b21c47dc511525ac8", GitTreeState:"clean", GoVersion:"go1.13.8"}
```

> kafka helm chart 包版本为：kafka-0.20.8.tgz

同样为了简单起见，我们这里使用 `Helm3` 来安装 `Kafka`，首先我们需要添加一个 `incubator` 的仓库地址，因为 `stable` 的仓库里面并没有合适的 `Kafka` 的 `Chart` 包：

```
$ helm repo add incubator http://mirror.azure.cn/kubernetes/charts-incubator/
"incubator" has been added to your repositories

$ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Unable to get an update from the "local" chart repository (http://127.0.0.1:8879/charts):
        Get http://127.0.0.1:8879/charts/index.yaml: dial tcp 127.0.0.1:8879: connect: connection refused
...Successfully got an update from the "argocd-helm" chart repository
...Successfully got an update from the "istio" chart repository
...Successfully got an update from the "loki" chart repository
...Successfully got an update from the "incubator" chart repository
...Successfully got an update from the "stable" chart repository
Update Complete. ⎈ Happy Helming!⎈
```

将 `Kafka` 的 `Helm Chart` 包下载到本地，这有助于我们了解 `Chart` 包的使用方法，当然也可以省去这一步：

```
$ helm fetch incubator/kafka
# wget https://mirror.azure.cn/kubernetes/charts-incubator/kafka-0.20.8.tgz

tar -xvf kafka-0.20.8.tgz
```

然后新建一个名为 `kafka-test.yaml` 的文件，内容如下所示：

```
resources:
  limits:
    cpu: 200m
    memory: 1536Mi
  requests:
    cpu: 100m
    memory: 1024Mi

livenessProbe:
  initialDelaySeconds: 60

# persistence:
#   storageClass: "rook-ceph-block"
```

由于 `kafka` 初次启动的时候比较慢，所以尽量将健康检查的初始化时间设置长一点，我们这里设置成 `livenessProbe.initialDelaySeconds=60`，资源声明可以根据我们集群的实际情况进行声明，最后如果需要持久化 `kafka` 的数据，还需要提供一个 `StorageClass`，我们也知道 `kafka` 对磁盘的 `IO` 要求本身也是非常高的，所以最好是用 `Local PV`，我们这里使用的是 `ceph rbd` 的一个 `StorageClass` 资源对象：（`storageclass.yaml`）

```
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
   name: rook-ceph-block
provisioner: rook-ceph.rbd.csi.ceph.com
parameters:
    # clusterID 是 rook 集群运行的命名空间
    clusterID: rook-ceph
    # 指定存储池
    pool: k8s-test-pool
    # RBD image (实际的存储介质) 格式. 默认为 "2".
    imageFormat: "2"
    # RBD image 特性. CSI RBD 现在只支持 `layering` .
    imageFeatures: layering
    # Ceph 管理员认证信息，这些都是在 clusterID 命名空间下面自动生成的
    csi.storage.k8s.io/provisioner-secret-name: rook-csi-rbd-provisioner
    csi.storage.k8s.io/provisioner-secret-namespace: rook-ceph
    csi.storage.k8s.io/node-stage-secret-name: rook-csi-rbd-node
    csi.storage.k8s.io/node-stage-secret-namespace: rook-ceph
    # 指定 volume 的文件系统格式，如果不指定, csi-provisioner 会默认设置为 `ext4`
    csi.storage.k8s.io/fstype: ext4
reclaimPolicy: Retain
```

具体的存储方案需要根据我们自己的实际情况进行选择，我这里使用的 `Rook` 搭建的 `Cep`h，使用相对简单很多，感兴趣的也可以查看前面的文章 **[使用 `Rook` 快速搭建 `Ceph` 集群](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_dev/rook_ceph/2rook_ceph.md)** 了解相关信息。

定制的 `values`文件准备好过后就可以直接使用 `Helm` 来进行安装了：

```
$ kubectl create ns kafka
namespace/kafka created

$ helm install -f kafka-test.yaml kfk kafka --namespace kafka
NAME: kfk
LAST DEPLOYED: Wed Mar 18 09:08:02 2020
NAMESPACE: kafka
STATUS: deployed
REVISION: 1
NOTES:
### Connecting to Kafka from inside Kubernetes

You can connect to Kafka by running a simple pod in the K8s cluster like this with a configuration like this:

  apiVersion: v1
  kind: Pod
  metadata:
    name: testclient
    namespace: kafka
  spec:
    containers:
    - name: kafka
      image: confluentinc/cp-kafka:5.0.1
      command:
        - sh
        - -c
        - "exec tail -f /dev/null"

Once you have the testclient pod above running, you can list all kafka
topics with:

  kubectl -n kafka exec testclient -- kafka-topics --zookeeper kfk-zookeeper:2181 --list

To create a new topic:

  kubectl -n kafka exec testclient -- kafka-topics --zookeeper kfk-zookeeper:2181 --topic test1 --create --partitions 1 --replication-factor 1

To listen for messages on a topic:

  kubectl -n kafka exec -ti testclient -- kafka-console-consumer --bootstrap-server kfk-kafka:9092 --topic test1 --from-beginning

To stop the listener session above press: Ctrl+C

To start an interactive message producer session:
  kubectl -n kafka exec -ti testclient -- kafka-console-producer --broker-list kfk-kafka-headless:9092 --topic test1

To create a message in the above session, simply type the message and press "enter"
To end the producer session try: Ctrl+C

If you specify "zookeeper.connect" in configurationOverrides, please replace "kfk-zookeeper:2181" with the value of "zookeeper.connect", or you will get error.·
```

安装成功后可以查看下 Release 的状态：

```
$ helm ls -n kafka
NAME    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
kfk     kafka           1               2020-03-18 09:08:02.835422 +0800 CST    deployed        kafka-0.20.8    5.0.1  
```
```
docker pull confluentinc/cp-kafka:5.0.1
```

正常情况下隔一会儿就会部署上`3`个实例的 `kafka` 和 `zookeeper `的集群：

```
$ kubectl get pods -n kafka
NAME              READY   STATUS    RESTARTS   AGE
kfk-kafka-0       1/1     Running   0          107m
kfk-kafka-1       1/1     Running   0          55m
kfk-kafka-2       1/1     Running   0          54m
kfk-zookeeper-0   1/1     Running   0          3h11m
kfk-zookeeper-1   1/1     Running   0          3h5m
kfk-zookeeper-2   1/1     Running   0          3h5m
```

**部署完成后创建一个测试的客户端来测试下 `kafka` 集群是否正常了**：(`testclient.yaml`)

```
apiVersion: v1
kind: Pod
metadata:
  name: testclient
  namespace: kafka
spec:
  containers:
  - name: kafka
    image: confluentinc/cp-kafka:5.0.1
    command:
      - sh
      - -c
      - "exec tail -f /dev/null"
```
 
 同样直接部署上面的资源对象即可：

```
$ kubectl get pods -n kafka | grep test
testclient        1/1     Running   0          72s
```

测试的客户端创建完成后，通过如下命令创建一个新的 topic:

```
kubectl -n kafka exec testclient -- kafka-topics --zookeeper kfk-zookeeper:2181 --topic test1 --create --partitions 1 --replication-factor 1
Created topic "test1".
```
然后开启一个新的命令行终端生成一条消息：

```
kubectl -n kafka exec -ti testclient -- kafka-console-producer --broker-list kfk-kafka-headless:9092 --topic test1
>Hello kafka on k8s
>
```

**这个时候在 `test1` 这个 `topic` 这边的监听器里面可以看到对应的消息记录了**：

```
$ kubectl -n kafka exec -ti testclient -- kafka-console-consumer --bootstrap-server kfk-kafka:9092 --topic test1 --from-beginning
Hello kafka on k8s
Processed a total of 1 messages
command terminated with exit code 130
```

到这里就表明我们部署的 kafka 已经成功运行在了 Kubernetes 集群上面。当然我们这里只是在测试环境上使用，对于在生产环境上是否可以将 `kafka` 部署在` Kubernetes` 集群上需要考虑的情况就非常多了，**对于有状态的应用都更加推荐使用 `Operato`r 去使用，比如[ `Confluent` 的 `Kafka Operator`](https://www.confluent.io/confluent-operator/)**，