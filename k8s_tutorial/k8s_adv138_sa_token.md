# **ServiceAccount Token 在不同 K8s 版本中的使用**

ServiceAccount 为 Pod 中运行的进程提供了一个身份，Pod 内的进程可以使用其关联服务账号的身份，向集群的 APIServer 进行身份认证。


当创建 Pod 的时候规范下面有一个 `spec.serviceAccount` 的属性用来指定该 Pod 使用哪个 `ServiceAccount`，如果没有指定的话则默认使用 default 这个 sa。然后通过投射卷，在 Pod 的目录 `/run/secrets/kubernetes.io/serviceaccount/` 下有一个 token 令牌文件。

我们通过 RBAC 对该 sa 授予了什么权限，那么容器里的应用拿着这个 token 后，就具备了对应的权限。

但是需要注意的是不同的 K8s 版本对该 token 文件的使用是不一样的，所以我们这里分别进行下简单说明。

## `<=1.20` 版本

使用 kind 快速创建一个小于等于 v1.20 版本的集群：

```
☸ ➜ kind create cluster --name kind120 --image kindest/node:v1.20.15


☸ ➜ kubectl get nodes
NAME                    STATUS   ROLES                  AGE   VERSION
kind120-control-plane   Ready    control-plane,master   33s   v1.20.15
```

我们先创建一个字为 sa-demo 的 ServiceAccount 对象：

```
☸ ➜ kubectl create sa sa-demo

☸ ➜ kubectl get sa
NAME      SECRETS   AGE
default   1         43s
sa-demo   1         6s

☸ ➜ kubectl get secret
NAME                  TYPE                                  DATA   AGE
default-token-dv78w   kubernetes.io/service-account-token   3      46s
sa-demo-token-4gvbw   kubernetes.io/service-account-token   3      8s
```

我们可以看到创建 sa 后自动生成了一个 secret，格式为 `<saname>-token-xxxx`，比如我们创建了一个名字为 `sa-demo` 的 sa 之后，系统自动创建了一个名字为 `sa-demo-token-4gvbw` 的 `secret`，这个 secret 里就包含了一个 token。

```
☸ ➜ kubectl describe secrets sa-demo-token-4gvbw
Name:         sa-demo-token-4gvbw
Namespace:    default
Labels:       <none>
Annotations:  kubernetes.io/service-account.name: sa-demo
              kubernetes.io/service-account.uid: 1ae8eea9-acc6-4e3d-b378-07feb9146ac4

Type:  kubernetes.io/service-account-token

Data
====
ca.crt:     1066 bytes
namespace:  7 bytes
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6ImhQNmFMNjAyaDZ5OElyMmtTNGdPUWxRdHVDU1A4aGFfVkJiNHdHMkZjQlUifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6InNhLWRlbW8tdG9rZW4tNGd2YnciLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoic2EtZGVtbyIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjFhZThlZWE5LWFjYzYtNGUzZC1iMzc4LTA3ZmViOTE0NmFjNCIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDpkZWZhdWx0OnNhLWRlbW8ifQ.j0DQmzTeSfagKYGc2dMUuzhYqVQh2puJAoQS0EMKeiAKD6rC4bUHWXWBrCu5Ttvpch6ZTEYwyCdRof1lDGWiLa3pJ1R1RwUNVQTCmVTZPs7tTuoGLRW0KGfEd0jyi4LU6uw4kA_6kwEsz4q2quWcB_fiH_Z3iKVfh1JolYTVAWTBMWnVn6gBvIrlXV5ny2oyvcPQeVfIek8aPQqhbsct_qOxrjqpZY8mpBz0ETR_EELjmcZxVVPLvomOdCqEqbV-FF5KRiFxizB3Xoh6NHz3EcsxpCZNRYdand-UFHaBQC9IPwJKzxhANGmuZuWJUCqCVGGRZTo9c6eoyVz831sZ0A
```

可以看到自动生成的这个 secret 对象里面包含一个 token，我们也可以通过下面的命令来获取：

```
☸ ➜ kubectl get secrets sa-demo-token-4gvbw -o jsonpath='{.data.token}' | base64 -d
```

这个 token 是 JWT 结构的，我们可以把这个 token 复制到 jwt.io 网站进行解码。

![Alt Image Text](images/adv/adv138_1.png "Body image")

右侧部分显示了 token 被解码之后的内容，其中 PAYLOAD 部分是 token 里包含的 sa-demo 的信息，可以看到里面没有过期时间，也说明了该 token 是永不过期的。

现在我们使用上面我们创建的 sa 来运行一个 Pod：

```
# demo-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: demo
spec:
  serviceAccount: sa-demo
  containers:
    - name: demo
      image: nginx:1.7.9
      ports:
        - containerPort: 80
```

直接创建该 Pod 即可：

```
☸ ➜ kubectl apply -f demo-pod.yaml
☸ ➜ kubectl get pods
NAME   READY   STATUS    RESTARTS   AGE
demo   1/1     Running   0          81s
☸ ➜ kubectl get pod demo -oyaml
apiVersion: v1
kind: Pod
metadata:
  name: demo
  namespace: default
spec:
  containers:
  - image: nginx:1.7.9
    imagePullPolicy: IfNotPresent
    name: demo
# ......
    volumeMounts:
    - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      name: sa-demo-token-4gvbw
      readOnly: true
# ......
  volumes:
  - name: sa-demo-token-4gvbw
    secret:
      defaultMode: 420
      secretName: sa-demo-token-4gvbw
```

Pod 创建后我们可以看到会自动将指定 sa 对应的 secret 挂载到容器的 /`var/run/secrets/kubernetes.io/serviceaccount` 目录下去，所以现在该目录下面肯定包含对应的 token 文件，我们可以查看该值来验证下：

```
☸ ➜ kubectl exec -it demo -- cat /run/secrets/kubernetes.io/serviceaccount/token
eyJhbGciOiJSUzI1NiIsImtpZCI6ImhQNmFMNjAyaDZ5OElyMmtTNGdPUWxRdHVDU1A4aGFfVkJiNHdHMkZjQlUifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6InNhLWRlbW8tdG9rZW4tNGd2YnciLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoic2EtZGVtbyIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjFhZThlZWE5LWFjYzYtNGUzZC1iMzc4LTA3ZmViOTE0NmFjNCIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDpkZWZhdWx0OnNhLWRlbW8ifQ.j0DQmzTeSfagKYGc2dMUuzhYqVQh2puJAoQS0EMKeiAKD6rC4bUHWXWBrCu5Ttvpch6ZTEYwyCdRof1lDGWiLa3pJ1R1RwUNVQTCmVTZPs7tTuoGLRW0KGfEd0jyi4LU6uw4kA_6kwEsz4q2quWcB_fiH_Z3iKVfh1JolYTVAWTBMWnVn6gBvIrlXV5ny2oyvcPQeVfIek8aPQqhbsct_qOxrjqpZY8mpBz0ETR_EELjmcZxVVPLvomOdCqEqbV-FF5KRiFxizB3Xoh6NHz3EcsxpCZNRYdand-UFHaBQC9IPwJKzxhANGmuZuWJUCqCVGGRZTo9c6eoyVz831sZ0A
```

可以看到 Pod 里通过投射卷所挂载的 token 跟 sa-demo 对应的 secret 包含的 token 是模一样的，这个 token 是永不过期的，所以即使删除了 Pod 之后重新创建，Pod 里的 token 仍然是不变的，因为 secret 对象里面的 token 数据并没有变化。

如果需要在 Pod 中去访问 K8s 集群的资源对象，**现在就可以为使用的 sa 绑定上相应的权限，然后在 Pod 应用中使用该对应的 token 去和 APIServer 进行通信就可以了，这个时候的 token 就能识别到对应的权限了**。

## `>=1.21 ` 版本 && `<= 1.23` 版本

接下来我们基于 >= 1.21 && <= 1.23 版本的 K8s 集群进行测试。

这里我们使用 kind 快速创建一个 v1.22.15 版本的集群：

```
☸ ➜ kind create cluster --name kind122 --image kindest/node:v1.22.15
☸ ➜ kubectl get nodes
NAME                    STATUS   ROLES                  AGE    VERSION
kind122-control-plane   Ready    control-plane,master   115s   v1.22.15
```

同样首先创建一个名为 sa-demo 的 ServiceAccount 对象：

```
☸ ➜ kubectl create sa sa-demo
☸ ➜ kubectl get sa
NAME      SECRETS   AGE
default   1         43s
sa-demo   1         6s
☸ ➜ kubectl get secret
NAME                  TYPE                                  DATA   AGE
default-token-9w9bp   kubernetes.io/service-account-token   3      116s
sa-demo-token-g7d2g   kubernetes.io/service-account-token   3      8s
```

同样可以看到创建 sa 后系统也自动创建了一个对应的 secret 对象，和以前版本没什么区别，我们也可以通过下面的命令来获得该 secret 对象里面包含的 token 值：

```
☸ ➜ kubectl get secrets sa-demo-token-g7d2g -o jsonpath='{.data.token}' | base64 -d
eyJhbGciOiJSUzI1NiIsImtpZCI6Im1ERkhnQ3Y3b1oxUmNHbWVhN210SDEwNXY2dVNkc0QzdXJjTkhsY21FRVEifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6InNhLWRlbW8tdG9rZW4tZzdkMmciLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoic2EtZGVtbyIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjI3ZGI0M2FjLTdjYjItNDQ2Yi05N2Q1LWU0MGUzOWRjZTg4YyIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDpkZWZhdWx0OnNhLWRlbW8ifQ.fnSaqrZKolTfz2pi9t32X38Er60WSzUoRHArte6qVmQ1NTaMis4F6rESWekeJvGW26szTJdll6vK8KtL_IRO2m6sp_fEAYfNMQMXL4CuaRByXeAavDqLgMHhodf4k4Yg-Mj4LCQ3aHOxojbAbPT1i_h17Ewivc39fmzp-dAXbHhhWhCW2Vl_CkM-F-UtzLyDwThvJedkeetrfyOOjE7K6HpzWfqIQyMUdCJog3WnFO_4kHXacFCgYg_gNPMYyViQAsTsxB8FplGdEzRuWKnQO9cDE55V4l55IxmE0er-dSSdG8085PzxaM_lMCtRI8YtjRjxcbxS5QkTm5R_ps0IsA
```

同样将该 token 值拷贝到 jwt.io 网站进行解码。

![Alt Image Text](images/adv/adv138_2.png "Body image")

从解码后的值可以看到该 token 值里面同样不包含任何过期时间，也说明了我们创建 sa 之后，所对应的 token 是永不过期的。

同样我们再次使用上面的 sa 来创建一个 Pod，如下所示：

```
# demo-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: demo
spec:
  serviceAccount: sa-demo
  containers:
    - name: demo
      image: nginx:1.7.9
      ports:
        - containerPort: 80
```

直接创建该 Pod：

```
☸ ➜ kubectl apply -f demo-pod.yaml
☸ ➜ kubectl get pods
NAME   READY   STATUS    RESTARTS   AGE
demo   1/1     Running   0          81s
☸ ➜ kubectl get pod demo -oyaml
apiVersion: v1
kind: Pod
metadata:
  name: demo
  namespace: default
spec:
  containers:
  - image: nginx:1.7.9
    imagePullPolicy: IfNotPresent
    name: demo
    ports:
    - containerPort: 80
      protocol: TCP
    volumeMounts:
    - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      name: kube-api-access-6wmfb
      readOnly: true
# ......
  volumes:
  - name: kube-api-access-6wmfb
    projected:
      defaultMode: 420
      sources:
      - serviceAccountToken:
          expirationSeconds: 3607
          path: token
      - configMap:
          items:
          - key: ca.crt
            path: ca.crt
          name: kube-root-ca.crt
      - downwardAPI:
          items:
          - fieldRef:
              apiVersion: v1
              fieldPath: metadata.namespace
            path: namespace
```

**当 Pod 创建后查看对应的资源对象，可以看到和之前的版本已经有一个很大的区别了，并不是将上面自动创建的 secret 挂载到容器的 `/var/run/secrets/kubernetes.io/serviceaccount ` 目录。**

我们可以查看下 Pod 中的 token 值来和 secret 包含的 token 值进行对比：

```
☸ ➜ kubectl exec -it demo -- cat /run/secrets/kubernetes.io/serviceaccount/token
eyJhbGciOiJSUzI1NiIsImtpZCI6Im1ERkhnQ3Y3b1oxUmNHbWVhN210SDEwNXY2dVNkc0QzdXJjTkhsY21FRVEifQ.eyJhdWQiOlsiaHR0cHM6Ly9rdWJlcm5ldGVzLmRlZmF1bHQuc3ZjLmNsdXN0ZXIubG9jYWwiXSwiZXhwIjoxNzA1MDI1NDU4LCJpYXQiOjE2NzM0ODk0NTgsImlzcyI6Imh0dHBzOi8va3ViZXJuZXRlcy5kZWZhdWx0LnN2Yy5jbHVzdGVyLmxvY2FsIiwia3ViZXJuZXRlcy5pbyI6eyJuYW1lc3BhY2UiOiJkZWZhdWx0IiwicG9kIjp7Im5hbWUiOiJkZW1vIiwidWlkIjoiNzY1ODRmODAtZjU1My00Mzk2LWIxOTUtMDEwOTBhMzM4MWYyIn0sInNlcnZpY2VhY2NvdW50Ijp7Im5hbWUiOiJzYS1kZW1vIiwidWlkIjoiMjdkYjQzYWMtN2NiMi00NDZiLTk3ZDUtZTQwZTM5ZGNlODhjIn0sIndhcm5hZnRlciI6MTY3MzQ5MzA2NX0sIm5iZiI6MTY3MzQ4OTQ1OCwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50OmRlZmF1bHQ6c2EtZGVtbyJ9.TAoe1eCHCXUoHh6oM4uySp8kzRaLQ44GZdU02Ir8m_dzYpdFSw4nwsNyqPggrZdDL3BMH4zceudBEdQuyxiSsrpVDeQKww2wTGhXAr2hWujrJq4ycmu6aMywyv2iRX9Vn-Las1giWK_bFuzCxiR10Lcgyd5N7VjB2WcT7K8rN7dAeUWgiH2s9lMOzoaIorUDXzlnSTcmxkhz1h7RXYKVGaqZBbd5wJsRnINZPGxqsS-wi21Aw2FFmIeeK8GGlnAqnS0f3VS1N2jm03gKPii-sMt0GARse4HsmhGAhyJnt9za6ZNpBgcybd7uEBjgIVrRFTkqBJOjPrAnMvRucVtwww
```

可以很明显看到现在 Pod 中的 token 值和自动创建 secret 的 token 值不一样了，同样在 jwt.io 解码该 token 值。

![Alt Image Text](images/adv/adv138_3.png "Body image")

可以看到该 token 值解码后的 PAYLOAD 数据中包含了很多不同的数据，其中的 exp 字段表示该 token 的过期时间，可以看到过期时间是 1 年。

这里我们可以总结下在 v1.21 到 v1.23 版本的 K8s 集群，当创建 ServiceAccount 对象后，系统仍然会自动创建一个 secret 对象，该 secret 对象里面包含的 token 仍然是永不过期的，但是 Pod 里面并不会使用该 secret 的 token 值了。

从上面查看创建后的 Pod 资源清单可以看出，现在创建 Pod 后，Kubernetes 控制平面会自动添加一个投射卷到 Pod，此卷包括了访问 Kubernetes API 的 token，该清单片段定义了由三个数据源组成的投射卷，这三个数据源是：

* `serviceAccountToken` 数据源：包含 kubelet 从 kube-apiserver 获取的令牌，kubelet 使用 TokenRequest API 获取有时间限制的令牌。为 TokenRequest 服务的这个令牌会在 Pod 被删除或定义的生命周期（默认为 1 小时）结束之后过期。该令牌绑定到特定的 Pod， 并将其 audience（受众）设置为与 kube-apiserver 的 audience 相匹配。 这种机制取代了之前基于 Secret 添加卷的机制，之前 Secret 代表了针对 Pod 的 ServiceAccount 但不会过期。
* `configMap` 数据源：ConfigMap 包含一组证书颁发机构数据，Pod 可以使用这些证书来确保自己连接到集群的 `kube-apiserver`（而不是连接到中间件或意外配置错误的对等点上）。
* downwardAPI 数据源：用于查找包含 Pod 的名字空间的名称，并使该名称信息可用于在 Pod 内运行的应用程序代码。

所以我们应该要指定现在版本的 K8s 集群创建的 Pod 里面包含的 token 不是使用 ServiceAccount 自动关联的 secret 对象里面的 token 了，而是 kubelet 会向 TokenRequest API 发送一个请求，申请一个新的 token 放在 Pod 的 `/run/secrets/kubernetes.io/serviceaccount/token` 里。

这个 token 会在 1 个小时后由 kubelet 重新去申领一个新的 token，所以 1 小时之后再次查看这个 token 的话会发现 token 的内容是变化的，如果删除此 Pod 重新创建的话，则会重新申领 token，被删除 Pod 里的 token 会立即过期。


而且我们还可以手动使用 `kubectl create token <sa>` 命令来请求 `ServiceAccount` 的 token，可以指定有效期等：

```

☸ ➜ kubectl create token -h
Request a service account token.

Examples:
  # Request a token to authenticate to the kube-apiserver as the service account "myapp" in the current namespace
  kubectl create token myapp

  # Request a token for a service account in a custom namespace
  kubectl create token myapp --namespace myns

  # Request a token with a custom expiration
  kubectl create token myapp --duration 10m

  # Request a token with a custom audience
  kubectl create token myapp --audience https://example.com

  # Request a token bound to an instance of a Secret object
  kubectl create token myapp --bound-object-kind Secret --bound-object-name mysecret

  # Request a token bound to an instance of a Secret object with a specific uid
  kubectl create token myapp --bound-object-kind Secret --bound-object-name mysecret --bound-object-uid
0d4691ed-659b-4935-a832-355f77ee47cc

Options:
# ......
```

## `>=1.24` 版本

现在我们再来看下 v1.24 版本以上的 K8s 集群中的 ServiceAccount token 是如何工作的。这里我们使用 kind 快速创建一个 v1.25.3 版本的集群：

```
☸ ➜ kind create cluster --name kind125 --image kindest/node:v1.25.3
☸ ➜ kubectl get nodes
NAME                    STATUS   ROLES                  AGE    VERSION
kind125-control-plane   Ready    control-plane,master   115s   v1.25.3
```

同样创建一个名为 sa-demo 的 ServiceAccount：

```
☸ ➜ kubectl create sa sa-demo
☸ ➜ kubectl get sa
NAME      SECRETS   AGE
default   0         39d
sa-demo   0         5s
☸ ➜ kubectl get secrets
No resources found in ns1 namespace
```

我们可以看到该 ServiceAccount 创建后并没有创建对应的 Secret 对象。同样接下来创建一个如下所示的 Pod：

```
# demo-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: demo
spec:
  serviceAccount: sa-demo
  containers:
    - name: demo
      image: nginx:1.7.9
      ports:
        - containerPort: 80
```

创建上面的 Pod 后查看详情：

```
☸ ➜ kubectl apply -f demo-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: demo
  namespace: default
spec:
  containers:
  - image: nginx:1.7.9
    imagePullPolicy: IfNotPresent
    name: demo
    ports:
    - containerPort: 80
      protocol: TCP
    volumeMounts:
    - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      name: kube-api-access-pftqd
      readOnly: true
# ......
  volumes:
  - name: kube-api-access-pftqd
    projected:
      defaultMode: 420
      sources:
      - serviceAccountToken:
          expirationSeconds: 3607
          path: token
      - configMap:
          items:
          - key: ca.crt
            path: ca.crt
          name: kube-root-ca.crt
      - downwardAPI:
          items:
          - fieldRef:
              apiVersion: v1
              fieldPath: metadata.namespace
            path: namespace
```

可以看到创建 Pod 后同样会自动添加一个投射卷到 Pod，此卷包括了访问 Kubernetes API 的令牌，和 `>=1.21` 版本 `&& <= 1.23` 版本 表现是一致的。同样我们可以下查看 Pod 中的 token 值来进行验证：

```
☸ ➜ kubectl exec -it demo -- cat /run/secrets/kubernetes.io/serviceaccount/token
eyJhbGciOiJSUzI1NiIsImtpZCI6IndnazJLZENQTktiZkxVejhnMnhmTHJYRTlkZ2ZnOHJGQmgwVW4td3BWd0kifQ.eyJhdWQiOlsiaHR0cHM6Ly9rdWJlcm5ldGVzLmRlZmF1bHQuc3ZjLmNsdXN0ZXIubG9jYWwiXSwiZXhwIjoxNzA0ODg0MDg0LCJpYXQiOjE2NzMzNDgwODQsImlzcyI6Imh0dHBzOi8va3ViZXJuZXRlcy5kZWZhdWx0LnN2Yy5jbHVzdGVyLmxvY2FsIiwia3ViZXJuZXRlcy5pbyI6eyJuYW1lc3BhY2UiOiJkZWZhdWx0IiwicG9kIjp7Im5hbWUiOiJkZW1vIiwidWlkIjoiMTY0ZTIwZTYtYjNjMi00ZmQ5LWI3ZTUtMDZjYTExZWIyOWM4In0sInNlcnZpY2VhY2NvdW50Ijp7Im5hbWUiOiJzYS1kZW1vIiwidWlkIjoiYjJlNWM3ZmYtNjlhNy00NzYyLTkxMDctM2UxNzZhYmQ3NTdiIn0sIndhcm5hZnRlciI6MTY3MzM1MTY5MX0sIm5iZiI6MTY3MzM0ODA4NCwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50OmRlZmF1bHQ6c2EtZGVtbyJ9.lhYscyn_d9Y3GZSipSqGj4Jtsu8qsIyz34L18lv37HxjjGU_bQmUFCXYf_CRom8DfadHppmlaskZS18KmyTV1Z09BeujJd8viUnnYCWb9K6VJB5uPBYWLB0FETfgQy7Kqu8Gvk8qBKLjdCkl8U2vr2Oqd2qSEDyvqhNBQXnckQRH6wyypBUc7EXSGAJf6dPVE3c6XqnbXMJ7SRZb5svE-hv0lZKmJrouz9Ia4qxUXUtpzDlMPnHOym2x9d1TSSZ1Lp7BOsqTnxlUQVueh9w869jAajrP1G9e5zhZwZBfzRfARqCVqoLid_hOQP-mo4MLfHbn61SWItlCBd75nl2WLQ
```

我们可以把上面输出的 token 值拷贝到 jwt.io 里进行解码。

![Alt Image Text](images/adv/adv138_4.png "Body image")

**从上面的数据可以看到这里的 token 的有效期也为 1 年，这个 token 在 Pod 里也是每 1 小时会更新一次，如果 Pod 被删除重建，那么会重新申领一个新的 token，被删除 Pod 里的 token 立即过期**。

需要注意的没有特定的机制使通过 TokenRequest 签发的令牌无效，如果你不再信任为某个 Pod 绑定的 ServiceAccount 令牌，你可以删除该 Pod，删除 Pod 将使其绑定的令牌过期。

## 总结

我们可以简单总结下不同版本的 K8s 集群下面的 ServiceAccount Token 是如何工作的。

1.20（含 1.20）之前的版本，**在创建 sa 时会自动创建一个 secret，然后这个会把这个 secret 通过投射卷挂载到 pod 里，该 secret 里面包含的 token 是永久有效的**。

1.21~1.23 版本，**在创建 sa 时也会自动创建 secret，但是在 pod 里并不会使用 secret 里的 token，而是由 kubelet 到 TokenRequest API 去申请一个 token，该 token 默认有效期为一年，但是 pod 每一个小时会更新一次 token**。

**1.24 版本及以上，在创建 sa 时不再自动创建 secret 了，只保留由 kubelet 到 TokenRequest API 去申请 token。**

当然我们仍然可以手动创建 Secret 来保存 ServiceAccount 令牌，例如在你需要一个永不过期的令牌的时候。

一旦手动创建一个 Secret 并将其关联到 ServiceAccount，Kubernetes 控制平面就会自动将令牌填充到该 Secret 中