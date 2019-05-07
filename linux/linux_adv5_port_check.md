# 监控Linux系统当前监听使用的端口

## 1. netstat

```
$ netstat -tupln
```

* **t** , tcp
* **u**, udp
* **p**, progam name, pid 
* **l**, only list listen port
* **n**, 不进行名称解析

```
$ sudo netstat -tupln
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 0.0.0.0:111             0.0.0.0:*               LISTEN      658/rpcbind
tcp        0      0 0.0.0.0:54641           0.0.0.0:*               LISTEN      729/rpc.statd
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      2711/sshd
tcp6       0      0 :::111                  :::*                    LISTEN      658/rpcbind
tcp6       0      0 :::22                   :::*                    LISTEN      2711/sshd
tcp6       0      0 :::45563                :::*                    LISTEN      729/rpc.statd
udp        0      0 127.0.0.1:905           0.0.0.0:*                           729/rpc.statd
udp        0      0 0.0.0.0:68              0.0.0.0:*                           579/dhclient
udp        0      0 0.0.0.0:18007           0.0.0.0:*                           579/dhclient
udp        0      0 0.0.0.0:111             0.0.0.0:*                           658/rpcbind
udp        0      0 0.0.0.0:51465           0.0.0.0:*                           729/rpc.statd
udp        0      0 0.0.0.0:830             0.0.0.0:*                           658/rpcbind
udp6       0      0 :::48062                :::*                                729/rpc.statd
udp6       0      0 :::13349                :::*                                579/dhclient
udp6       0      0 :::111                  :::*                                658/rpcbind
udp6       0      0 :::830                  :::*                                658/rpcbind
```

```
$ sudo netstat -tupln | grep 22$ sudo netstat -tupln | grep 22
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      2711/sshd
tcp6       0      0 :::22                   :::*                    LISTEN      2711/sshd
```

## 2. lsof

[什么是lsof](3Linux_lsof.md)

```
$ lsof -i
```
* **i**: internet

```
 sudo lsof -i
COMMAND    PID    USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
dhclient   579    root    5u  IPv4   7669      0t0  UDP *:bootpc
dhclient   579    root   20u  IPv4   7591      0t0  UDP *:18007
dhclient   579    root   21u  IPv6   7592      0t0  UDP *:13349
rpcbind    658    root    6u  IPv4   7965      0t0  UDP *:sunrpc
rpcbind    658    root    7u  IPv4   7968      0t0  UDP *:830
rpcbind    658    root    8u  IPv4   7969      0t0  TCP *:sunrpc (LISTEN)
rpcbind    658    root    9u  IPv6   7970      0t0  UDP *:sunrpc
rpcbind    658    root   10u  IPv6   7971      0t0  UDP *:830
rpcbind    658    root   11u  IPv6   7972      0t0  TCP *:sunrpc (LISTEN)
rpc.statd  729   statd    4u  IPv4   8162      0t0  UDP localhost:905
rpc.statd  729   statd    7u  IPv4   8169      0t0  UDP *:51465
rpc.statd  729   statd    8u  IPv4   8172      0t0  TCP *:54641 (LISTEN)
rpc.statd  729   statd    9u  IPv6   8175      0t0  UDP *:48062
rpc.statd  729   statd   10u  IPv6   8178      0t0  TCP *:45563 (LISTEN)
sshd      2711    root    3u  IPv4  12573      0t0  TCP *:ssh (LISTEN)
sshd      2711    root    4u  IPv6  12575      0t0  TCP *:ssh (LISTEN)
sshd      3466    root    3u  IPv4  80802      0t0  TCP Jacob:ssh->10.0.2.2:53461 (ESTABLISHED)
sshd      3559 vagrant    3u  IPv4  80802      0t0  TCP Jacob:ssh->10.0.2.2:53461 (ESTABLISHED)
```