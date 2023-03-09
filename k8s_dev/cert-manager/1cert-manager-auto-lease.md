# **1 Cert-Manager 实现 K8s 服务域名证书自动化续签**

Cert-Manager 是一款用于 Kubernetes 集群中自动化管理 TLS 证书的开源工具，**它使用了 Kubernetes 的自定义资源定义（CRD）机制，让证书的创建、更新和删除变得非常容易**。

### 设计理念

Cert-Manager 是将 TLS 证书视为一种资源，就像 Pod、Service 和 Deployment 一样，可以使用 Kubernetes API 进行管理。

它使用了自定义资源定义（CRD）机制，通过扩展 Kubernetes API，为证书的生命周期提供了标准化的管理方式

## 架构设计

Cert-Manager 的架构分为两层：**控制层**和**数据层**。

控制层: **负责证书的管理，包括证书的创建、更新和删除等**；

数据层: 负责存储证书相关的数据，**包括证书的私钥、证书请求、证书颁发机构等**。

Cert-Manager 支持多种证书颁发机构，包括 **自签名证书selfSigned**、Let's Encrypt、HashiCorp Vault、Venafi 等。

它还支持多种验证方式，包括 HTTP 验证、DNS 验证和 TLS-SNI 验证等。这些验证方式可以帮助确保证书的颁发机构是可信的，并且确保证书的私钥不会泄露

## 使用场景

Cert-Manager 的使用场景非常广泛，包括以下几个方面：

* HTTPS 访问：通过 Cert-Manager 可以方便地为 Kubernetes 集群中的 Service 和 Ingress 创建 TLS 证书，以便实现 HTTPS 访问。
* **部署安全：Cert-Manager 可以为 Kubernetes 集群中的 Pod 创建 TLS 证书，以确保 Pod 之间的通信是加密的**。
* 服务间认证：Cert-Manager 可以为 Kubernetes 集群中的 Service 创建 TLS 证书，以确保 Service 之间的通信是加密的。
* 其他应用场景：Cert-Manager 还可以用于为其他应用程序创建 TLS 证书，以确保通信是加密的。

## 解决的实际问题

* 自动化管理证书：Cert-Manager 可以自动化地管理 TLS 证书，无需人工干预，自动签发证书以及过期前 renew 证书等问题，避免了证书管理的复杂性和错误。
* 安全性：Cert-Manager 可以帮助确保证书的颁发机构是可信的，并确保证书的私钥不会泄露，从而提高了通信的安全性。
* 管理成本：Cert-Manager 可以通过标准化证书的管理方式，简化证书管理的成本和流程。

### cert-manager 创建证书的过程

在 Kubernetes 中，cert-manager 通过以下流程创建资源对象以签发证书：

* 创建一个 **CertificateRequest** 对象，包含证书的相关信息，例如证书名称、域名等。
	* **该对象指定了使用的 Issuer 或 ClusterIssuer，以及证书签发完成后，需要存储的 Secret 的名称**。
* **Issuer 或 ClusterIssuer 会根据证书请求的相关信息，创建一个 Order 对象，表示需要签发一个证书**。
	* 该对象包含了签发证书所需的域名列表、证书签发机构的名称等信息。
* **证书签发机构根据 Order 对象中的信息创建一个或多个 Challenge 对象，用于验证证书申请者对该域名的控制权**。
	* Challenge 对象包含一个 DNS 记录或 HTTP 服务，证明域名的所有权。
* cert-manager 接收到 Challenge 对象的回应ChallengeResponse后，会将其更新为已解决状态。
	* 证书签发机构会检查所有的 Challenge 对象，如果全部通过验证，则会签发证书。
* 签发证书完成后，证书签发机构会将证书信息写入 Secret 对象，同时将 Order 对象标记为已完成。证书信息现在可以被其他部署对象使用。

cert-manager 在 k8s 中创建证书的整个过程可以通过以下流程图来描述：

```
              +-------------+
              |             |
              |   Ingress/  |
              | annotations |
              |             |
              +------+------+
                     |
                     | watch ingress change
                     |
                     v
              +-------------+
              |             |
              |   Issuer/   |
              | ClusterIssuer |
              |             |
              +------+------+
                     |
                     | Create CertificateRequest
                     |
                     v
              +------+------+
              |             |
              |CertificateRequest|
              |             |
              +------+------+
                     |
                     | Create Order
                     |
                     v
              +------+------+
              |             |
              |      Order  |
              |             |
              +------+------+
                     |
                     | Create Challenges
                     |
                     v
              +------+------+
              |             |
              |  Challenge  |
              |             |
              +------+------+
                     |
                     | Respond to Challenge
                     |
                     v
              +------+------+
              |             |
              |ChallengeResponse|
              |             |
              +------+------+
                     |
                     | Issue Certificate
                     |
                     v
              +------+------+
              |             |
              |     Secret  |
              |             |
              +------+------+
```

实际上在我们手动实践的时候，可以通过以下命令查看各个过程的信息：

```
kubectl get CertificateRequests,Orders,Challenges
```

到这里，在了解了 cert-manager 的设计理念、架构设计、使用场景、实际解决的问题之后，动手操作利用 cert-manager 给实际项目创建证书


## 安装和配置

安装 cert-manager

```

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cert-manager.yaml

NAME                                       READY   STATUS    RESTARTS   AGE
cert-manager-5d495db6fc-6rtxx              1/1     Running   0          9m56s
cert-manager-cainjector-5f9c9d977f-bxchd   1/1     Running   0          9m56s
cert-manager-webhook-57bd45f9c-89q87       1/1     Running   0          9m56s
```

使用 cmctl 命令行工具检查 cert-manager 是否正常

```
brew install cmctl
cmctl check api
```

```
OS=$(go env GOOS); ARCH=$(go env GOARCH); curl -fsSL -o cmctl.tar.gz https://github.com/cert-manager/cert-manager/releases/latest/download/cmctl-$OS-$ARCH.tar.gz

$ tar xzf cmctl.tar.gz
$ sudo mv cmctl /usr/local/bin

$ cmctl help
```

**安装完成后，Cert-manager 将自动创建 CRD（Custom Resource Definitions）和相关的资源，如证书、密钥**

检查 cert-manager 的webhook是否正常

```
cat <<EOF > 02-test-resources.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: cert-manager-test
---
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: test-selfsigned
  namespace: cert-manager-test
spec:
  selfSigned: {}
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: selfsigned-cert
  namespace: cert-manager-test
spec:
  dnsNames:
    - example.com
  secretName: selfsigned-cert-tls
  issuerRef:
    name: test-selfsigned
EOF
```

```
kubectl apply -f 02-test-resources.yaml
kubectl delete -f 02-test-resources.yaml
```

```
$ kubectl get certificate -n cert-manager-test
NAME              READY   SECRET                AGE
selfsigned-cert   True    selfsigned-cert-tls   49s
```

## 创建 cert-manager 的证书颁发实体对象

cert-manager 的 Issuer 和 ClusterIssuer 都是用来定义证书颁发的实体的资源对象。

* **Issuer 是命名空间级别的资源，用于在命名空间内颁发证书**。
	* 例如，当您需要使用自签名证书来保护您的服务，或者使用 Let's Encrypt 等公共证书颁发机构来颁发证书时，**可以使用 Issuer**。
* **ClusterIssuer 是集群级别的资源，用于在整个集群内颁发证书**。
	* 例如，当您需要使用公司的内部 CA 来颁发证书时，可以使用 ClusterIssuer。

知道两者之间的区别之后，你就可以根据自己的使用情况来决定自己的 issuer 的类型。这里列出几种常用的 issuer 使用模板：

创建 staging 环境的证书颁发者 issuer

**`01-Issuer.yaml`**
	
```
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    # The ACME server URL
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    # Email address used for ACME registration
    email: xxx@qq.com #此处填写你的邮箱地址
    # Name of a secret used to store the ACME account private key
    privateKeySecretRef:
      name: letsencrypt-staging
    # Enable the HTTP-01 challenge provider
    solvers:
      - http01:
          ingress:
            class:  nginx
```

> 使用 staging 环境颁发的证书无法正常在公网使用，需要本地添加受信任根证书


* 创建 prod 环境的证书颁发者 issuer

**`03-prod-issuer.yaml`**

```
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    # The ACME server URL
    server: https://acme-v02.api.letsencrypt.org/directory
    # Email address used for ACME registration 欢迎关注·云原生生态圈
    email: xxx@qq.com
    # Name of a secret used to store the ACME account private key
    privateKeySecretRef:
      name: letsencrypt-prod
    # Enable the HTTP-01 challenge provider
    solvers:
      - http01:
          ingress:
            class: nginx
```

* 创建 staging 环境的证书颁发者 ClusterIssuer

**`04-stage-ClusterIssuer.yaml`**

```
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    # The ACME server URL
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    # Email address used for ACME registration 欢迎关注·云原生生态圈
    email: xxx@qq.com
    # Name of a secret used to store the ACME account private key
    privateKeySecretRef:
      name: letsencrypt-staging
    # Enable the HTTP-01 challenge provider
    solvers:
      - http01:
          ingress:
            class:  nginx
```

* 创建 Prod 环境的证书颁发者 ClusterIssuer

**`05-prod-clusterissuer.yaml`**

```
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    # The ACME server URL
    server: https://acme-v02.api.letsencrypt.org/directory
    # Email address used for ACME registration 欢迎关注·云原生生态圈
    email: xxx@qq.com
    # Name of a secret used to store the ACME account private key
    privateKeySecretRef:
      name: letsencrypt-prod
    # Enable the HTTP-01 challenge provider
    solvers:
      - http01:
          ingress:
            class: nginx
```


### **通过应用实际测试一下**

这里我们基本上就完成了 cert-manager 签署证书的所有前置工作，下面通过一个简单实例测试证书：这里我们部署一个开源小项目文件传递柜

**`07-filecodebox.yaml`**

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: filecodebox-pv
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/data/filecodebox"
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: filecodebox-pvc
  namespace: blogs
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: filecodebox
  namespace: blogs
  labels:
    app: filecodebox
spec:
  replicas: 1
  template:
    metadata:
      name: filecodebox
      labels:
        app: filecodebox
    spec:
      containers:
        - name: filecodebox
          image: lanol/filecodebox:latest
          imagePullPolicy: IfNotPresent
          volumeMounts:
            - mountPath: /app/data
              name: filecodeboxdata
            - mountPath: /etc/localtime
              name: timezone
              readOnly: true
      restartPolicy: Always
      volumes:
        - name: filecodeboxdata
          persistentVolumeClaim:
            claimName: filecodebox-pvc
        - name: timezone
          hostPath:
            path: /usr/share/zoneinfo/Asia/Shanghai
  selector:
    matchLabels:
      app: filecodebox
---
apiVersion: v1
kind: Service
metadata:
  name: filecodebox-svc
  namespace: blogs
spec:
  selector:
    app: filecodebox
  ports:
    - port: 12345
  type: ClusterIP
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: filecodebox-ingress
  namespace: blogs
  labels:
    exposed_by: ingress
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod" #此处我们是基于issuer颁发一个prod的证书
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - file.devopsman.cn
      secretName: filecodebox-tls
  rules:
    - host: file.devopsman.cn
      http:
        paths:
          - pathType: Prefix
            path: "/"
            backend:
              service:
                name: filecodebox-svc
                port:
                  number: 12345
```

创建之后，这里就可以检验一下证书的有效期，查看是否生效

```
$  echo | openssl s_client -servername file.devopsman.cn  -connect file.devopsman.cn:443 2>/dev/null | openssl x509 -noout -dates
notBefore=Mar  1 04:02:01 2023 GMT
notAfter=May 30 04:02:00 2023 GMT
```

这里我们也可以通过 kubectl 查看签发生成的证书来确定

```
$ kubectl get certificate -n blogs
NAME              READY   SECRET            AGE
filecodebox-tls   False   filecodebox-tls   23s
```

```
$ kubectl get certificate filecodebox-tls -n blogs -oyaml

apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  creationTimestamp: "2023-03-08T15:35:25Z"
  generation: 1
  labels:
    exposed_by: ingress
  name: filecodebox-tls
  namespace: blogs
  ownerReferences:
  - apiVersion: networking.k8s.io/v1
    blockOwnerDeletion: true
    controller: true
    kind: Ingress
    name: filecodebox-ingress
    uid: 20053dd8-7c27-4a2e-83de-c32e3b1b6856
  resourceVersion: "14184"
  uid: ca530bcf-a4bc-4e1b-8719-23d6a2766417
spec:
  dnsNames:
  - file.devopsman.cn
  issuerRef:
    group: cert-manager.io
    kind: ClusterIssuer
    name: letsencrypt-prod
  secretName: filecodebox-tls
  usages:
  - digital signature
  - key encipherment
status:
  conditions:
  - lastTransitionTime: "2023-03-08T15:35:25Z"
    message: Issuing certificate as Secret does not exist
    observedGeneration: 1
    reason: DoesNotExist
    status: "True"
    type: Issuing
  - lastTransitionTime: "2023-03-08T15:35:25Z"
    message: Issuing certificate as Secret does not exist
    observedGeneration: 1
    reason: DoesNotExist
    status: "False"
    type: Ready
  nextPrivateKeySecretName: filecodebox-tls-f5v7j
```

在上面了解完证书颁发到签发的过程后，就可以通过以下命令查看整个过程大概的细节

```
$ kubectl get CertificateRequests,Orders,Challenges -n blogs 
NAME                                                       APPROVED   DENIED   READY   ISSUER             REQUESTOR                                         AGE
certificaterequest.cert-manager.io/filecodebox-tls-57kv8   True                False   letsencrypt-prod   system:serviceaccount:cert-manager:cert-manager   102s

NAME                                                          STATE     AGE
order.acme.cert-manager.io/filecodebox-tls-57kv8-2430474046   pending   102s

NAME                                                                        STATE     DOMAIN              AGE
challenge.acme.cert-manager.io/filecodebox-tls-57kv8-2430474046-716040620   pending   file.devopsman.cn   99s
```




