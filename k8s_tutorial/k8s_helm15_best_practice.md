# CHART 最佳实践

## Chart 最佳实践指南

* 一般约定：了解 chart 一般约定。
* `values` 文件：查看结构化 `values.yaml` 的最佳实践。
* `Template:`：学习一些编写模板的最佳技巧。
* `Requirement`：遵循 requirements.yaml 文件的最佳做法。
* 标签和注释:：`helm` 具有标签和注释的传统。
* Kubernetes 资源：
  * `Pod` 及其规格：查看使用 `pod` 规格的最佳做法。
  * 基于角色的访问控制：有关创建和使用服务帐户，角色和角色绑定的指导。
  * 自定义资源：自定义资源（`CRDs`）有其自己的相关最佳实践。


## 一般约定

最佳实践指南的这一部分介绍了一般约定。

### Chart 名称

Chart 名称应该是小写字母和数字组成，字母开头：

举例： 可以使用破折号 `-`, 但在 `Helm templates` 中使用需要一些小技巧

```
drupal
cert-manager
oauth2-proxy
```

**`Chart` 名称中不能使用`大写字母`和`下划线`。 `Chart` 名称不应使用点。**

包含 `chart` 的目录必须与 `chart` 具有相同的名称。

因此，`chart cert-manager` 必须在名为 `cert-manager/` 的目录中创建。这不仅仅是一种风格的细节，而是 `Helm Chart` 格式的要求。

### 版本号

只要有可能，`Helm` 使用 [SemVer 2](https://semver.org/) 来表示版本号。（请注意，Docker 镜像 tag 不一定遵循 SemVer，因此被视为该规则的一个例外。）

当 `SemVer` 版本存储在 `Kubernetes` 标签中时，我们通常会将该 `+` 字符更改为一个 `_` 字符，因为标签不允许 `+` 标志作为值。

### 格式化 YAML

YAML 文件应该使用两个空格缩进（而不是制表符）。

### 单词 `Helm`，`Tiller` 和 `Chart` 的用法

使用 `Helm`，`helm`，`Tiller` 和 `tiller` 这两个词有一些小的惯例。

* `Helm` 是指该项目，通常用作总括术语
* `helm` 指的是客户端命令
* `Tiller` 是后端的专有名称
* `tiller` 是后端二进制运行的名称
* 术语 “chart” 不需要大写，因为它不是专有名词。

如有疑问，请使用 Helm（大写'H'）。

### 通过版本限制 Tiller

一个 `Chart.yaml` 文件可以指定一个 `tillerVersion` SemVer 约束：

```
name: mychart
version: 0.2.0
tillerVersion: ">=2.4.0"
```

当模板使用 `Helm` 旧版本不支持的新功能时，应该设置此限制。虽然此参数将接受复杂的 SemVer 规则，但最佳做法是默认为格式 `>=2.4.0`，其中 `2.4.0` 引入了 `chart` 中使用的新功能的版本。

此功能是在`Helm 2.4.0`中引入的，因此任何`2.4.0`版本以下的`Tiller`都会忽略此字段。

## Values

这部分最佳实践指南涵盖了 `values` 的使用。在指南的这一部分，我们提供关于如何构建和使用 values 的建议，重点在于设计 `chart` 的 `values.yaml` 文件。


### 命名约定

**变量名称应该以小写字母开头**，单词应该用 `camelcase` 分隔：

正确写法：

```
chicken: true
chickenNoodleSoup: true
```

不正确写法：

```
Chicken: true  # initial caps may conflict with built-ins
chicken-noodle-soup: true # do not use hyphens in the name
```

请注意，`Helm` 的所有内置变量都以大写字母开头，以便将它们与用户定义的 `value` 区分开来，如：`.Release.Name`， `.Capabilities.KubeVersion`。

### 展平或嵌套值

YAML 是一种灵活的格式，并且值可以嵌套或扁平化。

**嵌套**：

```
server:
  name: nginx
  port: 80
```

**展平**：

```
serverName: nginx
serverPort: 80
```

在大多数情况下，展平应该比嵌套更受青睐。原因是对模板开发人员和用户来说更简单。

**为了获得最佳安全性，必须在每个级别检查嵌套值**：

```
{{if .Values.server}}
  {{default "none" .Values.server.name}}
{{end}}
```

对于每一层嵌套，都必须进行存在检查。但对于展平配置，可以跳过这些检查，使模板更易于阅读和使用。

```
{{default "none" .Values.serverName}}
```

当有大量相关变量时，且至少有一个是非可选的，可以使用嵌套值来提高可读性。

### 使类型清晰

YAML 的类型强制规则有时是违反直觉的。例如， `foo: false` 与 `foo: "false"` 不一样。`foo: 12345678` 在某些情况下，大整数将被转换为科学记数法。

避免类型转换错误的最简单方法是明确地表示字符串，并隐含其他所有内容。或者，简而言之，引用所有字符串。

通常，为了避免整型转换问题，最好将整型存储为字符串，并在模板中使用 `{{int $value}} `将字符串转换为整数。

在大多数情况下，显式类型标签受到重视，所以 `foo: !!string 1234 `应该将 1234 视 为一个字符串。但是，YAML 解析器消费标签，因此类型数据在解析后会丢失。


### 考虑用户如何使用你的 values


有几种潜在的 values 来源：

* `chart` 的 `values.yaml` 文件
* 由 `helm install -f` 或 `helm upgrade -f` 提供的 `value` 文件
* 传递给 `--set` 或的 `--set-string` 标志 `helm install` 或 `helm upgrade` 命令
* 通过 `--set-file` 将文件内容传递给 `helm install` or `helm upgrade`


在设计 value 的结构时，请记住 chart 的用户可能希望通过 `-f` 标志或 `--set `选项覆盖它们。

由于 `--set` 在表现力方面比较有限，编写 `values.yaml` 文件的第一个指导原则可以轻松使用 `--set` 覆盖。

出于这个原因，使用 `map` 来构建 `value` 文件通常会更好。

难以配合 `--set` 使用：

```
servers:
  - name: foo
    port: 80
  - name: bar
    port: 81
```


`Helm <=2.4` 时，以上不能用 `--set` 来表示。在 Helm 2.5 中，访问 foo 上的端口是 --set servers[0].port=80。用户不仅难以弄清楚，而且如果稍后 servers 改变顺序，则容易出错。

使用方便：

```
servers:
  foo:
    port: 80
  bar:
    port: 81
```

访问 `foo` 的端口更为方便：`--set servers.foo.port=80`。

### 文档'values.yaml'


应该记录'values.yaml'中的每个定义的属性。文档字符串应该以它描述的属性的名称开始，然后至少给出一个单句描述。

不正确：

```
# the host name for the webserver
serverHost = example
serverPort = 9191
```

正确：

```
# serverHost is the host name for the webserver
serverHost = example
# serverPort is the HTTP listener port for the webserver
serverPort = 9191
```

使用参数名称开始每个注释，它使文档易于grep，并使文档工具能够可靠地将文档字符串与其描述的参数关联起来。


## 模板

最佳实践指南的这一部分重点介绍模板。

### templates 目录结构

templates 目目录的结构应如下所示：

* 如果他们产生 `YAML` 输出，模板文件应该有扩展名 `.yaml`。扩展名. `tpl` 可用于产生不需要格式化内容的模板文件。
* 模板文件名应该使用横线符号（ `my-example-configmap.yaml `），而不是 `camelcase`。
* 每个资源定义应该在它自己的模板文件中。
* 模板文件名应该反映名称中的资源种类。例如 `foo-pod.yaml`， `bar-svc.yaml`

### 定义模板的名称

定义的模板（在 `{{define}}` 指令内创建的模板）可以全局访问。这意味着 `chart` 及其所有子 `chart` 都可以访问所有使用 `{{ define }} ` 创建的模板。

出于这个原因，所有定义的模板名称应该是带有某个 `namespace`。

正确：

```
{{- define "nginx.fullname"}}
{{/* ... */}}
{{end -}}
```

不正确：

```
{{- define "fullname" -}}
{{/* ... */}}
{{end -}}
```

强烈建议通过 `helm create` 命令创建新 `chart`，因为根据此最佳做法自动定义模板名称。


### 格式化模板


模板应该使用两个空格缩进（不是制表符）。

**模板指令在大括号之后和大括号之前应该有空格：**

正确：

```
{{.foo}}
{{print "foo"}}
{{- print "bar" -}}
```

**`{{- print "bar" -}}`**

不正确：

```
{{.foo}}
{{print "foo"}}
{{-print "bar"-}}
```

模板应尽可能地填充空格：

```
foo:
  {{- range .Values.items}}
  {{.}}
  {{end -}}
```

* **`{{- range .Values.items}}`**
* **`{{end -}}`**

**块（如控制结构）可以缩进以指示模板代码的流向**。

```
{{if $foo -}}
  {{- with .Bar}}Hello{{ end -}}
{{- end -}}
```

但是，由于 YAML 是一种面向空格的语言，因此代码缩进有时经常不能遵循该约定。

### 生成模板中的空格

最好将生成的模板中的空格保持最小。特别是，许多空行不应该彼此相邻。但偶尔空行（特别是逻辑段之间）很好。

这是最好的：

```
apiVersion: batch/v1
kind: Job
metadata:
  name: example
  labels:
    first: first
    second: second
```

这没关系：


```
apiVersion: batch/v1
kind: Job

metadata:
  name: example

  labels:
    first: first
    second: second
```

但这应该避免：

```
apiVersion: batch/v1
kind: Job

metadata:
  name: example





  labels:
    first: first

    second: second
```

### 注释（YAML 注释与模板注释）

YAML 和头盔模板都有注释标记。

YAML 注释：

```
# This is a comment
type: sprocket
```

模板注释：

```
{{- /*
This is a comment.
*/ -}}
type: frobnitz
```

记录模板功能时应使用模板注释，如解释定义的模板：

```

{{- /*
mychart.shortname provides a 6 char truncated version of the release name.
*/ -}}
{{define "mychart.shortname" -}}
{{.Release.Name | trunc 6}}
{{- end -}}
```
在模板内部，当 Helm 用户可能（有可能）在调试过程中看到注释时，可以使用 YAML 注释。

```
# This may cause problems if the value is more than 100Gi
memory: {{.Values.maxMem | quote}}
```

上面的注释在用户运行 `helm install --debug` 时可见，而在 `{{- /* */ -}}` 部分中指定的注释不是。

### 在模板和模板输出中使用 JSON


YAML 是 JSON 的超集。在某些情况下，使用 JSON 语法可以比其他 YAML 表示更具可读性。

例如，这个 YAML 更接近表达列表的正常 YAML 方法：

```
arguments:
  - "--dirname"
  - "/foo"
```

但是，当折叠为 JSON 列表样式时，它更容易阅读：

```
arguments: ["--dirname", "/foo"]
```

使用 JSON 增加易读性是很好的。但是，不应该使用 JSON 语法来表示更复杂的构造。

在处理嵌入到`YAML`中的纯`JSON`时（例如`init`容器配置），使用JSON格式当然是合适的。


## Requirements 文件

### 版本

在可能的情况下，使用版本范围，而不是固定到确切版本。建议的默认值是使用补丁级别的版本匹配：

```
version: ~1.2.3
```
这将匹配版本 `1.2.3` 和该版本的任何补丁。换句话说，`~1.2.3` 相当于 `>= 1.2.3`, `< 1.3.0`

### 存储库 URL

如有可能，请使用 `https://` 存 储库 URL，然后使用 `http://URL`。

**如果存储库已添加到存储库索引文件，则存储库名称可用作 `URL` 的别名。使用 `alias:` 或 `@` 跟随存储库名称。**

文件 `URL（file://...）`被视为对于由固定部署管道组装的 chart“特殊情况”。正式 `Helm` 库中是不允许在一个 `requirements.yaml` 使用 `file://` 的。

### 条件和标签


条件或标签应添加到任何可选的依赖项中。

条件的优选形式是：

```
condition: somechart.enabled
```

**`somechart` 是依赖的 `chart` 名称**

当多个子 `chart`（依赖关系）一起提供可选或可交换功能时，这些图应共享相同的标签。

**例如，如果 `nginx` 和 `memcached` 在一起，共同提供性能优化，给 `chart` 中的主应用程序，并要求已启用该功能时两者都存在，那么他们可能有这样的标记：**

```
tags:
  - webaccelerator
```

这允许用户使用一个标签打开和关闭该功能。

## 标签和注释

### 它是一个标签还是一个注释？

在下列条件下，元数据项应该是标签：

* Kubernetes 使用它来识别此资源
* 为了查询系统目的，向操作员暴露是非常有用的。

例如，我们建议使用 `helm.sh/chart: NAME-VERSION` 标签作为标签，以便操作员可以方便地查找要使用的特定 `chart` 的所有实例。

如果元数据项不用于查询，则应将其设置为注释。

`Helm hook` 总是注释。

## Pod 和 Pod 模板

以下（非详尽）资源列表使用 PodTemplates：

* Deployment
* ReplicationController
* ReplicaSet
* DaemonSet
* StatefulSet

### 镜像

容器镜像应该使用固定标签或镜像的 SHA。它不应该使用的标签 `latest`，`head`，`canary`，或其他设计为 “浮动” 的标签。

镜像可以在 `values.yaml` 文件中定义，可以很容易地换为镜像地址。

```
image: {{.Values.redisImage | quote}}
```

镜像和标签可以在 `values.yaml` 中定义为两个单独的字段：

```
image: "{{.Values.redisImage}}:{{ .Values.redisTag }}"
```

### ImagePullPolicy

`helm create` 设置 `imagePullPolicy` 为 `IfNotPresent`, 在 `deployment.yaml` 中：

```
imagePullPolicy: {{.Values.image.pullPolicy}}
```

和 `values.yaml` 中：

```
pullPolicy: IfNotPresent
```

同样，`Kubernetes` 默认 `imagePullPolicy` 为 `IfNotPresent`，如果它根本没有被定义。如果想要的值不是 `IfNotPresent`，只需将 `values.yaml` 中的值更新为所需的值即可。

### PodTemplates 应声明选择器

所有的 PodTemplate 部分都应该指定一个选择器。例如：

```
selector:
  matchLabels:
      app.kubernetes.io/name: MyName
template:
  metadata:
    labels:
      app.kubernetes.io/name: MyName
```

这是一个很好的做法，因为它可以使 `set` 和 `pod` 之间保持关系。

但对于像Deployment这样的集合来说，这更为重要。如果没有这一点，整套标签将用于选择匹配的pod，如果使用的标签（如版本或发布日期）变化了，则将会导致app中断。

## 自定义资源定义

使用自定义资源定义（CRD）时，区分两个不同的部分很重要：

* 有一个 `CRD` 的声明。这是一个 `YAML` 文件，`kind` 类型为 `CustomResourceDefinition`
* 然后有资源使用 `CRD`。`CRD` 定义 `foo.example.com/v1`。任何拥有 `apiVersion: example.com/v1` 和种类 Foo 的资源都是使用 CRD 的资源

### 在使用资源之前安装 CRD 声明

Helm 优化为尽可能快地将尽可能多的资源加载到 Kubernetes 中。通过设计，Kubernetes 可以采取一整套 manifests，并将它们全部启动在线（这称为 reconciliation 循环）。

但是与 CRD 有所不同。

对于 `CRD`，声明必须在该 `CRDs` 种类的任何资源可以使用之前进行注册。注册过程有时需要几秒钟。


#### 方法 1：独立的 chart

一种方法是将 CRD 定义放在一个 chart 中，然后将所有使用该 CRD 的资源放入另一个 chart 中。

在这种方法中，每个 chart 必须单独安装。


#### 方法 2：预安装 hook

要将这两者打包在一起，在 `CRD` 定义中添加一个 `crd-install` 钩子，以便在执行 `chart` 的其余部分之前完全安装它。

请注意，如果使用`crd-install hook`创建`CRD` ，则该 `CRD` 定义在 `helm delete` 运行时不会被删除。

## 基于角色的访问控制


RBAC 资源是：

* ServiceAccount (namespaced)
* Role (namespaced)
* ClusterRole
* RoleBinding (namespaced)
* ClusterRoleBinding

### YAML 配置

`RBAC` 和 `ServiceAccount` 配置应该在单独的密钥下进行。他们是不同的东西。将 YAML 中的这两个概念拆分出来可以消除混淆并使其更清晰。

```
rbac:
  # Specifies whether RBAC resources should be created
  create: true

serviceAccount:
  # Specifies whether a ServiceAccount should be created
  create: true
  # The name of the ServiceAccount to use.
  # If not set and create is true, a name is generated using the fullname template
  name
```

此结构可以扩展到需要多个 `ServiceAccounts` 的更复杂的 chart。

```
serviceAccounts:
  client:
    create: true
    name:
  server:
    create: true
    name:
```

### RBAC 资源应该默认创建

`rbac.create` 应该是一个布尔值，控制是否创建 `RBAC` 资源。默认应该是 `true`。想要管理 `RBAC` 访问控制的用户可以将此值设置为 `false`（在这种情况下请参阅下文）。

#### 使用 RBAC 资源

`serviceAccount.name` 应设置为由 `chart` 创建的访问控制资源使用的 `ServiceAccount` 的名称。如果 `serviceAccount.create` 为 `true`，则应该创建一个带有该名称的 `ServiceAccount`。

如果名称未设置，则使用该 `fullname` 模板生成名称，如果 `serviceAccount.create` 为 `false`，则不应创建该名称，但它仍应与相同的资源相关联，以便稍后通过手动创建的 RBAC 资源将引用它从而功能正常。如果 `serviceAccount.create` 为 `false` 且名称未指定，则使用默认的 `ServiceAccount`。

为 `ServiceAccount` 使用以下 `helper` 模板。

```
{{/*
Create the name of the service account to use
*/}}
{{- define "mychart.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "mychart.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}
```



