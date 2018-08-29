# 3.部署高可用etcd集群

`kubernetes` 系统使用`etcd`存储所有的数据，我们这里部署**3个节点的etcd集群**，**这3个节点直接复用kubernetes master的3个节点**，分别命名为**`etcd01`、`etcd02`、`etcd03`**:

* etcd01：192.168.1.137
* etcd02：192.168.1.138
* etcd03：192.168.1.170

## 定义环境变量

使用到的变量如下：

```
$ export NODE_NAME=etcd01 # 当前部署的机器名称(随便定义，只要能区分不同机器即可)
$ export NODE_IP=192.168.1.137 # 当前部署的机器IP
$ export NODE_IPS="192.168.1.137 192.168.1.138 192.168.1.170" # etcd 集群所有机器 IP
$ # etcd 集群间通信的IP和端口
$ export ETCD_NODES=etcd01=https://192.168.1.137:2380,etcd02=https://192.168.1.138:2380,etcd03=https://192.168.1.170:2380
$ # 导入用到的其它全局变量：ETCD_ENDPOINTS、FLANNEL_ETCD_PREFIX、CLUSTER_CIDR
$ source /usr/k8s/bin/env.sh
```

## or

### etcd01：192.168.1.137

```
$ vi start.sh

export NODE_NAME=etcd01 # 当前部署的机器名称(随便定义，只要能区分不同机器即可)
export NODE_IP=192.168.1.137 # 当前部署的机器IP
export NODE_IPS="192.168.1.137 192.168.1.138 192.168.1.170" # etcd 集群所有机器 IP
# etcd 集群间通信的IP和端口
export ETCD_NODES=etcd01=https://192.168.1.137:2380,etcd02=https://192.168.1.138:2380,etcd03=https://192.168.1.170:2380
# 导入用到的其它全局变量：ETCD_ENDPOINTS、FLANNEL_ETCD_PREFIX、CLUSTER_CIDR
source /usr/k8s/bin/env.sh
export KUBE_APISERVER="https://${MASTER_URL}:6443"
export PATH=/usr/k8s/bin:$PATH
```

## etcd02：192.168.1.138

```
$ vi start.sh

export NODE_NAME=etcd02 # 当前部署的机器名称(随便定义，只要能区分不同机器即可)
export NODE_IP=192.168.1.138 # 当前部署的机器IP
export NODE_IPS="192.168.1.137 192.168.1.138 192.168.1.170" # etcd 集群所有机器 IP
# etcd 集群间通信的IP和端口
export ETCD_NODES=etcd01=https://192.168.1.137:2380,etcd02=https://192.168.1.138:2380,etcd03=https://192.168.1.170:2380
# 导入用到的其它全局变量：ETCD_ENDPOINTS、FLANNEL_ETCD_PREFIX、CLUSTER_CIDR
source /usr/k8s/bin/env.sh
export KUBE_APISERVER="https://${MASTER_URL}:6443"
export PATH=/usr/k8s/bin:$PATH
```


## etcd03：192.168.1.170

```
$ vi start.sh

export NODE_NAME=etcd03 # 当前部署的机器名称(随便定义，只要能区分不同机器即可)
export NODE_IP=192.168.1.170 # 当前部署的机器IP
export NODE_IPS="192.168.1.137 192.168.1.138 192.168.1.170" # etcd 集群所有机器 IP
# etcd 集群间通信的IP和端口
export ETCD_NODES=etcd01=https://192.168.1.137:2380,etcd02=https://192.168.1.138:2380,etcd03=https://192.168.1.170:2380
# 导入用到的其它全局变量：ETCD_ENDPOINTS、FLANNEL_ETCD_PREFIX、CLUSTER_CIDR
source /usr/k8s/bin/env.sh
export KUBE_APISERVER="https://${MASTER_URL}:6443"
export PATH=/usr/k8s/bin:$PATH
```

```
$ source start.sh
```

## 下载etcd二进制文件(on all three master nodes)

到[https://github.com/coreos/etcd/releases](到https://github.com/coreos/etcd/releases页面下载最新版本的二进制文件)页面下载最新版本的二进制文件：

```
$ mkdir etcd && cd etcd
$ wget https://github.com/coreos/etcd/releases/download/v3.2.9/etcd-v3.2.9-linux-amd64.tar.gz
$ tar -xvf etcd-v3.2.9-linux-amd64.tar.gz
$ sudo mv etcd-v3.2.9-linux-amd64/etcd* /usr/k8s/bin/
```

## 创建TLS 密钥和证书(on all three master nodes)

为了保证通信安全，客户端(如etcdctl)与etcd 集群、etcd 集群之间的通信需要使用TLS 加密。

创建etcd 证书签名请求：

```
$ cat > etcd-csr.json <<EOF
{
  "CN": "etcd",
  "hosts": [
    "127.0.0.1",
    "${NODE_IP}"
  ],
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

**`hosts` 字段指定授权使用该证书的`etcd节点IP`**

生成`etcd`证书和私钥：

```
$ sudo cfssl gencert -ca=/etc/kubernetes/ssl/ca.pem \
  -ca-key=/etc/kubernetes/ssl/ca-key.pem \
  -config=/etc/kubernetes/ssl/ca-config.json \
  -profile=kubernetes etcd-csr.json | cfssljson -bare etcd
$ ls etcd*
etcd.csr  etcd-csr.json  etcd-key.pem  etcd.pem
$ sudo mkdir -p /etc/etcd/ssl
$ sudo mv etcd*.pem /etc/etcd/ssl/
```

cfssl生成`etcd`证书和私钥时，可能会出现`ca-key.pem`读取`permission denied`的问题 

```
$ sudo chown vagrant:vagrant /etc/kubernetes/ssl/ca-key.pem
```
可以解决问题


## 创建etcd 的systemd unit 文件（on all three master nodes）

```
$ sudo mkdir -p /var/lib/etcd  # 必须要先创建工作目录
$ cat > etcd.service <<EOF
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target
Documentation=https://github.com/coreos

[Service]
Type=notify
WorkingDirectory=/var/lib/etcd/
ExecStart=/usr/k8s/bin/etcd \\
  --name=${NODE_NAME} \\
  --cert-file=/etc/etcd/ssl/etcd.pem \\
  --key-file=/etc/etcd/ssl/etcd-key.pem \\
  --peer-cert-file=/etc/etcd/ssl/etcd.pem \\
  --peer-key-file=/etc/etcd/ssl/etcd-key.pem \\
  --trusted-ca-file=/etc/kubernetes/ssl/ca.pem \\
  --peer-trusted-ca-file=/etc/kubernetes/ssl/ca.pem \\
  --initial-advertise-peer-urls=https://${NODE_IP}:2380 \\
  --listen-peer-urls=https://${NODE_IP}:2380 \\
  --listen-client-urls=https://${NODE_IP}:2379,http://127.0.0.1:2379 \\
  --advertise-client-urls=https://${NODE_IP}:2379 \\
  --initial-cluster-token=etcd-cluster-0 \\
  --initial-cluster=${ETCD_NODES} \\
  --initial-cluster-state=new \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
```

* 指定etcd的工作目录和数据目录为`/var/lib/etcd`，需要在启动服务前创建这个目录；
* 为了保证通信安全，需要指定etcd 的公私钥(cert-file和key-file)、Peers通信的公私钥和CA 证书(peer-cert-file、peer-key-file、peer-trusted-ca-file)、客户端的CA 证书(trusted-ca-file)；
* `--initial-cluster-state`值为`new`时，`--name`的参数值必须位于`--initial-cluster`列表中；

## 启动etcd服务 (on all three ectd nodes)

```
$ sudo mv etcd.service /etc/systemd/system/
$ sudo systemctl daemon-reload
$ sudo systemctl enable etcd
$ sudo systemctl start etcd
$ sudo systemctl status etcd
```

### 最先启动的etcd 进程会卡住一段时间，等待其他节点启动加入集群，在所有的etcd 节点重复上面的步骤，直到所有的机器etcd 服务都已经启动。


## check ectd error log (if ectd fail to start)

```
$ systemctl status etcd
● etcd.service - Etcd Server
   Loaded: loaded (/etc/systemd/system/etcd.service; enabled; vendor preset: enabled)
   Active: active (running) since Fri 2018-08-24 09:39:30 UTC; 3 days ago
     Docs: https://github.com/coreos
 Main PID: 1827 (etcd)
    Tasks: 10
   Memory: 199.0M
      CPU: 25min 23.834s
   CGroup: /system.slice/etcd.service
           └─1827 /usr/k8s/bin/etcd --name=etcd02 --cert-file=/etc/etcd/ssl/etcd.pem --key-file=

Aug 28 06:12:25 kube-node2 etcd[1827]: store.index: compact 120713
Aug 28 06:12:25 kube-node2 etcd[1827]: finished scheduled compaction at 120713 (took 978.766µs)
Aug 28 06:17:25 kube-node2 etcd[1827]: store.index: compact 121134
Aug 28 06:17:25 kube-node2 etcd[1827]: finished scheduled compaction at 121134 (took 982.582µs)
Aug 28 06:22:25 kube-node2 etcd[1827]: store.index: compact 121556
Aug 28 06:22:25 kube-node2 etcd[1827]: finished scheduled compaction at 121556 (took 923.344µs)
Aug 28 06:27:25 kube-node2 etcd[1827]: store.index: compact 121978
Aug 28 06:27:25 kube-node2 etcd[1827]: finished scheduled compaction at 121978 (took 950.623µs)
Aug 28 06:32:25 kube-node2 etcd[1827]: store.index: compact 122398
Aug 28 06:32:25 kube-node2 etcd[1827]: finished scheduled compaction at 122398 (took 1.142914ms)
```

```
$ journalctl -u etcd.service

-- Logs begin at Tue 2018-08-28 04:50:08 UTC, end at Tue 2018-08-28 06:38:11 UTC. --
Aug 28 04:52:24 kube-node3 etcd[1136]: store.index: compact 113968
Aug 28 04:52:24 kube-node3 etcd[1136]: finished scheduled compaction at 113968 (took 507.623µs)
Aug 28 04:57:24 kube-node3 etcd[1136]: store.index: compact 114389

```

## 验证服务 (on master 01)

部署完etcd 集群后，在任一etcd 节点上执行下面命令：

```
for ip in ${NODE_IPS}; do
  ETCDCTL_API=3 /usr/k8s/bin/etcdctl \
  --endpoints=https://${ip}:2379  \
  --cacert=/etc/kubernetes/ssl/ca.pem \
  --cert=/etc/etcd/ssl/etcd.pem \
  --key=/etc/etcd/ssl/etcd-key.pem \
  endpoint health; done
```

输出如下结果：

```
https://192.168.1.137:2379 is healthy: successfully committed proposal: took = 4.026301ms
https://192.168.1.138:2379 is healthy: successfully committed proposal: took = 3.305413ms
https://192.168.1.170:2379 is healthy: successfully committed proposal: took = 3.75835ms
```

可以看到上面的信息3个节点上的etcd 均为**healthy**，则表示集群服务正常。








