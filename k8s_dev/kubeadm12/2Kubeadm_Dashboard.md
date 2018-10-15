# 安装 Dashboard 插件


`Kubernetes Dashboard` 是 `k8s`集群的一个 `WEB UI`管理工具，代码托管在 `github` 上，地址：`https://github.com/kubernetes/dashboard`

## 安装：

### 修改官方的配置文件，加入 `NodePort`

```
$ mkdir Dashboard && cd Dashboard
$ wget https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml

$ sudo vi kubernetes-dashboard.yaml

# ------------------- Dashboard Service ------------------- #

kind: Service
apiVersion: v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kube-system
spec:
  type: NodePort
  ports:
    - port: 443
      targetPort: 8443
  selector:
    k8s-app: kubernetes-dashboard
```

为了测试方便，我们将`Service`改成`NodePort`类型，然后直接部署新版本的`dashboard`即可。

```
$ kubectl create -f kubernetes-dashboard.yaml
```

然后我们可以查看 `dashboard` 的外网访问端口：

```
$ kubectl get svc kubernetes-dashboard -n kube-system
```

```
$ kubectl get svc kubernetes-dashboard -n kube-system
NAME                   TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)         AGE
kubernetes-dashboard   NodePort   10.109.105.170   <none>        443:30513/TCP   7h3m
```

然后直接访问集群中的任何一个节点 `IP(192.168.33.62)` 加上上面的`30513`端口即可打开 `dashboard` 页面

**由于 `dashboard` 默认是自建的 `https· 证书，该证书是不受浏览器信任的，所以我们需要强制跳转就可以了。**

默认 `dashboard` 会跳转到登录页面，我们可以看到 `dashboard` 提供了`Kubeconfig`和`token`两种登录方式，我们可以直接跳过或者使用本地的`Kubeconfig`文件进行登录，可以看到会跳转到如下页面： 


![Alt Image Text](images/kube2_1.jpg "Body image")

这是由于该用户没有对`default`命名空间的访问权限。 ​​

## 身份认证


登录 `dashboard` 的时候支持 `Kubeconfig` 和`token` 两种认证方式，`Kubeconfig` 中也依赖`token` 字段，所以生成`token` 这一步是必不可少的。

## 生成token

我们创建一个`admin`用户并授予`admin` 角色绑定，使用下面的`yaml`文件创建`admin`用户并赋予他管理员权限，然后就可以通过`token` 登陆`dashbaord`，这种认证方式本质实际上是通过`Service Account` 的身份认证加上`Bearer token`请求 `API server` 的方式实现，(`admin_sa.yaml`)

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

上面的`admin`用户创建完成后我们就可以获取到该用户对应的`token`了，如下命令：


```
$  kubectl get secret -n kube-system
NAME                  TYPE                                  DATA   AGE
admin-token-hr727     kubernetes.io/service-account-token   3      4h38m
```
```
$ kubectl get secret -n kube-system | grep admin-token*
admin-token-hr727    kubernetes.io/service-account-token   3      4h39m
```

```
$ kubectl get secret admin-token-hr727 -o jsonpath={.data.token} -n kube-system |base64 -d
# 会生成一串很长的base64后的字符串
```

```
eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJhZG1pbi10b2tlbi1ocjcyNyIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJhZG1pbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjljMTFmYjVjLWNkMDctMTFlOC05NzBkLTUyNTQwMGNhZTQ4YiIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlLXN5c3RlbTphZG1pbiJ9.DAhKm-qRVqBPJUqKR3vW2WroSW2bHuWh9GFE2q-FTZlxhn0QEhCAESbITVih68qLml0D3-AkOBX6qg3hs4g1uP2VUUfZdFBoREYgLiqU0QgS_PVPrSbewN0TuEl-jI0hiU3mIsW9kQ-5hNavlR4NnjNWGXuxogtIJCb6h1IfsU-WmUJYo5ZnaS-6WudLPChtj7j7QzZaiQ-9P0bg8QJai3Yjr-WA5r3UAvtLIZNZAP7g8N-ySyKexOuS5DkM77ZubRO0Vs-wB9tNOd5TKLIxEnx-rfHwykLzlW1xqPG9RxCztjiEwQ33t3Emuqd2neaol_1XpUkVWptDWJzpLo7ZkA
```

然后在 `dashboard` 登录页面上直接使用上面得到的 `token` 字符串即可登录，这样就可以拥有管理员权限操作整个 `kubernetes` 集群的对象，当然你也可以为你的登录用户新建一个指定操作权限的用户。​​ 

![Alt Image Text](images/kube2_2.jpg "Body image")