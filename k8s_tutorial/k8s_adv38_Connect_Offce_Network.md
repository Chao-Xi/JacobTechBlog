# kubernetes 办公环境下网络互通方案

**在 `kubernetes` 的网络模型中，基于官方默认的 `CNI` 网络插件 `Flannel`，这种 `Overlay Network`（覆盖网络）可以轻松的实现 `pod` 间网络的互通。**

当我们把基于 `spring cloud` 的微服务迁移到 `k8s` 中后，无须任何改动，微服务 `pod` 可以通过 `Eureka` 注册后可以互相轻松访问。除此之外，我们可以通过 `ingress + ingress controller` ，在每个节点上，把基于 `http 80`端口、`https 443` 端口的用户请求流量引入到集群服务中。

但是实际使用中，我们出现了以下需求：

1. **办公室网络 和 `k8s pod` 网络不通**。开发在电脑完成某个微服务模块开发后，希望本地启动后，能注册到 `k8s` 中开发环境的服务中心进行调试，而不是本地起一堆依赖的服务。
2. **办公室网络 和 `k8s svc` 网络不通.** 在 `k8s` 中运行的 `mysql`、`redis` 等，无法通过 `ingress 7`层暴露，**电脑无法通过客户端工具直接访问；如果我们通过 `service` 的 `NodePort` 模式，会导致维护量工作量巨大**


## 网络互通配置

**`k8s` 集群中新加一台配置不高（2核4G）的 `node` 节点（`node-30`）专门做路由转发，连接办公室网络和 `k8s` 集群 `pod`、`svc`**


* `node-30` IP 地址 `10.60.20.30`
* 内网 `DNS IP` 地址 `10.60.20.1`
* `pod` 网段`10.244.0.0/24`，`svc` 网段`10.96.0.0/12`
* 办公网段 `192.168.0.0/22`

#### 给 `node-30`节点打上污点标签（`taints`），不让 `k8s` 调度 `pod` 来占用资源：

```
kubectl taint nodes node-30 forward=node-30:NoSchedule
```


**`node-30`节点，做`snat`：**

* [What is fucking Source Network Address Translation(snat)](https://docs.paloaltonetworks.com/pan-os/7-1/pan-os-admin/networking/source-nat-and-destination-nat)
* [How to manage D/S NAT](https://netfilter.org/documentation/HOWTO/NAT-HOWTO-6.html)


```
# 开启转发
# vim /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
# sysctl -p

# 来自办公室访问pod、service snat
iptables -t nat -A POSTROUTING -s 192.168.0.0/22 -d 10.244.0.0/24 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 192.168.0.0/22 -d 10.96.0.0/12 -j  MASQUERADE
```

#### 在办公室的出口路由器上，设置静态路由，将 `k8s pod` 和 `service` 的网段，路由到 `node-30` 节点上

```
ip route 10.244.0.0 255.255.255.0 10.60.20.30
ip route 10.96.0.0  255.240.0.0   10.60.20.30
```

![Alt Image Text](images/adv/adv38_1.jpg "Body image")


## DNS 解析配置

以上步骤操作后，我们就可以在本地电脑通过访问 `pod ip` 和 `service ip` 去访问服务。**但是在 `k8s` 中，由于 `pod ip` 随时都可能在变化，`service ip` 也不是开发、测试能轻松获取到的。我们希望内网 `DNS` 在解析 `*.cluster.local`，去`coreDNS`寻找解析结果。**

例如，我们约定将（项目A 、开发环境一 、数据库mysql）部署到 `ProjectA-dev1` 这个 `namespace` 下，由于本地到 `k8s` 集群 `service` 网络已经打通，我们在本地电脑使用 `mysql` 客户端连接时，只需要填写`mysql.ProjectA-dev1.svc.cluster.local`即可，`DNS` 查询请求到了内网`DNS`后，走向 `CoreDNS`，从而解析出 `service ip`。

#### 方案一，最简单的做法，我们把内网`DNS`架设在`node-30`这台节点上，那么他肯定访问到`kube-dns 10.96.0.10`

```
# kubectl  get svc  -n kube-system |grep kube-dns
kube-dns   ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP   20d
```

#### 方案二，由于我们实验场景内网`DNS IP`地址 `10.60.20.1` ，并不在`node-30`上，我们需要打通`10.60.20.1` 访问 `svc`网段`10.96.0.0/12`即可

```
#内网DNS（IP 10.60.20.1） 添加静态路由
route add -net 10.96.0.0/12 gw 10.60.20.30

# node-30（IP 10.60.20.30） 做snat
iptables -t nat -A POSTROUTING -s 10.60.20.1/32 -d 10.96.0.0/12 -j MASQUERADE
```

#### 方案三（实验选择），由于我们实验场景内网`DNS IP 10.60.20.1` 并不在`node-30`上，我们可以用`nodeSelector`在`node-30`部署 一个`nginx ingress controller`， 用4层暴露出来`coredns` 的`TCP/UDP 53`端口。

给`node-30`打上标签：

```
kubectl label nodes node-30 node=dns-l4
```

创建一个`namespace`：

```
kubectl create ns dns-l4
```

在 `namespace dns-l4` 下部署 `nginx-ingress controller`，选择节点`node-30`，并`Tolerate`(容忍）其污点：

```
kind: ConfigMap
apiVersion: v1
metadata:
  name: nginx-configuration
  namespace: dns-l4
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx

---
kind: ConfigMap
apiVersion: v1
metadata:
  name: tcp-services
  namespace: dns-l4
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
data:
  53: "kube-system/kube-dns:53"

---
kind: ConfigMap
apiVersion: v1
metadata:
  name: udp-services
  namespace: dns-l4
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
data:
  53: "kube-system/kube-dns:53"
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: nginx-ingress-serviceaccount
  namespace: dns-l4
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx

---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: nginx-ingress-clusterrole
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
rules:
  - apiGroups:
      - ""
    resources:
      - configmaps
      - endpoints
      - nodes
      - pods
      - secrets
    verbs:
      - list
      - watch
  - apiGroups:
      - ""
    resources:
      - nodes
    verbs:
      - get
  - apiGroups:
      - ""
    resources:
      - services
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - "extensions"
    resources:
      - ingresses
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - ""
    resources:
      - events
    verbs:
      - create
      - patch
  - apiGroups:
      - "extensions"
    resources:
      - ingresses/status
    verbs:
      - update

---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: Role
metadata:
  name: nginx-ingress-role
  namespace: dns-l4
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
rules:
  - apiGroups:
      - ""
    resources:
      - configmaps
      - pods
      - secrets
      - namespaces
    verbs:
      - get
  - apiGroups:
      - ""
    resources:
      - configmaps
    resourceNames:
      # Defaults to "<election-id>-<ingress-class>"
      # Here: "<ingress-controller-leader>-<nginx>"
      # This has to be adapted if you change either parameter
      # when launching the nginx-ingress-controller.
      - "ingress-controller-leader-nginx"
    verbs:
      - get
      - update
  - apiGroups:
      - ""
    resources:
      - configmaps
    verbs:
      - create
  - apiGroups:
      - ""
    resources:
      - endpoints
    verbs:
      - get

---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: RoleBinding
metadata:
  name: nginx-ingress-role-nisa-binding
  namespace: dns-l4
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: nginx-ingress-role
subjects:
  - kind: ServiceAccount
    name: nginx-ingress-serviceaccount
    namespace: dns-l4

---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: nginx-ingress-clusterrole-nisa-binding
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: nginx-ingress-clusterrole
subjects:
  - kind: ServiceAccount
    name: nginx-ingress-serviceaccount
    namespace: dns-l4

---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: nginx-ingress-controller
  namespace: dns-l4
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: ingress-nginx
      app.kubernetes.io/part-of: ingress-nginx
  template:
    metadata:
      labels:
        app.kubernetes.io/name: ingress-nginx
        app.kubernetes.io/part-of: ingress-nginx
      annotations:
        prometheus.io/port: "10254"
        prometheus.io/scrape: "true"
    spec:
      nodeSelector:
        node: dns-l4
      hostNetwork: true
      serviceAccountName: nginx-ingress-serviceaccount
      tolerations:
      - key: "node-30"
        operator: "Exists"
        effect: "NoSchedule"
      containers:
        - name: nginx-ingress-controller
          image: quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.21.0
          args:
            - /nginx-ingress-controller
            - --configmap=$(POD_NAMESPACE)/nginx-configuration
            - --tcp-services-configmap=$(POD_NAMESPACE)/tcp-services
            - --udp-services-configmap=$(POD_NAMESPACE)/udp-services
            - --publish-service=$(POD_NAMESPACE)/ingress-nginx
            - --annotations-prefix=nginx.ingress.kubernetes.io
          securityContext:
            capabilities:
              drop:
                - ALL
              add:
                - NET_BIND_SERVICE
            runAsUser: 33
          env:
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: POD_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
          ports:
            - name: http
              containerPort: 80
            - name: https
              containerPort: 443
          livenessProbe:
            failureThreshold: 3
            httpGet:
              path: /healthz
              port: 10254
              scheme: HTTP
            initialDelaySeconds: 10
            periodSeconds: 10
            successThreshold: 1
            timeoutSeconds: 1
          readinessProbe:
            failureThreshold: 3
            httpGet:
              path: /healthz
              port: 10254
              scheme: HTTP
            periodSeconds: 10
            successThreshold: 1
            timeoutSeconds: 1
```

部署完成后，电脑验证，是否生效：

```
nslookup -q=A kube-dns.kube-system.svc.cluster.local  10.60.20.30
```

![Alt Image Text](images/adv/adv38_2.jpg "Body image")

这里我们用轻量级的`dnsmasq`来作为内网 `dns` 配置案例，将来自内网的`*.cluster.local`解析请求，走 `KubeDNS 10.60.20.30`：

```
# vim /etc/dnsmasq.conf
strict-order
listen-address=10.60.20.1
bogus-nxdomain=61.139.2.69
server=/cluster.local/10.60.20.30

```

完成以上步骤后，我们办公网络与 `kubernetes` 网络互通的需求也就实现了，同时我们可以直接用 `k8s service` 的域名规则去访问到 `k8s` 中的服务。

![Alt Image Text](images/adv/adv38_3.jpg "Body image")




















