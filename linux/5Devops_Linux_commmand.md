# 运维实用的 Linux 命令

## 1、实用的 `xargs` 命令

在平时的使用中，我认为xargs这个命令还是较为重要和方便的。我们可以通过使用这个命令，将命令输出的结果作为参数传递给另一个命令。

比如说我们想找出某个路径下以 `.conf` 结尾的文件，并将这些文件进行分类，那么普通的做法就是先将以 `.conf` 结尾的文件先找出来，然后输出到一个文件中，接着`cat`这个文件，并使用`file`文件分类命令去对输出的文件进行分类。

这个普通的方法还的确是略显麻烦，那么这个时候`xargs`命令就派上用场了。

例1：找出 `/` 目录下以`.conf` 结尾的文件，并进行文件分类

命令：

```
$ cd /etc
$ sudo find / -name '*.conf'
/lib/modules-load.d/fuse.conf
/lib/modprobe.d/blacklist_linux_3.13.0-135-generic.conf
/var/lib/ucf/cache/:etc:rsyslog.d:50-default.conf
/var/lib/ucf/cache/:etc:idmapd.conf
/var/lib/dkms/virtualbox-guest/4.3.36/build/dkms.conf
...
```

**Note: do not use `sudo find / -name *.conf`, caused problem: `find: paths must precede expression: blkid.conf`**


```
$ sudo find / -name '*.conf' -type f -print | xargs file
...
/etc/init/upstart-socket-bridge.conf:                                                      ASCII text
/etc/init/mountnfs.sh.conf:                                                                ASCII text
/etc/init/udevtrigger.conf:                                                                ASCII text
/etc/init/rsyslog.conf:                                                                    ASCII text
/etc/init/cloud-final.conf:                                                                ASCII text
/etc/rsyslog.conf:                                                                         ASCII text
/run/resolvconf/resolv.conf:                                                               ASCII text
/home/vagrant/git/sshWebProject/mw/vendor/ruflin/elastica/env/nginx/nginx.conf:            ASCII text
/home/vagrant/git/sshWebProject/mw/maintenance/hiphop/server.conf:                         ASCII text
/home/vagrant/git/sshWebProject/mw/includes/tidy/tidy.conf:                                ASCII text
```

## 2、命令或脚本后台运行

有时候我们进行一些操作的时候，不希望我们的操作在终端会话断了之后就跟着断了，特别是一些数据库导入导出操作，如果涉及到大数据量的操作，我们不可能保证我们的网络在我们的操作期间不出问题，所以后台运行脚本或者命令对我们来说是一大保障。

比如说我们想把数据库的导出操作后台运行，并且将命令的操作输出记录到文件，那么我们可以这么做：

```
nohup mysqldump -uroot -pxxxxx --all-databases > ./alldatabases.sql &（xxxxx是密码）
```

当然如果你不想密码明文，你还可以这么做：

```
nohup mysqldump -uroot -p --all-databases > ./alldatabases.sql  （后面不加&符号）
```

执行了上述命令后，会提示叫你输入密码，输入密码后，该命令还在前台运行，但是我们的目的是后天运行该命令，这个时候你可以按下Ctrl+Z，然后在输入bg就可以达到第一个命令的效果，让该命令后台运行，同时也可以让密码隐蔽输入。

命令后台执行的结果会在命令执行的当前目录下留下一个 nohup.out 文件，查看这个文件就知道命令有没有执行报错等信息。

## 3、找出当前系统内存使用量较高的进程

在很多运维的时候，我们发现内存耗用较为严重，那么怎么样才能找出内存消耗的进程排序呢？

命令：`# ps -aux | sort -rnk 4  | head -20`

```
$ ps -aux | sort -rnk 4  | head -20
root       944  0.0  3.4 114436 34684 ?        Sl   Mar20   0:00 ruby /usr/bin/chef-client -d -P /var/run/chef/client.pid -c /etc/chef/client.rb -i 1800 -s 20 -L /var/log/chef/client.log
root      1327  0.0  3.3 182528 34344 ?        Ssl  Mar08   0:19 /usr/bin/ruby /usr/bin/puppet agent
root       915  0.0  2.7 366068 27840 ?        Ssl  Mar08  14:35 /usr/bin/dockerd --raw-logs
root       975  0.0  0.7 274904  7424 ?        Ssl  Mar08   8:49 docker-containerd -l unix:///var/run/docker/libcontainerd/docker-containerd.sock --metrics-interval=0 --start-timeout 2m --state-dir /var/run/docker/libcontainerd/containerd --shim docker-containerd-shim --runtime docker-runc
vagrant   8458  0.0  0.6  23676  6260 pts/0    Ss   03:09   0:00 -bash
root      8351  0.0  0.4 105148  4248 ?        Ss   03:09   0:00 sshd: vagrant [priv]
root      2701  0.0  0.3  61376  3080 ?        Ss   Mar08   0:00 /usr/sbin/sshd -D
vagrant   8457  0.0  0.2 105476  2304 ?        S    03:09   0:01 sshd: vagrant@pts/0
root       579  0.0  0.2  10220  2900 ?        Ss   Mar08   0:00 dhclient -1 -v -pf /run/dhclient.eth0.pid -lf /var/lib/dhcp/dhclient.eth0.leases eth0
root         1  0.0  0.2  33624  2960 ?        Ss   Mar08   0:00 /sbin/init
vagrant  13564  0.0  0.1  17168  1312 pts/0    R+   09:37   0:00 ps -aux
syslog     960  0.0  0.1 255840  1600 ?        Ssl  Mar08   0:00 rsyslogd
statd      726  0.0  0.1  21544  1372 ?        Ss   Mar08   0:00 rpc.statd -L
root       926  0.0  0.1  43452  1816 ?        Ss   Mar08   0:00 /lib/systemd/systemd-logind
root       656  0.0  0.1  23424  1108 ?        Ss   Mar08   0:02 rpcbind
root       440  0.0  0.1  49996  1768 ?        Ss   Mar08   0:00 /lib/systemd/systemd-udevd --daemon
root      1167  0.0  0.1 232768  1084 ?        Sl   Mar08   5:00 /usr/sbin/VBoxService
message+   823  0.0  0.1  39232  1336 ?        Ss   Mar08   0:36 dbus-daemon --system --fork
vagrant  13566  0.0  0.0   5928   684 pts/0    S+   09:37   0:00 head -20
vagrant  13565  0.0  0.0  14440   852 pts/0    S+   09:37   0:00 sort -rnk 4
```

1. **输出的第`4`列就是内存的耗用百分比**
2. **最后一列就是相对应的进程**

### 4、找出当前系统CPU使用量较高的进程

在很多运维的时候，我们发现CPU耗用较为严重，那么怎么样才能找出CPU消耗的进程排序呢？

命令：`# ps -aux | sort -rnk 3  | head -20`

```
$ ps -aux | sort -rnk 3  | head -20
vagrant   8458  0.0  0.6  23676  6260 pts/0    Ss   03:09   0:00 -bash
vagrant   8457  0.0  0.2 105476  2304 ?        S    03:09   0:01 sshd: vagrant@pts/0
vagrant  14570  0.0  0.0   5928   684 pts/0    S+   09:42   0:00 head -20
vagrant  14569  0.0  0.0  14440   852 pts/0    S+   09:42   0:00 sort -rnk 3
vagrant  14568  0.0  0.1  17168  1304 pts/0    R+   09:42   0:00 ps -aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
syslog     960  0.0  0.1 255840  1600 ?        Ssl  Mar08   0:00 rsyslogd
statd      726  0.0  0.1  21544  1372 ?        Ss   Mar08   0:00 rpc.statd -L
root       979  0.0  0.0  15408   624 ?        S    Mar08   0:00 upstart-file-bridge --daemon
root       975  0.0  0.7 274904  7424 ?        Ssl  Mar08   8:50 docker-containerd -l unix:///var/run/docker/libcontainerd/docker-containerd.sock --metrics-interval=0 --start-timeout 2m --state-dir /var/run/docker/libcontainerd/containerd --shim docker-containerd-shim --runtime docker-runc
root       944  0.0  3.4 114436 34684 ?        Sl   Mar20   0:00 ruby /usr/bin/chef-client -d -P /var/run/chef/client.pid -c /etc/chef/client.rb -i 1800 -s 20 -L /var/log/chef/client.log
root       926  0.0  0.1  43452  1816 ?        Ss   Mar08   0:00 /lib/systemd/systemd-logind
root       915  0.0  2.7 366068 27840 ?        Ssl  Mar08  14:35 /usr/bin/dockerd --raw-logs
root       905  0.0  0.0  23480   420 ?        Ss   Mar08   0:00 rpc.idmapd
root         9  0.0  0.0      0     0 ?        S    Mar08   0:00 [rcu_bh]
root      8363  0.0  0.0      0     0 ?        S    03:09   0:08 [kworker/0:1]
root      8351  0.0  0.4 105148  4248 ?        Ss   03:09   0:00 sshd: vagrant [priv]
root       826  0.0  0.0      0     0 ?        S<   Mar08   0:00 [nfsiod]
root       817  0.0  0.0      0     0 ?        S<   Mar08   0:00 [rpciod]
root         8  0.0  0.0      0     0 ?        S    Mar08   0:22 [rcuos/0]
```

1. **输出的第`3`列为CPU的耗用百分比，**
2. **最后一列就是对应的进程。**

## 5、同时查看多个日志或数据文件

在日常工作中，我们查看日志文件的方式可能是使用`tail`命令在一个个的终端查看日志文件，一个终端就看一个日志文件。包括我在内也是，但是有时候也会觉得这种方式略显麻烦，其实有个工具叫做 `multitail` 可以在同一个终端同时查看多个日志文件。

**首先安装 `multitail`：**

```
# wget ftp://ftp.is.co.za/mirror/ftp.rpmforge.net/redhat/el6/en/x86_64/dag/RPMS/multitail-5.2.9-1.el6.rf.x86_64.rpm
# yum -y localinstall multitail-5.2.9-1.el6.rf.x86_64.rpm
```
multitail 工具支持文本的高亮显示，内容过滤以及更多你可能需要的功能。


如下就来一个有用的例子：

此时我们既想查看secure的日志指定过滤关键字输出，又想查看实时的网络ping情况：

命令如下：

```
# multitail -e "Accepted" /var/log/secure  -l "ping baidu.com"
```

是不是很方便？如果平时我们想查看两个日志之间的关联性，可以观察日志输出是否有触发等。如果分开两个终端可能来回进行切换有点浪费时间，这个`multitail`工具查看未尝不是一个好方法。

## 6、持续 ping 并将结果记录到日志

怪异的症状，肯定是服务器网络出问题了。这个就是俗称的背锅，业务出了问题，第一时间相关人员找不到原因很多情况下就会把问题归结于服务器网络有问题。

**这个时候你去ping几个包把结果丢出来，人家会反驳你，刚刚那段时间有问题而已，现在业务都恢复正常了，网络肯定正常啊，这个时候估计你要气死。**

你要是再拿出zabbix等网络监控的数据，这个时候就不太妥当了，zabbix的采集数据间隔你不可能设置成1秒钟1次吧？小编就遇到过这样的问题，结果我通过以下的命令进行了ping监控采集。

```
ping 192.168.33.12 | awk '{ print $0"\t" strftime("%Y-%m-%d %H:%M:%S",systime()) } ' > /tmp/3312.log &
[2] 16444
```
输出的结果会记录到`/tmp/3312.log` 中，每秒钟新增一条`ping`记录，如下：

```
$ cd /tmp
$ ls
$ lsof 3312.log
$ kill -9 15917
$  kill -9 16444
[1]-  Killed                  ping 192.168.33.12 | awk '{ print $0"\t" strftime("%Y-%m-%d %H:%M:%S",systime()) } ' >> /tmp/3312.log  (wd: ~/tmp)
(wd now: /tmp)
$ tail -f 3312.log
$ tail -f 3312.log
64 bytes from 192.168.33.12: icmp_seq=387 ttl=64 time=0.662 ms	2019-03-21 09:59:09
64 bytes from 192.168.33.12: icmp_seq=388 ttl=64 time=0.283 ms	2019-03-21 09:59:10
64 bytes from 192.168.33.12: icmp_seq=389 ttl=64 time=0.368 ms	2019-03-21 09:59:11
64 bytes from 192.168.33.12: icmp_seq=390 ttl=64 time=0.716 ms	2019-03-21 09:59:12
64 bytes from 192.168.33.12: icmp_seq=391 ttl=64 time=0.553 ms	2019-03-21 09:59:13
64 bytes from 192.168.33.12: icmp_seq=392 ttl=64 time=0.641 ms	2019-03-21 09:59:14
64 bytes from 192.168.33.12: icmp_seq=393 ttl=64 time=0.548 ms	2019-03-21 09:59:15
64 bytes from 192.168.33.12: icmp_seq=394 ttl=64 time=0.468 ms	2019-03-21 09:59:16
64 bytes from 192.168.33.12: icmp_seq=395 ttl=64 time=0.452 ms	2019-03-21 09:59:17
```

## 7、查看tcp连接状态

指定查看`80`端口的tcp连接状态，有利于分析连接是否释放，或者攻击时进行状态分析。

命令：`# netstat -nat |awk '{print $6}'|sort|uniq -c|sort -rn`

```
$ netstat -nat |awk '{print $6}'|sort|uniq -c|sort -rn
      6 LISTEN
      1 Foreign
      1 ESTABLISHED
      1 established)
```

## 8、查找80端口请求数最高的前20个IP

有时候业务的请求量突然上去了，那么这个时候我们可以查看下请求来源IP情况，如果是集中在少数IP上的，那么可能是存在攻击行为，我们使用防火墙就可以进行封禁。命令如下：

```
# netstat -anlp|grep 80|grep tcp|awk '{print $5}'|awk -F: '{print $1}'|sort|uniq -c|sort -nr|head -n20
```


## 9、ssh实现端口转发

**可能很多的朋友都听说过ssh是linux下的远程登录安全协议，就是通俗的远程登录管理服务器**。但是应该很少朋友会听说过ssh还可以做端口转发。其实ssh用来做端口转发的功能还是很强大的，下面就来做示范。


> 实例背景：我们公司是有堡垒机的，任何操作均需要在堡垒机上进行，有写开发人员需要访问`ELasticSearch`的head面板查看集群状态，但是我们并不想将`ElasticSearch`的`9200`端口映射出去，依然想通过堡垒机进行访问。

> 所以才会将通往堡垒机`（192.168.1.15）`的请求转发到服务器`ElasticSearch（192.168.1.19）`的`9200`上。

**例子：**

**将发往本机`（192.168.1.15）`的`9200`端口访问转发到`192.168.1.19`的`9200`端口**

```
ssh -p 22 -C -f -N -g -L 9200:192.168.1.19:9200 ihavecar@192.168.1.19`
```

**记住：前提是先进行秘钥传输。**

命令执行完后，访问`192.168.1.15:9200`端口则真实是访问`192.168.1.19:9200`端口。



















