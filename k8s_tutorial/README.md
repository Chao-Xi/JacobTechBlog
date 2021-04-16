# K8S Tutorial from Basic to Adv. to Real World Analysis

![Alt Image Text](images/readme2.jpg "headline image")

## K8S基础(K8S Basic Tutorial)

### Part One: Docker Introduction

1. [容器介绍 (Docker Introduction)](k8s_basic1.md)
2. [容器网络，镜像管理，Docker的优势 (Docker network, Image management and Advantage)](k8s_basic2.md)



### Part Two: K8S Basic Understanding

1. [kubernetes介绍以及核心组件 (K8S Introduction and Core Components)](k8s_basic3.md)
2. [kubernetes基础架构和设计理念 （K8S Basic Structure and Design Concept)](k8s_basic4.md)
3. [Kubernetes基本对象 (K8S Basic object: Container, Pod, Node, Namespace, Service, Label, Annotations)](k8s_basic5.md)


## Kubernetes对象详解(K8S Objects Analysis)

1. [Pod控制器 (K8S pod controller)](k8s_basic6.md)
2. [Pod基础与属性介绍 (K8S pod attributes)](k8s_basic7.md)
3. [静态pod控制器与管理 (K8S Statefulset Pods and StatefulSet)](k8s_basic8.md)
4. [Namespace详解 (K8S Namespace)](k8s_basic9.md)
5. [Node详解 (K8S Node)](k8s_basic10.md)
6. [服务发现与负载均衡 (K8S Service, Endpoints, Headless service, Ingress Controller)](k8s_basic11.md)
7. [Kubernetes存储卷 (K8S Volume)](k8s_basic12.md)
8. [Deployment详解 (K8S Deployment)](k8s_basic13.md)
9. [Kubernetes Job](k8s_basic14.md)
10. [Kubernetes ConfigMap](k8s_basic15.md)
11. [Kubernetes Secret](k8s_basic16.md)
12. [Service Account, 授权, Pod Security Policies, Hostpath访问白名单, SELinux (K8S Service Account, Role, Security Context, PSP, Hostpath white list, SELinux)](k8s_basic17.md)
13. [Resource Quotas, LimitRange, Horizontal Pod Autoscaling](k8s_basic18.md)
14. [Network Policy, Namespace & Pod Isolation, Ingress, PodPreset, ThirdPartyResources](k8s_basic19.md)



## Kubernetes高阶,设计和实现(K8S Advanced Design)

1. [ECTD](k8s_basic20.md)
2. [API Server](k8s_basic21.md)
3. [kube-scheduler](k8s_basic22.md)
4. [Kubelet](k8s_basic23.md)
5. [kube-proxy, kube-dns, Federation](k8s_basic24.md)
6. [高可用(99.999),高可用性方案 (HA and HA Strategy)](k8s_basic25.md)
7. [服务发现(LB, DNS LB, IP LB, K8S service)](k8s_basic26.md)
8. [监控和日志(Log system and Monitoring system)](k8s_basic27.md)
9. [建立持续交付的服务体系 (Continuous Delivery System)](k8s_basic28.md)



## Kubernetes案例分析(K8S Case Analysis)

1. [声明式集群管理](k8s_ins1_cluster.md)
2. [存储管理](k8s_ins2_pv.md)
3. [确保用户高可用](k8s_ins3_hitch.md)
4. [网络分析](k8s_ins4_net.md)
5. [Ingress实践](k8s_ins5_ingress.md)



## K8S进阶课程(K8S Adv. Tutorial)

1. [kubernetes interview questions (Keep Updating)](k8s_adv33_interview.md)
3. [Kubernetes的11大基本概念及重要概念性理解](k8s_adv52_Common_knowledge.md)
3. [Kubernetes 2018 年度简史](k8s_adv42_dev2018.md)
4. [Kubernetes 1.14 正式发布，Windows节点生产级支持！](k8s_adv46_114.md)
5. [CKAD 模拟考试](k8s_adv86_ckad.md)
6. [CKAD Exercises](k8s_adv86_ckad2.md)

### 深入理解 容器化和 `Docker`

1. [从进程说容器](k8s_container1.md)
2. [Docker 镜像分析工具 Dive](k8s_container2_dive.md)

### K8S 生产架构

1. [7 款你不得不了解的开源云监控工具](k8s_arch1_monitor7.md) 
2. [Kubernetes 部署策略详解](k8s_adv41_deploy.md)
3. [Kubernetes CNI网络最强对比：Flannel、Calico、Canal和Weave](k8s_adv47_CNI.md)
4. [微服务需要拆分到什么程度？](k8s_arch2_micro_service.md)
5. [在 Kubernetes 上运行 Kafka 合适吗？](k8s_adv68_kafka.md)
6. [Kubernetes 零宕机滚动更新](k8s_adv87_rolling-update.md)

#### Kubernetes + JenkinsX + Istio渐进式交付
1. [Kubernetes 中的渐进式交付, 蓝绿部署和金丝雀部署: shipper, Istio, Flagger](k8s_adv54_release.md)
2. [使用 Jenkins X 渐进式交付](k8s_adv56_jenkinsX.md)
3. [使用 Jenkins X 渐进式交付：自动化金丝雀部署](k8s_adv57_Auto_Canary.md)

### K8S 操作

#### [提高 kubectl 使用生产力](k8s_skill7_kubectl_improve.md) 😍

* 命令自动补全安装[Linux/Mac(**Upgrading Bash on macOS**)]
* 快速查找资源 `kubectl explain`
* 使用自定义列格式化输出 `-o custom-columns=<header>:<jsonpath>`
* `JSONPath` 表达式
* 切换集群和命名空间
* 使用插件扩展 `kubectl`

#### [Kubernetes Deployment 故障排查常见方法😍](k8s_adv84_deployment_diagnostic.md) 
#### [Kubectl 常用命令大全](k8s_adv95_commands.md)

#### 使用技巧

1. [Kubectl Cheatsheet / kubectl命令技巧大全](k8s_adv27_kubectl_Cheatsheet.md)  😍
2. [使用`etcdctl`访问`kubernetes`数据](k8s_skill2_etcdctl.md)
3. [POD内部使用技巧](k8s_skill3_skillset.md)
4. [Kubernetes API 资源应该使用哪个 Group 和 Version?](k8s_adv31_api_group_version.md)
5. [jsonnet 和 Kubernetes](k8s_adv32_jsonnet.md)
6. [CentOS 7 ETCD集群配置大全](k8s_adv83_etcd_centos7.md)
7. [使用编程语言描述 Kubernetes 应用 - `cdk8s(python)`](k8s_adv96_cdk8s.md)
8. [tcpdump 简明教程](k8s_adv97_tcpdump.md)
9. [Connecting to a worker node using SSH](k8s_adv98_Connecting_workernode_SSH.md)
10. [Kubernetes 中的垃圾回收](k8s_adv102_garbage_collection.md)
11. [为 Kubernetes 节点发布扩展资源](k8s_adv103_resource_expand.md)
12. [Docker 和 Kubernetes：root 与特权](k8s_adv115_root.md)

#### 故障排除

1. [Kubernetes service中的故障排查](k8s_skill1_bugfix1.md)
2. [Kubernetes 网络故障常见排查方法](k8s_adv55_network_troubleshooting.md)
3. [Kubernetes 处理容器数据磁盘被写满](k8s_skill4_desc_full.md)
4. [Kubernetes 问题定位技巧：分析 ExitCode](k8s_skill5_exit_code.md)
5. [Kubernetes 最佳实践：处理内存碎片化](k8s_skill6_slan_cache.md)
6. [Kubernetes 删除卡在 `Terminating`状态的 `namespace`](k8s_skill8_clean_ns.md)
7. [Kubernetes 之`Docker`容器数据写满磁盘解决方法](k8s_skill9_desc_full2.md)

#### 编写模板

* [使用 `Kustomize` 配置 `Kubernetes` 应用](k8s_adv72_Kustomize.md)
* [使用 Kustomize 定制 Helm Chart](k8s_adv104_Kustomize_helm.md)

### 深入理解 POD

1. [使用YAML文件创建Kubernetes Deployment](k8s_adv0_yaml.md)
2. [Kubernetes Pod 工作流](k8s_adv1_pod.md)
3. [静态 Pod](k8s_adv20_static_pod.md)
4. [Pod Hook(PostStart & PreStop)](k8s_adv21_pod_hook.md)
5. [Pod 的生命周期](k8s_adv43_podlifecycle.md)
6. [健康检查(liveness probe & readiness probe)](k8s_adv22_health_inspect.md)
7. [Pod Init Container 详解](k8s_adv9_pod_init_container.md)

### etcd 

1. [etcd 集群大小优化选择](k8s_adv61_etcd_think.md)

### K8S 调度器

1. [Kubernetes 调度器介绍](k8s_adv25_kube-scheduler.md)
2. [理解 Kubernetes 的亲和性调度](k8s_adv7_Affinity_Selector.md)
3. [Kubernetes 集群均衡器 `Descheduler`](k8s_adv92_Descheduler.md)

### K8S and Cloud

1. [kube2iam overview, features and install on production](k8s_adv53_kube2iam.md)
2. [BB AWS Cluster Autoscaler](k8s_adv59_aws_cluster_autoscaler.md)

### 常用对象操作:

1. [学习使用 Kubernetes 中的 Service 对象](k8s_adv2_service.md)
2. [Kubernetes Deployment滚动升级](k8s_adv3_Deployment.md)
3. [kubernetes PodPreset 的使用](k8s_adv4_PodPreset.md)
4. [kubernetes ConfigMap 和 Secrets](k8s_adv5_ConfigMap_Secrets.md)
5. [Kubernetes Downward API 基本用法](k8s_adv6_Downward_API.md)
6. [kubernetes 的资源配额控制器](k8s_adv8_resource_quotation.md) 
7. [用Replication Controller、Replica Set 管理Pod](k8s_adv10_RC_RS.md)
8. [Job和CronJob 的使用方法](k8s_adv11_job_cronjob.md)
9. [Kubernetes 服务质量 `Qos` 解析 `Pod` 资源 `requests` 和 `limits` 如何配置?](k8s_adv19_Qos.md)
10. [`DaemonSet` 与 `StatefulSet` 的使用](k8s_adv24_DaemonSet_StatefulSet.md)
11. [Kubernetes Secret 资源对象使用方法](k8s_adv12_secret.md)
12. [两种方法上手`ConfigMap`(环境变量/挂载文件)](k8s_adv85_two_configmaps.md)
13. [`Kubernetes Namespace`命名空间详解](k8s_adv44_namespace.md)
14. [`Kubelet` 状态更新机制](k8s_adv58_kubelet.md)
15. [如何在`Kubernetes`实现GPU调度及共享](k8s_adv64_GPU_share.md)
16. [深入理解 `Kubernetes Admission Webhook`](k8s_adv65_admission_webhook.md)
17. [ConfigMap三种使用方法](k8s_adv89_cm_typical_ways.md)
18. [图解 K8S 控制器 Node 生命周期管理](k8s_adv90_node_mgm.md)

#### K8S授权和访问&证书

1. [Kubernetes RBAC 详解](k8s_adv13_RBAC.md)
2. [通过 GitHub OAuth 和 Dex 访问 Kubernetes 集群](k8s_adv69_oauth_dex.md)
3. [这些用来审计 Kubernetes RBAC 策略](k8s_adv74_BRAC_strategy.md)
4. [Kubernetes Pod 安全策略(PodSecurityPolicy,PSP)配置](k8s_adv76_psp.md)
5. [Kubernetes 集群安全机制详解](k8s_adv91_k8s_sec_policy.md)
6. [恢复全部清空的 Kubernetes 证书文件](k8s_adv112_recover_certificates.md)
7. [Kubernetes 配置更新那些事](k8s_adv113_config_update.md)

### 持久化存储:

#### (1) 使用指南：

1. [深入浅出聊聊Kubernetes存储（一）：详解Kubernetes存储关键概念](k8s_adv48_Storage1.md)
2. [深入浅出聊聊Kubernetes存储（二）：搞定持久化存储](k8s_adv48_Storage2.md)
3. [云原生存储详解：容器存储与 K8s 存储卷完整介绍](k8s_adv101_k8s_docker_vol.md)

#### (2) 常用方法：

1. [kubernetes 持久化存储(一): PV 和 PVC 的使用](k8s_adv14_pv1.md)
2. [kubernetes 持久化存储(二): StorageClass 的使用](k8s_adv14_pv2.md)
3. [**Kubernetes 中 `PV` 和 `PVC` 的状态变化**](k8s_adv100_pv_pvc.md)
4. [Pod 中挂载单个文件的方法 subpath](k8s_adv15_subpath.md)
5. [Kubernetes Local Persistent Volume](k8s_adv37_local_persistent_volume.md)
6. [3种K8S存储：emptyDir、hostPath、local](k8s_adv45_3OthersStorage.md)
7. [在 `Kubernetes v1.14` 中，如何动态配置本地存储？](k8s_adv60_local_pv.md)
8. [K8s 的软件定义存储解决方案(Software-Defined Storage:GlusterFS/ScaleIO/Quobyte)](k8s_adv62_sds.md)
9. [使用s3(minio)为kubernetes提供pv存储](k8s_adv109_s3_minio_pv.md)

### 服务发现及网络模型解析

#### (0)[ Kubernetes 网络模型解析](k8s_adv67_network_model.md)

1. 容器和容器之间的网络
2. `Pod` 与 `Pod` 之间的网络
   * 同一个 `Node` 中的 `Pod` 之间的一次通信
   * 不同 Node 中的 Pod 之间通讯 (`VXLAN / Flannel` )
3. `Pod` 与 `Service` 之间的网络
  * `netfilter`
  * `iptables` 
  * `IPVS`
  * `Pod` 到 `Service` 的一个包的流转
  * `Service` 到 `Pod` 的一个包的流转
4. Internet 与 Service 之间的网络
  * `Kubernetes` 流量到 `Internet` 
  * `Node` 到 `Internet`
  * `Internet` 到 `Kubernetes` (`NodePort / LoadBalancer / Ingress Controller`)
  
#### (1) 内部服务发现:

1. [内部服务发现 `kube-proxy` 实现原理](k8s_adv36_kube_proxy.md)
2. [如何在 `kubernetes` 中开启 `ipvs` 模式](k8s_adv26_ipvs.md)
3. [集群内部服务发现之 DNS](k8s_adv16_dns.md)
4. [详解 DNS 与 CoreDNS 的实现原理](k8s_adv40_CoreDNS.md)
5. [`kube-proxy` 工作模式分析 `Iptables VS Ipvs`](k8s_adv71_kube_proxy_adv.md)
6. [K8S 之 Headless 浅谈](k8s_adv93_svc_headless.md)
7. [Kubernetes 中的 DNS 查询(CoreDNS)](k8s_adv94_DNS_check.md)
8. [给 Pod 添加 DNS 记录](k8s_adv110_pod_dns.md)
9. [理解 Linux 网络命名空间 network namespace](k8s_adv111_net_namespaces.md)

#### (2) 外部服务发现

1. [外部服务发现之 ingress(一): traefik 的安装使用](k8s_adv17_ingress1.md)
2. [外部服务发现之 ingress(二): Ingress TLS 和 PATH 的使用](k8s_adv18_ingress2.md)
3. [Kubernetes Ingress 使用 Let's Encrypt 自动化 HTTPS](k8s_adv30_ingress_auto_https.md)
4. [Traefik 2.0 正式版发布及安装与使用](k8s_adv77_traefik2.0.md) 
5. [`Traefik` 团队开源的轻量级 `Service Mesh` 工具 `Maesh`](k8s_adv78_trarfik_mesh.md)
5. [如何保护对外暴露的 Kubernetes 服务](k8s_adv50_Ingress_Protection.md)
6. [nginx-ingress 的安装使用](k8s_adv51_Nginx_Ingress.md)
7. [ingress-nginx 中 Rewrite 的使用](k8s_adv82_ingress_nginx_rewrite.md)
8. [kubernetes 办公环境下网络互通方案](k8s_adv38_Connect_Offce_Network.md)
9. [Ingress vs Load Balancer](k8s_adv66_elbVSingress.md)
10. [使用 inlets 和 kubernetes 访问本地服务](k8s_adv79_inlets.md)
11. [获取客户端访问真实 IP](k8s_adv88_get_ip.md)
12. [图解 Kubernetes Ingress 完整详解](k8s_adv105_ingress_detail.md)
13. [图解 Kubernetes Service —— 技术详解](k8s_adv106_svc_scratch.md)
14. [图解 Istio](k8s_adv107_istio_scratch.md)
15. [Kubernetes Service APIs 介绍](k8s_adv108_serviceapis.md)

### K8S 伸缩问题

1. [k8s自动伸缩那些事](k8s_adv28_hpa_vpa.md)
2. [Pod 自动扩缩容(HPA: Horizontal Pod Autoscaling)](k8s_adv23_HPA.md)
3. [6个与弹性伸缩、调度相关的Kubernetes附加组件](k8s_adv49_AS_plugins.md)
4. [Kubernetes 预测性集群伸缩](k8s_adv70_CAC_prediction.md)
5. [Kubernetes HPA 使用详解](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_dev/prometheus/38k8s_hpa_metricsserver.md)
6. [改善 Kubernetes 上的 JVM 预热问题](k8s_adv114_jvm.md)

### K8S 深度设计理念

1. [Kubelet 调度资源预留(如何预防雪崩)](k8s_adv29_kubelet_resource.md)
2. [Kubernetes与容器设计模式](k8s_adv35_design_pattern.md)
3. [微服务中的Sidecar设计模式解析 & Kubernetes日志采集Sidecar模式介绍](k8s_adv34_sidecar.md)
4. [在 `Kubernetes` 中配置 `Container Capabilities`](k8s_adv80_container_capabilities.md)


### K8S 安全性问题

1. [浅谈Docker的安全性支持(一)](k8s_security1_docker1.md)
2. [浅谈Docker的安全性支持(二)](k8s_security1_docker2.md)
3. [Kubernetes集群节点被入侵挖矿案例与发现解决问题](k8s_security2_invasive_bitcoin_mining.md)



### K8S 其他工具

1. [安装使用 360 开源 K8S Dashboard: `Wayne`](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_dev/prometheus/9Adv_Wayne_dashboard.md) 
2. [Grafana 日志聚合工具 Loki](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_dev/prometheus/12Adv_Grafana_Loki.md)
3. [`Kubernetes Operator` 快速入门教程](k8s_adv63_operator.md)
4. [在现有 `Kubernetes` 集群上安装 `KubeSphere`](k8s_adv73_KubeSphere.md)
5. [VMWare 开源的 `Kubernetes` 可视化工具 `Octant`](k8s_adv75_octant_dashboard.md)
6. [使用 `OAM` and `Rudr` 部署 Kubernetes 应用](k8s_adv81_OAM_Rudr.md)


### K8S Q&A

1. [K8S Issues List](k8s_QA_sum.md)
2. [K8S Q&A Chapter one](k8s_QA1.md)
3. [K8S Q&A Chapter two](k8s_QA2.md)
4. [K8S Q&A Chapter three](k8s_QA3.md)
5. [K8S Q&A Chapter Four](k8s_QA4.md)
6. [K8S Q&A Chapter Five](k8s_QA5.md)
7. [K8S Q&A Chapter Six](k8s_QA6.md)

### K8S 生产案例

1. [kubernetes生产案例之阿里云游戏业务分析](k8s_prod1_AliGame.md)
2. [民生银行智能运维项目在容器云平台的部署](k8s_prod2_CMBC.md)

### google (gke) Kubernetes Best Practice

1. [Building Small Containers](k8s_bp1_small_container.md)
2. [Organizing Kubernetes with Namespaces](k8s_bp2_namespace.md)
3. [Kubernetes Health Checks with Readiness and Liveness Probes ](k8s_bp3_probes.md)
4. [Setting Resource Requests and Limits in Kubernetes](k8s_bp4_resouce_request_limit.md)
5. [K8S Terminating with Grace](k8s_bp5_grace_termination.md)
6. [K8S Mapping External Services](k8s_bp6_mapping_external_service.md)
7. [Upgrading your Cluster with Zero Downtime](k8s_bp7_upgrading_cluster.md)



### Daily Operations

[k8s command](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#-strong-getting-started-strong-)

```
$ kubectl get pods -o custom-columns=POD:metadata.name,NODE:spec.nodeName --sort-by spec.nodeName -n kube-system
POD                              NODE
kube-dns-7dc9f9f4c5-2srbc        ubertest-worker-4xlarge-hnc2s
```

```
$ kubectl get deploy -n=namespace -o=yaml --export
Flag --export has been deprecated, This flag is deprecated and will be removed in future.
```

```
$ kubectl top nodes
$ kubectl exec -it pod-name /bin/bash -n=namespace
```

**Show All nodes and labels**

```
$ for item in $( kubectl get node --output=name); do printf "Labels for %s\n" "$item" | grep --color -E '[^/]+$' && kubectl get "$item" --output=json | jq -r -S '.metadata.labels | to_entries | .[] | " \(.key)=\(.value)"' 2>/dev/null; printf "\n"; done

```

**Show All nodes and taints**

```
$ kubectl get nodes -o go-template='{{printf "%-50s %-12s\n" "Node" "Taint"}}{{- range .items}}{{- if $taint := (index .spec "taints") }}{{- .metadata.name }}{{ "\t" }}{{- range $taint }}{{- .key }}={{ .value }}:{{ .effect }}{{ "\t" }}{{- end }}{{- "\n" }}{{- end}}{{- end}}'
Node                                               Taint
ubertest-management-bmxwx	ismanagement=1:NoExecute	ismanagement=1:NoSchedule
ubertest-management-stzq9	ismanagement=1:NoSchedule	ismanagement=1:NoExecute

$ kubectl get nodes -o json | jq ".items[]|{name:.metadata.name, taints:.spec.taints}"
```


## 包管理工具 HELM

![Alt Image Text](images/boat.gif "headline image")

* [在Kubernetes平台上如何使用Helm部署以获得最佳体验？](k8s_helm18_best_practice.md)

### HELM 基本使用

1. [Helm安装使用](k8s_helm1_setup.md)
2. [Helm 的基本使用](k8s_helm2_application.md)
3. [Helm monitor 插件](k8s_helm9_monitor.md)
4. [`Chart Debug`调试模板](k8s_helm15_chart_debug.md)
5. [Helm V2 迁移到 V3 版本](k8s_helm17_helmv3.md)

### HELM Chart 管理

1. [Chart Repository 存储库指南](k8s_helm13_Charts_Repo.md)
   * [创建 `chart` 库 / 托管 `chart` 库 / 管理 `chart` 库 / 同步 `chart` 库]
2. [Helm Chart](k8s_helm12_Charts.md)
   * [`Chart` 文件结构 / `Chart.yaml` 文件 / `Chart` 依赖关系 / 通过 `charts/` 目录手动管理依赖性 / 模板 `Templates` 和值 `Values` / 使用 `Helm` 管理 `chart`]
3. [`Chart` 测试](k8s_helm14_Chart_Test.md)


### 开发 CHART 模板

1. [Helm 模板之内置函数和Values](k8s_helm3_func_value.md)
   * [`Charts/`/ 定义 `chart`/ 创建模板 / 添加一个简单的模板 / 内置对象/ `values` 文件] 
2. [Helm 模板之模板函数与管道](k8s_helm4_template_pipe.md)
   * [模板函数/ 管道 /  `default` 函数 /  运算符函数]
3. [Helm 模板之控制流程](k8s_helm5_process.md)
   * [`if/else` 条件 / 控制空格 / 使用 `with` 修改范围/ `range` 循环 / 变量]
4. [Helm模板之命名模板](k8s_helm6_definename.md)
   * [`partials` 和 `_` 文件 / 用 `define` 和 `template` 声明和使用命名模板/ 模板范围 / `include` 函数]
5. [`Helm Hooks` 的使用](k8s_helm7_hook.md)
   
6. [`Helm` 文件系统](k8s_helm8_files.md)
   * [模板内访问文件 /  `NOTES.txt` 文件/ `.helmignore` 文件]
7. [子 `chart` 和全局值](k8s_helm8_others.md)
   * [子 Chart 的使用 / 全局值的使用]
10. [Helm Chart 模板开发技巧](k8s_helm10_Dev_Skills.md)
   * [ 使用 `tpl` 函数 / 创建 `imagePullSecret` / `ConfigMap` 或者 `Secret` 更改时自动更新/ 告诉 `Tiller` 不要删除资源 / 使用`Partials/ others`]


### CHART 最佳实践

* [CHART 最佳实践](k8s_helm15_best_practice.md)

* 一般约定：了解 chart 一般约定。
* `values` 文件：查看结构化 `values.yaml` 的最佳实践。
* `Template:`：学习一些编写模板的最佳技巧。
* `Requirement`：遵循 requirements.yaml 文件的最佳做法。
* 标签和注释:：`helm` 具有标签和注释的传统。
* Kubernetes 资源：
  * `Pod` 及其规格：查看使用 `pod` 规格的最佳做法。
  * 基于角色的访问控制：有关创建和使用服务帐户，角色和角色绑定的指导。
  * 自定义资源：自定义资源（`CRDs`）有其自己的相关最佳实践。

#### HELM 开发技巧 

1. [`HELM`开发 `YAML`技巧](k8s_helm11_chart_yaml.md)
2. [Helm 词汇表](k8s_helm16_term.md)