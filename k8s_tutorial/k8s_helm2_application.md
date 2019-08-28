![Alt Image Text](images/helm/helm2_0.jpg "Headline image")
##  Helm 的基本使用

上节课我们成功安装了`Helm`的客户端以及服务端`Tiller Server`，我们也自己尝试创建了我们的第一个 `Helm Chart` 包，这节课就来和大家一起学习下 `Helm` 中的一些常用的操作方法。

## 仓库

`Helm` 的 `Repo` 仓库和 `Docker Registry` 比较类似，`Chart` 库可以用来存储和共享打包 `Chart` 的位置，我们在安装了 `Helm` 后，默认的仓库地址是 `google` 的一个地址，这对于我们不能科学上网的同学就比较苦恼了，没办法访问到官方提供的 `Chart` 仓库，可以用`helm repo list`来查看当前的仓库配置：

```
$ helm repo list
NAME  	URL
stable	https://kubernetes-charts.storage.googleapis.com
local 	http://127.0.0.1:8879/charts
```

我们可以看到除了一个默认的 `stable` 的仓库配置外，还有一个 `local` 的本地仓库，这是我们本地测试的一个仓库地址。其实要创建一个 `Chart` 仓库也是非常简单的，`Chart` 仓库其实就是一个带有`index.yaml`索引文件和任意个打包的 `Chart` 的 `HTTP` 服务器而已，比如我们想要分享一个 `Chart` 包的时候，将我们本地的 `Chart` 包上传到该服务器上面，别人就可以使用了，所以其实我们自己托管一个 `Chart` 仓库也是非常简单的，比如阿里云的 `OSS`、`Github Pages`，甚至自己创建的一个简单服务器都可以。

为了解决科学上网的问题，这里建了一个 `Github Pages` 仓库，每天会自动和官方的仓库进行同步，地址是：`https://github.com/cnych/kube-charts-mirror`，这样我们就可以将我们的 `Helm` 默认仓库地址更改成我们自己的仓库地址了：

```
$ helm repo remove stable
"stable" has been removed from your repositories
$ helm repo add stable https://cnych.github.io/kube-charts-mirror/
"stable" has been added to your repositories
$ helm repo list
NAME       URL
stable     https://cnych.github.io/kube-charts-mirror/
local      http://127.0.0.1:8879/charts
$ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Skip local chart repository
...Successfully got an update from the "stable" chart repository
Update Complete. ⎈ Happy Helming!⎈
```

仓库添加完成后，可以使用 `update` 命令进行仓库更新。当然如果要我们自己来创建一个 `web` 服务器来服务 `Helm Chart` 的话，只需要实现下面几个功能点就可以提供服务了：

* 将索引和`Chart`置于服务器目录中
* 确保索引文件`index.yaml`可以在没有认证要求的情况下访问
* 确保 `yaml` 文件的正确内容类型（`text/yaml` 或 `text/x-yaml`）

如果你的 `web` 服务提供了上面几个功能，那么也就可以当做 `Helm Chart` 仓库来使用了。

## 查找 chart

`Helm` 将 `Charts` 包安装到 `Kubernetes` 集群中，一个安装实例就是一个新的 `Release`，要找到新的 `Chart`，我们可以通过搜索命令完成。

直接运行`helm search`命令可以查看有哪些 `Charts` 是可用的：

```
helm search
NAME                                 	CHART VERSION	APP VERSION                 	DESCRIPTION
local/hello-helm                     	0.1.0        	1.0                         	A Helm chart for Kubernetes
stable/acs-engine-autoscaler         	2.2.0        	2.1.1                       	Scales worker nodes within agent pools
stable/aerospike                     	0.1.7        	v3.14.1.2                   	A Helm chart for Aerospike in Kubernetes
stable/anchore-engine                	0.2.3        	0.2.4                       	Anchore container analysis and policy evaluatio...
stable/apm-server                    	0.1.0        	6.2.4                       	The server receives data from the Elastic APM a...
stable/ark                           	1.2.1        	0.9.1                       	A Helm chart for ark
...
```
如果没有使用过滤条件，`helm search` 显示所有可用的 `charts`。可以通过使用过滤条件进行搜索来缩小搜索的结果范围：

```
$ helm search mysql
NAME                            	CHART VERSION	APP VERSION	DESCRIPTION
stable/mysql                    	0.10.1       	5.7.14     	Fast, reliable, scalable, and easy to use open-...
stable/mysqldump                	1.0.0        	5.7.21     	A Helm chart to help backup MySQL databases usi...
stable/prometheus-mysql-exporter	0.1.0        	v0.10.0    	A Helm chart for prometheus mysql exporter with...
stable/percona                  	0.3.2        	5.7.17     	free, fully compatible, enhanced, open source d...
stable/percona-xtradb-cluster   	0.1.5        	5.7.19     	free, fully compatible, enhanced, open source d...
stable/phpmyadmin               	1.1.0        	4.8.2      	phpMyAdmin is an mysql administration frontend
stable/gcloud-sqlproxy          	0.5.0        	1.11       	Google Cloud SQL Proxy
stable/mariadb                  	5.0.5        	10.1.36    	Fast, reliable, scalable, and easy to use open-...
```

可以看到明显少了很多 `charts` 了，同样的，我们可以使用 `inspect` 命令来查看一个 `chart` 的详细信息：

```
$ helm inspect stable/mysql
appVersion: 5.7.14
description: Fast, reliable, scalable, and easy to use open-source relational database
  system.
engine: gotpl
home: https://www.mysql.com/
icon: https://www.mysql.com/common/logos/logo-mysql-170x115.png
keywords:
- mysql
- database
- sql
maintainers:
- email: o.with@sportradar.com
  name: olemarkus
- email: viglesias@google.com
  name: viglesiasce
name: mysql
sources:
- https://github.com/kubernetes/charts
- https://github.com/docker-library/mysql
version: 0.10.1

---
## mysql image version
## ref: https://hub.docker.com/r/library/mysql/tags/
##
image: "mysql"
...
```

使用 `inspect` 命令可以查看到该 `chart` 里面所有描述信息，包括运行方式、配置信息等等。

通过 `helm search` 命令可以找到我们想要的 `chart` 包，找到后就可以通过 `helm install` 命令来进行安装了。

## 安装 chart

要安装新的软件包，直接使用 `helm install` 命令即可。最简单的情况下，它只需要一个 `chart` 的名称参

```
$ helm install stable/mysql
NAME:   queenly-angelfish
LAST DEPLOYED: Thu Sep 27 05:01:54 2018
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/Secret
NAME                     TYPE    DATA  AGE
queenly-angelfish-mysql  Opaque  2     1s

==> v1/ConfigMap
NAME                          DATA  AGE
queenly-angelfish-mysql-test  1     1s

==> v1/PersistentVolumeClaim
NAME                     STATUS   VOLUME  CAPACITY  ACCESS MODES  STORAGECLASS  AGE
queenly-angelfish-mysql  Pending  1s

==> v1/Service
NAME                     TYPE       CLUSTER-IP     EXTERNAL-IP  PORT(S)   AGE
queenly-angelfish-mysql  ClusterIP  10.254.193.49  <none>       3306/TCP  1s

==> v1beta1/Deployment
NAME                     DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE
queenly-angelfish-mysql  1        1        1           0          1s

==> v1/Pod(related)
NAME                                      READY  STATUS   RESTARTS  AGE
queenly-angelfish-mysql-76dfb56855-nczpx  0/1    Pending  0         1s


NOTES:
MySQL can be accessed via port 3306 on the following DNS name from within your cluster:
queenly-angelfish-mysql.default.svc.cluster.local

To get your root password run:

    MYSQL_ROOT_PASSWORD=$(kubectl get secret --namespace default queenly-angelfish-mysql -o jsonpath="{.data.mysql-root-password}" | base64 --decode; echo)

To connect to your database:

1. Run an Ubuntu pod that you can use as a client:

    kubectl run -i --tty ubuntu --image=ubuntu:16.04 --restart=Never -- bash -il

2. Install the mysql client:

    $ apt-get update && apt-get install mysql-client -y

3. Connect using the mysql cli, then provide your password:
    $ mysql -h queenly-angelfish-mysql -p

To connect to your database directly from outside the K8s cluster:
    MYSQL_HOST=127.0.0.1
    MYSQL_PORT=3306

    # Execute the following command to route the connection:
    kubectl port-forward svc/queenly-angelfish-mysql 3306

    mysql -h ${MYSQL_HOST} -P${MYSQL_PORT} -u root -p${MYSQL_ROOT_PASSWORD}
```

现在 `mysql chart` 已经安装上了，安装 `chart` 会创建一个新 `release` 对象。
上面的 `release` 被命名为 `queenly-angelfish`。如果你想使用你自己的 `release` 名称，只需使用`--name`参数指定即可，比如：

```
$ helm install stable/mysql --name mydb
```

在安装过程中，`helm` 客户端将打印有关创建哪些资源的有用信息，`release` 的状态以及其他有用的配置信息，比如这里的有访问 `mysql` 服务的方法、获取 `root` 用户的密码以及连接 `mysql` 的方法等信息。

### 值得注意的是 Helm 并不会一直等到所有资源都运行才退出。因为很多 charts 需要的镜像资源非常大，所以可能需要很长时间才能安装到集群中去。

要跟踪 `release` 状态或重新读取配置信息，可以使用 `helm status` 查看：

```
$ helm status queenly-angelfish
LAST DEPLOYED: Thu Sep 27 05:01:54 2018
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/Service
NAME                     TYPE       CLUSTER-IP     EXTERNAL-IP  PORT(S)   AGE
queenly-angelfish-mysql  ClusterIP  10.254.193.49  <none>       3306/TCP  27m

==> v1beta1/Deployment
NAME                     DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE
queenly-angelfish-mysql  1        1        1           0          27m

==> v1/Pod(related)
NAME                                      READY  STATUS   RESTARTS  AGE
queenly-angelfish-mysql-76dfb56855-nczpx  0/1    Pending  0         27m

==> v1/Secret
NAME                     TYPE    DATA  AGE
queenly-angelfish-mysql  Opaque  2     27m

==> v1/ConfigMap
NAME                          DATA  AGE
queenly-angelfish-mysql-test  1     27m

==> v1/PersistentVolumeClaim
NAME                     STATUS   VOLUME  CAPACITY  ACCESS MODES  STORAGECLASS  AGE
queenly-angelfish-mysql  Pending  27m
...
```

可以看到当前 `release` 的状态是`DEPLOYED`，下面还有一些安装的时候出现的信息。

## 自定义 chart

上面的安装方式是使用 `chart` 的默认配置选项。但是在很多时候，我们都需要自定义 `chart` 以满足自身的需求，要自定义 `chart`，我们就需要知道我们使用的 `chart` 支持的可配置选项才行。

要查看 `chart` 上可配置的选项，使用`helm inspect values`命令即可，比如我们这里查看上面的 `mysql` 的配置选项：

```
$ helm inspect values stable/mysql
## mysql image version
## ref: https://hub.docker.com/r/library/mysql/tags/
##
image: "mysql"
imageTag: "5.7.14"

## Specify password for root user
##
## Default: random 10 character string
# mysqlRootPassword: testing

## Create a database user
##
# mysqlUser:
## Default: random 10 character string
# mysqlPassword:

## Allow unauthenticated access, uncomment to enable
##
# mysqlAllowEmptyPassword: true

## Create a database
##
# mysqlDatabase:

## Specify an imagePullPolicy (Required)
## It's recommended to change this to 'Always' if the image tag is 'latest'
## ref: http://kubernetes.io/docs/user-guide/images/#updating-images
##
imagePullPolicy: IfNotPresent

extraVolumes: |
  # - name: extras
  #   emptyDir: {}

extraVolumeMounts: |
  # - name: extras
  #   mountPath: /usr/share/extras
  #   readOnly: true

extraInitContainers: |
  # - name: do-something
  #   image: busybox
  #   command: ['do', 'something']

# Optionally specify an array of imagePullSecrets.
# Secrets must be manually created in the namespace.
# ref: https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod
# imagePullSecrets:
  # - name: myRegistryKeySecretName

## Node selector
## ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector
nodeSelector: {}

livenessProbe:
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 5
  successThreshold: 1
  failureThreshold: 3

readinessProbe:
  initialDelaySeconds: 5
  periodSeconds: 10
  timeoutSeconds: 1
  successThreshold: 1
  failureThreshold: 3

## Persist data to a persistent volume
persistence:
  enabled: true
  ## database data Persistent Volume Storage Class
  ## If defined, storageClassName: <storageClass>
  ## If set to "-", storageClassName: "", which disables dynamic provisioning
  ## If undefined (the default) or set to null, no storageClassName spec is
  ##   set, choosing the default provisioner.  (gp2 on AWS, standard on
  ##   GKE, AWS & OpenStack)
  ##
  # storageClass: "-"
  accessMode: ReadWriteOnce
  size: 8Gi
  annotations: {}

## Configure resource requests and limits
## ref: http://kubernetes.io/docs/user-guide/compute-resources/
##
resources:
  requests:
    memory: 256Mi
    cpu: 100m

# Custom mysql configuration files used to override default mysql settings
configurationFiles: {}
#  mysql.cnf: |-
#    [mysqld]
#    skip-name-resolve
#    ssl-ca=/ssl/ca.pem
#    ssl-cert=/ssl/server-cert.pem
#    ssl-key=/ssl/server-key.pem

# Custom mysql init SQL files used to initialize the database
initializationFiles: {}
#  first-db.sql: |-
#    CREATE DATABASE IF NOT EXISTS first DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
#  second-db.sql: |-
#    CREATE DATABASE IF NOT EXISTS second DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;

metrics:
  enabled: false
  image: prom/mysqld-exporter
  imageTag: v0.10.0
  imagePullPolicy: IfNotPresent
  resources: {}
  annotations: {}
    # prometheus.io/scrape: "true"
    # prometheus.io/port: "9104"
  livenessProbe:
    initialDelaySeconds: 15
    timeoutSeconds: 5
  readinessProbe:
    initialDelaySeconds: 5
    timeoutSeconds: 1

## Configure the service
## ref: http://kubernetes.io/docs/user-guide/services/
service:
  ## Specify a service type
  ## ref: https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services---service-types
  type: ClusterIP
  port: 3306
  # nodePort: 32000

ssl:
  enabled: false
  secret: mysql-ssl-certs
  certificates:
#  - name: mysql-ssl-certs
#    ca: |-
#      -----BEGIN CERTIFICATE-----
#      ...
#      -----END CERTIFICATE-----
#    cert: |-
#      -----BEGIN CERTIFICATE-----
#      ...
#      -----END CERTIFICATE-----
#    key: |-
#      -----BEGIN RSA PRIVATE KEY-----
#      ...
#      -----END RSA PRIVATE KEY-----

## Populates the 'TZ' system timezone environment variable
## ref: https://dev.mysql.com/doc/refman/5.7/en/time-zone-support.html
##
## Default: nil (mysql will use image's default timezone, normally UTC)
## Example: 'Australia/Sydney'
# timezone:

# To be added to the database server pod(s)
podAnnotations: {}
```

然后，我们可以直接在 `YAML` 格式的文件中来覆盖上面的任何配置，在安装的时候直接使用该配置文件即可：(`config.yaml`)

```
mysqlUser: NYjxiUser
mysqlDatabase: NYjxiDB
service:
  type: NodePort
```
我们这里通过 `config.yaml` 文件定义了 `mysqlUser` 和 `mysqlDatabase`，并且把 `service` 的类型更改为了 `NodePort`，然后现在我们来安装的时候直接指定该 `yaml` 文件：

```
l$ helm install -f config.yaml stable/mysql --name mydb
NAME:   mydb
LAST DEPLOYED: Thu Sep 27 06:11:02 2018
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/Service
NAME        TYPE      CLUSTER-IP     EXTERNAL-IP  PORT(S)         AGE
mydb-mysql  NodePort  10.254.69.235  <none>       3306:30364/TCP  2s

==> v1beta1/Deployment
NAME        DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE
mydb-mysql  1        1        1           0          2s

==> v1/Pod(related)
NAME                         READY  STATUS   RESTARTS  AGE
mydb-mysql-7ff7cc9459-4rxd6  0/1    Pending  0         2s

==> v1/Secret
NAME        TYPE    DATA  AGE
mydb-mysql  Opaque  2     2s

==> v1/ConfigMap
NAME             DATA  AGE
mydb-mysql-test  1     2s

==> v1/PersistentVolumeClaim
NAME        STATUS   VOLUME  CAPACITY  ACCESS MODES  STORAGECLASS  AGE
mydb-mysql  Pending  2s


NOTES:
MySQL can be accessed via port 3306 on the following DNS name from within your cluster:
mydb-mysql.default.svc.cluster.local
...
```

我们可以看到当前 `release` 的名字已经变成 `mydb` 了。然后可以查看下 `mydb` 关联的 `Service` 是否变成 `NodePort` 类型的了：

```
$ kubectl get svc
NAME                      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
kubernetes                ClusterIP   10.254.0.1      <none>        443/TCP          15d
mydb-mysql                NodePort    10.254.69.235   <none>        3306:30364/TCP   2m
queenly-angelfish-mysql   ClusterIP   10.254.193.49   <none>        3306/TCP         1h
```
看到服务 `mydb-mysql` 变成了 `NodePort` 类型的，二之前默认创建的 `queenly-angelfish-mysql` 是 `ClusterIP` 类型的，证明上面我们通过 `YAML` 文件来覆盖 `values` 是成功的。

接下来我们查看下 `Pod` 的状况：

```
$ kubectl get pods
NAME                                       READY     STATUS    RESTARTS   AGE
mydb-mysql-7ff7cc9459-4rxd6                0/1       Pending   0          4m
queenly-angelfish-mysql-76dfb56855-nczpx   0/1       Pending   0          1h
```

比较奇怪的是之前默认创建的和现在的 `mydb` 的 `release` 创建的 `Pod` 都是 `Pending` 状态，直接使用 `describe` 命令查看下：

```
$ kubectl describe pod mydb-mysql-7ff7cc9459-4rxd6
Name:           mydb-mysql-7ff7cc9459-4rxd6
Namespace:      default
Node:           <none>
Labels:         app=mydb-mysql
                pod-template-hash=3993775015
Annotations:    kubernetes.io/created-by={"kind":"SerializedReference","apiVersion":"v1","reference":{"kind":"ReplicaSet","namespace":"default","name":"mydb-mysql-7ff7cc9459","uid":"1bf387f0-c21c-11e8-9074-080027ee1d...
Status:         Pending
IP:
Created By:     ReplicaSet/mydb-mysql-7ff7cc9459
Controlled By:  ReplicaSet/mydb-mysql-7ff7cc9459
...
Events:
  Type     Reason            Age               From               Message
  ----     ------            ----              ----               -------
  Warning  FailedScheduling  1m (x26 over 7m)  default-scheduler  PersistentVolumeClaim is not bound: "mydb-mysql" (repeated 2 times)
```

我们可以发现两个 `Pod` 处于 `Pending` 状态的原因都是 `PVC` 没有被绑定上，所以这里我们可以通过 `storageclass` 或者手动创建一个合适的 `PV` 对象来解决这个问题。

另外为了说明 `helm` 更新的用法，我们这里来直接禁用掉数据持久化，可以在上面的`config.yaml` 文件中设置：

```
persistence:
  enabled: false
```

另外一种方法就是在安装过程中使用`--set`来覆盖对应的 `value` 值，比如禁用数据持久化，我们这里可以这样来覆盖：

```
$ helm install stable/mysql --set persistence.enabled=false --name mydb
```
## 升级

我们这里将数据持久化禁用掉来对上面的 mydb 进行升级：

```
$ cat config.yaml
mysqlUser: NYjxiUser
mysqlDatabase: NYjxiDB
service:
  type: NodePort
persistence:
  enabled: false

$ helm upgrade -f config.yaml mydb stable/mysql
Release "mydb" has been upgraded. Happy Helming!
LAST DEPLOYED: Thu Sep 27 06:23:16 2018
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/Secret
NAME        TYPE    DATA  AGE
mydb-mysql  Opaque  2     12m

==> v1/ConfigMap
NAME             DATA  AGE
mydb-mysql-test  1     12m

==> v1/Service
NAME        TYPE      CLUSTER-IP     EXTERNAL-IP  PORT(S)         AGE
mydb-mysql  NodePort  10.254.69.235  <none>       3306:30364/TCP  12m

==> v1beta1/Deployment
NAME        DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE
mydb-mysql  1        1        1           0          12m

==> v1/Pod(related)
NAME                        READY  STATUS   RESTARTS  AGE
mydb-mysql-96cf76947-22n77  0/1    Pending  0         1s
...
```

可以看到已经变成 `DEPLOYED` 状态了，现在我们再去看看 `Pod` 的状态呢：

```
$  kubectl get pods
NAME                                       READY     STATUS    RESTARTS   AGE
mydb-mysql-96cf76947-22n77                 1/1       Running   0          48s
queenly-angelfish-mysql-76dfb56855-nczpx   0/1       Pending   0          1h
```

我们看到 `mydb` 关联的 `Pod` 已经变成了 `runing` 的状态，已经不是 `Pending` 状态了，同样的，使用 `describe` 命令查看：

```
$ kubectl describe pod  mydb-mysql-96cf76947-22n77
Name:           mydb-mysql-96cf76947-22n77
Namespace:      default
Node:           192.168.1.138/192.168.1.138
Start Time:     Thu, 27 Sep 2018 06:23:17 +0000
...
Events:
  Type    Reason                 Age   From                    Message
  ----    ------                 ----  ----                    -------
  Normal  Scheduled              2m    default-scheduler       Successfully assigned mydb-mysql-96cf76947-22n77 to 192.168.1.138
  Normal  SuccessfulMountVolume  2m    kubelet, 192.168.1.138  MountVolume.SetUp succeeded for volume "data"
  Normal  SuccessfulMountVolume  2m    kubelet, 192.168.1.138  MountVolume.SetUp succeeded for volume "default-token-hgmcr"
  Normal  Pulling                2m    kubelet, 192.168.1.138  pulling image "busybox:1.25.0"
  Normal  Pulled                 2m    kubelet, 192.168.1.138  Successfully pulled image "busybox:1.25.0"
  Normal  Created                2m    kubelet, 192.168.1.138  Created container
  Normal  Started                2m    kubelet, 192.168.1.138  Started container
  Normal  Pulling                2m    kubelet, 192.168.1.138  pulling image "mysql:5.7.14"
  Normal  Pulled                 1m    kubelet, 192.168.1.138  Successfully pulled image "mysql:5.7.14"
  Normal  Created                1m    kubelet, 192.168.1.138  Created container
  Normal  Started                1m    kubelet, 192.168.1.138  Started container
```
我们可以看到现在没有任何关于 `PVC` 的错误信息了，这是因为我们刚刚更新的版本中就是禁用掉了的数据持久化的，证明 `helm upgrade` 和 `--values` 是生效了的。现在我们使用 `helm ls` 命令查看先当前的 `release`：

```
$ helm ls
NAME             	REVISION	UPDATED                 	STATUS  	CHART       	NAMESPACE
mydb             	2       	Thu Sep 27 06:23:16 2018	DEPLOYED	mysql-0.10.1	default
queenly-angelfish	1       	Thu Sep 27 05:01:54 2018	DEPLOYED	mysql-0.10.1	default
```


可以看到 `mydb` 这个 `release` 的`REVISION`已经变成`2`了，这是因为 `release` 的版本是递增的，每次安装、升级或者回滚，版本号都会加`1`，第一个版本号始终为1，同样我们可以使用 `helm history` 命令查看 `release` 的历史版本：

```
$ helm history mydb
REVISION	UPDATED                 	STATUS    	CHART       	DESCRIPTION
1       	Thu Sep 27 06:11:02 2018	SUPERSEDED	mysql-0.10.1	Install complete
2       	Thu Sep 27 06:23:16 2018	DEPLOYED  	mysql-0.10.1	Upgrade complete
```

当然如果我们要回滚到某一个版本的话，使用 `helm rollback` 命令即可，比如我们将 `mydb` 回滚到上一个版本

```
$ helm rollback mydb 1
```

## 删除

上节课我们就学习了要删除一个 `release` 直接使用 `helm delete` 命令就 OK：

```
$ helm delete queenly-angelfish
release "queenly-angelfish" deleted
```
这将从集群中删除该 `release`，但是这并不代表就完全删除了，我们还可以通过`--deleted`参数来显示被删除掉 `release`:

```
$ helm list --deleted
NAME             	REVISION	UPDATED                 	STATUS 	CHART           	NAMESPACE
lanky-lion       	1       	Wed Sep 26 09:30:34 2018	DELETED	hello-helm-0.1.0	default
queenly-angelfish	1       	Thu Sep 27 05:01:54 2018	DELETED	mysql-0.10.1    	default
```

```
$ helm list --all
NAME             	REVISION	UPDATED                 	STATUS  	CHART           	NAMESPACE
lanky-lion       	1       	Wed Sep 26 09:30:34 2018	DELETED 	hello-helm-0.1.0	default
mydb             	2       	Thu Sep 27 06:23:16 2018	DEPLOYED	mysql-0.10.1    	default
queenly-angelfish	1       	Thu Sep 27 05:01:54 2018	DELETED 	mysql-0.10.1    	default
```

`helm list --all`则会显示所有的 `release`，包括已经被删除的

由于 `Helm` 保留已删除 `release` 的记录，因此不能重新使用 `release` 名称。（如果确实 需要重新使用此 `release` 名称，则可以使用此 `–replace` 参数，但它只会重用现有 `release` 并替换其资源。）这点是不是和 `docker container` 的管理比较类似

请注意，因为 `release` 以这种方式保存，所以可以回滚已删除的资源并重新激活它。

如果要彻底删除 `release`，则需要加上`--purge`参数：

```
$ helm delete queenly-angelfish --purge
release "queenly-angelfish" deleted
```
