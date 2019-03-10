# Top 9 Linux Job Interview Questions

## 1.How to check the `kernel version` of a Linux system?

**check all**

```
$ uname -a
Linux Jacob 3.13.0-135-generic #184-Ubuntu SMP Wed Oct 18 11:55:51 UTC 2017 x86_64 x86_64 x86_64 GNU/Linux
```

**check version**

```
$ uname -v
#184-Ubuntu SMP Wed Oct 18 11:55:51 UTC 2017
```

**check release**

```
$ uname -r
3.13.0-135-generic
```

## 2.How to see the current IP address on Linux?

**Option1**

```
$ ifconfig
docker0   Link encap:Ethernet  HWaddr 02:42:e3:a7:28:b4
          inet addr:172.17.0.1  Bcast:0.0.0.0  Mask:255.255.0.0
          UP BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

eth0      Link encap:Ethernet  HWaddr 08:00:27:9e:58:5a
          inet addr:10.0.2.15  Bcast:10.0.2.255  Mask:255.255.255.0
          inet6 addr: fe80::a00:27ff:fe9e:585a/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:155963 errors:0 dropped:0 overruns:0 frame:0
          TX packets:104358 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:78693539 (78.6 MB)  TX bytes:69450644 (69.4 MB)

...
```

**Option2**

```
$ ip addr show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:9e:58:5a brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe9e:585a/64 scope link
       valid_lft forever preferred_lft forever
...
```


```
$ ip addr show docker0
4: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default
    link/ether 02:42:e3:a7:28:b4 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 scope global docker0
       valid_lft forever preferred_lft forever
```

## 3.How to check for free disk space in Linux?

```
$ df -ah
Filesystem      Size  Used Avail Use% Mounted on
sysfs              0     0     0    - /sys
proc               0     0     0    - /proc
udev            492M   12K  492M   1% /dev
devpts             0     0     0    - /dev/pts
tmpfs           100M  372K  100M   1% /run
/dev/sda1        40G  5.7G   32G  16% /
none            4.0K     0  4.0K   0% /sys/fs/cgroup
none               0     0     0    - /sys/fs/fuse/connections
none               0     0     0    - /sys/kernel/debug
none               0     0     0    - /sys/kernel/security
none            5.0M     0  5.0M   0% /run/lock
none            497M     0  497M   0% /run/shm
none            100M     0  100M   0% /run/user
none               0     0     0    - /sys/fs/pstore
binfmt_misc        0     0     0    - /proc/sys/fs/binfmt_misc
cgroup             0     0     0    - /sys/fs/cgroup/cpuset
cgroup             0     0     0    - /sys/fs/cgroup/cpu
cgroup             0     0     0    - /sys/fs/cgroup/cpuacct
cgroup             0     0     0    - /sys/fs/cgroup/memory
rpc_pipefs         0     0     0    - /run/rpc_pipefs
cgroup             0     0     0    - /sys/fs/cgroup/devices
cgroup             0     0     0    - /sys/fs/cgroup/freezer
cgroup             0     0     0    - /sys/fs/cgroup/blkio
cgroup             0     0     0    - /sys/fs/cgroup/perf_event
cgroup             0     0     0    - /sys/fs/cgroup/hugetlb
systemd            0     0     0    - /sys/fs/cgroup/systemd
/dev/sda1        40G  5.7G   32G  16% /var/lib/docker/aufs
none            466G  163G  304G  35% /vagrant
```

## 4.How to see if a Linux service is running?

#### old way `service status(options) service_name`

```
$ service docker status
docker start/running, process 915
```

#### new way `systemctl status(options) service_name`


## 5.How to check the size of a directory in Linux?

```
$ du -sh TechBlog/
1.2G	TechBlog/
```

## 6.How to check for open ports in Linux?

```
$ sudo netstat -lnotp
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name Timer
tcp        0      0 0.0.0.0:60932           0.0.0.0:*               LISTEN      726/rpc.statd    off (0.00/0/0)
tcp        0      0 0.0.0.0:111             0.0.0.0:*               LISTEN      656/rpcbind      off (0.00/0/0)
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      2701/sshd        off (0.00/0/0)
tcp6       0      0 :::111                  :::*                    LISTEN      656/rpcbind      off (0.00/0/0)
tcp6       0      0 :::57429                :::*                    LISTEN      726/rpc.statd    off (0.00/0/0)
tcp6       0      0 :::22                   :::*                    LISTEN      2701/sshd        off (0.00/0/0)
```

```
$ sudo netstat -tulpn
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 0.0.0.0:60932           0.0.0.0:*               LISTEN      726/rpc.statd
tcp        0      0 0.0.0.0:111             0.0.0.0:*               LISTEN      656/rpcbind
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      2701/sshd
tcp6       0      0 :::111                  :::*                    LISTEN      656/rpcbind
tcp6       0      0 :::57429                :::*                    LISTEN      726/rpc.statd
tcp6       0      0 :::22                   :::*                    LISTEN      2701/sshd
udp        0      0 127.0.0.1:902           0.0.0.0:*                           726/rpc.statd
udp        0      0 0.0.0.0:68              0.0.0.0:*                           579/dhclient
udp        0      0 0.0.0.0:111             0.0.0.0:*                           656/rpcbind
udp        0      0 0.0.0.0:15077           0.0.0.0:*                           579/dhclient
udp        0      0 0.0.0.0:35589           0.0.0.0:*                           726/rpc.statd
udp        0      0 0.0.0.0:830             0.0.0.0:*                           656/rpcbind
udp6       0      0 :::56354                :::*                                579/dhclient
udp6       0      0 :::111                  :::*                                656/rpcbind
udp6       0      0 :::33972                :::*                                726/rpc.statd
udp6       0      0 :::830                  :::*                                656/rpcbind
```

## 7.How to check Linux process information (CPU usage, memory, user information, etc.)?

```
$ ps aux | grep docker
root       915  0.0  2.7 366068 28084 ?        Ssl  Mar01  10:58 /usr/bin/dockerd --raw-logs
root       975  0.0  0.7 274904  7592 ?        Ssl  Mar01   6:38 docker-containerd -l unix:///var/run/docker/libcontainerd/docker-containerd.sock --metrics-interval=0 --start-timeout 2m --state-dir /var/run/docker/libcontainerd/containerd --shim docker-containerd-shim --runtime docker-runc
```

```
$ top
```

## 8.How to deal with mounts in Linux

```
$ ls /mnt
$ mount /dir /mnt
$ mount
```

## 9.Man pages

```
$ man ps

PS(1)                                                                 User Commands                                                                PS(1)

NAME
       ps - report a snapshot of the current processes.

SYNOPSIS
       ps [options]

DESCRIPTION
... 


EXAMPLES
       To see every process on the system using standard syntax:
          ps -e
          ps -ef
          ps -eF
          ps -ely

       To see every process on the system using BSD syntax:
          ps ax
          ps axu
...
```

