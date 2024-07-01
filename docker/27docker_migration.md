# Docker容器跨服务器迁移步骤

## 1、需求背景

云服务器A马上就过期了，上面部署了很多docker容器，需要将其迁移到云服务器B，后续通过B服务器进行访问。

## 2、操作步骤

1、在A服务器上,使用docker save命令将`xxx/pandora`容器保存为文件:

```
docker save -o xxx-pandora.tar xxx/pandora
```

 2、将生成的`xxx-pandora.tar`文件复制到B服务器上,可以使用scp命令或者其他文件传输方式。


3、在B服务器上加载该镜像文件。

```
docker load -i xxx-pandora.tar
```

4、在B服务器启动容器,并使用与源服务器相同的挂载和端口映射选项:

将容器内8899端口映射到主机的18899端口

```
docker run  -e PANDORA_CLOUD=cloud -e PANDORA_SERVER=0.0.0.0:8899 -p 18899:8899 -d xxx/pandora
```

5、检查目标服务器上新的容器是否运行正常。

```

[root@YLMS ~]# docker ps
CONTAINER ID   IMAGE                        COMMAND                  CREATED        STATUS                 PORTS                                                                                                                                                  NAMES
b5d7f4745f45   zhayujie/chatgpt-on-wechat   "/entrypoint.sh"         40 hours ago   Up 40 hours                                                                                                                                                                   chatgpt-on-wechat
2993a4e55540   yidadaa/chatgpt-next-web     "docker-entrypoint.s…"   8 days ago     Up 8 days              0.0.0.0:3000->3000/tcp, :::3000->3000/tcp                                                                                                              goofy_feynman
8b540c459ef8   jumpserver/web:v3.10.4       "/docker-entrypoint.…"   7 weeks ago    Up 3 weeks (healthy)   80/tcp, 0.0.0.0:8790->8790/tcp, :::8790->8790/tcp                                                                                                      jms_web
8a2691cc801a   jumpserver/redis:6.2         "docker-entrypoint.s…"   7 weeks ago    Up 3 weeks (healthy)   6379/tcp                                                                                                                                               jms_redis
89418d78b232   jumpserver/kael:v3.10.4      "./entrypoint.sh"        7 weeks ago    Up 3 weeks (healthy)   8083/tcp                                                                                                                                               jms_kael
f5370fe2fe28   jumpserver/lion:v3.10.4      "./entrypoint.sh"        7 weeks ago    Up 3 weeks (healthy)   4822/tcp, 8081/tcp                                                                                                                                     jms_lion
5bdd5d5e88c0   jumpserver/koko:v3.10.4      "./entrypoint.sh"        7 weeks ago    Up 3 weeks (healthy)   0.0.0.0:2222->2222/tcp, :::2222->2222/tcp, 5000/tcp                                                                                                    jms_koko
08b894ce83bc   jumpserver/mariadb:10.6      "docker-entrypoint.s…"   7 weeks ago    Up 3 weeks (healthy)   3306/tcp                                                                                                                                               jms_mysql
c26c065c9d45   jumpserver/chen:v3.10.4      "./entrypoint.sh"        7 weeks ago    Up 3 weeks (healthy)   8082/tcp                                                                                                                                               jms_chen
da7ea72b6129   jumpserver/core-ce:v3.10.4   "./entrypoint.sh sta…"   7 weeks ago    Up 3 weeks (healthy)   8080/tcp                                                                                                                                               jms_celery
7fbed9e689a2   jumpserver/core-ce:v3.10.4   "./entrypoint.sh sta…"   7 weeks ago    Up 3 weeks (healthy)   8080/tcp                                                                                                                                               jms_core
061160c6bec9   jumpserver/magnus:v3.10.4    "./entrypoint.sh"        7 weeks ago    Up 3 weeks (healthy)   8088/tcp, 14330/tcp, 0.0.0.0:33061-33062->33061-33062/tcp, :::33061-33062->33061-33062/tcp, 54320/tcp, 0.0.0.0:63790->63790/tcp, :::63790->63790/tcp   jms_magnus
c0a792328b3a   influxdb:1.8                 "/entrypoint.sh infl…"   9 months ago   Up 4 days              0.0.0.0:31531->8086/tcp, :::31531->8086/tcp                                                                                                            influxdb1.8
5fef32af966f   mysql:8.0.15                 "docker-entrypoint.s…"   9 months ago   Up 3 weeks             33060/tcp, 0.0.0.0:18954->3306/tcp, :::18954->3306/tcp                                                                                                 mysqlserver
112f45563a0c   tancloud/hertzbeat:latest    "./bin/entrypoint.sh…"   9 months ago   Up 3 days              22/tcp, 0.0.0.0:45606->1157/tcp, :::45606->1157/tcp                                                                                                    ylcloud
```








