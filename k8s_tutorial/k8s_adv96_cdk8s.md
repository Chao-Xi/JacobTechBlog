# 使用编程语言描述 Kubernetes 应用 - cdk8s

[cdk8s](https://github.com/awslabs/cdk8s) 是 `AWS Labs` 发布的一个使用 `TypeScript` 编写的新框架，它允许我们使用一些面向对象的编程语言来定义 Kubernetes 的资源清单，cdk8s 最终也是生成原生的 `Kubernetes YAML` 文件，所以我们可以在任何地方使用 `cdk8s` 来定义运行的 `Kubernetes` 应用资源。

## 介绍

在 cdk8s 中提供了一个结构（`construct`）的概念，它们是 `Kubernetes` 资源对象（`Deployment`、`Service`、`Ingress` 等）的抽象。定义的 `Kubernetes` 应用就是一颗结构树，树的根是一个 `App` 结构，在应用程序中，我们可以定义任意数量的图表（`charts`，类似于 `Helm Chart` 模板），每个图表都会被合并到一个单独的 `Kubernetes` 资源清单文件中，图表依次由任意数量的构造组成，最终由 `Kubernetes` 的资源对象组成。

不过需要注意的是`cdk8s `仅仅只是定义` Kubernetes` 应用，并不会将应用安装到集群中，当使用 `cdk8s` 执行某个应用程序时，它会将应用程序中定义的所有图表合并到 dist 目录中，然后我们可以使用 `kubectl apply -f dist/chart.k8syaml` 或者其他 `GitOps` 工具将这些图表安装到 `Kubernetes` 集群中去。

## 使用

目前 cdk8s 支持使用 `TypeScript` 和 `Python` 两种编程语言来定义 `Kubernetes` 应用。这里我们以更熟悉的 `Python` 为例来说明 `cdk8s` 的基本使用。

`cdk8s` 有一个比较轻量级的 `CLI` 工具，其中包含一些有用的命令。我们可以先在全局中安装 `cdk8s CLI`，可以使用如下两种方式进行安装：

* 如果是 `Mac` 系统，可以直接使用 `Homebrew` 工具进行安装：

```
$ brew install cdk8s
```

* 除此之外也可以使用 npm 工具进行安装（依赖 Node.js）：

```
$ npm install -g cdk8s-cli
```

安装完成后我们就可以使用 `cdk8s` 命令来创建一个 `cdk8s` 应用了：

```
pip3 install pipenv
$ mkdir hello && cd hello
# cdk8s init TYPE - TYPE 表示项目类型：python-app 或者 typescript-app
# If already run cdk8s init in this folder before, run `pipenv clean` to clean folder

$ cdk8s init python-app  
Initializing a project from the python-app template
Pipfile.lock not found, creating…
Locking [dev-packages] dependencies…
Locking [packages] dependencies…
Updated Pipfile.lock (a65489)!
Installing dependencies from Pipfile.lock (a65489)…
  🐍   ▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉ 0/0 — 00:00:00
To activate this project's virtualenv, run pipenv shell.
Alternatively, run a command inside the virtualenv with pipenv run.
Installing cdk8s~=0.19.0…
Adding cdk8s to Pipfile's [packages]…
✔ Installation Succeeded 
Pipfile.lock (eea701) out of date, updating to (a65489)…
Locking [dev-packages] dependencies…
Locking [packages] dependencies…
✔ Success! 
Updated Pipfile.lock (eea701)!
Installing dependencies from Pipfile.lock (eea701)…
  🐍   ▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉ 9/9 — 00:00:02
To activate this project's virtualenv, run pipenv shell.
Alternatively, run a command inside the virtualenv with pipenv run.
========================================================================================================

 Your cdk8s Python project is ready!

   cat help      Prints this message  
   cdk8s synth   Synthesize k8s manifests to dist/
   cdk8s import  Imports k8s API objects to "imports/k8s"

  Deploy:
   kubectl apply -f dist/*.k8s.yaml

========================================================================================================
```

初始化完成后我们可以查看下项目的基本结构：

```
$ tree .
.
├── Pipfile
├── Pipfile.lock
├── cdk8s.yaml
├── dist
│   └── hello.k8s.yaml
├── help
├── imports
│   └── k8s
│       ├── __init__.py
│       ├── _jsii
│       │   ├── __init__.py
│       │   └── k8s@0.0.0.jsii.tgz
│       └── py.typed
└── main.py

4 directories, 10 files
```

现在我们可以打开 main.py 文件，内容如下所示：

```
#!/usr/bin/env python
from constructs import Construct
from cdk8s import App, Chart


class MyChart(Chart):
    def __init__(self, scope: Construct, ns: str):
        super().__init__(scope, ns)

        # define resources here


app = App()
MyChart(app, "hello")

app.synth()
```

从上面代码可以看出应用以结构树的形式构成，结构是一种抽象的可组合的单元。上面我们使用 `cdk8s init` 命令初始化的项目定义了单个空的图表。

当我们运行 `cdk8s synth` 的时候，将会为应用程序中的每个 `Chart` 合成 `Kubernetes` 资源清单，并将其写入到 `dist` 目录。我们可以使用如下所示命令测试下：

```
$ cdk8s synth
dist/hello.k8s.yaml
$ cat dist/hello.k8s.yaml
$ # 空内容
```

* 接下来我们在图表中定义一些 `Kubernetes API` 对象。与 `charts` 和 `apps` 类似，`Kubernetes API` 对象在 `cdk8s` 中也表示为结构。
* 使用 `cdk8s import` 命令可以将这些结构导入到项目中，然后我们就可以在项目目录的 `imports/k8s` 模块下面找到它们。

当我们使用 `cdk8s` 初始化创建项目的时候，其实已经执行了 `cdk8s import` 操作，所以我们可以在 `imports` 目录下面看到一些信息，我们可以将该目录提交到源码中进行管理，也可以在构建过程中去生成。

下面我们来定义一个简单的 `Kubernetes` 应用程序，包含 `Deployment` 和 `Service` 资源对象，修改 `main.py` 代码，内容如下所示：

```
#!/usr/bin/env python
from constructs import Construct
from cdk8s import App, Chart

from imports import k8s  # 导入由 cdk8s import 命令生成的特定 k8s 版本的资源对象


class MyChart(Chart):
    def __init__(self, 
            scope: Construct,  # 我们的app实例
            ns: str):  # 需要注意的是这里并不是 k8s 的 namespace，只是我们资源的一个前缀而已
        super().__init__(scope, ns)

        # 定义一些变量
        label = {"app": "hello-k8s"}
        
        # 定义带有一个容器两个副本的Deployment资源对象
        k8s.Deployment(self, 'deployment',
                        spec=k8s.DeploymentSpec(
                            replicas=2,
                            selector=k8s.LabelSelector(match_labels=label),
                            template=k8s.PodTemplateSpec(
                                metadata=k8s.ObjectMeta(labels=label),
                                spec=k8s.PodSpec(containers=[
                                    k8s.Container(
                                        name='hello-k8s',
                                        image='paulbouwer/hello-kubernetes:1.7',
                                        ports=[k8s.ContainerPort(container_port=8080)]
                                    )
                                ])
                            )
                        ))
        # 定义一个关联上述 Pod 的 Service 对象
        k8s.Service(self, 'service', 
                    spec=k8s.ServiceSpec(
                        type='NodePort',
                        ports=[k8s.ServicePort(port=80, target_port=k8s.IntOrString.from_number(8080))],
                        selector=label
                        )
                    )


app = App()  # 创建一个 App 实例
MyChart(app, "hello") 

app.synth()  # 该方法负责生成生成k8s资源清单文件
```

现在我们执行 `cdk8s synth` 命令，会在 `dist` 目录下生成如下所示的资源清单：

```
$ cdk8s synth
dist/hello.k8s.yaml

 cat dist/hello.k8s.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-deployment-c51e9e6b
spec:
  replicas: 2
  selector:
    matchLabels:
      app: hello-k8s
  template:
    metadata:
      labels:
        app: hello-k8s
    spec:
      containers:
        - image: paulbouwer/hello-kubernetes:1.7
          name: hello-k8s
          ports:
            - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: hello-service-9878228b
spec:
  ports:
    - port: 80
      targetPort: 8080
  selector:
    app: hello-k8s
  type: NodePort
```

资源清单生成后，我们就可以使用 kubectl 命令来直接安装应用：

```
$ kubectl apply -f dist/hello.k8s.yaml
deployment.apps/hello-deployment-c51e9e6b created
service/hello-service-9878228b created
```

## 对比

可能有的读者觉得 `cdk8s` 和 `Helm` 或者 `kustomize `之类的工具比较起来也没有多大优势，而且这些工具不需要我们编写实际的代码，直接使用模板语言就可以了，就目前的使用来说的确是这样的，但是一旦应用特别复杂的时候，我们也会感受到 `Helm` 之类的工具的局限性，毕竟用编程语言去描述应用更加工程化，可以有更多的逻辑实现。而且我认为 `cdk8s` 和 `DevOps` 结合更具有优势，它可以让开发人员接管 `Ops` 任务，当基础机构越来越多变和复杂的情况下，应用程序的部署流程更加工程化的需求也明显也在不断增加。不过目前 `cdk8s` 项目还处于早期，不建议用于生产环境，但是这种用编程语言来描述应用的思路还是非常值得关注的。

* https://cdk8s.io/
* https://cdk8s.io/getting-started/python