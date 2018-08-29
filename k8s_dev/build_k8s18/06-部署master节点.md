# 6.部署master 节点

kubernetes master 节点包含的组件有：

* kube-apiserver
* kube-scheduler
* kube-controller-manager

目前这3个组件需要部署到同一台机器上：（后面再部署高可用的master）**(在3台master上都进行了安装)**

* `kube-scheduler`、`kube-controller-manager` 和 `kube-apiserver` 三者的功能紧密相关；
* 同时只能有一个 `kube-scheduler`、`kube-controller-manager` 进程处于工作状态，如果运行多个，则需要通过选举产生一个 leader；

master 节点与node 节点上的Pods 通过Pod 网络通信，所以需要在master 节点上部署Flannel 网络。

## 环境变量

```
$ export NODE_IP=192.168.1.137  # 当前部署的master 机器IP
$ source /usr/k8s/bin/env.sh
```

## 下载最新版本的二进制文件

在[kubernetes changelog](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.8.md#server-binaries) 页面下载最新版本的文件：

```
$ mkdir master && cd master
$ wget https://dl.k8s.io/v1.8.2/kubernetes-server-linux-amd64.tar.gz
$ tar -xzvf kubernetes-server-linux-amd64.tar.gz
$ cd kubernetes
```
将二进制文件拷贝到/usr/k8s/bin目录

```
$ sudo cp -r server/bin/{kube-apiserver,kube-controller-manager,kube-scheduler} /usr/k8s/bin/
```

## 创建kubernetes 证书

```
$ cd ..
$ cat > kubernetes-csr.json <<EOF
{
  "CN": "kubernetes",
  "hosts": [
    "127.0.0.1",
    "${NODE_IP}",
    "${MASTER_URL}",
    "${CLUSTER_KUBERNETES_SVC_IP}",
    "kubernetes",
    "kubernetes.default",
    "kubernetes.default.svc",
    "kubernetes.default.svc.cluster",
    "kubernetes.default.svc.cluster.local"
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

* 如果 hosts 字段不为空则需要指定授权使用该证书的 **IP 或域名列表**，所以上面分别指定了当前部署的 master 节点主机 IP 以及apiserver 负载的内部域名
* 还需要添加 kube-apiserver 注册的名为 `kubernetes` 的服务 IP (Service Cluster IP)，一般是 kube-apiserver `--service-cluster-ip-range` 选项值指定的网段的**第一个IP**，如 “10.254.0.1”

生成kubernetes 证书和私钥：

```
$ cfssl gencert -ca=/etc/kubernetes/ssl/ca.pem \
  -ca-key=/etc/kubernetes/ssl/ca-key.pem \
  -config=/etc/kubernetes/ssl/ca-config.json \
  -profile=kubernetes kubernetes-csr.json | cfssljson -bare kubernetes
$ ls kubernetes*
kubernetes.csr  kubernetes-csr.json  kubernetes-key.pem  kubernetes.pem
$ sudo mkdir -p /etc/kubernetes/ssl/
$ sudo mv kubernetes*.pem /etc/kubernetes/ssl/
```

## 6.1 配置和启动kube-apiserver

### 创建kube-apiserver 使用的客户端token 文件

kubelet 首次启动时向kube-apiserver 发送TLS Bootstrapping 请求，kube-apiserver 验证请求中的token 是否与它配置的token.csv 一致，如果一致则自动为kubelet 生成证书和密钥。

```
$ # 导入的 environment.sh 文件定义了 BOOTSTRAP_TOKEN 变量

$ cat > token.csv <<EOF
${BOOTSTRAP_TOKEN},kubelet-bootstrap,10001,"system:kubelet-bootstrap"
EOF

$ sudo mv token.csv /etc/kubernetes/
```

1. `${BOOTSTRAP_TOKEN}`在`token.csv`中会自动变成数字形式，否则在copy到node中后，node无法加入cluster
2. 我的token.csv, 
3. `cecd02f2984fb36d12f1cb67236f9802,kubelet-bootstrap,10001,"system:kubelet-bootstrap" `


### 拷贝token.csv到所有nodes的`/etc/kubernetes/`,以便于后期node加入cluster

### 创建kube-apiserver 的systemd unit文件

```
$ cat  > kube-apiserver.service <<EOF
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=network.target

[Service]
ExecStart=/usr/k8s/bin/kube-apiserver \\
  --admission-control=NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \\
  --advertise-address=${NODE_IP} \\
  --bind-address=0.0.0.0 \\
  --insecure-bind-address=${NODE_IP} \\
  --authorization-mode=Node,RBAC \\
  --runtime-config=rbac.authorization.k8s.io/v1alpha1 \\
  --kubelet-https=true \\
  --experimental-bootstrap-token-auth \\
  --token-auth-file=/etc/kubernetes/token.csv \\
  --service-cluster-ip-range=${SERVICE_CIDR} \\
  --service-node-port-range=${NODE_PORT_RANGE} \\
  --tls-cert-file=/etc/kubernetes/ssl/kubernetes.pem \\
  --tls-private-key-file=/etc/kubernetes/ssl/kubernetes-key.pem \\
  --client-ca-file=/etc/kubernetes/ssl/ca.pem \\
  --service-account-key-file=/etc/kubernetes/ssl/ca-key.pem \\
  --etcd-cafile=/etc/kubernetes/ssl/ca.pem \\
  --etcd-certfile=/etc/kubernetes/ssl/kubernetes.pem \\
  --etcd-keyfile=/etc/kubernetes/ssl/kubernetes-key.pem \\
  --etcd-servers=${ETCD_ENDPOINTS} \\
  --enable-swagger-ui=true \\
  --allow-privileged=true \\
  --apiserver-count=2 \\
  --audit-log-maxage=30 \\
  --audit-log-maxbackup=3 \\
  --audit-log-maxsize=100 \\
  --audit-log-path=/var/lib/audit.log \\
  --audit-policy-file=/etc/kubernetes/audit-policy.yaml \\
  --event-ttl=1h \\
  --logtostderr=true \\
  --v=6
Restart=on-failure
RestartSec=5
Type=notify
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

```

* 如果你安装的是1.9.x版本的，一定要记住上面的参数`experimental-bootstrap-token-auth`，需要替换成`enable-bootstrap-token-auth`，因为这个参数在1.9.x里面已经废弃掉了
* kube-apiserver 1.6 版本开始使用 etcd v3 API 和存储格式
* `--authorization-mode=RBAC` 指定在安全端口使用RBAC 授权模式，拒绝未通过授权的请求
* kube-scheduler、kube-controller-manager 一般和 kube-apiserver 部署在同一台机器上，它们使用非安全端口和 kube-apiserver通信
* kubelet、kube-proxy、kubectl 部署在其它 Node 节点上，如果通过安全端口访问 kube-apiserver，则必须先通过 TLS 证书认证，再通过 RBAC 授权
* kube-proxy、kubectl 通过使用证书里指定相关的 User、Group 来达到通过 RBAC 授权的目的
* 如果使用了 kubelet TLS Boostrap 机制，则不能再指定 `--kubelet-certificate-authority`、`--kubelet-client-certificate` 和 `--kubelet-client-key` 选项，否则后续 kube-apiserver 校验 kubelet 证书时出现 ”x509: certificate signed by unknown authority“ 错误
* `--admission-control` 值必须包含 `ServiceAccount`，否则部署集群插件时会失败
* `--bind-address` 不能为 `127.0.0.1`
* `--service-cluster-ip-range` 指定 Service Cluster IP 地址段，该地址段不能路由可达
* `--service-node-port-range=${NODE_PORT_RANGE}` 指定 NodePort 的端口范围
* 缺省情况下 kubernetes 对象保存在`etcd/registry` 路径下，可以通过 `--etcd-prefix` 参数进行调整
* kube-apiserver 1.8版本后需要在`--authorization-mode`参数中添加`Node`，即：`--authorization-mode=Node,RBAC`，否则Node 节点无法注册
* 注意要开启审查日志功能，指定`--audit-log-path`参数是不够的，这只是指定了日志的路径，还需要指定一个审查日志策略文件：`--audit-policy-file`，我们也可以使用日志收集工具收集相关的日志进行分析。

审查日志策略文件内容如下：（/etc/kubernetes/audit-policy.yaml）

```
apiVersion: audit.k8s.io/v1beta1 # This is required.
kind: Policy
# Don't generate audit events for all requests in RequestReceived stage.
omitStages:
  - "RequestReceived"
rules:
  # Log pod changes at RequestResponse level
  - level: RequestResponse
    resources:
    - group: ""
      # Resource "pods" doesn't match requests to any subresource of pods,
      # which is consistent with the RBAC policy.
      resources: ["pods"]
  # Log "pods/log", "pods/status" at Metadata level
  - level: Metadata
    resources:
    - group: ""
      resources: ["pods/log", "pods/status"]

  # Don't log requests to a configmap called "controller-leader"
  - level: None
    resources:
    - group: ""
      resources: ["configmaps"]
      resourceNames: ["controller-leader"]

  # Don't log watch requests by the "system:kube-proxy" on endpoints or services
  - level: None
    users: ["system:kube-proxy"]
    verbs: ["watch"]
    resources:
    - group: "" # core API group
      resources: ["endpoints", "services"]

  # Don't log authenticated requests to certain non-resource URL paths.
  - level: None
    userGroups: ["system:authenticated"]
    nonResourceURLs:
    - "/api*" # Wildcard matching.
    - "/version"

  # Log the request body of configmap changes in kube-system.
  - level: Request
    resources:
    - group: "" # core API group
      resources: ["configmaps"]
    # This rule only applies to resources in the "kube-system" namespace.
    # The empty string "" can be used to select non-namespaced resources.
    namespaces: ["kube-system"]

  # Log configmap and secret changes in all other namespaces at the Metadata level.
  - level: Metadata
    resources:
    - group: "" # core API group
      resources: ["secrets", "configmaps"]

  # Log all other resources in core and extensions at the Request level.
  - level: Request
    resources:
    - group: "" # core API group
    - group: "extensions" # Version of group should NOT be included.

  # A catch-all rule to log all other requests at the Metadata level.
  - level: Metadata
    # Long-running requests like watches that fall under this rule will not
    # generate an audit event in RequestReceived.
    omitStages:
      - "RequestReceived"
```

审查日志的相关配置可以查看文档了解：[https://kubernetes.io/docs/tasks/debug-application-cluster/audit/](https://kubernetes.io/docs/tasks/debug-application-cluster/audit/)

### 启动kube-apiserver

```
$ sudo cp kube-apiserver.service /etc/systemd/system/
$ sudo systemctl daemon-reload
$ sudo systemctl enable kube-apiserver
$ sudo systemctl start kube-apiserver
$ sudo systemctl status kube-apiserver
```

```
● kube-apiserver.service - Kubernetes API Server
   Loaded: loaded (/etc/systemd/system/kube-apiserver.service; enabled; vendor preset: enabled)
   Active: active (running) since Mon 2018-08-27 01:46:54 UTC; 1 day 8h ago
     Docs: https://github.com/GoogleCloudPlatform/kubernetes
 Main PID: 1131 (kube-apiserver)
    Tasks: 10
   Memory: 270.4M
      CPU: 15min 59.024s
   CGroup: /system.slice/kube-apiserver.service
           └─1131 /usr/k8s/bin/kube-apiserver --admission-control=NamespaceLifecycle,LimitRanger,ServiceAcc
```

## 6.2 配置和启动kube-controller-manager 

### 创建kube-controller-manager 的systemd unit 文件 (master 01 and master 02)

```
$ cat > kube-controller-manager.service <<EOF
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
ExecStart=/usr/k8s/bin/kube-controller-manager \\
  --address=127.0.0.1 \\
  --master=http://${MASTER_URL}:8080 \\
  --allocate-node-cidrs=true \\
  --service-cluster-ip-range=${SERVICE_CIDR} \\
  --cluster-cidr=${CLUSTER_CIDR} \\
  --cluster-name=kubernetes \\
  --cluster-signing-cert-file=/etc/kubernetes/ssl/ca.pem \\
  --cluster-signing-key-file=/etc/kubernetes/ssl/ca-key.pem \\
  --service-account-private-key-file=/etc/kubernetes/ssl/ca-key.pem \\
  --root-ca-file=/etc/kubernetes/ssl/ca.pem \\
  --leader-elect=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

* `--address` 值必须为 `127.0.0.1`，因为当前 kube-apiserver 期望 scheduler 和 controller-manager 在同一台机器

* `--master=http://${MASTER_URL}:8080`：使用`http`(非安全端口)与 kube-apiserver 通信，需要下面的`haproxy`安装成功后才能去掉8080端口。

* `--cluster-cidr` 指定 Cluster 中 Pod 的 CIDR 范围，该网段在各 Node 间必须路由可达(flanneld保证)

* `--service-cluster-ip-range` 参数指定 Cluster 中 Service 的CIDR范围，该网络在各 Node 间必须路由不可达，必须和 kube-apiserver 中的参数一致

* `--cluster-signing-*` 指定的证书和私钥文件用来签名为 TLS BootStrap 创建的证书和私钥

* `--root-ca-file` 用来对 kube-apiserver 证书进行校验，指定该参数后，才会在Pod 容器的 ServiceAccount 中放置该 CA 证书文件

* `--leader-elect=true` 部署多台机器组成的 master 集群时选举产生一处于工作状态的 `kube-controller-manager` 进程

### 启动kube-controller-manager

```
$ sudo cp kube-controller-manager.service /etc/systemd/system/
$ sudo systemctl daemon-reload
$ sudo systemctl enable kube-controller-manager
$ sudo systemctl start kube-controller-manager
$ sudo systemctl status kube-controller-manager
```

```
● kube-controller-manager.service - Kubernetes Controller Manager
   Loaded: loaded (/etc/systemd/system/kube-controller-manager.service; enabled; ve
   Active: active (running) since Fri 2018-08-24 15:45:17 UTC; 3 days ago
     Docs: https://github.com/GoogleCloudPlatform/kubernetes
 Main PID: 2185 (kube-controller)
    Tasks: 8
   Memory: 8.1M
      CPU: 36.041s
   CGroup: /system.slice/kube-controller-manager.service
           └─2185 /usr/k8s/bin/kube-controller-manager --address=127.0.0.1 --master

Warning: Journal has been rotated since unit was started. Log output is incomplete
```

## 6.3 配置和启动kube-scheduler

### 创建kube-scheduler 的systemd unit文件

```
$ cat > kube-scheduler.service <<EOF
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
ExecStart=/usr/k8s/bin/kube-scheduler \\
  --address=127.0.0.1 \\
  --master=http://${MASTER_URL}:8080 \\
  --leader-elect=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

* `--address` 值必须为 `127.0.0.1`，因为当前 kube-apiserver 期望 scheduler 和 controller-manager 在同一台机器
* `--master=http://${MASTER_URL}:8080`：使用`http`(非安全端口)与 kube-apiserver 通信，需要下面的haproxy启动成功后才能去掉8080端口
* `--leader-elect=true` 部署多台机器组成的 master 集群时选举产生一处于工作状态的 `kube-controller-manager` 进程

### 启动kube-scheduler

```
$ sudo cp kube-scheduler.service /etc/systemd/system/
$ sudo systemctl daemon-reload
$ sudo systemctl enable kube-scheduler
$ sudo systemctl start kube-scheduler
$ sudo systemctl status kube-scheduler
```

```
$ sudo systemctl status kube-scheduler
● kube-scheduler.service - Kubernetes Scheduler
   Loaded: loaded (/etc/systemd/system/kube-scheduler.service; enabled; vendor pres
   Active: active (running) since Fri 2018-08-24 15:45:48 UTC; 3 days ago
     Docs: https://github.com/GoogleCloudPlatform/kubernetes
 Main PID: 2232 (kube-scheduler)
    Tasks: 8
   Memory: 8.3M
      CPU: 14min 13.828s
   CGroup: /system.slice/kube-scheduler.service
           └─2232 /usr/k8s/bin/kube-scheduler --address=127.0.0.1 --master=http://k

Warning: Journal has been rotated since unit was started. Log output is incomplete
```

## 6.4 验证master 节点

```
$ kubectl get componentstatuses
NAME                 STATUS    MESSAGE              ERROR
scheduler            Healthy   ok
controller-manager   Healthy   ok
etcd-2               Healthy   {"health": "true"}
etcd-0               Healthy   {"health": "true"}
etcd-1               Healthy   {"health": "true"}
```




