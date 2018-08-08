![Alt Image Text](images/headline7.jpg "Headline image")
# Docker端口映射与容器管理

在实际的生产环境中,经常需要**多个服务组件容器共同协作的情况**,往往需要**多个容器之间能够互相访问到对方的服务**;除了通过网络访问外,Docker还提供两个很方便的功能来满足服务访问的基本需求:

* 一个是允许映射容器内应用的服务端口到本地宿主主机;
* 另一个是互联网机制实现多个容器间通过容器名来快速访问。

## 一、端口映射实现访问容器

### 1、从外部访问容器应用
在启动容器的时候,如果不指定对应的参数,在容器外都是无法通过网络来访问容器内的网络应用和服务的,当容器中运行一些网络应用,要让外部访问这些应用时,可以通过`-P`或`-p`参数来指定端口映射.当使用`-P`(大写的)标记时,Docker会随机映射一个**49000~49900**的端口到内部容器开放的网络端口:

```
[vagrant@node1 ~]$ sudo docker run -d -p training/webapp python app.py
/usr/bin/docker-current: Invalid containerPort: training.
See '/usr/bin/docker-current run --help'.
[vagrant@node1 ~]$ sudo docker run -d -P training/webapp python app.py
Unable to find image 'training/webapp:latest' locally
Trying to pull repository docker.io/training/webapp ...
latest: Pulling from docker.io/training/webapp
e190868d63f8: Pull complete
909cd34c6fd7: Pull complete
0b9bfabab7c1: Pull complete
a3ed95caeb02: Pull complete
10bbbc0fc0ff: Pull complete
fca59b508e9f: Pull complete
e7ae2541b15b: Pull complete
9dd97ef58ce9: Pull complete
a4c1b0cb7af7: Pull complete
Digest: sha256:06e9c1983bd6d5db5fba376ccd63bfa529e8d02f23d5079b8f74a616308fb11d
Status: Downloaded newer image for docker.io/training/webapp:latest
a491b4a7a7373a66d68345d57bbe6471bca3c4d5c13bdd4e6fbe7643b88d3d2c
[vagrant@node1 ~]$ docker ps -l
Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.26/containers/json?limit=1: dial unix /var/run/docker.sock: connect: permission denied
[vagrant@node1 ~]$ sudo docker ps -l
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS                     NAMES
a491b4a7a737        training/webapp     "python app.py"     58 seconds ago      Up 57 seconds       0.0.0.0:32768->5000/tcp   romantic_northcutt
[vagrant@node1 ~]$ sudo docker ps -a
CONTAINER ID        IMAGE                     COMMAND                  CREATED              STATUS                      PORTS                                       NAMES
a491b4a7a737        training/webapp           "python app.py"          About a minute ago   Up About a minute           0.0.0.0:32768->5000/tcp                     romantic_northcutt****
```
然后是使用**`docker ps -l`**即可查看到如上图本主机的**32768**被映射到了容器的5000端口。访问宿主机的**32768**端口即可访问容器内web应用提供的界面。
同样，可以使用**`docker logs`**命令查看应用的信息：

```
sudo docker logs -f container_name
```
```
[vagrant@node1 ~]$ sudo docker logs -f romantic_northcutt
 * Running on http://0.0.0.0:5000/ (Press CTRL+C to quit)
^C
```

`-p`（小写的）可以指定要映射的端口，并且，在一个指定端口上只可以绑定一个容器，支持的格式有：

```
IP:HostPort:ContainerPort | IP: :ContainerPort | HostPort:ContainerPort。
```

### 2、映射所有接口地址

使用**`HostPort:ContainerPort`**格式将本地的5000端口映射到容器的`5000`端口，可以执行：

```
[vagrant@node1 ~]$ sudo docker run -d -p 5000:5000 training/webapp python app.py
f783165636184c5bf6672287fcba00474cc5baa90538fd72eab68e364b0c902e
/usr/bin/docker-current: Error response from daemon: driver failed programming external connectivity on endpoint hopeful_visvesvaraya (7b5e74f44c04e7af7757465f6d03dd66e390cdc7682ac25d58cd9fb3ff0f1974): Bind for 0.0.0.0:5000 failed: port is already allocated.
```

5000端口已经被占用，改为`5001	`,将本地的`5001`端口映射到容器的`50001`端口，可以执行：

```
[vagrant@node1 ~]$ sudo docker run -d -p 5001:5001 training/webapp python app.py
d55e0f47b54d6e658d8b7c3d60186468290c0bbca773a73a656b1198b1df2b27
[vagrant@node1 ~]$ sudo docker ps -a
CONTAINER ID        IMAGE                     COMMAND                  CREATED             STATUS                      PORTS                                       NAMES
d55e0f47b54d        training/webapp           "python app.py"          27 minutes ago      Up 27 minutes               5000/tcp, 0.0.0.0:5001->5001/tcp
```

此时默认绑定本地所有接口上的所有地址，多次使用-p标记可以绑定多个端口

```
[vagrant@node1 ~]$ sudo docker run -d -p 5001:5001 -p 3000:80 training/webapp python app.py
1e65858d092760625aaaa5a27b0a744517188fed11a1914267f96b9402d7cb38
[vagrant@node1 ~]$ sudo docker ps -a
CONTAINER ID        IMAGE                     COMMAND                  CREATED             STATUS                      PORTS                                                    NAMES
1e65858d0927        training/webapp           "python app.py"          3 seconds ago       Up 2 seconds                5000/tcp, 0.0.0.0:5001->5001/tcp, 0.0.0.0:3000->80/tcp   vibrant_colden
```
### 3、映射到指定地址的指定端口

可以使用**`IP:HostPort:ContainerPort`**格式指定映射使用一个特定地址，比如**`localhost地址127.0.0.1`**:

```
[vagrant@node1 ~]$ sudo docker run -d -p 127.0.0.1:5001:5001 training/webapp python app.py
5ca88d7e7ff5264180f1690341e9076154a761ccddde911b5411e09f6f23343e
[vagrant@node1 ~]$ sudo docker ps -a
CONTAINER ID        IMAGE                     COMMAND                  CREATED             STATUS                      PORTS                                       NAMES
5ca88d7e7ff5        training/webapp           "python app.py"          3 seconds ago       Up 2 seconds                5000/tcp, 127.0.0.1:5001->5001/tcp          focused_varahamihira
```

### 4、映射到指定地址的任意端口

使用**`IP::ContainerPort`**绑定localhost的任意端口到容器的5000端口，本地主机会自动分配一个端口：

```
[vagrant@node1 ~]$ sudo docker run -d -p 127.0.0.1::5000 training/webapp python app.py
26f1402a04e7ff505e45e629a8cb3328f2cd2fa7d56a0b4df2a883bb73962d5e
[vagrant@node1 ~]$ sudo docker ps -a
CONTAINER ID        IMAGE                     COMMAND                  CREATED             STATUS                      PORTS                                       NAMES
26f1402a04e7        training/webapp           "python app.py"          6 seconds ago       Up 5 seconds                127.0.0.1:32768->5000/tcp                   thirsty_bhabha
```
还可以使用udp标记来指定**udp端口**：

```
[vagrant@node1 ~]$ sudo docker run -d -p 127.0.0.1:5001:5001/udp training/webapp python app.py
1b26fb3d486af57d764b0280185a54260b43cccf617b510dd5f095f1b6075b31
[vagrant@node1 ~]$ sudo docker ps -a
CONTAINER ID        IMAGE                     COMMAND                  CREATED             STATUS                      PORTS                                       NAMES
1b26fb3d486a        training/webapp           "python app.py"          4 seconds ago       Up 4 seconds                5000/tcp, 127.0.0.1:5001->5001/udp          flamboyant_perlman
```

### 5、查看映射端口配置

使用**`docker port`**命令来查看当前映射的端口配置，也可以查看到绑定的地址:

```
[vagrant@node1 ~]$ sudo docker port flamboyant_perlman
5001/udp -> 127.0.0.1:5001
```

## 二、互联机制实现便捷互访

**容器的互联是一种让多个容器中应用进行快速交互的方式**。它会在源和接收容器之间创建连接关系，**接收容器可以通过`容器名`快速访问到容器源容器，而不用指定具体的IP地址**。

### 1、自定义容器命名

连接系统依据容器的名称来执行，虽然创建容器的时候，系统默认会分配一个名字，但自定义容器名字有两个好处：

* 自定义的命名比较好记，比如web容器，我们给它起名叫web，可以一目了然。
* 当要连接其它容器是，即便重启，也可以使用容器名而不用改变，比如连接web容器到db容器。

使用`--name`标记可以为容器自定义命名：

```
[vagrant@node1 ~]$ sudo docker run -d -P --name web training/webapp python app.py
e134dd92987f4c2181cd83f3ca2eab73fd01bb2567a17c12411285e8acc47405
[vagrant@node1 ~]$ sudo docker ps -a
CONTAINER ID        IMAGE                     COMMAND                  CREATED             STATUS                      PORTS                                       NAMES
e134dd92987f        training/webapp           "python app.py"          3 seconds ago       Up 3 seconds                0.0.0.0:32769->5000/tcp                     web
```

也可以使用**`docker inspect`**来查看容器的名字：

```
[vagrant@node1 ~]$ sudo docker inspect -f "{{ .Name }}" e134dd92987f
/web
```

在执行**`docker run`**的时候如果添加**`--rm`**标记，则容器在终止后会立即删除，注意，**`--rm`**和**`-d`**参数不能同时使用。

### 2、容器互联

使用**`--link`**参数可以让容器之间安全地进行交互。
创建一个新的数据库容器：

```
[vagrant@node1 ~]$ sudo docker run -d --name DB training/postgres
d69a45f468280058024c8340ebe1197708b99214aedba44b6e6582da0abb685d
[vagrant@node1 ~]$ sudo docker ps -a
CONTAINER ID        IMAGE                     COMMAND                  CREATED             STATUS                      PORTS                                       NAMES
d69a45f46828        training/postgres         "su postgres -c '/..."   13 seconds ago      Up 12 seconds               5432/tcp                                    DB
e134dd92987f        training/webapp           "python app.py"          11 minutes ago      Up 11 minutes               0.0.0.0:32769->5000/tcp                     web
```

删除之前创建的web容器：

```
[vagrant@node1 ~]$ sudo docker stop e134dd92987f
e134dd92987f
[vagrant@node1 ~]$ sudo docker rm -v e134dd92987f
e134dd92987f
[vagrant@node1 ~]$ sudo docker ps -a
CONTAINER ID        IMAGE                     COMMAND                  CREATED              STATUS                      PORTS                                       NAMES
d69a45f46828        training/postgres         "su postgres -c '/..."   About a minute ago   Up About a minute           5432/tcp                                    DB
```
然后创建一个新的web容器，并将它连接到DB容器：

```
[vagrant@node1 ~]$ sudo docker run -d -P --name web --link DB:DB training/webapp python app.py
3398c561dbea428ff740af13829a3b1c88002cb188b47d8cbb4c4d6310031d1d
[vagrant@node1 ~]$ sudo docker ps -a
CONTAINER ID        IMAGE                     COMMAND                  CREATED             STATUS                      PORTS                                       NAMES
3398c561dbea        training/webapp           "python app.py"          2 seconds ago       Up 2 seconds                0.0.0.0:32770->5000/tcp                     web
d69a45f46828        training/postgres         "su postgres -c '/..."   3 minutes ago       Up 3 minutes                5432/tcp                                    DB
```
此时，**`DB容器`**和**`web容器`**建立互联关系：

**`--link`参数的格式为`--link name:alias`，**

其中**name是要连接的容器名称**，**alias是这个连接的别名**。

**Docker相当于在两个互联的容器之间创建了一个虚拟通道，而且不用映射他们的端口到宿主机上**，在启动DB容器的时候并没有使用`-p`和`-P`标记，**从而避免了暴露数据库服务端口到外部网络上。**

Docker通过两种方式为容器公开连接信息：

* 更新环境变量：
* 更新/etc/hosts文件

使用**`env`**命令查看web容器的环境变量：

```
# remove the container directly
[vagrant@node1 ~]$ sudo docker run --rm --name web2 --link DB:DB training/webapp env
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=8b704698b6b3
DB_PORT=tcp://172.17.0.9:5432
DB_PORT_5432_TCP=tcp://172.17.0.9:5432
DB_PORT_5432_TCP_ADDR=172.17.0.9
DB_PORT_5432_TCP_PORT=5432
DB_PORT_5432_TCP_PROTO=tcp
DB_NAME=/web2/DB
DB_ENV_PG_VERSION=9.3
HOME=/root
```

其中DB_开头的环境变量是提供web容器连接DB容器使用的，前缀采用大写的连接别名。

除了环境变量之外，Docker还添加host信息到父容器的`/etc/hosts`文件：

 ```
 
 
[vagrant@node1 ~]$ sudo docker run -it --rm --link DB:DB training/webapp /bin/bash
root@d5f020504bbb:/opt/webapp# pwd
/opt/webapp
root@d5f020504bbb:/opt/webapp# cat /etc/hosts
127.0.0.1	localhost
::1	localhost ip6-localhost ip6-loopback
fe00::0	ip6-localnet
ff00::0	ip6-mcastprefix
ff02::1	ip6-allnodes
ff02::2	ip6-allrouters
172.17.0.9	DB d69a45f46828
172.17.0.10	d5f020504bbb
 ```
 
这里现实两个hosts信息，一个是**DB数据库IP和主机名**，另一个就是**web主机名和IP**，**接着安装ping命令，测试连同性**：
 
```
root@d5f020504bbb:/opt/webapp# apt install -yqq inetutils-ping
The following packages will be REMOVED:
  iputils-ping ubuntu-minimal
The following NEW packages will be installed:
  inetutils-ping
0 upgraded, 1 newly installed, 2 to remove and 3 not upgraded.
Need to get 55.6 kB of archives.
After this operation, 131 kB of additional disk space will be used.
(Reading database ... 18233 files and directories currently installed.)
Removing ubuntu-minimal (1.325) ...
Removing iputils-ping (3:20121221-4ubuntu1.1) ...
Selecting previously unselected package inetutils-ping.
(Reading database ... 18221 files and directories currently installed.)
Preparing to unpack .../inetutils-ping_2%3a1.9.2-1_amd64.deb ...
Unpacking inetutils-ping (2:1.9.2-1) ...
Setting up inetutils-ping (2:1.9.2-1) ...


root@d5f020504bbb:/opt/webapp# ping DB
PING DB (172.17.0.9): 56 data bytes
64 bytes from 172.17.0.9: icmp_seq=0 ttl=64 time=0.123 ms
64 bytes from 172.17.0.9: icmp_seq=1 ttl=64 time=0.073 ms
64 bytes from 172.17.0.9: icmp_seq=2 ttl=64 time=0.095 ms
^C--- DB ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max/stddev = 0.073/0.097/0.123/0.000 ms
```

用ping命令来测试DB容器，结果解析`172.17.0.9`，证明连接成功**；用户可以连接多个子容器到父容器，比如可以连接多个web到同一个DB容器上**

 