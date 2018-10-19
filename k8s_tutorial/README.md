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

### 深入理解 POD

1. [使用YAML文件创建Kubernetes Deployment](k8s_adv0_yaml.md)
2. [Kubernetes Pod 工作流](k8s_adv1_pod.md)
3. [静态 Pod](k8s_adv20_static_pod.md)
4. [Pod Hook(PostStart & PreStop)](k8s_adv21_pod_hook.md)
5. [健康检查(liveness probe & readiness probe)](k8s_adv22_health_inspect.md)
6. [Pod Init Container 详解](k8s_adv9_pod_init_container.md)

### K8S 调度器

1. [Kubernetes 调度器介绍](k8s_adv25_kube-scheduler.md)
2. [理解 Kubernetes 的亲和性调度](k8s_adv7_Affinity_Selector.md)

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
11. [Pod 自动扩缩容(HPA: Horizontal Pod Autoscaling)](k8s_adv23_HPA.md)
12. [`DaemonSet` 与 `StatefulSet` 的使用](k8s_adv24_DaemonSet_StatefulSet.md)
13. [如何在 `kubernetes` 中开启 `ipvs` 模式](k8s_adv26_ipvs.md)

### 持久化存储:

1. [kubernetes 持久化存储(一)](k8s_adv14_pv1.md)
2. [kubernetes 持久化存储(二)](k8s_adv14_pv2.md)
3. [Pod 中挂载单个文件的方法 subpath](k8s_adv15_subpath.md)

### 服务发现

1. [集群内部服务发现之 DNS](k8s_adv16_dns.md)
2. [外部服务发现之 ingress(一): traefik 的安装使用](k8s_adv17_ingress1.md)
3. [外部服务发现之 ingress(二): Ingress TLS 和 PATH 的使用](k8s_adv18_ingress2.md)

### 包管理工具 HELM

1. [Helm安装使用](k8s_helm1_setup.md)
2. [Helm 的基本使用](k8s_helm2_application.md)
3. [Helm 模板之内置函数和Values](k8s_helm3_func_value.md)
4. [Helm 模板之模板函数与管道](k8s_helm4_template_pipe.md)
5. [Helm 模板之控制流程](k8s_helm5_process.md)
6. [Helm模板之命名模板](k8s_helm6_definename.md)
7. [Helm Hooks 的使用](k8s_helm7_hook.md)
8. [Helm模板之其他注意事项](k8s_helm8_others.md)

### K8S 安全性问题

1. [浅谈Docker的安全性支持(一)](k8s_security1_docker1.md)
2. [浅谈Docker的安全性支持(二)](k8s_security1_docker2.md)
3. [Kubernetes集群节点被入侵挖矿案例与发现解决问题](k8s_security2_invasive_bitcoin_mining.md)


### K8S Q&A

1. [K8S Issues List](k8s_QA_sum.md)
2. [K8S Q&A Chapter one](k8s_QA1.md)
3. [K8S Q&A Chapter two](k8s_QA2.md)
4. [K8S Q&A Chapter three](k8s_QA3.md)

### K8S 生产案例

1. [kubernetes生产案例之阿里云游戏业务分析](k8s_prod1_AliGame.md)