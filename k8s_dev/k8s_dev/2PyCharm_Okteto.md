## 使用 PyCharm、Okteto 和 Kubernetes 搭建远程开发环境

[Okteto](https://okteto.com/) 是一个通过在 Kubernetes 中来开发和测试代码的应用程序开发工具。可以通过 `Okteto` 在 `Kubernetes` 中一键为我们启动一个开发环境，非常简单方便。前面我们也介绍过 `Google` 推出的 `Skaffol`d 工具，今天我们演示下如何使用 `Okteto` 来搭建 `Python` 应用开发环境。

## 安装


我们只需要在本地开发机上面安装 [Okteto CLI](https://okteto.com/docs/getting-started/installation) 工具即可，要想使用 `Okteto` 来配置环境就需要我们本地机上可以访问一个 `Kubernetes` 集群，所以前提是需要配置一个可访问的 `Kubernetes `集群的 `kubeconfig` 文件，如果你没有 `Kubernetes` 集群的话，可以使用 [`OKteto Cloud`](https://okteto.com/) 提供的环境，对于个人用户来说免费的额度基本上够用了。`Okteto CLI` 就是一个二进制文件，所以安装非常简单。

对于 MacOS 或者 Linux 系统执行执行如下命令即可：

```
$ curl https://get.okteto.com -sSfL | SH
```

对于 `Windows` 用户直接下载 `https://downloads.okteto.com/cli/okteto.exe` 并将其添加到您的 `$PATH` 路径中即可。

配置完成后在终端中执行如下命令，正常就安装完成了：

```