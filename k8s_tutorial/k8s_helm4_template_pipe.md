![Alt Image Text](images/helm/helm4_0.jpg "Headline image")
# Helm 模板之模板函数与管道

## 模板函数

比如我们需要从`.Values`中读取的值变成字符串的时候就可以通过调用`quote`模板函数来实现：(`templates/configmap.yaml`)

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-configmap
data:
  myvalue: "Hello World"
  k8s: {{ quote .Values.course.k8s }}
  python: {{ .Values.course.python }}
```

模板函数遵循调用的语法为：`functionName arg1 arg2...`。在上面的模板文件中，`quote .Values.course.k8s`调用`quote`函数并将后面的值作为一个参数传递给它。最终被渲染为：

```
$ helm install --dry-run --debug ./mychart
[debug] Created tunnel using local port: '45872'

[debug] SERVER: "127.0.0.1:45872"

[debug] Original chart version: ""
[debug] CHART PATH: /home/vagrant/helm/mychart

.....

MANIFEST:

---
# Source: mychart/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: silly-meerkat-configmap
data:
  myvalue: "Hello World"
  k8s: "devops"
  python: django
```
### 我们可以看到`.Values.course.k8s`被渲染成了字符串`devops`。

 Helm 是一种 Go 模板语言，拥有超过60多种可用的内置函数，一部分是由[Go 模板语言](https://godoc.org/text/template)本身定义的，其他大部分都是[Sprig模板库](https://godoc.org/github.com/Masterminds/sprig)提供的一部分，我们可以前往这两个文档中查看这些函数的用法。

比如我们这里使用的`quote`函数就是`Sprig` 模板库提供的一种字符串函数，用途就是用双引号将字符串括起来，如果需要双引号"，则需要添加\来进行转义，而squote函数的用途则是用双引号将字符串括起来，而不会对内容进行转义。

## 管道

模板语言除了提供了丰富的内置函数之外，其另一个强大的功能就是管道的概念。和UNIX中一样，管道我们通常称为`Pipeline`，是一个链在一起的一系列模板命令的工具，以紧凑地表达一系列转换。简单来说，管道是可以按顺序完成一系列事情的一种方法。比如我们用管道来重写上面的 `ConfigMap` 模板：

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-configmap
data:
  myvalue: "Hello World"
  k8s: {{ .Values.course.k8s | quote }}
  python: {{ .Values.course.python }}
```

```
$ helm install --dry-run --debug ./mychart

...
data:
  myvalue: "Hello World"
  k8s: "devops"
  python: django

```

这里我们直接调用quote函数，而是调换了一个顺序，使用一个管道符|将前面的参数发送给后面的模板函数：`{{ .Values.course.k8s | quote }}`，使用管道我们可以将几个功能顺序的连接在一起，比如我们希望上面的 `ConfigMap` 模板中的 k8s 的 `value` 值被渲染后是大写的字符串，则我们就可以使用管道来修改：（`templates/configmap.yaml`）

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-configmap
data:
  myvalue: "Hello World"
  k8s: {{ .Values.course.k8s | upper | quote }}
  python: {{ .Values.course.python }}
```
这里我们在管道中增加了一个`upper`函数，该函数同样是`Sprig` 模板库提供的，表示将字符串每一个字母都变成大写。然后我们用`debug`模式来查看下上面的模板最终会被渲染成什么样子：

```
$ helm install --dry-run --debug ./mychart

...
data:
  myvalue: "Hello World"
  k8s: "DEVOPS"
  python: django
```

我们可以看到之前我们的`devops`已经被渲染成了`"DEVOPS"`了，要注意的是使用管道操作的时候，前面的操作结果会作为参数传递给后面的模板函数，比如我们这里希望将上面模板中的 `python` 的值渲染为重复出现`3`次的字符串，则我们就可以使用到`Sprig` 模板库提供的`repeat`函数，不过该函数需要传入一个参数`repeat COUNT STRING`表示重复的次数：（`templates/configmap.yaml`）

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-configmap
data:
  myvalue: "Hello World"
  k8s: {{ .Values.course.k8s | upper | quote }}
  python: {{ .Values.course.python | quote | repeat 3 }}
```

该repeat函数会将给定的字符串重复3次返回，所以我们将得到这个输出：

```
$ helm install --dry-run --debug ./mychart

data:
  myvalue: "Hello World"
  k8s: "DEVOPS"
  python: "django""django""django"
```

我们可以看到上面的输出中 `python` 对应的值变成了`3个`相同的字符串，这显然是不符合我们预期的，我们的预期是形成一个字符串，而现在是`3`个字符串了，而且上面还有错误信息，根据管道处理的顺序，我们将`quote`函数放到`repeat`函数后面去是不是就可以解决这个问题了：（`templates/configmap.yaml`）

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-configmap
data:
  myvalue: "Hello World"
  k8s: {{ .Values.course.k8s | upper | quote }}
  python: {{ .Values.course.python | repeat 3 | quote }}
```
现在是不是就是先重复`3`次`.Values.course.python`的值，然后调用`quote`函数

```
$ helm install --dry-run --debug ./mychart

data:
  myvalue: "Hello World"
  k8s: "DEVOPS"
  python: "djangodjangodjango"
```

## `default` 函数

另外一个我们会经常使用的一个函数是`default` 函数：`default DEFAULT_VALUE GIVEN_VALUE`。该函数允许我们在模板内部指定默认值，以防止该值被忽略掉了。比如我们来修改上面的 `ConfigMap` 的模板：（`templates/configmap.yaml`）
 
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-configmap
data:
  myvalue: {{ .Values.hello | default  "Hello World" | quote }}
  k8s: {{ .Values.course.k8s | upper | quote }}
  python: {{ .Values.course.python | repeat 5 | quote }}
```

由于我们的`values.yaml`文件中只定义了 `course` 结构的信息，并没有定义 `hello` 的值，所以如果没有设置默认值的话是得不到`{{ .Values.hello }}`的值的，这里我们为该值定义了一个默认值：`Hello World`，所以现在如果在`values.yaml`文件中没有定义这个值，则我们也可以得到默认值：

```
$ helm install --dry-run --debug ./mychart/
[debug] Created tunnel using local port: '41443'

...

[debug] Created tunnel using local port: '41443'
metadata:
  name: bald-parrot-configmap
data:
  myvalue: "Hello World"
  k8s: "DEVOPS"
  python: "djangodjangodjangodjangodjango"
```

