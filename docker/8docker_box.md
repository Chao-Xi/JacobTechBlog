![Alt Image Text](images/headline8.jpg "Headline image")
# Docker安装和使用BusyBox、Alphine、Ubuntu/Debian、CentOS/Fedora等操作系统

目前常用的Linux发行版主要包括**Debian/Ubuntu**系列和**CentOS/Fedora**系列；使用Docker，只需要一个命令就能快速获取一个Linux发行版镜像，镜像一般都很精简，但是可以支持完整的Linux系统的大部分功能。

## 1、BusyBox
BusyBox是一个集成一百多个最常用的Linux命令和工具（如cat、echo、grep、mount、telnet等）的精简工具箱，它只有几MB的大小，很方便各种快速验证，可运行多款POSIX环境的操作系统中。

在Docker Hub中搜索busybox相关的镜像：

```
[vagrant@node1 ~]$ sudo docker search busybox
INDEX       NAME                                  DESCRIPTION                                     STARS     OFFICIAL   AUTOMATED
docker.io   docker.io/busybox                     Busybox base image.                             1312      [OK]
docker.io   docker.io/progrium/busybox                                                            67                   [OK]
docker.io   docker.io/hypriot/rpi-busybox-httpd   Raspberry Pi compatible Docker Image with ...   41
......

```
可以看到最受欢迎的镜像，带有OFFICIAL标记说明时官方的镜像，使用**`docker pull`** 指令下载**`busybox:latest`**：

```
[vagrant@node1 ~]$ sudo docker pull busybox
Using default tag: latest
Trying to pull repository docker.io/library/busybox ...
latest: Pulling from docker.io/library/busybox
Digest: sha256:cb63aa0641a885f54de20f61d152187419e8f6b159ed11a251a09d115fdff9bd
Status: Image is up to date for docker.io/busybox:latest


[vagrant@node1 ~]$ sudo docker images
REPOSITORY                    TAG                   IMAGE ID            CREATED             SIZE
exited.tar                    latest                8eb9635c4f15        22 hours ago        69.8 MB
jacob/python-web              testpythonwebserver   274abed832d4        38 hours ago        200 MB
docker.io/busybox             latest                e1ddd7948a1c        3 days ago          1.16 MB
docker.io/ubuntu              16.04                 7aa3602ab41e        8 days ago          115 MB
docker.io/ubuntu              latest                735f80812f90        8 days ago          83.5 MB
```

启动一个busybox容器，并查看挂在信息:

```
[vagrant@node1 ~]$ sudo docker run -it busybox
/ # mount
rootfs on / type rootfs (rw)
overlay on / type overlay (rw,relatime,lowerdir=/var/lib/docker/overlay2/l/LBNVPYLM4IZF66GP5ZHT2HKN6H:/var/lib/docker/overlay2/l/FMUCELPX2NYQ3DGVT2LVJKP4XS,upperdir=/var/lib/docker/overlay2/5485e2af4d4fe7f33efb1906e66587feb4fc982239373d65b6f3ac75c3e7edc9/diff,workdir=/var/lib/docker/overlay2/5485e2af4d4fe7f33efb1906e66587feb4fc982239373d65b6f3ac75c3e7edc9/work)
proc on /proc type proc (rw,nosuid,nodev,noexec,relatime)
tmpfs on /dev type tmpfs (rw,nosuid,mode=755)
devpts on /dev/pts type devpts (rw,nosuid,noexec,relatime,gid=5,mode=620,ptmxmode=666)
sysfs on /sys type sysfs (ro,nosuid,nodev,noexec,relatime)
tmpfs on /sys/fs/cgroup type tmpfs (ro,nosuid,nodev,noexec,relatime,mode=755)
cgroup on /sys/fs/cgroup/systemd type cgroup (ro,nosuid,nodev,noexec,relatime,xattr,release_agent=/usr/lib/systemd/systemd-cgroups-agent,name=systemd)
cgroup on /sys/fs/cgroup/cpuset type cgroup (ro,nosuid,nodev,noexec,relatime,cpuset)
cgroup on /sys/fs/cgroup/net_prio,net_cls type cgroup (ro,nosuid,nodev,noexec,relatime,net_prio,net_cls)
cgroup on /sys/fs/cgroup/hugetlb type cgroup (ro,nosuid,nodev,noexec,relatime,hugetlb)
cgroup on /sys/fs/cgroup/memory type cgroup (ro,nosuid,nodev,noexec,relatime,memory)
cgroup on /sys/fs/cgroup/perf_event type cgroup (ro,nosuid,nodev,noexec,relatime,perf_event)
cgroup on /sys/fs/cgroup/blkio type cgroup (ro,nosuid,nodev,noexec,relatime,blkio)
cgroup on /sys/fs/cgroup/devices type cgroup (ro,nosuid,nodev,noexec,relatime,devices)
cgroup on /sys/fs/cgroup/cpuacct,cpu type cgroup (ro,nosuid,nodev,noexec,relatime,cpuacct,cpu)
cgroup on /sys/fs/cgroup/freezer type cgroup (ro,nosuid,nodev,noexec,relatime,freezer)
cgroup on /sys/fs/cgroup/pids type cgroup (ro,nosuid,nodev,noexec,relatime,pids)
mqueue on /dev/mqueue type mqueue (rw,nosuid,nodev,noexec,relatime)
/dev/mapper/VolGroup00-LogVol00 on /etc/resolv.conf type xfs (rw,relatime,attr2,inode64,noquota)
/dev/mapper/VolGroup00-LogVol00 on /etc/hostname type xfs (rw,relatime,attr2,inode64,noquota)
/dev/mapper/VolGroup00-LogVol00 on /etc/hosts type xfs (rw,relatime,attr2,inode64,noquota)
shm on /dev/shm type tmpfs (rw,nosuid,nodev,noexec,relatime,size=65536k)
/dev/mapper/VolGroup00-LogVol00 on /run/secrets type xfs (rw,relatime,attr2,inode64,noquota)
devpts on /dev/console type devpts (rw,nosuid,noexec,relatime,gid=5,mode=620,ptmxmode=000)
proc on /proc/asound type proc (ro,nosuid,nodev,noexec,relatime)
proc on /proc/bus type proc (ro,nosuid,nodev,noexec,relatime)
proc on /proc/fs type proc (ro,nosuid,nodev,noexec,relatime)
proc on /proc/irq type proc (ro,nosuid,nodev,noexec,relatime)
proc on /proc/sys type proc (ro,nosuid,nodev,noexec,relatime)
proc on /proc/sysrq-trigger type proc (ro,nosuid,nodev,noexec,relatime)
tmpfs on /proc/kcore type tmpfs (rw,nosuid,mode=755)
tmpfs on /proc/timer_list type tmpfs (rw,nosuid,mode=755)
tmpfs on /proc/timer_stats type tmpfs (rw,nosuid,mode=755)
tmpfs on /proc/sched_debug type tmpfs (rw,nosuid,mode=755)
tmpfs on /proc/scsi type tmpfs (ro,relatime)
tmpfs on /sys/firmware type tmpfs (ro,relatime)
```
busybox镜像虽然小巧，但包括了大量的常见的Linux命令，可利用它熟悉Linux命令

## 2、Alpine

Alpine操作系统是一个面向安全的轻型Linux发行版，不同于通常的Linux发行版，Alpine采用了musl libc和BusyBox以减小系统的体积和运行时资源消耗，但功能上比BusyBox完善的多，Alpine还提供了自己的包管理工具apk，可以通过https://pkgs:alpinelinux.org/packages查询包信息，也可以通过apk命令直接查询和安装各种软件。相比于其他Docker镜像，它的容量非常小，仅仅只有5MB左右，并且拥有非常友好的包管理机制。

使用官方镜像
由于镜像很小，下载时间短，可以使用**`docker run`**指令直接运行一个alpine容器，并指定运行的linux指令：

```
[vagrant@node1 ~]$ sudo docker run alpine echo '123'
Unable to find image 'alpine:latest' locally
Trying to pull repository docker.io/library/alpine ...
latest: Pulling from docker.io/library/alpine
8e3ba11ec2a2: Pull complete
Digest: sha256:7043076348bf5040220df6ad703798fd8593a0918d06d3ce30c6c93be117e430
Status: Downloaded newer image for docker.io/alpine:latest
123


[vagrant@node1 ~]$ sudo docker ps -a
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                          PORTS                     NAMES
942ec00fe8c9        alpine              "echo 123"               12 seconds ago      Exited (0) 11 seconds ago                                 infallible_murdock
9a88d21d360f        busybox             "sh"                     3 minutes ago       Exited (0) About a minute ago                             eloquent_knuth
```
使用time工具测试在本地没有提前pull镜像的情况下，执行echo命令的时间，仅仅需要1秒左右

```
[vagrant@node1 ~]$ time sudo docker run alpine echo '123'
123

real	0m0.239s
user	0m0.025s
sys	0m0.015s
```

目前，大部分Docker官方镜像都已经支持Alpine作为基础镜像，因此可以很容易地进行迁移。


## 3、Debian/Ubuntu

Debian和Ubuntu都是目前较为流行的Debian系的服务器操作系统，十分适合研发场景。

### Debian系统简介及使用

Debian是由GPL和其他自由软件许可协议授权的自由软件组成的操作系统，由Debian Project组织维护；现在Debian包括了超过2500个软件包并支持12个计算系统架构，主要为采用Linux核心的Debian GNU/Linux系统，其他还有采用GNU Hurd核心的Debian GNU/Hurd系统、采用FreeBSD核心的Debian GNU/kFreeBSD系统，以及采用NetBSD核心的Debian GNU/NetBSD系统，甚至还有利用Debian的系统架构和工具，采用OpenSolais核心构建而成的Nexenta OS系统。在这些系统中，以采用Linux核心的Debian GNU/Linux最为著名。

使用**`docker search`**搜索Docker Hub，查找Debian镜像：

```
[vagrant@node1 ~]$ sudo docker search debian
INDEX       NAME                                          DESCRIPTION                                     STARS     OFFICIAL   AUTOMATED
docker.io   docker.io/ubuntu                              Ubuntu is a Debian-based Linux operating s...   8120      [OK]
docker.io   docker.io/debian                              Debian is a Linux distribution that's comp...   2691      [OK]
docker.io   docker.io/google/debian                                                                       53                   [OK]
docker.io   docker.io/neurodebian                         NeuroDebian provides neuroscience research...   50        [OK]
docker.io   docker.io/arm32v7/debian                      Debian is a Linux distribution that's comp...   38
docker.io   docker.io/armhf/debian                        Debian is a Linux distribution that's comp...   31
docker.io   docker.io/itscaro/debian-ssh                  debian:jessie                                   23                   [OK]
docker.io   docker.io/resin/armv7hf-debian                Debian is a Linux distro composed entirely...   20
docker.io   docker.io/samueldebruyn/debian-git            a minimal docker container with debian and...   18                   [OK]
docker.io   docker.io/eboraas/debian                      Debian base images, for all currently-avai...   8                    [OK]
docker.io   docker.io/i386/debian                         Debian is a Linux distribution that's comp...   7
docker.io   docker.io/rockyluke/debian                    Docker images of Debian.                        5
docker.io   docker.io/vergissberlin/debian-development    Docker debian image to use for development...   5                    [OK]
docker.io   docker.io/smartentry/debian                   debian with smartentry                          4                    [OK]
docker.io   docker.io/vicamo/debian                       Debian docker images for all versions/arch...   3
docker.io   docker.io/ppc64le/debian                      Debian is a Linux distribution that's comp...   2
docker.io   docker.io/s390x/debian                        Debian is a Linux distribution that's comp...   2
docker.io   docker.io/vpgrp/debian                        Docker images of Debian.                        2
docker.io   docker.io/holgerimbery/debian                 debian multiarch docker base image              1
docker.io   docker.io/casept/debian-amd64                 A debian image built from scratch. Mostly ...   0
docker.io   docker.io/fleshgrinder/debian                 Debian base images for production and mult...   0                    [OK]
docker.io   docker.io/igneoussystems/base-debian-client   Base image for debian clients                   0
docker.io   docker.io/jdub/debian-sources-resource        Concourse CI resource to check for updated...   0                    [OK]
```

官方提供的Debian镜像以及面向科研领域的neurodebian镜像。

可以使用`docker run`直接运行debian镜像：

```
[vagrant@node1 ~]$ sudo docker run -it debian bash
Unable to find image 'debian:latest' locally
Trying to pull repository docker.io/library/debian ...
latest: Pulling from docker.io/library/debian
55cbf04beb70: Pull complete
Digest: sha256:f1f61086ea01a72b30c7287adee8c929e569853de03b7c462a8ac75e0d0224c4
Status: Downloaded newer image for docker.io/debian:latest
root@824a28b8830a:/# cat /etc/issue
Debian GNU/Linux 9 \n \l
```
debian镜像很适合作为基础镜像，用于构建自定义镜像。

### Ubuntu系统简介及使用

Ubuntu是一个以桌面应用为主的GUN/Linux操作系统，基于Debian发行版和GNOME/Unity桌面环境，与Debian的不同在于它每6个月会发行一个新版本，每2年会推出一个长期支持（Long Term Support，LTS）版本，一般支持3年。

Ubuntu相关的镜像有很多，在Docker Hub上使用**`-s 10`**参数进行搜索，只搜索那些被收藏10次以上的镜像：

```
[vagrant@node1 ~]$ sudo docker search  -s 10 ubuntu
Flag --stars has been deprecated, use --filter=stars=3 instead
INDEX       NAME                                                             DESCRIPTION                                     STARS     OFFICIAL   AUTOMATED
docker.io   docker.io/ubuntu                                                 Ubuntu is a Debian-based Linux operating s...   8120      [OK]
docker.io   docker.io/dorowu/ubuntu-desktop-lxde-vnc                         Ubuntu with openssh-server and NoVNC            204                  [OK]
docker.io   docker.io/rastasheep/ubuntu-sshd                                 Dockerized SSH service, built on top of of...   162                  [OK]
docker.io   docker.io/consol/ubuntu-xfce-vnc                                 Ubuntu container with "headless" VNC sessi...   122                  [OK]
docker.io   docker.io/ansible/ubuntu14.04-ansible                            Ubuntu 14.04 LTS with ansible                   94                   [OK]
docker.io   docker.io/ubuntu-upstart                                         Upstart is an event-based replacement for ...   87        [OK]
docker.io   docker.io/neurodebian                                            NeuroDebian provides neuroscience research...   50        [OK]
docker.io   docker.io/1and1internet/ubuntu-16-nginx-php-phpmyadmin-mysql-5   ubuntu-16-nginx-php-phpmyadmin-mysql-5          42                   [OK]
docker.io   docker.io/ubuntu-debootstrap                                     debootstrap --variant=minbase --components...   39        [OK]
docker.io   docker.io/nuagebec/ubuntu                                        Simple always updated Ubuntu docker images...   23                   [OK]
docker.io   docker.io/tutum/ubuntu                                           Simple Ubuntu docker images with SSH access     18
docker.io   docker.io/i386/ubuntu                                            Ubuntu is a Debian-based Linux operating s...   13
docker.io   docker.io/1and1internet/ubuntu-16-apache-php-7.0                 ubuntu-16-apache-php-7.0                        12                   [OK]
docker.io   docker.io/ppc64le/ubuntu                                         Ubuntu is a Debian-based Linux operating s...   12
```

Docker1.12版本中已经不支持**`--stars`**参数了，可以使用**`-f stars=N`**参数。

使用Ubuntu14.04镜像安装一些常用软件；首先使用**`-it`**参数启动容器，登陆bash，参看ubuntu的发行版本号：

```
[vagrant@node1 ~]$ sudo docker pull ubuntu:14.04
Trying to pull repository docker.io/library/ubuntu ...
14.04: Pulling from docker.io/library/ubuntu
8284e13a281d: Pull complete
26e1916a9297: Pull complete
4102fc66d4ab: Pull complete
1cf2b01777b2: Pull complete
7f7a2d5e04ed: Pull complete
Digest: sha256:71529e96591eb36a4100cd0cc5353ff1a2f4ee7a85011e3d3dd07cb5eb524a3e
Status: Downloaded newer image for docker.io/ubuntu:14.04


[vagrant@node1 ~]$ sudo docker images
REPOSITORY                    TAG                   IMAGE ID            CREATED             SIZE
exited.tar                    latest                8eb9635c4f15        22 hours ago        69.8 MB
jacob/python-web              testpythonwebserver   274abed832d4        38 hours ago        200 MB
docker.io/busybox             latest                e1ddd7948a1c        3 days ago          1.16 MB
docker.io/ubuntu              16.04                 7aa3602ab41e        8 days ago          115 MB
docker.io/ubuntu              latest                735f80812f90        8 days ago          83.5 MB
docker.io/ubuntu              14.04                 971bb384a50a        2 weeks ago         188 MB

[vagrant@node1 ~]$ sudo docker run -it ubuntu:14.04 /bin/bash

root@5511b0556761:/# lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 14.04.5 LTS
Release:	14.04
Codename:	trusty
```

直接使用apt-get安装一个软件的时候，会提示`E：Unable to locate package`:

```
root@fab691c91210:/# apt-get install curl
Reading package lists... Done
Building dependency tree
Reading state information... Done
E: Unable to locate package curl
```
这并非系统不支持apt-get命令，Docker镜像在制作时为了精简清楚了apt仓库信息，因此需要先执行apt-get update命令来更新信息，更新信息后即可成功通过apt-get命令安装软件：

```
root@fab691c91210:/# apt-get update
Get:1 http://security.ubuntu.com trusty-security InRelease [65.9 kB]
Ign http://archive.ubuntu.com trusty InRelease
Get:2 http://archive.ubuntu.com trusty-updates InRelease [65.9 kB]
Get:3 http://security.ubuntu.com trusty-security/universe Sources [92.5 kB]
Get:4 http://security.ubuntu.com trusty-security/main amd64 Packages [941 kB]
Get:5 http://archive.ubuntu.com trusty-backports InRelease [65.9 kB]
Get:6 http://archive.ubuntu.com trusty Release.gpg [933 B]
Get:7 http://archive.ubuntu.com trusty-updates/universe Sources [256 kB]
Get:8 http://security.ubuntu.com trusty-security/restricted amd64 Packages [18.1 kB]
Get:9 http://security.ubuntu.com trusty-security/universe amd64 Packages [303 kB]
Get:10 http://archive.ubuntu.com trusty-updates/main amd64 Packages [1360 kB]
Get:11 http://security.ubuntu.com trusty-security/multiverse amd64 Packages [4727 B]
Get:12 http://archive.ubuntu.com trusty-updates/restricted amd64 Packages [21.4 kB]
Get:13 http://archive.ubuntu.com trusty-updates/universe amd64 Packages [598 kB]
Get:14 http://archive.ubuntu.com trusty-updates/multiverse amd64 Packages [16.0 kB]
Get:15 http://archive.ubuntu.com trusty-backports/main amd64 Packages [14.7 kB]
Get:16 http://archive.ubuntu.com trusty-backports/restricted amd64 Packages [40 B]
Get:17 http://archive.ubuntu.com trusty-backports/universe amd64 Packages [52.5 kB]
Get:18 http://archive.ubuntu.com trusty-backports/multiverse amd64 Packages [1392 B]
Get:19 http://archive.ubuntu.com trusty Release [58.5 kB]
Get:20 http://archive.ubuntu.com trusty/universe Sources [7926 kB]
Get:21 http://archive.ubuntu.com trusty/main amd64 Packages [1743 kB]
Get:22 http://archive.ubuntu.com trusty/restricted amd64 Packages [16.0 kB]
Get:23 http://archive.ubuntu.com trusty/universe amd64 Packages [7589 kB]
Get:24 http://archive.ubuntu.com trusty/multiverse amd64 Packages [169 kB]
Fetched 21.4 MB in 15s (1348 kB/s)
Reading package lists... Done
```

安装curl工具：

```
root@fab691c91210:/# apt-get install curl -y
Reading package lists... Done
Building dependency tree
Reading state information... Done
The following extra packages will be installed:
  ca-certificates krb5-locales libasn1-8-heimdal libcurl3 libgssapi-krb5-2
  libgssapi3-heimdal libhcrypto4-heimdal libheimbase1-heimdal
  libheimntlm0-heimdal libhx509-5-heimdal libidn11 libk5crypto3 libkeyutils1
  libkrb5-26-heimdal libkrb5-3 libkrb5support0 libldap-2.4-2
  libroken18-heimdal librtmp0 libsasl2-2 libsasl2-modules libsasl2-modules-db
  libwind0-heimdal openssl
rocessing triggers for libc-bin (2.19-0ubuntu6.14) ...
Processing triggers for ca-certificates (20170717~14.04.1) ...
Updating certificates in /etc/ssl/certs... 148 added, 0 removed; done.
Running hooks in /etc/ca-certificates/update.d....done.
```

接下来安装apache服务

```
root@fab691c91210:/# apt-get install -y apache2
Reading package lists... Done
Building dependency tree
Reading state information... Done
The following extra packages will be installed:
  apache2-bin apache2-data libapr1 libaprutil1 libaprutil1-dbd-sqlite3
  libaprutil1-ldap libxml2 sgml-base ssl-cert xml-core
Suggested packages:
  www-browser apache2-doc apache2-suexec-pristine apache2-suexec-custom ufw
  apache2-utils sgml-base-doc openssl-blacklist debhelper
The following NEW packages will be installed:
  apache2 apache2-bin apache2-data libapr1 libaprutil1 libaprutil1-dbd-sqlite3
  libaprutil1-ldap libxml2 sgml-base ssl-cert xml-core
0 upgraded, 11 newly installed, 0 to remove and 3 not upgraded.
Need to get 1898 kB of archives.
```

启动apache服务，查看端口启动：

```
root@fab691c91210:/# service apache2 start
 * Starting web server apache2                                                                                                                                        AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using 172.17.0.3. Set the 'ServerName' directive globally to suppress this message
 *
```

```
root@fab691c91210:/# netstat -lnotp
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name Timer
tcp6       0      0 :::80                   :::*                    LISTEN      3345/apache2     off (0.00/0/0)
```

## 4、CentOS/Fedora

### CentOS系统简介及使用

**CentOS**和**Fedora**都是基于Redhat的常见Linux分支，CectOS是目前企业级服务器的常用操作系统；Fedora则主要面向个人桌面用户。由于CentOS与Redhat Linux源于相同的代码基础，所以很多成本敏感且需要高稳定性的公司就使用CentOS来代替商业版**Redhat Hat Eeterprise Linux**。CentOS自身不包含闭源软件。

在Docker Hub上使用`docker search`命令来搜索标星为25的CentOS相关镜像：

```
[vagrant@node1 ~]$ sudo docker search  -f stars=25 centos
INDEX       NAME                                        DESCRIPTION                                     STARS     OFFICIAL   AUTOMATED
docker.io   docker.io/centos                            The official build of CentOS.                   4553      [OK]
docker.io   docker.io/ansible/centos7-ansible           Ansible on Centos7                              115                  [OK]
docker.io   docker.io/jdeathe/centos-ssh                CentOS-6 6.9 x86_64 / CentOS-7 7.4.1708 x8...   98                   [OK]
docker.io   docker.io/consol/centos-xfce-vnc            Centos container with "headless" VNC sessi...   58                   [OK]
docker.io   docker.io/imagine10255/centos6-lnmp-php56   centos6-lnmp-php56                              44                   [OK]
docker.io   docker.io/tutum/centos                      Simple CentOS docker image with SSH access      43
docker.io   docker.io/centos/mysql-57-centos7           MySQL 5.7 SQL database server                   35
docker.io   docker.io/gluster/gluster-centos            Official GlusterFS Image [ CentOS-7 +  Glu...   31                   [OK]
docker.io   docker.io/openshift/base-centos7            A Centos7 derived base image for Source-To...   31
docker.io   docker.io/centos/python-35-centos7          Platform for building and running Python 3...   27
```
使用**`docker run`**直接运行最新的CentOS镜像，并登录shell：

```
[vagrant@node1 ~]$ sudo docker pull centos
Using default tag: latest
Trying to pull repository docker.io/library/centos ...
latest: Pulling from docker.io/library/centos
256b176beaff: Pull complete
Digest: sha256:841b391425fbee381551ad319ce93d6495a2fe42ccb154864106d7e1dbb2e361
Status: Downloaded newer image for docker.io/centos:latest

[vagrant@node1 ~]$ sudo docker images
REPOSITORY                    TAG                   IMAGE ID            CREATED                  SIZE
docker.io/centos              latest                5182e96772bf        Less than a second ago   200 MB
```

```
[vagrant@node1 ~]$ sudo docker run -it centos /bin/bash
[root@29f7586724e6 /]# cat /etc/redhat-release
CentOS Linux release 7.5.1804 (Core)
```

### Fedora系统简介及使用

Fedora是由Fedora Project社区开发，目标是创建一套新颖、多功能并且自由和开源的操作系统；对用户而言，Fedora是一套功能完备的、可以更新的免费操作系统，而对赞助商Red Hat而言，它是许多新技术的测试平台，被认为可用的技术最终加入到Red Hat Enterprise Linux中。

在Docker Hub上使用docker search命令搜索星至少为2的Fedora相关镜像：

```
[vagrant@node1 ~]$ sudo docker search  -f stars=2 fedora
INDEX       NAME                                DESCRIPTION                                     STARS     OFFICIAL   AUTOMATED
docker.io   docker.io/fedora                    Official Docker builds of Fedora                684       [OK]
docker.io   docker.io/fedora/apache                                                             34                   [OK]
docker.io   docker.io/mattsch/fedora-nzbhydra   Fedora NZBHydra                                 5                    [OK]
docker.io   docker.io/darksheer/fedora22        Base Fedora 22 Image -- Updated hourly          2                    [OK]
docker.io   docker.io/vbatts/fedora-varnish     https://github.com/vbatts/laughing-octo/tr...   2                    [OK]
```

使用docker run命令直接运行Fedora官方镜像，并登录bash：

```
[vagrant@node1 ~]$ sudo docker pull fedora
Using default tag: latest
Trying to pull repository docker.io/library/fedora ...
latest: Pulling from docker.io/library/fedora
e71c36a80ba9: Pull complete
Digest: sha256:7ae08e5637170eb47c01e315b6e64e0d48c6200d2942c695d0bee61b38c65b39
Status: Downloaded newer image for docker.io/fedora:latest
[vagrant@node1 ~]$ sudo docker images
REPOSITORY                    TAG                   IMAGE ID            CREATED                  SIZE
docker.io/centos              latest                5182e96772bf        Less than a second ago   200 MB
docker.io/fedora              latest                cc510acfcd70        3 months ago             253 MB
```
```
[vagrant@node1 ~]$ sudo docekr run -it fedora bash
sudo: docekr: command not found
[vagrant@node1 ~]$ sudo docker run -it fedora bash
[root@30453a92f346 /]# cat /etc/redhat-release
Fedora release 28 (Twenty Eight)
```

