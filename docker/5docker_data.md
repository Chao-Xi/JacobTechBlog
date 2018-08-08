![Alt Image Text](images/headline5.jpg "Headline image")
# Docker数据管理

生产环境中使用Docker的过程中,往往需要对数据进行持久化,或者需要在多个容器之间进行数据共享;容器中管理数据主要有两种方式:

* 数据卷(Data Volumes):容器内数据直接映射到本地主机环境;
* 数据卷容器(Data Volume Containers):使用特定容器映射到本地主机环境;

## 一、数据卷

数据卷时一个可供容器使用的特殊目录,它将主机操作系统目录直接映射进容器,类似与Linux中的**monut操作**.

数据卷可以提供很多有用的特性:

* **数据卷可以在容器之间共享和重用,容器间传递数据将变得高效方便;**
* **对数据卷内数据的修改会立马生效,无论是容器内操作还是本地操作;**
* **对数据卷的更新不会影响镜像,解藕了应用和数据';**
* **卷会一直存在,直到没有容器使用,可以安全地卸载它.**

### 1、在容器内创建一个数据卷
在用docker run命令的时候,使用-v标记可以在容器内创建一个数据卷.多次使用-v标记可以创建多个数据卷.
下面创建一个 web 容器，并加载一个宿主机目录到容器的 /var/www/html/目录
在宿主机上创建/web/webapp1 目录，并创建一个 index.html 文件，内容如下：

```
[vagrant@node1 ~]$ sudo mkdir -p /web/webapp1
[vagrant@node1 ~]$ sudo vi /web/webapp1/index.html
[vagrant@node1 ~]$ sudo cat /web/webapp1/index.html
<html>
  <title>Test page</title>
  <body>
     <h1>Hello Jac<h1>
  </body>
</html>
```

查看镜像,并使用镜像创建容器:

```
[vagrant@node1 ~]$ sudo docker images
REPOSITORY              TAG                   IMAGE ID            CREATED             SIZE
jacob/python-web        testpythonwebserver   274abed832d4        8 hours ago         200 MB
127.0.0.1:5000/centos   latest                49f7960eb7e4        8 weeks ago         200 MB
docker.io/centos        centos7               49f7960eb7e4        8 weeks ago         200 MB
docker.io/centos        latest                49f7960eb7e4        8 weeks ago         200 MB
docker.io/registry      2.4.1                 8ff6a4aae657        2 years ago         172 MB
```

```
[vagrant@node1 ~]$ sudo docker run -dit -p 80:80 -p 10122:20 -v /web/webapp1/:/var/www/html/ docker.io/centos:latest
b363586f27149477a1f2d78bb7fb314d7342a0844a511b017f247958ab4a9a7a
```

```
-d              : Detached (-d)
-t              : Allocate a pseudo-tty
-i              : Keep STDIN open even if not attached
```

```
[vagrant@node1 ~]$ sudo docker ps -a
CONTAINER ID        IMAGE                     COMMAND                  CREATED             STATUS                           PORTS                                       NAMES
b363586f2714        docker.io/centos:latest   "/bin/bash"              38 seconds ago      Up 37 seconds                    0.0.0.0:80->80/tcp, 0.0.0.0:10122->20/tcp   laughing_montalcini
27ac2d67622d        registry:2.4.1            "/bin/registry ser..."   About an hour ago   Up About an hour                 0.0.0.0:5000->5000/tcp                      registry
99f3ee29179b        centos:centos7            "/bin/python -m Si..."   8 hours ago         Exited (137) About an hour ago                                               python_web
4be2470c1199        centos:centos7            "/bin/bash"              13 hours ago        Exited (137) About an hour ago                                               lucid_wing
```
上面的命令加载**主机的** `/web/webapp1` 目录到**容器的** `/var/www/html` 目录。这个功能在进行测试的时候十分方便，比如用户可以放置一些程序到本地目录中，来查看容器是否正常工作。本地目录的路径必须是绝对路径，如果目录不存在 Docker 会自动为你创建它。

`/web/webapp1` 目录的文件都将会出现在容器内。这对于在主机和容器之间共享文件是非常有帮助的，例如挂载需要编译的源代码。为了保证可移植性（并不是所有的系统的主机目录都是可以用的），挂载主机目录不需要从 Dockerfile 指定。
挂在的目录可以通过使用`docker inspect 容器ID`

```
[vagrant@node1 ~]$ sudo docker inspect b363586f2714
 
 "Mounts": [
            {
                "Type": "bind",
                "Source": "/web/webapp1",
                "Destination": "/var/www/html",
                "Mode": "",
                "RW": true,
                "Propagation": "rprivate"
            }
        ],
"NetworkSettings": {
            "Bridge": "",
            "SandboxID": "ec47f3ce92bbe4d9f9b747e26b6bdd31286243d74e2de185529d03231761eed1",
            "HairpinMode": false,
            "LinkLocalIPv6Address": "",
            "LinkLocalIPv6PrefixLen": 0,
            "Ports": {
                "20/tcp": [
                    {
                        "HostIp": "0.0.0.0",
                        "HostPort": "10122"
                    }
                ],
                "80/tcp": [
                    {
                        "HostIp": "0.0.0.0",
                        "HostPort": "80"
                    }
                ]
            },
```
或者

```
[vagrant@node1 ~]$ sudo docker inspect -f '{{ .Mounts }}' containerid
[{bind  /web/webapp1 /var/www/html   true rprivate}]
```

## 二、数据卷容器

如果需要在多个容器之间共享一些持续更新的数据,最简单的方式是使用数据卷容器;数据卷容器也是一个容器,但是他的目的是专门用来提供数据卷供其他容器挂载.

**首先,创建一个数据卷容器`dbdata`,并在其中创建一个数据卷挂载到`/dbdata`:**


```
[vagrant@node1 ~]$ sudo docker run -it -v /dbdata --name dbdata ubuntu
Unable to find image 'ubuntu:latest' locally
Trying to pull repository docker.io/library/ubuntu ...
latest: Pulling from docker.io/library/ubuntu
c64513b74145: Pull complete
01b8b12bad90: Pull complete
c5d85cf7a05f: Pull complete
b6b268720157: Pull complete
e12192999ff1: Pull complete
Digest: sha256:3f119dc0737f57f704ebecac8a6d8477b0f6ca1ca0332c7ee1395ed2c6a82be7
Status: Downloaded newer image for docker.io/ubuntu:latest
```

**查看/dbdata目录:**

```
root@b4222c651608:/# ls
bin  boot  dbdata  dev  etc  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var

```

然后,可以在其他容器中使用`--volumes-from`来挂载`dbdata`容器中的数据卷,例如创建db1和db2两个容器,并从`dbdata`容器挂载数据卷:

```
[vagrant@node1 ~]$ sudo docker run -it --volumes-from dbdata --name db1 ubuntu
root@58928eac9056:/# exit
exit
[vagrant@node1 ~]$ sudo docker run -it --volumes-from dbdata --name db2 ubuntu
root@d4894fc7df1e:/# exit
exit

[vagrant@node1 ~]$ sudo docker ps -a
CONTAINER ID        IMAGE                     COMMAND                  CREATED             STATUS                           PORTS                                       NAMES
d4894fc7df1e        ubuntu                    "/bin/bash"              19 seconds ago      Exited (0) 11 seconds ago                                                    db2
58928eac9056        ubuntu                    "/bin/bash"              31 seconds ago      Exited (0) 25 seconds ago                                                    db1
b4222c651608        ubuntu                    "/bin/bash"              4 minutes ago       Exited (0) 2 minutes ago                                                     dbdata
```

此时,容器db1和db2都挂载同一个数据卷到相同的`/dbdata`目录.三个容器任何一方在该目录下的写入,其他容器都可以看到.

在dbdata容器中创建一个`test`文件,到db1容器内查看:

```
[vagrant@node1 ~]$ sudo docker exec -it b4222c651608 /bin/bash
Error response from daemon: Container b4222c651608b95e619950b1d4024d59d6bfb31c2788be3bf8d9a94c796d0e2b is not running
[vagrant@node1 ~]$ sudo docker start b4222c651608
b4222c651608
[vagrant@node1 ~]$ sudo docker exec -it b4222c651608 /bin/bash
root@b4222c651608:/# cd dbdata
root@b4222c651608:/dbdata# touch test
root@b4222c651608:/dbdata# exit
exit

#into db1 container
[vagrant@node1 ~]$ sudo docker exec -it 58928eac9056 /bin/bash
Error response from daemon: Container 58928eac9056561328525399c31fba04f00e4b611959954aaed463aa63cc8717 is not running
[vagrant@node1 ~]$ sudo docker start 58928eac9056
58928eac9056
[vagrant@node1 ~]$ sudo docker exec -it 58928eac9056 /bin/bash
root@58928eac9056:/# cd dbdata/
root@58928eac9056:/dbdata# ls
test
```

可以多次使用--volumes-from参数来从多个容器挂载多个数据卷,还可以从其他已经挂载了容器卷的容器来挂载数据卷:

```
[vagrant@node1 ~]$ sudo docker run -dit --name db3 --volumes-from db1 training/postgres
Unable to find image 'training/postgres:latest' locally
Trying to pull repository docker.io/training/postgres ...
latest: Pulling from docker.io/training/postgres
a3ed95caeb02: Pull complete
6e71c809542e: Pull complete
2978d9af87ba: Pull complete
e1bca35b062f: Pull complete
500b6decf741: Pull complete
74b14ef2151f: Pull complete
7afd5ed3826e: Pull complete
3c69bb244f5e: Pull complete
d86f9ec5aedf: Pull complete
010fabf20157: Pull complete
Digest: sha256:a945dc6dcfbc8d009c3d972931608344b76c2870ce796da00a827bd50791907e
Status: Downloaded newer image for docker.io/training/postgres:latest
25b88f3e7e73943b4fc773da3ba0f136e9892691f8e6257d9d62c46ebe157f08

[vagrant@node1 ~]$ sudo docker ps -a
CONTAINER ID        IMAGE                     COMMAND                  CREATED             STATUS                           PORTS                                       NAMES
25b88f3e7e73        training/postgres         "su postgres -c '/..."   39 seconds ago      Up 37 seconds                    5432/tcp                                    db3

[vagrant@node1 ~]$ sudo docker exec -it 25b88f3e7e73 bin/bash
root@25b88f3e7e73:/# exit
exit
```

如果删除了挂载的容器(包括dbdata、db1和db2),数据卷并不会被自动删除.如果要删除一个数据卷,必须在删除最后一个还挂载着它的容器时显示使用docker rm -v命令来指定同时删除关联的容器.
使用数据卷可以在容器之间自由地升级和移动数据卷.

## 三、利用数据卷容器迁移数据

可以利用数据卷容器对其中的数据卷进行备份、恢复,以实现数据的迁移.

### 1、备份

利用下面的命令来备份dbdata数据卷容器内的数据卷:

```
sudo docker run --volumes-from dbdata -v $(pwd):/backup --name worker ubuntu tar cvf /backup/backup.tar /dbdata
```
首先利用`ubuntu镜像`创建一个`容器worker`.使用`--volumes-from dbdata`参数来让`worker容器`挂载`dbdata容器的数据卷(即dbdata数据卷)`;

使用`-v $(pwd):/backup`参数来挂载本地的当前目录到`worker容器的/backup目录`.
worker容器启动后,使用了`tar cvf /backup/backup.tar /dbdata`命令来将/dbdata下内容备份为容器内的/backup/backup.tar,即宿主主机当前目录下的backup.tar.

```
[vagrant@node1 ~]$ sudo docker run --volumes-from dbdata -v $(pwd):/backup --name worker ubuntu tar cvf /backup/backup.tar /dbdata
tar: Removing leading `/' from member names
/dbdata/
/dbdata/test
```
### 2、恢复
首先创建一个带有数据卷的容器dbdata2:

```
[vagrant@node1 ~]$ sudo docker run -v /dbdata --name dbdata2 ubuntu /bin/bash

```

然后创建另一个新的容器,挂载dbdata2的容器,并使用untar解压备份文件到所挂载的容器卷中:

```
[vagrant@node1 ~]$ sudo docker run --volumes-from dbdata2 -v $(pwd):/backup busybox tar xvf /backup/backup.tar
Unable to find image 'busybox:latest' locally
Trying to pull repository docker.io/library/busybox ...
latest: Pulling from docker.io/library/busybox
8c5a7da1afbc: Pull complete
Digest: sha256:cb63aa0641a885f54de20f61d152187419e8f6b159ed11a251a09d115fdff9bd
Status: Downloaded newer image for docker.io/busybox:latest
dbdata/
dbdata/test
```


