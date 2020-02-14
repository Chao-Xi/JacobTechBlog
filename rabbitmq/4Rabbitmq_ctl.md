# RabbitMQ手册之rabbitmqctl

## Server Status

> 服务状态查询语句，询问服务之后，将返回tab分隔的一组列项结果。一些查询语句（例如 `list_queues`, `list_exchanges`, `list_bindings`, `list_consumers`）接受一个可选的`vhost`参数。该参数（如果存在），必须在查询之后立即指定。

```
rabbitmqctl list_queues [-p vhost] [[--offline] | [--online] | [--local]] [queueinfoitem ...]
# 返回队列的详细信息。如果 "-p" 标志不存在，那么将返回默认虚拟主机的队列详细信息。"-p" 可以用来覆盖默认vhost。可以使用一下互斥选项之一，通过其状态或者位置过滤显示的队列。
# [--offline] 表示仅仅列出当前不可用的持久队列（更具体地说，他们的主节点不是）
# [--online] 表示列出当前可用的队列（他们的主节点是）
# [--local] 表示仅仅列出那些主程序在当前节点上的队列
# queueinfoitem参数用于指示要包括在结果中的哪些队列信息项。结果中的列顺序将与参数的顺序相匹配。queueinfoitem可以从以下列表中获取任何值：
# name 表示队列的名称
# durable 表示服务器重启之后，队列是否存活
# auto_delete 表示不再使用的队列是否自动被删除
# arguments 表示队列的参数
# policy 表示应用在队列中的策略名称
# pid 表示和队列相关联的Erlang进程的ID
# owner_pid 表示作为队列的排他所有者的连接的Erlang进程的ID，如果队列是非排他，则为空
# exclusive 表示队列是否是排他的，有 owner_pid 返回 True，否则返回 False
# exclusive_consumer_pid 表示排他消费者订阅该队列的频道的Erlang进程的ID，如果没有独家消费者，则为空
# exclusive_consumer_tag 表示订阅该队列的排他消费者的消费tag。如果没有排他消费者，则为空
# messages_ready 表示准备被发送到客户端的消息数量
# messages_unacknowledged 表示已经被发送到客户端但是还没有被确认的消息数量
# messages 表示准备发送和没有被确认的消息数量总和（队列深度）
# messages_ready_ram 表示驻留在 ram 里的 messages_ready 的消息数量
# messages_unacknowledged_ram 表示驻留在 ram 里的 messages_unacknowledged 的消息数量
# messages_ram 表示驻留在 ram 里的消息总数
# messages_persistent 表示队列中持久消息的总数（对于临时队列，总是为0）
# message_bytes 表示在队列中所有消息body的大小，这并不包括消息属性（包括header）或者任何开销
# message_bytes_ready 表示类似于 messge_bytes 但仅仅计算那些将发送到客户端的消息
# message_bytes_unacknowledged 表示类似于 message_bytes 但仅仅计算那些已经发送到客户还没有确认的消息
# message_bytes_ram 表示类似于 message_bytes 但仅仅计算那些驻留在ram中的消息
# message_bytes_persistent 表示类似于 message_bytes 但仅仅计算那些持久消息
# head_message_timestamp 表示队列中第一个消息的时间戳属性（如果存在）。只有处在 paged-in 状态的消息才存在时间戳。
# disk_reads 表示该队列自start起，从磁盘读取消息的次数总和
# disk_writes 表示该队列自start起，被写入磁盘消息的次数总和
# consumers 表示consumer的数量
# consumer_utilisation 表示队列能够立即将消息传递给消费者的时间分数（0.0 ~ 1.0之间），如果消费者受到网络拥塞或者预取计数的限制，该值可能小于1.0
# memory 表示和该队列相关联的Erlang进程消耗的内存字节数，包括stack/heap/内部数据结构
# slave_pids 表示该队列目前的slave的ID号（如果该队列被镜像的话）
# synchronised_slave_pids 表示如果队列被镜像，给出与主队列同步的当前slave的ID号，即可以从主队列接管而不丢失消息的slave的ID
# state 表示队列的状态，一般是 "running"； 如果队列正在同步，也可能是 "{syncing, MsgCount}"； 如果队列所处的节点当前down了，队列显示的状态为 "down"
# 如果没有指定queueinfoitem，那么将显示队列的名称（name）和深度（messages）


rabbitmqctl list_exchanges [-p vhost] [exchangeinfoitem ...]
# 返回交换器的详细信息。如果 "-p" 标志不存在，那么将返回默认虚拟主机的交换器详细信息。"-p" 可以用来覆盖默认vhost。
# exchangeinfoitem参数用于指示要包括在结果中的哪些交换器信息项。结果中的列顺序将与参数的顺序相匹配。exchangeinfoitem可以从以下列表中获取任何值：
# name 表示交换器的名称
# type 表示交换器类型（例如： direct/topic/fanout/headers）
# durable 表示服务器重启之后，交换器是否存活
# auto_delete 表示交换器不再使用时，是否被自动删除
# internal 表示交换器是否是内部的，例如不能被客户端直接发布
# arguments 表示交换器的参数
# policy 表示引用在该交换器上的策略名称
# 如果没有指定任何 exchangeinfoitem，那么该命令将显示交换器的名称（name）和类型（type）


rabbitmqctl list_bindings [-p vhost] [bindinginfoitem ...]
# 返回绑定的详细信息。如果 "-p" 标志不存在，那么将返回默认虚拟主机的绑定详细信息。"-p" 可以用来覆盖默认vhost。
# bindinginfoitem参数用于指示要包括在结果中的哪些绑定信息项。结果中的列顺序将与参数的顺序相匹配。bindinginfoitem可以从以下列表中获取任何值：
# source_name 表示绑定附加到的消息源的名称
# source_kind 表示绑定附加到的消息源的类型，目前通常交换器
# destination_name 表示附加绑定到的消息目的地的名称
# destination_kind 表示附加绑定到的消息目的地的类型
# routing_key 表示绑定的routing key
# arguments 表示绑定的参数
# 如果没有指定任何的 bindinginfoitem ，那么将展示上述所有的参数
# rabbitmqctl list_bindings -p /myvhost exchange_name queue_name
# 上述命令，表示展示在 /myvhost 虚拟主机中的绑定的exchange名称和queue名称


rabbitmqctl list_connections [connectioninfoitem ...]
# 返回TCP/IP连接统计信息
# connectioninfoitem 参数用于指示要包括在结果中的哪些连接信息项，结果中的列顺序将与参数的顺序相匹配。connectioninfoitem可以从以下列表中获取任何值：
# pid 表示与该connection相关联的Erlang进程的id号
# name 表示该连接的可读性名称
# port 表示服务端口
# host 表示通过反向DNS获取的服务器主机名，如果反向DNS失败或未启用，则为其IP地址
# peer_port 表示对等端口
# peer_host 表示通过反向DNS获取的对等主机名，如果反向DNS失败或未启用，则为其IP地址
# ssl 表示该连接是否使用SSL保护的bool值
# ssl_protocal 表示SSL协议(例如： tlsv1)
# ssl_key_exchange 表示SSL关键交换器算法（例如： rsa）
# ssl_cipher 表示SSL密码算法（例如： aes_256_cbc）
# ssl_hash 表示SSL哈希函数（例如： sha）
# peer_cert_issuer 表示对等体的SSL证书的颁发者，以RFC4514形式出现
# peer_cert_validity 表示对等体的SSL证书的有效期限
# state 表示连接状态（例如： starting/tuning/opening/running/flow/blocking/blocked/closing/closed）
# channels 表示正在使用连接的通道数量
# protocol 表示正在使用的AMQP的版本号。注意，如果一个客户端需要一个AMQP 0-9 连接，我们将其作为 AMQP 0-9-1
# auth_mechanism 表示使用SASL认证机制，如PLAN
# user 表示和该连接相关联的用户名
# vhost 表示vhost名称
# timeout 表示连接超时/协商心跳间隔，单位为秒
# frame_max 表示最大的frame大小（byte）
# channel_max 表示该连接上通道的最大数量
# client_properties 表示在连接建立期间，有客户端传送的消息属性
# recv_oct 表示接受到的八位字节
# recv_cnt 表示接受到的包
# send_oct 表示发送的八位字节
# send_cnt 表示发送的包
# send_pend 表示发送的队列大小
# connected_at 表示该连接被建立的日期和时间的时间戳格式
# 如果没有指定任何connectioninfoitem，那么将展示：user/peer_host/peer_port/流量控制和内存块状态之后的时间


rabbitmqctl list_channels [channelinfoitem ...]
# 返回所有当前的通道的信息，通道即一个执行大多数AMQP命令的逻辑容器。这包括由普通AMQP连接的一部分通道、由各种插件和其他扩展程序创建的通道。
# channelinfoitem 参数用于指示要包括在结果中的哪些连接信息项，结果中的列顺序将与参数的顺序相匹配。channelinfoitem 可以从以下列表中获取任何值：
# pid 表示与该连接相关联的Erlang程序的ID号
# connection 表示与通道所属连接相关联的Erlang进程的ID号
# name 表示通道的可读性名称
# number 表示通道的号码，在连接中唯一表示它
# user 表示和该通道相关联的用户名
# vhost 表示通道操作所在的vhost
# transactional 表示通道是否处于事务模式，返回 true，否则返回 false
# confirm 表示通道是否处于确认模式，返回 true, 否则返回 false
# consumer_count 表示通过通道检索消息的逻辑AMQP消费者数量
# messages_unacknowledged 表示通过通道发送过但还没收到反馈的消息的数量
# messages_uncommitted 表示尚未提交的事务中接受的消息数
# acks_uncommitted 表示尚未提交的事务中接受的确认数
# messages_unconfirmed 表示尚未确认已发布的消息数量。在不处于确认模式中的通道上，该值为0
# prefetch_count 表示新消费者的QoS预取限制，如果没有限制则为0
# global_prefetch_count 表示整个通道的QoS预取限制，如果没有限制则为0
# 如果没有指定任何 channelinfoitem 项，那么将展示 pid/user/consumer_count/messages_unacknowledged


rabbitmqctl list_consumers [-p vhost]
# 列出消费者，例如对一个队列的消息流的订阅者。每一行用tab字符分隔：
# 订阅的队列名称、创建和管理订阅的通道id、在通道中唯一标识订阅的消费者tag、消息传输到订阅者之后是否需要确认的bool值、代表预取限制的整数（0表示none）、订阅者的其他参数


rabbitmqctl status
# 展示broker的状态信息，例如在当前Erlang节点上正在运行的应用、RabbitMQ和Erlang版本号、OS名称、内存和文件描述统计信息


rabbitmqctl node_health_check
# RabbitMQ节点的健康检查，验证 Rabbit 应用正在运行，list_queues和list_channels返回，警告没有被设置
# rabbitmqctl node_health_check -n rabbit@stringer
# 上述例子，表示对RabbitMQ节点进行健康检查


rabbitmqctl environment
# 在每个正在运行的应用程序的应用程序环境中，显示每个变量的名称和值


rabbitmqctl report
# 生成服务器状态报告，其中包括用于支持目的的所有服务器状态信息的并置。当伴随支持请求时，输出应该被重定向到一个文件
# rabbitmqctl report > server_report.txt


rabbitmqctl eval {expr}
# 评估一个任务Erlang表达式
# rabbitmqctl eval 'node().'
# 上述例子，将返回 rabbitmqctl 已经连接的节点名称
```

### 返回队列的详细信息

```
$  sudo rabbitmqctl list_queues
Timeout: 60.0 seconds ...
Listing queues for vhost / ...
name	messages
hello	0

# 表示consumer的数量
$  sudo rabbitmqctl list_queues consumers
Timeout: 60.0 seconds ...
Listing queues for vhost / ...
consumers
1
```

### 返回交换器的详细信息

```
$ sudo rabbitmqctl list_exchanges
Listing exchanges for vhost / ...
name	type
amq.direct	direct
amq.match	headers
amq.fanout	fanout
	direct
amq.topic	topic
amq.rabbitmq.trace	topic
amq.headers	headers
```

### 返回绑定的详细信息

```
$ sudo rabbitmqctl list_bindings
Listing bindings for vhost /...
source_name	source_kind	destination_name	destination_kind	routing_key	arguments
	exchange	hello	queue	hello	[]
```

### 返回TCP/IP连接统计信息

```
$ sudo rabbitmqctl list_connections
Listing connections ...
user	peer_host	peer_port	state
admin	192.168.33.1	52727	running
```

### 返回所有当前的通道的信息，通道即一个执行大多数AMQP命令的逻辑容器。这包括由普通AMQP连接的一部分通道、由各种插件和其他扩展程序创建的通道。

```
$ sudo rabbitmqctl list_channels
Listing channels ...
pid	user	consumer_count	messages_unacknowledged
<rabbit@jabox.3.29946.0>	admin	1	0
```

### 列出消费者，例如对一个队列的消息流的订阅者

```
$ sudo rabbitmqctl list_consumers
queue_name	channel_pid	consumer_tag	ack_required	prefetch_count	active	arguments
hello	<rabbit@jabox.3.29946.0>	ctag1.d6c95bb056e34fc98850545a0a35a024	false	1	true	[]
```

### 展示broker的状态信息，

```
$ sudo rabbitmqctl status
untime

OS PID: 12582
OS: Linux
Uptime (seconds): 15042
RabbitMQ version: 3.8.2
Node name: rabbit@jabox
Erlang configuration: Erlang/OTP 22 [erts-10.6.4] [source] [64-bit] [smp:1:1] [ds:1:1:10] [async-threads:64] [hipe]
Erlang processes: 439 used, 1048576 limit
Scheduler run queue: 1
Cluster heartbeat timeout (net_ticktime): 60

Plugins

Enabled plugin file: /etc/rabbitmq/enabled_plugins
Enabled plugins:

 * rabbitmq_management
 * rabbitmq_management_agent
 * rabbitmq_web_dispatch
 * cowboy
 * amqp_client
 * cowlib
...
```

### 表示对RabbitMQ节点进行健康检查

```
$ sudo rabbitmqctl node_health_check
Timeout: 70 seconds ...
Checking health of node rabbit@jabox ...
Health check passed
```

## 用户和用户角色
 
 ```
 # 查看用户信息
rabbitmqctl list_users
# 结果如下
Listing users ...
guest   [administrator]
...done.


# 创建新用户 rabbitmqctl add_user {username} {password}
rabbitmqctl add_user jshan 123456
# 结果如下，表示创建成功
Creating user "jshan" ...
...done.
# 再次查询结果如下
Listing users ...
guest   [administrator]
jshan   []
...done.
# 上述结果中，第一列表示用户名，第二列表示用户角色


# 为用户设置用户角色 rabbitmqctl set_user_tags {username} {role}
rabbitmqctl set_user_tags jshan monitoring
# 结果如下，表示设置成功
Setting tags for user "jshan" to [monitoring] ...
...done.
# 说明一下，执行该命令之后，会先删除该用户已有的角色，然后添加新的角色，可以填写多个角色，如果想删除某个用户的所有角色，可以设置如下：
rabbitmqctl set_user_tags {username}


# 修改用户密码 rabbitmqctl change_password {username} {newpassword}
rabbitmqctl change_password jshan 123
# 结果如下，表示修改成功
Changing password for user "jshan" ...
...done.


# 清除用户密码 rabbitmqctl clear_password {username}
rabbitmqctl clear_password jshan
# 结果如下，表示清除成功
Clearing password for user "jshan" ...
...done.
# 说明一下，执行该命令之后，用户无法对该用户使用密码登录


# 删除用户 rabbitmqctl delete_user {username}
rabbitmq delete_user jshan
# 结果如下，表示删除成功
Deleting user "jshan" ...
...done.
```
 
 ```
 $ sudo rabbitmqctl list_users
 user	tags
admin	[administrator]
guest	[administrator]
```

## 用户角色

> `rabbitmq`用户角色（`role`）分为五类： 超级管理员（`administrator`）、监控者（`monitor`）、决策制定者（`policymaker`）、普通管理者（`management`）和其他。

* `administrator` 可登录管理控制台（启用`management plugin`的情况下），查看所有的信息，并且可以对用户、策略（`policy`）进行操作；
* `monitoring` 可登录管理控制台（启用`management plugin`的情况下），同时可以查看`rabbitmq`节点的相关信息（进程数、内存使用情况，磁盘使用情况等）；
* `policymaker` 可以登录管理控制台（启用`management plugin`的情况下），同时可以对策略（`policy`）进行操作；
* `management` 仅可登录管理控制台（启用`management plugin`的情况下），无法看到节点信息，也无法对策略进行管理；
* 其他无法登录管理控制台，通常就是普通的生产者和消费者。

```
rabbitmqctl [-n {nodename}] [-t timeout] [-q] {command} [command options...]
```

## `application`和`cluster management`

```
rabbitmqctl stop [{pid_file}]
# 表示stop 在RabbitMQ服务器上运行的一个Erlang 节点，可以指定某一个 *pid_file*，表示会等待这个指定的程序结束


rabbitmqctl shutdown
# 表示终止RabbitMQ 服务器上的Erlang进程，如果终止失败，会返回非零数字


rabbitmqctl stop_app
# 表示终止RabbitMQ的应用，但是Erlang节点还在运行。该命令典型的运行在一些需要RabbitMQ应用被停止的管理行为之前，例如 reset


rabbitmqctl start_app
# 表示启动RabbitMQ的应用。该命令典型的运行在一些需要RabbitMQ应用被停止的管理行为之后，例如 reset


rabbitmqctl wait {pid_file}
# 表示等待RabbitMQ应用启动。该命令会等待指定的pid file被创建，也就是启动的进程对应的pid保存在这个文件中，然后RabbitMQ应用在这个进程中启动。如果该进程终止，没有启动RabbitMQ应用，就会返回错误。
# 合适的pid file是有rabbitmq-server 脚本创建的，默认保存在 Mnesia 目录下，可以通过修改 RABBITMQ_PID_FILE 环境变量来修改
# 例如 rabbitmqctl wait /var/run/rabbitmq/pid


rabbitmqctl reset
# 表示设置RabbitMQ节点为原始状态。会从该节点所属的cluster中都删除，从管理数据库中删除所有数据，例如配置的用户和vhost，还会删除所有的持久消息。
# 要想reset和force_reset操作执行成功，RabbitMQ应用需要处于停止状态，即执行过 stop_app


rabbitmqctl force_reset
# 表示强制性地设置RabbitMQ节点为原始状态。它和reset的区别在于，可以忽略目前管理数据库的状态和cluster的配置，无条件的reset。
# 该方法的使用，应当用在当数据库或者cluster配置损坏的情况下作为最后的方法。


rabbitmqctl rotate_logs {suffix}
# 表示将日志文件的内容追加到新的日志文件中去，这个新的日志文件的文件名是原有的日志文件名加上命令中的 suffix，并且恢复日志到原来位置的新文件中。
# 注意：如果新文件原先不存在，那么会新建一个；如果suffix为空，那么不会发生日志转移，只是重新打开了一次日志文件而已。


rabbitmqctl hipe_compile {directory}
# 表示在指定的目录下执行HiPE编译和缓存结果文件 .beam-files
# 如果需要父目录会被创建。并且在编译之前，该目录下的所有 .beam-files会被自动删除。
# 使用预编译的文件，你应该设置 RABBITMQ_SERVER_CODE_PATH 环境变量为 hipe_compile 调用指定的目录。
```

## cluster management

```
rabbitmqctl join_cluster {clusternode} [--ram]
# 表示结合到指定的集群，如果有参数 --ram 表示作为RAM节点结合到该集群中。
# 该命令指令本节结合到指定的集群中，在结合之前，该节点需要reset，所以在使用时，需要格外注意。为了成功运行本命令，必须要停止RabbitMQ应用，例如 stop_app
# 集群节点有两种类型: disc 和 RAM。disc类型，复制数据在RAM和disc上，在节点失效的情况下，提供了冗余保证，也能从一些全局事件中恢复，例如所有节点失效。RAM类型，只复制数据在RAM上，主要表现在伸缩性上，特别是在管理资源（例如：增加删除队列，交换器，或者绑定）上表现突出。
# 一个集群必须至少含有一个disc节点，当通常都多余一个。通过该命令时，默认是设置为disc节点，如果需创建RAM节点，需要指定参数 --ram
# 执行此命令之后，在该节点上启动的RabbitMQ应用，在该节点挂掉之后，会尝试连接节点所在集群中的其他节点。
# 为了离开集群，可以 reset 该节点，也可以使用命令 forget_cluster_node 远程删除节点


rabbitmqctl cluster_status
# 表示显示通过节点类型聚合在一起的集群中的所有节点，还有目前正在运行的节点


rabbitmqctl change_cluster_node_type {disc|ram}
# 表示改变集群节点的类型。该操作的正确执行，必定会停止该节点。并且在调整一个node为ram类型时，该节点不能为该集群的唯一node


rabbitmqctl forget_cluster_node [--offline]
# 表示远程移除一个集群节点。要删除的节点必须脱机，如果没有脱机，需要使用 --offline 参数。当使用 --offline 参数时，rabbitmqctl不会去连接节点，而是暂时变成节点，以便进行变更。这在节点不能正常启动时非常有用。在这种情况下，节点会成为集群元数据的规范来源（例如哪些队列存在）。因此如果可以的话，应该使用此命令在最新的节点上关闭。
# --offline 参数使节点从脱机节点上移除。使用场景主要是在所有节点脱机，且最后一个节点无法联机时，从而防止整个集群启动。在其他情况不应该使用，否则会导致不一致。
# 例如 rabbitmqctl -n hare@mcnulty forget_cluster_node  rabbit@stringer
# 上述命令将从节点 hare@mcnulty 中移除节点 rabbit@stringer


rabbitmqctl rename_cluster_node {oldnode1} {newnode1} [oldnode2] [newnode2...]
# 表示在本地数据库上修改集群节点名称。该命令让rabbitmqctl暂时成为一个节点来做出做变更。因此，本地的待修改的集群节点一定要完全停止，其他节点可以是online或者offline


rabbitmqctl update_cluster_nodes {clusternode}
# 表示指示已经集群的节点在唤醒时联系 {clusternode} 进行集群。这与 join_cluster 命令不同，因为它不加入任何集群，它是检查节点是否已经在具有 {clusternode} 的集群中。
# 该命令的需求，是在当一个节点offline时，修改了集群节点的情形下。例如：节点A和B聚群，节点A offline了，节点C和B集群，并且B节点离开了该集群，那么当节点A起来的时候，A会尝试连接B，但是由于B节点已经不在该集群中，所以会失败。
# 通过 update_cluster_nodes -n A C 将会解决上述问题。


rabbitmqctl force_boot
# 表示强制确保节点启动，即使该节点并不是最后down的。
# 一般情况下，当你同时shut down了RabbitMQ集群时，第一个重启的节点应该是最后一个down掉的，因为它可能已经看到了其他节点发生的事情。但是有时候这并不可能：例如当整个集群lose power，那么该集群的所有节点会认为他们不是最后一个关闭的。
# 如果最后down的节点永久的lost，那么应该优先使用 rabbitmqctl forget_cluster_node --offline ，因为这将确保在丢失节点上的镜像队列得到优先处理。


rabbitmqctl sync_queue [-p vhost] {queue}
# {queue} 表示待同步的队列名称
# 指引含有异步slaves的镜像队列去同步自身。当队列执行同步化时，其将会被锁定（指所有publishers发送出去的和consumers获取到的队列都会被锁定）。为了成功执行此命令，队列必须要被镜像。
# 注意，排除消息的异步队列将最终被同步化，此命令主要运用于未被排除完全消息的队列。


rabbitmqctl cancel_sync_queue [-p vhost] {queue}
# 指引一个正在同步的镜像队列停止此操作。


rabbitmqctl purge_queue [-p vhost] {queue}
# {queue} 表示待清空消息的队列名称
# 该命令表示清空队列（即删除队列中的所有消息）


rabbitmqctl set_cluster_name {name}
# 设置集群的名称。在连接中，集群的名称被声明在客户端上，被同盟和插件用来记录一个消息所在的位置。集群的名称默认来自于集群中第一个节点的主机名，但是可以被修改。
```

```
$ sudo rabbitmqctl cluster_status
Basics

Cluster name: rabbit@jabox

Disk Nodes

rabbit@jabox

Running Nodes

rabbit@jabox

Versions

rabbit@jabox: RabbitMQ 3.8.2 on Erlang 22.2.6

Alarms

(none)

Network Partitions

(none)

Listeners

Node: rabbit@jabox, interface: [::], port: 25672, protocol: clustering, purpose: inter-node and CLI tool communication
Node: rabbit@jabox, interface: [::], port: 5672, protocol: amqp, purpose: AMQP 0-9-1 and AMQP 1.0
Node: rabbit@jabox, interface: [::], port: 15672, protocol: http, purpose: HTTP API

Feature flags

Flag: drop_unroutable_metric, state: disabled
Flag: empty_basic_get_metric, state: disabled
Flag: implicit_default_bindings, state: enabled
Flag: quorum_queue, state: enabled
Flag: virtual_host_metadata, state: enabled
```

## User management

> 注意，`rabbitmqctl` 管理 `RabbitMQ` 的内部用户数据库，所有其他后台需要认证的用户对于`rabbitmqctl`将不可见。

```
rabbitmqctl add_user {username} {password}
# {username} 表示用户名； ｛password｝表示用户密码
# 该命令将创建一个 non-administrative 用户


rabbitmqctl delete_user {username}
# 表示删除一个用户，该命令将指示RabbitMQ broker去删除指定的用户


rabbitmqctl change_password {username} {newpassword}
# 表示修改指定的用户的密码


rabbitmqctl clear_password {username}
# 表示清除指定用户的密码
# 执行此操作后的用户，将不能用密码登录，但是可能通过已经配置的SASL EXTERNAL的方式登录。


rabbitmqctl authenticate_user {username} {password}
# 表示指引RabbitMQ broker认证该用户和密码


rabbitmqctl set_user_tags {username} {tag ...}
# 表示设置用户的角色，｛tag｝可以是零个，一个，或者是多个。并且已经存在的tag也将会被移除。
# rabbitmqctl set_user_tags tonyg administrator 该命令表示指示RabbitMQ broker确保用户tonyg为一个管理员角色。
# 上述命令在用户通过AMQP方式登录时，不会有任何影响；但是如果通过其他方式，例如管理插件方式登录时，就可以去管理用户、vhost 和权限。


rabbitmqctl list_users
# 表示列出所有用户名信息
```

```
$ sudo rabbitmqctl list_users
user	tags
admin	[administrator]
guest	[administrator]
```

## Access control

> 注意，`rabbitmqctl` 管理 `RabbitMQ` 的内部用户数据库，所有其他后台需要认证的用户的权限对于`rabbitmqctl`将不可见。

```
rabbitmqctl add_vhost {vhost}
# ｛vhost｝ 表示待创建的虚拟主机项的名称


rabbitmqctl delete_vhost {vhost}
# 表示删除一个vhost。删除一个vhost将会删除该vhost的所有exchange、queue、binding、用户权限、参数和策略。


rabbitmqctl list_vhosts {vhostinfoitem ...}
# 表示列出所有的vhost。其中 {vhostinfoitem} 表示要展示的vhost的字段信息，展示的结果将按照 {vhostinfoitem} 指定的字段顺序展示。这些字段包括： name（名称） 和 tracing （是否为此vhost启动跟踪）。
# 如果没有指定具体的字段项，那么将展示vhost的名称。


rabbitmqctl set_permissions [-p vhost] {user} {conf} {write} {read}
# 表示设置用户权限。 {vhost} 表示待授权用户访问的vhost名称，默认为 "/"； {user} 表示待授权反问特定vhost的用户名称； {conf}表示待授权用户的配置权限，是一个匹配资源名称的正则表达式； {write} 表示待授权用户的写权限，是一个匹配资源名称的正则表达式； {read}表示待授权用户的读权限，是一个资源名称的正则表达式。
# rabbitmqctl set_permissions -p myvhost tonyg "^tonyg-.*" ".*" ".*"
# 例如上面例子，表示授权给用户 "tonyg" 在vhost为 `myvhost` 下有资源名称以 "tonyg-" 开头的 配置权限；所有资源的写权限和读权限。


rabbitmqctl clear_permissions [-p vhost] {username}
# 表示设置用户拒绝访问指定指定的vhost，vhost默认值为 "/"


rabbitmqctl list_permissions [-p vhost]
# 表示列出具有权限访问指定vhost的所有用户、对vhost中的资源具有的操作权限。默认vhost为 "/"。
# 注意，空字符串表示没有任何权限。


rabbitmqctl list_user_permissions {username}
# 表示列出指定用户的权限vhost，和在该vhost上的资源可操作权限。
```

### 默认vhost为 "/"。

```
$ sudo rabbitmqctl list_vhosts
Listing vhosts ...
name
/
```

```
$ sudo rabbitmqctl list_permissions
Listing permissions for vhost "/" ...
user	configure	write	read
admin	.*	.*	.*
guest	.*	.*	.*
```

```
$ sudo rabbitmqctl list_user_permissions admin
Listing permissions for user "admin" ...
vhost	configure	write	read
/	.*	.*	.*
```

## Parameter Management

>  `RabbitMQ`的一些特性（例如联合插件）是被动态的、集群范围内的参数控制。
> 
> 有两类参数：属于`vhost`的参数和全局参数。
> 
> 一个属于`vhost`的参数由三部分组成： 组件名称，参数名称和值。其中组件名称和名称是字符串，值是一个`Erlang`项。
> 
> 一个全局参数由两部分组成： 参数名称和值。其中名称是字符串，值是一个`Erlang`项。参数可以被设置，删除，列出。参数的具体设置方法如下：

```
rabbitmqctl set_parameter [-p vhost] {component_name} {name} {value}
# 设置参数，｛component_name｝表示待设置参数的组件名称，{name} 表示待设置的参数名称，｛value｝表示待设置的参数值，是一个JSON项，在多数shell中，你很有可能要应用该值
# rabbitmqctl set_parameter federation local_username '"guest"'
# 上述例子，表示设置默认vhost即 "/" 的 federation 组件的参数 local_username 的值设置为JSON项 "guest"


rabbitmqctl clear_parameter [-p vhost] {component_name} {key}
# 表示清理一个参数，｛component_name｝表示待清理的组件名称，｛key｝表示待清理的参数名称
# rabbitmqctl clear_parameter federation local_username
# 上述例子表示清理默认vhost上的组件 federation 的参数 local_username


rabbitmqctl list_parameters [-p vhost]
# 表示列举出指定的vhost上的所有参数


rabbitmqctl set_global_parameter {name} {value}
# 设置一个全局运行时的变量，有些类似于 set_parameter ，但是此 key-value 对并不绑定于vhost。 
# rabbitmqctl set_global_parameter mqtt_default_vhosts '{"O=client,CN=guest":"/"}'
# 上述例子，设置一个全局运行时的参数 mqtt_default_vhosts 的值为一个JSON项， {"O=client,CN=guest":"/"}


rabbitmqctl clear_global_parameter {name}
# 清除一个全局运行时参数，类似于 clear_parameter，但是此 key-value 对并不绑定于vhost。
# rabbitmqctl clear_global_parameter mqtt_default_vhosts
# 上述例子，清除一个全局运行时参数 mqtt_default_vhosts


rabbitmqctl list_global_parameters
# 列出所有的全局运行时参数，类似于 list_parameters，但是该命令不绑定于任何vhost
```

### 列出所有的全局运行时参数，类似于 list_parameters，但是该命令不绑定于任何vhost

```
$ sudo rabbitmqctl list_global_parameters

Listing global runtime parameters ...
name	value
cluster_name	"rabbit@jabox"
```

## Policy Management

>  策略用于在集群范围内，控制和修改队列和交换器的行为。适用于给定固定虚拟机，并由名称，模式，定义和可选优先级组成。可以设置，清除和列出策略

```
rabbitmqctl set_policy [-p vhost] [--priority priority] [--apply-to apply-to] {name} {pattern} {definition}
# {name} 表示策略名称；
# {pattern} 表示当匹配到给定资源的正则表达式，使的该策略得以应用； 
# {definition} 表示策略的定义，作为一个JSON项，在多数shell中，你很可能需要去应用它
# {priority} 表示策略的优先级的整数，数据越大表示优先级越高，默认值为0
# {apply_to} 表示策略应该应用的类型： queues/exchange/all，默认值是 all


rabbitmqctl clear_policy [-p vhost] {name}
# 表示清理一个策略。 {name} 表示待清理的策略名称


rabbitmqctl list_policies [-p vhost]
# 表示列举出给定的vhost的所有策略信息
```

```
$ sudo rabbitmqctl list_policies -p /
```

## Miscellaneous

> rabbitmqctl 其他的一些命令

```
rabbitmqctl close_connection {connectionpid} {explanation}
# {connectionpid} 表示待关闭连接的Erlang进程的ID号
# {explanation} 表示解释字符串
# 指引broker去关闭与ID为 {connectionid} Erlang进程相关联的连接，作为AMQP连接关闭协议的一部分，它也会向连接的客户端传递 {explanation} 字符串
# rabbitmqctl close_connection "<rabbit@tanto.4262.0>" "go away"
# 上述例子，表示关闭与ID号为 "<rabbit@tanto.4262.0>" 的Erlang进程相关联的连接，并向连接的客户端传输解释性语句 "go away"。


rabbitmqctl trace_on [-p vhost]
# vhost 表示要启动跟踪的虚拟机名称
# 开始跟踪。注意，跟踪状态不是持久的，如果服务重启，它将恢复为关闭


rabbitmqctl trace_off [-p vhost]
# 停止跟踪


rabbitmqctl set_vm_memory_high_watermark {fraction}
# {fraction} 触发流量控制的新内存阈值分数，大于或等于0的浮点数


rabbitmqctl set_vm_memory_high_watermark absolute {memory_limit}
# {memory_limit} 触发流量控制的新内存限制，以字节表示，大于或等于0的整数或作为具有存储单元（例如： 512M或者1G），可用的单位有：
k/kiB： kibibytes(2^10字节)； M/MiB: mebibytes(2^20字节)； G/GiB: gibibytes(2^30字节)
kB: kilobytes(10^3); MB: megabytes(10^6); GB: gigabytes(10^9)


rabbitmqctl set_disk_free_limit {disk_limit}
# {disk_limit} 下限为字节整数或具有存储单元的字符串（参见 vm_memory_high_watermark 命令），例如： 512M或1G，一旦可用磁盘空间达到限制，将会设置磁盘告警


rabbitmqctl set_disk_free_limit mem_relative {fraction}
# {fraction} 相对于可用RAM的限制，为非负的浮点数。低于1.0的值可能是危险的，应小心使用。


rabbitmqctl encode [--decode] [value] [passphrase] [--list-ciphers] [--list-hashes] [--cipher cipher] [--hash hash] [--iterations iteraions]
# [--decode] 表示解密输入值的标志位。
  例如: rabbitmqctl encode --decode '{encrypted,'<<"...">>}' mypassphrase
# [value] [passphrase] 表示加密和解密的值、密码。 
  例如： rabbitmqctl encode '<<"guest">>' mypassphrase
  例如： rabbitmqctl encode --decode '{encrypted,'<<"...">>}' mypassphrase 
# [--list-ciphers] 表示列出支持的密码标志位
  例如： rabbitmqctl encode --list-ciphers
# [--list-hashes] 表示列出支持的哈希算法标志位
  例如： rabbitmqctl encode --list-hashes
# [--cipher cipher] [--hash hash] [--iterations iterations] 表示用于指定加密设置的选项，它们可以独立使用
  例如： rabbitmqctl encode --cipher blowfish_cfb64 --hash sha256 --iterations 1000 '<<"guest">>' mypassphrase
```
