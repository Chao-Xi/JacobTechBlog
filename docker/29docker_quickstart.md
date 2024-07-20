# 2024 Docker快速启动清单

## 1 - 中间件 -

### 1-1 Nginx

镜像拉取：`docker pull nginx`

```

docker run -itd -p 80:80 --restart=always --name Nginx \
-v /docker_data/Nginx_data/html:/usr/share/nginx/html \
-v /docker_data/Nginx_data/conf:/etc/nginx/conf.d \
-v /docker_data/Nginx_data/nginx.conf:/etc/nginx/nginx.conf \
nginx
```

```
# 参数解释
# -itd: 表示以后台运行的方式启动容器,并分配一个伪终端（pseudo-TTY）和保持 STDIN 打开
# -p 80:80: 将主机的端口映射到容器的端口，这里是将主机的 80 端口映射到容器的 80 端口，用于访问 Nginx 站点页面
# --name Nginx: 为容器指定一个名称，这里是 "Nginx"
# --restart=always: 表示当容器退出时，总是重新启动容器
```

```
# 持久化解释
# -v /docker_data/Nginx_data/html:/usr/share/nginx/html
# 将到容器中的 "/usr/share/nginx/html" 路径映射挂载到 宿主机中的"/docker_data/Nginx_data/html"目录下,这样做的目的是将 Nginx 的 站点页面 路径映射到本地
# -v /docker_data/Nginx_data/conf:/etc/nginx/conf.d (可不映射，映射请确保配置文件准确，否则可能会启动失败)
# 将到容器中的 "/etc/nginx/conf.d" 路径映射挂载到 宿主机中的"/docker_data/Nginx_data/conf"目录下,这样做的目的是将 Nginx 的 虚拟主机配置文件 路径映射到本地
# -v /docker_data/Nginx_data/nginx.conf:/etc/nginx/nginx.conf (可不映射，映射请确保配置文件准确，否则可能会启动失败)
# 将到容器中的 "/etc/nginx/nginx.conf" 路径映射挂载到 宿主机中的"/docker_data/Nginx_data/nginx.conf"目录下,这样做的目的是将 Nginx 的 主配置文件 路径映射到本地
```

### 1-2 Tomcat

镜像拉取：docker pull tomcat

启动容器的方式

```
docker run -itd -p 8080:8080 --restart=always --name Tomcat \
-v /docker_data/Tomcat_data/webapps:/usr/local/tomcat/webapps/ROOT \
tomcat
```

```
# 参数解释
# -itd: 表示以后台运行的方式启动容器,并分配一个伪终端（pseudo-TTY）和保持 STDIN 打开
# -p 8080:8080: 将主机的端口映射到容器的端口，这里是将主机的 8080 端口映射到容器的 8080 端口，用于访问 Tomcat 站点页面
# --name Tomcat: 为容器指定一个名称，这里是 "Tomcat"
# --restart=always: 表示当容器退出时，总是重新启动容器
```

```
# 持久化解释
# -v /docker_data/Tomcat_data/webapps:/usr/local/tomcat/webapps/ROOT
# 将到容器中的 "/usr/local/tomcat/webapps/ROOT" 路径映射挂载到 宿主机中的"/docker_data/Tomcat_data/webapps"目录下,这样做的目的是将 Tomcat 的 站点页面 路径映射到本地
```


### 1-3 Weblogic

镜像拉取：`docker pull ismaleiva90/weblogic12`

启动容器的方式

```
docker run -itd -p 7001:7001 \
--restart=always --name Weblogic \
ismaleiva90/weblogic12
```

```
# 参数解释
# -itd: 表示以后台运行的方式启动容器,并分配一个伪终端（pseudo-TTY）和保持 STDIN 打开
# -p 7001:7001: 将主机的端口映射到容器的端口，这里是将主机的 7001 端口映射到容器的 7001 端口，用于访问 Weblogic 控制台页面
# --name Weblogic: 为容器指定一个名称，这里是 "Weblogic"
# --restart=always: 表示当容器退出时，总是重新启动容器

 Web Console
# http://localhost:7001/console
# User: weblogic
# Pass: welcome1
```

## 2 - 数据库 -

### 2-1 MySQL

镜像拉取：docker pull mysql:8.0.31

启动容器的方式

```
docker run -d -it -p 3306:3306 --name MySQL --restart=always \
-v /docker_data/MySQL_Data/data:/var/lib/mysql \
-v /docker_data/MySQL_Data/conf:/etc/mysql/conf.d \
--privileged=true \
-e MYSQL_DATABASE='test_db' \
-e MYSQL_ROOT_PASSWORD='abc$123' \
-e MYSQL_USER='testuser' -e MYSQL_PASSWORD='abc$123' \
mysql:8.0.31 --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
```

```
# 参数解释
# -d: 表示以后台运行的方式启动容器
# -it: 分别表示分配一个伪终端（pseudo-TTY）并保持 STDIN 打开
# -p 3306:3306: 将主机的端口映射到容器的端口，这里是将主机的 3306 端口映射到容器的 3306 端口，用于访问 MySQL 数据库
# --name MySQL: 为容器指定一个名称，这里是 "MySQL"
# --restart=always: 表示当容器退出时，总是重新启动容器
# --privileged=true: 若不加字段--privileged=true可能会报权限错误
# --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci: 这两个选项参数是改变所有表的默认编码和排序规则以使用 UTF-8 (utf8mb4
```

```
# 持久化解释
# -v /docker_data/MySQL_Data/data:/var/lib/mysql
# 将到容器中的 "/var/lib/mysql" 路径映射挂载到 宿主机中的"/docker_data/MySQL_Data/data"目录下,这样做的目的是将 MySQL 数据库的数据存储在本地中，以便数据在容器重启时得以保留
# -v /docker_data/MySQL_Data/conf:/etc/mysql/conf.d (可不映射，映射请确保配置文件准确，否则可能会启动失败)
# 将到容器中的 "/etc/mysql/conf.d" 路径映射挂载到 宿主机中的"/docker_data/MySQL_Data/conf"目录下,这样做的目的是自定义配置文件的路径
```

```
# 环境变量解释
# MYSQL_ROOT_PASSWORD【必选】
# 该变量是必需的，指定将为 MySQL 的 root 超级用户帐户设置的密码,MYSQL_RANDOM_ROOT_PASSWORD=yes这个变量也是设置root用户密码的，不同的是他是随机生成一个密码,生成的 root 密码将打印到 stdout ( GENERATED ROOT PASSWORD: .....)。
# MYSQL_USER【可选】
# 这些变量是可选的，结合使用来创建新用户。该用户将被授予变量指定的数据库的超级用户权限。创建用户需要同时设置`MYSQL_PASSWORD`变量。
# 请注意，无需使用此机制来创建 root 超级用户，默认情况下会使用变量指定的密码创建该用户MYSQL_ROOT_PASSWORD
# MYSQL_PASSWORD【可选】
# 这些变量是可选的，结合使用来创建新用户并设置该用户的密码。该用户将被授予变量指定的数据库的超级用户权限。创建用户需要这两个变量。
# 请注意，无需使用此机制来创建 root 超级用户，默认情况下会使用变量指定的密码创建该用户MYSQL_ROOT_PASSWORD
# MYSQL_DATABASE【可选】
# 该变量是可选的，允许您指定要在映像启动时创建的数据库的名称。如果提供了MYSQL_USER、MYSQL_PASSWORD这两个变量，则该变量设置的用户将被授予对此数据库的超级用户访问权限
```

### 2-2 Oracle 11g

镜像拉取：`docker pull registry.cn-hangzhou.aliyuncs.com/helowin/oracle_11g`

启动容器的方式

```
docker run -d -it -p 1521:1521 --name Oracle_11g --restart=always \
--mount source=oracle_vol,target=/home/oracle/app/oracle/oradata \
registry.cn-hangzhou.aliyuncs.com/helowin/oracle_11g
```

```
# 参数解释
# -d: 表示以后台运行的方式启动容器
# -it: 分别表示分配一个伪终端（pseudo-TTY）并保持 STDIN 打开
# -p 1521:1521: 将主机的端口映射到容器的端口，这里是将主机的 1521 端口映射到容器的 1521 端口，用于访问 Oracle 数据库
# --name Oracle_11g: 为容器指定一个名称，这里是 "Oracle_11g"
# --restart=always: 表示当容器退出时，总是重新启动容器
```

```
# 持久化解释
# --mount source=oracle_vol,target=/home/oracle/app/oracle/oradata 将名为 "oracle_vol" 的 Docker 卷挂载到容器中的 "/home/oracle/app/oracle/oradata" 路径。这样做的目的是将 Oracle 数据库的数据存储在持久化的卷中，以便数据在容器重启时得以保留
```

### 2-3 PostgreSQL

镜像拉取：docker pull postgres

启动容器的方式

```
docker run -d -p 5432:5432 --restart=always --name PostgreSQL \
-e POSTGRES_USER='postgres' \
-e POSTGRES_PASSWORD='abc$123' \
-e POSTGRES_DB='test' \
-e PGDATA=/var/lib/postgresql/data/pgdata \
-v /docker_data/Postgres_Data:/var/lib/postgresql/data \
-d postgres
```

```
# 参数解释
# -d: 表示以后台运行的方式启动容器
# -it: 分别表示分配一个伪终端（pseudo-TTY）并保持 STDIN 打开
# -p 5432:5432: 将主机的端口映射到容器的端口，这里是将主机的 5432 端口映射到容器的 5432 端口，用于访问 Postgre 数据库
# --name PostgreSQL: 为容器指定一个名称，这里是 "PostgreSQL"
# --restart=always: 表示当容器退出时，总是重新启动容器
```

```
# 持久化解释
# -v /docker_data/Postgres_Data:/var/lib/postgresql/data
# 将到容器中的 "/var/lib/postgresql/data" 路径映射挂载到 宿主机中的 ”/docker_data/Postgres_Data“目录下,这样做的目的是将 Postgre 数据库的数据存储在本地中，以便数据在容器重启时得以保留

# 环境变量解释
# POSTGRES_PASSWORD【必选】
# 您需要使用此环境变量才能使用 PostgreSQL 映像。它不能为空或未定义。该环境变量设置 PostgreSQL 的超级用户密码。默认超级用户由环境变量定义POSTGRES_USER
# POSTGRES_USER【可选】
# 此可选环境变量与设置用户及其密码结合使用。该变量将创建具有超级用户权限的指定用户和同名的数据库。如果未指定，则将使用默认用户"postgres"
# POSTGRES_DB【可选】
# 此可选环境变量可用于为首次启动映像时创建的默认数据库定义不同的名称。如果未指定，则将使用POSTGRES_USER设定的值，如果POSTGRES_USER没有设定则默认为"postgres"。
# PGDATA【可选】
# 默认为/var/lib/postgresql/data 如果您使用的数据卷是文件系统挂载点（如 GCE 持久磁盘），或无法被用户 chowned 的远程文件夹postgres（如某些 NFS 挂载），或包含文件夹/文件（例如lost+found），则 Postgresinitdb需要一个子目录在安装点内创建以包含数据
```

### 2-4 达梦

镜像拉取：docker pull if010/dameng

启动容器的方式

```
docker run -d -p 5236:5236 --restart=always --name DaMengDB --privileged=true \
-e PAGE_SIZE=16 \
-e LD_LIBRARY_PATH=/opt/dmdbms/bin \
-e EXTENT_SIZE=32 \
-e BLANK_PAD_MODE=1 \
-e LOG_SIZE=1024 \
-e UNICODE_FLAG=1 \
-e LENGTH_IN_CHAR=1 \
-e INSTANCE_NAME=dm8_test \
-v /docker_data/DaMeng_Data:/opt/dmdbms/data \
if010/dameng
```

```
# 参数解释
# *该镜像是本人从官网下载后重新上传Docker Hub的，可放心使用
# -d: 表示以后台运行的方式启动容器
# -it: 分别表示分配一个伪终端（pseudo-TTY）并保持 STDIN 打开
# -p 5236:5236: 将主机的端口映射到容器的端口，这里是将主机的 5236 端口映射到容器的 5236 端口，用于访问达梦数据库
# --name DaMengDB: 为容器指定一个名称，这里是 "DaMengDB"
# --restart=always: 表示当容器退出时，总是重新启动容器
```

```
# 持久化解释
# -v /docker_data/DaMeng_Data:/opt/dmdbms/data
# 将到容器中的 "/opt/dmdbms/data" 路径映射挂载到 宿主机中的 ”/docker_data/DaMeng_Data“目录下,这样做的目的是将 达梦 数据库的数据存储在本地中，以便数据在容器重启时得以保留留

# 使用 `-e` 命令参数指定数据库初始化时，需要注意的是 页大小 (page_size)、簇大小 (extent_size)、大小写敏感 (case_sensitive)、字符集 (UNICODE_FLAG) 、VARCHAR 类型以字符为单位 (LENGTH_IN_CHAR)、空格填充模式 (BLANK_PAD_MODE) 、页检查模式（PAGE CHECK）等部分参数，一旦确定无法修改，在初始化实例时确认需求后谨慎设置。

# 注意
# 1.如果使用 docker 容器里面的 disql，进入容器后，先执行 source /etc/profile 防止中文乱码。
# 2.新版本 Docker 镜像中数据库默认用户名/密码为 SYSDBA/SYSDBA001（注意全部都是大写）。
```

### 2-5 Redis

镜像拉取：docker pull redis

启动容器的方式

```

docker run -d -p 6379:6379 --restart=always --name Redis \
-v /docker_data/Redis_Data/conf:/usr/local/etc/redis \
-v /docker_data/Redis_Data/data:/data \
redis redis-server /usr/local/etc/redis/redis.conf
```

```
# 参数解释
# -d: 表示以后台运行的方式启动容器
# -it: 分别表示分配一个伪终端（pseudo-TTY）并保持 STDIN 打开
# -p 6379:6379: 将主机的端口映射到容器的端口，这里是将主机的 6379 端口映射到容器的 6379 端口，用于访问 Redis 数据库
# --name Redis: 为容器指定一个名称，这里是 "Redis"
# --restart=always: 表示当容器退出时，总是重新启动容器
```

```
# 持久化解释
# -v /docker_data/Redis_Data/conf:/usr/local/etc/redis (可不映射，映射请确保配置文件准确，否则可能会启动失败)
# 将到容器中的 "/usr/local/etc/redis" 路径映射挂载到 宿主机中的"/docker_data/Redis_Data/conf"目录下,这样子做的目的是可以自定义Redis的配置文件
# -v /docker_data/Redis_Data/data:/data
# 将到容器中的 "/data" 路径映射挂载到 宿主机中的"/docker_data/Redis_Data/data"目录下,这样做的目的是将 Redis 数据库的数据存储在本地中，以便数据在容器重启时得以保留

# 关于启动命令
# redis-server /usr/local/etc/redis/redis.conf
# 容器内部执行该命令是为了按照我们自定义的配置文件启动，这个不是必须的！！！
```

### 2-7 MongoDB

镜像拉取：docker pull mongo

启动容器的方式

```
docker run -d -p 27017:27017 --restart=always --name MongoDB \
-e MONGO_INITDB_ROOT_USERNAME=mongoadmin \
-e MONGO_INITDB_ROOT_PASSWORD=abc123 \
-v /docker_data/MongoDB_Data/data:/data/db \
-v /docker_data/MongoDB_Data/conf:/etc/mongo \
mongo --config /etc/mongo/mongod.conf --wiredTigerCacheSizeGB 1.5
```

```
# 参数解释
# -d: 表示以后台运行的方式启动容器
# -it: 分别表示分配一个伪终端（pseudo-TTY）并保持 STDIN 打开
# -p 27017:27017: 将主机的端口映射到容器的端口，这里是将主机的 27017 端口映射到容器的 27017 端口，用于访问 MongoDB 数据库
# --name MongoDB: 为容器指定一个名称，这里是 "MongoDB"
# --restart=always: 表示当容器退出时，总是重新启动容器
# --config /etc/mongo/mongod.conf: 指定配置文件路径 (这个不是必须的，设置此选项之前需准备好mongod.conf文件映射到Docker内部)
# --wiredTigerCacheSizeGB 1.5: 设置WiredTiger缓存大小限制为1.5G
```

```
 持久化解释
# -v /docker_data/MongoDB_Data/conf:/etc/mongo (可不映射，映射请确保配置文件准确，否则可能会启动失败)
# 将到容器中的 "/etc/mongo" 路径映射挂载到 宿主机中的"/docker_data/MongoDB_Data/conf"目录下,这样子做的目的是可以自定义MongoDB的配置文件
# -v /docker_data/Redis_Data/data:/data
# 将到容器中的 "/data/db" 路径映射挂载到 宿主机中的"/docker_data/MongoDB_Data/data"目录下,这样做的目的是将 MongoDB 数据库的数据存储在本地中，以便数据在容器重启时得以保留

# 环境变量解释
# MONGO_INITDB_ROOT_USERNAME【可选】
# 该变量是创建管理员用户,该用户是在admin身份验证数据库中创建的,并被赋予角色root,这是一个"超级用户"角色。
# MONGO_INITDB_ROOT_PASSWORD【可选】
# 该变量是为创建管理员用户设置密码,需配合MONGO_INITDB_ROOT_USERNAME变量参数使用
```

### 2-8 Memcache

镜像拉取：docker pull memcached

启动容器的方式

```

docker run -d -p 11211:11211 --name Memcached --restart=always memcached memcached -m 64

# 参数解释
# -d: 表示以后台运行的方式启动容器
# -it: 分别表示分配一个伪终端（pseudo-TTY）并保持 STDIN 打开
# -p 11211:11211: 将主机的端口映射到容器的端口，这里是将主机的 11211 端口映射到容器的 11211 端口，用于访问 Memcached 消息队列的web管理界面
# --name Memcached: 为容器指定一个名称，这里是 "Memcached"
# --restart=always: 表示当容器退出时，总是重新启动容器

# 命令执行解释
# memcached -m 64
# 这会将 Memcached 服务器设置为使用 64 MB 进行存储
```

## 3 - 消息队列 -

### 3-1 RabbitMQ

镜像拉取：docker pull rabbitmq

启动容器的方式

```
docker run -itd -p 15672:15672 --name RabbitMQ \
--hostname rmq-test.if010.com \
-e RABBITMQ_DEFAULT_VHOST=rmq-test.if010.com \
-e RABBITMQ_DEFAULT_USER=admin \
-e RABBITMQ_DEFAULT_PASS=abc123 \
rabbitmq:3-management 
```

```
# 参数解释
# -itd: 表示以后台运行的方式启动容器,并分配一个伪终端（pseudo-TTY）和保持 STDIN 打开
# -p 15672:15672: 将主机的端口映射到容器的端口，这里是将主机的 15672 端口映射到容器的 15672 端口，用于访问 RabbitMQ 控制台页面，内部除了该端口外，还开了4369/tcp、5671-5672/tcp、15671/tcp、15691-15692/tcp、25672/tcp
# --name RabbitMQ: 为容器指定一个名称，这里是 "RabbitMQ"
# --restart=always: 表示当容器退出时，总是重新启动容器
# --hostname: 设置容器主机名称
```
```
# 环境变量解释
# RABBITMQ_DEFAULT_VHOST【可选】
该变量是可选的，是设置 RabbitMQ 的主机名称
# RABBITMQ_DEFAULT_USER【可选】
该变量是可选的，是设置 RabbitMQ 的账户
# RABBITMQ_DEFAULT_PASS【可选】
该变量是可选的，是设置 RabbitMQ 的密码
```

## 4 - 软件应用 -

### 4-1 Portainer

镜像拉取：`docker pull portainer/portainer-ee`

启动容器的方式


```
docker run -d -p 8000:8000 -p 9443:9443 --name Portainer \
--restart=always \
-v /var/run/docker.sock:/var/run/docker.sock \
-v /docker_data/Portainer_data:/data \
portainer/portainer-ee:latest
```

### 4-2 Gitlab

镜像拉取：docker pull gitlab/gitlab-ce

启动容器的方式

```

docker run -d --name GitLab \
--hostname gitlab.if010.com \
--publish 8443:443 --publish 8081:80 -p 2222:22 \
--restart always \
--volume /docker_data/GitLab_data/config:/etc/gitlab \
--volume /docker_data/GitLab_data/logs:/var/log/gitlab \
--volume /docker_data/GitLab_data/data:/var/opt/gitlab \
-v /etc/localtime:/etc/localtime \
--shm-size 256m \
gitlab/gitlab-ce:latest
```