# **L3 How to Install RabbitMQ on CentOS 7**


### **Step 1: Update the system**

Use the following commands to update your CentOS 7 system to the latest stable status:

```
sudo yum install epel-release
sudo yum update
sudo reboot
```

### **Step 2: Install Erlang**

Since RabbitMQ is written in Erlang, you need to install Erlang before you can use RabbitMQ:

**Install Erlang**

```
wget http://packages.erlang-solutions.com/erlang-solutions-1.0-1.noarch.rpm
sudo rpm -Uvh erlang-solutions-1.0-1.noarch.rpm
```
Verify your installation of Erlang:

```
$ erl
Erlang/OTP 22 [erts-10.6.4] [source] [64-bit] [smp:1:1] [ds:1:1:10] [async-threads:1] [hipe]

Eshell V10.6.4  (abort with ^G)
1>
```

Press `Ctrl+C` twice to quit the Erlang shell.

### **Step 3: Install RabbitMQ**

[https://www.rabbitmq.com/download.html](https://www.rabbitmq.com/download.html)

```
wget https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.8.2/rabbitmq-server-3.8.2-1.el7.noarch.rpm

sudo rpm --import https://www.rabbitmq.com/rabbitmq-signing-key-public.asc

sudo yum install rabbitmq-server-3.8.2-1.el7.noarch.rpm
```

### **Step 4: Modify firewall rules**


In order to access the RabbitMQ remote management console, you need to allow inbound TCP traffic on ports 4369, 25672, 5671, 5672, 15672, 61613, 61614, 1883, and 8883.

```
sudo firewall-cmd --zone=public --permanent --add-port=4369/tcp --add-port=25672/tcp --add-port=5671-5672/tcp --add-port=15672/tcp  --add-port=61613-61614/tcp --add-port=1883/tcp --add-port=8883/tcp


sudo firewall-cmd --reload
```

Start the RabbitMQ server and enable it to start on system boot:

```
$ sudo systemctl start rabbitmq-server.service
$ sudo systemctl enable rabbitmq-server.service
Created symlink from /etc/systemd/system/multi-user.target.wants/rabbitmq-server.service to /usr/lib/systemd/system/rabbitmq-server.service.
```

You can check the status of RabbitMQ with:

```
$ sudo rabbitmqctl status
warning: the VM is running with native name encoding of latin1 which may cause Elixir to malfunction as it expects utf8. Please ensure your locale is set to UTF-8 (which can be verified by running "locale" in your shell)
Status of node rabbit@jabox ...
Runtime

OS PID: 12582
OS: Linux
Uptime (seconds): 31
RabbitMQ version: 3.8.2
Node name: rabbit@jabox
Erlang configuration: Erlang/OTP 22 [erts-10.6.4] [source] [64-bit] [smp:1:1] [ds:1:1:10] [async-threads:64] [hipe]
Erlang processes: 256 used, 1048576 limit
Scheduler run queue: 1
Cluster heartbeat timeout (net_ticktime): 60

Plugins

Enabled plugin file: /etc/rabbitmq/enabled_plugins
Enabled plugins:


Data directory

Node data directory: /var/lib/rabbitmq/mnesia/rabbit@jabox

Config files


Log file(s)

 * /var/log/rabbitmq/rabbit@jabox.log
 * /var/log/rabbitmq/rabbit@jabox_upgrade.log

Alarms

(none)

Memory

Calculation strategy: rss
Memory high watermark setting: 0.4 of available memory, computed to: 0.4158 gb
other_proc: 0.0297 gb (35.19 %)
code: 0.023 gb (27.24 %)
other_system: 0.0111 gb (13.11 %)
allocated_unused: 0.0098 gb (11.64 %)
reserved_unallocated: 0.0064 gb (7.63 %)
other_ets: 0.0027 gb (3.15 %)
atom: 0.0014 gb (1.7 %)
binary: 0.0001 gb (0.14 %)
mnesia: 0.0001 gb (0.09 %)
metrics: 0.0 gb (0.06 %)
msg_index: 0.0 gb (0.03 %)
plugins: 0.0 gb (0.01 %)
quorum_ets: 0.0 gb (0.01 %)
connection_channels: 0.0 gb (0.0 %)
connection_other: 0.0 gb (0.0 %)
connection_readers: 0.0 gb (0.0 %)
connection_writers: 0.0 gb (0.0 %)
mgmt_db: 0.0 gb (0.0 %)
queue_procs: 0.0 gb (0.0 %)
queue_slave_procs: 0.0 gb (0.0 %)
quorum_queue_procs: 0.0 gb (0.0 %)

File Descriptors

Total: 2, limit: 32671
Sockets: 0, limit: 29401

Free Disk Space

Low free disk space watermark: 0.05 gb
Free disk space: 33.7313 gb

Totals

Connection count: 0
Queue count: 0
Virtual host count: 1

Listeners

Interface: [::], port: 25672, protocol: clustering, purpose: inter-node and CLI tool communication
Interface: [::], port: 5672, protocol: amqp, purpose: AMQP 0-9-1 and AMQP 1.0
```

### **Step 5: Enable and use the RabbitMQ management console**

Enable the RabbitMQ management console so that you can monitor the RabbitMQ server processes from a web browser:

```
$ sudo rabbitmq-plugins enable rabbitmq_management

warning: the VM is running with native name encoding of latin1 which may cause Elixir to malfunction as it expects utf8. Please ensure your locale is set to UTF-8 (which can be verified by running "locale" in your shell)
Enabling plugins on node rabbit@jabox:
rabbitmq_management
The following plugins have been configured:
  rabbitmq_management
  rabbitmq_management_agent
  rabbitmq_web_dispatch
Applying plugin configuration to rabbit@jabox...
The following plugins have been enabled:
  rabbitmq_management
  rabbitmq_management_agent
  rabbitmq_web_dispatch

started 3 plugins.


$ sudo chown -R rabbitmq:rabbitmq /var/lib/rabbitmq/
```

Next, you need to setup an administrator user account for accessing the RabbitMQ server management console. 

In the following commands, 

* `"mqadmin"` is the administrator's username, 
* `"mqadminpassword"` is the password. 

Remember to replace them with your own ones.


```
# sudo rabbitmqctl add_user mqadmin mqadminpassword

$ sudo rabbitmqctl add_user admin admin
Adding user "admin" ...

# User: admin 
$ sudo rabbitmqctl set_user_tags admin administrator
Setting tags for user "admin" to [administrator] ...

# User: admin 
$ sudo rabbitmqctl set_permissions -p / admin ".*" ".*" ".*"
Setting permissions for user "admin" in vhost "/" ...
```

Now, visit the following URL:


```
http://[your-vm-server-IP]:15672/
```

```
http://192.168.33.10:15672
```

![Alt Image Text](images/3_1.png "Body image")

* admin
* admin

![Alt Image Text](images/3_2.png "Body image")
