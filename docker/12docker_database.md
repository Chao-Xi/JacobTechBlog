# 数据库应用

 目前主流数据库包括**关系型(SQL)**和**非关系型(NoSQL)**两种。
 
 关系型数据库是建立在关系模型基础上的数据库，借助于集合代数等数学概念和方法来处理数据库的数据，支持复杂的事物处理和结构化查询。代表实现有**MySQL、Oracle、PostGreSQL、MariaDB、SQLServer**等。
 
 非关系型数据库放弃了传统关系型数据库的部分强一致性限制，带来性能上的提升，更使用于需要大规模并行处理的场景；非关系型数据库是关系型数据库的良好补充。代表实现有**MongoDB、Redis、CouchDB**等。
 
 
##  MySQL

![Alt Image Text](images/docker12_body1.jpg "body image")

MySQL是全球最流行的开源的开源关系数据库软件之一，因为其高性能、成熟可靠和适应性而得到广泛应用；MySQL目前在不少的大规模网站和应用中被使用。

使用官方镜像可以快速启动一个MySQL Server实例：

```
$ docker run --name hi-mysql -e MYSQL_ROOT_PASSWORD=123 -d mysql:latest
17951b5d1bdb4431246f62bced42ce33e779f7be93375c5eaf4b86cc62b99419

$ docker ps -a
CONTAINER ID        IMAGE                     COMMAND                  CREATED             STATUS               PORTS                     NAMES
17951b5d1bdb        mysql:latest              "docker-entrypoint..."   8 seconds ago       Up 6 seconds         3306/tcp, 33060/tcp       hi-mysql
```

hi-mysql是容器的名称，123为数据库的root的密码。使用docker ps可以在运行的容器。

### 1、系统与日志访问

可以使用`docker exec`指令调用内部系统的`bash shell`，以访问容器内部系统：

```
$ docker exec -it hi-mysql bash
```

```
root@17951b5d1bdb:/# mysql -uroot -p123
mysql: [Warning] Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 9
Server version: 8.0.12 MySQL Community Server - GPL

Copyright (c) 2000, 2018, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
4 rows in set (0.01 sec)

mysql> create database jxi_test;
Query OK, 1 row affected (0.20 sec)

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| jxi_test           |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
5 rows in set (0.00 sec)
```

退出数据库

```
mysql> quit
Bye
root@17951b5d1bdb:/#
```

### 2、使用自定义配置文件

如果使用自定义MySQL配置，则可以创建一个目录，内置cnf配置文件，然后将其挂载至容器的`/etc/mysql/conf.d`目录；比如自定义配置文件为`/my/custom/config-file.cnf`，则可以使用以下命令：

```
docker run --name some-mysql1 -v /my/custom:/etc/mysql/conf.d -e MYSQL_ROOT_PASSWORD=456 -d mysql:latest
4e6f340d6a4a8e729db108f7f72a9e76f5a72c46f0bbf70e18b71f1ab2973e5f

docker ps -a
CONTAINER ID        IMAGE                     COMMAND                  CREATED             STATUS             PORTS                     NAMES
4e6f340d6a4a        mysql:latest              "docker-entrypoint..."   4 seconds ago       Up 2 seconds       3306/tcp, 33060/tcp       some-mysql1
17951b5d1bdb        mysql:latest              "docker-entrypoint..."   18 minutes ago      Up 18 minutes      3306/tcp, 33060/tcp       hi-mysql
```

可以看到启动一个新的容器，新容器就会结合创建的两个配置文件

```
cd /my/custom/

ls -la
total 0
drwxr-xr-x 2 root root  6 Aug 23 02:53 .
drwxr-xr-x 3 root root 20 Aug 23 02:53 ..
```

```
$ less /etc/my.cnf

[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0
# Settings user and group are ignored when systemd is used.
# If you need to run mysqld under a different user or group,
# customize your systemd unit file for mariadb according to the
# instructions in http://fedoraproject.org/wiki/Systemd

[mysqld_safe]
log-error=/var/log/mariadb/mariadb.log
pid-file=/var/run/mariadb/mariadb.pid

#
# include all files from the config directory
#
!includedir /etc/my.cnf.d
```

### 3、脱离cnf文件进行配置

很多的配置选项可以通过标签（flags）传递mysqld进程；这样用户就可以脱离cnf配置文件，对容器进行弹性的定制。比如：改变默认编码方式，将所有表格的编码方式修改为uft8mb4：


如果需要查看可用选项的完整列表，可以执行：

```
$ docker run -it --rm mysql:latest -verbose --help 
$ docker run -it --rm mysql:latest -verbose --help  > conf.txt

2018-08-23T03:14:35.998793Z 0 [Warning] [MY-011070] [Server] 'Disabling symbolic links using --skip-symbolic-links (or equivalent) is the default. Consider not using this option as it' is deprecated and will be removed in a future release.
mysqld  Ver 8.0.12 for Linux on x86_64 (MySQL Community Server - GPL)
Copyright (c) 2000, 2018, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Starts the MySQL database server.

Usage: mysqld [OPTIONS]

Default options are read from the following files in the given order:
/etc/my.cnf /etc/mysql/my.cnf ~/.my.cnf
The following groups are read: mysqld server mysqld-8.0
The following options may be given as the first argument:
--print-defaults        Print the program argument list and exit.
--no-defaults           Don't read default options from any option file,
                        except for login file.
--defaults-file=#       Only read default options from the given file #.
--defaults-extra-file=# Read this file after the global files are read.
--defaults-group-suffix=#
                        Also read groups with concat(group, suffix)
--login-path=#          Read this path from the login file.
```

## MongoDB

![Alt Image Text](images/docker12_body2.jpg "body image")

MongoDB是一款可扩展、高性能的开源文档数据库，是当今最流行的NoSQL数据库软件之一。采用C++开发，支持复杂的数据类型和强大的查询语言，提供了关系数据库的绝大部分功能。

### 一、可以使用docker run指令直接运行官方mongodb镜像

```
$ docker run --name mongo-container -d mongo
Unable to find image 'mongo:latest' locally
Trying to pull repository docker.io/library/mongo ...
latest: Pulling from docker.io/library/mongo
3b37166ec614: Pull complete
ba077e1ddb3a: Pull complete
34c83d2bc656: Pull complete
84b69b6e4743: Pull complete
0f72e97e1f61: Pull complete
ce9080750e9c: Pull complete
931490877d83: Pull complete
ab49899969a7: Pull complete
a0ef762c0966: Pull complete
faa01fee8eab: Pull complete
c35e41e41615: Pull complete
5d923a737149: Pull complete
307ec52f6e87: Pull complete
87ef7e24f86a: Pull complete
Digest: sha256:e40c5b535cb2f1f39dba4687abfd0ecbec89520aba1945484ea00cf8688d4595
Status: Downloaded newer image for docker.io/mongo:latest
37802d38b0424d3d79601d4b87276e7b0f4eb9c662da7e16fcc263866c05216c
```

使用docker ps查看正在运行的mongo-container容器的容器ID：

```
docker ps -a
CONTAINER ID        IMAGE                     COMMAND                  CREATED             STATUS               PORTS              NAMES
37802d38b042        mongo                     "docker-entrypoint..."   2 minutes ago       Up 2 minutes         27017/tcp          mongo-container
```

mongo容器启动一个bash进程，并通过`mongo`指令启动mongodb交互命令行，再通过`db.stats()`指令查看数据库状态

```
$ docker exec -it 37802d38b042 bash
root@37802d38b042:/# mongo

MongoDB shell version v4.0.1
connecting to: mongodb://127.0.0.1:27017
MongoDB server version: 4.0.1
Welcome to the MongoDB shell.
For interactive help, type "help".
For more comprehensive documentation, see
	http://docs.mongodb.org/
Questions? Try the support group
	http://groups.google.com/group/mongodb-user
Server has startup warnings:
2018-08-23T03:24:42.344+0000 I CONTROL  [initandlisten]
2018-08-23T03:24:42.344+0000 I CONTROL  [initandlisten] ** WARNING: Access control is not enabled for the database.
2018-08-23T03:24:42.344+0000 I CONTROL  [initandlisten] **          Read and write access to data and configuration is unrestricted.
2018-08-23T03:24:42.344+0000 I CONTROL  [initandlisten]
---
Enable MongoDB's free cloud-based monitoring service, which will then receive and display
metrics about your deployment (disk utilization, CPU, operation statistics, etc).

The monitoring data will be available on a MongoDB website with a unique URL accessible to you
and anyone you share the URL with. MongoDB may use this information to make product
improvements and to suggest MongoDB products and deployment options to you.

To enable free monitoring, run the following command: db.enableFreeMonitoring()
To permanently disable this reminder, run the following command: db.disableFreeMonitoring()
---

> show dbs
admin   0.000GB
config  0.000GB
local   0.000GB

> exit
bye
```

还可以通过env查看环境变量的配置：

```
root@37802d38b042:/# env
HOSTNAME=37802d38b042
MONGO_VERSION=4.0.1
TERM=xterm
MONGO_PACKAGE=mongodb-org
MONGO_REPO=repo.mongodb.org
JSYAML_VERSION=3.10.0
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
GPG_KEYS=9DA31620334BD75D9DCB49F368818C72E52529D4
PWD=/
SHLVL=1
HOME=/root
MONGO_MAJOR=4.0
GOSU_VERSION=1.10
_=/usr/bin/env
```
镜像默认暴露了mongodb的服务端口：**27017**，可以通过该端口访问服务。

### 1、连接mongodb容器

使用`--link`参数，连接新建的`mongo-container`容器：

```
$ docker run -it --link mongo-container:db alpine sh
Unable to find image 'alpine:latest' locally
Trying to pull repository docker.io/library/alpine ...
latest: Pulling from docker.io/library/alpine
8e3ba11ec2a2: Pull complete
Digest: sha256:7043076348bf5040220df6ad703798fd8593a0918d06d3ce30c6c93be117e430
Status: Downloaded newer image for docker.io/alpine:latest
/ # ls -l
total 8
drwxr-xr-x    2 root     root          4096 Jul  5 14:47 bin
drwxr-xr-x    5 root     root           360 Aug 23 03:40 dev
drwxr-xr-x    1 root     root            66 Aug 23 03:40 etc
drwxr-xr-x    2 root     root             6 Jul  5 14:47 home
drwxr-xr-x    5 root     root           278 Jul  5 14:47 lib
drwxr-xr-x    5 root     root            44 Jul  5 14:47 media
drwxr-xr-x    2 root     root             6 Jul  5 14:47 mnt
dr-xr-xr-x  225 root     root             0 Aug 23 03:40 proc
drwx------    1 root     root            26 Aug 23 03:41 root
drwxr-xr-x    1 root     root            21 Aug 23 03:40 run
drwxr-xr-x    2 root     root          4096 Jul  5 14:47 sbin
drwxr-xr-x    2 root     root             6 Jul  5 14:47 srv
dr-xr-xr-x   13 root     root             0 Aug 23 03:40 sys
drwxrwxrwt    2 root     root             6 Jul  5 14:47 tmp
drwxr-xr-x    7 root     root            66 Jul  5 14:47 usr
drwxr-xr-x   11 root     root           125 Jul  5 14:47 var
```

进入alpine系统容器后，用户可以使用ping指令测试mongo容器的连通性

```
/ # ping db
PING db (172.17.0.3): 56 data bytes
64 bytes from 172.17.0.3: seq=0 ttl=64 time=0.149 ms
64 bytes from 172.17.0.3: seq=1 ttl=64 time=0.096 ms
64 bytes from 172.17.0.3: seq=2 ttl=64 time=0.188 ms
64 bytes from 172.17.0.3: seq=3 ttl=64 time=0.159 ms
```

### 2、直接使用mongo cli指令

如果想直接在宿主机机器使用mongodb镜像，可以在`docker run`指令后面加入`entrypoint`指令，这样就可以非常方便的直接进入`mongo cli`了

```
$ docker run -it --link mongo-container:db mongo mongo --host db

MongoDB shell version v4.0.1
connecting to: mongodb://db:27017/
MongoDB server version: 4.0.1
Welcome to the MongoDB shell.
For interactive help, type "help".
For more comprehensive documentation, see
	http://docs.mongodb.org/
Questions? Try the support group
	http://groups.google.com/group/mongodb-user
2018-08-23T03:49:32.475+0000 I STORAGE  [main] In File::open(), ::open for '/home/mongodb/.mongorc.js' failed with Unknown error
Server has startup warnings:
2018-08-23T03:24:42.344+0000 I CONTROL  [initandlisten]
2018-08-23T03:24:42.344+0000 I CONTROL  [initandlisten] ** WARNING: Access control is not enabled for the database.
2018-08-23T03:24:42.344+0000 I CONTROL  [initandlisten] **          Read and write access to data and configuration is unrestricted.
2018-08-23T03:24:42.344+0000 I CONTROL  [initandlisten]
---
Enable MongoDB's free cloud-based monitoring service, which will then receive and display
metrics about your deployment (disk utilization, CPU, operation statistics, etc).

The monitoring data will be available on a MongoDB website with a unique URL accessible to you
and anyone you share the URL with. MongoDB may use this information to make product
improvements and to suggest MongoDB products and deployment options to you.

To enable free monitoring, run the following command: db.enableFreeMonitoring()
To permanently disable this reminder, run the following command: db.disableFreeMonitoring()
---

> db.version()
4.0.1
> db.stats()
{
	"db" : "test",
	"collections" : 0,
	"views" : 0,
	"objects" : 0,
	"avgObjSize" : 0,
	"dataSize" : 0,
	"storageSize" : 0,
	"numExtents" : 0,
	"indexes" : 0,
	"indexSize" : 0,
	"fileSize" : 0,
	"fsUsedSize" : 0,
	"fsTotalSize" : 0,
	"ok" : 1
}

```

最后，可以使用`--storageEngine`参数来设置储存引擎：

```
$ docker run --name mongo-container -d mongo --storageEngine wiredTiger
3beacb9defdaaf32a02e14e95d0ae330849bc75c50a00e63103694471aa7e30f

$ docker ps -a
CONTAINER ID        IMAGE                     COMMAND                  CREATED             STATUS                        PORTS                     NAMES
3beacb9defda        mongo                     "docker-entrypoint..."   5 seconds ago       Up 3 seconds                  27017/tcp                 mongo-container
```

## 二、使用自定义Dockerfile

### 1、新建项目目录，并在根目录新建Dockerfile
**设置用户之前创建的sshd镜像继承**
[how to make it](9docker_ssh.md) 

```
$ mkdir mongodb
$ cd mongodb/
[mongodb]$ vi Dockerfile

#设置用户之前创建的sshd镜像继承
FROM sshd:dockerfile
MAINTAINER docker_user (jxi@docker.com)

RUN apt-get update && \
	apt-get install -y mongodb pwgen && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

#创建mongodb存放数据文件的文件夹
RUN mkdir -p /data/db
VOLUME /data/db

ENV AUTH yes

#添加脚本
ADD run.sh /run.sh
ADD set_mongodb_password.sh /set_mongodb_password.sh
RUN chmod 755 ./*.sh

EXPOSE 27017
EXPOSE 28017

CMD ["/run.sh"]
```

新建`set_mongodb_password.sh`脚本。主要负责配置数据库的用户名和密码：

```
vi set_mongodb_password.sh

#这个脚本主要设置数据库的用户名和密码
#!/bin/bash

#判断是否已经设置过密码
if [ -f /.mongodb_password_set ]; then
       echo "MongoDB password already set!"
       exit 0
fi

/usr/local/mongodb/bin/mongod --smallfiles --nojournal &

PASS=${MONGODB_PASS:-$(pwgen -s 12 1)}
_word=$( [ ${MONGODB_PASS} ] && echo "preset" || echo "random" )

RET=1
while [[ RET -ne 0 ]]; do
   echo "=> Waiting for confirmation of MongoDB service startup"
   sleep 5
   mongo admin --eval "help" >/dev/null 2>&1
   RET=$?
done

#通过docker logs + id可以看到下面的输出
echo "=> Creating an admin user with a ${_word} password in MongoDB"
mongo admin --eval "db.addUser({user: 'admin', pwd: '$PASS', roles: [ 'userAdminAnyDatabase', 'dbAdminAnyDatabase' ]});"
mongo admin --eval "db.shutdownServer();"

echo "=> Done!"
touch /.mongodb_password_set

echo "========================================================================"
echo "You can now connect to this MongoDB server using:"
echo ""
echo "    mongo admin -u admin -p $PASS --host <host> --port <port>"
echo ""
echo "Please remember to change the above password as soon as possible!"
echo "========================================================================"
```

新建run.sh脚本，主要的mongodb启动脚本：

```
vi run.sh

#!/bin/bash

if [ ! -f /.mongodb_password_set ]; then

        /set_mongodb_password.sh

fi

if [ "$AUTH" == "yes" ]; then

   #export mongodb='/usr/local/mongodb/bin/mongod --nojournal --auth --httpinterface --rest'

    export mongodb='/usr/local/mongodb/bin/mongod --nojournal --auth'

else

   #export mongodb='/usr/local/mondodb/bin/mongod --nojournal --httpinterface --rest'

    export mongodb='/usr/local/mondodb/bin/mongod --nojournal'

fi

if [ ! -f /data/db/mongod.lock ]; then

    eval $mongodb

else

    export mongodb=$mongodb' --dbpath /data/db' 

    rm /data/db/mongod.lock

    mongod --dbpath /data/db --repair && eval $mongodb

fi
```

### 2、使用docker build指令构建镜像

```
$ docker build  -t mongodb-image .

Sending build context to Docker daemon 5.632 kB
Step 1/12 : FROM sshd:dockerfile
 ---> b59b2f96ecd5
Step 2/12 : MAINTAINER docker_user (jxi@docker.com)
 ---> Running in 2359d13a1668
 ---> 63a6a0912bbc
Removing intermediate container 2359d13a1668
Step 3/12 : RUN apt-get update && 	apt-get install -y mongodb pwgen && 	apt-get clean && 	rm -rf /var/lib/apt/lists/*
 ---> Running in 8b981b75926a

.....

Removing intermediate container f21ee1022afb
Step 10/12 : EXPOSE 27017
 ---> Running in 8319222566a6
 ---> ca32c584b2ec
Removing intermediate container 8319222566a6
Step 11/12 : EXPOSE 28017
 ---> Running in f266c3521c79
 ---> 462628e84681
Removing intermediate container f266c3521c79
Step 12/12 : CMD /run.sh
 ---> Running in 9b1121ba83a9
 ---> 11bd6d90294f
Removing intermediate container 9b1121ba83a9
Successfully built 11bd6d90294f
```

### 3、启动后台容器，并分别映射27017和28017端口到本地

```
$ docker run -d -p 27017:27017 -p 28017:28017 mongodb-image
bc3daf4a5c7a0b433bf335c31781a4707d35e857b661924020639ea881f01055
```
```
docker ps -a
CONTAINER ID        IMAGE                   COMMAND       CREATED             STATUS             PORTS                                                        NAMES
bc3daf4a5c7a        mongodb-image           "/run.sh"     22 seconds ago      Up 20 seconds      0.0.0.0:27017->27017/tcp, 22/tcp, 0.0.0.0:28017->28017/tcp   jovial_davinci
```

通过docker logs查看默认的admin账户密码：

```
docker logs fefb14c07337
```

也可以利用环境变量在容器启动时指定密码：

```
docker run -d -p 27017:27017 -p 28017:28017 mongo -e MONGODB_PASS="mypsaa" mongodb
```

甚至，设定不需要密码即可访问：

```
docker run -d -p 27017:27017 -p 28017:28017 mongo -e AUTH=no mongodb
```

## Redis

![Alt Image Text](images/docker12_body3.jpg "body image")

Redis是一个开源（BSD许可）的基于内存的数据结构存储系统，可以用作数据库、缓存和消息中间件。Redis使用ANSI C实现，全称意为`REmote DIctionary Server`。

通过`docker run`直接启动一个**redis-container容器**：

```
$ docker run --name redis-container -d redis

Unable to find image 'redis:latest' locally
Trying to pull repository docker.io/library/redis ...
latest: Pulling from docker.io/library/redis
be8881be8156: Already exists
d6f5ea773ca3: Pull complete
735cc65c0db4: Pull complete
787dddf99946: Pull complete
0733799a7c0a: Pull complete
6d250f04811a: Pull complete
Digest: sha256:858b1677143e9f8455821881115e276f6177221de1c663d0abef9b2fda02d065
Status: Downloaded newer image for docker.io/redis:latest
afb2a02889e3f6552182a2712111294e59b92e6c6ad79c6ee7d53de45520d51c

$ docker ps -a
CONTAINER ID        IMAGE       COMMAND                  CREATED              STATUS                 PORTS          NAMES
afb2a02889e3        redis       "docker-entrypoint..."   About a minute ago   Up About a minute      6379/tcp       redis-container
```



### 1、连接redis容器

可以使用`--link参数`，连接创建的redis-container容器：进入容器可以使用ping指令测试容器

```
$ docker run -it --link redis-container:db alpine sh
/ # ping db
PING db (172.17.0.4): 56 data bytes
64 bytes from 172.17.0.4: seq=0 ttl=64 time=0.137 ms
64 bytes from 172.17.0.4: seq=1 ttl=64 time=0.133 ms
^C
--- db ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss
round-trip min/avg/max = 0.133/0.135/0.137 ms

/ # nc db 6379
ping
+PONG
```

官方镜像内也自带了redis客户端，可以使用指令直接使用：

```
docker run -it --link redis-container:db --entrypoint redis-cli redis -h db

db:6379> ping
PONG
db:6379> set 1 2
OK
db:6379> get 1
"2"
db:6379>
```

### 2、使用自定义配置

可以通过数据卷实现自定义redis配置：

```
$ docker run -v /myredis/cong/redis.conf:/user/local/etc/redis/redis.conf --name myredis redis redis-server /user/local/etc/redis/redis.conf


1:C 23 Aug 04:35:42.092 # oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
1:C 23 Aug 04:35:42.098 # Redis version=4.0.11, bits=64, commit=00000000, modified=0, pid=1, just started
1:C 23 Aug 04:35:42.098 # Configuration loaded
1:M 23 Aug 04:35:42.099 * Running mode=standalone, port=6379.
1:M 23 Aug 04:35:42.099 # WARNING: The TCP backlog setting of 511 cannot be enforced because /proc/sys/net/core/somaxconn is set to the lower value of 128.
1:M 23 Aug 04:35:42.099 # Server initialized
1:M 23 Aug 04:35:42.099 # WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
1:M 23 Aug 04:35:42.099 * Ready to accept connections
^C1:signal-handler (1534999131) Received SIGINT scheduling shutdown...
1:M 23 Aug 04:38:51.791 # User requested shutdown...
1:M 23 Aug 04:38:51.791 # Redis is now ready to exit, bye bye...

```

## Memcached


![Alt Image Text](images/docker12_body4.jpg "body image")
Memcached是一个高性能、分布式的开源内存对象缓存系统。守护进程基于C语言实现，基于libevent的事件处理可以实现很高的性能，由于数据仅存在于内存中，因此重启Memcached或重启操作系统会导致数据全部丢失。

直接使用官方提供的memcached镜像运行一个memcached-container容器：

```
$ docker run --name memcached-container -d memcached
Unable to find image 'memcached:latest' locally
Trying to pull repository docker.io/library/memcached ...
latest: Pulling from docker.io/library/memcached
be8881be8156: Already exists
2d7b02eaa8cb: Pull complete
988ce23b2606: Pull complete
d6a941ece7ef: Pull complete
32bb7a7ebd5c: Pull complete
Digest: sha256:69f0266361e61c532e670a4a7fdd94e2520583b4d737918d6b92eb3bac9e7d8d
Status: Downloaded newer image for docker.io/memcached:latest
4643051cb9c7ec0645bdb7e5a031520273482e2107d09d0fd1c97b87258d0f21
```

在docker run指令中可以设定memcached server使用的内存大小：

```
$ docker run --name memcached-container-2 -d memcached memcached -m 64
82d22ac405ba9034abbf21b8af05653c542ecb8ff935b41f2a3c2d430cd36c7e

$ docker ps -a
CONTAINER ID        IMAGE            COMMAND                  CREATED             STATUS            PORTS         NAMES
82d22ac405ba        memcached         "docker-entrypoint..."   5 seconds ago      Up 3 seconds      11211/tcp     memcached-container-2
```
以上命令将memcached server的内存使用量设置为64M