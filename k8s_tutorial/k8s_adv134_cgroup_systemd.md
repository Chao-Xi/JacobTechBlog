# K8s 选 cgroupfs 还是 systemd

## 什么是 cgroup

Cgroup 是一个 Linux 内核特性，**对一组进程的资源使用（CPU、内存、磁盘 I/O 和网络等）进行限制、审计和隔离**。

**cgroups(Control Groups) 是 linux 内核提供的一种机制，这种机制可以根据需求把一系列系统任务及其子任务整合 (或分隔) 到按资源划分等级的不同组内，从而为系统资源管理提供一个统一的框架**。

简单说，**cgroups 可以限制、记录任务组所使用的物理资源。**

本质上来说，cgroups 是内核附加在程序上的一系列钩子 (hook)，**通过程序运行时对资源的调度触发相应的钩子以达到资源追踪和限制的目的**。


### 什么是 cgroupfs

docker 默认的 Cgroup Driver 是 cgroupfs

```
$ docker info | grep cgroup
 Cgroup Driver: cgroupfs
```

Cgroup 提供了一个原生接口并通过 cgroupfs 提供（从这句话我们可以知道 cgroupfs 就是 Cgroup 的一个接口的封装）。

类似于 `procfs` 和 `sysfs`，是一种虚拟文件系统。并且 cgroupfs 是可以挂载的，默认情况下挂载在 `/sys/fs/cgroup` 目录。

Cgroup 提供了一个原生接口并通过 cgroupfs 提供（从这句话我们可以知道 cgroupfs 就是 Cgroup 的一个接口的封装）。

**类似于 procfs 和 sysfs，是一种虚拟文件系统。并且 `cgroupfs` 是可以挂载的，默认情况下挂载在 `/sys/fs/cgroup` 目录**。

### 什么是 Systemd？

Systemd 也是对于 Cgroup 接口的一个封装。systemd 以 PID1 的形式在系统启动的时候运行，并提供了一套系统管理守护程序、库和实用程序，用来控制、管理 Linux 计算机操作系统资源。

### **为什么使用 systemd 而不是 croupfs**

ubuntu 系统，debian 系统，centos7 系统，都是使用 systemd 初始化系统的。systemd 这边已经有一套 cgroup 管理器了，如果容器运行时和 kubelet 使用 cgroupfs，此时就会存在 cgroups 和 systemd 两种 cgroup 管理器。

也就意味着操作系统里面存在两种资源分配的视图，当操作系统上存在 CPU，内存等等资源不足的时候，操作系统上的进程会变得不稳定。

### **如何修改 docker 默认的 cgroup 驱动**

增加 `"exec-opts": ["native.cgroupdriver=systemd"]` 配置 , 重启 docker 即可

```
$ cat /etc/docker/daemon.json 
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "http://hub-mirror.c.163.com"
  ],
  "max-concurrent-downloads": 10,
  "log-driver": "json-file",
  "log-level": "warn",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
    },
  "data-root": "/var/lib/docker"
}
```

kubelet 配置 cgroup 驱动


**说明： 在版本 1.22 中，如果用户没有在 KubeletConfiguration 中设置 cgroupDriver 字段， kubeadm init 会将它设置为默认值 systemd。**

```
# kubeadm-config.yaml
kind: ClusterConfiguration
apiVersion: kubeadm.k8s.io/v1beta3
kubernetesVersion: v1.21.0
---
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
cgroupDriver: systemd
```

然后使用 kubeadm 初始化

```
$ kubeadm init --config kubeadm-config.yaml

```
