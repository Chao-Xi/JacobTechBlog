# 5.部署Flannel 网络

kubernetes 要求集群内各节点能通过Pod 网段互联互通，下面我们来使用Flannel 在所有节点上创建互联互通的Pod 网段的步骤。

### 需要在所有的Node节点安装。

## 环境变量

```
$ export NODE_IP=192.168.1.137  # 当前部署节点的IP
# 导入全局变量
$ source /usr/k8s/bin/env.sh
```

## 创建TLS 密钥和证书

**etcd 集群启用了双向TLS 认证**，所以需要为**flanneld** 指定与**etcd** 集群通信的CA 和密钥。

创建flanneld 证书签名请求：

```
$ mkdir flanneld && cd flanneld

$ cat > flanneld-csr.json <<EOF
{
  "CN": "flanneld",
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

生成flanneld 证书和私钥：

```
$ sudo cfssl gencert -ca=/etc/kubernetes/ssl/ca.pem \
  -ca-key=/etc/kubernetes/ssl/ca-key.pem \
  -config=/etc/kubernetes/ssl/ca-config.json \
  -profile=kubernetes flanneld-csr.json | cfssljson -bare flanneld
$ ls flanneld*
flanneld.csr  flanneld-csr.json  flanneld-key.pem flanneld.pem
$ sudo mkdir -p /etc/flanneld/ssl
$ sudo mv flanneld*.pem /etc/flanneld/ssl
```

## 向etcd 写入集群Pod 网段信息

```
该步骤只需在第一次部署Flannel 网络时执行，后续在其他节点上部署Flanneld 时无需再写入该信息
```

```
$ etcdctl \
  --endpoints=${ETCD_ENDPOINTS} \
  --ca-file=/etc/kubernetes/ssl/ca.pem \
  --cert-file=/etc/flanneld/ssl/flanneld.pem \
  --key-file=/etc/flanneld/ssl/flanneld-key.pem \
  set ${FLANNEL_ETCD_PREFIX}/config '{"Network":"'${CLUSTER_CIDR}'", "SubnetLen": 24, "Backend": {"Type": "vxlan"}}'
# 得到如下反馈信息
{"Network":"172.30.0.0/16", "SubnetLen": 24, "Backend": {"Type": "vxlan"}}
```

写入的 Pod 网段`(${CLUSTER_CIDR}，172.30.0.0/16)` 必须与 `kube-controller-manager` 的 `--cluster-cidr` 选项值一致；

## 安装和配置flanneld

前往[flanneld release](https://github.com/coreos/flannel/releases)页面下载最新版的flanneld 二进制文件：

```
$ mkdir flannel
$ wget https://github.com/coreos/flannel/releases/download/v0.9.0/flannel-v0.9.0-linux-amd64.tar.gz
$ tar -xzvf flannel-v0.9.0-linux-amd64.tar.gz -C flannel
$ sudo cp flannel/{flanneld,mk-docker-opts.sh} /usr/k8s/bin
```

创建flanneld的systemd unit 文件

```
$ cat > flanneld.service << EOF
[Unit]
Description=Flanneld overlay address etcd agent
After=network.target
After=network-online.target
Wants=network-online.target
After=etcd.service
Before=docker.service

[Service]
Type=notify
ExecStart=/usr/k8s/bin/flanneld \\
  -etcd-cafile=/etc/kubernetes/ssl/ca.pem \\
  -etcd-certfile=/etc/flanneld/ssl/flanneld.pem \\
  -etcd-keyfile=/etc/flanneld/ssl/flanneld-key.pem \\
  -etcd-endpoints=${ETCD_ENDPOINTS} \\
  -etcd-prefix=${FLANNEL_ETCD_PREFIX}
ExecStartPost=/usr/k8s/bin/mk-docker-opts.sh -k DOCKER_NETWORK_OPTIONS -d /run/flannel/docker
Restart=on-failure

[Install]
WantedBy=multi-user.target
RequiredBy=docker.service
EOF
```

* `mk-docker-opts.sh`脚本将分配给flanneld 的Pod 子网网段信息写入到`/run/flannel/docker` 文件中，后续docker 启动时使用这个文件中的参数值为 docker0 网桥
* flanneld 使用系统缺省路由所在的接口和其他节点通信，对于有多个网络接口的机器(内网和公网)，可以用 `--iface` 选项值指定通信接口(上面的 systemd unit 文件没指定这个选项)

## 启动flanneld (ON all nodes)

```
$ sudo cp flanneld.service /etc/systemd/system/
$ sudo systemctl daemon-reload
$ sudo systemctl enable flanneld
$ sudo systemctl start flanneld
$ systemctl status flanneld
```
## 检查flanneld 服务

```
$ ifconfig flannel.1

flannel.1 Link encap:Ethernet  HWaddr 66:4a:88:e0:75:32
          inet addr:172.30.21.0  Bcast:0.0.0.0  Mask:255.255.255.255
          inet6 addr: fe80::644a:88ff:fee0:7532/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1450  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:8 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
```

## 检查分配给各flanneld 的Pod 网段信息

```
$ # 查看集群 Pod 网段(/16)

$ etcdctl \
>   --endpoints=${ETCD_ENDPOINTS} \
>   --ca-file=/etc/kubernetes/ssl/ca.pem \
>   --cert-file=/etc/flanneld/ssl/flanneld.pem \
>   --key-file=/etc/flanneld/ssl/flanneld-key.pem \
>   get ${FLANNEL_ETCD_PREFIX}/config
{"Network":"172.30.0.0/16", "SubnetLen": 24, "Backend": {"Type": "vxlan"}}

$ # 查看已分配的 Pod 子网段列表(/24)
$ etcdctl \
  --endpoints=${ETCD_ENDPOINTS} \
  --ca-file=/etc/kubernetes/ssl/ca.pem \
  --cert-file=/etc/flanneld/ssl/flanneld.pem \
  --key-file=/etc/flanneld/ssl/flanneld-key.pem \
  ls ${FLANNEL_ETCD_PREFIX}/subnets
/kubernetes/network/subnets/172.30.77.0-24
$ 172.30.77.0 this maybe changed according to you situation
$ # 查看某一 Pod 网段对应的 flanneld 进程监听的 IP 和网络参数
$ etcdctl \
  --endpoints=${ETCD_ENDPOINTS} \
  --ca-file=/etc/kubernetes/ssl/ca.pem \
  --cert-file=/etc/flanneld/ssl/flanneld.pem \
  --key-file=/etc/flanneld/ssl/flanneld-key.pem \
  get ${FLANNEL_ETCD_PREFIX}/subnets/172.30.77.0-24  
{"PublicIP":"192.168.1.137","BackendType":"vxlan","BackendData":{"VtepMAC":"62:fc:03:83:1b:2b"}}
$ 172.30.77.0 this maybe changed according to you situation
```

## 确保各节点间Pod 网段能互联互通

```
$ etcdctl \
  --endpoints=${ETCD_ENDPOINTS} \
  --ca-file=/etc/kubernetes/ssl/ca.pem \
  --cert-file=/etc/flanneld/ssl/flanneld.pem \
  --key-file=/etc/flanneld/ssl/flanneld-key.pem \
  ls ${FLANNEL_ETCD_PREFIX}/subnets
  
/kubernetes/network/subnets/172.30.19.0-24
/kubernetes/network/subnets/172.30.30.0-24
/kubernetes/network/subnets/172.30.77.0-24
/kubernetes/network/subnets/172.30.41.0-24
/kubernetes/network/subnets/172.30.83.0-24
```
当前五个节点分配的 Pod 网段分别是：172.30.77.0-24、172.30.30.0-24、172.30.19.0-24、172.30.41.0-24、172.30.83.0-24。

我只显示了一个`/kubernetes/network/subnets/172.30.83.0-24`, 心痛😭😭😭😭




