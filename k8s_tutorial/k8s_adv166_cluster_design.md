# 如何设计永不宕机的 K8s 集群 - 2025

## 1 控制平面高可用设计

### 1 多Master节点部署

**跨可用区部署优化：**

AWS示例：使用`topology.kubernetes.io/zone`标签强制etcd节点分布在3个AZ。

**性能调优参数：**

```
# etcd配置（/etc/etcd/etcd.conf）
ETCD_HEARTBEAT_INTERVAL="500ms"  
ETCD_ELECTION_TIMEOUT="2500ms"  
ETCD_MAX_REQUEST_BYTES="157286400"  # 提高大请求吞吐量  
```

**API Server负载均衡实战：**

```
# Nginx配置示例（健康检查与熔断）
upstream kube-apiserver {
  server 10.0.1.10:6443 max_fails=3 fail_timeout=10s;
  server 10.0.2.10:6443 max_fails=3 fail_timeout=10s;
  check interval=5000 rise=2 fall=3 timeout=3000 type=http;
  check_http_send "GET /readyz HTTP/1.0\r\n\r\n";
  check_http_expect_alive http_2xx http_3xx;
}
```


### 2. etcd集群深度调优

etcd的写入性能直接影响集群稳定性，需根据业务负载计算所需节点数：

```
所需etcd节点数 = (预期写入QPS × 平均请求大小) / (单节点最大吞吐量) + 冗余系数  
```

**示例：**

* 单节点吞吐量：1.5MB/s（SSD磁盘）
* 业务负载：2000 QPS，每个请求10KB → 2000×10KB=20MB/s
* 计算结果：20/1.5≈13节点 → 实际部署5节点（3工作节点+2冗余）

**调优参数：**

```
# /etc/etcd/etcd.conf  
# 增加网络和磁盘吞吐  
ETCD_HEARTBEAT_INTERVAL="500ms"  
ETCD_ELECTION_TIMEOUT="2500ms"  
ETCD_SNAPSHOT_COUNT="10000"  # 提高快照频率  
```

**监控与告警规则：**

```
# 主节点切换频繁告警
increase(etcd_server_leader_changes_seen_total[1h]) > 3  
# 写入延迟过高告警  
histogram_quantile(0.99, rate(etcd_disk_wal_fsync_duration_seconds_bucket[5m])) > 1s  
```

**灾难恢复命令：**

```
# 从快照恢复etcd  
ETCDCTL_API=3 etcdctl snapshot restore snapshot.db --data-dir /var/lib/etcd-new
```

## 2 工作节点高可用设计

### 3. Cluster Autoscaler高级策略

**分优先级扩容：为关键服务预留专用节点池（如GPU节点）。**

```
# 节点组配置（AWS EKS）
- name: gpu-nodegroup  
  instanceTypes: ["p3.2xlarge"]  
  labels: { node.kubernetes.io/accelerator: "nvidia" }  
  taints: { dedicated=gpu:NoSchedule }  
  scalingConfig: { minSize: 1, maxSize: 5 }  
```

**HPA自定义指标示例：**

```
# 基于Prometheus的QPS扩缩容  
metrics:  
- type: Pods  
  pods:  
    metric:  
      name: http_requests_per_second  
    target:  
      type: AverageValue  
      averageValue: 500  
```

### 4. Pod调度深度策略

**拓扑分布约束：确保Pod均匀分布至不同硬件拓扑**。

```
spec:  
  topologySpreadConstraints:  
  - maxSkew: 1  
    topologyKey: topology.kubernetes.io/zone  
    whenUnsatisfiable: DoNotSchedule  
```
 
### 5. 基于污点的精细化调度

场景：为AI训练任务预留GPU节点，并防止普通Pod调度到GPU节点：

```
# 节点打标签  
kubectl label nodes gpu-node1 accelerator=nvidia  

# 设置污点  
kubectl taint nodes gpu-node1 dedicated=ai:NoSchedule  

# Pod配置容忍度 + 资源请求  
spec:  
  tolerations:  
    - key: "dedicated"  
      operator: "Equal"  
      value: "ai"  
      effect: "NoSchedule"  
  containers:  
    - resources:  
        limits:  
          nvidia.com/gpu: 1
```

## 3、网络高可用设计

### 6. Cilium eBPF网络加速

Cilium eBPF网络加速

* 优势：减少50%的CPU开销，支持基于eBPF的细粒度安全策略。
* 部署步骤：

```
helm install cilium cilium/cilium --namespace kube-system \  
  --set kubeProxyReplacement=strict \  
  --set k8sServiceHost=API_SERVER_IP \  
  --set k8sServicePort=6443  
```

验证：

```
cilium status  
# 应显示 "KubeProxyReplacement: Strict"  
```

### 7. Ingress多活架构

全局负载均衡配置（AWS示例）：

```
resource "aws_globalaccelerator_endpoint_group" "ingress" {  
  listener_arn = aws_globalaccelerator_listener.ingress.arn  
  endpoint_configuration {  
    endpoint_id = aws_lb.ingress.arn  
    weight      = 100  
  }  
}  
```

## 4、存储高可用设计

### 8. Rook/Ceph生产级配置

存储集群部署：

```
apiVersion: ceph.rook.io/v1  
kind: CephCluster  
metadata:  
  name: rook-ceph  
spec:  
  dataDirHostPath: /var/lib/rook  
  mon:  
    count: 3  
    allowMultiplePerNode: false  
  storage:  
    useAllNodes: false  
    nodes:  
    - name: "storage-node-1"  
      devices:  
      - name: "nvme0n1"  
```

### 9. Velero跨区域备份实战

定时备份与复制：

```
velero schedule create daily-backup --schedule="0 3 * * *" \  
  --include-namespaces=production \  
  --ttl 168h  
  
velero backup-location create secondary --provider aws \  
  --bucket velero-backup-dr \  
  --config region=eu-west-1  
```

### 10. 灾难恢复：Velero跨区域备份策略

```
velero install \  
  --provider aws \  
  --plugins velero/velero-plugin-for-aws:v1.5.0 \  
  --bucket velero-backups \  
  --backup-location-config region=us-west-2 \  
  --snapshot-location-config region=us-west-2 \  
  --use-volume-snapshots=false \  
  --secret-file ./credentials-velero  

# 添加跨区域复制规则  
velero backup-location create secondary \  
  --provider aws \  
  --bucket velero-backups \  
  --config region=us-east-1  
```

场景：将AWS us-west-2的备份自动复制

## 5 监控与日志

### 11. Thanos长期存储优化

**公式：计算Thanos的存储分块策略**

```
存储周期 = 原始数据保留时间（如2周） + 压缩块保留时间（如1年）  
存储成本 = 原始数据量 × 压缩比（约3:1） × 云存储单价  
```

**分层存储配置：**

```
# thanos-store.yaml  
args:  
  - --retention.resolution-raw=14d  
  - --retention.resolution-5m=180d  
  - --objstore.config-file=/etc/thanos/s3.yml  
```

**多集群查询：**

```
thanos query \  
  --http-address 0.0.0.0:10902 \  
  --store=thanos-store-01:10901 \  
  --store=thanos-store-02:10901 
```

### 12. EFK日志过滤规则：

```
# Fluentd配置（提取Kubernetes元数据）
<filter kubernetes.**>  
  @type parser  
  key_name log  
  reserve_data true  
  <parse>  
    @type json  
  </parse>  
</filter>  
```

## 6 安全与合规

### 13. OPA Gatekeeper策略库

**禁止特权容器**：

```
apiVersion: constraints.gatekeeper.sh/v1beta1  
kind: K8sPSPPrivilegedContainer  
spec:  
  match:  
    kinds: [{ apiGroups: [""], kinds: ["Pod"] }]  
  parameters:  
    privileged: false  
```
 
### 14. 运行时安全检测：

```
# Falco检测特权容器启动  
falco -r /etc/falco/falco_rules.yaml \  
  -o json_output=true \  
  -o "webserver.enabled=true"  
```

###  15. 基于OPA的镜像扫描准入控制

```
# image_scan.rego  
package kubernetes.admission  

deny[msg] {  
  input.request.kind.kind == "Pod"  
  image := input.request.object.spec.containers[_].image  
  vuln_score := data.vulnerabilities[image].maxScore  
  vuln_score >= 7.0  
  msg := sprintf("镜像 %v 存在高危漏洞（CVSS评分 %.1f）", [image, vuln_score])  
} 
```

策略：禁止使用存在高危漏洞的镜像：

## 7 灾难恢复与备份

### 16. 多集群联邦流量切分：

```
apiVersion: types.kubefed.io/v1beta1  
kind: FederatedService  
metadata:  
  name: frontend  
spec:  
  placement:  
    clusters:  
      - name: cluster-us  
      - name: cluster-eu  
  trafficSplit:  
    - cluster: cluster-us  
      weight: 70  
    - cluster: cluster-eu  
      weight: 30  
```

### 17. 混沌工程全链路测试：

```
apiVersion: chaos-mesh.org/v1alpha1  
kind: NetworkChaos  
metadata:  
  name: simulate-az-failure  
spec:  
  action: partition  
  mode: all  
  selector:  
    namespaces: [production]  
    labelSelectors:  
      "app": "frontend"  
  direction: both  
  duration: "10m"
```

### 18. 混沌工程：模拟Master节点故障

使用Chaos Mesh测试控制平面韧性：

```
apiVersion: chaos-mesh.org/v1alpha1  
kind: PodChaos  
metadata:  
  name: kill-master  
spec:  
  action: pod-kill  
  mode: one  
  selector:  
    namespaces: [kube-system]  
    labelSelectors:  
      "component": "kube-apiserver"  
  scheduler:  
    cron: "@every 10m"  
  duration: "5m"  
```

观测指标：

* API Server恢复时间（应<1分钟）
* 工作节点Pod是否正常调度

## 8 成本控制

### 19. Kubecost多集群预算分配

配置示例：

```
apiVersion: kubecost.com/v1alpha1  
kind: Budget  
metadata:  
  name: team-budget  
spec:  
  target:  
    namespace: team-a  
  amount:  
    value: 5000  
    currency: USD  
  period: monthly  
  notifications:  
    - threshold: 80%  
      message: "团队A的云资源消耗已达预算80%"  
```

## 9 自动化

### 20. Argo Rollouts金丝雀发布

分阶段灰度策略：
 
```
apiVersion: argoproj.io/v1alpha1  
kind: Rollout  
spec:  
  strategy:  
    canary:  
      steps:  
        - setWeight: 10%  
        - pause: { duration: 5m }  # 监控业务指标  
        - setWeight: 50%  
        - pause: { duration: 30m } # 观察日志和性能  
        - setWeight: 100%  
  analysis:  
    templates:  
      - templateName: success-rate  
    args:  
      - name: service-name  
        value: my-service  
```
 
**自动回滚条件：当请求错误率 > 5%时终止发布**。

### 总结

关键性能指标：

* 控制平面：API Server P99延迟 < 500ms
* 数据平面：Pod启动时间 < 5s（冷启动）
* 网络：跨AZ延迟 < 10ms


### 工具链推荐

* 网络诊断：Cilium Network Observability
* 存储分析：Rook Dashboard
* 成本监控：Kubecost + Grafana
* 策略管理：OPA Gatekeeper + Kyverno
