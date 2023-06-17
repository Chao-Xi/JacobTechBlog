# 如何优雅的对 Docker 容器进行健康检查

自 1.12 版本之后，Docker 引入了原生的健康检查实现。对于容器而言，最简单的健康检查是进程级的健康检查，即检验进程是否存活。

Docker Daemon 会自动监控容器中的 PID1 进程，如果 `docker run` 命令中指明了 `restart policy`，可以根据策略自动重启已结束的容器。在很多实际场景下，仅使用进程级健康检查机制还远远不够。

比如，容器进程虽然依旧运行却由于应用死锁无法继续响应用户请求，这样的问题是无法通过进程监控发现的。

容器启动之后，初始状态会为 starting (启动中)。

**Docker Engine 会等待 interval 时间，开始执行健康检查命令，并周期性执行**。 

* 如果单次检查返回值非 0 或者运行需要比指定 timeout 时间还长，则本次检查被认为失败；
* 如果健康检查连续失败超过了 retries 重试次数，状态就会变为 unhealthy (不健康)。

## 1. Dockerfile 方式

可以在 Dockerfile 中声明应用自身的健康检测配置。`HEALTHCHECK`指令声明了健康检测命令，用这个命令来判断容器主进程的服务状态是否正常，从而比较真实的反应容器实际状态。

HEALTHCHECK指令格式：

* **`HEALTHCHECK [选项] CMD <命令>`**：设置检查容器健康状况的命令
* **HEALTHCHECK NONE**：如果基础镜像有健康检查指令，使用这行可以屏蔽掉

>  注 ：在 Dockerfile 中HEALTHCHECK只可以出现一次，如果写了多个，只有最后一个生效。


使用包含HEALTHCHECK指令的 Dockerfile 构建出来的镜像，在实例化 Docker 容器的时候，就具备了健康状态检查的功能。启动容器后会自动进行健康检查。

**HEALTHCHECK 支持下列选项：**

* `--interval=<间隔>`：两次健康检查的间隔，默认为 30 秒;
* `--timeout=<间隔>`：健康检查命令运行超时时间，如果超过这个时间，本次健康检查就被视为失败，默认 30 秒;
* `--retries=<次数>`：当连续失败指定次数后，则将容器状态视为 unhealthy，默认 3 次。
* `--start-period=<间隔>`: 应用的启动的初始化时间，在启动过程中的健康检查失效不会计入，默认 0 秒;

**参数作用解释如下：**

* 运行状态检查首先会在容器启动后的 interval 秒内运行，然后在前一次检查完成后的 interval 秒内再次运行。
* 如果一次状态检查花费的时间超过 timeout 秒，则认为这次检查失败。
* 容器的运行状态检查连续失败 retries 次才会被视为不健康。
* start period 为需要时间启动的容器提供初始化时间。在此期间的探测失败将不计入最大重试次数。

但是，如果在启动期间健康检查成功，则认为容器已启动，所有连续失败的情况都将计算到最大重试次数

**在`HEALTHCHECK [选项] CMD`后面的命令，格式和`ENTRYPOINT`一样，分为 `shell `格式，和 `exec `格 式。**

命令的返回值决定了该次健康检查的成功与否：

* 0：成功;
* 1：失败;
* 2：保留值，不要使用

假设有个镜像是个最简单的 Web 服务，我们希望增加健康检查来判断其 Web 服务是否在正常工作，我们可以用 curl 来帮助判断，其 `Dockerfile` 的HEALTHCHECK可以这么

```
FROM nginx:1.23
HEALTHCHECK --interval=5s --timeout=3s  --retries=3 \
    CMD curl -fs http://localhost/ || exit 1
```

**这里设置了每 5 秒检查一次（这里为了试验所以间隔非常短，实际应该相对较长），如果健康检查命令超过 3 秒没响应，并且重试 3 次都没响应就视为失败，并且使用`curl -fs http://localhost/ || exit 1`作为健康检查命令**

使用docker build来构建这个镜像：

```
docker build -t myweb:v1 .
```

构建好后启动容器：

```
docker run -d --name web myweb:v1
```

当运行该镜像后，可以通过`docker container ls`看到最初的状态为(`health: starting`)：

```
docker container ls
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                            PORTS               NAMES
7068d793c6e4        myweb:v1            "/docker-entrypoint.…"   3 seconds ago       Up 2 seconds (health: starting)   80/tcp              web
```

在等待几秒钟后，再次`docker container ls`，就会看到健康状态变化为了(healthy)：

```
$ docker container ls
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                    PORTS               NAMES
7068d793c6e4        myweb:v1            "/docker-entrypoint.…"   18 seconds ago      Up 16 seconds (healthy)   80/tcp               web
```

如果健康检查连续失败超过了重试次数，状态就会变为(unhealthy)。

**为了帮助排障，健康检查命令的输出（包括stdout以及stderr）都会被存储于健康状态里，可以用 docker inspect来查看**。

```
$ docker inspect --format '{{json .State.Health}}' web | python -m json.tool
{
    "FailingStreak": 0,
    "Log": [
        {
            "End": "2022-08-20T14:02:38.19224648+08:00",
            "ExitCode": 0,
            "Output": "xxx",
            "Start": "2022-08-20T14:02:38.116041192+08:00"
        },
        {
            "End": "2022-08-20T14:02:43.271105619+08:00",
            "ExitCode": 0,
            "Output": "xxx",
            "Start": "2022-08-20T14:02:43.200932585+08:00"
        }
    ],
    "Status": "healthy"
}
```

##  2. docker run 方式

**另外一种方法是在 docker run 命令中，直接指明 healthcheck 相关策略**：

```
$ docker run  -d \
    --name=myweb \
    --health-cmd="curl -fs http://localhost/ || exit 1" \
    --health-interval=5s \
    --health-retries=12 \
    --health-timeout=2s \
    nginx:1.23
```

通过执行`docker run --help | grep health`命令查看相关的参数及解释如下：

* `--health-cmd string`：运行检查健康状况的命令
* `--health-interval duration`：运行间隔时间(`ms|s|m|h`)(缺省为 0s)
* `--health-retries int`：需要报告不健康的连续失败次数
* `--health-start-period duration `：容器在开始健康重试倒计时之前初始化的起始周期(ms|s|m|h)(默认 0)
* `--health-timeout duration`：允许一次检查运行的最大时间(`ms|s|m|h`)(默认为 0s)
* `--no-healthcheck`：禁用任何容器指定的`HEALTHCHECK`，会使得 Dockerfile 构建出来的`HEALTHCHECK`功能失效。

如果是以 supervisor 来管理容器的多个服务，想通过子服务的状态来判断容器的监控状态，可以使用`supervisorctl status来`做判断，比如

```
$ docker run --rm -d \
    --name=myweb \
    --health-cmd="supervisorctl status" \
    --health-interval=5s \
    --health-retries=3 \
    --health-timeout=2s \
    nginx:v1
```

按照此参数的设置，如果`supervisorctl status`检查子服务有一个不为正常的`RUNNING`状态，那么在等待大约 15 秒左右，容器的监控状态就会从(healthy)变为(unhealthy)

## 3. docker-composer 方式

```
version: '3'
services:
  web:
    image: nginx:v1
    container_name: web
    healthcheck:
      test: ["CMD", "supervisorctl", "status"]
      interval: 5s
      timeout: 2s
      retries: 3
```

执行成功后，等待数秒查询容器的状态：

```
$ docker-compose ps
Name              Command                  State                 Ports
--------------------------------------------------------------------------------
web    supervisord -c /etc/superv ...   Up (healthy)   443/tcp, 80/tcp
``` 
 
 当通过手动supervisorctl stop停掉里面的一些子服务，导致里面的子服务状态不全为RUNNING状态时，再查看容器的状态：
 
```
 healthcheck:
   disable: true
```