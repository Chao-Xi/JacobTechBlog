# Kubernetes 资源清单静态分析工具 - KubeLinter

KubeLinter 是一种开源静态分析工具，用于识别 Kubernetes 对象中的错误配置。KubeLinter 提供了对 Kubernetes YAML 文件和 Helm Chart 的安全检查的能力，验证集群配置是否遵循最佳安全实践。

**通过内置检查，可以获得有关错误配置和违反 Kubernetes 策略的反馈。这提高了开发人员的工作效率，将安全即代码与 DevOps 和 DevSecOps 流程集成，同时确保为 Kubernetes 应用程序自动实施强化的安全策略**。


KubeLinter 分析 YAML 文件和 Helm Chart 并运行 Kubernetes 原生安全检查，以识别提升的访问权限、错误配置和一般的最佳实践违规行为。KubeLinter 是一个基于 Go 的二进制文件，用于命令行或 CI 管道的一部分，并在允许任何 Kubernetes 配置更改之前为开发人员提供必要的安全检查。目前，CLI 中内置了 19 项安全检查，包括：

* 使用默认ServiceAccount
* 不匹配的选择器
* 以 root 身份运行容器
* 设置可写的 host 主机挂载

## 安装 KubeLinter

### 使用 Go 安装

```
GO111MODULE=on go get golang.stackrox.io/kube-linter/cmd/kube-linter
```

或者直接从 Release 页面(https://github.com/stackrox/kube-linter/releases/tag/0.2.2)下载最新的二进制文件添加到 PATH 路径下即可。

### 使用 brew 安装

在 macOS 下使用 Homebrew 或者在 Linux 下使用 LinuxBrew 安装：

```
brew install kube-linter
```

## 使用 KubeLinter

运行 KubeLinter 对 YAML 文件进行 Lint 只需要最基本的两个步骤即可:

1. 找到您要测试安全性和生产就绪最佳实践的 YAML 文件
2. 执行命令 `kube-linter lint /path/to/your/yaml.yaml`

例如下面的的 pod.yaml 资源文件，该文件存在几个问题：


**安全问题**

1. 这个 pod 中的容器不是作为只读文件系统运行的，这可能允许它写入 root 文件系统。

**生产就绪**

1. 容器的 CPU 限制未设置，这可能会使其消耗过多的 CPU
2. 未设置容器的内存限制，这可能会使其消耗过多内存

```
apiVersion: v1
kind: Pod
metadata:
name: security-context-demo
spec:
securityContext:
    runAsUser: 1000
    runAsGroup: 3000
    fsGroup: 2000
volumes:
- name: sec-ctx-vol
    emptyDir: {}
containers:
- name: sec-ctx-demo
    image: busybox
    resources:
    requests:
        memory: "64Mi"
        cpu: "250m"
    command: [ "sh", "-c", "sleep 1h" ]
    volumeMounts:
    - name: sec-ctx-vol
    mountPath: /data/demo
    securityContext:
    allowPrivilegeEscalation: false
```

3.拷贝上面的 pod.yaml 文件执行下面的命令进行 lint

```
kube-linter lint pod.yaml
```

4.KubeLinter 运行默认检查，会输出如下所示的结果

要了解有关 KubeLinter 使用和配置的更多信息，请访问 https://docs.kubelinter.io。

