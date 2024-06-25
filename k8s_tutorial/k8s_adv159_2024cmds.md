# 2024 DevOps工程师常用的K8s命令和技巧

Kubernetes 改变了容器编排方式，kubectl是管理 Kubernetes 集群的主要工具。要运行这些命令，请使用Kubernetes 集群或在线集群，并确保kubectl已安装。

* 获取 kubectl 版本

```
kubectl version
```

* 获取集群详细信息

收集有关 Kubernetes 集群的详细信息。


```
kubectl cluster-info
```

* 列出可用的 Kubernetes API 资源


**在 Kubernetes 中，该api-resources命令用于kubectl列出集群 API 服务器上可用的所有顶级 API 资源。**

```
kubectl api-resources
```

* 检索Kubernetes上下文

列出 kubeconfig 文件中所有可用的上下文（集群、用户和命名空间）。

```
kubectl config get-contexts
```

* **切换集群**

在不同的上下文/集群之间切换。这对于管理多个 Kubernetes 环境很有用。

```
kubectl config use-context <context_name>
```

* **切换/上下文默认命名空间**

Kubernetes 中的命令`kubectl config set-context`允许您在 Kubernetes 配置中设置或更改上下文。上下文定义kubectl默认情况下将使用哪个用户和命名空间命令。这对于管理多个 Kubernetes 命名空间非常有用。

```
kubectl config set-context --current --namespace <NAMESPACE_NAME>
```

* **Kubectl创建更新资源**

创建或更新 Kubernetes 资源以匹配YAML配置文件中定义的所需状态。

```
kubectl apply -f <file_path>
```

* 使用Kubectl创建资源

创建或更新 Kubernetes 资源以匹配YAML配置文件中定义的所需状态。

```
kubectl apply -f <file_path>
```

* **使用Kubectl创建资源**

```
kubectl create namespace <namespace_name>
```

* **修补 Kubernetes 资源**

通过应用合并补丁、JSON 合并补丁或 JSON 补丁来修改资源的属性。接受 JSON 和 YAML 格式。

注意：自定义资源不支持合并补丁

```
kubectl patch (-f FILENAME | TYPE NAME) [-p PATCH|--patch-file FILE]
```

例子：

```
#更新节点JSON
kubectl patch node k8s-node-1 -p '{"spec":{"unschedulable":true}}' 


#更新节点YAML
kubectl patch node k8s-node-1 -p $'spec:\n unschedulable: true' 

# 使用战略合并补丁部分更新由“node.json”中指定的类型和名称标识的节点
kubectl patch -f node.json -p '{"spec":{"unschedulable":true}}'

# 更新容器的镜像；spec.containers[*].name 是必需的，因为它是合并键
kubectl patch pod valid-pod -p '{"spec":{"containers":[{"name":"kubernetes-serve-hostname","image":"new image"}]}}'

# 使用带有位置数组的 JSON 补丁更新容器的镜像
kubectl patch pod valid-pod --type='json' -p='[{"op": "replace", "path": "/spec/containers/0/image", "value":"new image"}]'

# 使用合并补丁通过 'scale' 子资源更新部署的副本
kubectl patch deployment nginx-deployment --subresource='scale' --type='merge' -p '{"spec":{"replicas":2}}'
```

### 列出任何资源

列出当前命名空间的所有部署。

```
kubectl get deploy -n kube-system
```

### 管理部署

管理部署的推出和更新。

示例（检查部署的推出状态）：

```
kubectl rollout status deployment/<deployment_name>
```

### Pod描述信息

获取有关特定 pod 的详细信息。

```
kubectl describe pod <pod_name> -n <NAMESPACE>
```

### 查看容器日志

从 pod 中检索正在运行的容器的日志。

```
kubectl logs <pod_name> <container_name> -f
```

### 在pod中执行命令

```
kubectl exec -it <pod_name> -c <container_name> -- /bin/sh
```

### 缩放副本


扩展 Deployment、ReplicationController 或 StatefulSet 的副本数量。以下将 Deployment 扩展为 3 个副本

```
kubectl scale deployment <deployment_name> --replicas=3
```

### 公开 Kubernetes 资源

将 Deployment、ReplicaSet 或 Pod 公开为服务。此处将 Deployment 公开为 NodePort 服务

```
kubectl expose deployment <deployment_name> --type=NodePort --port=<port_number>
```

### 删除k8s资源

删除 YAML 文件中定义的资源或直接按名称删除资源。删除 pod 或任何其他资源

```
kubectl delete pod <pod_name>
```

### 在 Kubernetes 中设置节点污点

向节点添加污点以限制某些 pod 的调度，除非它们能够容忍该污点。
示例（使用 key=value 污点污染节点）：

```
kubectl taint nodes <node_name> key=value:taint_effect
```

### 在 Kubernetes 中将节点标记为不可调度

指示该节点不可用于调度。

```
kubectl cordon NODE

#将节点标记为可调度。使用kubectl cordon
kubectl uncordon NODE
```

### 排空Kubernetes节点

```
#排空节点“foo”，即使其上存在未由复制控制器、副本集、作业、守护进程集或状态集管理的 pod
kubectl drain foo --force

# 如上所述，但如果存在未由复制控制器、副本集、作业、守护进程集或状态集管理的pod，则中止，并使用 15 分钟的宽限期
kubectl drain foo --grace-period=900
```

### 解释资源

获取pod 清单的文档

```
kubectl explain pods
```

### 列出事件

```
kubectl get events --sort-by=.metadata.creationTimestamp
```

### 比较资源配置

将集群的当前状态与应用清单时集群所处的状态进行比较。

```
kubectl diff -f ./my-manifest.yaml
```

### 设置配置资源

滚动更新“frontend”部署的“www”容器，更新镜像

```
kubectl set image deployment/frontend www=image:v2
```

### 替换 Kubernetes 中的资源

强制替换、删除然后重新创建资源。注意：将导致服务中断。

```
kubectl replace --force -f ./pod.json
```

### 管理标签

通过添加、删除或覆盖标签来修改标签。

```
kubectl label pods my-pod new-label=awesome                      # 添加label
kubectl label pods my-pod new-label-                             # 删除label
kubectl label pods my-pod new-label=new-value --overwrite        # 覆盖值
```

### 编辑资源

在您喜欢的编辑器中编辑任何 API 资源。

```
kubectl edit svc/docker-registry                      # 编辑名为 docker-registry 的服务
KUBE_EDITOR="nano" kubectl edit svc/docker-registry   # 使用其他编辑器
```

### 调试资源

用于对 Kubernetes 中现有 Pod 进行故障排除的调试 Pod

```
kubectl debug my-pod -it --image=busybox:1.28  # 在现有 pod 中创建交互式调试会话并立即连接到它

kubectl debug node/my-node -it --image=busybox:1.28 # 在节点上创建交互式调试会话并立即连接到它
```

### 运行 Pod

它是一个多功能命令，可以启动一个容器的单个实例或一组容器。

```
kubectl run -i --tty busybox --image=busybox:1.28 # 以交互式 shell 形式运行 pod
```

### 将文件/目录复制到容器或从容器中复制

将当前命名空间 pod 中的远程 pod 复制到其中。

```
kubectl cp /tmp/foo_dir my-pod:/tmp/bar_dir
```

### 将端口转发到 Kubernetes Pod

这对于在本地访问集群服务而无需通过服务或入口公开它们非常有用。语法如下：

```
kubectl port-forward <pod-name> <local-port>:<pod-port>
```

### 查看 Kubernetes 中的资源指标

它概述了集群内节点和/或 pod 的资源消耗情况。以下是其用法和语法的细分：

```
kubectl top [node | pod | container | service] [NAME | -l label]
```

### 格式化输出

要以特定格式将详细信息输出到终端窗口，请将`-o（或--output）`标志添加到支持的kubectl命令。

* `-o=custom-columns=<spec>`：使用逗号分隔的自定义列的列表打印表格。
* `-o=custom-columns-file=<filename><filename>`：使用文件中的自定义列模板打印表格
* `-o=go-template=<template>`：打印golang模板中定义的字段
* `-o=go-template-file=<filename>`：打印文件中golang模板定义的字段<filename>
* `-o=json`：输出 JSON 格式的 API 对象
* `-o=jsonpath=<template>`：打印jsonpath表达式中定义的字段
* `-o=jsonpath-file=<filename>`：打印文件中jsonpath表达式定义的字段
* `-o=name`：仅打印资源名称，不打印其他内容
* `-o=wide`：以纯文本格式输出任何附加信息，对于 pod，包含节点名称
* `-o=yaml`：输出 YAML 格式的 API 对象


使用示例-o=custom-columns：

```
#集群中运行的所有镜像
kubectl get pods -A -o=custom-columns='DATA:spec.containers[*].image'

#在命名空间default中运行的所有镜像，按Pod分组
kubectl get pods --namespace default --output=custom-columns="NAME:.metadata.name,IMAGE:.spec.containers[*].image" 

#除“registry.k8s.io/coredns:1.6.2”之外的所有镜像
kubectl get pods -A -o=custom-columns='DATA:spec.containers[?(@.image!="registry.k8s.io/coredns:1.6.2")].image' 

# 获取元数据下的所有字段
kubectl get pods -A -o=custom-columns='DATA:metadata.*'
```

### Kubectl 输出详细程度和调试

Kubectl 详细程度使用 -v 或 --v 标志后跟一个整数来设置，表示日志级别。

* `--v=0`：通常这对于集群操作员始终可见很有用。
* `--v=1`：如果您不想太冗长，则可以使用合理的默认日志级别。
* `--v=2`：提供系统发生重大变化时的稳定状态信息和关键日志消息。建议使用默认日志级别。
* `--v=3`：有关变更的扩展信息。
* `--v=4`：调试级别详细程度。
* `--v=5`：跟踪级别详细程度。
* `--v=6`：显示请求的资源。
* `--v=7`：显示HTTP请求头。
* `--v=8`：显示HTTP请求内容。
* `--v=9`：显示HTTP请求内容，不截断内容。





