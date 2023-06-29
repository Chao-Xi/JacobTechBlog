# Helm Chart 开发 ：7个常用的Helm 函数 2023

Helm是Kubernetes的包管理器。我们大部分时间花在使用现成的Chart上。但通常企业中应用部署的情况下，我们会具有开发创建Helm Chart的必要性。


想要制作自己的 Helm Chart的原因有很多。也许最直接的就是打包您自己的应用程序。有时可能是修改现有Chart以满足特定需求。在所有情况下，创建（或修改）Helm Chart通常涉及使用以下文件（从最常见的文件开始）：


* YAML templates
* `_helpers.tpl`

这些文件位于Helm Chart的templates目录中。除了从Sprig库借用的一些功能之外，它们都还使用Go模板语言。**这意味着您可以使用Go模板函数 + Sprig 的模板函数来制作最强大的模板**。

## 设置Helm环境

幸运的是，Helm 创建者可以非常轻松地通过命令创建一个 Helm Chart示例，该Chart可以根据用户的特定需求进行自定义。我们需要做的就是运行：

```
helm create mychart
```

上面的命令将创建一个名为mychart的目录，其中包含部署功能齐全的 Helm Chart所需的文件。目录内容如下所示：

```
mychart
├── Chart.yaml
├── charts
├── templates
│   ├── NOTES.txt
│   ├── _helpers.tpl
│   ├── deployment.yaml
│   ├── hpa.yaml
│   ├── ingress.yaml
│   ├── service.yaml
│   ├── serviceaccount.yaml
│   └── tests
│       └── test-connection.yaml
└── values.yaml
```

我们不会一一命名这些函数并显示每个函数的语法及其使用方式。您可以参考Helm 文档来获取此类参考。相反，我们将介绍一些一起使用多个函数的用例。

现在，让我们开始我们的 Helm 函数之旅。

## 1. 设置副本数上限

我们的第一个场景是为Chart用户可以设置的最大副本数设置上限。

### **挑战**


我们注意到，**当部署的Pod数量超过10个时，我们的应用程序在Kubernetes上无法正常运行。我们希望确保每当允许用户设置副本计数（通常在部署中）时，该数量都小于 10**。如果指定了更高的数字，Chart应自动将其降低到10。

**解决方案**

为了实现这个逻辑，我们可以使用以下代码：

```
{{- if gt (.Values.replicaCount | int ) 10 }} 
   {{- print  10 }} 
{{- else }} 
   {{- print .Values.replicaCount }} 
{{- end }}
```

让我们分解一下这段代码：

1. 我们使用该`if..else..end`结构来做出条件判断。
2. 该gt函数测试一个值是否大于一个数字。语法是`gt .Arg1 .Arg2`.   
	* **这里`Arg1`需要是`replicaCount`用户在部署Chart时指定的参数。所以，我们使用`.Values.replicaCount`。**
3. 问题是该gt函数只接受数字值。
	*  `Values.replicaCount`作为字符串传递。因此，我们使用该int函数将其转换为整数。Go 中的函数可以在同一行或使用|管道符号接受值（与 Linux shell 的工作方式相同）。我们使用括号来确保将整个内容作为第一个参数.`Values.replicaCount | int`传递给函数`gt`。
	*  **传递给该`gt`函数的第二个参数是10。因此，现在该gt函数正在检查 是否`.Value.replicaCount`大于 10 并将返回`true` or `false` 作为结果。**
	*  如果结果是true，则条件成立。该函数只是回显传递给它的任何内容。这里是10。
	*  否则，让用户自己指定repicaCount，只要小于即可10。

现在，让我们使用这段代码。打开`templates/deployment.yaml`并将引用 的行replicaCount（应该是第 9 行或第 10 行）更改为如下所示：

```
replicas: {{ if gt (.Values.replicaCount | int) 10 }}{{- printf "10" }}{{- else }}{{- print .Values.replicaCount }}{{- end }}{{- end }}
```

为了测试我们的更改，让我们打开`values.yaml`文件并将`replicaCount`变量更改为`100`例如：

```
#values.yaml
replicaCount: 100
```

尝试使用以下命令（在目录mychart内）运行Helm Chart，而不将其安装到集群：

```
helm install mychart --dry-run .
```

输出将是一个YAML清单。通过向上滚动直到部署部分，您会看到如下内容：

```
# Source: mychart/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mychart
  labels:
    helm.sh/chart: mychart-0.1.0
    app.kubernetes.io/name: mychart
    app.kubernetes.io/instance: mychart
    app.kubernetes.io/version: "1.16.0"
    app.kubernetes.io/managed-by: Helm
spec:
  replicas: 10
  selector:
    matchLabels:
      app.kubernetes.io/name: mychart
      app.kubernetes.io/instance: mychart
```

请思考下我们的副本是如何自动减少到10的， 因为我们打算运行100个副本。


Cool ！但现在我们有两个问题：

1. 模板看起来很丑。我们必须将整个代码片段放在一行上以避免空格问题。
2. 如果我们想在其他部署模板或也需要遵守相同规则的 StatefulSet 中使用相同的代码片段怎么办？这就是include函数发挥作用的地方。

## 2. 使用子模板在模板之间共享代码片段

**该`include`函数用于将子模板嵌入到模板中的任何位置**。

子模板可以存储在以下划线开头的任何文件中。**如果您注意到，我们的 Helm Chart已经使用了存储在文件中的子模板`templates/_helpers.tpl`**。

它包含一些常见的功能，例如如何根据Chart名称和版本名称命名资源以及其他类似用途。

在我们的场景中，我们希望将`replicaCount`限制逻辑存储在子模板中，以便我们可以在任何需要实现它的模板中使用它。让我们看看如何。


**打开`templates/_helpers.tpl`文件（请注意，我们可以创建另一个模板文件，因为 Helm 只会查找以`_`下划线开头的任何文件并将其视为子模板。**

我们使用 是`_helpers.tpl`为了保持一致性和简单性）。将我们的代码片段添加到文件末尾，使其如下所示：

```
{{- define "replicaCountCeiling" -}}
    {{- if gt (.Values.replicaCount | int) 10 }}
        {{- print 10 }}
    {{- else }}
        {{- print .Values.replicaCount }}
    {{- end }}
{{- end }}
```

注意这里使用define函数，该define函数是一个Go模板函数，用于定义嵌套模板。

它在Helm中使用，因为我们追求相同的目的。**它接受子模板名称作为参数。直到关键字end为止的任何内容都被视为模板。在这里，我们将逻辑创建为名为 replicaCountCeiling的嵌套模板**。

要使用此子模板，请打开`templates/deployment.yaml`文件并替换我们之前使用的代码，以使该行如下所示：

```
replicas: {{ include "replicaCountCeiling" . }}
```

如果您尝试试运行Chart，您会收到类似于以下内容的错误：

```
Error: INSTALLATION FAILED: template: mychart/templates/deployment.yaml:9:15: executing "mychart/templates/deployment.yaml" at <include "replicaCountCeiling" .Values>: error calling include: template: mychart/templates/_helpers.tpl:64:22: executing "replicaCountCeiling" at <.Values.replicaCount>: nil pointer evaluating interface {}.replicaCount
```

现在，让我们通过修改`replicaCount`子模板源中的变量的方式来修复此错误`templates/_helpers.tpl`：

```
{{ define "replicaCountCeiling" }}
    {{- if gt (.replicaCount | int) 10 }}
        {{- print 10 }}
    {{- else }}
        {{- print .replicaCount }}
    {{- end }}
{{- end }}
```

如果您现在尝试试运行Chart，它将毫无问题地工作。但我们改变了什么？我们只是简单地调用该变量而不引用它的父.Values变量。

为什么？因为当我们通过函数调用它时，我们已经将它作为根变量传递给子模板include。

大多数时候，您需要将.作为根变量传递以避免混淆并访问Chart可用的所有变量。

## 3. 生成 YAML 片段

ConfigMap在Kubernetes中被大量使用。

它们用于存储可供集群中运行的容器使用的配置参数。假设我们有一个需要提供给容器的配置文件。文件本身如下所示：

```
db:
  name: mydb
  port: 3306
api:
  url: "http://someurl"
  port: 8080
```

容器期望在`/app/config.yaml`下找到该文件。由于我们想要使用 Helm 将应用程序安装到 Kubernetes，因此我们获取文件内容并将值文件放入名为config的键下，如下：

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-configmap
data:
  config.yaml: | 
# The contents of the config.yaml file
```

**我们有一个键名为的`config.yaml`，我们需要将数据添加到其中**。但如何实现呢？仅引用values文件中的键config，如下所示：

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-configmap
data:
  config.yaml: |
{{ .Values.config }}
```

但是，如果您尝试使用此配置部署Chart，它将失败。以下命令可以帮助我们了解此Chart失败的原因：

```
helm template --debug test .
```

**即使 Helm 无法处理它们，这也会为您提供生成的原始 YAML。这对于解决此类问题非常有用**。如果我们查看生成的输出，我们会看到生成的 ConfigMap 如下所示：

```
# Source: mychart/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-configmap
data:
  config.yaml: |
map[api:map[port:8080 url:http://someurl] db:map[name:mydb port:3306]]
```

显然，这不是我们所期望的。

**原因是Go将`values.yaml`文件中的值转换为它可以使用的数据结构。**

我们的config数据被转换成一个Map，其中包含一个包含Map的列表。

这就是 Go 理解 YAML 并使用它的方式。但我们对Go数据结构的文本表示非常感兴趣！这就是该`toYaml`功能派上用场的地方。

**修改`templates/configmap.yaml`如下：**

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-configmap
data:
  config.yaml: |
{{ .Values.config | toYaml }}
```

该`toYaml`函数仅接受数据结构并将其转换为相应的YAML。

这就是我们所需要的。让我们再次重新运行最后一个命令，看看生成的 YAML 是什么样子的：

```
# Source: mychart/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-configmap
data:
  config.yaml: |
api:
  port: 8080
  url: http://someurl
db:
  name: mydb
  port: 3306
```

是的，好多了。至少我们有有效的 YAML，而不是Go映射和列表。但等一下。这并不完全有效，是吗？

从values文件中获取的内容与键`config.yaml`具有相同的缩进级别。

这意味着它们没有嵌套在其下，整个` ConfigMap`无效。
幸运的是，我们有indent功能。

`indent`顾名思义，该函数将内容缩进到指定的缩进级别。我们将`templates/configmap.yaml`最后一次修改为如下所示：

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-configmap
data:
  config.yaml: |
{{ .Values.config | toYaml | indent 4 }}
```

我们将values缩进四个空格，因为它有两级深，并且我们使用两个空格进行缩进 (2 + 2 = 4)。如果我们最后一次运行调试命令，ConfigMap 应如下所示：

```
# Source: mychart/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-configmap
data:
  config.yaml: |
    api:
      port: 8080
      url: http://someurl
    db:
      name: mydb
      port: 3306
```

如您所见，该文件包含构造正确ConfigMap的有效YAML。

为了完整起见，关联的部署如下所示（为简洁起见，仅显示相关部分）：

```
spec:
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ include "mychart.serviceAccountName" . }}
      securityContext:
        {{- toYaml .Values.podSecurityContext | nindent 8 }}
      containers:
        - name: {{ .Chart.Name }}
          volumeMounts:
            - name: config-volume
              mountPath: /app/config.yaml
              subPath: config.yaml
# more content
      volumes:
        - name: config-volume
          configMap:
            name: my-configmap
# rest of the file
```