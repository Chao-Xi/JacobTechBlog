# **Kustomize中模板化的正确方式(2023)**

Kustomize 不是一个新工具，它自 2017 年以来一直在建设中，并在 1.14 版本中作为原生 kubectl 子命令引入。是的，你没听错，它现在直接嵌入到你日常使用的工具中，所以你可以扔掉 helm 命令。

## 哲学

当使用 Git 作为 VCS、创建 Docker 镜像或在 Kubernetes 中声明资源时，Kustomize 试图遵循你在日常工作中使用的理念。

所以，首先，Kustomize 就像 Kubernetes，它是完全声明式的！你说你想要什么，系统就会提供给你，你不必遵循命令式的方式并描述希望它如何构建事物。

其次，它像 Docker 一样工作。你有很多层，每一层都在修改之前的层。多亏了这一点，你可以不断地写出高于他人的东西，而不会在你的配置中增加复杂性。构建的结果将是添加基础和你在其上应用的不同层。

最后，与 Git 一样，你可以使用远程库作为你工作的开始，并在其上添加一些定制。

## 使用

```
 tree .
.
└── k8s
    ├── base
    │   ├── deployment.yaml
    │   ├── kustomization.yaml
    │   └── service.yaml
    └── overlays
        └── prod
            ├── custom-env.yaml
            ├── database-secret.yaml
            ├── kustomization.yaml
            └── replica-and-rollout-strategy.yaml

4 directories, 7 files
```

### 基础

要开始使用 Kustomize，你需要有原始的 yaml 文件来描述你要部署到集群中的任何资源。我们这里的示例将这些文件将存储在文件夹 `./k8s/base/ `中。

这些文件将永远不会被修改，我们将在它们上面应用自定义来创建新的资源定义。

注意：你可以随时使用命令 `kubectl apply -f ./k8s/base/` 构建基础模板（例如，用于开发环境）。 在此示例中，我们将使用一个 Service 和一个 Deployment 资源：

**`service.yaml`**


```
apiVersion: v1
kind: Service
metadata:
  name: sl-demo-app
spec:
  ports:
    - name: http
      port: 8080
  selector:
    app: sl-demo-app
```

**`deployment.yaml`**

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sl-demo-app
spec:
  selector:
    matchLabels:
      app: sl-demo-app
  template:
    metadata:
      labels:
        app: sl-demo-app
    spec:
      containers:
        - name: app
          image: foo/bar:latest
          ports:
            - name: http
              containerPort: 8080
              protocol: TCP
```

我们将在该文件夹中添加一个名为 kustomization.yaml 的新文件：

```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - service.yaml
  - deployment.yaml
```

该文件将是你核心文件，它描述了你使用的资源，这些资源文件是相对于当前文件的路径。

> 注意：这个 `kustomization.yaml` 文件在运行 `kubectl apply -f ./k8s/base/` 时可能会导致错误，你可以使用参数 `--validate=false `运行它，或者干脆不对整个文件夹运行命令。

要将该 base 基础模板应用到集群，你只需执行以下命令：

```
$ kubectl apply -k k8s/base
```


但是这样会直接将我们的模板应用到集群中，有时候我们可能希望将模板渲染出来看下结果是否正确，这个时候我们可以去直接使用 kustomize 的命令 kustomize build 来实现，所以我们需要单独安装下 kustomize，对于 Mac 用户可以直接使用 brew 命令一键安装，其他系统可以直接前往 Release 页面下载二进制文件，然后放入 PATH 路径即可。

```
$ brew install kustomize
```

要查看将在你的集群中应用了什么，我们将在本文中主要使用命令 kustomize build 而不是 kubectl apply -k。

`kustomize build k8s/base` 命令的结果如下，会直接将两个文件连接在一起：


```
$ kustomize build k8s/base
apiVersion: v1
kind: Service
metadata:
  name: sl-demo-app
spec:
  ports:
  - name: http
    port: 8080
  selector:
    app: sl-demo-app
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sl-demo-app
spec:
  selector:
    matchLabels:
      app: sl-demo-app
  template:
    metadata:
      labels:
        app: sl-demo-app
    spec:
      containers:
      - image: foo/bar:latest
        name: app
        ports:
        - containerPort: 8080
          name: http
          protocol: TCP
```
          
### 定制

现在，我们想要针对特定  场景来定制我们的应用程序，例如，针对我们的生产环境，接下来我们将看到如何通过一些修改来增强我们的基础。本文的主要目标不是涵盖 Kustomize 的全部功能，而是作为一个标准示例向你展示此工具背后的理念。

首先，我们将创建文件夹 `k8s/overlays/prod`，其中包含一个 `kustomization.yaml `文件，包含以下内容
          
```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
  - ../../base
```

如果我们构建它，我们将看到与之前构建 base 时相同的结果。

```
$ kustomize build k8s/overlays/prod
```
          
          
为 Deployment 定义环境变量


在 base 中，我们没有定义任何环境变量，现在我们将添加 `env` 变量到 base 中去，要做到这一点，非常简单，我们只需要创建我们想要在 base 之上应用的 yaml 块，并在 `kustomization.yaml` 中引用它。

`custom-env.yaml` 包含的环境变量如下所示：

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sl-demo-app
spec:
  template:
    spec:
      containers:
        - name: app # (1)
          env:
            - name: CUSTOM_ENV_VARIABLE
              value: Value defined by Kustomize ❤️
```

> 注意：这里的 name (1) 非常重要，可以让 Kustomize 找到需要修改的正确容器。

你可以看到这个 yaml 文件本身是无效的，但它只描述了我们想在之前的 base 上添加的内容。

我们只需将此文件添加到 `k8s/overlays/prod/kustomization.yaml` 中的 patches 属性下面即可

```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base

patches:
  - path: custom-env.yaml
```

如果现在我们来构建，将会得到下面的结果:

```
$ kustomize build k8s/overlays/prod
apiVersion: v1
kind: Service
metadata:
  name: sl-demo-app
spec:
  ports:
  - name: http
    port: 8080
  selector:
    app: sl-demo-app
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sl-demo-app
spec:
  selector:
    matchLabels:
      app: sl-demo-app
  template:
    metadata:
      labels:
        app: sl-demo-app
    spec:
      containers:
      - env:
        - name: CUSTOM_ENV_VARIABLE
          value: Value defined by Kustomize ❤️
        image: foo/bar:latest
        name: app
        ports:
        - containerPort: 8080
          name: http
          protocol: TCP
```

可以看到我们上面定义的 env 块已应用在我们的 base 之上了，现在 `CUSTOM_ENV_VARIABLE` 将出现在我们的 deployment.yaml 中。

patches 属性中可以直接指定一个 yaml 文件，也可以直接在该属性这里修改资源，补丁可以包括容器镜像、端口、环境变量等。比如可以在 kustomization.yaml 文件中添加以下内容：

```
patches:
  - target:
      kind: Deployment
      name: sl-demo-app
    patch: |-
      - op: replace
        path: /spec/template/spec/containers/0/image
        value: my-image:latest
```

上述内容将基础资源中名为 `sl-demo-app` 的 `Deployment` 的容器镜像修改为 `my-image:latest`。

**更改副本数量**

接下来我们想添加有关副本数量的信息，像之前一样，仅包含定义副本所需的额外信息的块或 yaml 就足够了：

```
# replica-and-rollout-strategy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sl-demo-app
spec:
  replicas: 10
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
    type: RollingUpdate
```

和以前一样，我们将它添加到 kustomization.yaml 中的 patches 列表中：

```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base

patches:
  - path: custom-env.yaml
  - path: replica-and-rollout-strategy.yaml
```

同样执行命令 `kustomize build k8s/overlays/prod` 后会得到如下结果：

```
$ kustomize build k8s/overlays/prod
apiVersion: v1
kind: Service
metadata:
  name: sl-demo-app
spec:
  ports:
  - name: http
    port: 8080
  selector:
    app: sl-demo-app
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sl-demo-app
spec:
  replicas: 10
  selector:
    matchLabels:
      app: sl-demo-app
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: sl-demo-app
    spec:
      containers:
      - env:
        - name: CUSTOM_ENV_VARIABLE
          value: Value defined by Kustomize ❤️
        image: foo/bar:latest
        name: app
        ports:
        - containerPort: 8080
          name: http
          protocol: TCP
```


可以看到副本数和 rollingUpdate 策略已经应用在 base 之上了。

**通过命令行使用 Secret 定义**

我们经常会从命令行将一些变量设置为 Secret 数据，这里我们使用 kustomize 的一个子命令来编辑 `kustomization.yaml ` 并为创建一个 Secret，如下所示

```
$ cd k8s/overlays/prod
$ kustomize edit add secret sl-demo-app --from-literal=db-password=12345
```

上面的命令会修改 `kustomization.yaml` 文件并在其中添加一个 SecretGenerator，内容如下所示：

```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base

patches:
  - path: custom-env.yaml
  - path: replica-and-rollout-strategy.yaml
secretGenerator:
  - literals:
      - db-password=12345
    name: sl-demo-app
    type: Opaque
```

同样如果从示例项目的根文件夹运行 `kustomize build k8s/overlays/prod` 命令将获得以下输出。

```
apiVersion: v1
data:
  db-password: MTIzNDU=
kind: Secret
metadata:
  name: sl-demo-app-gkmm8tkdd7
type: Opaque
---
apiVersion: v1
kind: Service
metadata:
  name: sl-demo-app
spec:
  ports:
    - name: http
      port: 8080
  selector:
    app: sl-demo-app
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sl-demo-app
spec:
  replicas: 10
  selector:
    matchLabels:
      app: sl-demo-app
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: sl-demo-app
    spec:
      containers:
        - env:
            - name: CUSTOM_ENV_VARIABLE
              value: Value defined by Kustomize ❤️
          image: foo/bar:latest
          name: app
          ports:
            - containerPort: 8080
              name: http
              protocol: TCP
```

注意上面生成的 Secret 对象名称是 `sl-demo-app-gkmm8tkdd7` 而不是 sl-demo-app，这是正常的，如果 Secret 内容发生变化，就可以触发 Deployment 的滚动更新。

如果想在我们的 Deployment 中使用这个 Secret，我们只需要像以前一样添加一个使用 Secret 的新层定义即可。比如我们将 `db-password` 值以环境变量的方式注入 pod，则可以声明如下的层文件：

```
# database-secret.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sl-demo-app
spec:
  template:
    spec:
      containers:
        - name: app
          env:
            - name: "DB_PASSWORD"
              valueFrom:
                secretKeyRef:
                  name: sl-demo-app
                  key: db.password
```

然后在 kustomization.yaml 文件 pathes 中添加上面的层文件：

```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base

patches:
  - path: custom-env.yaml
  - path: replica-and-rollout-strategy.yaml
  - path: database-secret.yaml

secretGenerator:
  - literals:
      - db-password=12345
    name: sl-demo-app
    type: Opaque
```

构建后可以得到如下的结果：

```
$ kustomize build k8s/overlays/prod
apiVersion: v1
data:
  db-password: MTIzNDU=
kind: Secret
metadata:
  name: sl-demo-app-gkmm8tkdd7
type: Opaque
---
apiVersion: v1
kind: Service
metadata:
  name: sl-demo-app
spec:
  ports:
  - name: http
    port: 8080
  selector:
    app: sl-demo-app
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sl-demo-app
spec:
  replicas: 10
  selector:
    matchLabels:
      app: sl-demo-app
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: sl-demo-app
    spec:
      containers:
      - env:
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              key: db.password
              name: sl-demo-app-gkmm8tkdd7
        - name: CUSTOM_ENV_VARIABLE
          value: Value defined by Kustomize ❤️
        image: foo/bar:latest
        name: app
        ports:
        - containerPort: 8080
          name: http
          protocol: TCP
```


可以看到 Deployment 中新增了 `DB_PASSWORD` 这部分内容，使用的 secretKeyRef.name 名称则为 Secret 的名称。

### 更改镜像

与 Secret 一样，有一个自定义指令允许直接从命令行更改镜像或标签，如果你是通过 CI/CD 来发布应用这将非常有用，如下所示：

```
$ cd k8s/overlays/prod
$ TAG_VERSION=3.4.5 # (1)
$ kustomize edit set image foo/bar=foo/bar:$TAG_VERSION
```

这里的 `TAG_VERSION` 通常是我们的 CI/CD 系统来定义的，上面的命令执行后，`kustomization.yaml` 文件中会新增一个 images 的属性，里面包括 `newName` 和 `newTag` 两个属性：

```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base

patches:
  - path: custom-env.yaml
  - path: replica-and-rollout-strategy.yaml
  - path: database-secret.yaml

secretGenerator:
  - literals:
      - db-password=12345
    name: sl-demo-app
    type: Opaque
images:
  - name: foo/bar
    newName: foo/bar
    newTag: 3.4.5
```

同样执行 build 命令后得到的 Deployment 中的 image 就是 foo/bar:3.4.5

## 总结


过上面的这些简单示例我们可以了解如何利用 Kustomize 的强大功能来定义 Kubernetes 资源文件，甚至无需使用模板系统。我们所做的所有修改文件都将应用在原始文件之上，而无需使用花括号和命令式修改对其进行更改。

Kustomize 中还有很多高级用法，例如 mixins 和继承逻辑或其他允许为每个创建的对象定义名称、标签或命名空间的指令，我们后续再来介绍。


