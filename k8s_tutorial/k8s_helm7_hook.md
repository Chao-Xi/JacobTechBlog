# Helm Hooks 的使用

和`Kubernetes`里面的容器一样，`Helm`也提供了 `Hook` 的机制，允许 `chart` 开发人员在 `release` 的生命周期中的某些节点来进行干预，比如我们可以利用 `Hooks` 来做下面的这些事情：

#### 在加载任何其他 `chart` 之前，在安装过程中加载 `ConfigMap` 或 `Secret`
#### 在安装新 `chart` 之前执行作业以备份数据库，然后在升级后执行第二个作业以恢复数据
#### 在删除 `release` 之前运行作业，以便在删除 `release` 之前优雅地停止服务

值得注意的是 `Hooks` 和普通模板一样工作，但是它们具有特殊的注释，可以使 `Helm` 以不同的方式使用它们。

### `Hook` 在资源清单中的 `metadata` 部分用 `annotations` 的方式进行声明：

```
apiVersion: ...
kind: ....
metadata:
  annotations:
    "helm.sh/hook": "pre-install"
# ...
```

## Hooks

### 在 `Helm` 中定义了如下一些可供我们使用的 `Hooks`：

* 预安装`pre-install`：在模板渲染后，`kubernetes` 创建任何资源之前执行
* 安装后`post-install`：在所有 `kubernetes` 资源安装到集群后执行
* 预删除`pre-delete`：在从 `kubernetes` 删除任何资源之前执行删除请求
* 删除后`post-delete`：删除所有 `release` 的资源后执行
* 升级前`pre-upgrade`：在模板渲染后，但在任何资源升级之前执行
* 升级后`post-upgrade`：在所有资源升级后执行
* 预回滚`pre-rollback`：在模板渲染后，在任何资源回滚之前执行
* 回滚后`post-rollback`：在修改所有资源后执行回滚请求
* `crd-install`：在运行其他检查之前添加 `CRD` 资源，只能用于 `chart` 中其他的资源清单定义的 `CRD` 资源。

## 生命周期

`Hooks` 允许开发人员在 `release` 的生命周期中的一些关键节点执行一些钩子函数，我们正常安装一个 `chart` 包的时候的生命周期如下所示：

* 用户运行`helm install foo`
* `chart` 被加载到服务端 `Tiller Server` 中
* 经过一些验证，`Tiller Server` 渲染 `foo` 模板
* `Tiller` 将产生的资源加载到 `kubernetes` 中去
* `Tiller` 将 `release` 名称和其他数据返回给 `Helm` 客户端
* `Helm` 客户端退出

如果开发人员在 `install` 的生命周期中定义了两个 `hook：pre-install`和`post-install`，那么我们安装一个 `chart` 包的生命周期就会多一些步骤了：

* 用户运行`helm install foo`
* `chart` 被加载到服务端 `Tiller Server` 中
* 经过一些验证，`Tiller Server` 渲染 `foo` 模板
* `Tiller` 将 `hook` 资源加载到 `kubernetes` 中，准备执行`pre-install` hook
* `Tiller` 会根据权重对 `hook` 进行排序（**默认分配权重0，权重相同的 hook 按升序排序**）
* `Tiller` 然后加载最低权重的 `hook`
* `Tiller` 等待，直到 `hook` 准备就绪
* `Tiller` 将产生的资源加载到 `kubernetes` 中
* `Tiller` 执行`post-install` hook
* `Tiller` 等待，直到 `hook `准备就绪
* `Tiller` 将 `release` 名称和其他数据返回给客户端
* `Helm` 客户端退出

#### 等待 `hook` 准备就绪，这是一个阻塞的操作，如果 `hook` 中声明的是一个 `Job` 资源，那么 `Tiller` 将等待 `Job` 成功完成，如果失败，则发布失败，在这个期间，`Helm` 客户端是处于暂停状态的。

对于所有其他类型，只要 `kubernetes` 将资源标记为加载（添加或更新），资源就被视为**就绪**状态，当一个 `hook` 声明了很多资源是，**这些资源是被串行执行的**。


#### 另外需要注意的是 `hook` 创建的资源不会作为 `release` 的一部分进行跟踪和管理，一旦 `Tiller Server` 验证了 `hook` 已经达到了就绪状态，它就不会去管它了。

#### 所以，如果我们在 `hook` 中创建了资源，那么不能依赖`helm delete`去删除资源，因为 `hook` 创建的资源已经不受控制了，要销毁这些资源，需要在`pre-delete`或者`post-delete`这两个 `hook` 函数中去执行相关操作，或者将`helm.sh/hook-delete-policy`这个 `annotation` 添加到 `hook` 模板文件中。

## 写一个 hook

上面我们也说了 `hook` 和普通模板一样，也可以使用普通的模板函数和常用的一些对象，比如`Values`、`Chart`、`Release`等等，唯一和普通模板不太一样的地方就是在资源清单文件中的`metadata` 部分会有一些特殊的注释`annotation`。

例如，现在我们来创建一个 `hook`，在前面的示例 `templates` 目录中添加一个 `post-install-job.yaml` 的文件，表示安装后执行的一个 `hook`：

```
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ .Release.Name }}-post-install-job
  lables:
    release: {{ .Release.Name }}
    chart: {{ .Chart.Name }}
    version: {{ .Chart.Version }}
  annotations:
    # 注意，如果没有下面的这个注释的话，当前的这个Job就会被当成release的一部分
    "helm.sh/hook": post-install
    "helm.sh/hook-weight": "-5"
    "helm.sh/hook-delete-policy": hook-succeeded
spec:
  template:
    metadata:
      name: {{ .Release.Name }}
      labels:
        release: {{ .Release.Name }}
        chart: {{ .Chart.Name }}
        version: {{ .Chart.Version }}
    spec:
      restartPolicy: Never
      containers:
      - name: post-install-job
        image: alpine
        command: ["/bin/sleep", "{{ default "10" .Values.sleepTime }}"]
```

上面的 `Job` 资源中我们添加一个 `annotations`，要注意的是，如果我们没有添加下面这行注释的话，这个资源就会被当成是 `release` 的一部分资源：

```
annotations:
  "helm.sh/hook": post-install
```

当然一个资源中我们也可以同时部署多个 `hook`，比如我们还可以添加一个`post-upgrade`的钩子：

```
annotations:
  "helm.sh/hook": post-install,post-upgrade
```

另外值得注意的是我们为 `hook` 定义了一个权重，**这有助于建立一个确定性的执行顺序，权重可以是正数也可以是负数，但是必须是字符串才行**。当 `Tiller` 开始执行一个特定类型的 `hook` (例： `pre-install hooks post-install hooks`, 等等) 执行周期时，它会按升序对这些 `hook` 进行排序

```
annotations:
  "helm.sh/hook-weight": "-5"
```
最后还添加了一个删除 `hook` 资源的策略：

```
annotations:
  "helm.sh/hook-delete-policy": hook-succeeded
```

#### 删除资源的策略可供选择的注释值：

* `hook-succeeded`：表示 `Tiller` 在 `hook` 成功执行后删除 `hook` 资源
* `hook-failed`：表示如果 `hook` 在执行期间失败了，`Tiller` 应该删除 `hook` 资源
* `before-hook-creation`：表示在删除新的 `hook` 之前应该删除以前的 `hook`


### 当 `helm` 的 `release` 更新时，有可能 `hook` 资源已经存在于群集中。默认情况下，`helm` 会尝试创建资源，并抛出错误**`”… already exists”`**。

### 我们可以选择 `“helm.sh/hook-delete-policy”: “before-hook-creation”`，取代 `“helm.sh/hook-delete-policy”: “hook-succeeded,hook-failed”` 因为：

* 例如为了手动调试，将错误的 `hook` 作业资源保存在 `kubernetes` 中是很方便的。 出于某种原因，可能有必要将成功的 `hook` 资源保留在 `kubernetes` 中。同时，在 `helm release` 升级之前进行手动资源删除是不可取的。

*  `“helm.sh/hook-delete-policy”: “before-hook-creation”` 在 hook 中的注释，如果在新的 `hook` 启动前有一个 `hook` 的话，会使 `Tiller` 将以前的`release` 中的 `hook` 删除，而这个 `hook` 同时它可能正在被其他一个策略使用。