# Jenkins X

## Jenkins X 能做什么？

`Jenkins X` 在 `Kubernetes` 上自动安装，配置和升级 `Jenkins` 和其他应用程序（`Helm`，`Skaffold`，`Nexus` 等）。

它使用 `Docker 镜像`、`Helm Chart` 和**流水线来自动化应用程序的 CI/CD**。它使用 `GitOps` 来管理环境之间的升级，**并通过在拉取请求和生产时对其进行评论来提供大量反馈**。

## Jenkins X 入门


要安装 `Jenkins X`，首先需要在你的机器或云供应商上安装 `jx` 二进制文件。从 Google Cloud 可以获得300美元的积分，所以我决定从那里开始。

## 在 `Google Cloud` 上安装 `Jenkins X` 并创建群集


浏览到`cloud.google.com`并登录。如果你还没有帐户，请注册免费试用。转到控制台（右上角有一个链接）并激活 `Google Cloud shell`。将以下命令复制并粘贴到 `shell` 中。

```
curl -L https://github.com/jenkins-x/jx/releases/download/v1.3.79/jx-linux-amd64.tar.gz | tar xzv
sudo mv jx /usr/local/bin
```

> 注意：`Google Cloud Shell` 将在一小时后终止在你的主目录之外所做的任何更改，因此你可能必须重新运行这些命令。好消息是它们将在你的历史中，所以你只需要向上箭头并进入。


你也可以删除上面的 `sudo mv` 命令，并将以下内容添加到 `.bashrc` 中。

```
export PATH=$PATH:.
```

使用以下命令在 `GKE（Google Kubernetes Engine`）上创建集群。你可能必须为你的帐户启用 `GKE`。

```
jx create cluster gke --skip-login
```

如果系统提示你下载 `helm`，请确认你要安装。系统将提示你选择` Google Cloud Zone`。我建议选择一个靠近你的位置。对于 `Google Cloud Machine` 类型，我选择了 `n1-standard-2` 并使用了 `min（3）`和 `max（5）`个节点数的默认值。


对于 `GitHub` 名称，键入你自己的（例如 `mraible`）和你在 `GitHub` 上注册的电子邮件（例如 `matt.raible@okta.com`）。

> 注意：如果你的帐户启用了两步认证，则 `GitHub` 集成将失败。如果你希望成功完成该过程，则需要在 `GitHub` 上禁用它。

**当提示安装 `ingress controller` 时，按 `Enter` 键 确定。再次按 `Enter` 键选择默认 `domain`。**

系统将提示你创建 `GitHub API Token`。单击提供的 `URL` 并将其命名为 **“Jenkins X”**。将 `token` 值复制并粘贴回控制台。

下一步是将 `API token` 从 `Jenkins` 复制到你的控制台。按照控制台中提供的说明进行操作。

完成后，运行 `jx console` 并单击链接以登录到 `Jenkins` 实例。单击 `Administration` 并升级 `Jenkins` 及其所有插件（插件管理器 > 滚动到底部并选择全部）。

如果未能执行此步骤，将无法从 `GitHub pull request` 到 `Jenkins X CI` 进程。











