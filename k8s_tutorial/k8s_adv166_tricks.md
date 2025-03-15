# Kubernetes 秘密技巧  2025

## 1. 使用 initContainers 进行复杂的启动前任务

**大多数 Kubernetes 用户都熟悉 initContainers 用于简单的设置任务**，比如等待服务准备就绪。

**然而，initContainers 可以做更多事情。**

例如，您可以使用它们从外部源获取密钥、设置环境变量，甚至在主容器启动之前运行数据库迁移

```
apiVersion: v1
kind:Pod
metadata:
name:example-pod
spec:
initContainers:
-name:init-migration
    image:my-migration-image
    command:['sh','-c','python migrate.py']
    volumeMounts:
    -name:migration-scripts
      mountPath:/scripts
containers:
-name:app-container
    image:my-app-image
    volumeMounts:
    -name:migration-scripts
      mountPath:/app/scripts
volumes:
-name:migration-scripts
    emptyDir:{}
```

## **2. 利用自定义资源定义 (CRDs) 和操作符**

CRDs 允许您使用自己的 API 类型扩展 Kubernetes，而操作符则使用这些 CRDs 来管理复杂的应用程序。

虽然许多人知道 CRDs，但很少有人充分利用它们的潜力。

```
apiVersion: myoperator.example.com/v1
kind: MyDB
metadata:
  name: mydatabase
spec:
  replicas: 3
  storageGB: 10
```

Kubernetes 管理员将根据此自定义资源自动创建和管理有状态集、服务和持久卷。

## 3. 使用 Pod Presets 进行默认配置

**Pod Presets 是一个较少人知的功能，允许您将默认配置、环境变量或卷注入到 pod 中，而无需修改其 YAML 文件**。

**Pod Presets 是一个较少人知的功能，允许您将默认配置、环境变量或卷注入到 pod 中，而无需修改其 YAML 文件**。

```
apiVersion: settings.k8s.io/v1alpha1
kind:PodPreset
metadata:
name:default-env-vars
spec:
selector:
    matchLabels:
      env:production
env:
-name:LOG_LEVEL
    value:info
volumes:
-name:秘密-volume
    秘密:
      秘密Name:my-秘密
```

## 4. 高级网络策略以实现细粒度控制

**网络策略是控制 pod 之间流量流动的强大方式，但许多用户只触及了它们的表面**。

您可以使用它们来强制执行安全最佳实践，比如最小权限原则

```
apiVersion: networking.k8s.io/v1
kind:NetworkPolicy
metadata:
name:allow-only-internal-services
spec:
podSelector:
    matchLabels:
      app:my-app
policyTypes:
-Ingress
-Egress
ingress:
-from:
    -podSelector:
        matchLabels:
          app:internal-service
    ports:
    -protocol:TCP
      port:80
egress:
-to:
    -ipBlock:
        cidr:10.0.0.0/24
    ports:
    -protocol:TCP
      port:443
```

**kind:NetworkPolicy**

## 5. 垃圾回收和资源配额以实现高效的集群管理

**垃圾回收和资源配额经常被忽视，但它们对于维护健康的集群至关重要**。

通过设置资源配额并了解垃圾回收策略，您可以防止资源耗尽并确保集群的平稳运行。

```
apiVersion: v1
kind:ResourceQuota
metadata:
name:compute-resources
spec:
hard:
    requests.cpu:"2"
    requests.memory:4Gi
    limits.cpu:"4"
    limits.memory:8Gi
```