# KubeLinter：如何检查K8s清单文件和Helm图表

开源工具可以分析Kubernetes YAML文件和Helm 图表，以确保它们遵循最佳实践，重点关注生产就绪性和安全性。

以下是如何设置和使用它。

KubeLinter是一款开源工具，可分析 **Kubernetes YAML 文件和 Helm 图表**，以确保它们遵循最佳实践，重点关注生产就绪性和安全性。它对配置的各个方面进行检查，以识别潜在的安全错误配置和DevOps最佳实践

通过运行 KubeLinter，**您可以获得有关Kubernetes配置文件和 Helm 图表的有价值的信息**。它可以帮助团队在开发过程的早期检测并解决安全问题。

**KubeLinter 执行的检查的一些示例包括以非 root 用户身份运行容器、强制执行最小权限以及通过仅将敏感信息存储在机密中来正确处理敏感信息。**


## 为什么选择 KubeLinter？

KubeLinter 带有合理的**默认检查**，但它也是可配置的。**可以根据组织的策略灵活地启用或禁用特定检查**。此外，您可以创建自己的自定义检查来强制执行特定要求。

**当 lint 检查失败时，KubeLinter 会提供有关如何解决已识别问题的建议。它还返回一个非零退出代码以指示存在潜在问题。**

## **安装、设置和入门**

要开始使用KubeLinter，可以参考官方文档。该文档提供了有关安装、使用和配置 KubeLinter 的详细信息。以下是 KubeLinter 的一些安装选项。

**使用Go**

通过运行以下命令使用 Go 安装 KubeLinter：

```
go install golang.stackrox.io/kube-linter/cmd/kube-linter@latest
```

**使用 Homebrew (macOS) 或 LinuxBrew (Linux)**

通过运行以下命令，使用 Homebrew 或 LinuxBrew 安装 KubeLinter：

```
brew install kube-linter
```

### 从源码构建

如果您更喜欢从源代码构建 KubeLinter，请按照以下步骤操作：

```
# 克隆 KubeLinter 存储库
git clone git@github.com:stackrox/kube-linter.git

# 编译源代码以创建 kube-linter 二进制文件
make build

# 通过检查版本来验证安装
.gobin/kube-linter version
```

KubeLinter 提供不同层的测试，**包括go单元测试、端到端集成测试和使用bats-core 的端到端集成测试**。您可以运行这些测试来确保 KubeLinter 的正确性和可靠性。

## 如何使用 KubeLinter

要使用 KubeLinter，**您可以首先针对本地 YAML 文件运行它**。只需指定要测试的 YAML 文件的路径，**KubeLinter 将执行 linting 检查**。例如。

```
kube-linter lint /path/to/your/yaml.yaml
```

KubeLinter 的输出将**显示任何检测到的问题以及建议的修复步骤**。它还将提供所发现的 lint 错误的摘要。

您可以选择在本地运行它或将其集成到您的 CI 系统中。以下是本地运行 KubeLinter 的说明：


安装 KubeLinter 后，您可以使用 **lint 命令并提供 Kubernetes YAML 文件或包含 YAML 文件的目录的路径**。

对于单个 YAML 文件：

```
kube-linter lint /path/to/yaml-file.yaml
```

对于包含 YAML 文件的目录：

```
kube-linter lint /path/to/directory/containing/yaml-files/
```

要使用 KubeLinter 进行本地 YAML linting，请按照以下步骤操作：

* 找到要测试安全性和生产就绪性最佳实践的 YAML 文件。
* 运行以下命令，替换`/path/to/your/yaml.yaml为 YAML` 文件的实际路径。格式如下：

```
kube-linter lint /path/to/your/yaml.yaml
```

下面是一个使用名为 pod 规范文件示例的示例pod.yaml，该文件具有生产就绪性和安全问题：

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

将上面的 YAML 内容保存到名为lint-pod.yaml. 然后，您可以通过运行以下命令来检查该文件：

```
kube-linter lint lint-pod.yaml
```

KubeLinter 将运行默认检查并根据 linting 结果报告建议。在上面的示例中，输出将显示三个 lint 错误：

```
pod.yaml: (object: <no namespace>/security-context-demo /v1, Kind=Pod)
container "sec-ctx-demo" does not have a read-only root file system (check: 
no-read-only-root-fs, remediation: Set readOnlyRootFilesystem to true in your 
container's securityContext.)
 
pod.yaml: (object: <no namespace>/security-context-demo /v1, Kind=Pod) 
container "sec-ctx-demo" has cpu limit 0 (check: unset-cpu-requirements, 
remediation: Set your container's CPU requests and limits depending on its 
requirements. See 
https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#requests-and-limits for more details.)
 
pod.yaml: (object: <no namespace>/security-context-demo /v1, Kind=Pod) 
container "sec-ctx-demo" has memory limit 0 (check: unset-memory-requirements, 
remediation: Set your container's memory requests and limits depending on its requirements. 
See 
https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#requests-and-limits for more details.)
 
Error: found 3 lint errors
```

要在本地运行 Helm 图表的 KubeLinter，您需要提供包含该文件的目录的路径`chart.yaml`。以下是为 Helm 图表运行 KubeLinter 的命令：

```
kube-linter lint /path/to/directory/containing/chart.yaml-file/
```

您还可以使用该`--format`选项来指定输出格式。例如，对于 JSON 格式使用 `–format=json`，对于 SARIF 规范使用 `–format=sarif`。


**如果您使用预提交框架来管理 git 预提交挂钩，则可以将 KubeLinter 集成为预提交挂钩。将以下配置添加到您的`.pre-commit-config.yaml`文件**中：

```
- repo: https://github.com/stackrox/kube-linter
 rev: 0.6.0 # kube-linter version
 hooks:
  - id: kube-linter
```

此配置设置`kube-linter hook`，它使用 `go get` 在本地克隆、构建和安装 `KubeLinter`。

KubeLinter 为不同的操作提供了额外的命令和选项。以下是运行 KubeLinter 命令的一般语法。

* `kube-linter` [资源] [命令] [选项]
* `command` 指定要执行的操作，例如 lint 或检查列表
* `options`为每个命令指定附加选项。例如，您可以使用`-c`或`--config`选项来指定配置文件。

要查看可用资源、命令和选项的完整列表，您可以使用--help或-h选项。
查找所有资源：

```
kube-linter --help
```

**要查找特定资源的可用命令，**例如检查：

```
kube-linter checks --help
```

要查找特定命令的可用选项，例如 lint：

```
kube-linter lint --help
```

要配置 KubeLinter 运行的检查或创建您自己的自定义检查，您可以使用 YAML 配置文件。运行 lint 命令时，您可以提供 –config 选项，后跟配置文件的路径。

如果未显式提供配置文件，**KubeLinter 将在当前工作目录中按优先顺序查找具有以下文件名的配置文件**：

```
.kube-linter.yaml
```

如果没有找到这些文件，KubeLinter 将使用默认配置。

以下是如何使用特定配置文件运行 lint 命令的示例：

```
kube-linter lint pod.yaml –config kubelinter-config.yaml
```

配置文件有两个主要部分

* customChecks 用于配置自定义检查。
* checks 配置默认检查。

要查看所有内置检查的列表，您可以参考KubeLinter 检查文档。
以下是您可以在配置文件中使用的一些配置选项。

禁用所有默认检查。`doNotAutoAddDefaults`您可以通过在检查部分中设置为 true 来禁用所有内置检查。

运行所有默认检查。addAllBuiltIn您可以通过在检查部分设置为 true 来运行所有内置检查

```
checks:
 addAllBuiltIn: true
```

运行自定义检查。您可以根据现有模板创建自定义检查。params文档中的每个模板描述都包含有关可与该模板一起使用的参数 ( ) 的详细信息。这是一个例子。

```
customChecks:
 - name: required-annotation-responsible
  template: required-annotation
  params:
   key: company.io/responsible
```

这些是 KubeLinter 中可用的一些配置选项。您可以参考 KubeLinter 文档以获取有关配置和定制的更多详细信息。

**KubeLinter 是一个 alpha 版本，这意味着它仍处于开发的早期阶段。因此，未来可能会在命令使用、标志和配置文件格式方面发生重大变化**