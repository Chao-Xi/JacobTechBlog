# 浅谈Docker的安全性支持(一)


`Docker`作为最重视安全的容器技术之一，在很多方面都提供了强安全性的默认配置，其中包括：

* 容器`root`用户的 `Capability` 能力限制、
* `Seccomp`系统调用过滤、
* `Apparmor`的 MAC 访问控制、
* `ulimit`限制、
* `pid-limits`的支持，镜像签名机制等。

这篇文章我们就带大家详细了解一下。

`Docker`利用`Namespace`实现了`6`项隔离，看似完整，实际上依旧没有完全隔离`Linux`资源，比如`/proc` 、`/sys` 、`/dev/sd*`等目录未完全隔离，`SELinux`、`time`、`syslog`等所有现有`Namespace`之外的信息都未隔离。 其实`Docker`在安全性上也做了很多工作，大致包括下面几个方面：


## 1、Linux内核 Capability 能力限制

### `Docker`支持为容器设置`Capabilities`，指定开放给容器的权限。

这样在容器中的`root用户`比实际的`root`少很多权限。

Docker 在0.6版本以后支持将容器开启超级权限，**使容器具有宿主机的root权限。**

## 2、镜像签名机制

`Docker 1.8`版本以后提供了镜像签名机制来验证镜像的来源和完整性，**这个功能需要手动开启**，

这样镜像制作者可以在`push`镜像前对镜像进行签名，在镜像`pull`的时候，`Docker`不会`pull`验证失败或者没有签名的镜像标签。

## 3、Apparmor的MAC访问控制

`Apparmor`可以将进程的权限与进程`capabilities`能力联系在一起，**实现对进程的强制性访问控制（MAC）**。

在`Docker`中，我们可以使用`Apparmor`来限制用户只能执行**某些特定命令、限制容器网络、文件读写权限等功能**。

## 4、Seccomp系统调用过滤

使用`Seccomp`可以限制进程能够调用的系统调用（`system call`）的范围，

### `Docker`提供的默认 `Seccomp` 配置文件已经禁用了大约 `44` 个超过 `300+ `的系统调用，满足大多数容器的系统调用诉求。

## 5、User Namespace隔离

`Namespace`为运行中进程提供了隔离，限制他们对系统资源的访问，而进程没有意识到这些限制，为防止容器内的特权升级攻击的最佳方法是将容器的应用程序配置为作为非特权用户运行，

对于其进程必须作为容器中的 `root `用户运行的容器，可以将此用户重新映射到 `Docker` 主机上权限较低的用户。映射的用户被分配了一系列 `UID`，这些 `UID` 在命名空间内作为从 `0` 到 `65536` 的普通 `UID` 运行，但在主机上没有特权。

## 6、SELinux

### `SELinux`主要提供了强制访问控制（`MA`C），即不再是仅依据进程的所有者与文件资源的`rwx`权限来决定有无访问能力。能在攻击者实施了容器突破攻击后增加一层壁垒。`Docker`提供了对`SELinux`的支持。

## 7、pid-limits的支持

### 在说`pid-limits`前，需要说一下什么是`fork炸弹`(`fork bomb`)，`fork炸弹`就是以极快的速度创建大量进程，并以此消耗系统分配予进程的可用空间使进程表饱和，从而使系统无法运行新程序。

说起进程数限制，大家可能都知道`ulimit`的`nproc`这个配置，`nproc`是存在坑的，与其他`ulimit`选项不同的是，`nproc`是一个以用户为管理单位的设置选项，即他调节的是属于一个用户`UID`的最大进程数之和。这部分内容下一篇会介绍。`Docker`从`1.10`以后，支持为容器指定`--pids-limit` 限制容器内进程数，使用其可以限制容器内进程数。

## 8、其他内核安全特性工具支持

在容器生态的周围，还有很多工具可以为容器安全性提供支持，比如可以使用 `Docker bench audit tool`（工具地址：`https://github.com/docker/docker-bench-security`）检查你的`Docker运行环境`，使用`Sysdig Falco`（工具地址：`https://sysdig.com/opensource/falco/`）来检测容器内是否有异常活动，可以使用`GRSEC` 和 `PAX`来加固系统内核等等。


## Linux内核Capability能力限制

### `Capabilities`简单来说，就是指开放给进程的权限，比如允许进程可以访问网络、读取文件等。

`Docker`容器本质上就是一个进程，默认情况下，`Docker` 会删除必须的 `capabilities` 外的所有 `capabilities`，可以在 `Linux` 手册页中看到完整的可用 `capabilities` 列表。

**Docker 0.6版本以后支持在启动参数中增加 `--privileged` 选项为容器开启超级权限。**

`Docker`支持`Capabilities`对于容器安全意义重大，因为在容器中我们经常会以`root`用户来运行，使用`Capability`限制后，容器中的 `root` 比真正的 `root`用户权限少得多。这就意味着，即使入侵者设法在容器内获取了 `root` 权限，也难以做到严重破坏或获得主机 `root` 权限。

当我们在`docker run`时指定了`--privileded `选项，`docker`其实会完成两件事情：

* 获取系统`root`用户所有能力赋值给容器； 
* 扫描宿主机所有设备文件挂载到容器内。

当执行`docker run` 时未指定`--privileded `选项

```
$ docker run --rm --name def-cap-con1 -d alpine /bin/sh -c "while true;do echo hello; sleep 1;done"
a4bd8d16507eaa26da6c21e34ef5fa04313e6a01db18a32503c11e414918233a

$ docker inspect def-cap-con1 -f '{{.State.Pid}}'
24168

$ cat /proc/24168/status | grep Cap
CapInh:	00000000a80425fb
CapPrm:	00000000a80425fb
CapEff:	00000000a80425fb
CapBnd:	00000000a80425fb
CapAmb:	0000000000000000


$ docker exec def-cap-con1 ls -l /dev
rwxrwxrwx    1 root     root            11 Sep 17 15:43 core -> /proc/kcore
lrwxrwxrwx    1 root     root            13 Sep 17 15:43 fd -> /proc/self/fd
crw-rw-rw-    1 root     root        1,   7 Sep 17 15:43 full
drwxrwxrwt    2 root     root            40 Sep 17 15:43 mqueue
crw-rw-rw-    1 root     root        1,   3 Sep 17 15:43 null
lrwxrwxrwx    1 root     root             8 Sep 17 15:43 ptmx -> pts/ptmx
drwxr-xr-x    2 root     root             0 Sep 17 15:43 pts
crw-rw-rw-    1 root     root        1,   8 Sep 17 15:43 random
drwxrwxrwt    2 root     root            40 Sep 17 15:43 shm
lrwxrwxrwx    1 root     root            15 Sep 17 15:43 stderr -> /proc/self/fd/2
lrwxrwxrwx    1 root     root            15 Sep 17 15:43 stdin -> /proc/self/fd/0
lrwxrwxrwx    1 root     root            15 Sep 17 15:43 stdout -> /proc/self/fd/1
crw-rw-rw-    1 root     root        5,   0 Sep 17 15:43 tty
crw-rw-rw-    1 root     root        1,   9 Sep 17 15:43 urandom
crw-rw-rw-    1 root     root        1,   5 Sep 17 15:43 zero
```

如果指定了`--privileded` 选项

```
$ docker run --privileged --rm --name pri-cap-con1 -d alpine /bin/sh -c "while true;do echo hello; sleep 1;done"
dd3624f54dd01908e239e48de0afb611ebbc3205fac20e2064e16c6cddd22182

$ docker inspect pri-cap-con1 -f '{{.State.Pid}}'
24481

$ cat /proc/24481/status | grep Cap
CapInh:	0000001fffffffff
CapPrm:	0000001fffffffff
CapEff:	0000001fffffffff
CapBnd:	0000001fffffffff
CapAmb:	0000000000000000

$ docker exec pri-cap-con1 ls -l /dev
total 0
crw-------    1 root     root       10, 235 Sep 17 15:48 autofs
drwxr-xr-x    2 root     root            60 Sep 17 15:48 bsg
crw-------    1 root     root       10, 234 Sep 17 15:48 btrfs-control
lrwxrwxrwx    1 root     root            11 Sep 17 15:48 core -> /proc/kcore
drwxr-xr-x    3 root     root            80 Sep 17 15:48 cpu
crw-------    1 root     root       10,  61 Sep 17 15:48 cpu_dma_latency
crw-------    1 root     root       10,  62 Sep 17 15:48 crash
brw-rw----    1 root     disk      253,   0 Sep 17 15:48 dm-0
brw-rw----    1 root     disk      253,   1 Sep 17 15:48 dm-1
lrwxrwxrwx    1 root     root            13 Sep 17 15:48 fd -> /proc/self/fd
crw-rw-rw-    1 root     root        1,   7 Sep 17 15:48 full
crw-rw-rw-    1 root     root       10, 229 Sep 17 15:48 fuse
crw-------    1 root     root       10, 228 Sep 17 15:48 hpet
crw-------    1 root     root       10, 183 Sep 17 15:48 hwrng
drwxr-xr-x    2 root     root           200 Sep 17 15:48 input
crw-r--r--    1 root     root        1,  11 Sep 17 15:48 kmsg
crw-rw----    1 root     disk       10, 237 Sep 17 15:48 loop-control
drwxr-xr-x    2 root     root            60 Sep 17 15:48 mapper
crw-------    1 root     root       10, 227 Sep 17 15:48 mcelog
crw-r-----    1 root     kmem        1,   1 Sep 17 15:48 mem
drwxrwxrwt    2 root     root            40 Sep 17 15:48 mqueue
drwxr-xr-x    2 root     root            60 Sep 17 15:48 net
crw-------    1 root     root       10,  60 Sep 17 15:48 network_latency
crw-------    1 root     root       10,  59 Sep 17 15:48 network_throughput
crw-rw-rw-    1 root     root        1,   3 Sep 17 15:48 null
crw-------    1 root     root       10, 144 Sep 17 15:48 nvram
crw-------    1 root     root        1,  12 Sep 17 15:48 oldmem
crw-r-----    1 root     kmem        1,   4 Sep 17 15:48 port
crw-------    1 root     root      108,   0 Sep 17 15:48 ppp
lrwxrwxrwx    1 root     root             8 Sep 17 15:48 ptmx -> pts/ptmx
drwxr-xr-x    2 root     root             0 Sep 17 15:48 pts
crw-rw-rw-    1 root     root        1,   8 Sep 17 15:48 random
drwxr-xr-x    2 root     root            60 Sep 17 15:48 raw
crw-------    1 root     root      252,   0 Sep 17 15:48 rtc0
brw-rw----    1 root     disk        8,   0 Sep 17 15:48 sda
brw-rw----    1 root     disk        8,   1 Sep 17 15:48 sda1
brw-rw----    1 root     disk        8,   2 Sep 17 15:48 sda2
brw-rw----    1 root     disk        8,   3 Sep 17 15:48 sda3
crw-rw----    1 root     disk       21,   0 Sep 17 15:48 sg0
drwxrwxrwt    2 root     root            40 Sep 17 15:48 shm
crw-------    1 root     root       10, 231 Sep 17 15:48 snapshot
drwxr-xr-x    2 root     root           160 Sep 17 15:48 snd
lrwxrwxrwx    1 root     root            15 Sep 17 15:48 stderr -> /proc/self/fd/2
lrwxrwxrwx    1 root     root            15 Sep 17 15:48 stdin -> /proc/self/fd/0
lrwxrwxrwx    1 root     root            15 Sep 17 15:48 stdout -> /proc/self/fd/1
crw-rw-rw-    1 root     root        5,   0 Sep 17 15:48 tty
crw--w----    1 root     tty         4,   0 Sep 17 15:48 tty0
crw--w----    1 root     tty         4,   1 Sep 17 15:48 tty1
crw--w----    1 root     tty         4,  10 Sep 17 15:48 tty10
crw--w----    1 root     tty         4,  11 Sep 17 15:48 tty11
crw--w----    1 root     tty         4,  12 Sep 17 15:48 tty12
crw--w----    1 root     tty         4,  13 Sep 17 15:48 tty13
crw--w----    1 root     tty         4,  14 Sep 17 15:48 tty14
crw--w----    1 root     tty         4,  15 Sep 17 15:48 tty15
crw--w----    1 root     tty         4,  16 Sep 17 15:48 tty16
crw--w----    1 root     tty         4,  17 Sep 17 15:48 tty17
crw--w----    1 root     tty         4,  18 Sep 17 15:48 tty18
crw--w----    1 root     tty         4,  19 Sep 17 15:48 tty19
crw--w----    1 root     tty         4,   2 Sep 17 15:48 tty2
crw--w----    1 root     tty         4,  20 Sep 17 15:48 tty20
crw--w----    1 root     tty         4,  21 Sep 17 15:48 tty21
crw--w----    1 root     tty         4,  22 Sep 17 15:48 tty22
crw--w----    1 root     tty         4,  23 Sep 17 15:48 tty23
crw--w----    1 root     tty         4,  24 Sep 17 15:48 tty24
crw--w----    1 root     tty         4,  25 Sep 17 15:48 tty25
crw--w----    1 root     tty         4,  26 Sep 17 15:48 tty26
crw--w----    1 root     tty         4,  27 Sep 17 15:48 tty27
crw--w----    1 root     tty         4,  28 Sep 17 15:48 tty28
crw--w----    1 root     tty         4,  29 Sep 17 15:48 tty29
crw--w----    1 root     tty         4,   3 Sep 17 15:48 tty3
crw--w----    1 root     tty         4,  30 Sep 17 15:48 tty30
crw--w----    1 root     tty         4,  31 Sep 17 15:48 tty31
crw--w----    1 root     tty         4,  32 Sep 17 15:48 tty32
crw--w----    1 root     tty         4,  33 Sep 17 15:48 tty33
crw--w----    1 root     tty         4,  34 Sep 17 15:48 tty34
crw--w----    1 root     tty         4,  35 Sep 17 15:48 tty35
crw--w----    1 root     tty         4,  36 Sep 17 15:48 tty36
crw--w----    1 root     tty         4,  37 Sep 17 15:48 tty37
crw--w----    1 root     tty         4,  38 Sep 17 15:48 tty38
crw--w----    1 root     tty         4,  39 Sep 17 15:48 tty39
crw--w----    1 root     tty         4,   4 Sep 17 15:48 tty4
crw--w----    1 root     tty         4,  40 Sep 17 15:48 tty40
crw--w----    1 root     tty         4,  41 Sep 17 15:48 tty41
crw--w----    1 root     tty         4,  42 Sep 17 15:48 tty42
crw--w----    1 root     tty         4,  43 Sep 17 15:48 tty43
crw--w----    1 root     tty         4,  44 Sep 17 15:48 tty44
crw--w----    1 root     tty         4,  45 Sep 17 15:48 tty45
crw--w----    1 root     tty         4,  46 Sep 17 15:48 tty46
crw--w----    1 root     tty         4,  47 Sep 17 15:48 tty47
crw--w----    1 root     tty         4,  48 Sep 17 15:48 tty48
crw--w----    1 root     tty         4,  49 Sep 17 15:48 tty49
crw--w----    1 root     tty         4,   5 Sep 17 15:48 tty5
crw--w----    1 root     tty         4,  50 Sep 17 15:48 tty50
crw--w----    1 root     tty         4,  51 Sep 17 15:48 tty51
crw--w----    1 root     tty         4,  52 Sep 17 15:48 tty52
crw--w----    1 root     tty         4,  53 Sep 17 15:48 tty53
crw--w----    1 root     tty         4,  54 Sep 17 15:48 tty54
crw--w----    1 root     tty         4,  55 Sep 17 15:48 tty55
crw--w----    1 root     tty         4,  56 Sep 17 15:48 tty56
crw--w----    1 root     tty         4,  57 Sep 17 15:48 tty57
crw--w----    1 root     tty         4,  58 Sep 17 15:48 tty58
crw--w----    1 root     tty         4,  59 Sep 17 15:48 tty59
crw--w----    1 root     tty         4,   6 Sep 17 15:48 tty6
crw--w----    1 root     tty         4,  60 Sep 17 15:48 tty60
crw--w----    1 root     tty         4,  61 Sep 17 15:48 tty61
crw--w----    1 root     tty         4,  62 Sep 17 15:48 tty62
crw--w----    1 root     tty         4,  63 Sep 17 15:48 tty63
crw--w----    1 root     tty         4,   7 Sep 17 15:48 tty7
crw--w----    1 root     tty         4,   8 Sep 17 15:48 tty8
crw--w----    1 root     tty         4,   9 Sep 17 15:48 tty9
crw-rw----    1 root     audio       4,  64 Sep 17 15:48 ttyS0
crw-rw----    1 root     audio       4,  65 Sep 17 15:48 ttyS1
crw-rw----    1 root     audio       4,  66 Sep 17 15:48 ttyS2
crw-rw----    1 root     audio       4,  67 Sep 17 15:48 ttyS3
crw-------    1 root     root       10, 239 Sep 17 15:48 uhid
crw-------    1 root     root       10, 223 Sep 17 15:48 uinput
crw-rw-rw-    1 root     root        1,   9 Sep 17 15:48 urandom
crw-------    1 root     root      247,   0 Sep 17 15:48 usbmon0
crw-rw----    1 root     tty         7,   0 Sep 17 15:48 vcs
crw-rw----    1 root     tty         7,   1 Sep 17 15:48 vcs1
crw-rw----    1 root     tty         7,   2 Sep 17 15:48 vcs2
crw-rw----    1 root     tty         7,   3 Sep 17 15:48 vcs3
crw-rw----    1 root     tty         7,   4 Sep 17 15:48 vcs4
crw-rw----    1 root     tty         7,   5 Sep 17 15:48 vcs5
crw-rw----    1 root     tty         7,   6 Sep 17 15:48 vcs6
crw-rw----    1 root     tty         7, 128 Sep 17 15:48 vcsa
crw-rw----    1 root     tty         7, 129 Sep 17 15:48 vcsa1
crw-rw----    1 root     tty         7, 130 Sep 17 15:48 vcsa2
crw-rw----    1 root     tty         7, 131 Sep 17 15:48 vcsa3
crw-rw----    1 root     tty         7, 132 Sep 17 15:48 vcsa4
crw-rw----    1 root     tty         7, 133 Sep 17 15:48 vcsa5
crw-rw----    1 root     tty         7, 134 Sep 17 15:48 vcsa6
drwxr-xr-x    2 root     root            60 Sep 17 15:48 vfio
crw-------    1 root     root       10,  63 Sep 17 15:48 vga_arbiter
crw-------    1 root     root       10, 137 Sep 17 15:48 vhci
crw-------    1 root     root       10, 238 Sep 17 15:48 vhost-net
crw-rw-rw-    1 root     root        1,   5 Sep 17 15:48 zero
```
对比`/proc/$pid/status` ，

可以看到两个容器进程之间能力位图的差别，加上`--privileged` 的能力位图与超级用户的能力位图一样。

### 再对比增加`--privileged`后目录`/dev` 下文件变化，可以看到，加了特权后，宿主机所有设备文件都挂载在容器内。

我们可以看到，使用`--privileged` 参数授权给容器的权限太多，所以需要谨慎使用。如果需要挂载某个特定的设备，可以通过`--device`方式，只挂载需要使用的设备到容器中，而不是把宿主机的全部设备挂载到容器上。例如，为容器内挂载宿主机声卡：

```
$ docker run --device=/dev/snd:/dev/snd …
```

此外，可以通过`--add-cap` 和 `--drop-cap` 这两个参数来对容器的能力进行调整，以最大限度地保证容器使用的安全。

### 例如，给容器增加一个修改系统时间的命令：

```
$ docker run --cap-drop ALL --cap-add SYS_TIME ntpd /bin/sh
```

查看容器`PID`，执行`getpcaps PID`查看进程的能力，执行结果如下：

```
[root@VM_0_6_centos ~]# getpcaps 652
Capabilities for `652': = cap_chown,cap_dac_override,cap_fowner,cap_fsetid,cap_kill,cap_setgid,cap_setuid,cap_setpcap,cap_net_bind_service,cap_net_raw,cap_sys_chroot,cap_sys_time,...
[root@VM_0_6_centos ~]#
```

可以看到容器中已经增加了`sys_time` 能力，可以修改系统时间了。

## Docker镜像签名机制

### 当我们执行`docker pull` 镜像的时候，镜像仓库再验证完用户身份后，会先返回一个`manifest.json`文件，其中包含了`镜像名称`、`tag`、所有`layer层SHA256`值，还有镜像的签名信息，然后`docker daemon`会`并行`的下载这些`layer`层文件。

Docker 1.8以后，提供了一个数字签名机制`——content trust`来验证官方仓库镜像的来源和完整性,简单来说就是镜像制作者制作镜像时可以选择对镜像标签（`tag`）进行签名或者不签名，当`pull`镜像时，就可以通过这个签名进行校验，如果一致则认为数据源可靠，并下载镜像。

默认情况下，这个`content trust`是被关闭了的，你需要设置一个环境变量来开启这个机制，即：

```
$ export DOCKER_CONTENT_TRUST=11
```

当`content trust`机制被开启后，`docker`不会`pull`验证失败或者没有签名的镜像标签。当然也可以通过在`pull`时加上`--disable-content-trust`来暂时取消这个限制。


## Apparmor的MAC访问控制

### `AppArmor`和`SELinux`都是`Linux`安全模块，可以将进程的权限与进程`capabilities`能力联系在了一起，实现对进程的强制性访问控制（`MAC`）。

由`SELinux`有点复杂，经常都被人直接关闭，而`AppArmor`就相对要简单点。Docker官方也推荐这种方式。

`Docker` 自动为容器生成并加载名为` docker-default` 的默认配置文件。在 Docker 1.13.0和更高版本中，`Docker` 二进制文件在 `tmpfs` 中生成该配置文件，然后将其加载到内核中。在早于 1.13.0 的 Docker 版本上，此配置文件将在 `/etc/apparmor.d/docker` 中生成。`docker-default` 配置文件是运行容器的默认配置文件。它具有适度的保护性，同时提供广泛的应用兼容性。

**这个配置文件用于容器而不是 `Docker` 守护进程。运行容器时会使用 `docker-default` 策略，除非通过 `security-opt` 选项覆盖。**

下面我们使用`Nginx`做演示，提供一个自定义`AppArmor` 配置文件：

1、创建自定义配置文件，假设文件路径为 `/etc/apparmor.d/containers/docker-nginx `。

```
#include <tunables/global>

profile docker-nginx flags=(attach_disconnected,mediate_deleted) {
  #include <abstractions/base>
  ...
  deny network raw,
  ...
  deny /bin/** wl,
  deny /root/** wl,
  deny /bin/sh mrwklx,
  deny /bin/dash mrwklx,
  deny /usr/bin/top mrwklx,
  ...
}
```
2、加载配置文件

```
$ sudo apparmor_parser -r -W /etc/apparmor.d/containers/docker-nginx
```

3、使用这个配置文件运行容器

```
$ docker run --security-opt "apparmor=docker-nginx" -p 80:80 -d --name apparmor-nginx nginx12
```

4、进入运行中的容器中，尝试一些操作来测试配置是否生效：

```
$ docker container exec -it apparmor-nginx bash1
root@6da5a2a930b9:~# ping 8.8.8.8
ping: Lacking privilege for raw socket.

root@6da5a2a930b9:/# top
bash: /usr/bin/top: Permission denied

root@6da5a2a930b9:~# touch ~/thing
touch: cannot touch 'thing': Permission denied

root@6da5a2a930b9:/# sh
bash: /bin/sh: Permission denied
```

可以看到，我们通过 `apparmor` 配置文件可以对容器进行保护。

## Seccomp系统调用过滤

`Seccomp`是`Linux kernel` 从2.6.23版本开始所支持的一种安全机制，可用于限制进程能够调用的系统调用（`system call`）的范围。在`Linux`系统里，大量的系统调用（`systemcall`）直接暴露给用户态程序，但是，并不是所有的系统调用都被需要，而且不安全的代码滥用系统调用会对系统造成安全威胁。通过`Seccomp`，我们限制程序使用某些系统调用，这样可以减少系统的暴露面，同时使程序进入一种“安全”的状态。每个进程进行系统调用（`system call`）时，`kernel` 都会检查对应的白名单以确认该进程是否有权限使用这个系统调用。从Docker1.10版本开始，Docker安全特性中增加了对`Seccomp`的支持。

使用`Seccomp`的前提是`Docker`构建时已包含了`Seccomp`，并且内核中的`CONFIG_SECCOMP`已开启。可使用如下方法检查内核是否支持`Seccomp`：

```
$ cat /boot/config-`uname -r` | grep CONFIG_SECCOMP=
CONFIG_SECCOMP=y
```

默认的 `seccomp` 配置文件为使用 `seccomp `运行容器提供了一个合理的设置，并禁用了大约 `44` 个超过 `300+` 的系统调用。它具有适度的保护性，同时提供广泛的应用兼容性。默认的 `Docker` 配置文件可以在`moby源码profiles/seccomp/`下找到。

默认`seccomp profile`片段如下：

```
{
 "defaultAction": "SCMP_ACT_ERRNO",
 "archMap": [
  {
   "architecture": "SCMP_ARCH_X86_64",
   "subArchitectures": [
    "SCMP_ARCH_X86",
    "SCMP_ARCH_X32"
   ]
  },=
  ...
 ],
 "syscalls": [
  {
   "names": [
    "reboot"
   ],
   "action": "SCMP_ACT_ALLOW",
   "args": [],
   "comment": "",
   "includes": {
    "caps": [
     "CAP_SYS_BOOT"
    ]
   },
   "excludes": {}
  },
  ...
 ]
}
```

### `seccomp profile`包含`3`个部分：

默认操作，系统调用所支持的Linux架构和系统调用具体规则(syscalls)。对于每个调用规则，其中`name`是系统调用的名称，`action`是发生系统调用时`seccomp`的操作，`args`是系统调用的参数限制条件。

比如上面的`“SCMP_ACT_ALLOW”action`代表这个进程这个系统调用被允许，这个`call`，允许进程可以重启系统。

`seccomp` 有助于以最小权限运行 `Docker` 容器。不建议更改默认的 `seccomp `配置文件

运行容器时，如果没有通过 `--security-opt` 选项覆盖容器，则会使用默认配置。例如，以下显式指定了一个策略：

```
$ docker run --rm \
             -it \
             --security-opt seccomp=/path/to/seccomp/profile.json \
             hello-seccomp
  ```

Docker 的默认 seccomp 配置文件是一个白名单，它指定了允许的调用。Docker文档列举了所有不在白名单而被有效阻止的重要（但不是全部）系统调用以及每个系统调用被阻止的原因，







