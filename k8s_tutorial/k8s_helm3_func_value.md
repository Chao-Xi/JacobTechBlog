![Alt Image Text](images/helm/helm3_0.jpg "Headline image")
# Helm 模板之内置函数和Values

* Charts
* 定义 `chart`
* 创建模板
* 添加一个简单的模板
* 内置对象
* `values` 文件

## Charts

如 `chart` 指南中所述，`Helm chart` 的结构如下所示：

```
mychart/
  Chart.yaml
  values.yaml
  charts/
  templates/
  ...
```

**`templates/` 目录用于放置模板文件。当 `Tiller` 评估 `chart` 时，它将 `templates/` 通过模板渲染引擎发送目录中的所有文件。然后，`Tiller` 收集这些模板的结果并将它们发送给 `Kubernetes`。**

`values.yaml` 文件对模板也很重要。该文件包含 `char`t 默认值。这些值可能在用户在 `helm install` 或 `helm upgrade  --install` 期间被覆盖。

#### `Chart.yaml` 文件包含 `chart` 的说明。

可以从模板中查看访问它。该 `charts/` 目录可能包含其他 `chart`（我们称之为子 chart）。在本指南的后面，我们将看到它们在模板渲染方面如何起作用。


## 定义 chart

`Helm` 的 `github` 上面有一个[比较完整的文档](https://github.com/helm/helm/blob/master/docs/charts.md)，建议大家好好阅读下该文档，这里我们来一起创建一个`chart`包。

一个 `chart` 包就是一个文件夹的集合，文件夹名称就是 `chart` 包的名称，比如创建一个 `mychart` 的 `chart` 包：

```
$ helm create mychart
Creating mychart

$ tree mychart/
mychart/
├── charts
├── Chart.yaml
├── templates
│   ├── deployment.yaml
│   ├── _helpers.tpl
│   ├── ingress.yaml
│   ├── NOTES.txt
│   └── service.yaml
└── values.yaml

2 directories, 7 files
```

我们来仔细看看 `templates` 目录下面的文件:

* `NOTES.txt`：chart 的 “帮助文本”。这会在用户运行 `helm install` 时显示给用户。
* `deployment.yaml`：创建 `Kubernetes deployment` 的基本 `manifest`
* `service.yaml`：为 `deployment` 创建 `service` 的基本 `manifest`
* `ingress.yaml`: 创建 `ingress` 对象的资源清单文件
* `_helpers.tpl`：放置模板助手的地方，可以在整个 `chart` 中重复使用

这里我们明白每一个文件是干嘛的就行，然后我们把 `templates` 目录下面所有文件全部删除掉，这里我们自己来创建模板文件：

```
$ rm -rf mychart/templates/*.*
```

在编写生产级 `chart` 时，使用这些 `chart` 的基本版本可能非常有用。所以在你的日常 `chart` 制作中，可以不删除它们。


## 创建模板

这里我们来创建一个非常简单的模板 `ConfigMap`，在 `templates` 目录下面新建一个`configmap.yaml`文件：

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: mychart-configmap
data:
  myvalue: "Hello World"
```

**提示**： 模板名称不遵循严格的命名模式。但是，我们建议 `.yaml` 为 YAML 文件后缀，`.tpl` 为模板助手后缀。

上面的 `YAML` 文件是一个简单的 `ConfigMap`，具有最少的必要字段。由于该文件位于 `templates/` 目录中，因此将通过模板引擎发送。

在 `templates/` 目录中放置一个像这样的纯 `YAML` 文件。当 `Tiller` 读取这个模板时，它会直接发送给 `Kubernetes`。

实际上现在我们就有一个可安装的 `chart` 包了，通过`helm install`命令来进行安装：

```
$ helm install ./mychart/
NAME:   eyewitness-grasshopper
LAST DEPLOYED: Thu Sep 27 06:56:18 2018
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/ConfigMap
NAME               DATA  AGE
mychart-configmap  1     1s
```

在上面的输出中，我们可以看到我们的 `ConfigMap` 资源对象已经创建了。然后使用如下命令我们可以看到实际的模板被渲染过后的资源文件：

```
$ helm get eyewitness-grasshopper
REVISION: 1
RELEASED: Thu Sep 27 06:56:18 2018
CHART: mychart-0.1.0
USER-SUPPLIED VALUES:
{}

COMPUTED VALUES:
affinity: {}
image:
  pullPolicy: IfNotPresent
  repository: nginx
  tag: stable
ingress:
  annotations: {}
  enabled: false
  hosts:
  - chart-example.local
  path: /
  tls: []
nodeSelector: {}
replicaCount: 1
resources: {}
service:
  port: 80
  type: ClusterIP
tolerations: []

HOOKS:
MANIFEST:

---
# Source: mychart/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mychart-configmap
data:
  myvalue: "Hello World"
```

该 `helm get manifest` 命令获取 `release` 名称（eyewitness-grasshopper）并打印出上传到服务器的所有 `Kubernetes` 资源。每个文件都以 `---` 开始作为 `YAML` 文档的开始，然后是一个自动生成的注释行，告诉我们该模板文件生成的这个 `YAML` 文档。

从那里开始，我们可以看到 `YAML` 数据正是我们在我们的 `configmap.yaml` 文件中所设计的 。


现在我们看到上面的 `ConfigMap` 文件是不是正是我们前面在模板文件中设计的，现在我们删除当前的`release`:

```
$ helm list --all
NAME                  	REVISION	UPDATED                 	STATUS  	CHART           	NAMESPACE
eyewitness-grasshopper	1       	Thu Sep 27 06:56:18 2018	DEPLOYED	mychart-0.1.0   	default
```

```
$ helm delete eyewitness-grasshopper --purge
release "eyewitness-grasshopper" deleted
```
## 添加一个简单的模板

我们可以看到上面我们定义的 `ConfigMap` 的名字是固定的，但往往这并不是一种很好的做法，我们可以通过插入 `release` 的名称来生成资源的名称，比如这里 `ConfigMap` 的名称我们希望是：`{{ .Release.Name }}-configmap`，这就需要用到 `Chart` 的模板定义方法了。

需要注意的是`kubernetes`资源对象的 `labels` 和 `name` 定义被限制 `63个字符`，所以需要注意名称的定义。

现在我们来重新定义下上面的 `configmap.yaml` 文件：

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-configmap
data:
  myvalue: "Hello World"
```

我们将名称替换成了`{{ .Release.Name }}-configmap`，

其中包含在`{{`和`}}`之中的就是模板指令。

`{{ .Release.Name }}` 将 `release `的名称注入到模板中来，这样最终生成的 `ConfigMap` 名称就是以 `release` 的名称开头的了。其中 `dot（.）`分隔每个 `namespace` 元素。


`Release` 前面的前一个小圆点表示我们从这个范围的最上面的 `namespace` 开始（我们将稍微谈一下 `scope`）。所以我们可以这样理解 `.Release.Name`：**"从顶层命名空间开始，找到 Release 对象，然后在里面查找名为 Name 的对象"**。

这里的 `Release` 模板对象属于 `Helm` 内置的一种对象，还有其他很多内置的对象，稍后我们将接触到。

现在我们来重新安装我们的 `Chart` 包，注意观察 `ConfigMap` 资源对象的名称：

```
$ helm install ./mychart
NAME:   foiled-sponge
LAST DEPLOYED: Thu Sep 27 07:07:20 2018
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/ConfigMap
NAME                     DATA  AGE
foiled-sponge-configmap  1     1s
```

**注意**，在该 `RESOURCES` 部分中，我们看到的名称 `foiled-sponge-configmap` 不是 `mychart-configmap`。

可以运行 `helm get manifest foiled-sponge` 以查看整个生成的 `YAML`。

可以看到现在生成的名称变成了`foiled-sponge-configmap`，证明已经生效了，当然我们也可以使用命令`helm get manifest foiled-sponge`查看最终生成的清单文件的样子。

```
$ helm get manifest foiled-sponge

---
# Source: mychart/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: foiled-sponge-configmap
data:
  myvalue: "Hello World"
```

```
$ helm delete foiled-sponge --purge
release "foiled-sponge" deleted
```

### 调试

我们用模板来生成资源文件的清单，但是如果我们想要调试就非常不方便了，不可能我们每次都去部署一个`release`实例来校验模板是否正确，所幸的时 `Helm` 为我们提供了`--dry-run --debug`这个可选参数，在执行`helm install`的时候带上这两个参数就可以把对应的 `values` 值和生成的最终的资源清单文件打印出来，而不会真正的去部署一个`release`实例，比如我们来调试上面创建的 `chart` 包：

```
$ helm install --dry-run --debug ./mychart
[debug] Created tunnel using local port: '41250'

[debug] SERVER: "127.0.0.1:41250"

[debug] Original chart version: ""
[debug] CHART PATH: /home/vagrant/helm/mychart

NAME:   tufted-scorpion
REVISION: 1
RELEASED: Thu Sep 27 07:25:09 2018
CHART: mychart-0.1.0
USER-SUPPLIED VALUES:
{}

COMPUTED VALUES:
affinity: {}
image:
  pullPolicy: IfNotPresent
  repository: nginx
  tag: stable
ingress:
  annotations: {}
  enabled: false
  hosts:
  - chart-example.local
  path: /
  tls: []
nodeSelector: {}
replicaCount: 1
resources: {}
service:
  port: 80
  type: ClusterIP
tolerations: []

HOOKS:
MANIFEST:

---
# Source: mychart/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: tufted-scorpion-configmap
data:
  myvalue: "Hello World"

```

现在我们使用`--dry-run`就可以很容易地测试代码了，不需要每次都去安装一个 `release` 实例了，但是要注意的是这不能确保 `Kubernetes` 本身就一定会接受生成的模板，在调试完成后，还是需要去安装一个实际的 `release` 实例来进行验证的。

## 内置对象

刚刚我们使用`{{.Release.Name}}` 将 `release` 的名称插入到模板中。这里的 `Release` 就是 `Helm` 的内置对象，下面是一些常用的内置对象，在需要的时候直接使用就可以：

#### `Release`：这个对象描述了 `release` 本身。它里面有几个对象：

* `Release.Name`：`release` 名称
* `Release.Time`：`release` 的时间
* `Release.Namespace`：`release` 的 `namespace`（如果清单未覆盖）
* `Release.Service`：`release` 服务的名称（始终是 `Tiller`）。
* `Release.Revision`：此 `release` 的修订版本号，**从1开始累加。**
* `Release.IsUpgrade`：**如果当前操作是升级或回滚，则将其设置为 `true`**。
* `Release.IsInstall`：**如果当前操作是安装，则设置为 true**。

#### `Values`：从`values.yaml`文件和用户提供的文件`传入模板的值`。默认情况下，`Values` 是空的。

#### `Chart`：`Chart.yaml`文件的内容。所有的 `Chart` 对象都将从该文件中获取。`chart` 指南中[Charts Guide](https://github.com/kubernetes/helm/blob/master/docs/charts.md#the-chartyaml-file)列出了可用字段，可以前往查看。

#### `Files`：这提供对 `chart` 中所有非特殊文件的访问。虽然无法使用它来访问模板，但可以使用它来访问 `chart` 中的其他文件。请参阅 "访问文件" 部分。

* `Files.Get` 是一个按名称获取文件的函数（`.Files.Get config.ini`）
* `Files.GetBytes` 是将文件内容作为字节数组而不是字符串获取的函数。这对于像图片这样的东西很有用。

#### `Capabilities`：这提供了关于 `Kubernetes `集群支持的功能的信息。

* `Capabilities.APIVersions` 是一组版本信息。
* `Capabilities.APIVersions.Has $version` 指示是否在群集上启用版本（`batch/v1`）。
* `Capabilities.KubeVersion` 提供了查找 Kubernetes 版本的方法。它具有以下值：Major，Minor，GitVersion，GitCommit，GitTreeState，BuildDate，GoVersion，Compiler，和 Platform。
* `Capabilities.TillerVersion` 提供了查找 `Tiller` 版本的方法。它具有以下值：SemVer，GitCommit，和 GitTreeState。

#### `Template`：包含有关正在执行的当前模板的信息

#### `Name`：到当前模板的文件路径（例如 `mychart/templates/mytemplate.yaml`）

#### `BasePath`：当前 `chart` 模板目录的路径（例如 `mychart/templates`）。


上面这些值可用于任何顶级模板，**要注意内置值始终以大写字母开头。** 

这也符合`Go`的命名约定。当你创建自己的名字时，你可以自由地使用适合你的团队的惯例。

## values 文件

上面的内置对象中有一个对象就是 `Values`，该对象提供对传入 `chart` 的值的访问，Values 对象的值有4个来源：

* `chart` 包中的 `values.yaml` 文件
* `父 chart` 包的 `values.yaml` 文件
* 通过 `helm install` 或者 `helm upgrade` 的`-f`或者`--values`参数传入的自定义的 `yaml` 文件(上节课我们已经学习过)
* 通过`--set` 参数传入的值

`chart` 的 `values.yaml` 提供的值可以被用户提供的 `values` 文件覆盖，而该文件同样可以被`--set`提供的参数所覆盖。

这里我们来重新编辑 `mychart/values.yaml `文件，**将默认的值全部清空**，添加一个新的数据：(`values.yaml`)

```
course: k8s
```

然后我们在上面的 `templates/configmap.yaml` 模板文件中就可以使用这个值了：(`configmap.yaml`)

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-configmap
data:
  myvalue: "Hello World"
  course: {{ .Values.course }}
```

可以看到最后一行我们是通过`{{ .Values.course }}`来获取 `course` 的值的。现在我们用 `debug` 模式来查看下我们的模板会被如何渲染：

```
$ helm install --dry-run --debug ./mychart
[debug] Created tunnel using local port: '38561'

[debug] SERVER: "127.0.0.1:38561"

[debug] Original chart version: ""
[debug] CHART PATH: /home/vagrant/helm/mychart

NAME:   youthful-panda
REVISION: 1
RELEASED: Thu Sep 27 07:51:03 2018
CHART: mychart-0.1.0
USER-SUPPLIED VALUES:
{}

COMPUTED VALUES:
course: k8s

HOOKS:
MANIFEST:

---
# Source: mychart/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: youthful-panda-configmap
data:
  myvalue: "Hello World"
  course: k8s
```

我们可以看到 `ConfigMap` 中 `course` 的值被渲染成了 `k8s`，这是因为在默认的 `values.yaml` 文件中该参数值为 k8s，同样的我们可以通过--set参数来轻松的覆盖 `course` 的值：

```
$  helm install --dry-run --debug --set course=python ./mychart
[debug] Created tunnel using local port: '41643'

[debug] SERVER: "127.0.0.1:41643"

[debug] Original chart version: ""
[debug] CHART PATH: /home/vagrant/helm/mychart

NAME:   foolhardy-rottweiler
REVISION: 1
RELEASED: Thu Sep 27 07:51:48 2018
CHART: mychart-0.1.0
USER-SUPPLIED VALUES:
course: python

COMPUTED VALUES:
course: python

HOOKS:
MANIFEST:

---
# Source: mychart/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: foolhardy-rottweiler-configmap
data:
  myvalue: "Hello World"
  course: python
```

由于`--set` 比默认 `values.yaml` 文件具有更高的优先级，所以我们的模板生成为 `course: python`。

`values` 文件也可以包含更多结构化内容，例如，我们在 `values.yaml` 文件中可以创建 `course` 部分，然后在其中添加几个键：

```
course:
  k8s: devops
  python: django
```
现在我们稍微修改模板：

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-configmap
data:
  myvalue: "Hello World"
  k8s: {{ .Values.course.k8s }}
  python: {{ .Values.course.python }}
```
同样可以使用 `debug` 模式查看渲染结果：

```
$ helm install --dry-run --debug ./mychart
[debug] Created tunnel using local port: '40096'

[debug] SERVER: "127.0.0.1:40096"

[debug] Original chart version: ""
[debug] CHART PATH: /home/vagrant/helm/mychart

NAME:   operatic-meerkat
REVISION: 1
RELEASED: Thu Sep 27 07:54:50 2018
CHART: mychart-0.1.0
USER-SUPPLIED VALUES:
{}

COMPUTED VALUES:
course:
  k8s: devops
  python: django

HOOKS:
MANIFEST:

---
# Source: mychart/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: operatic-meerkat-configmap
data:
  myvalue: "Hello World"
  k8s: devops
  python: django
```

可以看到模板中的参数已经被 `values.yaml` 文件中的值给替换掉了。虽然以这种方式构建数据是可以的，

#### 但我们还是建议保持 value 树浅一些，平一些，这样维护起来要简单一点。

## 删除默认 key

如果您需要从默认值中删除一个键，可以覆盖该键的值为 `null`，在这种情况下，`Helm` 将从覆盖值合并中删除该键。

例如，`stable` 版本的 `Drupal chart` 允许配置 `liveness` 探测器，如果你配置自定义的 image。以下是默认值：

```
livenessProbe:
  httpGet:
    path: /user/login
    port: http
  initialDelaySeconds: 120
```

如果尝试覆盖 `liveness Probe` 处理程序 `exec` 而不是 `httpGet`，使用 `--set livenessProbe.exec.command=[cat,docroot/CHANGELOG.txt]`，`Helm` 会将默认和重写的键合并在一起，从而产生以下 YAML：

```
livenessProbe:
  httpGet:
    path: /user/login
    port: http
  exec:
    command:
    - cat
    - docroot/CHANGELOG.txt
  initialDelaySeconds: 120
```

但是，`Kubernetes` 会报错，因为无法声明多个 `liveness Prob`e 处理程序。为了克服这个问题，你可以指示 `Helm `过将 `livenessProbe.httpGet` 通设置为空来删除它：


```
helm install stable/drupal --set image=my-registry/drupal:0.1.0 --set livenessProbe.exec.command=[cat,docroot/CHANGELOG.txt] --set livenessProbe.httpGet=null
```

**`livenessProbe.httpGet=null`**

