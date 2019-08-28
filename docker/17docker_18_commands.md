# Docker入门18条命令行

使用 `docker container my_command`

* `create` — 从镜像中创建一个容器
* `start` — 启动一个已有的容器
* `run` — 创建一个新的容器并且启动它
* `ls` — 列出正在运行的容器
* `inspect` — 查看关于容器的信息
* `logs` — 打印日志
* `stop` — 优雅停止正在运行的容器
* `kill` — 立即停止容器中的主要进程
* `rm` — 删除已经停止的容器

## 镜像命令

使用 `docker image my_command`

* `build` — 构建一个镜像
* `push` — 将镜像推送到远程镜像仓库中
* `ls` — 列出镜像
* `history `— 查看中间镜像信息
* `inspect` — 查看关于镜像的信息，包括层
* `rm` — 删除镜像

## 容器&镜像


* `docker version` — 列出关于Docker客户端以及服务器版本的信息
* `docker login` — 登录到`Docker`镜像仓库
* `docker system prune` — 删除所有未使用的容器、网络以及无名称的镜像（虚悬镜像）

## 容器命令详解

### 启动容器

术语“创建”，“开始”和“运行”在日常生活中都具有相似的语义，但每个都是一个独立的Docker命令，用于创建并/或启动容器。让我们先看看创建容器的命令。

```
docker container create my_repo/my_image:my_tag — 从一个镜像中创建容器
```

我将在下文中把 `my_repo/my_image:my_tag`缩写为 `my_image`。

你可以通过传递许多标志来`create`。


```
docker container create -a STDIN my_image
```

* `-a`是`--attach`的缩写，指将容器连接到`STDIN`，`STDOUT`或`STDERR`。

既然我们已经创建了一个容器，那么让我们来启动它。


```
docker container start my_container — 启动一个已有的容器
```

请注意，容器可以通过容器的ID或容器的名称来引用。

```
docker container start my_container
```

既然你知道如何创建和启动一个容器，让我们来看看最常见的`Docker`命令。它将`create`和`start`结合到一个命令中：`run`。

```
docker container run my_image
```

创建一个新容器并且启动它。这一命令同样也有许多选项。让我们看看其中几个。

`docker container run -i -t -p 1000:8000 --rm my_image`

* `-i` 是 `—interactive` 的缩写，即使未连接，也要保持`STDIN`打开；
* `-t`是`—tty`的缩写，它会分配一个伪终端，将终端与容器的`STDIN`和`STDOUT`连接起来。
* 你需要指定`-i`和`-t` 通过终端`shell`与容器交互。
* `-p`是 `–port`的缩写。端口是与外部世界的接口。`1000：8000` 将 `Docker` 端口`8000`映射到计算机上的端口`1000`。

如果你有一个app输出了一些内容到浏览器，你可以将浏览器导航到`localhost:1000`并且查看它。

#### `--rm` 自动删除停止运行的容器。


让我们再来看看run的几个例子。

```
docker container run -it my_image my_command sh
```

* `sh` 是你可在运行时指定的命令，它将在容器内部启动`shell`会话，你可以通过终端与其交互。对于`Alpine`镜像，`sh`优于`bash`，因为`Alpine`镜像不随`bash`一起安装。键入`exit`以结束交互式`shell`会话。


请注意，我们将`-i`和`-t`结合为`-it`。

```
docker container run -d my_image
```

* `-d`是`—detach`的缩写，指在后台运行容器，允许您在容器运行时将终端用于其他命令。


### 检查容器状态


如果你有许多运行中的Docker容器并且想要找到与哪一个互动，那么你需要列出它们。

`docker container ls` — 列出运行中的容器，同时提供关于容器有用的信息。

`docker container ls -a -s`

* `-a`是`--all`的缩写，列出所有容器（不仅仅是正在运行中的容器）
* `-s`是`--size`的缩写，列出每个容器的大小。

* `docker container inspect my_container` — 查看有关容器的信息
* `docker container logs my_container` — 列出容器日志

### 终止容器


有时你需要停止一个正在运行中的容器，你需要用到以下命令：


**`docker container stop my_container`**

优雅地停止一个或多个正在运行的容器。在容器关闭之前提供默认**10秒**以完成任何进程。


**如果你觉得10秒太长的话，可以使用以下命令**：

**`docker container kill my_container`**

立即停止一个或多个正在运行的容器。这就像拔掉电视上的插头一样。但是在大多数情况下，建议使用`stop`命令。


你需要删除容器可以使用以下命令：


* `docker container rm my_container` — 删除一个或多个容器
* `docker container rm $(docker ps -a -q)` — 删除所有不在运行中的容器


以上就是Docker容器的关键命令。接下来，我们来看看关于镜像的命令。


## 镜像命令详解

以下是Docker镜像使用的7条命令


### 构建镜像

```
docker image build -t my_repo/my_image:my_tag . 
```

**在指定路径或`url`的`Dockerfile`中构建一个名为`my_image`的`Docker`镜像。**


* `-t`是`tag`的缩写，是告诉`docker`用提供的标签来标记镜像，在本例中，是`my_tag`。
* 在命令末尾的句号`（.）`是告诉Docker根据当前工作目录中的`Dockerfile`构建镜像。


当你构建好镜像之后，你想要推送它到远程仓库中以便它可以共享并且在有需要的时候被拉取。那么下一个命令十分有用，尽管并非是镜像命令。

* `docker login` — 登录到Docker镜像仓库，根据提示键入你的用户名和密码
* `docker image push my_repo/my_image:my_tag` — 推送一个镜像到仓库。


你拥有了这些镜像之后，你可能想要检查他们。

###  检查镜像


* `docker image ls` — 列出你的镜像以及每个镜像的大小

* `docker image history my_image` — 显示镜像的中间镜像，包括大小及其创建方式

* `docker image inspect my_image` — 显示关于镜像的细节，包括组成镜像的层

有时候你还需要清理你的镜像。



### 清理镜像


* `docker image rm my_image` — 删除指定镜像。如果镜像被保存在镜像仓库中，那么该镜像在那依旧可用。
* `docker image rm $(docker images -a -q)` — 删除所有镜像。必须小心使用这一命令。请注意已经被推送到远程仓库的镜像依然能够保存，这是镜像仓库的一个优势。

以上就是大部分与Docker镜像相关的重要命令。





















