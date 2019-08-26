# 使用 kubeadm 搭建 v1.15.3 版本 Kubernetes 集群

以前文章和视频中都是使用的 Kubeadm 搭建的 Kubernetes 集群，[但是版本比较低了（1.12.0版本）](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_dev/kubeadm12/README.md)，近期有不少反馈让更新下版本，本文将通过 Kubeadm 来搭建最新版本的 `Kubernetes 1.15.3` 集群，其实和以前搭建的方式方法基本一致，**我们这里准备使用 `calico` 网络插件以及 `ipvs` 模式的 `kube-proxy`**。

## 环境准备

`3`个节点，都是 Centos 7.6 系统，内核版本：3.10.0-957.12.2.el7.x86_64，在每个节点上添加 hosts 信息：

```
$ uname -a
3.10.0-957.27.2.el7.x86_64
```

```
$ cat /etc/hosts
$ sudo vi /etc/hosts`
10.151.30.11 jabox
10.151.30.22 jabox-node1
10.151.30.23 jabox-node2
```

禁用防火墙：

```
sudo systemctl stop firewalld
sudo systemctl disable firewalld
```

禁用`SELINUX`：

```
$ setenforce 0
$ cat /etc/selinux/config
SELINUX=disabled

$ sudo vi /etc/selinux/config
SELINUX=disabled
```

创建`/etc/sysctl.d/k8s.conf`文件，添加如下内容：

```
$ sudo vi /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
```

执行如下命令使修改生效：

```
sudo modprobe br_netfilter
sudo sysctl -p /etc/sysctl.d/k8s.conf
```

#### 安装 `ipvs`

```
$ cd /etc/sysconfig/modules/
$ sudo vi ipvs.modules

#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
```


```
$ sudo chmod 755 /etc/sysconfig/modules/ipvs.modules
$ sudo bash /etc/sysconfig/modules/ipvs.modules
$ sudo lsmod | grep -e ip_vs -e nf_conntrack_ipv4
```


上面脚本创建了的 `/etc/sysconfig/modules/ipvs.modules` 文件，保证在节点重启后能自动加载所需模块。

使用 `lsmod | grep -e ip_vs -e nf_conntrack_ipv4`命令查看是否已经正确加载所需的内核模块。

```
$ lsmod | grep -e ip_vs -e nf_conntrack_ipv4
nf_conntrack_ipv4      15053  4
nf_defrag_ipv4         12729  1 nf_conntrack_ipv4
ip_vs_sh               12688  0
ip_vs_wrr              12697  0
ip_vs_rr               12600  10
ip_vs                 145497  16 ip_vs_rr,ip_vs_sh,ip_vs_wrr
nf_conntrack          137239  7 ip_vs,nf_nat,nf_nat_ipv4,xt_conntrack,nf_nat_masquerade_ipv4,nf_conntrack_netlink,nf_conntrack_ipv4
libcrc32c              12644  4 xfs,ip_vs,nf_nat,nf_conntrack
```

#### 接下来还需要确保各个节点上已经安装了 `ipset` 软件包：

**optional**

```
$ sudo yum -y update
$ sudo yum -y install epel-release
```

接下来还需要确保各个节点上已经安装了 ipset 软件包：

```
$ sudo yum install ipset
```

**为了便于查看 `ipvs` 的代理规则，最好安装一下管理工具 ipvsadm**：

```
$ sudo yum install ipvsadm
```

#### 同步服务器时间

```
$ sudo yum install chrony -y
$ sudo systemctl enable chronyd
$ sudo systemctl start chronyd
$ sudo systemctl status chronyd
```

```
$ sudo systemctl status chronyd
● chronyd.service - NTP client/server
   Loaded: loaded (/usr/lib/systemd/system/chronyd.service; enabled; vendor preset: enabled)
   Active: active (running) since Tue 2019-08-27 08:22:32 UTC; 1h 54min ago
     Docs: man:chronyd(8)
           man:chrony.conf(5)
 Main PID: 433 (chronyd)
    Tasks: 1
   Memory: 536.0K
   CGroup: /system.slice/chronyd.service
           └─433 /usr/sbin/chronyd
```

```
$ chronyc sources
210 Number of sources = 4
MS Name/IP address         Stratum Poll Reach LastRx Last sample
===============================================================================
^? cooler.krajany.vn.ua          2  10     0   909    +11ms[  +11ms] +/-  217ms
^? montreal.ca.logiplex.net      2  10     0   635  -6973us[-6973us] +/-  171ms
^? ntp.xtom.nl                   2   9     0   23m  -6963us[-4331us] +/-  155ms
^? 203.107.6.88                  2   6     1     9  -54879s[-54879s] +/-   20ms
```

```
$ date
Tue Aug 27 10:17:26 UTC 2019
```

#### 关闭 `swap` 分区：

```
$ sudo swapoff -a
```

**修改`/etc/fstab`文件，注释掉 `SWAP` 的自动挂载**

```
sudo vi /etc/fstab
```

使用`free -m`确认 `swap` 已经关闭

```
$ free -m
              total        used        free      shared  buff/cache   available
Mem:            991         604          60           7         326         202
Swap:             0           0           0
```

**`swappiness` 参数调整，修改`/etc/sysctl.d/k8s.conf`添加下面一行**：

```
$ sudo vi /etc/sysctl.d/k8s.conf
vm.swappiness=0
```



**执行`sysctl -p /etc/sysctl.d/k8s.conf`使修改生效。**

`sudo sysctl -p /etc/sysctl.d/k8s.conf`

#### 接下来可以安装 Docker

```
$ sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2


$ sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

$ sudo yum list docker-ce --showduplicates | sort -r
Failed to set locale, defaulting to C
docker-ce.x86_64            3:19.03.1-3.el7                    docker-ce-stable
docker-ce.x86_64            3:19.03.1-3.el7                    @docker-ce-stable
docker-ce.x86_64            3:19.03.0-3.el7                    docker-ce-stable
docker-ce.x86_64            3:18.09.8-3.el7                    docker-ce-stable
docker-ce.x86_64            3:18.09.7-3.el7                    docker-ce-stable
docker-ce.x86_64            3:18.09.6-3.el7                    docker-ce-stable
docker-ce.x86_64            3:18.09.5-3.el7                    docker-ce-stable
docker-ce.x86_64            3:18.09.4-3.el7                    docker-ce-stable
docker-ce.x86_64            3:18.09.3-3.el7                    docker-ce-stable
docker-ce.x86_64            3:18.09.2-3.el7                    docker-ce-stable
docker-ce.x86_64            3:18.09.1-3.el7                    docker-ce-stable
docker-ce.x86_64            3:18.09.0-3.el7                    docker-ce-stable
docker-ce.x86_64            18.06.3.ce-3.el7                   docker-ce-stable
docker-ce.x86_64            18.06.2.ce-3.el7                   docker-ce-stable
docker-ce.x86_64            18.06.1.ce-3.el7                   docker-ce-stable
docker-ce.x86_64            18.06.0.ce-3.el7                   docker-ce-stable
docker-ce.x86_64            18.03.1.ce-1.el7.centos            docker-ce-stable
docker-ce.x86_64            18.03.0.ce-1.el7.centos            docker-ce-stable
docker-ce.x86_64            17.12.1.ce-1.el7.centos            docker-ce-stable
docker-ce.x86_64            17.12.0.ce-1.el7.centos            docker-ce-stable
docker-ce.x86_64            17.09.1.ce-1.el7.centos            docker-ce-stable
docker-ce.x86_64            17.09.0.ce-1.el7.centos            docker-ce-stable
docker-ce.x86_64            17.06.2.ce-1.el7.centos            docker-ce-stable
docker-ce.x86_64            17.06.1.ce-1.el7.centos            docker-ce-stable
docker-ce.x86_64            17.06.0.ce-1.el7.centos            docker-ce-stable
docker-ce.x86_64            17.03.3.ce-1.el7                   docker-ce-stable
docker-ce.x86_64            17.03.2.ce-1.el7.centos            docker-ce-stable
docker-ce.x86_64            17.03.1.ce-1.el7.centos            docker-ce-stable
docker-ce.x86_64            17.03.0.ce-1.el7.centos            docker-ce-stable
Loading mirror speeds from cached hostfile
Loaded plugins: fastestmirror
Installed Packages
Available Packages
 * updates: mirrors.cn99.com
 * extras: mirrors.163.com
 * epel: mirror01.idc.hinet.net
 * base: mirrors.163.com
```

可以选择安装一个版本，比如我们这里安装最新版本：

```
$ sudo yum install docker-ce-19.03.1-3.el7
```

**Optional:**

```
$ vi /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "registry-mirrors" : [
    "https://ot2k4d59.mirror.aliyuncs.com/"
  ]
}
```

启动 Docker

```
$ sudo systemctl start docker
$ sudo systemctl enable docker
$ sudo systemctl status docker
```

在确保 `Docker` 安装完成后，上面的相关环境配置也完成了，

**现在我们就可以来安装 `Kubeadm` 了，我们这里是通过指定`yum` 源的方式来进行安装的：**

```
$ cd /etc/yum.repos.d
$ sudo vi kubernetes.repo
```

```
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
```

当然了，上面的 `yum` 源是需要科学上网的，如果不能科学上网的话，**我们可以使用阿里云的源进行安装(my choice)**：

```
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
        http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
```


然后安装 `kubeadm`、`kubelet`、`kubectl`：

```
$ sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
```

```
$ kubeadm version
kubeadm version: &version.Info{Major:"1", Minor:"15", GitVersion:"v1.15.3", GitCommit:"2d3c76f9091b6bec110a5e63777c332469e0cba2", GitTreeState:"clean", BuildDate:"2019-08-19T11:11:18Z", GoVersion:"go1.12.9", Compiler:"gc", Platform:"linux/amd64"}
```

**可以看到我们这里安装的是 `v1.15.3` 版本，然后将 `kubelet` 设置成开机启动**：

```
sudo systemctl enable kubelet.service
```

> ### 到这里为止上面所有的操作都需要在所有节点执行配置。


## 初始化集群

然后接下来在 `master` 节点配置 `kubeadm` 初始化文件，可以通过如下命令导出默认的初始化配置：

```
$ kubeadm config print init-defaults > kubeadm.yaml
```

然后根据我们自己的需求修改配置，比如修改 `imageRepository` 的值，`kube-proxy` 的模式为 `ipvs`，另外需要注意的是我们这里是准备安装 `calico` 网络插件的，需要将 `networking.podSubnet` 设置为`192.168.0.0/16`：

```
apiVersion: kubeadm.k8s.io/v1beta2
bootstrapTokens:
- groups:
  - system:bootstrappers:kubeadm:default-node-token
  token: abcdef.0123456789abcdef
  ttl: 24h0m0s
  usages:
  - signing
  - authentication
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: 10.151.30.11 # apiserver 节点内网IP  ❤️
  bindPort: 6443     ❤️
nodeRegistration:
  criSocket: /var/run/dockershim.sock
  name: jabox
  taints:
  - effect: NoSchedule
    key: node-role.kubernetes.io/master
---
apiServer:
  timeoutForControlPlane: 4m0s
apiVersion: kubeadm.k8s.io/v1beta2
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controllerManager: {}
dns:
  type: CoreDNS   # dns类型  ❤️
etcd:
  local:
    dataDir: /var/lib/etcd
imageRepository: gcr.azk8s.cn/google_containers # gcr.azk8s.cn  ❤️
kind: ClusterConfiguration
kubernetesVersion: v1.15.3  # k8s版本 ❤️
networking:
  dnsDomain: cluster.local
  serviceSubnet: 192.168.0.0/16     ❤️
  serviceSubnet: 10.96.0.0/12       ❤️
scheduler: {}
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: ipvs       # kube-proxy 模式   ❤️
```

然后使用上面的配置文件进行初始化：

```
$ sudo kubeadm init --config kubeadm.yaml
```

```
W0827 08:27:34.909696    3572 strict.go:54] error unmarshaling configuration schema.GroupVersionKind{Group:"kubeadm.k8s.io", Version:"v1beta2", Kind:"ClusterConfiguration"}: error converting YAML to JSON: yaml: unmarshal errors:
  line 18: key "serviceSubnet" already set in map
[init] Using Kubernetes version: v1.15.3
[preflight] Running pre-flight checks
	[WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/
	[WARNING SystemVerification]: this Docker version is not on the list of validated versions: 19.03.1. Latest validated version: 18.09
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Activating the kubelet service
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [jabox localhost] and IPs [10.151.30.11 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [jabox localhost] and IPs [10.151.30.11 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [jabox kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 10.151.30.11]
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "sa" key and public key
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "kubelet.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
[control-plane] Creating static Pod manifest for "kube-scheduler"
[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
[apiclient] All control plane components are healthy after 39.003591 seconds
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config-1.15" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Skipping phase. Please see --upload-certs
[mark-control-plane] Marking the node jabox as control-plane by adding the label "node-role.kubernetes.io/master=''"
[mark-control-plane] Marking the node jabox as control-plane by adding the taints [node-role.kubernetes.io/master:NoSchedule]
[kubelet-check] Initial timeout of 40s passed.
[bootstrap-token] Using token: abcdef.0123456789abcdef
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 10.151.30.11:6443 --token abcdef.0123456789abcdef \
    --discovery-token-ca-cert-hash sha256:fd41714893497adf4d44919788049ea398290d0fb36618fbb9b09609e36ab585
```

> 可以看到最新验证的 `docker` 版本是`18.09`，虽然是一个 `warning`，所以最好还是安装`18.09`版本的 `docker`。

> `Master node`需要两个以上的`CPUS`, 所以 master 的 [Vagrantfile](vagrant/jx1-Vagrantfile)	

拷贝 `kubeconfig` 文件

```
$ mkdir -p $HOME/.kube
$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
$ sudo chown $(id -u):$(id -g) $HOME/.kube/config
```


## 添加节点


记住初始化集群上面的配置和操作要提前做好，将 `master` 节点上面的 `$HOME/.kube/config` 文件拷贝到 `node` 节点对应的文件中，安装 `kubeadm`、`kubelet`、`kubectl`，然后执行上面初始化完成后提示的 `join` 命令即可：


```
$ sudo kubeadm join 10.151.30.11:6443 --token abcdef.0123456789abcdef \
    --discovery-token-ca-cert-hash sha256:fd41714893497adf4d44919788049ea398290d0fb36618fbb9b09609e36ab585

[preflight] Running pre-flight checks
	[WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/
	[WARNING SystemVerification]: this Docker version is not on the list of validated versions: 19.03.1. Latest validated version: 18.09
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
[kubelet-start] Downloading configuration for the kubelet from the "kubelet-config-1.15" ConfigMap in the kube-system namespace
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Activating the kubelet service
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
```

> ### 如果忘记了上面的 `join` 命令可以使用命令 `kubeadm token create --print-join-command`重新获取。###

执行成功后运行 `get nodes` 命令：

```
$ kubectl get nodes
NAME          STATUS     ROLES    AGE    VERSION
jabox         NotReady   master   6m2s   v1.15.3
jabox-node1   NotReady   <none>   88s    v1.15.3
jabox-node2   NotReady   <none>   13s    v1.15.3
```

可以看到是 `NotReady` 状态，这是因为还没有安装网络插件，接下来安装网络插件，可以在文档 [https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/) 中选择我们自己的网络插件，这里我们安装 `calio`:

```
$ wget https://docs.projectcalico.org/v3.8/manifests/calico.yaml
# 因为有节点是多网卡，所以需要在资源清单文件中指定内网网卡  ❤️

$ vi calico.yaml

...
containers:
        # Runs calico-node container on each Kubernetes node.  This
        # container programs network policy and routes on each
        # host.
        - name: calico-node
          image: calico/node:v3.8.2
          env:
            # Use Kubernetes API as the backing datastore.
            - name: DATASTORE_TYPE
              value: "kubernetes"
            - name: IP_AUTODETECTION_METHOD  # DaemonSet中添加该环境变量 ❤️
              value: interface=eth0      # 指定内网网卡  ❤️
            # Wait for the datastore.
            - name: WAIT_FOR_DATASTORE
              value: "true"
            # Set based on the k8s node name.
            - name: NODENAME
              valueFrom:
                fieldRef:
                  fieldPath: spec.nodeName
...

$ $ kubectl apply -f calico.yaml  # 安装calico网络插件 ❤️
```

隔一会儿查看 Pod 运行状态：

```
$ kubectl get pods -n kube-system
NAME                                       READY   STATUS    RESTARTS   AGE
calico-kube-controllers-65b8787765-zxc9t   1/1     Running   0          121m
calico-node-fql98                          1/1     Running   0          121m
calico-node-lkqhj                          1/1     Running   0          121m
calico-node-xpzx5                          1/1     Running   0          121m
coredns-cf8fb6d7f-79wwr                    1/1     Running   0          157m
coredns-cf8fb6d7f-hhv2n                    1/1     Running   0          157m
etcd-jabox                                 1/1     Running   0          156m
kube-apiserver-jabox                       1/1     Running   0          156m
kube-controller-manager-jabox              1/1     Running   2          156m
kube-proxy-f2n2s                           1/1     Running   0          153m
kube-proxy-wfdv9                           1/1     Running   0          157m
kube-proxy-zc7h7                           1/1     Running   0          152m
kube-scheduler-jabox                       1/1     Running   3          156m
kubernetes-dashboard-fcfb4cbc-mw92p        1/1     Running   0          141m
```

网络插件运行成功了，node 状态也正常了：

```
$ kubectl get nodes
NAME          STATUS   ROLES    AGE    VERSION
jabox         Ready    master   158m   v1.15.3
jabox-node1   Ready    <none>   154m   v1.15.3
jabox-node2   Ready    <none>   152m   v1.15.3
```

## 安装 Dashboard

```
$ sudo yum install wget
$ wget https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml

$ vi kubernetes-dashboard.yaml
# 修改镜像名称
......
spec:
  containers:
  - name: kubernetes-dashboard
    image: gcr.azk8s.cn/google_containers/kubernetes-dashboard-amd64:v1.10.1
    imagePullPolicy: IfNotPresent
.....
# 修改Service为NodePort类型
  selector:
    k8s-app: kubernetes-dashboard
  type: NodePort
```

直接创建：

```
$ kubectl apply -f kubernetes-dashboard.yaml
$ kubectl get pods -n kube-system -l k8s-app=kubernetes-dashboard
NAME                                  READY   STATUS    RESTARTS   AGE
kubernetes-dashboard-fcfb4cbc-mw92p   1/1     Running   0          147m
$ kubectl get svc -n kube-system -l k8s-app=kubernetes-dashboard
NAME                   TYPE       CLUSTER-IP    EXTERNAL-IP   PORT(S)         AGE
kubernetes-dashboard   NodePort   10.100.46.1   <none>        443:31180/TCP   147m
```
然后可以通过上面的 `31180` 端口去访问 `Dashboard`，要记住使用 `https`，`Chrome`不生效可以使用`Firefox`测试：

```
$ kubectl get pods -n kube-system -owide
NAME                                       READY   STATUS    RESTARTS   AGE    IP               NODE          NOMINATED NODE   READINESS GATES
...
kubernetes-dashboard-fcfb4cbc-mw92p        1/1     Running   0          149m   192.168.106.65   jabox-node2   <none>           <none>
```

然后创建一个具有全局所有权限的用户来登录`Dashboard：(admin.yaml)`

`https://10.151.30.22/31180`

![Alt Image Text](images/1_1.png "Body image")


然后创建一个具有全局所有权限的用户来登录`Dashboard`：(`admin.yaml`)

```
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: admin
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
subjects:
- kind: ServiceAccount
  name: admin
  namespace: kube-system

---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin
  namespace: kube-system
  labels:
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
```

直接创建：

```
$ kubectl apply -f admin.yaml
$ kubectl get secret -n kube-system|grep admin-token

admin-token-vgn2z                                kubernetes.io/service-account-token   3      120m
$ kubectl get secret admin-token-vgn2z -o jsonpath={.data.token} -n kube-system |base64 -d   #会生成一串很长的base64后的字符串
eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJhZG1pbi10b2tlbi12Z24yeiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJhZG1pbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjQ1ZmRmZTZmLTg1Y2EtNGI0YS1hZmViLWYyMGZiOTFjNmYzNiIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlLXN5c3RlbTphZG1pbiJ9.C9-Qi7cUBPFkv6A_dzCy2-2eh9u81MI1Ew8r3V70pHHWoChJan1eZ-v7XBtwlOHu5Ec76onNTanoxd9SZTWecq0NBuUiWJu7KnorJqkMNraAnx60QpbIs3MLeJIJJx7ETtf7j3tIQqFlS7JhETFwcUoJuPuIvheh3E0-fDsvThn4y4Nox40w28Fi01Be-RJiCZ1JGBpWuY2b4C61tVQzWe9Kr7e584zbNCHhg1wWzZnatOa_DJ2lG0ivRadA9aU68OvO_092LwKFj8RnYYe7wp3uYITBydJpmGuoXPpyyyXlVQ_LhlZIoYGnD0pMAyY4sfB167-4b77o6QgVLID-EQ
```

![Alt Image Text](images/1_2.png "Body image")


最终我们就完成了使用 `kubeadm` 搭建 `v1.15.3` 版本的 `kubernetes` 集群、`coredns`、`ipvs`、`calico`。





