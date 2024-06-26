# Prometheus Operator 常用指标

Prometheus Operator 安装完成后会有很多默认的监控指标，一不注意就大量的报警产生，所以我们非常有必要了解下这些常用的监控指标，有部分指标很有可能对于我们自己的业务可有可无，所以可以适当的进行修改，这里我们就来对常用的几个指标进行简单的说明。

## 1. Kubernetes 资源相关

### 1.1 CPUThrottlingHigh

关于 CPU 的 limit 合理性指标。查出最近5分钟，超过25%的 CPU 执行周期受到限制的容器。表达式：


```
sum(increase(container_cpu_cfs_throttled_periods_total{container!="", }[5m])) by (container, pod, namespace)
          /
sum(increase(container_cpu_cfs_periods_total{}[5m])) by (container, pod, namespace)
          > ( 25 / 100 )
```

相关指标：

* `container_cpu_cfs_periods_total`：容器生命周期中度过的 cpu 周期总数
* `container_cpu_cfs_throttled_periods_total`：容器生命周期中度过的受限的 cpu 周期总数


### 1.2 KubeCPUOvercommit

集群 CPU 过度使用。CPU 已经过度使用无法容忍节点故障，节点资源使用的总量超过节点的 CPU 总量，所以如果有节点故障将影响集群资源运行因为所需资源将无法被分配。

表达式：

```
sum(namespace:kube_pod_container_resource_requests_cpu_cores:sum{})
          /
sum(kube_node_status_allocatable_cpu_cores)
          >
(count(kube_node_status_allocatable_cpu_cores)-1) / count(kube_node_status_allocatable_cpu_cores)
```
相关指标：

* `kube_pod_container_resource_requests_cpu_cores`：资源 CPU 使用的 cores 数量
* `kube_node_status_allocatable_cpu_cores`：节点 CPU cores 数量

### 1.3 KubeMemoryOvercommit

集群内存过度使用。内存已经过度使用无法容忍节点故障，节点资源使用的总量超过节点的内存总量，所以如果有节点故障将影响集群资源运行因为所需资源将无法被分配。表达式：

```
sum(namespace:kube_pod_container_resource_requests_memory_bytes:sum{})
          /
        sum(kube_node_status_allocatable_memory_bytes)
          >
        (count(kube_node_status_allocatable_memory_bytes)-1)
          /
        count(kube_node_status_allocatable_memory_bytes)
```

相关指标：

* `kube_pod_container_resource_requests_memory_bytes`：资源内存使用的量
* `kube_node_status_allocatable_memory_bytes`：节点内存量

### 1.4 KubeCPUQuotaOvercommit

集群CPU是否超分。查看 CPU 资源分配的额度是否超过进群总额度

表达式：

```
sum(kube_pod_container_resource_limits_cpu_cores{job="kube-state-metrics"})
          /
        sum(kube_node_status_allocatable_cpu_cores)
          > 1.1
```

相关指标：

* `kube_pod_container_resource_limits_cpu_cores`：资源分配的 CPU 资源额度
* `kube_node_status_allocatable_cpu_cores`：节点 CPU 总量

### 1.5 KubeMemoryQuotaOvercommit

集群超分内存，查看内存资源分配的额度是否超过进群总额度

表达式：

```
sum(kube_pod_container_resource_limits_memory_bytes{job="kube-state-metrics"})
          /
        sum(kube_node_status_allocatable_memory_bytes{job="kube-state-metrics"})
          > 1.1
```

相关指标:

* `kube_pod_container_resource_limits_memory_bytes`：资源配额内存量
* `kube_node_status_allocatable_memory_bytes`：节点内存量

### 1.6 KubeMEMQuotaExceeded

命名空间级内存资源使用的比例，关乎资源配额。当使用 request 和 limit 限制资源时，使用值和最大值还是有一点区别，当有 request 时说明最低分配了这么多资源。需要注意当 request 等于 limit 时那么说明资源已经是100%已经分配使用当监控告警发出的时候需要区分。表达式：

```
sum (kube_pod_container_resource_requests_memory_bytes{job="kube-state-metrics"} ) by (namespace)/ (sum(kube_pod_container_resource_limits_memory_bytes{job="kube-state-metrics"}) by (namespace)) > 0.8
```

相关指标:

* `kube_pod_container_resource_requests_memory_bytes`：内存资源使用量
* `kube_pod_container_resource_limits_memory_bytes`：内存资源最大值

### 1.7 KubeCPUQuotaExceeded

命名空间级 CPU 资源使用的比例，关乎资源配额。当使用 request 和 limit 限制资源时，使用值和最大值还是有一点区别，当有 request 时说明最低分配了这么多资源。需要注意当 request 等于 limit 时那么说明资源已经是100%已经分配使用当监控告警发出的时候需要区分。

表达式：

```
sum (kube_pod_container_resource_requests_cpu_cores{job="kube-state-metrics"} ) by (namespace)/ (sum(kube_pod_container_resource_limits_cpu_cores{job="kube-state-metrics"}) by (namespace)) > 0.8
```

相关指标:

* `kube_pod_container_resource_requests_cpu_cores`：CPU 使用量
* `kube_pod_container_resource_limits_cpu_cores`：CPU 限额最大值

## 2. Kubernetes 存储相关

### 2.1 KubePersistentVolumeFillingUp

PVC 容量监控

表达式：

```
kubelet_volume_stats_available_bytes{job="kubelet", metrics_path="/metrics"}
          /
        kubelet_volume_stats_capacity_bytes{job="kubelet", metrics_path="/metrics"}
          < 0.3
```

相关指标：

* `kubelet_volume_stats_available_bytes`：剩余空间
* `kubelet_volume_stats_capacity_bytes`：空间总量

### 2.2 KubePersistentVolumeFillingUp

磁盘空间耗尽预测：通过PVC资源使用6小时变化率预测 接下来4天的磁盘使用率

表达式：

```
(kubelet_volume_stats_available_bytes{job="kubelet", metrics_path="/metrics"}
            /
          kubelet_volume_stats_capacity_bytes{job="kubelet", metrics_path="/metrics"}
        ) < 0.4
        and
        predict_linear(kubelet_volume_stats_available_bytes{job="kubelet", metrics_path="/metrics"}[6h], 4 * 24 * 3600) < 0
```

相关指标:

* `kubelet_volume_stats_available_bytes`：剩余空间
* `kubelet_volume_stats_capacity_bytes`：空间总量

### 2.3 KubePersistentVolumeErrors

PV 使用状态监控。

表达式：

```
kube_persistentvolume_status_phase{phase=~"Failed|Pending",job="kube-state-metrics"}
```

相关指标：

* `kube_persistentvolume_status_phase`：PV 使用状态


## 3. kubernetes system 相关

### 3.1 KubeVersionMismatch

组件版本与当前集群版本是否有差异。对比组件版本是否有差异，默认为1 。

表达式：

```
count(count by (gitVersion) (label_replace(kubernetes_build_info{job!~"kube-dns|coredns"},"gitVersion","$1","gitVersion","(v[0-9]*.[0-9]*.[0-9]*).*")))
```

相关指标：

* `kubernetes_build_info`：获取组件信息

### 3.2 KubeClientErrors

客户端访问某些接口的错误率。

表达式：

```
(sum(rate(rest_client_requests_total{code=~"5.."}[5m])) by (instance, job)
          /
        sum(rate(rest_client_requests_total[5m])) by (instance, job))
        > 0.01
```

相关指标：

* `rest_client_requests_total`：状态码

## 4. APIServer 相关

### 4.1 KubeAPIErrorsHigh

APIServer 请求错误率。5分钟内 APIServer 请求错误率。

表达式：

```
sum(rate(apiserver_request_total{job="apiserver",code=~"5.."}[5m])) by (resource,subresource,verb)
          /
        sum(rate(apiserver_request_total{job="apiserver"}[5m])) by (resource,subresource,verb) > 0.0
```

相关指标：

* `apiserver_request_total：APIServer` 请求数

### 4.2 KubeClientCertificateExpiration

kubelet 客户端证书过期。监测证书状态30天告警和7天告警。

表达式：

```
apiserver_client_certificate_expiration_seconds_count{job="apiserver"} > 0 and on(job) histogram_quantile(0.01, sum by (job, le) (rate(apiserver_client_certificate_expiration_seconds_bucket{job="apiserver"}[5m]))) < 2592000
apiserver_client_certificate_expiration_seconds_count{job="apiserver"} > 0 and on(job) histogram_quantile(0.01, sum by (job, le) (rate(apiserver_client_certificate_expiration_seconds_bucket{job="apiserver"}[5m]))) < 604800
```

相关指标：

* `apiserver_client_certificate_expiration_seconds_count`：证书有效剩余时间

### 4.3 AggregatedAPIErrors

自定义注册的 APIServer 服务可用性监控，当检测到自定义注册的 APIServer 五分钟不用次数达到2次。

表达式：

```
sum by(name, namespace)(increase(aggregator_unavailable_apiservice_count[5m])) > 2
```

相关指标:

* `aggregator_unavailable_apiservice_count`：监测自定义注册的 APIService 不可用次数。

### 4.4 KubeAPIDown

APIserver 失联，监控 APIServer 服务，失联原因可能是服务 down 还可能是网络出现状况。

表达式：

```
absent(up{job="apiserver"} == 1)
```

## 5. kubelet 相关

### 5.1 KubeNodeNotReady

节点是否处于就绪状态。检测节点是否为就绪状态，或者可能是 kubelet 服务down 了。

表达式：

```
kube_node_status_condition{job="kube-state-metrics",condition="Ready",status="true"} == 0
```

相关指标：

* `kube_node_status_condition`：节点状态监测

### 5.2 KubeNodeUnreachable

节点状态为 Unreachable。

表达式：

```
kube_node_spec_unschedulable{job="kube-state-metrics"} == 1
```

### 5.3 KubeletTooManyPods

节点运行过多的 Pod，监测节点上运行的 Pods 数量。

表达式：

```
max(max(kubelet_running_pod_count{job="kubelet", metrics_path="/metrics"}) by(instance) * on(instance) group_left(node) kubelet_node_name{job="kubelet", metrics_path="/metrics"}) by(node) / max(kube_node_status_capacity_pods{job="kube-state-metrics"} != 1) by(node) > 0.95
```
相关指标：

* `kubelet_running_pod_count`：节点运行的 Pods 数量
* `kubelet_node_name`：节点名称
* `kube_node_status_capacity_pods`：节点可运行的最大 Pod 数量

### 5.4 KubeNodeReadinessFlapping

监测集群状态，查看集群内节点状态改变的频率。

表达式：

```
sum(changes(kube_node_status_condition{status="true",condition="Ready"}[15m])) by (node) > 2
```

### 5.5 KubeletDown

监控 kubelet 服务，down 或者网络出现问题。

表达式：

```
absent(up{job="kubelet", metrics_path="/metrics"} == 1)
```

## 6. 集群组件

### 6.1 KubeSchedulerDown

KubeScheduler 失联，监测 KubeScheduler 是否正常。

表达式：

```
absent(up{job="kube-scheduler"} == 1)
```

### 6.2 KubeControllerManagerDown

监测 KubeControllerManager 服务，Down 或者网络不通。

表达式：

```
absent(up{job="kube-controller-manager"} == 1)
```

## 7. 应用相关

### 7.1 KubePodCrashLooping

Pod 重启时间，重启时间超过3m告警。

表达式：

```
rate(kube_pod_container_status_restarts_total{job="kube-state-metrics"}[5m]) * 60 * 3 > 0
```

相关指标:

* `kube_pod_container_status_restarts_total`：重启状态0为正常

### 7.2 KubePodNotReady

Pods 没有就绪，检测 Pod 是否就绪。

表达式：

```
sum by (namespace, pod) (max by(namespace, pod) (kube_pod_status_phase{job="kube-state-metrics", phase=~"Pending|Unknown"}) * on(namespace, pod) group_left(owner_kind) max by(namespace, pod, owner_kind) (kube_pod_owner{owner_kind!="Job"})) > 0
```

相关指标：

* `kube_pod_status_phase`：Pod 状态

### 7.3 KubeDeploymentGenerationMismatch

Deployment 部署失败，Deployment 生成的资源与定义的资源不匹配。

表达式：

```
kube_deployment_status_observed_generation{job="kube-state-metrics"}
          !=
        kube_deployment_metadata_generation{job="kube-state-metrics"}
```

相关指标：

* `kube_deployment_status_observed_generation`：Deployment 生成资源数
* `kube_deployment_metadata_generation`：Deployment 定义资源数

### 7.4 KubeDeploymentReplicasMismatch

查看 Deplyment 副本是否达到预期。

表达式：

```
(
          kube_deployment_spec_replicas{job="kube-state-metrics"}
            !=
          kube_deployment_status_replicas_available{job="kube-state-metrics"}
        ) and (
          changes(kube_deployment_status_replicas_updated{job="kube-state-metrics"}[3m])
            ==
          0
        )
```

相关指标：

* `kube_deployment_spec_replicas`                     资源定义副本数
* `kube_deployment_status_replicas_available`        正在运行副本数
* `kube_deployment_status_replicas_updated `          更新的副本数

### 7.5 KubeStatefulSetReplicasMismatch

监测 StatefulSet 副本是否达到预期。

表达式：

```
(
          kube_statefulset_status_replicas_ready{job="kube-state-metrics"}
            !=
          kube_statefulset_status_replicas{job="kube-state-metrics"}
        ) and (
          changes(kube_statefulset_status_replicas_updated{job="kube-state-metrics"}[5m])
            ==
          0
        )
```

相关指标：

* `kube_statefulset_status_replicas_ready`：就绪副本数
* `kube_statefulset_status_replicas`：当前副本数
* `kube_statefulset_status_replicas_updated`：更新的副本数

### 7.6 KubeStatefulSetUpdateNotRolledOut

StatefulSet  更新失败且未回滚，对比版本号和副本数。

表达式：

```
max without (revision) (
          kube_statefulset_status_current_revision{job="kube-state-metrics"}
            unless
          kube_statefulset_status_update_revision{job="kube-state-metrics"}
        )
          *
        (
          kube_statefulset_replicas{job="kube-state-metrics"}
            !=
          kube_statefulset_status_replicas_updated{job="kube-state-metrics"}
        )
```

相关指标：

* `kube_statefulset_status_replicas`：每个 StatefulSet 的副本数。
* `kube_statefulset_status_replicas_current`：每个 StatefulSet 的当前副本数。
* `kube_statefulset_status_replicas_ready`：每个StatefulSet 的就绪副本数。
* `kube_statefulset_status_replicas_updated`：每个StatefulSet 的更新副本数。
* `kube_statefulset_status_observed_generation`：StatefulSet 控制器观察到的生成。
* `kube_statefulset_replicas`：StatefulSet 所需的副本数。
* `kube_statefulset_metadata_generation`：表示 StatefulSet 所需状态的特定生成的序列号。
* `kube_statefulset_created`：创建时间戳。
* `kube_statefulset_labels`：Kubernetes 标签转换为 Prometheus 标签。
* `kube_statefulset_status_current_revision`：指示用于按顺序(0，currentReplicas)生成 Pod 的StatefulSet 的版本。
* `kube_statefulset_status_update_revision`：指示用于按顺序 [replicas-updatedReplicas，replicas] 生成 Pod 的 StatefulSet 的版本。


### 7.7 KubeDaemonSetRolloutStuck

监测 DaemonSet 是否处于就绪状态。

表达式：

```
kube_daemonset_status_number_ready{job="kube-state-metrics"}
          /
        kube_daemonset_status_desired_number_scheduled{job="kube-state-metrics"} < 1.00
```

相关指标：

* `kube_daemonset_status_number_ready`：就绪的 DaemonSet
* `kube_daemonset_status_desired_number_scheduled`：应该调度的 DaemonSet 数量

### 7.8 KubeDaemonSetMisScheduled

DaemonSet  运行在不该运行的节点上面。

表达式：

```
kube_daemonset_status_number_misscheduled{job="kube-state-metrics"} > 0
```
相关指标：

* `kube_daemonset_status_number_misscheduled`：运行在不该运行的节点状态

### 7.9 KubeContainerWaiting

监测哪些容器是在等待状态的。

表达式：

```
sum by (namespace, pod, container) (kube_pod_container_status_waiting_reason{job="kube-state-metrics"}) > 0
```
相关指标：

* `kube_pod_container_status_waiting_reason`：容器声明周期过程中的状态，无论是创建成功还是失败都应该是0。


## 8. 节点相关

### 8.1 NodeClockNotSynchronising

主机与时间服务器失联。

表达式：

```
min_over_time(node_timex_sync_status[5m]) == 0
```

相关指标：

* `node_timex_sync_status`：同步状态。

### 8.2 NodeClockSkewDetected

本地时间偏移量。

表达式：

```
(node_timex_offset_seconds > 0.05
        and
          deriv(node_timex_offset_seconds[5m]) >= 0
        )
        or
        (
          node_timex_offset_seconds < -0.05
        and
          deriv(node_timex_offset_seconds[5m]) <= 0)
```

相关指标：

* `node_timex_offset_seconds`：误差

### 8.3 NodeHighNumberConntrackEntriesUsed

链接状态跟踪。

表达式：

```
(node_nf_conntrack_entries / node_nf_conntrack_entries_limit) > 0.75
```

相关指标：

* `node_nf_conntrack_entries`：链接状态跟踪表分配的数量
* `node_nf_conntrack_entries_limit`：表总量

### 8.4 NodeNetworkReceiveErrs

网卡接收错误量。

表达式：

```
increase(node_network_receive_errs_total[2m]) > 10
```

相关指标：

* `node_network_receive_errs_total`：接收错误总量

### 8.5 NodeNetworkTransmitErrs

网卡传输错误量。

表达式：

```
increase(node_network_transmit_errs_total[2m]) > 10
```

相关指标：

* `node_network_transmit_errs_total`：传输错误总量

### 8.6 NodeFilesystemAlmostOutOfFiles

inode 数量监测

表达式：

```
(
          node_filesystem_files_free{job="node-exporter",fstype!=""} / node_filesystem_files{job="node-exporter",fstype!=""} * 100 < 5
        and
          node_filesystem_readonly{job="node-exporter",fstype!=""} == 0
        )
```

相关指标：

* `node_filesystem_files_free`：空闲的 inode
* `node_filesystem_files`：inodes 总量

### 8.7 NodeFilesystemFilesFillingUp

inode 耗尽预测，以6小时曲线变化预测接下来24小时和4小时可能使用的 inodes。

表达式：

```
(node_filesystem_files_free{job="node-exporter",fstype!=""} / node_filesystem_files{job="node-exporter",fstype!=""} * 100 < 20
        and
          predict_linear(node_filesystem_files_free{job="node-exporter",fstype!=""}[6h], 4*60*60) < 0
        and
          node_filesystem_readonly{job="node-exporter",fstype!=""} == 0)
```

相关指标：

* `node_filesystem_files_free`：空闲的 inode
* `node_filesystem_files`：inodes 总量

### 8.8 NodeFilesystemAlmostOutOfSpace

分区容量使用率。

表达式：

```
(node_filesystem_avail_bytes{job="node-exporter",fstype!=""} / node_filesystem_size_bytes{job="node-exporter",fstype!=""} * 100 < 10
        and
          node_filesystem_readonly{job="node-exporter",fstype!=""} == 0
        )
```
相关指标：

* `node_filesystem_avail_bytes`：空闲容量
* `node_filesystem_size_bytes`：总容量

### 8.9 NodeFilesystemSpaceFillingUp

分区容量耗尽预测，以6小时曲线变化预测接下来24小时和4小时可能使用的容量。

表达式：

```
(node_filesystem_avail_bytes{job="node-exporter",fstype!=""} / node_filesystem_size_bytes{job="node-exporter",fstype!=""} * 100 < 15
        and
          predict_linear(node_filesystem_avail_bytes{job="node-exporter",fstype!=""}[6h], 4*60*60) < 0
        and
          node_filesystem_readonly{job="node-exporter",fstype!=""} == 0)
```

相关指标：

* `node_filesystem_avail_bytes`：空闲容量
* `node_filesystem_size_bytes`：总容量


## 9. Etcd 相关

### 9.1 Etcdlived

etcd 存活检测。

表达式：

```
up{job="etcd"} < 1
```

### 9.2 EtcdCluseterUnavailable

etcd 集群健康检查，down 数量大于集群可允许故障数量。

表达式：

```
count(up{job="etcd"} == 0) > (count(up{job="etcd"}) / 2 - 1)
```

### 9.3 EtcdLeaderCheck

检查 leader。

表达式：

```
max(etcd_server_has_leader) != 1
```

### 9.4 EtcdBackendFsync

etcd io 监测，后端提交 延时。

表达式：

```
histogram_quantile(0.99, sum(rate(etcd_disk_backend_commit_duration_seconds_bucket[5m])) by (instance, le)) > 100
```

### 9.5 EtcdWalFsync

etcd io 监测，文件同步到磁盘延时。

表达式：

```
histogram_quantile(0.99, sum(rate(etcd_disk_wal_fsync_duration_seconds_bucket[5m])) by (instance, le)) > 100
```

### 9.6 EtcdDbSize

检测数据库大小。

表达式：

```
etcd_debugging_mvcc_db_total_size_in_bytes/1024/1024 > 1024
```

### 9.7 EtcdGrpc

Grpc 调用速率。表达式：

```
sum(rate(grpc_server_handled_total{grpc_type="unary"}[1m])) > 100
```

## 10. CoreDNS 相关


### 10.1 DnsRequest

DNS 查询速率，每分钟查询超过100告警。

表达式：

```
sum(irate(coredns_dns_request_count_total{zone !="dropped"}[1m])) > 100
```

相关指标：

* `coredns_dns_request_count_total`：总查询数

### 10.2 DnsRequestFaild

异常查询，异常状态码，不是 NOERROR。

表达式：

```
irate(coredns_dns_response_rcode_count_total{rcode!="NOERROR"} [1m]) > 0
```
相关指标：

* `coredns_dns_response_rcode_count_total`：查询返回状态码

DNS-Rcode：

DNS-Rcode 作为 DNS 应答报文中有效的字段，主要用来说明 DNS 应答状态，是排查域名解析失败的重要指标。通常常见的 Rcode 值如下：

* Rcode 值为0，对应的 DNS 应答状态为 NOERROR，意思是成功的响应，即这个域名解析是成功
* Rcode 值为2，对应的 DNS 应答状态为 SERVFAIL，意思是服务器失败，也就是这个域名的权威服务器拒绝响应或者响应 REFUSE，递归服务器返回 Rcode 值为 2 给 CLIENT
* Rcode 值为3，对应的 DNS 应答状态为 NXDOMAIN，意思是不存在的记录，也就是这个具体的域名在权威服务器中并不存在
* Rcode 值为5，对应的 DNS 应答状态为 REFUSE，意思是拒绝，也就是这个请求源IP不在服务的范围内


### 10.3 DnsPanic

DNS 恐慌值，可能收到攻击。

表达式：

```
irate(coredns_panic_count_total[1m]) > 100
```




