![Alt Image Text](images/headline6.jpg "Headline image")
# Docker容器操作

##  一、启动创建容器

容器是Docker的另一个核心概念，是镜像的一个运行实例；不同的是，镜像是静态的只读文件，而容器带有运行是需要的可写文件层。如果认为虚拟机是模拟运行的一整套操作系统（包括内核、应用运行环境和其他系统环境和跑在上面的应用），**那么Docker容器就是独立运行的一个或一组应用，以及必须的运行环境。(不包含内核)**

### 1、创建容器
新建容器，使用docker create命令创建容器：

```
[vagrant@node1 ~]$ sudo docker create -it ubuntu:latest
eaf3670d9d253c090ce274be84a1a5386b9924da731f3e4991d30f1532d5e76e
[vagrant@node1 ~]$ sudo docker ps -a
CONTAINER ID        IMAGE                     COMMAND                  CREATED             STATUS                     PORTS                                       NAMES
eaf3670d9d25        ubuntu:latest             "/bin/bash"              3 seconds ago       Created                                                                affectionate_curie
```

使用docker create命令新建的容器是处于停止状态，可以使用docker start命令来启动它。

关于docker create的命令选项比较复杂，可以使用--help查看：

```
[vagrant@node1 ~]$ docker create --help

Usage:	docker create [OPTIONS] IMAGE [COMMAND] [ARG...]

Create a new container

Options:
      --add-host list                         Add a custom host-to-IP mapping (host:ip) (default [])
  -a, --attach list                           Attach to STDIN, STDOUT or STDERR (default [])
      --blkio-weight uint16                   Block IO (relative weight), between 10 and 1000, or 0 to disable (default 0)
      --blkio-weight-device weighted-device   Block IO weight (relative device weight) (default [])
      --cap-add list                          Add Linux capabilities (default [])
      --cap-drop list                         Drop Linux capabilities (default [])
      --cgroup-parent string                  Optional parent cgroup for the container
      --cidfile string                        Write the container ID to the file
      --cpu-count int                         CPU count (Windows only)
      --cpu-percent int                       CPU percent (Windows only)
```

### 2、启动容器

使用docker start命令来启动一个已经创建的容器，例如启动刚创建的ubuntu容器：

```
[vagrant@node1 ~]$ sudo docker ps -a
CONTAINER ID        IMAGE                     COMMAND                  CREATED             STATUS                     PORTS                                       NAMES
eaf3670d9d25        ubuntu:latest             "/bin/bash"              3 minutes ago       Created                                                                affectionate_curie
25b88f3e7e73        training/postgres         "su postgres -c '/..."   3 hours ago         Up 3 hours                 5432/tcp                                    db3
58928eac9056        ubuntu                    "/bin/bash"              4 hours ago         Up 4 hours                                                             db1
b4222c651608        ubuntu                    "/bin/bash"              4 hours ago         Up 4 hours                                                             dbdata
b363586f2714        docker.io/centos:latest   "/bin/bash"              4 hours ago         Up 4 hours                 0.0.0.0:80->80/tcp, 0.0.0.0:10122->20/tcp   laughing_montalcini
27ac2d67622d        registry:2.4.1            "/bin/registry ser..."   6 hours ago         Up 5 hours                 0.0.0.0:5000->5000/tcp                      registry
99f3ee29179b        centos:centos7            "/bin/python -m Si..."   13 hours ago        Exited (137) 5 hours ago                                               python_web
4be2470c1199        centos:centos7            "/bin/bash"              17 hours ago        Exited (137) 5 hours ago                                               lucid_wing
[vagrant@node1 ~]$ sudo docker start eaf3670d9d25
eaf3670d9d25
[vagrant@node1 ~]$ sudo docker ps -a
CONTAINER ID        IMAGE                     COMMAND                  CREATED             STATUS                     PORTS                                       NAMES
eaf3670d9d25        ubuntu:latest             "/bin/bash"              3 minutes ago       Up 3 seconds                                                           affectionate_curie
25b88f3e7e73        training/postgres         "su postgres -c '/..."   3 hours ago         Up 3 hours                 5432/tcp                                    db3
58928eac9056        ubuntu                    "/bin/bash"              4 hours ago         Up 4 hours                                                             db1
b4222c651608        ubuntu                    "/bin/bash"              4 hours ago         Up 4 hours                                                             dbdata
b363586f2714        docker.io/centos:latest   "/bin/bash"              4 hours ago         Up 4 hours                 0.0.0.0:80->80/tcp, 0.0.0.0:10122->20/tcp   laughing_montalcini
27ac2d67622d        registry:2.4.1            "/bin/registry ser..."   6 hours ago         Up 5 hours                 0.0.0.0:5000->5000/tcp

```

### 3、新建并启动容器

除了创建容器后通过start命令来启动，也可以直接新建并启动容器，命令主要为`docker run`，相当于先执行`docker create`命令，再执行`docker start`命令；利用`docker run`来创建并启动容器时，Docker在后台运行的标准操作包括

* 检查本地的镜像，不存在就从公有仓库下载；
* 利用镜像创建一个容器，并启动该容器；
* 分配一个文件系统给容器，并在只读的镜像层外面挂载一层可读写层；
* 从宿主主机配置的端口中桥接一个虚拟接口到容器中；
* 从网桥的地址池配置一个IP地址给容器；
* 执行用户指定的应用程序；
* 执行完毕后容器被自动终止。

启动一个bash终端，允许用户进行交互：

```
sudo docker run -it ubuntu:16.04 /bin/bash
```

* -i：让容器的标准输入保持打开
* -t：让Docker分配一个伪终端并绑定到容器的标准输入上

更多选项可以通过`man docker-run`命令查看

在交互模式下，用户可以通过所创建的终端来输入命令：

```
root@d583abb93a39:/# pwd
/
root@d583abb93a39:/# ls -a
.  ..  .dockerenv  bin  boot  dev  etc  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
root@d583abb93a39:/# ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.3  18224  1964 ?        Ss   21:54   0:00 /bin/bash
root        11  0.0  0.2  34412  1432 ?        R+   22:11   0:00 ps aux
```
在容器中使用ps可以看出只运行了bash应用，并没有运行其他无关的进程
可以使用`Ctrl+d`或输入`exit`命令退出容器：

```
root@d583abb93a39:/# exit
exit
```

对于所创建的bash容器，当使用exit命令退出之后，容器就自动处于退出（exited）状态，对Docker容器来说，当运行的应用退出之后，容器也就没有继续运行的必要了。
有时，执行`docker run`会出错，此时可以根据代码排查错误，常见错误代码：

* 125：Docker daemon执行出错，例如指定了不支持的Docker命令参数；
* 126：所指定命令无法执行，例如权限出错；
* 127：容器内命令无法找到

命令执行后出错，会默认返回错误码。

### 4、守护态运行

让Docker容器在后台以守护态`（Daemonized）`形式运行，可以通过添加`-d`参数实现，执行后，容器会返回一个唯一的`ID（默认保留前12位）`，可以通过`docker ps`命令查看容器信息：

```
[vagrant@node1 ~]$ sudo docker run  -d ubuntu /bin/bash -c "while true; do echo hello world; sleep 1; done"
710c6b32427b9858a7d0afe693fea652b57aed729088b3771864a56ec727ad37
[vagrant@node1 ~]$ sudo docker ps -a
CONTAINER ID        IMAGE                     COMMAND                  CREATED             STATUS                      PORTS                                       NAMES
710c6b32427b        ubuntu                    "/bin/bash -c 'whi..."   2 seconds ago       Up 2 seconds                                                            hardcore_raman
d583abb93a39        ubuntu:16.04              "/bin/bash"              28 minutes ago      Exited (0) 8 minutes ago
```

此时，要获取容器的输出信息，可以使用docker logs命令

```
[vagrant@node1 ~]$ sudo docker logs 710c6b32427b
hello world
hello world
hello world
hello world
hello world
hello world
hello world
hello world
hello world
hello world
hello world
hello world
hello world
hello world
```

## 二、终止容器
1、可以使用`docker stop`来终止容器，格式为：`docker stop [ -t | --time [=10] ] [CONTAINER...]`。
首先向容器发送SIGTERM信号，等待一段时间超时时间（默认为10秒）后，再发送SIGKILL信号来终止容器：

```
[vagrant@node1 ~]$ sudo docker stop  710c6b32427b
710c6b32427b
[vagrant@node1 ~]$ sudo docker ps -a
CONTAINER ID        IMAGE                     COMMAND                  CREATED             STATUS                            PORTS                                       NAMES
710c6b32427b        ubuntu                    "/bin/bash -c 'whi..."   5 minutes ago       Exited (137) About a minute ago
```
当Docker容器中指定的应用终结时，容器也会自动终止，例如上一节只启动了一个终端的容器，用户通过exit命令或者Ctrl+d来退出终端时，所创建的容器立刻终止，处于stopped状态。

可以使用`docker ps -qa`命令看到所有容器的ID：

```
[vagrant@node1 ~]$ sudo docker ps -qa
710c6b32427b
d583abb93a39
eaf3670d9d25
25b88f3e7e73
58928eac9056
b4222c651608
b363586f2714
27ac2d67622d
99f3ee29179b
4be2470c1199
```
2、处于终止状态的容器，可以通过`docker start`命令来重新启动：

```
[vagrant@node1 ~]$ sudo docker start d583abb93a39
d583abb93a39
[vagrant@node1 ~]$ sudo docker ps -a
CONTAINER ID        IMAGE                     COMMAND                  CREATED             STATUS                       PORTS                                       NAMES
710c6b32427b        ubuntu                    "/bin/bash -c 'whi..."   12 minutes ago      Exited (137) 8 minutes ago                                               hardcore_raman
d583abb93a39        ubuntu:16.04              "/bin/bash"              40 minutes ago      Up 3 seconds
```
3、docker restart命令会将一个运行状态的容器先终止，然后再重新启动：

```
[vagrant@node1 ~]$ sudo docker restart d583abb93a39
d583abb93a39
[vagrant@node1 ~]$ sudo docker ps -a
CONTAINER ID        IMAGE                     COMMAND                  CREATED             STATUS                       PORTS                                       NAMES
710c6b32427b        ubuntu                    "/bin/bash -c 'whi..."   13 minutes ago      Exited (137) 9 minutes ago                                               hardcore_raman
d583abb93a39        ubuntu:16.04              "/bin/bash"              41 minutes ago      Up 4 seconds
```

## 三、进入容器

如果需要进入容器进行操作，可以使用官网的`attach`或`exec`命令，以及`第三方的nsenter工具`等，可以任选一种进行操作。

### 1、attach命令

attach是Docker自带的命令，格式为：

```
docker attach [--detach-keys [= [ ] ] ] [ --no-stdin] [--sig-proxy[=true] ] CONTAINER
```

支持三个主要选项：

* `--detach-keys [=[ ] ]`：指定退出attach模式的快捷健序列，默认是CTRL-PCTRL-q；
* `--no-stdin=true | false`：是否关闭标准输入，默认时保持打开；
* `--sig-proxy=true | false`：是否代理收到的系统信号给应用进程，默认为true

```
[vagrant@node1 ~]$ sudo docker attach d583abb93a39
You cannot attach to a stopped container, start it first
[vagrant@node1 ~]$ sudo docker start d583abb93a39
d583abb93a39
[vagrant@node1 ~]$ sudo docker attach d583abb93a39
```

但是使用`attach`命令有时候并不方便。当多个窗口同时用`attach`命令连到同一个容器的时候，所有窗口都会同步显示。当某个窗口因命令阻塞时，其他窗口也无法执行操作了。

### 2、exec命令


Docker从1.3.0版本起提供了一个更加方便的exec命令，可以在容器内直接执行任意命令。

格式为：

```
docker exec [-d | --detach ] [--detach-keys [=[ ] ] ] [-i | --interactive] [--privileged] [-t | --tty] [-u | --user [=USER] ] CONTAINER COMMAND [ARG...]。
```

比较重要的参数有：

* `-i，--interactive=true | false`：打开标准输入接受用户输入命令，默认为false；
* `--privileged=true | false`：是否给执行命令以高权限，默认为false；
* `-t，--tty=true | false`；分配伪终端，默认为false；
* `-u，--user=""`：执行命令的用户名或ID。

进入刚创建的容器中，并启动一个bash：

```
[vagrant@node1 ~]$ sudo docker start d583abb93a39
d583abb93a39
[vagrant@node1 ~]$ sudo docker ps -a
CONTAINER ID        IMAGE                     COMMAND                  CREATED             STATUS                         PORTS                                       NAMES
710c6b32427b        ubuntu                    "/bin/bash -c 'whi..."   56 minutes ago      Exited (137) 52 minutes ago                                                hardcore_raman
d583abb93a39        ubuntu:16.04              "/bin/bash"              About an hour ago   Up 2 seconds                                                               boring_ride
eaf3670d9d25        ubuntu:latest             "/bin/bash"              About an hour ago   Exited (0) About an hour ago                                               affectionate_curie
25b88f3e7e73        training/postgres         "su postgres -c '/..."   5 hours ago         Up 
[vagrant@node1 ~]$ sudo docker exec -it d583abb93a39 /bin/bash
root@d583abb93a39:/#
```
可以看到，一个bash终端打开了，在不影响容器内其他应用的前提下，可以很容易与容器进行交互。

### 3、nsenter工具

在util-linux软件包版本2.23+中包含nsenter工具。如果系统中的util-linux包没有该命令，可以按照下面的方法从源码安装：

```
[vagrant@node1 ~]$ sudo yum install ncurses-devel.x86_64
Loaded plugins: fastestmirror
base
Loading mirror speeds from cached hostfile
 * base: mirrors.cat.net
 * epel: ftp.riken.jp
 * extras: mirrors.cat.net
 * updates: mirrors.cat.net
Resolving Dependencies
--> Running transaction check
---> Package ncurses-devel.x86_64 0:5.9-14.20130511.el7_4 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

====================================================================================================================================================
 Package                              Arch                          Version                                       Repository                   Size
====================================================================================================================================================
Installing:
 ncurses-devel                        x86_64                        5.9-14.20130511.el7_4                         base                        712 k

Transaction Summary
====================================================================================================================================================
Install  1 Package

Total download size: 712 k
Installed size: 2.1 M
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Installing : ncurses-devel-5.9-14.20130511.el7_4.x86_64                                                                                       1/1
  Verifying  : ncurses-devel-5.9-14.20130511.el7_4.x86_64                                                                                       1/1

Installed:
  ncurses-devel.x86_64 0:5.9-14.20130511.el7_4

Complete!
```

nsenter可以访另一个进程的名字空间。`nsenter`要正常工作需要有root权限，庆幸CentOS7使用的是util-linux-2.23,所以就直接使用系统提供的util-linux包了。

```
[vagrant@node1 ~]$ sudo rpm -q util-linux
util-linux-2.23.2-43.el7.x86_64
```

为了连接容器，还需要找到容器的第一个进程的PID，可以通过下面的命令获取：

```
PID=$(docker inspect --format "{{.State.Pid}}" <container>)
```
通过这个ID就可以连接容器：

```
nsenter --target $PID --mount --uts --ipc --net --pid
```

```
[vagrant@node1 ~]$ PID=$(sudo docker inspect --format "{{.State.Pid}}" d583abb93a39)
[vagrant@node1 ~]$ echo $PID
5740
[vagrant@node1 ~]$ nsenter --target $PID --mount --uts --ipc --net --pid
nsenter: cannot open /proc/5740/ns/ipc: Permission denied
[vagrant@node1 ~]$ sudo nsenter --target $PID --mount --uts --ipc --net --pid
mesg: ttyname failed: No such file or directory
root@d583abb93a39:/#
```
可进一步在容器中操作：

```
root@d583abb93a39:/# w
 00:02:54 up 20:52,  0 users,  load average: 0.00, 0.01, 0.05
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
root@d583abb93a39:/#
```
使用docker rm命令来删除处于终止或退出状态的容器，命令格式为：

```
docker rm [-f | --force] [-l | --link] [-v | --volumes] CONTAINER [CONTAINER...]。
```

主要支持选项：

* `-f，--force=false`：是否强行终止并删除一个运行中的容器；
* `-l，--link=false`：删除容器的连接，但保留容器；
* `-v，--volumes=false`：删除容器挂载的数据卷。

查看处于终止状态的容器，并删除：

`docker rm`不能删除正在运行的容器，要想删除必须添加`-f参数`：

```
[vagrant@node1 ~]$ sudo docker rm -f eaf3670d9d25
eaf3670d9d25
[vagrant@node1 ~]$ sudo docker ps -a
CONTAINER ID        IMAGE                     COMMAND                  CREATED             STATUS                           PORTS                                       NAMES
710c6b32427b        ubuntu                    "/bin/bash -c 'whi..."   About an hour ago   Exited (137) About an hour ago                                               hardcore_raman
d583abb93a39        ubuntu:16.04              "/bin/bash"              2 hours ago         Up 53 minutes                                                                boring_ride
```
## 五、导入和导出容器
某些时候，需要将`容器`从`一个系统迁移到另外一个系统`，此时可以使用Docker的导入和导出功能；这是Docker自身提供的一个重要特性。

### 1、导出容器

导出容器指一个已经创建的容器到一个文件，不管此时这个容器是否处于运行状态，可以使用`docker export`命令，

格式：`docker export [-o | --output [=""]] CONTAINER`；

可以通过`-o`选项指定导出的`tar文件名`。也可以直接通过重定向来实现。

首先查看容器：

```
[vagrant@node1 ~]$ sudo docker ps -a
CONTAINER ID        IMAGE                     COMMAND                  CREATED             STATUS                     PORTS                                       NAMES
710c6b32427b        ubuntu                    "/bin/bash -c 'whi..."   2 hours ago         Exited (137) 2 hours ago                                               hardcore_raman
d583abb93a39        ubuntu:16.04              "/bin/bash"              2 hours ago         Up About an hour                                                       boring_ride
25b88f3e7e73        training/postgres         "su postgres -c '/..."   6 hours ago         Up 6 hours                 5432/tcp                                    db3
58928eac9056        ubuntu                    "/bin/bash"              6 hours ago         Up 6 hours                                                             db1
b4222c651608        ubuntu                    "/bin/bash"              7 hours ago         Up 6 hours                                                             dbdata
b363586f2714        docker.io/centos:latest   "/bin/bash"              7 hours ago         Up 7 hours                 0.0.0.0:80->80/tcp, 0.0.0.0:10122->20/tcp   laughing_montalcini
27ac2d67622d        registry:2.4.1            "/bin/registry ser..."   8 hours ago         Up 8 hours                 0.0.0.0:5000->5000/tcp                      registry
99f3ee29179b        centos:centos7            "/bin/python -m Si..."   15 hours ago        Exited (137) 8 hours ago                                               python_web
4be2470c1199        centos:centos7            "/bin/bash"              20 hours ago        Exited (137) 8 hours ago                                               lucid_wing
```

分别导出`d583abb93a39`和`710c6b32427b`容器到`Up.tar`和`exited.tar`文件

```
[vagrant@node1 ~]$ sudo docker export -o Up.tar d583abb93a39
[vagrant@node1 ~]$ sudo docker 710c6b32427b >exited.tar

[vagrant@node1 ~]$ sudo docker export 710c6b32427b >exited.tar
[vagrant@node1 ~]$ ls -l
total 158340
-rw-r--r-- 1 root    root       10240 Aug  2 20:12 backup.tar
-rw-rw-r-- 1 vagrant vagrant 72261120 Aug  3 00:34 exited.tar
-rw------- 1 root    root    89864192 Aug  3 00:32 Up.tar
```
之后，可以将导出的tar文件传输到其他机器上，然后再通过导入命令导入到系统中，从而实现容器的迁移。


### 2、导出容器

**导出的文件可以使用`docker import`命令导入变成镜像**，该命令格式为：

```
docker import [-c | --change [=[ ] ] ] [-m | --message [=MESSAGE] ] file | URL | - [REPOSITORY [:TAG] ]

```
可以通过`-c，--change=[ ]`选项在导入的同事执行对容器进行修改的`Dockerfile`指令

将导出的`Up.tar`文件导入到系统中：

```
[vagrant@node1 ~]$ cat exited.tar | sudo docker import - exited.tar
sha256:8eb9635c4f15e2be8a7148802fbd423183375fbbd81267b70066bd6e45209813
[vagrant@node1 ~]$ sudo docker images
REPOSITORY                    TAG                   IMAGE ID            CREATED             SIZE
exited.tar                    latest                8eb9635c4f15        9 seconds ago       69.8 MB
jacob/python-web              testpythonwebserver   274abed832d4        16 hours ago        200 MB
docker.io/busybox             latest                e1ddd7948a1c        2 days ago          1.16 MB
docker.io/ubuntu              16.04                 7aa3602ab41e        7 days ago          115 MB
```
容器是直接提供应用服务的组件，也是Docker实现快速启停和高效服务性能的基础。