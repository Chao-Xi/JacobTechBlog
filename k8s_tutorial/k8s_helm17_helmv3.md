# Helm V2 迁移到 V3 版本

[Helm V3 版本](https://v3.helm.sh/)已经发布了第三个 `Beta` 版本了，由于 `V2` 和 `V3` 版本之间的架构变化较大，所以如果我们现在正在使用 `V2` 版本的话，**要迁移到 `V3` 版本了就有点小麻烦，其中最重要的当然就是数据迁移的问题，为了解决这个版本迁移问题，官方提供了一个名为 `helm-2to3` 的插件可以来简化我们的迁移工作**。

```
$ helm version
Client: &version.Version{SemVer:"v2.14.3", GitCommit:"0e7f3b6637f7af8fcfddb3d2941fcc7cbebb0085", GitTreeState:"clean"}
Server: &version.Version{SemVer:"v2.14.3", GitCommit:"0e7f3b6637f7af8fcfddb3d2941fcc7cbebb0085", GitTreeState:"clean"}
```

## 安装 Helm V3

为了能够让 `Helm V2 CLI` 包还可以继续使用，所以我们这里就不直接覆盖了，让两个版本的 CLI 包可以共存，比较迁移还是有风险的，等到我们准备好移除 V2 版本的时候再删除也不迟。

在 `Helm GitHub` 仓库上下载最新的 `V3 Beta` 版本，地址：[https://github.com/helm/helm/releases](https://github.com/helm/helm/releases)，要注意选择和你系统一致的二进制包，比如我们这里是 `Mac` 系统，就下载`MacOS amd64`这个包，下载完成后解压将对应的 `Helm CLI` 包重命名为`helm3`，并移动到 PATH 路径（比如`/usr/local/bin`）下面去，然后我们就可以准备使用 `helm3` 命令了：


我的环境是Centos7, 安装的具体步骤如下

```
$ cd helm
$ wget https://get.helm.sh/helm-v3.0.0-beta.3-linux-amd64.tar.gz
$ tar -zxvf helm-v3.0.0-beta.3-linux-amd64.tar.gz
$ sudo mv helm /usr/local/bin/helm3
```

```
$ helm3 version
version.BuildInfo{Version:"v3.0.0-beta.3", GitCommit:"5cb923eecbe80d1ad76399aee234717c11931d9a", GitTreeState:"clean", GoVersion:"go1.12.9"}
```

```
$ helm repo list
NAME  	URL
stable	https://kubernetes-charts.storage.googleapis.com
local 	http://127.0.0.1:8879/charts
```

```
$ helm3 repo list
Error: no repositories to show
```

我们可以看到使用 `helm3` 命令查看不到我们之前配置的 chart 仓库信息。

## HELM-2TO3 插件

`helm-2to3` 插件就可以让我们将 `Helm V2` 版本的配置和 `release` 迁移到 `Helm V3` 版本去。

安装的 Kubernetes 对象不会被修改或者删除，所以不用担心。接下来我们就来安装这个插件。


### 安装

直接使用下面的命令安装即可：

```
$ helm3 plugin install https://github.com/helm/helm-2to3
Downloading and installing helm-2to3 v0.1.1 ...
https://github.com/helm/helm-2to3/releases/download/v0.1.1/helm-2to3_0.1.1_linux_amd64.tar.gz
tar: LICENSE: time stamp 2019-09-11 15:28:09 is 971666.287859679 s in the future
tar: plugin.yaml: time stamp 2019-09-11 15:28:09 is 971666.286604121 s in the future
tar: 2to3: time stamp 2019-09-11 15:29:05 is 971719.143007412 s in the future
Installed plugin: 2to3
```

然后可以使用 `helm3` 命令查看插件是否安装成功：




```
$ helm3 plugin list
NAME	VERSION	DESCRIPTION
2to3	0.1.1  	migrate Helm v2 configuration and releases in-place to Helm v3

$ helm3 2to3
Migrate Helm v2 configuration and releases in-place to Helm v3

Usage:
  2to3 [command]

Available Commands:
  convert     migrate Helm v2 release in-place to Helm v3
  help        Help about any command
  move        migrate Helm v2 configuration in-place to Helm v3

Flags:
  -h, --help   help for 2to3

Use "2to3 [command] --help" for more information about a command.
```

到这里就证明我们的 `helm-2to3` 插件已经安装成功了。


### 插件特性

现在插件支持的功能主要有两个部分：

* 迁移 `Helm V2` 配置
* 迁移 `Helm V2 release`

接下来我们就来分别操作下。

## 迁移 Helm V2 配置

首先我们需要迁移 Helm V2 版本的相关配置和数据目录：

```
$  helm3 2to3 move config
[Helm 2] Home directory: /home/vagrant/.helm
[Helm 3] Config directory: /home/vagrant/.config/helm
[Helm 3] Data directory: /home/vagrant/.local/share/helm
[Helm 3] Create config folder "/home/vagrant/.config/helm" .
[Helm 3] Config folder "/home/vagrant/.config/helm" created.
[Helm 2] repositories file "/home/vagrant/.helm/repository/repositories.yaml" will copy to [Helm 3] config folder "/home/vagrant/.config/helm/repositories.yaml" .
[Helm 2] repositories file "/home/vagrant/.helm/repository/repositories.yaml" copied successfully to [Helm 3] config folder "/home/vagrant/.config/helm/repositories.yaml" .
[Helm 3] Create data folder "/home/vagrant/.local/share/helm" .
[Helm 3] data folder "/home/vagrant/.local/share/helm" created.
[Helm 2] plugins "/home/vagrant/.helm/plugins" will copy to [Helm 3] data folder "/home/vagrant/.local/share/helm/plugins" .
[Helm 2] plugins "/home/vagrant/.helm/plugins" copied successfully to [Helm 3] data folder "/home/vagrant/.local/share/helm/plugins" .
[Helm 2] starters "/home/vagrant/.helm/starters" will copy to [Helm 3] data folder "/home/vagrant/.local/share/helm/starters" .
[Helm 2] starters "/home/vagrant/.helm/starters" copied successfully to [Helm 3] data folder "/home/vagrant/.local/share/helm/starters" .
```

上面的操作会迁移：

* Chart starters
* Chart 仓库
* 插件

> 不过需要注意的是，请检查下所有的 Helm V2 下面的插件是否能够在 Helm V3 下面正常工作，把不起作用的插件删除即可。


现在我们再查看下 Chart 仓库信息：


```
$ helm3 repo list
NAME  	URL
stable	https://kubernetes-charts.storage.googleapis.com
local 	http://127.0.0.1:8879/charts
```

```
$ helm3 plugin list
NAME	VERSION	DESCRIPTION
2to3	0.1.1  	migrate Helm v2 configuration and releases in-place to Helm v3
```

我们可以看到已经可以看到 `Chart` 仓库信息了，在 `Helm V3` 下面也可以使用之前 `V2` 版本提供的 `Chart` 仓库和插件了。

上面的 `move config` 命令会创建 `Helm V3` 配置和数据目录（如果它们不存在），并将覆盖`repositories.yaml`文件（如果存在）。

此外，该插件还支持将非默认的 Helm V2 主目录以及 Helm V3 配置和数据目录，使用如下配置使用即可：

```
$ export HELM_V2_HOME=$HOME/.helm2
$ export HELM_V3_CONFIG=$HOME/.helm3
$ export HELM_V3_DATA=$PWD/.helm3
$ helm3 2to3 move config
```

## 迁移 Helm V2 Release

现在我们可以开始迁移 releases 了。可以使用如下命令查看下命令的可用选项：

```
$ helm3 2to3 convert -h
migrate Helm v2 release in-place to Helm v3

Usage:
  2to3 convert [flags] RELEASE

Flags:
      --delete-v2-releases       v2 releases are deleted after migration. By default, the v2 releases are retained
      --dry-run                  simulate a convert
  -h, --help                     help for convert
  -l, --label string             label to select tiller resources by (default "OWNER=TILLER")
  -s, --release-storage string   v2 release storage type/object. It can be 'secrets' or 'configmaps'. This is only used with the 'tiller-out-cluster' flag (default "secrets")
  -t, --tiller-ns string         namespace of Tiller (default "kube-system")
      --tiller-out-cluster       when  Tiller is not running in the cluster e.g. Tillerless
```

可以看到最后的 ·--tiller-out-cluster· 参数，甚至支持 [Tillerless Helm v2]（https://github.com/rimusz/helm-tiller）。

现在我们来查看下 `Helm V2` 下面的 `release`，然后选择一个来测试下迁移：

```
$ helm list
NAME       	REVISION	UPDATED                 	STATUS  	CHART              	APP VERSION	NAMESPACE
vitess-etcd	1       	Thu Aug 29 02:12:09 2019	DEPLOYED	etcd-operator-0.9.0	0.9.4      	vitess
```
上面我们也看到该迁移命令支持`--dry-run`选项，当然最安全的方式是先使用下该参数测试下效果：

```
$  helm3 2to3 convert --dry-run vitess-etcd
NOTE: This is in dry-run mode, the following actions will not be executed.
Run without --dry-run to take the actions described below:

Release "vitess-etcd" will be converted from Helm 2 to Helm 3.
[Helm 3] Release "vitess-etcd" will be created.
[Helm 3] ReleaseVersion "vitess-etcd.v1" will be created.
```

我们可以查看上面的`dry-run`模式下面的一些描述信息，没有什么问题的话就可以真正的来执行迁移操作了：

```
$  helm3 2to3 convert vitess-etcd
Release "vitess-etcd" will be converted from Helm 2 to Helm 3.
[Helm 3] Release "vitess-etcd" will be created.
[Helm 3] ReleaseVersion "vitess-etcd.v1" will be created.
[Helm 3] ReleaseVersion "vitess-etcd.v1" created.
[Helm 3] Release "vitess-etcd" created.
Release "vitess-etcd" was converted successfully from Helm 2 to Helm 3. Note: the v2 releases still remain and should be removed to avoid conflicts with the migrated v3 releases.
```

迁移完成后，然后检查下是否成功了：

```
$ helm list
NAME       	REVISION	UPDATED                 	STATUS  	CHART              	APP VERSION	NAMESPACE
vitess-etcd	1       	Thu Aug 29 02:12:09 2019	DEPLOYED	etcd-operator-0.9.0	0.9.4      	vitess
```

```
$ helm3 list
NAME	NAMESPACE	REVISION	UPDATED	STATUS	CHART
```

我们可以看到执行`helm3 list`命令并没有任何 `release` 信息，这是因为我们迁移的 `vitess-etcd` 这个 `release` 是被安装在`vitess`这个命名空间下面的，所以需要指定命名空间才可以看到：


```
$ helm3 list -n vitess
NAME       	NAMESPACE	REVISION	UPDATED                                	STATUS  	CHART
vitess-etcd	vitess   	1       	2019-08-29 02:12:09.972743896 +0000 UTC	deployed	etcd-operator-0.9.0
```

> 注意：由于我们没有指定	--delete-v2-releases	选项，所以 `Helm V2 etcd-operator` 这个 `releas`e 信息还是存在的，我们可以在以后使用 `kubectl` 进行删除。

当你准备好迁移你所有的 `releases` 的时候，你可以循环`helm list`里面的所有 `release` 来自动的将每个 `Helm V2 release` 迁移到 `Helm V3` 版本去。

如果你正在使用 `Tillerless Helm V2`，只需要指定`--tiller-out-cluster`选项来迁移 release 即可：

```
$ helm3 2to3 convert minio --tiller-out-cluster
```

## 清理 Helm V2 数据


最后当然就是清理之前版本的旧数据了，虽然这并不是必须的，但是还是建议你清理下，可以避免一些冲突。清理 Helm V2 的数据比较简单：


* 删除主文件夹`~/.helm`
* 如果你没有使用`--delete-v2-releases`选项，那么旧使用 `kubectl` 工具来删除 `Tiller releases` 数据
* 卸载掉烦人😱的 `Tiller`

**Happy Helm v3 sailing~**


