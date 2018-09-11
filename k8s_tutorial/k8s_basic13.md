# Kubernetes对象详解 

## Deployment

### `Deployment`为`Pod`和`ReplicaSet`提供了一个声明式定义(`declarative`)方法，用来替代以前的 `ReplicationController`来方便的管理应用。

* `Kubernetesv1.7`及以前`API`版本使用`extensions/v1beta1`
* `Kubernetesv1.8`的`API`版本升级到`apps/v1beta2`

## 示例

```
apiVersion: extensions/v1beta1
kind: Deployment
  metadata
    name: nginx-deployment
spec:
  replicas: 3
  template:
    metadata:
      labels:
        app: nginx
      spec:
        containers:
        - name: nginx
          image: nginx:1.7.9
          ports:
          - containerPort: 80
```

## 使用

### 扩容

```
kubectl scale deployment nginx-deployment --replicas 10
```

### 如果集群支持 `horizontal pod autoscaling` 的话，还可以为`Deployment`设置自动扩展

```
kubectl autoscale deployment nginx-deployment --min=10 --max=15 --cpu-percent=80
```

### 更新镜像也比较简单:

```
kubectl set image deployment/nginx-deployment nginx=nginx:1.9.1
```
### 回滚:

```
kubectl rollout undo deployment/nginx-deployment
```

## Deployment的典型应用场景

* 定义`Deployment`来创建`Pod`和`ReplicaSet`
* 滚动升级和回滚应用
* 扩容和缩容
* 暂停和继续`Deployment`

## Deployment是什么?

* `Deployment`为`Pod`和`Replica Set`(下一代`Replication Controller`)提供声明式更新。
* 你只需要在`Deployment`中描述你想要的目标状态是什么，`Deployment controller`就会帮你将 `Pod`和`Replica Set`的实际状态改变到你的目标状态。你可以定义一个全新的`Deployment`，也可以创建一个新的替换旧的Deployment。


## 典型用例

* 使用`Deployment`来创建`ReplicaSet`。`ReplicaSet`在后台创建`pod`。检查启动状态，看它是成功还是失败。
* 然后，通过更新`Deployment`的`PodTemplateSpec`字段来声明`Pod`的新状态。这会创建一个新的`ReplicaSet`，`Deployment`会按照控制的速率将`pod`从旧的`ReplicaSet`移动到新的`ReplicaSet`中 。
* 如果当前状态不稳定，回滚到之前的`Deployment revision`。每次回滚都会更新`Deployment`的`revision`。
* 扩容`Deployment`以满足更高的负载。
* 暂停`Deployment`来应用`PodTemplateSpec`的多个修复，然后恢复上线。
* 根据`Deployment`的状态判断上线是否hang住了。
* 清除旧的不必要的`ReplicaSet`。


## Deployment Spec

* Pod Template
* Replicas
* Selector
* .spec.strategy
   * `.spec.strategy.type==Recreate`
     在创建出新的Pod之前会先杀掉所有已存在的Pod。
   * `.spec.strategy.type==RollingUpdate`
   
   ```
   1.可以指定maxUnavailable 和 maxSurge 来控制 rolling update 进程。
   2.Max Unavailable
   .spec.strategy.rollingUpdate.maxUnavailable 是可选配置项，用来指定在升级过程中不可用Pod的最大 数量。该值可以是一个绝对值(例如5)，也可以是期望Pod数量的百分比(例如10%)。
   3.Max Surge
   .spec.strategy.rollingUpdate.maxSurge 是可选配置项，用来指定可以超过期望的Pod数量的最大个数。
该值可以是一个绝对值(例如5)或者是期望的Pod数量的百分比(例如10%)。
   ```

* Progress Deadline Seconds
* Min Ready Seconds
* Rollback To
* Revision
* Revision History Limit 

## 创建Deployment

下面是一个`Deployment`示例，它创建了一个`ReplicaSet`来启动`3`个`nginx pod`。

下载示例文件并执行命令:

```
$ kubectl create -f docs/user-guide/nginx-deployment.yaml --record

deployment "nginx-deployment" created
```
kubectl的 `--record` 的`flag`设置为 true可以在`annotation`中记录当前命令创建或者升级了该资源。这在未来会很有用，例如，查看在每个`Deployment revision`中执行了哪些命令。

然后立即执行get将获得如下结果

```
$kubectl get deployments

NAME             DESIRED CURRENT UP-TO-DATE AVAILABLE AGE 
nginx-deployment 3       0       0
```

## 输出

* 输出结果表明我们希望的`repalica`数是`3`(根据`deployment`中的`.spec.replicas`配置)当前`replica`数( `.status.replicas`)是`0`, 最新的`replica`数(`.status.updatedReplicas`)是`0`，可用的`replica`数 (`.status.availableReplicas`)是`0`。

* 过几秒后再执行get命令，将获得如下输出

```
$ kubectl get deployments 

NAME DESIRED CURRENT UP-TO-DATE AVAILABLE AGE
nginx-deployment 3 3 3 3 18s
```

们可以看到Deployment已经创建了3个replica，所有的`replica`都已经是最新的了(包含最新的`pod template`)，可用的(根据`Deployment`中的`.spec.minReadySeconds`声明，处于已就绪状态的pod的最少个数)。执行`kubectl get r`s和`kubectl get pods`会显示`Replica Set(RS)`和 `Pod`已创建。

```
$ kubectl get rs -n=kube-ops
NAME                    DESIRED   CURRENT   READY     AGE
prometheus-56f964cc74   1         1         1         3h
```

## 更新Deployment

* 注意: `Deployment`的`rollout`当且仅当`Deployment`的`pod template`(例如`.spec.template`)中的
`label`更新或者镜像更改时被触发。其他更新，例如扩容`Deployment`不会触发`rollout`。

* 假如我们现在想要让`nginx pod`使用`nginx:1.9.1`的镜像来代替原来的`nginx:1.7.9`的镜像。

```
$ kubectl set image deployment/nginx-deployment nginx=nginx:1.9.1
deployment "nginx-deployment" image updated
```

* 我们可以使用`edi`t命令来编辑`Deployment`，修改 `.spec.template.spec.containers[0].image `，将 `nginx:1.7.9` 改写成 `nginx:1.9.1`。

```
$ kubectl edit deployment/nginx-deployment 

deployment "nginx-deployment" edited
```

## 查看rollout的状态

```
$ kubectl rollout status deployment/nginx-deployment

Waiting for rollout to finish: 2 out of 3 new replicas have been updated...
deployment "nginx-deployment" successfully rolled out
```

## Rollout规则

* `Deployment`可以保证在升级时只有一定数量的`Pod`是`down`的。默认的，它会确保至少有比期望的`Pod`数量少一个的`Pod`是`up`状态(最多一个不可用)。
* `Deployment`同时也可以确保只创建出超过期望数量的一定数量的`Pod`。默认的，它会确保最多比期望的`Pod`数量多一个的`Pod`是`up`的(最多1个surge)。
* 在未来的`Kuberentes`版本中，将从`1-1`变成`25%-25%`。


## Rollover(多个rollout并行)

* 每当Deployment controller观测到有新的deployment被创建时，如果没有已存在的Replica Set 来创建期望个数的Pod的话，就会创建出一个新的Replica Set来做这件事。已存在的Replica Set控制label匹配.spec.selector但是template跟.spec.template不匹配的Pod缩容。最终，新的 Replica Set将会扩容出.spec.replicas指定数目的Pod，旧的Replica Set会缩容到0

*  如果你更新了一个的已存在并正在进行中的Deployment，每次更新Deployment都会创建一 个新的Replica Set并扩容它，同时回滚之前扩容的Replica Set——将它添加到旧的Replica Set 列表，开始缩容。

*  例如，假如你创建了一个有5个niginx:1.7.9 replica的Deployment，但是当还只有3个 nginx:1.7.9的replica创建出来的时候你就开始更新含有5个nginx:1.9.1 replica的Deployment。 在这种情况下，Deployment会立即杀掉已创建的3个nginx:1.7.9的Pod，并开始创建nginx:1.9.1 的Pod。它不会等到所有的5个nginx:1.7.9的Pod都创建完成后才开始执行滚动更新。

## 回滚Deployment

* 有时候你可能想回退一个`Deployment`，例如，当`Deployment`不稳定时，比如一直`crash looping`。

* 默认情况下，`kubernetes`会在系统中保存前两次的`Deployment`的`rollout`历史记录，以便你可以随时回退(你可以修改`revision history limit`来更改保存的`revision`数)。

* 注意: 只要`Deployment`的`rollout`被触发就会创建一个`revision`。也就是说当且仅当 `Deployment`的`Pod` `template`(如`.spec.template`)被更改，例如更新`template`中的`label`和容器镜像时，就会创建出一个新的`revision`。

* 其他的更新，比如扩容`Deployment`不会创建`revision`——因此我们可以很方便的手动或者自动扩容。这意味着当你回退到历史`revision`是，只有`Deployment`中的`Pod template`部分才会回退。

## 检查Deployment升级的历史记录

首先，检查下`Deployment`的`revision`:

```
$ kubectl rollout history deployment/nginx-deployment
  deployments "nginx-deployment":
  REVISION CHANGE-CAUSE
  1        kubectl create -f docs/user-guide/nginx-deployment.yaml --record
  2        kubectl set image deployment/nginx-deployment nginx=nginx:1.9.1
  3.       kubectl set image deployment/nginx-deployment nginx=nginx:1.91
```

 因为我们创建`Deployment`的时候使用了`--recored`参数可以记录命令，我们可以很方便的查看每次`revison`的变化。

## 查看revision

因为我们创建Deployment的时候使 用了--recored参数可以记录命令， 我们可以很方便的查看每次revison 的变化。

可以通过设置 `.spec.revisonHistoryLimit`项来指定 `deployment`最多保留多少`revison`历史记录。默认的会保留所有的 `revision`;如果将该项设置为`0`， `Deployment`就不允许回退了。

```
$ kubectl rollout history deployment/nginx-deployment --revision=2

deployments "nginx-deployment" revision 2
Labels: app=nginx pod-template-hash=1159050644
Annotations: kubernetes.io/change-cause=kubectl set image deployment/nginx-deployment nginx=nginx:1.9.1
Containers: nginx:
Image: Port:
nginx:1.9.1 80/TCP
QoS Tier:
cpu: BestEffort memory: BestEffort
Environment Variables: No volumes.
<none>
```
## 回退到历史版本

我们可以决定回退当前的rollout到之前的版本:

```
$ kubectl rollout undo deployment/nginx-deployments

deployment "nginx-deployment" rolledback
```

也可以使用 `--to-revision`参数指定某个历史版本:

```
$ kubectl rollout undo deployment/nginx-deployment --to-revision=2
 
deployment "nginx-deployment" rolledback
```

## Deployment扩容

可以使用以下命令扩容Deployment:

```
$ kubectl scale deployment nginx-deployment --replicas 10d eployment "nginx-deployment" scaled
```

假设你的集群中启用了**horizontal pod autoscaling**，你可以给`Deployment`设置一个`autoscaler` ，基于当前`Pod`的`CPU`利用率选择最少和最多的Pod数。

```
$ kubectl autoscale deployment nginx-deployment --min=10 --max=15 --cpu-percent=80 deployment "nginx-deployment" autoscaled
```

## 暂停和恢复Deployment

可以在触发一次或多次更新前暂停一个Deployment，然后再恢复它。这样你就能多次暂停和恢复Deployment，在此期间进行一些修复工作，而不会触发不必要的`rollout`。

使用以下命令暂停Deployment:

```
$ kubectl rollout pause deployment/nginx-deployment 
  deployment "nginx-deployment" paused
```

然后更新Deplyment中的镜像:

```
$ kubectl set image deploy/nginx nginx=nginx:1.9.1 
  deployment "nginx-deployment" image updated
```

恢复这个Deployment

```
$ kubectl rollout resume deploy nginx
  deployment "nginx" resumed
```



