# Prometheus高可用Thanos学习-sidercar和query & Thanos部署

`kubectl create namespace thanos`

最近工作中的主要任务都是在业务的高可用上，由于项目中使用到了Promethues，所以也花了一些时间研究了一下Promethues的高可用方案。发现也没有blog告诉怎么去deploy一个Thanos的集群，所以本文也会给出deploy的方法和源文件

由于`Promethues`本身仅是一个采样系统，如果做成`master-slave模`式，存在切换开销，并且增加系统的复杂性。因此官方给出的高可用建议方案如下图，使用多个对等的`Promethues`，对所有的`DataSource`均进行采样。这里的`Service`是`K8S`的`Service`，所以理论上访问该`Service`会随机地访问后端的两个`Promethues`。

![Alt Image Text](images/35_1.png "Body image")

上面方案中，当其中一个`Promethues pod`中断时，`K8S`会将流量仅导向另外一个`pod`。但是`pod`中断期间，其无法获取数据，因此当中断的`pod`恢复之后，在存储端，需要进行`sync`。可是，何时`sync`，怎么`sync`是一个比较复杂的问题，就算能解决这两个问题，实际生产环境中进行文件`sync`，本身也会存在各式各样的风险。

**所以`Thanos`就没有使用存储端`Sync`的方法来保证数据的一致性，而是采用才`query`端对查询到的数据进行合并**。下面会简单介绍一下Thanos的原理。

## 1. Thanos基本原理

基于官方的介绍，我将`Thanos`的架构简化，仅保存最基本的，我所关心的部分如下， 主要包含3部分：

1. **Thanos Query.** 主要是对从`Promethues Pod`采集来的数据进行`merge`，提供查询接口给客户端（官方文档上暂时没看到`merge`的原理，这篇总结之后需要花些时间看源码学习一下）；
2. **Thanos SideCar**. **将`Promethues container`的数据进行封装，以提供接口给`Thanos Query`**（实际上SideCar还能提供更多用处，但是这里暂时我们仅关心数据查询，后面再进一步研究，暂时不要图多）
3. **`Prometheus Container`.** 采集数据，通过`Remote Read API`提供接口给`Thanos SideCar`。

![Alt Image Text](images/35_2.png "Body image")

## 2. Thanos部署

本文聚焦 Thanos 的云原生部署方式，充分利用 Kubernetes 的资源调度与动态扩容能力。从官方文档里可以看到，当前 Thanos 在 Kubernetes 上部署有以下三种：


* `prometheus-operator`：集群中安装了 `prometheus-operator` 后，就可以通过创建 CRD 对象来部署 Thanos 了；
* 社区贡献的一些 `helm charts`：很多个版本，目标都是能够使用 helm 来一键部署 thanos；
* `kube-thanos：Thanos` 官方的开源项目，包含部署 `thanos` 到 `kubernetes` 的 `jsonnet` 模板与 `yaml` 示例。

本文将使用基于 kube-thanos 提供的 yaml 示例 (`examples/all/manifests`) 来部署，原因是 `prometheus-operator` 与社区的 `helm chart` 方式部署多了一层封装，屏蔽了许多细节，并且它们的实现都还不太成熟。

直接使用 `kubernetes` 的 `yaml` 资源文件部署更直观，也更容易做自定义，而且我相信 Thanos 用户通常都是高玩，有必要对 `thanos` 理解透彻，日后才能更好地根据实际场景做架构和配置的调整，直接使用 `yaml` 部署能够让我们看清细节。

## 方案

我们再来看看如何选型部署方案。

### **`Sidecar` or `Receiver`**

![Alt Image Text](images/35_3.png "Body image")

`Receiver` 方案是让 `Prometheus` 通过 `remote wirte API` 将数据 `push` 到 `Receiver `集中存储（同样会清理过期数据）：

![Alt Image Text](images/35_4.png "Body image")

那么该选哪种方案呢？我的建议是：

* 如果你的 `Query` 跟 `Sidecar` 离的比较远，比如 `Sidecar` 分布在多个数据中心，`Query` 向所有 `Sidecar` 查数据，速度会很慢，这种情况可以考虑用 `Receiver`，将数据集中吐到 `Receiver`，然后 `Receiver` 与 `Query` 部署在一起，`Query` 直接向 `Receiver` 查最新数据，提升查询性能；
* 如果你的使用场景只允许 `Prometheus` 将数据 `push` 到远程，可以考虑使用 `Receiver`。比如 `IoT` 设备没有持久化存储，只能将数据 `push` 到远程。

此外的场景应该都尽量使用 Sidecar 方案。


### **评估是否需要 Ruler**

`Ruler` 是一个可选组件，原则上推荐尽量使用 `Prometheus` 自带的 `rule` 功能（生成新指标+告警），这个功能需要一些 `Prometheus` 最新数据，直接使用 `Prometheus` 本机 `rule` 功能和数据，性能开销相比 `Thanos Ruler` 这种分布式方案小得多，并且几乎不会出错，`Thanos Ruler` 由于是分布式，所以更容易出错一些。

如果某些有关联的数据分散在多个不同 `Prometheus` 上，比如对某个大规模服务采集做了分片，每个 `Prometheus` 仅采集一部分 `endpoint` 的数据，对于 `record `类型的 `rule` （生成的新指标），还是可以使用 `Prometheus` 自带的 `rule `功能，在查询时再聚合一下就可以（如果可以接受的话）。

对于 `alert` 类型的 `rule`，我们就需要用 `Thanos Ruler` 来做了，因为有关联的数据分散在多个 `Prometheus` 上，用单机数据去做 `alert` 计算是不准确的，可能会造成误告警或不告警。

### 评估是否需要 `Store Gateway` 与 `Compact`

Store 也是一个可选组件，也是 Thanos 的一大亮点的关键：**数据长期保存**。

评估是否需要 Store 组件实际就是评估一下自己是否有数据长期存储的需求，比如查看一两个月前的监控数据。如果有，那么 Thanos 可以将数据上传到对象存储保存。

Thanos 支持以下对象存储：

* Google Cloud Storage
* AWS/S3
* Azure Storage Account
* OpenStack Swift
* Tencent COS
* AliYun OSS

在国内，最方便还是使用国内主流公有云对象存储服务。如果你的服务没有跑在公有云上，也可以通过跟云服务厂商拉专线的方式来走内网使用对象存储，这样速度通常也是可以满足需求的；如果实在用不了公有云的对象存储服务，也可以自己安装 minio 来搭建兼容 AWS 的 S3 对象存储服务。

搞定了对象存储，还需要给 `Thanos` 多个组件配置对象存储相关的信息，以便能够上传与读取监控数据。除 Query 以外的所有 Thanos 组件（`Sidecar`、`Receiver`、`Ruler`、`Store Gateway`、`Compac`t）都需要配置对象存储信息，使用 `--objstore.config`直接配置内容或 `--objstore.config-file` 引用对象存储配置文件，不同对象存储配置方式不一样，参考官方文档：https://thanos.io/storage.md


通常使用了对象存储来长期保存数据不止要安装 `Store Gateway`，还需要安装 `Compact`  来对对象存储里的数据进行压缩与降采样，这样可以提升查询大时间范围监控数据的性能。

注意：`Compact` 并不会减少对象存储的使用空间，而是会增加，增加更长采样间隔的监控数据，这样当查询大时间范围数据时，就自动拉取更长时间间隔采样的数据以减少查询数据的总量，**从而加快查询速度 （大时间范围的数据不需要那么精细），当放大查看时（选择其中一小段时间），又自动选择拉取更短采样间隔的数据，从而也能显示出小时间范围的监控细节**。

### 部署实践

这里以 Thanos 最新版本为例，选择 Sidecar 方案，介绍各个组件的 K8s yaml 定义方式并解释一些重要细节（根据自身需求，参考上一节的方案选型，自行评估需要安装哪些组件）。

**准备对象存储配置**


如果我们要使用对象存储来长期保存数据，那么就要准备下对象存储的配置信息 （`thanos-objectstorage-secret.yaml`），比如使用腾讯云 COS 来存储：

```
apiVersion: v1
kind: Secret
metadata:
  name: thanos-objectstorage
  namespace: thanos
type: Opaque
stringData:
  objectstorage.yaml: |
    type: COS
    config:
      bucket: "thanos"
      region: "ap-singapore"
      app_id: "12*******5"
      secret_key: "tsY***************************Edm"
      secret_id: "AKI******************************gEY"
```
或者使用阿里云 OSS 存储：

```
apiVersion: v1
kind: Secret
metadata:
  name: thanos-objectstorage
  namespace: thanos
type: Opaque
stringData:
  objectstorage.yaml: |
    type: ALIYUNOSS
    config:
      endpoint: "oss-cn-hangzhou-internal.aliyuncs.com"
      bucket: "thanos"
      access_key_id: "LTA******************KBu"
      access_key_secret: "oki************************2HQ"
```

**给 `Prometheus` 加上 `Sidecar`**

如果选用 `Sidecar` 方案，就需要给 `Prometheus` 加上 `Thanos Sidecar`，准备 `prometheus.yaml`：

```
kind: Service
apiVersion: v1
metadata:
  name: prometheus-headless
  namespace: thanos
  labels:
    app.kubernetes.io/name: prometheus
spec:
  type: ClusterIP
  clusterIP: None
  selector:
    app.kubernetes.io/name: prometheus
  ports:
  - name: web
    protocol: TCP
    port: 9090
    targetPort: web
  - name: grpc
    port: 10901
    targetPort: grpc
---

apiVersion: v1
kind: ServiceAccount
metadata:
  name: prometheus
  namespace: thanos

---

apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: prometheus
  namespace: thanos
rules:
- apiGroups: [""]
  resources:
  - nodes
  - nodes/proxy
  - nodes/metrics
  - services
  - endpoints
  - pods
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["get"]
- nonResourceURLs: ["/metrics"]
  verbs: ["get"]

---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: prometheus
subjects:
  - kind: ServiceAccount
    name: prometheus
    namespace: thanos
roleRef:
  kind: ClusterRole
  name: prometheus
  apiGroup: rbac.authorization.k8s.io
---

apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: prometheus
  namespace: thanos
  labels:
    app.kubernetes.io/name: thanos-query
spec:
  serviceName: prometheus-headless
  podManagementPolicy: Parallel
  replicas: 2
  selector:
    matchLabels:
      app.kubernetes.io/name: prometheus
  template:
    metadata:
      labels:
        app.kubernetes.io/name: prometheus
    spec:
      serviceAccountName: prometheus
      securityContext:
        fsGroup: 2000
        runAsNonRoot: true
        runAsUser: 1000
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app.kubernetes.io/name
                operator: In
                values:
                - prometheus
            topologyKey: kubernetes.io/hostname
      containers:
      - name: prometheus
        image: quay.io/prometheus/prometheus:v2.15.2
        args:
        - --config.file=/etc/prometheus/config_out/prometheus.yaml
        - --storage.tsdb.path=/prometheus
        - --storage.tsdb.retention.time=10d
        - --web.route-prefix=/
        - --web.enable-lifecycle
        - --storage.tsdb.no-lockfile
        - --storage.tsdb.min-block-duration=2h
        - --storage.tsdb.max-block-duration=2h
        - --log.level=debug
        ports:
        - containerPort: 9090
          name: web
          protocol: TCP
        livenessProbe:
          failureThreshold: 6
          httpGet:
            path: /-/healthy
            port: web
            scheme: HTTP
          periodSeconds: 5
          successThreshold: 1
          timeoutSeconds: 3
        readinessProbe:
          failureThreshold: 120
          httpGet:
            path: /-/ready
            port: web
            scheme: HTTP
          periodSeconds: 5
          successThreshold: 1
          timeoutSeconds: 3
        volumeMounts:
        - mountPath: /etc/prometheus/config_out
          name: prometheus-config-out
          readOnly: true
        - mountPath: /prometheus
          name: prometheus-storage
        - mountPath: /etc/prometheus/rules
          name: prometheus-rules
      - name: thanos
        image: quay.io/thanos/thanos:v0.11.0
        args:
        - sidecar
        - --log.level=debug
        - --tsdb.path=/prometheus
        - --prometheus.url=http://127.0.0.1:9090
        - --objstore.config-file=/etc/thanos/objectstorage.yaml
        - --reloader.config-file=/etc/prometheus/config/prometheus.yaml.tmpl
        - --reloader.config-envsubst-file=/etc/prometheus/config_out/prometheus.yaml
        - --reloader.rule-dir=/etc/prometheus/rules/
        env:
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        ports:
        - name: http-sidecar
          containerPort: 10902
        - name: grpc
          containerPort: 10901
        livenessProbe:
            httpGet:
              port: 10902
              path: /-/healthy
        readinessProbe:
          httpGet:
            port: 10902
            path: /-/ready
        volumeMounts:
        - name: prometheus-config-tmpl
          mountPath: /etc/prometheus/config
        - name: prometheus-config-out
          mountPath: /etc/prometheus/config_out
        - name: prometheus-rules
          mountPath: /etc/prometheus/rules
        - name: prometheus-storage
          mountPath: /prometheus
        - name: thanos-objectstorage
          subPath: objectstorage.yaml
          mountPath: /etc/thanos/objectstorage.yaml
      volumes:
      - name: prometheus-config-tmpl
        configMap:
          defaultMode: 420
          name: prometheus-config-tmpl
      - name: prometheus-config-out
        emptyDir: {}
      - name: prometheus-rules
        configMap:
          name: prometheus-rules
      - name: thanos-objectstorage
        secret:
          secretName: thanos-objectstorage
  volumeClaimTemplates:
  - metadata:
      name: prometheus-storage
      labels:
        app.kubernetes.io/name: prometheus
    spec:
      accessModes:
      - ReadWriteOnce
      resources:
        requests:
          storage: 200Gi
      volumeMode: Filesystem
```

* `Prometheus` 使用 `StatefulSet` 方式部署，挂载数据盘以便存储最新监控数据；
* 由于 `Prometheus` 副本之间没有启动顺序的依赖，所以 `podManagementPolicy` 指定为 `Parallel`，加快启动速度；
* 为 `Prometheus` 绑定足够的 RBAC 权限，以便后续配置使用 k8s 的服务发现（`kubernetes_sd_configs`）时能够正常工作。
* 为 `Prometheus` 创建 `headless` 类型 `service`，为后续 `Thanos Query` 通过 `DNS SRV` 记录来动态发现 `Sidecar` 的 `gRPC` 端点做准备（使用 `headless service `才能让` DNS SRV` 正确返回所有端点）。
* 使用两个 `Prometheus` 副本，用于实现高可用；
* 使用硬反亲和，避免 `Prometheus` 部署在同一节点，既可以分散压力也可以避免单点故障；
* `Prometheus` 使用 `--storage.tsdb.retention.time` 指定数据保留时长，默认`15`天，可以根据数据增长速度和数据盘大小做适当调整（数据增长取决于采集的指标和目标端点的数量和采集频率）；
* `Sidecar` 使用 `--objstore.config-file` 引用我们刚刚创建并挂载的对象存储配置文件，用于上传数据到对象存储；
* 通常会给 `Prometheus` 附带一个 `quay.io/coreos/prometheus-config-reloader` 来监听配置变更并动态加载，但 `thanos sidecar` 也为我们提供了这个功能，所以可以直接用 `thanos sidecar` 来实现此功能，也支持配置文件根据模板动态生成：`--reloader.config-file` 指定 `Prometheus` 配置文件模板，`--reloader.config-envsubst-file` 指定生成配置文件的存放路径，假设是 `/etc/prometheus/config_out/prometheus.yaml `，那么 `/etc/prometheus/config_out` 这个路径使用 `emptyDir `让 `Prometheus` 与 `Sidecar `实现配置文件共享挂载，`Prometheus` 再通过`--config.file ` 指定生成出来的配置文件，当配置有更新时，挂载的配置文件也会同步更新，`Sidecar` 也会通知 `Prometheus` 重新加载配置。另外，`Sidecar` 与 `Prometheus` 也挂载同一份 `rules` 配置文件，配置更新后 `Sidecar` 仅通知 `Prometheus` 加载配置，不支持模板，因为 `rules` 配置不需要模板来动态生成。


然后再给 `Prometheus` 准备配置 （`prometheus-config.yaml`）：

```

apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config-tmpl
  namespace: thanos
data:
  prometheus.yaml.tmpl: |-
    global:
      scrape_interval: 5s
      evaluation_interval: 5s
      external_labels:
        cluster: prometheus-ha
        prometheus_replica: $(POD_NAME)
    rule_files:
    - /etc/prometheus/rules/*rules.yaml
    scrape_configs:
    - job_name: cadvisor
      metrics_path: /metrics/cadvisor
      scrape_interval: 10s
      scrape_timeout: 10s
      scheme: https
      tls_config:
        insecure_skip_verify: true
      bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
      kubernetes_sd_configs:
      - role: node
      relabel_configs:
      - action: labelmap
        regex: __meta_kubernetes_node_label_(.+)
---

apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-rules
  labels:
    name: prometheus-rules
  namespace: thanos
data:
  alert-rules.yaml: |-
    groups:
    - name: k8s.rules
      rules:
      - expr: |
          sum(rate(container_cpu_usage_seconds_total{job="cadvisor", image!="", container!=""}[5m])) by (namespace)
        record: namespace:container_cpu_usage_seconds_total:sum_rate
      - expr: |
          sum(container_memory_usage_bytes{job="cadvisor", image!="", container!=""}) by (namespace)
        record: namespace:container_memory_usage_bytes:sum
      - expr: |
          sum by (namespace, pod, container) (
            rate(container_cpu_usage_seconds_total{job="cadvisor", image!="", container!=""}[5m])
          )
        record: namespace_pod_container:container_cpu_usage_seconds_total:sum_rate
```

本文重点不在 prometheus 的配置文件，所以这里仅以采集 kubelet 所暴露的 cadvisor 容器指标的简单配置为例。

`Prometheus` 实例采集的所有指标数据里都会额外加上 `external_labels` 里指定的 `label`，通常用 `cluster` 区分当前 `Prometheus` 所在集群的名称，我们再加了个 `prometheus_replica`，用于区分相同 `Prometheus` 副本（这些副本所采集的数据除了 `prometheus_replica` 的值不一样，其它几乎一致，这个值会被 `Thanos Sidecar` 替换成 `Pod` 副本的名称，用于 `Thanos` 实现 `Prometheus` 高可用）

### 安装 Query

准备 `thanos-query.yaml`：

```
apiVersion: v1
kind: Service
metadata:
  name: thanos-query
  namespace: thanos
  labels:
    app.kubernetes.io/name: thanos-query
spec:
  ports:
  - name: grpc
    port: 10901
    targetPort: grpc
  - name: http
    port: 9090
    targetPort: http
  selector:
    app.kubernetes.io/name: thanos-query
---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: thanos-query
  namespace: thanos
  labels:
    app.kubernetes.io/name: thanos-query
spec:
  replicas: 3
  selector:
    matchLabels:
      app.kubernetes.io/name: thanos-query
  template:
    metadata:
      labels:
        app.kubernetes.io/name: thanos-query
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app.kubernetes.io/name
                  operator: In
                  values:
                  - thanos-query
              topologyKey: kubernetes.io/hostname
            weight: 100
      containers:
      - args:
        - query
        - --log.level=debug
        - --query.auto-downsampling
        - --grpc-address=0.0.0.0:10901
        - --http-address=0.0.0.0:9090
        - --query.partial-response
        - --query.replica-label=prometheus_replica
        - --query.replica-label=rule_replica
        - --store=dnssrv+_grpc._tcp.prometheus-headless.thanos.svc.cluster.local
        - --store=dnssrv+_grpc._tcp.thanos-rule.thanos.svc.cluster.local
        - --store=dnssrv+_grpc._tcp.thanos-store.thanos.svc.cluster.local
        image: thanosio/thanos:v0.11.0
        livenessProbe:
          failureThreshold: 4
          httpGet:
            path: /-/healthy
            port: 9090
            scheme: HTTP
          periodSeconds: 30
        name: thanos-query
        ports:
        - containerPort: 10901
          name: grpc
        - containerPort: 9090
          name: http
        readinessProbe:
          failureThreshold: 20
          httpGet:
            path: /-/ready
            port: 9090
            scheme: HTTP
          periodSeconds: 5
        terminationMessagePolicy: FallbackToLogsOnError
      terminationGracePeriodSeconds: 120
```

配置内容仅为示例，根据自身情况来配置，格式基本兼容 `Prometheus` 的 `rule` 配置格式，参考：https://thanos.io/components/rule.md/#configuring-rules

### 安装 Compact

准备 Compact 部署配置 `thanos-compact.yaml`：

```

apiVersion: v1
kind: Service
metadata:
  labels:
    app.kubernetes.io/name: thanos-compact
  name: thanos-compact
  namespace: thanos
spec:
  ports:
  - name: http
    port: 10902
    targetPort: http
  selector:
    app.kubernetes.io/name: thanos-compact
---

apiVersion: apps/v1
kind: StatefulSet
metadata:
  labels:
    app.kubernetes.io/name: thanos-compact
  name: thanos-compact
  namespace: thanos
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: thanos-compact
  serviceName: thanos-compact
  template:
    metadata:
      labels:
        app.kubernetes.io/name: thanos-compact
    spec:
      containers:
      - args:
        - compact
        - --wait
        - --objstore.config-file=/etc/thanos/objectstorage.yaml
        - --data-dir=/var/thanos/compact
        - --debug.accept-malformed-index
        - --log.level=debug
        - --retention.resolution-raw=90d
        - --retention.resolution-5m=180d
        - --retention.resolution-1h=360d
        image: thanosio/thanos:v0.11.0
        livenessProbe:
          failureThreshold: 4
          httpGet:
            path: /-/healthy
            port: 10902
            scheme: HTTP
          periodSeconds: 30
        name: thanos-compact
        ports:
        - containerPort: 10902
          name: http
        readinessProbe:
          failureThreshold: 20
          httpGet:
            path: /-/ready
            port: 10902
            scheme: HTTP
          periodSeconds: 5
        terminationMessagePolicy: FallbackToLogsOnError
        volumeMounts:
        - mountPath: /var/thanos/compact
          name: data
          readOnly: false
        - name: thanos-objectstorage
          subPath: objectstorage.yaml
          mountPath: /etc/thanos/objectstorage.yaml
      terminationGracePeriodSeconds: 120
      volumes:
      - name: thanos-objectstorage
        secret:
          secretName: thanos-objectstorage
  volumeClaimTemplates:
  - metadata:
      labels:
        app.kubernetes.io/name: thanos-compact
      name: data
    spec:
      accessModes:
      - ReadWriteOnce
      resources:
        requests:
          storage: 100Gi
```

* `Compact` 只能部署单个副本，因为如果多个副本都去对对象存储的数据做压缩和降采样的话，会造成冲突；
* 使用 `StatefulSet` 部署，方便自动创建和挂载磁盘。磁盘用于存放临时数据，因为 `Compact` 需要一些磁盘空间来存放数据处理过程中产生的中间数据。
* `--wait` 让 `Compact` 一直运行，轮询新数据来做压缩和降采样；
* `Compact` 也需要对象存储的配置，用于读取对象存储数据以及上传压缩和降采样后的数据到对象存储；
* 创建一个普通 `service`，主要用于被 `Prometheus` 使用 `kubernetes` 的 `endpoints` 服务发现来采集指标（其它组件的 `service` 也一样有这个用途）；
* `--retention.resolution-raw` 指定原始数据存放时长，`--retention.resolution-5m` 指定降采样到数据点 `5` 分钟间隔的数据存放时长，`--retention.resolution-1h`  指定降采样到数据点 `1` 小时间隔的数据存放时长，它们的数据精细程度递减，占用的存储空间也是递减，通常建议它们的存放时间递增配置（一般只有比较新的数据才会放大看，久远的数据通常只会使用大时间范围查询来看个大致，所以建议将精细程度低的数据存放更长时间）。

### 安装 Receiver

该组件处于试验阶段，慎用。准备 `Receiver` 部署配置 `thanos-receiver.yaml`：

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: thanos-receive-hashrings
  namespace: thanos
data:
  thanos-receive-hashrings.json: |
    [
      {
        "hashring": "soft-tenants",
        "endpoints":
        [
          "thanos-receive-0.thanos-receive.kube-system.svc.cluster.local:10901",
          "thanos-receive-1.thanos-receive.kube-system.svc.cluster.local:10901",
          "thanos-receive-2.thanos-receive.kube-system.svc.cluster.local:10901"
        ]
      }
    ]
---

apiVersion: v1
kind: Service
metadata:
  name: thanos-receive
  namespace: thanos
  labels:
    kubernetes.io/name: thanos-receive
spec:
  ports:
  - name: http
    port: 10902
    protocol: TCP
    targetPort: 10902
  - name: remote-write
    port: 19291
    protocol: TCP
    targetPort: 19291
  - name: grpc
    port: 10901
    protocol: TCP
    targetPort: 10901
  selector:
    kubernetes.io/name: thanos-receive
  clusterIP: None
---

apiVersion: apps/v1
kind: StatefulSet
metadata:
  labels:
    kubernetes.io/name: thanos-receive
  name: thanos-receive
  namespace: thanos
spec:
  replicas: 3
  selector:
    matchLabels:
      kubernetes.io/name: thanos-receive
  serviceName: thanos-receive
  template:
    metadata:
      labels:
        kubernetes.io/name: thanos-receive
    spec:
      containers:
      - args:
        - receive
        - --grpc-address=0.0.0.0:10901
        - --http-address=0.0.0.0:10902
        - --remote-write.address=0.0.0.0:19291
        - --objstore.config-file=/etc/thanos/objectstorage.yaml
        - --tsdb.path=/var/thanos/receive
        - --tsdb.retention=12h
        - --label=receive_replica="$(NAME)"
        - --label=receive="true"
        - --receive.hashrings-file=/etc/thanos/thanos-receive-hashrings.json
        - --receive.local-endpoint=$(NAME).thanos-receive.thanos.svc.cluster.local:10901
        env:
        - name: NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        image: thanosio/thanos:v0.11.0
        livenessProbe:
          failureThreshold: 4
          httpGet:
            path: /-/healthy
            port: 10902
            scheme: HTTP
          periodSeconds: 30
        name: thanos-receive
        ports:
        - containerPort: 10901
          name: grpc
        - containerPort: 10902
          name: http
        - containerPort: 19291
          name: remote-write
        readinessProbe:
          httpGet:
            path: /-/ready
            port: 10902
            scheme: HTTP
          initialDelaySeconds: 10
          periodSeconds: 30
        resources:
          limits:
            cpu: "4"
            memory: 8Gi
          requests:
            cpu: "2"
            memory: 4Gi
        volumeMounts:
        - mountPath: /var/thanos/receive
          name: data
          readOnly: false
        - mountPath: /etc/thanos/thanos-receive-hashrings.json
          name: thanos-receive-hashrings
          subPath: thanos-receive-hashrings.json
        - mountPath: /etc/thanos/objectstorage.yaml
          name: thanos-objectstorage
          subPath: objectstorage.yaml
      terminationGracePeriodSeconds: 120
      volumes:
      - configMap:
          defaultMode: 420
          name: thanos-receive-hashrings
        name: thanos-receive-hashrings
      - name: thanos-objectstorage
        secret:
          secretName: thanos-objectstorage
  volumeClaimTemplates:
  - metadata:
      labels:
        app.kubernetes.io/name: thanos-receive
      name: data
    spec:
      accessModes:
      - ReadWriteOnce
      resources:
        requests:
          storage: 200Gi
```

* 部署 `3 `个副本， 配置 `hashring`， `--label=receive_replica`；
* 为数据添加 `receive_replica` 这个 `label`（`Query` 的 `--query.replica-label `也要加上这个）来实现 `Receiver` 的高可用；
* `Query` 要指定 `Receiver` 后端地址：`--store=dnssrv+_grpc._tcp.thanos-receive.thanos.svc.cluster.local`；
* `request`、`limit` 根据自身规模情况自行做适当调整；
* `--tsdb.retention` 根据自身需求调整最新数据的保留时间；
* 如果改命名空间，记得把 `Receiver` 的 `--receive.local-endpoint` 参数也改下，不然会疯狂报错直至 `OOMKilled`。

因为使用了 `Receiver` 来统一接收 `Prometheus` 的数据，所以 `Prometheus` 也不需要 `Sidecar` 了，但需要给` Prometheus` 配置文件里加下 `remote_write`，让 `Prometheus` 将数据 `push `给 `Receiver`：

```
 remote_write:
 - url: http://thanos-receive.thanos.svc.cluster.local:19291/api/v1/receive
```

**指定 Query 为数据源**

查询监控数据时需要指定 `Prometheus` 数据源地址，由于我们使用了 `Thanos `来做分布式，而 `Thanos` 关键查询入口就是 `Query`，所以我们需要将数据源地址指定为 `Query` 的地址，假如使用 `Grafana` 查询，进入 `Configuration-Data Sources-Add data source`，选择 `Prometheus`，指定 `thanos query` 的地址：http://thanos-query.thanos.svc.cluster.local:9090


