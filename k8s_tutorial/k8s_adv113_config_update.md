# Kubernetes 配置更新那些事

> 为了降低 `kube-apiserver` 的负担，Kubernetes 从 v1.19 开始自动开启了 **`ImmutableEphemeralVolumes` 特性，开启后禁止 Secret 和 ConfigMap 的自动更新**

任何应用都需要一些特定的配置项，用来自定义应用的特性。

这些配置通常可以分为两类：一**类是诸如运行环境和外部依赖等非敏感配置，另一类是诸如密钥和 SSH 证书等敏感配置。**

这些配置不应该直接放到容器镜像中，而是应该配置与容器分离，通过数据卷、环境变量等方式在运行时动态挂载。

## **如何为POD提供配置**

**对 Kubernetes 应用来说，敏感配置推荐放到 Secret 中，而非敏感配置推荐放到 ConfigMap** 中。Secret 相对于 ConfigMap 来说，提供了更多的数据安全保证机制从而更适合敏感数据配置：

* 支持静态数据加密，将加密后的数据再存储到 etcd 中。
* 以 Volume 形式挂载到 Pod 时，数据存在 tmpfs 中而不是直接写入磁盘存储中。


**Pod 可以通过 Volume 和环境变量两种方式引用 ConfigMap 和 Secret，并且以 Volume 形式挂载后还支持热更新。**这种热更新机制看起来非常好，但在实际 DevOps 流程中实际上也有不少的问题，需要使用的时候特别注意。

## **Kubernetes热更新**

使用 Secret 和 ConfigMap 最简单的方法是以 Volume 形式挂载到 Pod 中，这种方式也支持自动更新。比如：

![Alt Image Text](images/adv/adv113_1.png "Body image")

**不过需要注意的是，在挂载时不要使用 `subPath`，因为使用 `subPath` 之后就不支持自动更新了。**

因为是文件的更新，容器应用可以用 inotify 机制监控文件的变化情况，进而再加载新配置。比如，对于 Go 应用来说，可以使用 fsnotify 库。

当然，**这种方法有很多限制**：


* 每个容器应用都需要监控配置文件变化的机制，或者为不支持自动监控配置文件变化的服务配置 sidecar。
* 不支持滚动更新，只要 Secret 和 ConfigMap 更新了，**所有使用他们的容器都会全部更新**。这会导致配置错误一下子更新到所有容器，而不是滚动更新，无法实现第一个 Pod 发现错误时停止后续的更新。
* **配置生效时间并不确定，生效时间依赖于 Kubelet 刷新，在 Devops 流水线中很难检测配置全部生效的时刻**。
* 大量 ConfigMap 和 Secret 的 watch 请求会**加重 kube-apiserver 的负载**，影响 kube-apiserver 的性能。

基于这些限制，Kubernetes 自动更新的方法仅推荐用于简单且副本数很少的应用中，而复杂的应用推荐使用下述的滚动更新机制。**使用滚动更新的另一个好处是对挂载方式没有限制，subPath 和环境变量都是支持的。**

## **滚动更新**


为了降低 `kube-apiserver` 的负担，Kubernetes 从 v1.19 开始自动开启了 **`ImmutableEphemeralVolumes` 特性，开启后禁止 Secret 和 ConfigMap 的自动更新**：

![Alt Image Text](images/adv/adv113_2.png "Body image")

关闭自动更新后，在更新 ConfigMap 和 Secret 的时候就需要一些额外的步骤对应用进行滚**动更新。这其中最常用的几种方法是 Reloader、checksum 注解以及动态 Secret/ConfigMap 名称。**


## **Reloader**

**[Reloader](https://github.com/stakater/Reloader) 是一个监视 `ConfigMap/Secret` 更改并对其关联的 Deployment、Daemonset、StatefulSet、DeploymentConfig 进行滚动更新的开源项目**。

Reloader 的使用方法比较简单，首先部署 Reloader 控制器：

```
kubectl apply -k https://github.com/stakater/Reloader/deployments/kubernetes
```

**然后，给想要滚动更新配置的应用加上 reloader 注解即可：**

```
kind: Deployment
metadata:
  annotations:
    configmap.reloader.stakater.com/reload: "foo-configmap"
     secret.reloader.stakater.com/reload: "foo-secret"
spec:
  template: metadata:
```

checksum 注解 checksum 注解是 Helm Charts 中最常用的滚动更新方法，即在 Deployment 的 annotations 中加上 Secret 或者 ConfigMap 的 sha256sum，这样已有的 Pod 就会随着 Secret 或者 ConfigMap 的变更而更新：


![Alt Image Text](images/adv/adv113_3.png "Body image")

## 动态 Secret/ConfigMap 名称


动态 Secret/ConfigMap 名称是 Kustomize 中最常用的滚动更新方法，即 [configMapGenerator](https://kubectl.docs.kubernetes.io/references/kustomize/configmapgenerator/) 和 [secretGenerator](https://kubectl.docs.kubernetes.io/references/kustomize/secretgenerator/)。它们根据 `Secret` 和 `ConfigMap` 的数据动态生成一个名称，进而在执行 `kubectl apply --kustomize` 命令的时候触发 Deployment 的滚动更新。

![Alt Image Text](images/adv/adv113_4.png "Body image")

**比如使用 configMapGenerator：**

将生成下面的 Manifest：

![Alt Image Text](images/adv/adv113_5.png "Body image")

而在 Deployment 只要使用 ConfigMap 名字 my-application-properties，kustomize 会把原始名字替换成生成后的名字。
