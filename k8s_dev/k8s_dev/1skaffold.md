# Skaffold-简化本地开发kubernetes应用的神器

> 墙裂推荐kubernetes应用开发者使用的工具

在我们开发`kubernetes`应用的过程中，一般情况下是我们在本地开发调试测试完成以后，再通过`CI/CD`的方式部署到`kubernetes`的集群中，这个过程首先是非常繁琐的，而且效率非常低下，因为你想验证你的每次代码修改，就得提交代码重新走一遍`CI/CD`的流程，我们知道编译打包成镜像这些过程就是很耗时的，即使我们在自己本地搭建一套开发`kubernetes`集群，也同样的效率很低。在实践中，若不在本地运行那些服务，调试将变得颇具挑战。

**就在几天前，我遇到了`Skaffold`，它是一款命令行工具，旨在促进`kubernetes`应用的持续开发，`Skaffold`可以将构建、推送及向`kubernetes`集群部署应用程序的过程自动化.**

## 介绍

`Skaffold`是一款命令行工具，旨在促进`Kubernetes`应用的持续开发。

你可以在本地迭代应用源码，然后将其部署到本地或者远程`Kubernetes`集群中。`Skaffold`会处理构建、上传和应用部署方面的工作流。它通用可以在自动化环境中使用，例如`CI/CD`流水线，以实施同样的工作流，并作为将应用迁移到生产环境时的工具 —— `Skaffold` 官方文档

### Skaffold的特点：

* 没有服务器端组件，所以不会增加你的集群开销
* 自动检测源代码中的更改并自动构建/推送/部署
* **自动更新镜像`TAG`，不要担心手动去更改`kubernetes`的 `manifest` 文件**
* 一次性构建/部署/上传不同的应用，因此它对于微服务同样完美适配
* 支持开发环境和生产环境，通过仅一次运行`manifest`，或者持续观察变更

**另外`Skaffold`是一个可插拔的架构，允许开发人员选择自己最合适的工作流工具**

![Alt Image Text](images/1_1.png "Body image")

我们可以通过下面的 gif 图片来了解`Skaffold`1的使用

![Alt Image Text](images/1_2.gif. "Body image")

## 使用

要使用Skaffold最好是提前在我们本地安装一套单节点的`kubernetes`集群，比如`minikube`或者`Docker for MAC/Windows`的`Edge`版

### 安装

**您将需要安装以下组件后才能开始使用`Skaffold`：**

**1. skaffold**

下载最新的`Linux`版本，请运行如下命令：

```
$ curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 && chmod +x skaffold && sudo mv skaffold /usr/local/bin
```

下载最新的OSX版本，请运行：

```
$ curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-darwin-amd64 && chmod +x skaffold && sudo mv skaffold /usr/local/bin
```

当然如果由于某些原因你不能访问上面的链接的话，则可以前往Skaffold的[github release](https://github.com/GoogleCloudPlatform/skaffold/releases)页面下载相应的安装包。

```
$ skaffold version
v1.9.1

 skaffold -h
A tool that facilitates continuous development for Kubernetes applications.

  Find more information at: https://skaffold.dev/docs/getting-started/

End-to-end pipelines:
  run               Run a pipeline
  dev               Run a pipeline in development mode
  debug             [beta] Run a pipeline in debug mode

Pipeline building blocks for CI/CD:
  build             Build the artifacts
  deploy            Deploy pre-built artifacts
  delete            Delete the deployed application
  render            [alpha] Perform all image builds, and output rendered Kubernetes manifests

Getting started with a new project:
  init              [alpha] Generate configuration for deploying an application
  fix               Update old configuration to a newer schema version

Other Commands:
  completion        Output shell completion for the given shell (bash or zsh)
  config            Interact with the Skaffold configuration
  credits           Export third party notices to given path (./skaffold-credits by default)
  diagnose          Run a diagnostic on Skaffold
  schema            List and print json schemas used to validate skaffold.yaml configuration
  survey            Show Skaffold survey url
  version           Print the version information

Usage:
  skaffold [flags] [options]

Use "skaffold <command> --help" for more information about a given command.
Use "skaffold options" for a list of global command-line options (applies to all commands).
```

### 开发

我们可以在本地开发一个非常简单的应用程序，然后通过`Skaffold`来进行迭代开发，这里我们直接使用`Skaffold`的官方示例，**首先`clone`代码**：

然后我们定位到`examples/getting-started`目录下去：

```
cd skaffold/examples/getting-started
 tree .
.
├── Dockerfile
├── README.md
├── k8s-pod.yaml
├── main.go
└── skaffold.yaml

0 directories, 5 files
```

该目录下面有一个非常简单的`golang`程序:（`main.go`）

```
package main

import (
	"fmt"
	"time"
)

func main() {
	for {
		fmt.Println("Hello world!")

		time.Sleep(time.Second * 1)
	}
}
```

**其中`skaffold-gcb.yaml`文件我们可以暂时忽略，这个文件是和`google cloud`结合使用的，我们可以看下`skaffold.yaml`文件内容，**这里我已经将镜像名称改成了我自己的了（`nyjxi/skaffold-example`），如下：

```
apiVersion: skaffold/v2beta3
kind: Config
build:
  artifacts:
  - image: nyjxi/skaffold-example
deploy:
  kubectl:
    manifests:
      - k8s-*
```

然后我们可以看到`k8s-pod.yaml`文件，**其中的镜像名称是一个`nyjxi/skaffold-example `的参数，这个地方`Skaffold`会自动帮我们替换成正在的镜像地址的**，如下：

```
apiVersion: v1
kind: Pod
metadata:
  name: getting-started
spec:
  containers:
  - name: getting-started
    image: nyjxi/skaffold-example
```

然后我们就可以在`getting-started`目录下面执行`skaffold dev`命令了：

```
cd examples/getting-started

$ skaffold dev
Listing files to watch...
 - nyjxi/skaffold-example
Generating tags...
 - nyjxi/skaffold-example -> nyjxi/skaffold-example:v1.9.0-25-gd7d0e8713-dirty
Checking cache...
 - nyjxi/skaffold-example: Not found. Building
Found [docker-desktop] context, using local docker daemon.
Building [nyjxi/skaffold-example]...
Sending build context to Docker daemon  3.072kB
Step 1/7 : FROM golang:1.12.9-alpine3.10 as builder
1.12.9-alpine3.10: Pulling from library/golang
9d48c3bd43c5: Already exists 
7f94eaf8af20: Pull complete 
9fe9984849c1: Pull complete 
cf0db633a67d: Pull complete 
0f7136d71739: Pull complete 
Digest: sha256:e0660b4f1e68e0d408420acb874b396fc6dd25e7c1d03ad36e7d6d1155a4dff6
Status: Downloaded newer image for golang:1.12.9-alpine3.10
 ---> e0d646523991
Step 2/7 : COPY main.go .
 ---> 78dd54602b0e
Step 3/7 : RUN go build -o /app main.go
 ---> Running in 4bdc0cc19720
 ---> 64956d29004c
Step 4/7 : FROM alpine:3.10
3.10: Pulling from library/alpine
21c83c524219: Pull complete 
Digest: sha256:f0e9534a598e501320957059cb2a23774b4d4072e37c7b2cf7e95b241f019e35
Status: Downloaded newer image for alpine:3.10
 ---> be4e4bea2c2e
Step 5/7 : ENV GOTRACEBACK=single
 ---> Running in 41eb0f517a91
 ---> 018cd648e357
Step 6/7 : CMD ["./app"]
 ---> Running in eecfa2f4586f
 ---> 38b9f7c5ab11
Step 7/7 : COPY --from=builder /app .
 ---> 8e23e1deee03
Successfully built 8e23e1deee03
Successfully tagged nyjxi/skaffold-example:v1.9.0-25-gd7d0e8713-dirty
Tags used in deployment:
 - nyjxi/skaffold-example -> nyjxi/skaffold-example:8e23e1deee03485a8db2f88b79e58b5e0c9609fd8659dd8abedcff334ad6e20b
Starting deploy...
 - pod/getting-started created
Waiting for deployments to stabilize...
Deployments stabilized in 32.388433ms
Watching for changes...
[getting-started] Hello world!
[getting-started] Hello world!
[getting-started] Hello world!

^CCleaning up...
 - pod "getting-started" deleted
```

`Skaffold`已经帮我们做了很多事情了：

* 用本地源代码构建 `Docke` 镜像
* 用它的`sha256`值作为镜像的标签
* 设置`skaffold.yaml`文件中定义的 `kubernetes manifests` 的镜像地址
* 用`kubectl apply -f`命令来部署 `kubernetes` 应用

 部署完成后，我们可以看到 pod 打印出了如下的信息：

```
[getting-started getting-started] Hello Skaffold!
[getting-started getting-started] Hello Skaffold!
[getting-started getting-started] Hello Skaffold!
```
同样的，我们可以通过kubectl工具查看当前部署的 POD：


```
$ kubectl get pods | grep getting-started
getting-started                             1/1     Running   0          6s
```

然后我们可以打印出上面的 POD 的详细信息：

```
$ kubectl get pod getting-started  -o yaml
...
spec:
  containers:
  - image: nyjxi/skaffold-example:8e23e1deee03485a8db2f88b79e58b5e0c9609fd8659dd8abedcff334ad6e20b
    imagePullPolicy: IfNotPresent
    name: getting-started
    resources: {}
    terminationMessagePath: /dev/termination-log
    terminationMessagePolicy: File
...
```

我们可以看到我们部署的 `POD` 的镜像地址，和我们已有的 `docker` 镜像地址和标签是一样的：

```
$ docker images |grep skaffold
nyjxi/skaffold-example     8e23e1deee03485a8db2f88b79e58b5e0c9609fd8659dd8abedcff334ad6e20b   8e23e1deee03
        9 minutes ago       7.58MB
```

现在，我们来更改下我们的`main.go`文件：

```
package main
import (
    "fmt"
    "time"
)

func main() {
    for {
        fmt.Println("Hello Jacob God!")
        time.Sleep(time.Second * 3)
    }
}
```
现在，我们来更改下我们的`main.go`文件：

```
$ skaffold dev
Listing files to watch...
 - nyjxi/skaffold-example
Generating tags...
 - nyjxi/skaffold-example -> nyjxi/skaffold-example:v1.9.0-25-gd7d0e8713-dirty
Checking cache...
 - nyjxi/skaffold-example: Not found. Building
Found [docker-desktop] context, using local docker daemon.
Building [nyjxi/skaffold-example]...
Sending build context to Docker daemon  3.072kB
...Successfully built 5197d27f25cf
Successfully tagged nyjxi/skaffold-example:v1.9.0-25-gd7d0e8713-dirty
Tags used in deployment:
 - nyjxi/skaffold-example -> nyjxi/skaffold-example:5197d27f25cf4d76b47bc06489e890ed9513f2f0859dd44a122dfb6d60d8417e
Starting deploy...
 - pod/getting-started configured
Waiting for deployments to stabilize...
Deployments stabilized in 21.664598ms
Watching for changes...
[getting-started] Hello world!
[getting-started] Hello world!
[getting-started] Hello Jacob God!
[getting-started] Hello Jacob God!
[getting-started] Hello Jacob God!
```

是不是立刻就变成了我们修改的结果了啊，同样我们可以用上面的样式去查看下 POD 里面的镜像标签是已经更改过了。

## 总结

我这里为了说明`Skaffold`的使用，可能描述显得有点拖沓，但是当你自己去使用的时候，就完全能够感受到`Skaffold`为开发`kubernetes`应用带来的方便高效，大大的提高了我们的生产力。 另外在`kubernetes`开发自动化工具领域，还有一些其他的选择，比如`Azure`的Draft、Datawire 的 Forge 以及 Weavework 的 Flux，大家都可以去使用一下，其他微软的Draft是和Helm结合得非常好，不过Skaffold当然也是支持的，工具始终是工具，能为我们提升效率的就是好工具，不过从开源的角度来说，信 Google 准没错。

