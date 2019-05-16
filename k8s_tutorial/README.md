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

### 深入理解 容器化和 `Docker`

1. [从进程说容器](k8s_container1.md)
2. [Docker 镜像分析工具 Dive](k8s_container2_dive.md)

### K8S 生产架构

1. [7 款你不得不了解的开源云监控工具](k8s_arch1_monitor7.md) 
2. [Kubernetes 部署策略详解](k8s_adv41_deploy.md)
3. [Kubernetes CNI网络最强对比：Flannel、Calico、Canal和Weave](k8s_adv47_CNI.md)

#### Kubernetes + JenkinsX + Istio渐进式交付
1. [Kubernetes 中的渐进式交付, 蓝绿部署和金丝雀部署: shipper, Istio, Flagger](k8s_adv54_release.md)
2. [使用 Jenkins X 渐进式交付](k8s_adv56_jenkinsX.md)
3. [使用 Jenkins X 渐进式交付：自动化金丝雀部署](k8s_adv57_Auto_Canary.md)

### K8S 操作

### 使用技巧

1. [Kubectl Cheatsheet / kubectl命令技巧大全](k8s_adv27_kubectl_Cheatsheet.md)
2. [使用`etcdctl`访问`kubernetes`数据](k8s_skill2_etcdctl.md)
3. [POD内部使用技巧](k8s_skill3_skillset.md)
4. [Kubernetes API 资源应该使用哪个 Group 和 Version?](k8s_adv31_api_group_version.md)
5. [jsonnet 和 Kubernetes](k8s_adv32_jsonnet.md)

#### 故障排除

1. [Kubernetes service中的故障排查](k8s_skill1_bugfix1.md)
2. [Kubernetes 网络故障常见排查方法](k8s_adv55_network_troubleshooting.md)


### 深入理解 POD

1. [使用YAML文件创建Kubernetes Deployment](k8s_adv0_yaml.md)
2. [Kubernetes Pod 工作流](k8s_adv1_pod.md)
3. [静态 Pod](k8s_adv20_static_pod.md)
4. [Pod Hook(PostStart & PreStop)](k8s_adv21_pod_hook.md)
5. [Pod 的生命周期](k8s_adv43_podlifecycle.md)
6. [健康检查(liveness probe & readiness probe)](k8s_adv22_health_inspect.md)
7. [Pod Init Container 详解](k8s_adv9_pod_init_container.md)

### K8S 调度器

1. [Kubernetes 调度器介绍](k8s_adv25_kube-scheduler.md)
2. [理解 Kubernetes 的亲和性调度](k8s_adv7_Affinity_Selector.md)

### K8S and Cloud

1. [kube2iam overview, features and install on production](k8s_adv53_kube2iam.md)

### 常用对象操作:

1. [学习使用 Kubernetes 中的 Service 对象](k8s_adv2_service.md)
2. [Kubernetes Deployment滚动升级](k8s_adv3_Deployment.md)
3. [kubernetes PodPreset 的使用](k8s_adv4_PodPreset.md)
4. [kubernetes ConfigMap 和 Secrets](k8s_adv5_ConfigMap_Secrets.md)
5. [Kubernetes Downward API 基本用法](k8s_adv6_Downward_API.md)
6. [kubernetes 的资源配额控制器](k8s_adv8_resource_quotation.md) 
7. [用Replication Controller、Replica Set 管理Pod](k8s_adv10_RC_RS.md)
8. [Job和CronJob 的使用方法](k8s_adv11_job_cronjob.md)
9. [Kubernetes RBAC 详解](k8s_adv13_RBAC.md)
10. [Kubernetes 服务质量 `Qos` 解析 `Pod` 资源 `requests` 和 `limits` 如何配置?](k8s_adv19_Qos.md)
11. [`DaemonSet` 与 `StatefulSet` 的使用](k8s_adv24_DaemonSet_StatefulSet.md)
12. [Kubernetes Secret 资源对象使用方法](k8s_adv12_secret.md)
13. [`Kubernetes Namespace`命名空间详解](k8s_adv44_namespace.md)
14. [`Kubelet` 状态更新机制](k8s_adv58_kubelet.md)

### 持久化存储:

#### (1) 使用指南：

1. [深入浅出聊聊Kubernetes存储（一）：详解Kubernetes存储关键概念](k8s_adv48_Storage1.md)
2. [深入浅出聊聊Kubernetes存储（二）：搞定持久化存储](k8s_adv48_Storage2.md)

#### (2) 常用方法：

1. [kubernetes 持久化存储(一): PV 和 PVC 的使用](k8s_adv14_pv1.md)
2. [kubernetes 持久化存储(二): StorageClass 的使用](k8s_adv14_pv2.md)
3. [Pod 中挂载单个文件的方法 subpath](k8s_adv15_subpath.md)
4. [Kubernetes Local Persistent Volume](k8s_adv37_local_persistent_volume.md)
5. [3种K8S存储：emptyDir、hostPath、local](k8s_adv45_3OthersStorage.md)

### 服务发现

#### (1) 内部服务发现:

1. [内部服务发现 `kube-proxy` 实现原理](k8s_adv36_kube_proxy.md)
2. [如何在 `kubernetes` 中开启 `ipvs` 模式](k8s_adv26_ipvs.md)
3. [集群内部服务发现之 DNS](k8s_adv16_dns.md)
4. [详解 DNS 与 CoreDNS 的实现原理](k8s_adv40_CoreDNS.md)

#### (2) 外部服务发现

1. [外部服务发现之 ingress(一): traefik 的安装使用](k8s_adv17_ingress1.md)
2. [外部服务发现之 ingress(二): Ingress TLS 和 PATH 的使用](k8s_adv18_ingress2.md)
3. [Kubernetes Ingress 使用 Let's Encrypt 自动化 HTTPS](k8s_adv30_ingress_auto_https.md)
4. [如何保护对外暴露的 Kubernetes 服务](k8s_adv50_Ingress_Protection.md)
6. [nginx-ingress 的安装使用](k8s_adv51_Nginx_Ingress.md)
7. [kubernetes 办公环境下网络互通方案](k8s_adv38_Connect_Offce_Network.md)

### K8S 伸缩问题

1. [k8s自动伸缩那些事](k8s_adv28_hpa_vpa.md)
2. [Pod 自动扩缩容(HPA: Horizontal Pod Autoscaling)](k8s_adv23_HPA.md)
3. [6个与弹性伸缩、调度相关的Kubernetes附加组件](k8s_adv49_AS_plugins.md)

### K8S 深度设计理念

1. [Kubelet 调度资源预留(如何预防雪崩)](k8s_adv29_kubelet_resource.md)
2. [Kubernetes与容器设计模式](k8s_adv35_design_pattern.md)
3. [微服务中的Sidecar设计模式解析 & Kubernetes日志采集Sidecar模式介绍](k8s_adv34_sidecar.md)


### 包管理工具 HELM

1. [Helm安装使用](k8s_helm1_setup.md)
2. [Helm 的基本使用](k8s_helm2_application.md)
3. [Helm 模板之内置函数和Values](k8s_helm3_func_value.md)
4. [Helm 模板之模板函数与管道](k8s_helm4_template_pipe.md)
5. [Helm 模板之控制流程](k8s_helm5_process.md)
6. [Helm模板之命名模板](k8s_helm6_definename.md)
7. [Helm Hooks 的使用](k8s_helm7_hook.md)
8. [Helm模板之其他注意事项](k8s_helm8_others.md)
9. [Helm monitor 插件](k8s_helm9_monitor.md)
10. [Helm Chart 模板开发技巧](k8s_helm10_Dev_Skills.md)

### K8S 安全性问题

1. [浅谈Docker的安全性支持(一)](k8s_security1_docker1.md)
2. [浅谈Docker的安全性支持(二)](k8s_security1_docker2.md)
3. [Kubernetes集群节点被入侵挖矿案例与发现解决问题](k8s_security2_invasive_bitcoin_mining.md)


### K8S 集群监控

1. [在 Kubernetes 中手动部署 Prometheus](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_dev/prometheus/4.Adv_Prometheus_setup.md)
2. [Kubernetes 应用监控](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_dev/prometheus/5Adv_Prometheus_monitor.md)
3. [监控 Kubernetes 集群节点](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_dev/prometheus/6Adv_K8S_Nodes_monitor.md)
4. [监控 Kubernetes 常用资源对象](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_dev/prometheus/7Adv_K8S_Resource_monitor.md)
5. [Grafana 在 Kubernetes 中的使用](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_dev/prometheus/8Adv_K8S_Grafana.md)
6. [报警神器 AlertManager 的使用](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_dev/prometheus/10Adv_k8s_AlertManger.md)
7. [Prometheus Operator 初体验](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_dev/prometheus/11Adv_Prometheus_Operator.md)
8. [使用 Prometheus Operator 监控 etcd](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_dev/prometheus/13Adv_Prometheus_Operator_etcd.md)
9. [Prometheus Operator 自定义报警](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_dev/prometheus/14Adv_Prometheus_Operator_alarm.md)
10. [Prometheus Operator 自动发现以及数据持久化](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_dev/prometheus/15Adv_Prometheus_Operator_Setting.md)
11. [kube-state-metrics](k8s_adv39_kube_state_metrics.md)

### K8S 其他工具

1. [安装使用 360 开源 K8S Dashboard: `Wayne`](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_dev/prometheus/9Adv_Wayne_dashboard.md) 
2. [Grafana 日志聚合工具 Loki](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_dev/prometheus/12Adv_Grafana_Loki.md)


### K8S Q&A

1. [K8S Issues List](k8s_QA_sum.md)
2. [K8S Q&A Chapter one](k8s_QA1.md)
3. [K8S Q&A Chapter two](k8s_QA2.md)
4. [K8S Q&A Chapter three](k8s_QA3.md)
5. [K8S Q&A Chapter Four](k8s_QA4.md)

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