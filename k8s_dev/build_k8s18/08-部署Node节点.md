# 8.部署Node 节点

kubernetes Node 节点包含如下组件：

###  flanneld
###  docker
###  kubelet
###  kube-proxy

## 环境变量 (master 03)

```
$ source /usr/k8s/bin/env.sh
$ export KUBE_APISERVER="https://${MASTER_URL}:6443"  // 如果你没有安装`haproxy`的话，还是需要使用6443端口的哦
$ #export KUBE_APISERVER="https://${MASTER_URL}"
$ export NODE_IP=192.168.1.170  # 当前部署的节点 IP
```

按照上面的步骤安装配置好flanneld

## 开启路由转发


修改`/etc/sysctl.conf`文件，添加下面的规则：

```
$ sudo vi /etc/sysctl.conf

net.ipv4.ip_forward=1
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
```

```
$ sudo modprobe ip_vs
$ sudo modprobe br_netfilter
```
执行下面的命令立即生效：
```
$  sudo sysctl -p

net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
```

## 安装docker


[Install Docker CE](https://github.com/Chao-Xi/JacobTechBlog/blob/master/docker/2docker_install.md#install-docker-ce)


## 配置docker


你可以用二进制或yum install 的方式来安装docker，然后修改docker 的systemd unit 文件：

```
systemctl status docker
```
```
● docker.service - Docker Application Container Engine
   Loaded: loaded (/lib/systemd/system/docker.service; enabled; vendor preset: enabled)
   Active: active (running) since Mon 2018-08-27 06:11:54 UTC; 1 day 20h ago
     Docs: https://docs.docker.com
 Main PID: 6425 (dockerd)
    Tasks: 298
   Memory: 271.5M
      CPU: 26min 40.030s
   CGroup: /system.slice/docker.service
           ├─ 3256 /usr/bin/docker-proxy -proto tcp -host-ip 0.0.0.0 -host-port 443 -container-ip 172.17.0.11 -container-port 443
           ├─ 3292 /usr/bin/docker-proxy -proto tcp -host-ip 0.0.0.0 -host-port 80 -container-ip 172.17.0.11 -container-port 80
           ├─ 3304 docker-containerd-shim -namespace moby -workdir /var/lib/docker/containerd/daemon/io.containerd.runtime.v1.linux/moby/b62e6379cdbe4a
           ├─ 6425 /usr/bin/dockerd --log-level=error
```

```
sudo vi /lib/systemd/system/docker.service

[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target docker.socket firewalld.service
Wants=network-online.target
Requires=docker.socket

[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
ExecStart=/usr/bin/dockerd --log-level=error $DOCKER_NETWORK_OPTIONS
ExecReload=/bin/kill -s HUP $MAINPID
LimitNOFILE=1048576
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNPROC=infinity
LimitCORE=infinity
# Uncomment TasksMax if your systemd version supports it.
# Only systemd 226 and above support this version.
TasksMax=infinity
TimeoutStartSec=0
# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes
# kill only the docker process, not all processes in the cgroup
KillMode=process
# restart the docker process if it exits prematurely
Restart=on-failure
StartLimitBurst=3
StartLimitInterval=60s

[Install]
WantedBy=multi-user.target
```

* dockerd 运行时会调用其它 docker 命令，如 docker-proxy，所以需要将 docker 命令所在的目录加到 PATH 环境变量中

* flanneld 启动时将网络配置写入到 `/run/flannel/docker` 文件中的变量 `DOCKER_NETWORK_OPTIONS`，dockerd 命令行上指定该变量值来设置 docker0 网桥参数
 
* 如果指定了多个 `EnvironmentFile` 选项，则必须将 `/run/flannel/docker` 放在最后(确保 docker0 使用 flanneld 生成的 bip 参数)
 
* 不能关闭默认开启的 `--iptables` 和 `--ip-masq` 选项
 
* 如果内核版本比较新，建议使用 `overlay` 存储驱动
 
* docker 从 1.13 版本开始，可能将 **iptables FORWARD chain的默认策略设置为DROP**，从而导致 ping 其它 Node 上的 Pod IP 失败，遇到这种情况时，需要手动设置策略为 `ACCEPT：`

```
$ sudo iptables -P FORWARD ACCEPT
```

如果没有开启上面的路由转发(`net.ipv4.ip_forward=1`)，则需要把以下命令写入`/etc/rc.local`文件中，防止节点**重启iptables FORWARD chain的默认策略又还原为DROP**（下面的开机脚本我测试了几次都没生效，不知道是不是方法有误，所以最好的方式还是开启上面的路由转发功能，一劳永逸）

```
 sleep 60 && /sbin/iptables -P FORWARD ACCEPT
```

为了加快 pull image 的速度，可以使用国内的仓库镜像服务器，同时增加下载的并发数。(如果 dockerd 已经运行，则需要重启 dockerd 生效。)

```
$ cat /etc/docker/daemon.json
{
   "max-concurrent-downloads": 10
}
```

**启动docker**

```
$ sudo systemctl daemon-reload
$ sudo systemctl stop firewalld
$ sudo systemctl disable firewalld
$ sudo iptables -F && sudo iptables -X && sudo iptables -F -t nat && sudo iptables -X -t nat
$ sudo systemctl enable docker
$ sudo systemctl start docker
```

* 需要关闭 firewalld(centos7)/ufw(ubuntu16.04)，否则可能会重复创建 iptables 规则
* 最好清理旧的 iptables rules 和 chains 规则
* 执行命令：docker version，检查docker服务是否正常

## 安装和配置kubelet (all node machines, exp: 192.168.1.170)

kubelet 启动时向`kube-apiserver` 发送`TLS bootstrapping` 请求，需要先将`bootstrap token` 文件中的`kubelet-bootstrap` 用户赋予`system:node-bootstrapper` 角色，**然后kubelet 才有权限创建认证请求(certificatesigningrequests)**：


**kubelet就是运行在Node节点上的，所以这一步安装是在所有的Node节点上，如果你想把你的Master也当做Node节点的话，当然也可以在Master节点上安装的。**

### 注意： `/etc/kubernetes/token.csv` 的存在

```
$ kubectl create clusterrolebinding kubelet-bootstrap --clusterrole=system:node-bootstrapper --user=kubelet-bootstrap
```

`--user=kubelet-bootstrap` 是文件 `/etc/kubernetes/token.csv` 中指定的用户名，同时也写入了文件 `/etc/kubernetes/bootstrap.kubeconfig`


另外1.8 版本中还需要为Node 请求创建一个RBAC 授权规则：

```
$ kubectl create clusterrolebinding kubelet-nodes --clusterrole=system:node --group=system:nodes
```

然后下载最新的kubelet 和kube-proxy 二进制文件（前面下载kubernetes 目录下面其实也有）：

```
$ mkdir nodes && cd nodes
$ wget https://dl.k8s.io/v1.8.2/kubernetes-server-linux-amd64.tar.gz
$ tar -xzvf kubernetes-server-linux-amd64.tar.gz
$ cd kubernetes
$ tar -xzvf  kubernetes-src.tar.gz
$ sudo cp -r ./server/bin/{kube-proxy,kubelet} /usr/k8s/bin/
```

## 创建kubelet bootstapping kubeconfig 文件

```
$ # 设置集群参数
$ kubectl config set-cluster kubernetes \
  --certificate-authority=/etc/kubernetes/ssl/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=bootstrap.kubeconfig
$ # 设置客户端认证参数
$ kubectl config set-credentials kubelet-bootstrap \
  --token=${BOOTSTRAP_TOKEN} \
  --kubeconfig=bootstrap.kubeconfig
$ # 设置上下文参数
$ kubectl config set-context default \
  --cluster=kubernetes \
  --user=kubelet-bootstrap \
  --kubeconfig=bootstrap.kubeconfig
$ # 设置默认上下文
$ kubectl config use-context default --kubeconfig=bootstrap.kubeconfig
$ mv bootstrap.kubeconfig /etc/kubernetes/
```

* `--embed-certs` 为 `true` 时表示将 `certificate-authority` 证书写入到生成的 `bootstrap.kubeconfig` 文件中；
* 设置 `kubelet` 客户端认证参数时**没有指定秘钥和证书**，后续由 `kube-apiserver` 自动生成；


## 创建kubelet 的systemd unit 文件

```
$ sudo mkdir /var/lib/kubelet # 必须先创建工作目录
$ cat > kubelet.service <<EOF
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=docker.service
Requires=docker.service

[Service]
WorkingDirectory=/var/lib/kubelet
ExecStart=/usr/k8s/bin/kubelet \\
  --fail-swap-on=false \\
  --cgroup-driver=cgroupfs \\
  --address=${NODE_IP} \\
  --hostname-override=${NODE_IP} \\
  --experimental-bootstrap-kubeconfig=/etc/kubernetes/bootstrap.kubeconfig \\
  --kubeconfig=/etc/kubernetes/kubelet.kubeconfig \\
  --require-kubeconfig \\
  --cert-dir=/etc/kubernetes/ssl \\
  --cluster-dns=${CLUSTER_DNS_SVC_IP} \\
  --cluster-domain=${CLUSTER_DNS_DOMAIN} \\
  --hairpin-mode promiscuous-bridge \\
  --allow-privileged=true \\
  --serialize-image-pulls=false \\
  --logtostderr=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

### 请仔细阅读下面的注意事项，不然可能会启动失败。

* `--fail-swap-on`参数，这个一定要注意，**Kubernetes 1.8开始要求关闭系统的Swap**，如果不关闭，默认配置下kubelet将无法启动，也可以通过kubelet的启动参数`–fail-swap-on=false`来避免该问题
* `--cgroup-driver`参数，kubelet 用来维护主机的的 `cgroups` 的，默认是cgroupfs，但是这个地方的值需要你根据docker 的配置来确定（`docker info |grep cgroup`）
* `-address` 不能设置为 `127.0.0.1`，否则后续 Pods 访问 kubelet 的 API 接口时会失败，因为 Pods 访问的 `127.0.0.1`指向自己而不是 `kubelet`
* 如果设置了 `--hostname-override` 选项，则 `kube-proxy` 也需要设置该选项，否则会出现找不到 Node 的情况
* `--experimental-bootstrap-kubeconfig` 指向 bootstrap kubeconfig 文件，kubelet 使用该文件中的用户名和 token 向 kube-apiserver 发送 TLS Bootstrapping 请求
* 管理员通过了 CSR 请求后，kubelet 自动在 `--cert-dir` 目录创建证书和私钥文件(`kubelet-client.crt` 和 `kubelet-client.key`)，然后写入 `--kubeconfig` 文件(自动创建 --kubeconfig 指定的文件)
* 建议在 `--kubeconfig` 配置文件中指定 `kube-apiserver` 地址，如果未指定 `--api-servers` 选项，则必须指定 `--require-kubeconfig` 选项后才从配置文件中读取 kue-apiserver 的地址，否则 kubelet 启动后将找不到 kube-apiserver (日志中提示未找到 API Server），`kubectl get nodes` 不会返回对应的 Node 信息
* `--cluster-dns` 指定 kubedns 的 Service IP(可以先分配，后续创建 kubedns 服务时指定该 IP)，`--cluster-domain` 指定域名后缀，这两个参数同时指定后才会生效

## 启动kubelet


```
$ sudo cp kubelet.service /etc/systemd/system/kubelet.service
$ sudo systemctl daemon-reload
$ sudo systemctl enable kubelet
$ sudo systemctl start kubelet
$ systemctl status kubelet

● kubelet.service - Kubernetes Kubelet
   Loaded: loaded (/etc/systemd/system/kubelet.service; enabled; vendor preset: enabled)
   Active: active (running) since Mon 2018-08-27 06:11:55 UTC; 1 day 21h ago
     Docs: https://github.com/GoogleCloudPlatform/kubernetes
 Main PID: 6559 (kubelet)
    Tasks: 19
   Memory: 54.2M
      CPU: 36min 34.399s
   CGroup: /system.slice/kubelet.service
           └─6559 /usr/k8s/bin/kubelet --fail-swap-on=false --cgroup-driver=cgroupfs --address=192.168.1.170 --hostname-override=192.168.1.170 --experi

Aug 29 03:23:05 kube-node3 kubelet[6559]: I0829 03:23:05.017595    6559 server.go:779] POST /stats/container/: (11.727714ms) 200 [[Go-http-client/1.1]
```

### 我遇见的问题：

```
$ journalctl -xe -u kubelet
$ journalctl -u kubelet -f

error: failed to run Kubelet: cannot create certificate signing request: Unauthorized？

Token error:   `/etc/kubernetes/token.csv` error
```

通过kubelet 的TLS 证书请求

```
$ kubectl get csr
NAME                                                   AGE       REQUESTOR           CONDITION
node-csr-Sr7P18vOf285TOAYgRLnL1HKgt0hRLIWZWICv9VOqv   2m        kubelet-bootstrap   Pending
$ kubectl get nodes
No resources found.
```

通过CSR 请求：

```
$ kubectl certificate approve node-csr-Sr7P18vOf285TOAYgRLnL1HKgt0hRLIWZWICv9VOqv
certificatesigningrequest "node-csr-Sr7P18vOf285TOAYgRLnL1HKgt0hRLIWZWICv9VOqv" approved

$ kubectl get nodes
NAME            STATUS    ROLES     AGE       VERSION
192.168.1.170   Ready     <none>    4d        v1.8.2
```
自动生成了kubelet kubeconfig 文件和公私钥：

```
$ ls -l /etc/kubernetes/kubelet.kubeconfig
-rw------- 1 root root 2288 Aug 24 16:30 /etc/kubernetes/kubelet.kubeconfig

$ ls -l /etc/kubernetes/ssl/kubelet*
-rw-r--r-- 1 root root 1046 Aug 24 16:30 /etc/kubernetes/ssl/kubelet-client.crt
-rw------- 1 root root  227 Aug 24 16:29 /etc/kubernetes/ssl/kubelet-client.key
-rw-r--r-- 1 root root 1115 Aug 24 16:29 /etc/kubernetes/ssl/kubelet.crt
-rw------- 1 root root 1675 Aug 24 16:29 /etc/kubernetes/ssl/kubelet.key
```

## 配置kube-proxy

### 创建kube-proxy 证书签名请求：

```
$ cd nodes
$ cat > kube-proxy-csr.json <<EOF
{
  "CN": "system:kube-proxy",
  "hosts": [],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "k8s",
      "OU": "System"
    }
  ]
}
EOF
```

* CN 指定该证书的 User 为 `system:kube-proxy`
* `kube-apiserver` 预定义的 RoleBinding `system:node-proxier` 将User `system:kube-proxy` 与 Role `system:node-proxier`绑定，该 Role 授予了调用 `kube-apiserver` Proxy 相关 API 的权限
* hosts 属性值为空列表


### 生成kube-proxy 客户端证书和私钥

```
$ sudo cfssl gencert -ca=/etc/kubernetes/ssl/ca.pem \
  -ca-key=/etc/kubernetes/ssl/ca-key.pem \
  -config=/etc/kubernetes/ssl/ca-config.json \
  -profile=kubernetes kube-proxy-csr.json | cfssljson -bare kube-proxy
$ ls kube-proxy*
kube-proxy.csr  kube-proxy-csr.json  kube-proxy-key.pem  kube-proxy.pem
$ sudo mv kube-proxy*.pem /etc/kubernetes/ssl/
```

### 创建kube-proxy kubeconfig 文件

```
$ # 设置集群参数
$ kubectl config set-cluster kubernetes \
  --certificate-authority=/etc/kubernetes/ssl/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=kube-proxy.kubeconfig
$ # 设置客户端认证参数
$ kubectl config set-credentials kube-proxy \
  --client-certificate=/etc/kubernetes/ssl/kube-proxy.pem \
  --client-key=/etc/kubernetes/ssl/kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-proxy.kubeconfig
$ # 设置上下文参数
$ kubectl config set-context default \
  --cluster=kubernetes \
  --user=kube-proxy \
  --kubeconfig=kube-proxy.kubeconfig
$ # 设置默认上下文
$ kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig
$ mv kube-proxy.kubeconfig /etc/kubernetes/

```

* 设置集群参数和客户端认证参数时 `--embed-certs` 都为 `true`，这会将 `certificate-authority`、`client-certificate` 和 `client-key` 指向的证书文件内容写入到生成的 `kube-proxy.kubeconfig` 文件中
* `kube-proxy.pem` 证书中 CN 为 `system:kube-proxy`，`kube-apiserver` 预定义的 RoleBinding `cluster-admin` 将User `system:kube-proxy` 与 Role `system:node-proxier` 绑定，该 Role 授予了调用 `kube-apiserver` Proxy 相关 API 的权限

### 创建kube-proxy 的systemd unit 文件

```
$ sudo mkdir -p /var/lib/kube-proxy # 必须先创建工作目录
$ cat > kube-proxy.service <<EOF
[Unit]
Description=Kubernetes Kube-Proxy Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=network.target

[Service]
WorkingDirectory=/var/lib/kube-proxy
ExecStart=/usr/k8s/bin/kube-proxy \\
  --bind-address=${NODE_IP} \\
  --hostname-override=${NODE_IP} \\
  --cluster-cidr=${SERVICE_CIDR} \\
  --kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig \\
  --logtostderr=true \\
  --v=2
Restart=on-failure
RestartSec=5
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

```

* `--hostname-override` 参数值必须与 kubelet 的值一致，否则 kube-proxy 启动后会找不到该 Node，从而不会创建任何 iptables 规则
* `--cluster-cidr` 必须与 kube-apiserver 的 `--service-cluster-ip-range` 选项值一致
* kube-proxy 根据 `--cluster-cidr` 判断集群内部和外部流量，指定 `--cluster-cidr` 或 `--masquerade-all` 选项后 kube-proxy 才会对访问 Service IP 的请求做 SNAT
* `--kubeconfig` 指定的配置文件嵌入了 kube-apiserver 的地址、用户名、证书、秘钥等请求和认证信息
* 预定义的 RoleBinding `cluster-admin` 将User `system:kube-proxy` 与 Role `system:node-proxier` 绑定，该 Role 授予了调用 `kube-apiserver` Proxy 相关 API 的权限

### 启动kube-proxy

```
$ sudo cp kube-proxy.service /etc/systemd/system/
$ sudo systemctl daemon-reload
$ sudo systemctl enable kube-proxy
$ sudo systemctl start kube-proxy
$ systemctl status kube-proxy

● kube-proxy.service - Kubernetes Kube-Proxy Server
   Loaded: loaded (/etc/systemd/system/kube-proxy.service; enabled; vendor preset: enabled)
   Active: active (running) since Mon 2018-08-27 01:46:48 UTC; 2 days ago
     Docs: https://github.com/GoogleCloudPlatform/kubernetes
 Main PID: 1130 (kube-proxy)
    Tasks: 0
   Memory: 20.7M
      CPU: 248ms
   CGroup: /system.slice/kube-proxy.service
           ‣ 1130 /usr/k8s/bin/kube-proxy --bind-address=192.168.1.170 --hostname-override=192.168.1.170 --cluster-cidr=10.254.0.0/16 --kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig --logtostderr=true --v=2

Warning: Journal has been rotated since unit was started. Log output is incomplete or unavailable.
```

### 验证集群功能

定义yaml 文件：（将下面内容保存为：`nginx-ds.yaml`）

```
apiVersion: v1
kind: Service
metadata:
  name: nginx-ds
  labels:
    app: nginx-ds
spec:
  type: NodePort
  selector:
    app: nginx-ds
  ports:
  - name: http
    port: 80
    targetPort: 80
---
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: nginx-ds
  labels:
    addonmanager.kubernetes.io/mode: Reconcile
spec:
  template:
    metadata:
      labels:
        app: nginx-ds
    spec:
      containers:
      - name: my-nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
```

**创建 Pod 和服务：**

```
$ kubectl create -f nginx-ds.yml
service "nginx-ds" created
daemonset "nginx-ds" created
```

### 执行下面的命令查看Pod 和SVC：

```
$ kubectl get pods -o wide
NAME                       READY     STATUS    RESTARTS   AGE       IP            NODE
nginx-ds-256wp             1/1       Running   1          4d        172.17.0.7    192.168.1.170

$ kubectl get svc
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
nginx-ds     NodePort    10.254.255.59   <none>        80:31053/TCP   4d
```

可以看到：

* 服务IP：110.254.255.59
* 服务端口：80
* NodePort端口：31053

在所有 Node 上执行：

```
$ curl 10.254.255.59
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

```
curl 192.168.1.170:31053
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>

```
```
curl 172.17.0.7

<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```
执行上面的命令预期都会输出nginx 欢迎页面内容，表示我们的Node 节点正常运行了。








