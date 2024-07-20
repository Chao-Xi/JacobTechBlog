# 2024 Dockerfile 增强新语法

Dockerfile 是使用 Docker 的相关开发人员的基本工具，用来充当构建 Docker 镜像的模板，在这个文件中包含用户可以在命令行上调用来构建镜像的所有命令。了解并有效利用 Dockerfile 可以显着简化开发流程，实现镜像创建的自动化并确保不同开发阶段的环境一致。Dockerfile 对于定义 Docker 容器内的项目环境、依赖项和应用程序配置至关重要。

借助新版本的 BuildKit 构建器工具包、Docker Buildx CLI 和 BuildKit v1.7.0 版本的 Dockerfile 前端，开发人员现在可以访问增强的 Dockerfile 功能。


本文我们将深入探讨这些新的 Dockerfile 功能，并解释如何在项目中利用它们来进一步优化 Docker 工作流程。

## 版本控制

在开始之前，**我们先快速提醒一下 Dockerfile 的版本控制方式以及您应该执行哪些操作来更新它。**

**尽管大多数项目使用 Dockerfile 来构建镜像，但其实 BuildKit 不仅限于该格式。**

BuildKit 支持多个不同的前端来定义 BuildKit 要处理的构建步骤。任何人都可以创建这些前端，将它们打包为常规容器镜像，并在调用构建时从注册表加载它们。

在新版本中，我们向 Docker Hub 发布了两个此类镜像：

`docker/dockerfile:1.7.0 和 docker/dockerfile:1.7.0-labs`

要使用新特性，您需要在文件开头指定 `#syntax` 指令，以告诉 BuildKit 用于构建的前端镜像。这里我们将其设置为使用最新的 `1.x.x` 主要版本，例如：

```
# syntax=docker/dockerfile:1.x.x

FROM alpine
```

**这意味着 BuildKit 与 Dockerfile 前端语法解耦，您可以立即开始使用新的 Dockerfile 特性，而不必担心您正在使用哪个 BuildKit 版本。**

只要您在 Dockerfile 顶部定义正确的 #syntax 指令，本文中描述的所有示例都适用于任何支持 BuildKit 的 Docker 版本。

## 变量扩展


**编写 Dockerfile 时，构建步骤可以包含使用构建参数 (`ARG`) 和环境变量 (`ENV`) 指令定义的变量。**

构建参数和环境变量之间的区别在于，环境变量保留在生成的镜像中，并在从中创建容器时持续存在。

**当您使用此类变量时，您很可能在 `COPY`、`RUN` 和其他命令中使用 `${NAME}`，或者 `$NAME`。**

您可能不知道 Dockerfile 支持两种形式的类似 Bash 的变量扩展：

* `${variable:-word}`：如果变量未设置，则将值设置为 word
* `${variable:+word}`：如果变量已设置，则将值设置为 word

到目前为止，**这些特殊形式在 Dockerfile 中并没有多大用处，因为 ARG 指令的默认值可以直接设置**：

```
FROM alpine
ARG foo="default value"
```

如果您是各种 shell 专家，您就会知道 Bash 和其他工具通常具有许多附加形式的变量扩展，以简化脚本的开发。

在 Dockerfile v1.7 中，我们就添加了一部分这样的功能。现在，您可以在 Dockerfile 中使用以下形式的变量扩展：

* **`${variable#pattern}` 和 `${variable##pattern} `从变量值中删除最短或最长的前缀**
* **`${variable%pattern}` 和 `${variable%%pattern}` 从变量值中删除最短或最长的后缀**
* `${variable/pattern/replacement}` 替换最先出现的 pattern 模式
* `${variable//pattern/replacement}` 替换所有出现的 pattern 模式


这些规则的使用方式一开始可能并不完全明显。让我们看一下实际 Dockerfile 中的一些示例。

**例如，项目通常无法就下载依赖项的版本是否应具有 v 前缀达成一致，下面的方式可以允许您获取所需的格式**：

```
# example VERSION=1.2.3
ARG VERSION=${VERSION#v}

# VERSION is now 1.2.3
```

**又比如下面的这个示例中同一个 `VERSION` 变量我们可以在不同的地方多次使用**：

```
ARG VERSION=v1.7.13
ADD https://github.com/containerd/containerd/releases/download/${VERSION}/containerd-${VERSION#v}-linux-amd64.tar.gz /
```

有的时候我们可能希望不同平台的构建配置不同的命令行，这时候我们就可以使用 BuildKit 提供的内置变量，例如 `TARGETOS` 和 `TARGETARCH`。

但是需要注意并非所有项目都使用相同的值，例如，在容器和 Go 生态中，我们将 64 位 ARM 架构称为 arm64，但有时您需要 aarch64，这个时候我们就可以使用 `${variable/pattern/replacement}` 来进行替换：

```
ADD https://github.com/oven-sh/bun/releases/download/bun-v1.0.30/bun-linux-${TARGETARCH/arm64/aarch64}.zip /
```

**接下来让我们看看新的扩展如何在多阶段构建中发挥作用。**

如果您构建多平台镜像并希望仅针对特定平台运行其他 COPY 或 RUN 命令，则可以使用该模式。

简而言之，其想法是定义一个全局构建参数，然后定义构建阶段，在阶段名称中使用构建参数值，同时通过构建参数名称指向目标阶段的基础。

以前的方式如下所示：

```
ARG BUILD_VERSION=1

FROM alpine AS base
RUN …

FROM base AS branch-version-1
RUN touch version1

FROM base AS branch-version-2
RUN touch version2

FROM branch-version-${BUILD_VERSION} AS after-condition

FROM after-condition
RUN …
```

使用此模式进行多平台构建时，限制之一是 build-arg 的所有可能值都需要由 Dockerfile 定义。**因为我们希望 Dockerfile 的构建方式可以在任何平台上构建，而不是将其限制在特定的平台上，所以这种方式会有一些限制**。

通过新的扩展，我们可以来演示仅在 RISC-V 上运行特殊命令，这仍然有些新，可能需要自定义行为：

```
#syntax=docker/dockerfile:1.7

ARG ARCH=${TARGETARCH#riscv64}
ARG ARCH=${ARCH:+"common"}
ARG ARCH=${ARCH:-$TARGETARCH}

FROM --platform=$BUILDPLATFORM alpine AS base-common
ARG TARGETARCH
RUN echo "Common build, I am $TARGETARCH" > /out

FROM --platform=$BUILDPLATFORM alpine AS base-riscv64
ARG TARGETARCH
RUN echo "Riscv only special build, I am $TARGETARCH" > /out

FROM base-${ARCH} AS base
```

我们再仔细看下上面的这些 `ARCH` 定义：

* **第一个将 ARCH 设置为 TARGETARCH，但从该值中删除 riscv64**。
* 我们实际上并不希望其他架构使用它们自己的值，而是希望它们都共享一个共同的值。**因此，我们将 ARCH 设置为 common，除非它已从之前的 riscv64 规则中清除**。
* 现在，如果我们仍然有一个空值，我们将其默认为 $TARGETARCH。
* 最后一个定义是可选的，因为我们已经为这两种情况提供了唯一值，但它使最终阶段名称 base-riscv64 更易于阅读。

