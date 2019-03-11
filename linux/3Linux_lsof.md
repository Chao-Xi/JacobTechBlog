# 8 Basic `lsof` Commands

## 1.Interpreting the `lsof` output

**`lsof`**

```
$ sudo lsof | head -10
COMMAND     PID  TID       USER   FD      TYPE             DEVICE SIZE/OFF       NODE NAME
init          1            root  cwd       DIR                8,1     4096          2 /
init          1            root  rtd       DIR                8,1     4096          2 /
init          1            root  txt       REG                8,1   265848       3385 /sbin/init
init          1            root  mem       REG                8,1    43616      45669 /lib/x86_64-linux-gnu/libnss_files-2.19.so
init          1            root  mem       REG                8,1    47760      45675 /lib/x86_64-linux-gnu/libnss_nis-2.19.so
init          1            root  mem       REG                8,1    97296      45690 /lib/x86_64-linux-gnu/libnsl-2.19.so
init          1            root  mem       REG                8,1    39824      45678 /lib/x86_64-linux-gnu/libnss_compat-2.19.so
init          1            root  mem       REG                8,1    14664      45691 /lib/x86_64-linux-gnu/libdl-2.19.so
init          1            root  mem       REG                8,1   252032       2168 /lib/x86_64-linux-gnu/libpcre.so.3.13.1
```

* `init` is the command that was run
* **process id**
* The user running the process
* file descriptor (cwd current working directory, inside of where the program was started from)
* type
* physical device
* size on some unix system(file size)
* Inode or file address on file system
* **Actual file path**

**In 99% precent situation, we only consider about `command`, `pid` and `name`**

## 2.Which processes have this file open?

**`lsof /var/log/nginx-error.log`**

```
$ sudo lsof /run/docker/libcontainerd/containerd/events.log
COMMAND   PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
docker-co 975 root    4w   REG   0,16        0 9130 /run/docker/libcontainerd/containerd/events.log
```

## 3.Which files does process X have open?

```
$ ps aux | grep docker
root       915  0.0  2.7 366068 28020 ?        Ssl  Mar01  11:14 /usr/bin/dockerd --raw-logs
root       975  0.0  0.7 274904  7472 ?        Ssl  Mar01   6:48 docker-containerd -l unix:///var/run/docker/libcontainerd/docker-containerd.sock --metrics-interval=0 --start-timeout 2m --state-dir /var/run/docker/libcontainerd/containerd --shim docker-containerd-shim --runtime docker-runc
vagrant   3166  0.0  0.0  10468   932 pts/0    S+   05:36   0:00 grep --color=auto docker
```

**`lsof -p 1`**

```
$ sudo lsof -p 975
COMMAND   PID USER   FD   TYPE             DEVICE SIZE/OFF  NODE NAME
docker-co 975 root  cwd    DIR                8,1     4096     2 /
docker-co 975 root  rtd    DIR                8,1     4096     2 /
docker-co 975 root  txt    REG                8,1 11316691 47463 /usr/bin/docker-containerd
docker-co 975 root  mem    REG                8,1  1857312 45695 /lib/x86_64-linux-gnu/libc-2.19.so
docker-co 975 root  mem    REG                8,1   141574 45687 /lib/x86_64-linux-gnu/libpthread-2.19.so
docker-co 975 root  mem    REG                8,1   149120 45684 /lib/x86_64-linux-gnu/ld-2.19.so
docker-co 975 root    0r   CHR                1,3      0t0  5304 /dev/null
docker-co 975 root    1u   CHR              136,6      0t0     9 /dev/pts/6
docker-co 975 root    2u   CHR              136,6      0t0     9 /dev/pts/6
docker-co 975 root    3u  0000                0,9        0  5259 anon_inode
docker-co 975 root    4w   REG               0,16        0  9130 /run/docker/libcontainerd/containerd/events.log
docker-co 975 root    5u  unix 0xffff88003cf8a3c0      0t0  9131 /var/run/docker/libcontainerd/docker-containerd.sock
docker-co 975 root    6u  0000                0,9        0  5259 anon_inode
docker-co 975 root    7u  unix 0xffff8800378852c0      0t0  9520 /var/run/docker/libcontainerd/docker-containerd.sock
```

**lsof -p `pgrep ABC`**


```
docker-co 975 root    2u   CHR              136,6      0t0     9 /dev/pts/6
docker-co 975 root    3u  0000                0,9        0  5259 anon_inode
```

* 2 stands for **error**
* 3 stands for **out**

## 4.Where is the binary for this process?

**`lsof -p ABC | grep bin`**

```
$ sudo lsof -p 975 | grep bin
docker-co 975 root  txt    REG                8,1 11316691 47463 /usr/bin/docker-containerd
```

## 5.Which shared libraries is this program using? (manually upgrading software, i.e. openssl)

**`lsof -p PID | grep .so`**

```
$ sudo lsof -p 975 | grep .so
docker-co 975 root  mem    REG                8,1  1857312 45695 /lib/x86_64-linux-gnu/libc-2.19.so
docker-co 975 root  mem    REG                8,1   141574 45687 /lib/x86_64-linux-gnu/libpthread-2.19.so
docker-co 975 root  mem    REG                8,1   149120 45684 /lib/x86_64-linux-gnu/ld-2.19.so
docker-co 975 root    5u  unix 0xffff88003cf8a3c0      0t0  9131 /var/run/docker/libcontainerd/docker-containerd.sock
docker-co 975 root    7u  unix 0xffff8800378852c0      0t0  9520 /var/run/docker/libcontainerd/docker-containerd.sock
```

## 6.Where is this thing logging to?

**`lsof -p ABC | grep log`**

```
$ sudo lsof -p 975 | grep log
docker-co 975 root    4w   REG               0,16        0  9130 /run/docker/libcontainerd/containerd/events.log
```

## 7.Which processes still have this old library open?

**`lsof grep libname.so`**

```
$ sudo lsof /lib/x86_64-linux-gnu/libc-2.19.so
COMMAND     PID       USER  FD   TYPE DEVICE SIZE/OFF  NODE NAME
init          1       root mem    REG    8,1  1857312 45695 /lib/x86_64-linux-gnu/libc-2.19.so
upstart-u   436       root mem    REG    8,1  1857312 45695 /lib/x86_64-linux-gnu/libc-2.19.so
systemd-u   440       root mem    REG    8,1  1857312 45695 /lib/x86_64-linux-gnu/libc-2.19.so
dhclient    579       root mem    REG    8,1  1857312 45695 /lib/x86_64-linux-gnu/libc-2.19.so
rpcbind     656       root mem    REG    8,1  1857312 45695 /lib/x86_64-linux-gnu/libc-2.19.so
rpc.statd   726      statd mem    REG    8,1  1857312 45695 /lib/x86_64-linux-gnu/libc-2.19.so
upstart-s   733       root mem    REG    8,1  1857312 45695 /lib/x86_64-linux-gnu/libc-2.19.so
dbus-daem   823 messagebus mem    REG    8,1  1857312 45695 /lib/x86_64-linux-gnu/libc-2.19.so
rpc.idmap   905       root mem    REG    8,1  1857312 45695 /lib/x86_64-linux-gnu/libc-2.19.so
dockerd     915       root mem    REG    8,1  1857312 45695 /lib/x86_64-linux-gnu/libc-2.19.so
systemd-l   926       root mem    REG    8,1  1857312 45695 /lib/x86_64-linux-gnu/libc-2.19.so
rsyslogd    960     syslog mem    REG    8,1  1857312 45695 /lib/x86_64-linux-gnu/libc-2.19.so
docker-co   975       root mem    REG    8,1  1857312 45695 /lib/x86_64-linux-gnu/libc-2.19.so
upstart-f   979       root mem    REG    8,1  1857312 45695 /lib/x86_64-linux-gnu/libc-2.19.so
getty      1065       root mem    REG    8,1  1857312 45695 /lib/x86_64-linux-gnu/libc-2.19.so
getty      1068       root mem    REG    8,1  1857312 45695 /lib/x86_64-linux-gnu/libc-2.19.so
getty      1072       root mem    REG    8,1  1857312 45695 /lib/x86_64-linux-gnu/libc-2.19.so
...
bash      31938    vagrant mem    REG    8,1  1857312 45695 /lib/x86_64-linux-gnu/libc-2.19.so
```


## 8.Which files does user XYZ have open?

`lsof -u XYZ(uname)`

```
$ sudo lsof -u vagrant
COMMAND   PID    USER   FD   TYPE             DEVICE SIZE/OFF   NODE NAME
sshd    31937 vagrant  cwd    DIR                8,1     4096      2 /
sshd    31937 vagrant  rtd    DIR                8,1     4096      2 /
sshd    31937 vagrant  txt    REG                8,1   762752  32004 /usr/sbin/sshd
sshd    31937 vagrant  mem    REG                8,1    14464   2207 /lib/x86_64-linux-gnu/security/pam_env.so
sshd    31937 vagrant  mem    REG                8,1    22896   2217 /lib/x86_64-linux-gnu/security/pam_limits.so
sshd    31937 vagrant  mem    REG                8,1    10320   2222 /lib/x86_64-linux-gnu/security/pam_mail.so
```

**`lsof -u XYZ -i # network only`**

```
$ sudo lsof -u vagrant -i
COMMAND     PID    USER   FD   TYPE             DEVICE SIZE/OFF   NODE NAME
dhclient    579    root    5u  IPv4               7676      0t0    UDP *:bootpc
dhclient    579    root   20u  IPv4               7586      0t0    UDP *:15077
dhclient    579    root   21u  IPv6               7587      0t0    UDP *:56354
rpcbind     656    root    6u  IPv4               7956      0t0    UDP *:sunrpc
rpcbind     656    root    7u  IPv4               7959      0t0    UDP *:830
```


## 9.Which process is listening on Port X (or using Protocol Y)?

```
lsof -i :80
lsof -i tcp
```

```
$ sudo lsof -i :22
COMMAND   PID    USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
sshd     2701    root    3u  IPv4  12606      0t0  TCP *:ssh (LISTEN)
sshd     2701    root    4u  IPv6  12608      0t0  TCP *:ssh (LISTEN)
sshd    31844    root    3u  IPv4 369239      0t0  TCP Jacob:ssh->10.0.2.2:53932 (ESTABLISHED)
sshd    31937 vagrant    3u  IPv4 369239      0t0  TCP Jacob:ssh->10.0.2.2:53932 (ESTABLISHED)
```

