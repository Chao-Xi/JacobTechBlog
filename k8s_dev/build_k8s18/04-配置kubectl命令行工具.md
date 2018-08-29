# 4. 配置kubectl 命令行工具

`kubectl`默认从`~/.kube/config`配置文件中获取访问**kube-apiserver地址、证书、用户名等信息，需要正确配置该文件才能正常使用kubectl命令**。

需要将下载的kubectl 二进制文件和生产的~/.kube/config配置文件拷贝到需要使用kubectl 命令的机器上。


## kubectl 安装在哪里 (master01 and all nodes)
`kubectl`是一个和`kube-apiserver`进行交互的一个命令行工具，所以你想安装到那个节点都想，master或者node任意节点都可以，比如你先在master节点上安装，这样你就可以在master节点使用kubectl命令行工具了，如果你想在node节点上使用(**当然安装的过程肯定会用到的**)，你就把master上面的kubectl二进制文件和~/.kube/config文件拷贝到对应的node节点上就行了。


## 环境变量 (master01 and all nodes)
```
$ source /usr/k8s/bin/env.sh
$ export KUBE_APISERVER="https://${MASTER_URL}:6443"
```


	注意这里的KUBE_APISERVER地址，因为我们还没有安装haproxy，所以暂时需要手动指定使用apiserver的6443端口，等
	haproxy安装完成后就可以用使用443端口转发到6443端口去了。

**变量`KUBE_APISERVER` 指定`kubelet` 访问的`kube-apiserver` 的地址，后续被写入~/.kube/config配置文件**


## 下载kubectl  (master01 and master03(node03))


```
$ mkdir ctl && cd ctl

$ wget https://dl.k8s.io/v1.8.2/kubernetes-client-linux-amd64.tar.gz # 如果服务器上下载不下来，可以想办法下载到本地，然后scp上去即可
$ tar -xzvf kubernetes-client-linux-amd64.tar.gz
$ sudo cp kubernetes/client/bin/kube* /usr/k8s/bin/
$ sudo chmod a+x /usr/k8s/bin/kube*
$ export PATH=/usr/k8s/bin:$PATH
```

## 创建admin 证书

`kubectl` 与`kube-apiserver` 的安全端口通信，**需要为安全通信提供TLS 证书和密钥**。创建admin 证书签名请求：

```
$ cat > admin-csr.json <<EOF
{
  "CN": "admin",
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
      "O": "system:masters",
      "OU": "System"
    }
  ]
}
EOF
```

* 后续`kube-apiserver`使用RBAC 对客户端(如kubelet、kube-proxy、Pod)请求进行授权
* `kube-apiserver` 预定义了一些RBAC 使用的RoleBindings，如**cluster-admin** 将**Group** `system:masters`与**Role** `cluster-admin`绑定，该**Role** 授予了调用kube-apiserver所有API 的权限
* O 指定了该证书的**Group** 为**system:masters**，kubectl使用该证书访问**kube-apiserver**时，由于证书被CA 签名，所以认证通过，同时由于证书用户组为经过预授权的**system:masters**，所以被授予访问所有API 的劝降
* hosts 属性值为空列表

### 生成admin 证书和私钥：

```
$ sudo cfssl gencert -ca=/etc/kubernetes/ssl/ca.pem \
  -ca-key=/etc/kubernetes/ssl/ca-key.pem \
  -config=/etc/kubernetes/ssl/ca-config.json \
  -profile=kubernetes admin-csr.json | cfssljson -bare admin

$ ls admin
admin.csr  admin-csr.json  admin-key.pem  admin.pem
$ sudo mv admin*.pem /etc/kubernetes/ssl/
```

## 创建kubectl kubeconfig 文件


```
# 设置集群参数
$ kubectl config set-cluster kubernetes \
  --certificate-authority=/etc/kubernetes/ssl/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER}
# 设置客户端认证参数
$ kubectl config set-credentials admin \
  --client-certificate=/etc/kubernetes/ssl/admin.pem \
  --embed-certs=true \
  --client-key=/etc/kubernetes/ssl/admin-key.pem \
  --token=${BOOTSTRAP_TOKEN}
# 设置上下文参数
$ kubectl config set-context kubernetes \
  --cluster=kubernetes \
  --user=admin
# 设置默认上下文
$ kubectl config use-context kubernetes
```

* `admin.pem`证书O 字段值为`system:masters`，`kube-apiserver` 预定义的 RoleBinding `cluster-admin` 将 Group `system:masters` 与 Role `cluster-admin` 绑定，该 Role 授予了调用`kube-apiserver` 相关 API 的权限
* **生成的kubeconfig 被保存到 `~/.kube/config` 文件**

## 分发kubeconfig 文件 (把master01`~/.kube/config`拷贝到其他的node上)

将`~/.kube/config`文件拷贝到运行`kubectl`命令的机器的`~/.kube/`目录下去。


## 在node上安装和配置kubelet需要`kubectl`
