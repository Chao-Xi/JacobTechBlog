![Alt Image Text](images/headline17.jpg "Headline image")
# Docker 的多阶段构建

`Docker`的口号是 **Build,Ship,and Run Any App,Anywhere**，在我们使用 `Docker` 的大部分时候，的确能感觉到其优越性，但是往往在我们 `Build` 一个应用的时候，是将我们的源代码也构建进去的，这对于类似于 `golang` 这样的编译型语言肯定是不行的，因为实际运行的时候我只需要把最终构建的二进制包给你就行，把源码也一起打包在镜像中，需要承担很多风险，即使是脚本语言，在构建的时候也可能需要使用到一些上线的工具，**这样无疑也增大了我们的镜像体积**。

## 示例

比如我们现在有一个最简单的 `golang` 服务，需要构建一个最小的`Docker` 镜像，源码如下：

```
package main
import (
    "github.com/gin-gonic/gin"
    "net/http"
)
func main() {
    router := gin.Default()
    router.GET("/ping", func(c *gin.Context) {
        c.String(http.StatusOK, "PONG")
    })
    router.Run(":8080")
}
```

## 解决方案

我们最终的目的都是将最终的可执行文件放到一个最小的镜像(比如`alpine`)中去执行，怎样得到最终的编译好的文件呢？基于 `Docker` 的指导思想，我们需要在一个标准的容器中编译，比如在一个 `Ubuntu` 镜像中先安装编译的环境，然后编译，最后也在该容器中执行即可。

**定义编译阶段**的 `Dockerfile`：(保存为`Dockerfile.build`)

```
FROM golang
WORKDIR /go/src/app
ADD . /go/src/app
RUN go get -u -v github.com/kardianos/govendor
RUN govendor sync
RUN GOOS=linux GOARCH=386 go build -v -o /go/src/app/app-server
```

**定义`alpine`镜像**：(保存为`Dockerfile.old`)

```
FROM alpine:latest
RUN apk add -U tzdata
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime
WORKDIR /root/
COPY app-server .
CMD ["./app-server"]
```

根据我们的执行步骤，我们还可以简单定义成一个脚本：(保存为`build.sh`)

```
#!/bin/sh
echo Building cnych/docker-multi-stage-demo:build

docker build -t cnych/docker-multi-stage-demo:build . -f Dockerfile.build

docker create --name extract cnych/docker-multi-stage-demo:build
docker cp extract:/go/src/app/app-server ./app-server
docker rm -f extract

echo Building cnych/docker-multi-stage-demo:old

docker build --no-cache -t cnych/docker-multi-stage-demo:old . -f Dockerfile.old
rm ./app-server
```


* build image using -f  "special the name of Dockerfile"
* create --name  "Assign a name to the container"
* **"docker cp"** copy files/folders between a container and the local filesystem
* "extract:/go/src/app/app-server ./app-server"  "**CONTAINER:SRC_PATH DEST_PATH|-**"
* **"docker cp [OPTIONS] SRC_PATH|- CONTAINER:DEST_PATH"**
* "docker rm -f extract container_id" Force the removal of a running container
* "docker build --no-cache -t cnych/docker-multi-stage-demo:old . -f Dockerfile.old"
* build new image with the "./app-server" inside the container run it and delete
* "--no-cache" Do not use cache when building the image

当我们执行完上面的构建脚本后，就实现了我们的目标。

## 多阶段构建

有没有一种更加简单的方式来实现上面的镜像构建过程呢？Docker 17.05版本以后，官方就提供了一个新的特性：**`Multi-stage builds（多阶段构建）`**。 使用多阶段构建，你可以在一个 `Dockerfile` 中使用多个 `FROM` 语句。

**每个 FROM 指令都可以使用不同的基础镜像，并表示开始一个新的构建阶段。你可以很方便的将一个阶段的文件复制到另外一个阶段，在最终的镜像中保留下你需要的内容即可。**


我们可以调整前面一节的 Dockerfile 来使用多阶段构建：(保存为Dockerfile)

```
FROM golang as build-env
ADD . /go/src/app
WORKDIR /go/src/app
RUN go get -u -v github.com/kardianos/govendor
RUN govendor sync
RUN GOOS=linux GOARCH=386 go build -v -o /go/src/app/app-server

FROM alpine
RUN apk add -U tzdata
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime
COPY --from=build-env /go/src/app/app-server /usr/local/bin/app-server
EXPOSE 8080
CMD [ "app-server" ]
```

* FROM golang AS build-env. 第一阶段命名为build-env
* 第二阶段COPY --from=build-env 
* COPY /go/src/app/app-server /usr/local/bin/app-server

现在我们只需要一个`Dockerfile`文件即可，也不需要拆分构建脚本了，只需要执行 build 命令即可

```
docker build -t cnych/docker-multi-stage-demo:latest .
```

默认情况下，构建阶段是没有命令的，我们可以通过它们的索引来引用它们，***第一个 FROM 指令从`0`开始***，我们也可***以用AS指令为阶段命令，比如我们这里的将第一阶段命名为build-env***，然后在其他阶段需要引用的时候使用--from=build-env参数即可。

最后我们简单的运行下该容器测试：

```
docker run --rm -p 8080:8080 cnych/docker-multi-stage-demo:latest
```

* Clean up (--rm)
* Automatically clean up the container and remove the file system when the container exits, you can add the --rm flag

```
--rm=false: Automatically remove the container when it exits
```

运行成功后，我们可以在浏览器中打开http://127.0.0.1:8080/ping地址，可以看到PONG返回。

现在我们就把两个镜像的文件最终合并到一个镜像里面了。



