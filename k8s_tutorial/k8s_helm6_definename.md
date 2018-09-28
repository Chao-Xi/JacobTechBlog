![Alt Image Text](images/helm/helm6_0.jpg "Headline image")

# Helm模板之命名模板

在实际的应用中，很多都是相对比较复杂的，往往会超过一个模板，如果有多个应用模板，我们应该如何进行处理呢？这就需要用到新的概念：`命名模板`。

### 1.命名模板我们也可以称为`子模板`，是限定在`一个文件内部的模板`，然后给一个名称。
在使用命名模板的时候有一个需要特别注意的是：**模板名称是全局的，如果我们声明了两个相同名称的模板，最后加载的一个模板会覆盖掉另外的模板**，由于子 `chart` 中的模板也是和顶层的模板一起编译的，所以在命名的时候一定要注意，**不要重名了**。

### 为了避免重名，有个通用的约定就是为每个定义的模板添加上 `chart` 名称：`{{define "mychart.labels"}}`，`define`关键字就是用来声明命名模板的，加上 `chart` 名称就可以避免不同 `chart` 间的模板出现冲突的情况。

## 声明和使用命名模板

使用`define`关键字就可以允许我们在模板文件内部创建一个命名模板，它的语法格式如下：

```
{{ define "ChartName.TplName" }}
# 模板内容区域
{{ end }}
```

比如，现在我们可以定义一个模板来封装一个 `label` 标签：

```
{{- define "mychart.labels" }}
  labels:
    from: helm
    date: {{ now | htmlDate }}
{{- end }}
```
然后我们可以将该模板嵌入到现有的 `ConfigMap` 中，然后使用`template`关键字在需要的地方包含进来即可：

```
{{- define "mychart.labels" }}
  labels:
    from: helm
    date: {{ now | htmlDate }}
{{- end }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-configmap
  {{- template "mychart.labels" }}
data:
  {{- range $key, $value := .Values.course }}
  {{ $key }}: {{ $value | quote }}
  {{- end }}
```

我们这个模板文件被渲染过后的结果如下所示：

```
$ helm install --dry-run --debug ./mychart/
[debug] Created tunnel using local port: '38763'

[debug] SERVER: "127.0.0.1:38763"

[debug] Original chart version: ""
[debug] CHART PATH: /home/vagrant/helm/mychart

...

---
# Source: mychart/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: ironic-mastiff-configmap
  labels:
    from: helm
    date: 2018-09-28
data:
  k8s: "devops"
  python: "django"
```


我们可以看到`define`区域定义的命名模板被嵌入到了template所在的区域，但是如果我们将命名模板全都写入到一个模板文件中的话无疑也会增大模板的复杂性。

还记得我们在创建 chart 包的时候，templates 目录下面默认会生成一个_helpers.tpl文件吗？我们前面也提到过 templates 目录下面除了`NOTES.txt`文件和`以下划线_开头命令的文件`之外，都会被当做 `kubernetes` 的资源清单文件，**而这个下划线开头的文件不会被当做资源清单外**，还可以被其他 `chart ` 模板中调用，这个就是 `Helm` 中的`partials`文件，所以其实我们完全就可以将命名模板定义在这些`partials`文件中，默认就是`_helpers.tpl`文件了。

现在我们将上面定义的命名模板移动到 `templates/_helpers.tpl` 文件中去：

```
{{/* 生成基本的 labels 标签 */}}
{{- define "mychart.labels" }}
  labels:
    from: helm
    date: {{ now | htmlDate }}
{{- end }}
```

### 一般情况下面，我们都会在命名模板头部加一个简单的文档块，用`/**/`包裹起来，用来描述我们这个命名模板的用途的。 

现在我们讲命名模板从模板文件 `templates/configmap.yaml` 中移除，当然还是需要保留 `template` 来嵌入命名模板内容，名称还是之前的 `mychart.lables`，这是因为**模板名称是全局的**，所以我们可以能够直接获取到。我们再用 `DEBUG` 模式来调试下是否符合预期？

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-configmap
  {{- template "mychart.labels" }}
data:
  {{- range $key, $value := .Values.course }}
  {{ $key }}: {{ $value | quote }}
  {{- end }}
```

```
$ helm install --dry-run --debug ./mychart/
[debug] Created tunnel using local port: '41818'

[debug] SERVER: "127.0.0.1:41818"

[debug] Original chart version: ""
[debug] CHART PATH: /home/vagrant/helm/mychart

NAME:   lolling-panther
...
---
# Source: mychart/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: lolling-panther-configmap
  labels:
    from: helm
    date: 2018-09-28
data:
  k8s: "devops"
  python: "django"
```

## 模板范围

上面我们定义的命名模板中，没有使用任何对象，只是使用了一个简单的函数，如果我们在里面来使用 chart 对象相关信息呢：

```
{{/* 生成基本的 labels 标签 */}}
{{- define "mychart.labels" }}
  labels:
    from: helm
    date: {{ now | htmlDate }}
    chart: {{ .Chart.Name }}
    version: {{ .Chart.Version }}
{{- end }}
```

如果这样的直接进行渲染测试的话，是不会得到我们的预期结果的：

```
$ helm install --dry-run --debug .
[debug] Created tunnel using local port: '42058'

...
# Source: mychart/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: peeking-zorse-configmap
  labels:
    from: helm
    date: 2018-09-22
    chart:
    version:
data:
  k8s: "devops"
  python: "django"

```

`chart` 的名称和版本都没有正确被渲染，这是因为他们不在我们定义的模板范围内，

### 当命名模板被渲染时，它会接收由 `template` 调用时传入的作用域，有我们我们这里并没有传入对应的作用域，因此模板中我们无法调用到 `.Chart` 对象，要解决也非常简单，我们只需要在 `template` 后面加上作用域范围即可：

```
...
{{- template "mychart.labels" .}}
...
```

如果这样的直接进行渲染测试的话，是不会得到我们的预期结果的：

```
$ helm install --dry-run --debug ./mychart/
[debug] Created tunnel using local port: '39750'
...
course:
  k8s: devops
  python: django
courselist:
- k8s
- python
- search
- golang

HOOKS:
MANIFEST:

---
# Source: mychart/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nuanced-lynx-configmap
  labels:
    from: helm
    date: 2018-09-28
    chart: mychart
    version: 0.1.0
data:
  k8s: "devops"
  python: "django"
```

我们可以看到 chart 的名称和版本号都已经被正常渲染出来了。

## include 函数

假如现在我们将上面的定义的 `labels` 单独提取出来放置到 `_helpers.tpl` 文件中：

```
{{/* 生成基本的 labels 标签 */}}
{{- define "mychart.labels" }}
from: helm
date: {{ now | htmlDate }}
chart: {{ .Chart.Name }}
version: {{ .Chart.Version }}
{{- end }}
```

现在我们将该命名模板插入到 `configmap` 模板文件的 `labels` 部分和 `data` 部分：

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-configmap
  labels:
    {{- template "mychart.labels" . }}
data:
  {{- range $key, $value := .Values.course }}
  {{ $key }}: {{ $value | quote }}
  {{- end }}
  {{- template "mychart.labels" . }}
```

然后同样的查看下渲染的结果：

```
$ helm install --dry-run --debug ./mychart/
[debug] Created tunnel using local port: '34995'

[debug] SERVER: "127.0.0.1:34995"

[debug] Original chart version: ""
[debug] CHART PATH: /home/vagrant/helm/mychart
...

---
# Source: mychart/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: jolly-owl-configmap
  labels:
from: helm
date: 2018-09-28
chart: mychart
version: 0.1.0
data:
  k8s: "devops"
  python: "django"
from: helm
date: 2018-09-28
chart: mychart
version: 0.1.0
    version: 0.1.0
```
我们可以看到渲染结果是有问题的，不是一个正常的 `YAML` 文件格式，这是因为`template`只是表示一个嵌入动作而已，不是一个函数，所以原本命名模板中是怎样的格式就是怎样的格式被嵌入进来了，
**比如我们可以在命名模板中给内容区域都空了两个空格，再来查看下渲染的结构**

```
{{/* 生成基本的 labels 标签 */}}
{{- define "mychart.labels" }}
  from: helm
  date: {{ now | htmlDate }}
  chart: {{ .Chart.Name }}
  version: {{ .Chart.Version }}
{{- end }}

```

```
$ helm install --dry-run --debug ./mychart/
[debug] Created tunnel using local port: '40979'
...

---
# Source: mychart/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: esteemed-elk-configmap
  labels:
  from: helm
  date: 2018-09-28
  chart: mychart
  version: 0.1.0
data:
  k8s: "devops"
  python: "django"
  from: helm
  date: 2018-09-28
  chart: mychart
  version: 0.1.0
```

我们可以看到 `data` 区域里面的内容是渲染正确的，但是上面 `labels` 区域是不正常的，因为命名模板里面的内容是属于 `labels` 标签的，是不符合我们的预期的，但是我们又不可能再去把命名模板里面的内容再增加两个空格，因为这样的话 `data` 里面的格式又不符合预期了。

为了解决这个问题，`Helm` 提供了另外一个方案来代替template，那就是使用`include`函数，在需要控制空格的地方使用`indent`管道函数来自己控制，比如上面的例子我们替换成`include`函数：

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-configmap
  labels:
{{- include "mychart.labels" . | indent 2 }}
data:
  {{- range $key, $value := .Values.course }}
  {{ $key }}: {{ $value | quote }}
  {{- end }}
{{- include "mychart.labels" . }}
```
在 `labels` 区域我们需要`4`个空格，所以在管道函数`indent`中，传入参数`2`就可以，而在 `data` 区域我们只需要`0`个空格，所以我们传入参数`2`即可以，现在我们来渲染下我们这个模板看看是否符合预期呢：

```
$ helm install --dry-run --debug ./mychart/
[debug] Created tunnel using local port: '32997'

[debug] SERVER: "127.0.0.1:32997"

[debug] Original chart version: ""
[debug] CHART PATH: /home/vagrant/helm/mychart
...
---
# Source: mychart/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: doltish-lionfish-configmap
  labels:
    from: helm
    date: 2018-09-28
    chart: mychart
    version: 0.1.0
data:
  k8s: "devops"
  python: "django"
  from: helm
  date: 2018-09-28
  chart: mychart
  version: 0.1.0
 
```

可以看到是符合我们的预期，所以在 Helm 模板中我们使用 include 函数要比 template 更好，可以更好地处理 YAML 文件输出格式。


