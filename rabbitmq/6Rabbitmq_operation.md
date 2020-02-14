# rabbitmq常见运维命令和问题总结

## 常见`rabbitmq server`命令：

```
service rabbitmq-server   start
service rabbitmq-server   stop
service rabbitmq-server   status
service rabbitmq-server   rotate-logs|
service rabbitmq-server   restart
service rabbitmq-server   condrestart
service rabbitmq-server   try-restart
service rabbitmq-server   reload
service rabbitmq-server   force-reload

ps -ef | grep rabbitmq  查看rabbitMq进程

kill -9 pid

netstat -anplt | grep LISTEN  rabbitmq默认监听端口15672/5672
```
```
$ service rabbitmq-server   status
Redirecting to /bin/systemctl status rabbitmq-server.service
● rabbitmq-server.service - RabbitMQ broker
   Loaded: loaded (/usr/lib/systemd/system/rabbitmq-server.service; enabled; vendor preset: disabled)
   Active: active (running) since Fri 2020-02-14 04:37:47 UTC; 5h 21min ago
 Main PID: 12582 (beam.smp)
   Status: "Initialized"
   CGroup: /system.slice/rabbitmq-server.service
           ├─12582 /usr/lib64/erlang/erts-10.6.4/bin/beam.smp -W w -A 64 -MBas ageffcbf -MHas ageffcbf -MBlm...
           ├─12760 /usr/lib64/erlang/erts-10.6.4/bin/epmd -daemon
           ├─12902 erl_child_setup 32768
           ├─12925 inet_gethost 4
           └─12926 inet_gethost 4
```

## rabbitmq 配置

一般情况下，`RabbitMQ`的默认配置就足够了。如果希望特殊设置的话，有两个途径：

* 一个是环境变量的配置文件 `rabbitmq-env.conf` ；
* 一个是配置信息的配置文件 `rabbitmq.config`；

**注意，这两个文件默认是没有的，如果需要必须自己创建。
`rabbitmq-env.conf`**


这个文件的位置是确定和不能改变的，位于：`/etc/rabbitmq`目录下（这个目录需要自己创建）。

文件的内容包括了RabbitMQ的一些环境变量，常用的有：

```
#RABBITMQ_NODE_PORT=    //端口号
#HOSTNAME=
RABBITMQ_NODENAME=mq
RABBITMQ_CONFIG_FILE=        //配置文件的路径
RABBITMQ_MNESIA_BASE=/rabbitmq/data        //需要使用的MNESIA数据库的路径
RABBITMQ_LOG_BASE=/rabbitmq/log        //log的路径
RABBITMQ_PLUGINS_DIR=/rabbitmq/plugins    //插件的路径
```

具体的列表见：http://www.rabbitmq.com/configure.html#define-environment-variables


## RabbitMQ cluster 基本运维操作

**rabbitmq集群必要条件**

绑定实体`ip`，即`ifconfig`所能查询到的绑定到网卡上的ip,以下是绑定方法

```
#编辑配置路径 /etc/rabbitmq/rabbitmq-env.conf
NODE_IP_ADDRESS=172.16.136.133
```
### 配置域名映射到实体ip

```
#配置文件1所在路径 /etc/rabbitmq/rabbitmq.config (如果是集群，每台机器都需要修改这个绑定本机实体ip)
#其中rabbit@master是创建集群时所配置的参数，@后面的参数为主机名，示例中为master
[
    {rabbit, [
    {cluster_nodes, {['rabbit@master'], disc}},
    {cluster_partition_handling, ignore},
    {default_user, <<"guest">>},
    {default_pass, <<"guest">>},
    {tcp_listen_options, [binary,
        {packet, raw},
        {reuseaddr, true},
        {backlog, 128},
        {nodelay, true},
        {exit_on_close, false},
        {keepalive, true}]}
    ]},
    {kernel, [
        {inet_dist_listen_max, 44001},
        {inet_dist_listen_min, 44001}
    ]}
].
```

配置文件2 所在路径 `/etc/hosts` (如果是集群，每台机器都需要修改这个绑定本机实体ip，而且`hosts`文件的映射不得重复，如果重复linux系统为以最下面一条记录为准)

```
172.16.136.133 master
172.16.136.134 venus
172.16.136.135 venus2
```

### 启动停止

* **停止**

```
#机器A
service rabbitmq-server stop
epmd -kill
#机器B
service rabbitmq-server stop
epmd -kill
#机器C
service rabbitmq-server stop
epmd -kill
```

* **启动**

方式1

```
#机器A
service rabbitmq-server start
#机器B
service rabbitmq-server start
#机器C
service rabbitmq-server start
```

方式2

```
rabbitmq-server -detached
```

##  集群重启顺序

> 此处的mq集群重建是比较快速和有效的方法，面向的是初次安装或者可以接受mq中所存有的数据丢失的情况下，必须先有`mq`的`.json`后缀的配置文件或者有把握写入集群中exchange、queue等配置。

<mark>**集群重启的顺序是固定的，并且是相反的**</mark>。 如下所述：

**启动顺序：**

* <mark>磁盘节点 => 内存节点 </mark>

**关闭顺序：**

* <mark>内存节点 => 磁盘节点 最后关闭必须是磁盘节点，不然可能回造成集群启动失败、数据丢失等异常情况。</mark>

### 重建集群

**按顺序停止所有机器中的`rabbitmq`**

```
#机器A
service rabbitmq-server stop
epmd -kill
#机器B
service rabbitmq-server stop
epmd -kill
#机器C
service rabbitmq-server stop
epmd -kill
```

### 按顺序停止所有机器中的rabbitmq

```
#机器C
service rabbitmq-server start
#机器B
service rabbitmq-server start
#机器A
service rabbitmq-server start
```

### 停止被加入集群节点app

> 比如A、B、C三台机器，将B和C加入到A中去，需要执行以下命令

```
#机器B
rabbitmqctl stop_app
#机器C
rabbitmqctl stop_app
```

### 建立集群

> 注意此处master为唯一没有执行`rabbitmqctl stop_app`的机器

```
#机器B
rabbitmqctl join_cluster rabbit@master
#机器C
rabbitmqctl join_cluster rabbit@master
```

### 启动集群

```
#机器B
rabbitmqctl start_app
#机器C
rabbitmqctl start_app
```

### 检查集群状态

在任意一台机器上执行`rabbitmqctl cluster_status`命令即可检查，输出包含集群中的节点与运行中的节点，兼以主机名标志


## 添加集群配置

### 创建用户

> 例子中创建了两个用户 添加用户`add_user`,设置角色`set_user_tags` ,添加`rabbitmq`虚拟主机`add_vhost`，设置访问权限`set_permissions,`以下是详细用法

```
# 创建第一个用户
/usr/sbin/rabbitmqctl add_user 用户名 密码
/usr/sbin/rabbitmqctl set_user_tags 用户名 administrator
/usr/sbin/rabbitmqctl set_permissions -p /  用户名 ".*" ".*" ".*"
# 创建第二个用户
/usr/sbin/rabbitmqctl add_user 用户名2 密码
/usr/sbin/rabbitmqctl set_user_tags 用户名2 management 
/usr/sbin/rabbitmqctl add_vhost sip_ext 
/usr/sbin/rabbitmqctl set_permissions -p sip_ext 用户名2 '.*' '.*' '.*'
```


* 备注：RabbitMQ 虚拟主机，RabbitMQ 通过虚拟主机（vhost）来分发消息。拥有自己独立的权限控制，不同的vhost之间是隔离的，单独的。
* 权限控制的基本单位：`vhost`。
* 用户只能访问与之绑定的`vhost`。
* `vhost`是`AMQP`中唯一无法通过协议来创建的基元。只能通过`rabbitmqctl`工具来创建。 

### 打开15672网页管理端，访问mq

```
/usr/sbin/rabbitmq-plugins enable rabbitmq_management 
```

备注：如果发现命令执行完毕没有打开此服务，`15672`端口没有监听，则是由于没有重启mq导致的

如果覆盖了用户需要使用以下命令修改mq用户密码 `/usr/sbin/rabbitmqctl change_password ` 用户名 密码

### 修改节点类型

```
rabbitmqctl stop_app
 
rabbitmqctl change_cluster_node_type dist
 
rabbitmqctl change_cluster_node_type ram
 
rabbitmqctl start_app
```

[**常用命令**](4Rabbitmq_ctl.md)


## 常见故障

* **集群状态异常**
	* `rabbitmqctl cluster_status`检查集群健康状态，不正常节点重新加入集群
	* 分析是否节点挂掉，手动启动节点。
	* 保证网络连通正常

* **队列阻塞、数据堆积**
	* 保证网络连通正常
	* 保证消费者正常消费，消费速度大于生产速度
	* 保证服务器TCP连接限制合理
* **脑裂**
	* 按正确顺序重启集群
	* 保证网络连通正常
	* 保证磁盘空间、cpu、内存足够

 