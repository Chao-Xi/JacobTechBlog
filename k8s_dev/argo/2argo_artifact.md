# 使用 Minio 进行制品管理和 Argo 集成


制品是任何工作流的一部分（比如：`CI/CD` 中），工作流中的步骤会生成制品，然后其他后续步骤可以使用这个制品。

我们这里使用 `Minio` 来作为制品仓库，`Minio` 是兼容 `Amazon S3 API` 的开源对象存储服务器。

首先先安装 Minio，我们这里使用 Helm 来快速的安装

**我们这里使用的是`helm3`**

```
$ helm install minio stable/minio --set service.type=NodePort --set defaultBucket.enabled=true --set defaultBucket.name=my-bucket --set persistence.enabled=false --namespace argo
```


我们这里指定了一个名为 `my-bucket` 的默认 `Bucket`，

* 使用 `NodePort` 类型的 `Service`，
* **另外需要注意的是我这里单纯为了测试，所以将 `persistence.enabled` 设置为了 `false`，对于线上环境一定要记得持久化数据**


```
$ helm install minio stable/minio --set service.type=NodePort --set defaultBucket.enabled=true --set defaultBucket.name=my-bucket --set persistence.enabled=false --namespace argo
NAME: minio
LAST DEPLOYED: Sat Dec  7 17:32:17 2019
NAMESPACE: argo
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
Minio can be accessed via port 9000 on the following DNS name from within your cluster:
minio.argo.svc.cluster.local

To access Minio from localhost, run the below commands:

  1. export POD_NAME=$(kubectl get pods --namespace argo -l "release=minio" -o jsonpath="{.items[0].metadata.name}")

  2. kubectl port-forward $POD_NAME 9000 --namespace argo

Read more about port forwarding here: http://kubernetes.io/docs/user-guide/kubectl/kubectl_port-forward/

You can now access Minio server on http://localhost:9000. Follow the below steps to connect to Minio server with mc client:

  1. Download the Minio mc client - https://docs.minio.io/docs/minio-client-quickstart-guide

  2. mc config host add minio-local http://localhost:9000 AKIAIOSFODNN7EXAMPLE wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY S3v4

  3. mc ls minio-local

Alternately, you can use your browser or the Minio SDK to access the server - https://docs.minio.io/categories/17
```

```
$  kubectl get pods -n argo  -l app=minio
NAME                     READY   STATUS    RESTARTS   AGE
minio-6f75f96c79-cnw2j   1/1     Running   0          85s
```

```
$  kubectl get svc -n argo  -l app=minio
NAME    TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
minio   NodePort   10.108.167.92   <none>        9000:31311/TCP   99s
```

到这里证明 Minio 就已经安装成功了，然后我们就可以通过 `31311` 这个 `NodePort` 端口访问 `Minio` 的 `Dashboard` 页面，

我们可以使用默认的 

* accessKey（AKIAIOSFODNN7EXAMPLE） 
* secretKey（wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY）

登录：

![Alt Image Text](images/2_1.png "body image") 

**然后我们需要把 `Minio` 和 `Argo` 集成在一起，通过编辑 `workflow-controller configmap` 来引用上面的 `Minio Service` 和 `Secret`**


上面我们通过 `Helm` 安装 `Minio` 的时候会自动将默认的 `accessKey` 和 `secretKey` 添加到名为 `minio` 的 `Secret` 对象中去：


```
$  kubectl get secret minio -n argo -o yaml
apiVersion: v1
data:
  accesskey: QUtJQUlPU0ZPRE5ON0VYQU1QTEU=
  secretkey: d0phbHJYVXRuRkVNSS9LN01ERU5HL2JQeFJmaUNZRVhBTVBMRUtFWQ==
kind: Secret
metadata:
  creationTimestamp: "2019-12-07T09:32:17Z"
  labels:
    app: minio
    chart: minio-3.0.2
    heritage: Helm
    release: minio
  name: minio
  namespace: argo
  resourceVersion: "615408"
  selfLink: /api/v1/namespaces/argo/secrets/minio
  uid: e6d6c62c-52cd-4c77-9a91-234f51f8dc3d
type: Opaque
```

直接编辑 `workflow-controller-configmap`，按照如下方式添加上 `Minio` 相关配置：


```
$ kubectl get configmap -n argo
NAME                            DATA   AGE
minio                           1      7m13s
workflow-controller-configmap   0      24h
```

```
$ kubectl edit configmap workflow-controller-configmap -n argo
configmap/workflow-controller-configmap edited
```

```
# Please edit the object below. Lines beginning with a '#' will be ignored,
# and an empty file will abort the edit. If an error occurs while saving this file will be
# reopened with the relevant failures.
#
apiVersion: v1
data:
  config: |
    artifactRepository:
      s3:
        bucket: my-bucket  # 默认的 bucket 名称
        endpoint: minio.argo:9000  # Minio 服务地址
        insecure: true
        # accessKeySecret 和 secretKeySecret 是 secret 中包含的，引入名为 minio 的 k8s secret 对象，这两个 key：'accesskey' 和 'secretkey', 存
储 真是的 minio 认证信息。
        accessKeySecret:
          name: minio
          key: accesskey
        secretKeySecret:
          name: minio
          key: secretkey
kind: ConfigMap
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","kind":"ConfigMap","metadata":{"annotations":{},"name":"workflow-controller-configmap","namespace":"argo"}}
  creationTimestamp: "2019-12-06T09:00:00Z"
  name: workflow-controller-configmap
  namespace: argo
  resourceVersion: "616258"
  selfLink: /api/v1/namespaces/argo/configmaps/workflow-controller-configmap
  uid: 791c8fb3-8c61-47e2-8cc8-86d08569377e
```

编辑完成后我们就完成了 `Minio` 和 `Argo` 的集成。


不过这里需要注意的是 `Secret` 对象是 `namespace `作用域的，上面 `ConfigMap` 解析 `Secret` 对象是和我们使用的 `Workflow` 的 `amespace` 中获取 `Minio Secret` 的，

所以如果 `Minio` 和 `Workflow` 不在同一个 `namespace` 下面，需要我们拷贝一份 `Secret` 到对应的 `namespace` 下面去，**比如我们这里 `Workflow` 都在 `default` 这个 namespace 下面，那么我就需要在 `default` 下面创建相同的 `Secret`：(`minio-secret.yaml`)**

```
apiVersion: v1
kind: Secret
metadata:
  name: minio
type: Opaque
data:
  accesskey: QUtJQUlPU0ZPRE5ON0VYQU1QTEU=
  secretkey: d0phbHJYVXRuRkVNSS9LN01ERU5HL2JQeFJmaUNZRVhBTVBMRUtFWQ==
```

创建上面的 `Secret` 对象：

```
kubectl create -f minio-secret.yaml
```


然后下载我们这里使用到的 `Workflow` 示例文件：

```
$ wget https://raw.githubusercontent.com/argoproj/argo/master/examples/artifact-passing.yaml
```

详细的 Workflow 内容如下图所示：


![Alt Image Text](images/2_2.png "body image") 

上面 Workflow 包括两个步骤：

* 步骤1生成制品：使用 whalesay 模板生成制品
* 步骤2消费制品：使用步骤1中创建的制品并打印消息。

同样，我们使用`argo submit`命令提交这个 Workflow：

```
$  argo submit artifact-passing.yaml
Name:                artifact-passing-nbhfk
Namespace:           default
ServiceAccount:      default
Status:              Pending
Created:             Sat Dec 07 17:55:30 +0800 (now)
```

我们可以看到上面 `Workflow` 的两个步骤都已经成功了，然后我们去 `minio-ui` 上面就可以查看到上面 `Workflow` 生成的制品了：

```
$ argo get artifact-passing-nbhfk
Name:                artifact-passing-nbhfk
Namespace:           default
ServiceAccount:      default
Status:              Succeeded
Created:             Sat Dec 07 17:55:30 +0800 (1 minute ago)
Started:             Sat Dec 07 17:55:30 +0800 (1 minute ago)
Finished:            Sat Dec 07 17:56:02 +0800 (43 seconds ago)
Duration:            32 seconds

STEP                                          PODNAME                            DURATION  MESSAGE
 ✔ artifact-passing-nbhfk (artifact-example)                                               
 ├---✔ generate-artifact (whalesay)           artifact-passing-nbhfk-2540944357  10s       
 └---✔ consume-artifact (print-message)       artifact-passing-nbhfk-3859743691  18s 
```

![Alt Image Text](images/2_3.png "body image") 


上面我们创建的制品被存储在 `Minio` 的 `my-bucket` 中，消费制品的任务根据 `Workflow` 中的定义根据提供的配置拉取制品，`Minio` 类似于 `S3` 提供了一个可共享的链接来使用制品:

![Alt Image Text](images/2_4.png "body image") 

![Alt Image Text](images/2_5.png "body image") 