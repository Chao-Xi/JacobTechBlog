![Alt Image Text](images/headline3.jpg "Headline image")
# 使用Dockerfile创建镜像

## 一、基本结构

Dockerfile是一个文本格式的配置文件，用户可以使用Dockerfile来创建自定义的镜像。
一般Dockerfile分为四部分：

* 基础镜像信息、
* 维护者信息、
* 镜像操作指令
* 容器启动执行命令；

一开始必须指明所基于的镜像名称，接下来一般是说明维护者信息，后面是镜像操作指令，最后是CMD指令，用来指定运行容器时的操作命令。

## 二、详细地操作指定说明

### 1、FROM 指定所创建镜像的基础镜像

如果本地不存在镜像，则默认去`Docker Hub`下载指定镜像，格式：`FROM<image>`，或`FROM<image>:<tag>`，或`FROM<image>@<digest>`；

任何Dockerfile中的第一条指令必须为FROM指令，并且，在同一个Dockerfile中创建多个镜像，可以使用多个FROM指令（每个镜像一次）。

### 2、MAINTAINER 指定维护者信息
格式为`MAINTAINER<name>；` 如：`MAINTAINER image_creator@docker.com；`该信息会写入生成镜像的Author属性域中。

### 3、RUN 运行指定命令
格式为：`RUN<command>`或`RUN ["executable", "paraml", "param2"]；`后一个指令会被解析为**Json数组，因此必须用双引号。**

* 前者默认在shell终端运行命令，即`/bin/sh -c；`
* 后者则使用exec执行，不会启动shell环境。

指定使用其他终端类型可以通过第二种方式实现，如：`RUN ["/bin/bash", "-c", "echo hello"]`。每条RUN命令将在当前进行的基础上执行指定命令，并提交为新的镜像。当命令较长可以使用\来换行。

### 4、CMD 用来指定启动容器时默认执行的命令

支持三种格式：

* CMD ["executable","param1","param2"]使用exec执行
* CMD command param1 param2在/bin/sh中执行，提供给需要交互的应用
* CMD ["param1","param2"]提供给ENTRYPOINT的默认参数

每个Dockerfile只能有一条CMD命令，如果指定多条命令，只有最后一条会被执行。如果启动容器是手动指定了运行的命令（作为run的参数），则会覆盖CMD指定的命令。

### 5、LABEL 用来指定生成镜像的元数据标签信息

格式：`LABEL <key>=<value> <key>=<value> <key>=<value>...`

### 6、EXPOSE 生命镜像内服务所监听的端口

格式：`EXPOSE <port> [<port>...]`

### 7、ENV 指定环境变量，在镜像生成过程中会被后续RUN指令使用，在镜像启动的容器中也会存在
格式：`ENV<key><value>或ENV<key>=<value>...`

指令指定的环境变量在运行时可以被覆盖掉，如`docker run --env <key>=<value> built_image`

### 8、ADD 将复制指定的<src>路径下的内容到容器中的<dest>路径下

格式：`ADD<src> <dest>`

`<src>`可以是Dockerfile所在目录的一个相对路径（文件或目录），也可以是一个URL，还可以是一个tar文件（如果tar文件，全自动解压到<dest>路径下）。

`<dest>`可以是镜像内的绝版路径，或者相对于工作目录（WORKDIR）的相对路径。

### 9、COPY 格式：`COPY <src> <dest>`

复制本地主机的`<src>`（为Dockerfile所在目录的相对路径、文件或目录）下的内容到镜像中的`<dest>`下。目标路径不存在是，会自动创建。
路径同样支持正则格式。
**当使用本地目录为源目录是，推荐使用COPY。**

### 10、ENTRYPOINT 指定镜像的默认入口命令，该入口命令会在启动容器时作为根命令执行，所有传入值作为该命令的参数

支持两种格式：

* ENTRYPOINT ["executable", "param1", "param2"]（exec调用执行）；
* EXTRYPOINT command param1 param2（shell中执行）。

此时CMD指定值将作为根命令的参数。

**每个Dockerfile中只能有一个ENTRYPOINT，当指定多个时，只有最后一个有效；在运行时，可以被--entrypoint参数覆盖掉。**

### 11、VOLUME 创建一个数据卷挂载点

格式：`VOLUME ["/data"]`

可以从本地主机或其他容器挂载数据卷，一般用来存放数据库和需要保存的数据等。

### 12、USER 指定运行容器时的用户名或UID，后续的RUN等指令也会使用指定的用户身份

格式：`USER daemon`

当服务不需要管理员权限是，可以通过该命令指定运行用户，并且可以在之前创建所需要的用户；

**要临时获取管理员权限可以使用gosu或sudo。**

### 13、WORKDIR 为后续的RUN、CMD和ENTRYPOINT指令配置工作目录

格式：`WORKDIR /path/to/workdir`

可以使用多个WORKDIR指令，后续命令如果参数是相对路径，则会基于之前命令指定的路径。

### 14、ARG 指定一些镜像内使用的参数（例如版本号信息等），这些参数在执行docker bulid命令时才以`--build-arg<varname>=<value>`格式传入

格式：`ARG<name>[=<default value>]`；

则可以用`docker build --build-arg<name>=<value>`来指定参数值。

### 15、ONBUILD 配置当所创建的镜像作为其他镜像的基础镜像时，所执行的创建操作指令

格式：`ONBUILD [INSTRUCTION]；`

如果基于image-A创建新的镜像时，新的Dockerfile中使用FROM image-A指定基础镜像，会自动执行ONBUILD指令的内容。

### 16、STOPSIGNAL 指定所创建镜像启动的容器接收退出的信号值

如：`STOPSIGNAL signa1`

### 17、HEALTHCHECK 配置所启动容器如何进行健康检查（如何判断健康与否），自Docker 1.12开始支持

**1. 格式有两种：**

* HEALTHCHECK [OPTIONS] CMD command：根据所执行命令返回值是否为0来判断；
* HEALTHCHECK NONE：禁止基础镜像中的健康检查；

**2. OPTION支持：**

* --interval=DURATION（默认为：30s）：过多久检查一次；
* --timeout=DURATION（默认为：30s）：每次检查等待结果的超时；
* --retries=N（默认为：3）：如果失败了，重试几次才最终确定失败。

### **18、SHELL 指定其他命令使用shell时的默认shell类型**

**SHELL ["executable", "parameters"]**

默认值为["/bin/sh", "-c"]。

对于Windows系统，建议在Dockerfile开头添加# excape='来指定转义信息。


