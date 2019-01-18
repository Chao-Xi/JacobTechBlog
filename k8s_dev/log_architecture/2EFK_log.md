# 在 K8S 上搭建 EFK 日志收集系统

Nowadays, Kubernetes 中比较流行的日志收集解决方案是 **`Elasticsearch`、`Fluentd` 和 `Kibana`（EFK）** 技术栈，也是官方现在比较推荐的一种方案。

`Elasticsearch` 是一个实时的、分布式的可扩展的搜索引擎，允许进行全文、结构化搜索，它通常用于索引和搜索大量日志数据，也可用于搜索许多不同类型的文档。

`Elasticsearch` 通常与 `Kibana` 一起部署，`Kibana` 是 `Elasticsearch` 的一个功能强大的数据可视化 `Dashboard`，`Kibana` 允许你通过 `web` 界面来浏览 `Elasticsearch` 日志数据。

**`Fluentd`是一个流行的开源数据收集器，我们将在 `Kubernetes` 集群节点上安装 `Fluentd`，通过获取容器日志文件、过滤和转换日志数据，然后将数据传递到 `Elasticsearch` 集群，在该集群中对其进行索引和存储。**

## 创建 Elasticsearch 集群

在创建 `Elasticsearch` 集群之前，我们先创建一个命名空间，我们将在其中安装所有日志相关的资源对象。

新建一个 `kube-logging.yaml` 文件：

```
apiVersion: v1
kind: Namespace
metadata:
  name: logging
```


然后通过 `kubectl` 创建该资源清单，创建一个名为 `logging` 的 `namespace`：

```
$ kubectl create -f kube-logging.yaml
namespace/logging created
$ kubectl get ns
NAME           STATUS    AGE
default        Active    244d
istio-system   Active    100d
kube-ops       Active    179d
kube-public    Active    244d
kube-system    Active    244d
logging        Active    4h
monitoring     Active    35d
```

现在创建了一个命名空间来存放我们的日志相关资源，接下来可以部署 `EFK` 相关组件，首先开始部署一个3节点的 `Elasticsearch` 集群。

这里我们使用3个 `Elasticsearch Pod` 来避免高可用下多节点集群中出现的“脑裂”问题，当一个或多个节点无法与其他节点通信时会产生“脑裂”，可能会出现几个主节点。

[Elasticsearch 集群脑裂问题](https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-node.html#split-brain)

### 一个关键点是您应该设在参数上

```
discover.zen.minimum_master_nodes=N/2+1
```

其中 `N` 是 `Elasticsearch` 集群中符合主节点的节点数，比如我们这里`3`个节点，意味着`N`应该设置为`2`。
这样，**如果一个节点暂时与集群断开连接，则另外两个节点可以选择一个新的主节点，并且集群可以在最后一个节点尝试重新加入时继续运行，在扩展 `Elasticsearch` 集群时，一定要记住这个参数。**

首先创建一个名为 `elasticsearch` 的无头服务，新建文件 `elasticsearch-svc.yaml`，文件内容如下：

```
kind: Service
apiVersion: v1
metadata:
  name: elasticsearch
  namespace: kube-logging
  labels:
    app: elasticsearch
spec:
  selector:
    app: elasticsearch
  clusterIP: None
  ports:
    - port: 9200
      name: rest
    - port: 9300
      name: inter-node
```

* 定义了一个名为 `elasticsearch` 的 `Service`，指定标签`app=elasticsearch`
* 我们将 **`Elasticsearch StatefulSet`** 与此服务关联时，服务将返回带有标签 `app=elasticsearch`的 `Elasticsearch Pods` 的 `DNS` 记录，
* 然后设置`clusterIP=None`，将该服务设置成**无头服务**。
* 最后，我们分别定义端口`9200`、`9300`，分别用于**与 `REST API` 交互**，以及用于**节点间通信**。
 * 9200: **与`REST API`交互**
 * 9300: **节点间通信**

使用 `kubectl` 直接创建上面的服务资源对象：

```
$ kubectl create -f elasticsearch-svc.yaml
service/elasticsearch created
$ kubectl get services -n=logging
Output
NAME            TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)             AGE
elasticsearch   ClusterIP   None         <none>        9200/TCP,9300/TCP   26s
```

### 无头服务：

```
.elasticsearch.logging.svc.cluster.local
```

现在我们已经为 `Pod` 设置了无头服务和一个稳定的域名 `.elasticsearch.logging.svc.cluster.local`，接下来我们通过 `StatefulSet` 来创建具体的 `Elasticsearch` 的 Pod 应用。


`Kubernetes StatefulSet` 允许我们为 `Pod` 分配一个稳定的标识和持久化存储，`Elasticsearch` 需要稳定的存储来保证 `Pod` 在重新调度或者重启后的数据依然不变，所以需要使用 `StatefulSet` 来管理 `Pod`。


[Why StatefulSet Pod](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_adv24_DaemonSet_StatefulSet.md)


新建名为 `elasticsearch-statefulset.yaml` 的资源清单文件，首先粘贴下面内容：

```
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: es-cluster
  namespace: logging
spec:
  serviceName: elasticsearch
  replicas: 3
  selector:
    matchLabels:
      app: elasticsearch
  template:
    metadata:
      labels:
        app: elasticsearch
```

该内容中，我们定义了一个名为 `es-cluster` 的 `StatefulSet` 对象，然后定义 `serviceName=elasticsearch` 和前面创建的 `Service` 相关联，这可以确保使用以下 `DNS` 地址访问 `StatefulSet` 中的每一个 `Pod：es-cluster-[0,1,2].elasticsearch.logging.svc.cluster.local`，其中`[0,1,2]`对应于已分配的 `Pod` 序号。

然后指定`3`个副本，将 `matchLabels` 设置为 `app=elasticsearch`，所以 `Pod` 的模板部分`.spec.template.metadata.lables` 也必须包含 `app=elasticsearch` 标签。

然后定义 `Pod` 模板部分内容：

```
...
  spec:
    containers:
    - name: elasticsearch
      image: docker.elastic.co/elasticsearch/elasticsearch-oss:6.4.3
      resources:
        limits:
          cpu: 1000m
        requests:
          cpu: 100m
      ports:
      - containerPort: 9200
        name: rest
        protocol: TCP
      - containerPort: 9300
        name: inter-node
        protocol: TCP
      volumeMounts:
      - name: data
        mountPath: /usr/share/elasticsearch/data
      env:
      - name: cluster.name
        value: k8s-logs
      - name: node.name
        valueFrom:
          fieldRef:
            fieldPath: metadata.name
      - name: discovery.zen.ping.unicast.hosts
        value: "es-cluster-0.elasticsearch,es-cluster-1.elasticsearch,es-cluster-2.elasticsearch"
      - name: discovery.zen.minimum_master_nodes
        value: "2"
      - name: ES_JAVA_OPTS
        value: "-Xms512m -Xmx512m"
```

1. 该部分是定义 `StatefulSet` 中的 `Pod`，我们这里使用一个`-oss`后缀的镜像，该镜像是 `Elasticsearch` 的开源版本，如果你想使用包含`X-Pack`之类的版本，**可以去掉该后缀**。
2. 然后暴露了`9200`和`9300`两个端口，注意名称要和上面定义的 `Service` 保持一致。然后通过 `volumeMount` 声明了数据持久化目录，下面我们再来定义 `VolumeClaims`。最后就是我们在容器中设置的一些环境变量了：
 * 	`cluster.name`：`Elasticsearch` 集群的名称，我们这里命名成 `k8s-logs`。
 *  `node.name`：节点的名称，通过`metadata.name`来获取。这将解析为 `es-cluster-[0,1,2]`，取决于节点的指定顺序。
 *  `discovery.zen.ping.unicast.hosts`：此字段用于设置在 `Elasticsearch` 集群中节点相互连接的发现方法。我们使用 `unicastdiscovery` 方式，它为我们的集群指定了一个静态主机列表。由于我们之前配置的无头服务，我们的 `Pod` 具有唯一的 `DNS` 域 `es-cluster-[0,1,2].elasticsearch.logging.svc.cluster.local`，因此我们相应地设置此变量。由于都在同一个 `namespace` 下面，所以我们可以将其缩短为`es-cluster-[0,1,2].elasticsearch`。要了解有关 `Elasticsearch` 发现的更多信息，请参阅 `Elasticsearch` 官方文档：[https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-discovery.html](https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-discovery.html)。
 *  `discovery.zen.minimum_master_nodes`：我们将其设置为`(N/2) + 1`，**`N`是我们的群集中符合主节点的节点的数量。我们有`3`个 `Elasticsearch` 节点，因此我们将此值设置为`2`（向下舍入到最接近的整数）**
 *  `ES_JAVA_OPTS`：这里我们设置为`-Xms512m -Xmx512m`，告诉`JVM`使用`512 MB`的**最小和最大堆**。您应该根据群集的资源可用性和需求调整这些参数。要了解更多信息，请参阅设置堆大小的相关文档：[https://www.elastic.co/guide/en/elasticsearch/reference/current/heap-size.html](https://www.elastic.co/guide/en/elasticsearch/reference/current/heap-size.html)。

接下来添加关于 `initContainer` 的内容：

[Why Init Container](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_adv9_pod_init_container.md)

```
...
    initContainers:
    - name: fix-permissions
      image: busybox
      command: ["sh", "-c", "chown -R 1000:1000 /usr/share/elasticsearch/data"]
      securityContext:
        privileged: true
      volumeMounts:
      - name: data
        mountPath: /usr/share/elasticsearch/data
    - name: increase-vm-max-map
      image: busybox
      command: ["sysctl", "-w", "vm.max_map_count=262144"]
      securityContext:
        privileged: true
    - name: increase-fd-ulimit
      image: busybox
      command: ["sh", "-c", "ulimit -n 65536"]
      securityContext:
        privileged: true
```

**这里我们定义了几个在主应用程序之前运行的 `Init 容器`，这些初始容器按照定义的顺序依次执行，执行完成后才会启动主应用容器。**

* 第一个名为 `fix-permissions` 的容器用来运行 `chown` 命令，将 `Elasticsearch` 数据目录的用户和组更改为`1000:1000`（`Elasticsearch` 用户的 `UID`）。因为默认情况下，`Kubernetes` 用 `root` 用户挂载数据目录，这会使得 `Elasticsearch` 无法方法该数据目录，可以参考 `Elasticsearch` 生产中的一些默认注意事项相关文档说明：[notes for production use and defaults](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html#_notes_for_production_use_and_defaults)
* 第二个名为 `increase-vm-max-map` 的容器用来增加操作系统对 `mmap` 计数的限制，**默认情况下该值可能太低，导致内存不足的错误**，要了解更多关于该设置的信息，可以查看 `Elasticsearch` 官方文档说明: [cm max map count](https://www.elastic.co/guide/en/elasticsearch/reference/current/vm-max-map-count.html)
* 最后一个初始化容器是用来执行 `ulimit` 命令增加打开文件描述符的最大数量的。
* 此外 `Elastisearch Notes for Production Use` 文档还提到了由于性能原因最好禁用 `swap`，当然对于 `Kubernetes` 集群而言，最好也是禁用 `swap` 分区的。

现在我们已经定义了主应用容器和它之前运行的 `Init Containers` 来调整一些必要的系统参数，接下来我们可以添加数据目录的持久化相关的配置，在 `StatefulSet` 中，使用 `volumeClaimTemplates` 来定义 `volume` 模板即可：

现在我们已经定义了主应用容器和它之前运行的 `Init Containers` 来调整一些必要的系统参数，**接下来我们可以添加数据目录的持久化相关的配置**，在 `StatefulSet` 中，使用 `volumeClaimTemplates` 来定义 `volume` 模板即可：

```
...
  volumeClaimTemplates:
  - metadata:
      name: data
      labels:
        app: elasticsearch
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: es-data-db
      resources:
        requests:
          storage: 50Gi
```

* 我们这里使用 `volumeClaimTemplates` 来定义持久化模板，`Kubernetes` 会使用它为 `Pod `创建 `PersistentVolume`，
* 设置访问模式为 `ReadWriteOnce`，这意味着它只能被 `mount` 到单个节点上进行读写，
* 然后最重要的是使用了一个名为 `es-data-db` 的 `StorageClass` 对象，
* 所以我们需要提前创建该对象，我们这里使用的 `NFS` 作为存储后端，所以需要安装一个对应的 `provisioner` 驱动，前面关于 `Storage` 的课程中已经和大家介绍过方法，[NFS](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_adv14_pv1.md#nfs)
* 新建一个 `elasticsearch-storageclass.yaml` 的文件，文件内容如下：

**elasticsearch-storageclass.yaml**

```
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: es-data-db
provisioner: fuseim.pri/ifs  # 该值需要和 provisioner 配置的保持一致
```
最后，我们指定了每个 `PersistentVolume` 的大小为 `50GB`，我们可以根据自己的实际需要进行调整该值。最后，完整的 `Elasticsearch StatefulSet` 资源清单文件内容如下：

```
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: es-cluster
  namespace: logging
spec:
  serviceName: elasticsearch
  replicas: 3
  selector:
    matchLabels:
      app: elasticsearch
  template:
    metadata:
      labels:
        app: elasticsearch
    spec:
      containers:
      - name: elasticsearch
        image: docker.elastic.co/elasticsearch/elasticsearch-oss:6.4.3
        resources:
            limits:
              cpu: 1000m
            requests:
              cpu: 100m
        ports:
        - containerPort: 9200
          name: rest
          protocol: TCP
        - containerPort: 9300
          name: inter-node
          protocol: TCP
        volumeMounts:
        - name: data
          mountPath: /usr/share/elasticsearch/data
        env:
          - name: cluster.name
            value: k8s-logs
          - name: node.name
            valueFrom:
              fieldRef:
                fieldPath: metadata.name
          - name: discovery.zen.ping.unicast.hosts
            value: "es-cluster-0.elasticsearch,es-cluster-1.elasticsearch,es-cluster-2.elasticsearch"
          - name: discovery.zen.minimum_master_nodes
            value: "2"
          - name: ES_JAVA_OPTS
            value: "-Xms512m -Xmx512m"
      initContainers:
      - name: fix-permissions
        image: busybox
        command: ["sh", "-c", "chown -R 1000:1000 /usr/share/elasticsearch/data"]
        securityContext:
          privileged: true
        volumeMounts:
        - name: data
          mountPath: /usr/share/elasticsearch/data
      - name: increase-vm-max-map
        image: busybox
        command: ["sysctl", "-w", "vm.max_map_count=262144"]
        securityContext:
          privileged: true
      - name: increase-fd-ulimit
        image: busybox
        command: ["sh", "-c", "ulimit -n 65536"]
        securityContext:
          privileged: true
  volumeClaimTemplates:
  - metadata:
      name: data
      labels:
        app: elasticsearch
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: es-data-db
      resources:
        requests:
          storage: 100Gi
```

现在直接使用 `kubectl` 工具部署即可：

```
$ kubectl create -f elasticsearch-storageclass.yaml
storageclass.storage.k8s.io "es-data-db" created
$ kubectl create -f elasticsearch-statefulset.yaml
statefulset.apps/es-cluster created
```
添加成功后，可以看到 `logging` 命名空间下面的所有的资源对象：

**sts: `StateSet`**

```
$ kubectl get sts -n logging
NAME         DESIRED   CURRENT   AGE
es-cluster   3         3         20h

$ kubectl get pods -n logging
NAME                      READY     STATUS    RESTARTS   AGE
es-cluster-0              1/1       Running   0          20h
es-cluster-1              1/1       Running   0          20h
es-cluster-2              1/1       Running   0          20h

$ kubectl get svc -n logging
NAME            TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
elasticsearch   ClusterIP   None             <none>        9200/TCP,9300/TCP   20h
```
`Pods` 部署完成后，我们可以通过请求一个 `REST API` 来检查 `Elasticsearch` 集群是否正常运行。使用下面的命令将本地端口`9200`转发到 `Elasticsearch` 节点（如`es-cluster-0`）对应的端口：

```
$ kubectl port-forward es-cluster-0 9200:9200 --namespace=logging
Forwarding from 127.0.0.1:9200 -> 9200
Forwarding from [::1]:9200 -> 9200
```

[Forward a local port to a port on the pod](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/#forward-a-local-port-to-a-port-on-the-pod)

```
$ curl http://localhost:9200/_cluster/state?pretty
```

正常来说，应该会看到类似于如下的信息：

```
{
  "cluster_name" : "k8s-logs",
  "compressed_size_in_bytes" : 348,
  "cluster_uuid" : "QD06dK7CQgids-GQZooNVw",
  "version" : 3,
  "state_uuid" : "mjNIWXAzQVuxNNOQ7xR-qg",
  "master_node" : "IdM5B7cUQWqFgIHXBp0JDg",
  "blocks" : { },
  "nodes" : {
    "u7DoTpMmSCixOoictzHItA" : {
      "name" : "es-cluster-1",
      "ephemeral_id" : "ZlBflnXKRMC4RvEACHIVdg",
      "transport_address" : "10.244.4.191:9300",
      "attributes" : { }
    },
    "IdM5B7cUQWqFgIHXBp0JDg" : {
      "name" : "es-cluster-0",
      "ephemeral_id" : "JTk1FDdFQuWbSFAtBxdxAQ",
      "transport_address" : "10.244.2.215:9300",
      "attributes" : { }
    },
    "R8E7xcSUSbGbgrhAdyAKmQ" : {
      "name" : "es-cluster-2",
      "ephemeral_id" : "9wv6ke71Qqy9vk2LgJTqaA",
      "transport_address" : "10.244.40.4:9300",
      "attributes" : { }
    }
  },
...

```

**看到上面的信息就表明我们名为 `k8s-logs` 的 `Elasticsearch` 集群成功创建了`3`个节点：`es-cluster-0`，`es-cluster-1`，和`es-cluster-2`，当前主节点是 `es-cluster-0`。**


## 创建 Kibana 服务


`Elasticsearch` 集群启动成功了，接下来我们可以来部署 `Kibana` 服务，新建一个名为 `kibana.yaml` 的文件，对应的文件内容如下：

```
apiVersion: v1
kind: Service
metadata:
  name: kibana
  namespace: logging
  labels:
    app: kibana
spec:
  ports:
  - port: 5601
  type: NodePort
  selector:
    app: kibana

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kibana
  namespace: logging
  labels:
    app: kibana
spec:
  selector:
    matchLabels:
      app: kibana
  template:
    metadata:
      labels:
        app: kibana
    spec:
      containers:
      - name: kibana
        image: docker.elastic.co/kibana/kibana-oss:6.4.3
        resources:
          limits:
            cpu: 1000m
          requests:
            cpu: 100m
        env:
          - name: ELASTICSEARCH_URL
            value: http://elasticsearch:9200
        ports:
        - containerPort: 5601
```

上面我们定义了两个资源对象，一个 `Service` 和 `Deployment`，为了测试方便，我们将 `Service` 设置为了 `NodePort` 类型，`Kibana Pod` 中配置都比较简单，

**唯一需要注意的是我们使用 `ELASTICSEARCH_URL` 这个环境变量来设置`Elasticsearch` 集群的端点和端口，直接使用 `Kubernetes DNS` 即可，此端点对应服务名称为 `elasticsearch`，由于是一个 `headless service`，所以该域将解析为`3`个 `Elasticsearch Pod` 的 `IP` 地址列表。**

```
- name: ELASTICSEARCH_URL
  value: http://elasticsearch:9200
```

配置完成后，直接使用 `kubectl` 工具创建：

```
$ kubectl create -f kibana.yaml
service/kibana created
deployment.apps/kibana created
```

创建完成后，可以查看 `Kibana Pod` 的运行状态：


```
$ kubectl get pods --namespace=logging
NAME                      READY     STATUS    RESTARTS   AGE
es-cluster-0              1/1       Running   0          20h
es-cluster-1              1/1       Running   0          20h
es-cluster-2              1/1       Running   0          20h
kibana-7558d4dc4d-5mqdz   1/1       Running   0          20h
$ kubectl get svc --namespace=logging
NAME            TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
elasticsearch   ClusterIP   None             <none>        9200/TCP,9300/TCP   20h
kibana          NodePort    10.105.208.253   <none>        5601:31816/TCP      20h
```

如果 `Pod` 已经是 `Running` 状态了，证明应用已经部署成功了，然后可以通过 `NodePort` 来访问 `Kibana` 这个服务，在浏览器中打开`http://<任意节点IP>:31816`即可，如果看到如下欢迎界面证明 `Kibana` 已经成功部署到了 `Kubernetes`集群之中。

![Alt Image Text](images/2_1.jpg "Headline image")


## 部署 Fluentd

`Fluentd` 是一个高效的日志聚合器，是用 `Ruby` 编写的，并且可以很好地扩展。对于大部分企业来说，`Fluentd` 足够高效并且消耗的资源相对较少，另外一个工具`Fluent-bit`更轻量级，占用资源更少，但是插件相对 `Fluentd` 来说不够丰富，所以整体来说，`Fluentd` 更加成熟，使用更加广泛，所以我们这里也同样使用 `Fluentd` 来作为日志收集工具。

### 工作原理

**`Fluentd` 通过一组给定的数据源抓取日志数据**，处理后（转换成结构化的数据格式）将它们转发给其他服务，比如 `Elasticsearch`、`对象存储`等等。`Fluentd` 支持超过300个日志存储和分析服务，所以在这方面是非常灵活的。主要运行步骤如下：

* 首先 `Fluentd` 从多个日志源获取数据
* 结构化并且标记这些数据
* 然后根据匹配的标签将数据发送到多个目标服务去

![Alt Image Text](images/2_2.jpg "Headline image")

### 配置

一般来说我们是通过一个配置文件来告诉 Fluentd 如何采集、处理数据的，下面简单和大家介绍下 Fluentd 的配置方法

#### 日志源配置

比如我们这里为了收集 `Kubernetes` 节点上的所有容器日志，就需要做如下的日志源配置：

```
<source>

@id fluentd-containers.log

@type tail

path /var/log/containers/*.log

pos_file /var/log/fluentd-containers.log.pos

time_format %Y-%m-%dT%H:%M:%S.%NZ

tag raw.kubernetes.*

format json

read_from_head true

</source>
```

上面配置部分参数说明如下：

* **id**：表示引用该日志源的唯一标识符，该标识可用于进一步过滤和路由结构化日志数据
* **type**：`Fluentd` 内置的指令，
  * **`tail`**表示 `Fluentd` 从上次读取的位置通过 `tail` 不断获取数据，
  * 另外一个是**`http`**表示通过一个 `GET` 请求来收集数据。
* **path**：`tail`类型下的特定参数，告诉 `Fluentd` 采集**`/var/log/containers`**目录下的所有日志，这是 `docker` 在 `Kubernetes` 节点上用来存储运行容器 `stdout` 输出日志数据的目录。
* **pos_file**：检查点，如果 `Fluentd` 程序重新启动了，它将使用此文件中的位置来恢复日志数据收集。
* **tag**：用来将日志源与目标或者过滤器匹配的自定义字符串，`Fluentd` 匹配源/目标标签来路由日志数据。

#### 路由配置

上面是日志源的配置，接下来看看如何将日志数据发送到 `Elasticsearch`：

```
<match **>

@id elasticsearch

@type elasticsearch

@log_level info

include_tag_key true

type_name fluentd

host "#{ENV['OUTPUT_HOST']}"

port "#{ENV['OUTPUT_PORT']}"

logstash_format true

<buffer>

@type file

path /var/log/fluentd-buffers/kubernetes.system.buffer

flush_mode interval

retry_type exponential_backoff

flush_thread_count 2

flush_interval 5s

retry_forever

retry_max_interval 30

chunk_limit_size "#{ENV['OUTPUT_BUFFER_CHUNK_LIMIT']}"

queue_limit_length "#{ENV['OUTPUT_BUFFER_QUEUE_LIMIT']}"

overflow_action block

</buffer>
```

* **`match`**：标识一个目标标签，后面是一个匹配日志源的正则表达式，我们这里想要捕获所有的日志并将它们发送给 `Elasticsearch`，所以需要配置成`**`。
* **`id`**：目标的一个唯一标识符。
* **`type`**：支持的输出插件标识符，我们这里要输出到 `Elasticsearch`，所以配置成 `elasticsearch`，这是 `Fluentd` 的一个内置插件。
* **`log_level`**：指定要捕获的日志级别，我们这里配置成`info`，表示任何该级别或者该级别以上（`INFO`、`WARNING`、`ERROR`）的日志都将被路由到 `Elsasticsearch`。
* **`host/port`**：定义 `Elasticsearch` 的地址，也可以配置认证信息，我们的 `Elasticsearch` 不需要认证，所以这里直接指定 `host` 和 `port` 即可。
* **`logstash_format`**：`Elasticsearch` 服务对日志数据构建反向索引进行搜索，将 `logstash_format` 设置为`true`，`Fluentd` 将会以 `logstash` 格式来转发结构化的日志数据。
* **`Buffer`**： `Fluentd` 允许在目标不可用时进行缓存，比如，如果网络出现故障或者 `Elasticsearch` 不可用的时候。缓冲区配置也有助于降低磁盘的 `IO`。


### 安装

要收集 `Kubernetes` 集群的日志，直接用 `DasemonSet` 控制器来部署 `Fluentd` 应用，这样，它就可以从 `Kubernetes` 节点上采集日志，确保在集群中的每个节点上始终运行一个 `Fluentd` 容器。当然可以直接使用 `Helm` 来进行一键安装，为了能够了解更多实现细节，我们这里还是采用手动方法来进行安装。

首先，我们通过 `ConfigMap` 对象来指定 `Fluentd` 配置文件，新建 `fluentd-configmap.yaml` 文件，文件内容如下：

```
kind: ConfigMap
apiVersion: v1
metadata:
  name: fluentd-config
  namespace: logging
  labels:
    addonmanager.kubernetes.io/mode: Reconcile
data:
  system.conf: |-
    <system>
      root_dir /tmp/fluentd-buffers/
    </system>
  containers.input.conf: |-
    <source>
      @id fluentd-containers.log
      @type tail
      path /var/log/containers/*.log
      pos_file /var/log/es-containers.log.pos
      time_format %Y-%m-%dT%H:%M:%S.%NZ
      localtime
      tag raw.kubernetes.*
      format json
      read_from_head true
    </source>
    # Detect exceptions in the log output and forward them as one log entry.
    <match raw.kubernetes.**>
      @id raw.kubernetes
      @type detect_exceptions
      remove_tag_prefix raw
      message log
      stream stream
      multiline_flush_interval 5
      max_bytes 500000
      max_lines 1000
    </match>
  system.input.conf: |-
    # Logs from systemd-journal for interesting services.
    <source>
      @id journald-docker
      @type systemd
      filters [{ "_SYSTEMD_UNIT": "docker.service" }]
      <storage>
        @type local
        persistent true
      </storage>
      read_from_head true
      tag docker
    </source>
    <source>
      @id journald-kubelet
      @type systemd
      filters [{ "_SYSTEMD_UNIT": "kubelet.service" }]
      <storage>
        @type local
        persistent true
      </storage>
      read_from_head true
      tag kubelet
    </source>
  forward.input.conf: |-
    # Takes the messages sent over TCP
    <source>
      @type forward
    </source>
  output.conf: |-
    # Enriches records with Kubernetes metadata
    <filter kubernetes.**>
      @type kubernetes_metadata
    </filter>
    <match **>
      @id elasticsearch
      @type elasticsearch
      @log_level info
      include_tag_key true
      host elasticsearch
      port 9200
      logstash_format true
      request_timeout    30s
      <buffer>
        @type file
        path /var/log/fluentd-buffers/kubernetes.system.buffer
        flush_mode interval
        retry_type exponential_backoff
        flush_thread_count 2
        flush_interval 5s
        retry_forever
        retry_max_interval 30
        chunk_limit_size 2M
        queue_limit_length 8
        overflow_action block
      </buffer>
    </match>
```

上面配置文件中我们配置了 `docker` 容器日志目录以及 `docker`、`kubelet` 应用的日志的收集，收集到数据经过处理后发送到 `elasticsearch:9200` 服务。

然后新建一个 `fluentd-daemonset.yaml` 的文件，文件内容如下：

```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: fluentd-es
  namespace: logging
  labels:
    k8s-app: fluentd-es
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: fluentd-es
  labels:
    k8s-app: fluentd-es
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
rules:
- apiGroups:
  - ""
  resources:
  - "namespaces"
  - "pods"
  verbs:
  - "get"
  - "watch"
  - "list"
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: fluentd-es
  labels:
    k8s-app: fluentd-es
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
subjects:
- kind: ServiceAccount
  name: fluentd-es
  namespace: logging
  apiGroup: ""
roleRef:
  kind: ClusterRole
  name: fluentd-es
  apiGroup: ""
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd-es
  namespace: logging
  labels:
    k8s-app: fluentd-es
    version: v2.0.4
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
spec:
  selector:
    matchLabels:
      k8s-app: fluentd-es
      version: v2.0.4
  template:
    metadata:
      labels:
        k8s-app: fluentd-es
        kubernetes.io/cluster-service: "true"
        version: v2.0.4
      # This annotation ensures that fluentd does not get evicted if the node
      # supports critical pod annotation based priority scheme.
      # Note that this does not guarantee admission on the nodes (#40573).
      annotations:
        scheduler.alpha.kubernetes.io/critical-pod: ''
    spec:
      priorityClassName: system-node-critical
      serviceAccountName: fluentd-es
      containers:
      - name: fluentd-es
        image: cnych/fluentd-elasticsearch:v2.0.4
        env:
        - name: FLUENTD_ARGS
          value: --no-supervisor -q
        resources:
          limits:
            memory: 500Mi
          requests:
            cpu: 100m
            memory: 200Mi
        volumeMounts:
        - name: varlog
          mountPath: /var/log
        - name: varlibdockercontainers
          mountPath: /data/docker/containers
          readOnly: true
        - name: config-volume
          mountPath: /etc/fluent/config.d
      nodeSelector:
        beta.kubernetes.io/fluentd-ds-ready: "true"
      tolerations:
      - key: node-role.kubernetes.io/master
        operator: Exists
        effect: NoSchedule
      terminationGracePeriodSeconds: 30
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
      - name: varlibdockercontainers
        hostPath:
          path: /data/docker/containers
      - name: config-volume
        configMap:
          name: fluentd-config
```

我们将上面创建的 `fluentd-config` 这个 `ConfigMap` 对象通过 `volumes` 挂载到了 `Fluentd` 容器中，另外为了能够灵活控制哪些节点的日志可以被收集，所以我们这里还添加了一个 `nodSelector` 属性：

```
nodeSelector:
  beta.kubernetes.io/fluentd-ds-ready: "true"
```

**意思就是要想采集节点的日志，那么我们就需要给节点打上上面的标签，比如我们这里3个节点都打上了该标签：**

```
$ kubectl get nodes --show-labels
NAME      STATUS    ROLES     AGE       VERSION   LABELS
master    Ready     master    245d      v1.10.0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/fluentd-ds-ready=true,beta.kubernetes.io/os=linux,kubernetes.io/hostname=master,node-role.kubernetes.io/master=
node02    Ready     <none>    165d      v1.10.0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/fluentd-ds-ready=true,beta.kubernetes.io/os=linux,com=youdianzhishi,course=k8s,kubernetes.io/hostname=node02
node03    Ready     <none>    225d      v1.10.0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/fluentd-ds-ready=true,beta.kubernetes.io/os=linux,jnlp=haimaxy,kubernetes.io/hostname=node03
```

**另外由于我们的集群使用的是 `kubeadm` 搭建的，默认情况下 `master` 节点有污点，所以要想也收集 `master` 节点的日志，则需要添加上容忍：**

```
tolerations:
- key: node-role.kubernetes.io/master
  operator: Exists
  effect: NoSchedule
```

另外需要注意的地方是，我这里的测试环境更改了 `docker` 的根目录：

```
$ docker info
...
Docker Root Dir: /data/docker
...
```

**所以上面要获取 `docker` 的容器目录需要更改成`/data/docker/containers`，这个地方非常重要，当然如果你没有更改 `docker` 根目录则使用默认的 `/var/lib/docker/containers` 目录即可。**


分别创建上面的 `ConfigMap` 对象和 `DaemonSet`：

```
$ kubectl create -f fluentd-configmap.yaml
configmap "fluentd-config" created
$ kubectl create -f fluentd-daemonset.yaml
serviceaccount "fluentd-es" created
clusterrole.rbac.authorization.k8s.io "fluentd-es" created
clusterrolebinding.rbac.authorization.k8s.io "fluentd-es" created
daemonset.apps "fluentd-es" created
```

创建完成后，查看对应的 Pods 列表，检查是否部署成功：

```
$ kubectl get pods -n logging
NAME                      READY     STATUS    RESTARTS   AGE
es-cluster-0              1/1       Running   0          1d
es-cluster-1              1/1       Running   0          1d
es-cluster-2              1/1       Running   0          1d
fluentd-es-2z9jg          1/1       Running   1          35s
fluentd-es-6dfdd          1/1       Running   0          35s
fluentd-es-bfkg7          1/1       Running   0          35s
kibana-7558d4dc4d-5mqdz   1/1       Running   0          1d
```

`Fluentd` 启动成功后，我们可以前往 `Kibana` 的 `Dashboard` 页面中，点击左侧的`Discover`，可以看到如下配置页面：

![Alt Image Text](images/2_3.jpg "Headline image")

在这里可以配置我们需要的 `Elasticsearch` 索引，前面 `Fluentd` 配置文件中我们采集的日志使用的是 `logstash` 格式，这里只需要在文本框中输入`logstash-*`即可匹配到 `Elasticsearch` 集群中的所有日志数据，然后点击下一步，进入以下页面：

![Alt Image Text](images/2_4.jpg "Headline image")

在该页面中配置使用哪个字段按时间过滤日志数据，在下拉列表中，选择`@timestamp`字段，然后点击`Create index pattern`，创建完成后，点击左侧导航菜单中的`Discover`，然后就可以看到一些直方图和最近采集到的日志数据了：

![Alt Image Text](images/2_5.jpg "Headline image")

### 测试

现在我们来将上一节课的计数器应用部署到集群中，并在 `Kibana` 中来查找该日志数据。

新建 `counter.yaml` 文件，文件内容如下：

```
apiVersion: v1
kind: Pod
metadata:
  name: counter
spec:
  containers:
  - name: count
    image: busybox
    args: [/bin/sh, -c,
            'i=0; while true; do echo "$i: $(date)"; i=$((i+1)); sleep 1; done']
```
 
该 `Pod` 只是简单将日志信息打印到 `stdout`，所以正常来说 `Fluentd` 会收集到这个日志数据，在 `Kibana` 中也就可以找到对应的日志数据了，使用 `kubectl` 工具创建该 `Pod`：


```
$ kubectl create -f counter.yaml
```

`Pod` 创建并运行后，回到 `Kibana Dashboard` 页面，在上面的`Discover`页面搜索栏中输入`kubernetes.pod_name:counter`，就可以过滤 `Pod` 名为 `counter` 的日志数据：

![Alt Image Text](images/2_6.jpg "Headline image")


我们也可以通过其他元数据来过滤日志数据，比如 您可以单击任何日志条目以查看其他元数据，如容器名称，Kubernetes 节点，命名空间等。

到这里，我们就在 `Kubernetes` 集群上成功部署了 `EFK` ，要了解如何使用 `Kibana` 进行日志数据分析，可以参考 `Kibana` 用户指南文档：[https://www.elastic.co/guide/en/kibana/current/index.html](https://www.elastic.co/guide/en/kibana/current/index.html)

当然对于在生产环境上使用 `Elaticsearch` 或者 `Fluentd`，还需要结合实际的环境做一系列的优化工作，本文中涉及到的资源清单文件都可以在[https://github.com/cnych/kubernetes-learning/tree/master/efkdemo](https://www.elastic.co/guide/en/kibana/current/index.html)找到。


> [https://www.digitalocean.com/community/tutorials/how-to-set-up-an-elasticsearch-fluentd-and-kibana-efk-logging-stack-on-kubernetes](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-elasticsearch-fluentd-and-kibana-efk-logging-stack-on-kubernetes)





















