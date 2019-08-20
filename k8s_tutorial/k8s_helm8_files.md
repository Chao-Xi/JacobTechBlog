# `Helm` 文件系统

* 模板内访问文件
* `NOTES.txt` 文件
* `.helmignore` 文件

## 模板内访问文件


在上一节中，我们介绍了几种创建和访问命名模板的方法。**这可以很容易地从另一个模板中导入一个模板。但有时需要导入不是模板的文件，并注入其内容而不通过模板渲染器发送内容。**

### `Helm` 通过 `.Files` 对象提供对文件的访问。在我们开始使用模板示例之前，需要注意一些关于它如何工作的内容：

* 向 `Helm chart` 添加额外的文件是可以的。这些文件将被捆绑并发送给 `Tiller`。不过要注意，由于 `Kubernetes` 对象的存储限制，`chart` 必须小于 `1M`。
* 通常出于安全原因，某些文件不能通过 `.Files` 对象访问。
 * **`templates/` 无法访问文件。**
 * 使用 `.helmignore` 排除的文件不能被访问。
* chart 不保留 UNIX 模式信息，因此文件级权限在涉及 .Files 对象时不会影响文件的可用性。

## 基本示例

留意这些注意事项，我们编写一个模板，从三个文件读入我们的` ConfigMap`。首先，我们将三个文件添加到 `char` 中，**将所有三个文件直接放在 `mychart /` 目录中**。



`config1.toml`:

```
message = Hello from config 1
```

`config2.toml:`

```
message = This is config 2
```

`config3.toml:`

```
message = Goodbye from config 3
```

这些都是一个简单的 `TOML` 文件（想想老派的 `Windows INI` 文件）。我们知道这些文件的名称，所以我们可以使用一个 `range` 函数来遍历它们并将它们的内容注入到我们的 `ConfigMap` 中。

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
  {{- $files := .Files}}
  {{- range tuple "config1.toml" "config2.toml" "config3.toml"}}
  {{.}}: |-
    {{$files.Get .}}
  {{- end}}
```

```
.
├── Chart.yaml
├── charts
├── config1.toml
├── config2.toml
├── config3.toml
├── templates
│   ├── NOTES.txt
│   ├── _helpers.tpl
│   └── configmap.yaml
└── values.yaml

2 directories, 8 files
```

这个配置映射使用了前几节讨论的几种技术。例如，

* 我们创建一个 `$files` 变量来保存 `.Files` 对象的引用。
* 我们还使用该 `tuple` 函数来创建我们循环访问的文件列表。
* 然后我们打印每个文件名（`{{.}}: |-`），
* 然后打印文件的内容 `{{ $files.Get . }}`。

运行这个模板将产生一个包含所有三个文件内容的 `ConfigMap`：

```
$ helm install --dry-run --debug ./mychart/
[debug] Created tunnel using local port: '52049'

[debug] SERVER: "127.0.0.1:52049"

[debug] Original chart version: ""
[debug] CHART PATH: /Users/i515190/k8s_sap/test/mychart

NAME:   binging-scorpion
REVISION: 1
RELEASED: Sat Aug 24 08:58:42 2019
CHART: mychart-0.1.0
USER-SUPPLIED VALUES:
{}

COMPUTED VALUES:
course:
  kubernetes: devops
  python: data_analysis
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
  name: binging-scorpion-configmap
  labels:
    from: helm
    date: 2019-08-24
    chart: mychart
    version: 0.1.0
data:
  kubernetes: "devops"
  python: "data_analysis"
  from: helm
  date: 2019-08-24
  chart: mychart
  version: 0.1.0
  config1.toml: |-
    message = Hello from config 1

  config2.toml: |-
    message = This is config 2

  config3.toml: |-
    message = Goodbye from config 3
```

### 路径助手


在处理文件时，对文件路径本身执行一些标准操作会非常有用。为了协助这个能力，Helm 从 Go 的 path 包中导入了许多函数供使用。它们都可以使用 Go 包中的相同名称访问，但使用时小写第一个字母，例如，`Base` 变成 `base`，等等

导入的功能是：

* Base
* Dir
* Ext
* IsAbs
* Clean

### Glob 模式


随着 `chart` 的增长，可能会发现需要组织更多地文件，因此我们提供了一种 `Files.Glob(pattern string`) 方法通过具有灵活性的模式 glob patterns 协助提取文件。

`.Glob` 返回一个 `Files` 类型，所以可以调用 `Files` 返回对象的任何方法。

例如，想象一下目录结构：


```
foo/:
  foo.txt foo.yaml

bar/:
  bar.go bar.conf baz.yaml
```

Globs 有多个方法可选择：

```
{{$root := .}}
{{range $path, $bytes := .Files.Glob "**.yaml"}}
{{$path}}: |-
{{$root.Files.Get $path}}
{{end}}
```

或

```
{{range $path, $bytes := .Files.Glob "foo/*"}}
{{$path.base}}: '{{ $root.Files.Get $path | b64enc }}'
{{end}}
```

### ConfigMap 和 Secrets 工具函数

想要将文件内容放置到 `configmap` 和 `secret` 中非常常见，以便在运行时安装到 `pod` 中。为了解决这个问题，我们在这个 `Files` 类型上提供了一些实用的方法。

为了进一步组织文件，将这些方法与 `Glob` 方法结合使用尤其有用。
根据上面的 Glob 示例中的目录结构：

根据上面的 `Glob` 示例中的目录结构：

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: conf
data:
  {{- (.Files.Glob "foo/*").AsConfig | nindent 2 }}
---
apiVersion: v1
kind: Secret
metadata:
  name: very-secret
type: Opaque
data:
  {{(.Files.Glob "bar/*").AsSecrets | nindent 2 }}
```

### 编码

我们可以导入一个文件，并使用 base64 对模板进行编码以确保成功传输：

```
apiVersion: v1
kind: Secret
metadata:
  name: {{.Release.Name}}-secret
type: Opaque
data:
  token: |-
    {{.Files.Get "config1.toml" | b64enc}}
```

以上例子将采用 `config1.toml` 文件，我们之前使用的相同文件并对其进行编码：

```
# Source: mychart/templates/secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: lucky-turkey-secret
type: Opaque
data:
  token: |-
    bWVzc2FnZSA9IEhlbGxvIGZyb20gY29uZmlnIDEK
```

### 行

有时需要访问模板中文件的每一行。`Lines` 为此提供了一种方便的方法。

```
data:
  some-file.txt: {{range .Files.Lines "foo/bar.txt"}}
    {{.}}{{ end }}
```

目前，无法将 `helm install` 期间将外部文件传递给 `chart`。因此，如果要求用户提供数据，则必须使用 `helm install -f` 或进行加载 `helm install --set`。

## NOTES.txt 文件

我们前面在使用 `helm install` 命令的时候，`Helm` 都会为我们打印出一大堆介绍信息，这样当别的用户在使用我们的 chart 包的时候就可以根据这些注释信息快速了解我们的 `chart` 包的使用方法，这些信息就是编写在 `NOTES.txt` 文件之中的，这个文件是纯文本的，但是它和其他模板一样，**具有所有可用的普通模板函数和对象**。

现在我们在前面的示例中 `templates` 目录下面创建一个 `NOTES.txt` 文件

```
$ cd /helm/mychart/templates
$ vi NOTES.txt


Your release is named {{ .Release.Name }}.

To learn more about the release, try:

  $ helm status {{ .Release.Name }}
  $ helm get {{ .Release.Name }}
```

我们可以看到我们在 `NOTES.txt` 文件中也使用 `Chart` 和 `Release` 对象，现在我们在 `mychart` 包根目录下面执行安装命令查看是否能够得到上面的注释信息：

```
$ cd ..
$ helm install .

$ helm install .
NAME:   masked-ocelot
LAST DEPLOYED: Tue Oct 16 08:44:41 2018
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/ConfigMap
NAME                     DATA  AGE
masked-ocelot-configmap  6     0s


NOTES:
Thank you for installing mychart.

Your release is named masked-ocelot.

To learn more about the release, try:

  $ helm status masked-ocelot
  $ helm get masked-ocelot
```

```
$ helm list
NAME         	REVISION	UPDATED                 	STATUS  	CHART        	NAMESPACE
masked-ocelot	1       	Tue Oct 16 08:44:41 2018	DEPLOYED	mychart-0.1.0	default
```

```
$ helm delete masked-ocelot
release "masked-ocelot" deleted

$ helm list --all
NAME         	REVISION	UPDATED                 	STATUS 	CHART           	NAMESPACE
lanky-lion   	1       	Wed Sep 26 09:30:34 2018	DELETED	hello-helm-0.1.0	default
masked-ocelot	1       	Tue Oct 16 08:44:41 2018	DELETED	mychart-0.1.0   	default
```

现在已经安装成功了，而且下面的注释部分也被渲染出来了，我们可以看到 NOTES.txt 里面使用到的模板对象都被正确渲染了。

为我们创建的 chart 包提供一个清晰的 `NOTES.txt` 文件是非常有必要的，可以为用户提供有关如何使用新安装 `chart` 的详细信息，这是一种非常友好的方式方法

## `.helmignore` 文件

`.helmignore` 文件用于指定不想包含在 `helm chart` 中的文件。

如果此文件存在，`helm package` 命令将在打包应用程序时忽略在 `.helmignore` 文件中指定的模式匹配的所有文件。

这有助于避免在 `helmchart` 中添加不需要或敏感的文件或目录。

`.helmignore` 文件支持 Unix shell glob 匹配，相对路径匹配和否定（以`！`为前缀）。每行只考虑一种模式。

这是一个示例 `.helmignore` 文件：

```
# comment
.git
*/temp*
*/*/temp*
temp?
```
