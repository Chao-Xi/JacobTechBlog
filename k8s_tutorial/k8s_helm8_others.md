# 子 `chart` 和全局值

* 子 Chart 的使用
* 全局值的使用

## 子 chart 包

我们到目前为止都只用了一个 chart，但是 chart 也可以有 子 chart 的依赖关系，它们也有自己的值和模板，在学习字 chart 之前，我们需要了解几点关于子 chart 的说明：

* 子 `chart` 是独立的，所以子 `chart` 不能明确依赖于其父 `chart`
* 子 `chart` 无法访问其父 `chart` 的值
* 父 `chart` 可以覆盖子 `chart` 的值
* `Helm` 中有全局值的概念，可以被所有的 `chart` 访问


## 创建子 chart

现在我们就来创建一个子 `chart`，还记得我们在创建 `mychart` 包的时候，在根目录下面有一个空文件夹 `charts` 目录吗？这就是我们的子 `chart` 所在的目录，在该目录下面添加一个新的 `chart`：

```
$ cd mychart/charts
$ helm create mysubchart
Creating mysubchart
$ rm -rf mysubchart/templates/*.*
$ tree ..
..
├── charts
│   └── mysubchart
│       ├── charts
│       ├── Chart.yaml
│       ├── templates
│       └── values.yaml
├── Chart.yaml
├── templates
│   ├── configmap.yaml
│   ├── _helpers.tpl
│   ├── NOTES.txt
│   └── post-install-job.yaml
└── values.yaml

5 directories, 8 files

```

同样的，我们将子 `chart` 模板中的文件全部删除了，接下来，我们为子 `chart` 创建一个简单的模板和 `values` 文件了。

```
$ cat > mysubchart/values.yaml <<EOF
in: mysub
EOF

cat > mysubchart/templates/configmap.yaml <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-configmap2
data:
  in: {{ .Values.in }}
EOF
```

我们上面已经提到过每个子 `chart` 都是独立的 `chart`，所以我们可以单独给 `mysubchart` 进行测试：

```
$ helm install --dry-run --debug ./mysubchart
[debug] Created tunnel using local port: '45378'

[debug] SERVER: "127.0.0.1:45378"

[debug] Original chart version: ""
[debug] CHART PATH: /home/vagrant/helm/mychart/charts/mysubchart

NAME:   amber-gecko
REVISION: 1
RELEASED: Tue Oct 16 09:08:36 2018
CHART: mysubchart-0.1.0
USER-SUPPLIED VALUES:
{}

COMPUTED VALUES:
in: mysub

HOOKS:
MANIFEST:

---
# Source: mysubchart/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: amber-gecko-configmap2
data:
  in: mysub
```

我们可以看到正常渲染出了结果。

## 值覆盖

现在 `mysubchart` 这个子 `chart` 就属于 `mychart` 这个父 `chart` 了，由于 `mychart` 是父级，所以我们可以在 `mychart` 的 `values.yaml` 文件中直接配置子 `chart` 中的值，比如我们可以在 `mychart/values.yaml` 文件中添加上子 `chart` 的值：

```
mychart/values.yaml
```
```
course:
  k8s: devops
  python: django
courselist:
- k8s
- python
- search
- golang

mysubchart:
  in: parent
```

注意最后两行，`mysubchart` 部分内的任何指令都会传递到 `mysubchart` 这个子 `chart` 中去的，现在我们在 `mychart` 根目录中执行调试命令，可以查看到子 `chart` 也被一起渲染了：

```
$ helm install --dry-run --debug .
[debug] Created tunnel using local port: '39309'

[debug] SERVER: "127.0.0.1:39309"

[debug] Original chart version: ""
[debug] CHART PATH: /home/vagrant/helm/mychart

NAME:   contrasting-iguana
REVISION: 1
RELEASED: Tue Oct 16 09:19:22 2018
CHART: mychart-0.1.0
USER-SUPPLIED VALUES:
{}

COMPUTED VALUES:
course:
  k8s: devops
  python: django
courselist:
- k8s
- python
- search
- golang
mysubchart:
  global: {}
  in: parent

HOOKS:
MANIFEST:

---
# Source: mychart/charts/mysubchart/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: contrasting-iguana-configmap2
data:
  in: parent
---
# Source: mychart/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: contrasting-iguana-configmap
  labels:
    from: helm
    date: 2018-10-16
    chart: mychart
    version: 0.1.0
data:
  k8s: "devops"
  python: "django"
  from: helm
  date: 2018-10-16
  chart: mychart
  version: 0.1.0

```

我们可以看到子 chart 中的值已经被顶层的值给覆盖了。但是在某些场景下面我们还是希望某些值在所有模板中都可以使用，这就需要用到全局 chart 值了。


## 全局值

全局值可以从任何 chart 或者子 chart中进行访问使用，values 对象中有一个保留的属性是`Values.global`，就可以被用来设置全局值，比如我们在父 chart 的 `values.yaml` 文件中添加一个全局值：

```
course:
  k8s: devops
  python: django
courselist:
- k8s
- python
- search
- golang

mysubchart:
  in: parent

global:
  allin: helm
```
我们在 values.yaml 文件中添加了一个 global 的属性，这样的话无论在父 chart 中还是在子 chart 中我们都可以通过`{{ .Values.global.allin }}` 来访问这个全局值了。比如我们在 `mychart/templates/configmap.yaml` 和 `mychart/charts/mysubchart/templates/configmap.yaml` 文件的 data 区域下面都添加上如下内容：

现在我们在 mychart 根目录下面执行 debug 调试模式：


```
$  helm install --dry-run --debug .

$ helm install --dry-run --debug .
[debug] Created tunnel using local port: '43004'

[debug] SERVER: "127.0.0.1:43004"

[debug] Original chart version: ""
[debug] CHART PATH: /home/vagrant/helm/mychart

NAME:   nihilist-lizzard
REVISION: 1
RELEASED: Tue Oct 16 09:32:54 2018
CHART: mychart-0.1.0
USER-SUPPLIED VALUES:
{}

COMPUTED VALUES:
course:
  k8s: devops
  python: django
courselist:
- k8s
- python
- search
- golang
global:
  allin: helm
mysubchart:
  global:
    allin: helm
  in: parent

HOOKS:
MANIFEST:

---
# Source: mychart/charts/mysubchart/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nihilist-lizzard-configmap2
data:
  in: parent

data:
  allin: helm
---
# Source: mychart/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nihilist-lizzard-configmap
  labels:
    from: helm
    date: 2018-10-16
    chart: mychart
    version: 0.1.0
data:
  k8s: "devops"
  python: "django"
  from: helm
  date: 2018-10-16
  chart: mychart
  version: 0.1.0

data:
  allin: helm
```
我们可以看到两个模板中都输出了	`allin: helm`这样的值，全局变量对于传递这样的信息非常有用，不过也要注意我们不能滥用全局值。

另外值得注意的是我们在学习命名模板的时候就提到过父 `chart` 和子 `chart` 可以共享模板。任何 `chart` 中的任何定义块都可用于其他 `chart`，所以我们在给命名模板定义名称的时候添加了 chart 名称这样的前缀，避免冲突。


### 与子 chart 共享模板(include / template)


父 `chart` 和子 `chart` 可以共享模板。任何 chart 中的任何定义块都可用于其他 chart。

例如，我们可以像这样定义一个简单的模板：

```
{{- define "labels"}}from: mychart{{ end }}

```

回想一下模板上的标签是如何全局共享的。因此，`labels chart` 可以包含在其他 chart 中。

尽管 chart 开发人员可以选择 `include` 和 `template`, 使用 `include` 的一个优点是，include 可以动态地引用模板：

```
{{include $mytemplate}}
```


