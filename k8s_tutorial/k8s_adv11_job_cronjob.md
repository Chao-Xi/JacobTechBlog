![Alt Image Text](images/adv/adv11_0.jpg "Body image")

# Job和CronJob 的使用方法

今天我们来给大家介绍另外一类资源对象：`Job`，

### 我们在日常的工作中经常都会遇到一些需要进行批量数据处理和分析的需求，当然也会有按时间来进行调度的工作，在我们的`Kubernetes`集群中为我们提供了`Job`和`CronJob`两种资源对象来应对我们的这种需求。

## Job

我们用`Job`这个资源对象来创建一个任务，我们定一个`Job`来执行一个倒计时的任务，定义`YAML`文件：

```
apiVersion: batch/v1
kind: Job
metadata:
  name: job-demo
spec:
  template:
    metadata:
      name: job-demo
    spec:
      restartPolicy: Never
      containers:
      - name: counter
        image: busybox
        command:
        - "bin/sh"
        - "-c"
        - "for i in 9 8 7 6 5 4 3 2 1; do echo $i; done"
```

### 注意`Job`的`RestartPolicy`仅支持`Never`和`OnFailure`两种，不支持`Always`，我们知道`Job`就相当于来执行一个批处理任务，执行完就结束了，如果支持`Always`的话是不是就陷入了死循环了？

然后来创建该`Job`，保存为`job-demo.yaml`：

```
$ kubectl create -f job-demo.yaml
job "job-demo" created
```

然后我们可以查看当前的`Job`资源对象：

```
$ kubectl get jobs
NAME       DESIRED   SUCCESSFUL   AGE
job-demo   1         1            23s
```

```
kubectl get jobs -o wide
NAME       DESIRED   SUCCESSFUL   AGE       CONTAINERS   IMAGES    SELECTOR
job-demo   1         1            20s       counter      busybox   controller-uid=cecde718-b7fb-11e8-9074-080027ee1df7
```

注意查看我们的`Pod`的状态，同样我们可以通过`kubectl logs`来查看当前任务的执行结果。

```
$ kubectl get pods -a
NAME                  READY     STATUS             RESTARTS   AGE
job-demo-6hk9t                  0/1       Completed   0          1m
```
```
$ kubectl logs job-demo-6hk9t
9
8
7
6
5
4
3
2
1
```

## CronJob

### `CronJob`其实就是在`Job`的基础上加上了时间调度，我们可以：在给定的时间点运行一个任务，也可以周期性地在给定时间点运行。这个实际上和我们`Linux`中的`crontab`就非常类似了。

一个CronJob对象其实就对应中crontab文件中的一行，它根据配置的时间格式周期性地运行一个Job，格式和crontab也是一样的。

`crontab`的格式如下：

```
分 时 日 月 星期 要运行的命令 第1列分钟0～59 第2列小时0～23） 第3列日1～31 第4列月1～12 第5列星期0～7（0和7
表示星期天） 第6列要运行的命令
```
```
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: cronjob-demo
spec:
  successfulJobsHistoryLimit: 10
  failedJobsHistoryLimit: 10
  schedule: "*/1 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          containers:
          - name: hello
            image: busybox
            args:
            - "bin/sh"
            - "-c"
            - "for i in 9 8 7 6 5 4 3 2 1; do echo $i; done"
```

* 我们这里的`Kind`是`CronJob`了，

* 要注意的是`.spec.schedule`字段是必须填写的，用来指定任务运行的周期，格式就和`crontab`一样，另外一个字段是`.spec.jobTemplate`, 用来指定需要运行的任务，格式当然和`Job`是一致的。
 
* 还有一些值得我们关注的字段`.spec.successfulJobsHistoryLimit`和.`spec.failedJobsHistoryLimit`，表示历史限制，是可选的字段。它们指定了可以保留多少完成和失败的`Job`，*_默认没有限制_*，所有成功和失败的Job都会被保留。

* 然而，当运行一个`Cron Job`时，`Job`可以很快就堆积很多，所以一般推荐设置这两个字段的值。如果设置限制的值为 0，那么相关类型的`Job`完成后将不会被保留。

接下来我们来创建这个`cronjob`

```
$ kubectl create -f cronjob-demo.yaml
cronjob "cronjob-demo" created
```

```
$ kubectl get jobs
NAME                      DESIRED   SUCCESSFUL   AGE
cronjob-demo-1536916500   1         1            2m
cronjob-demo-1536916560   1         1            1m
cronjob-demo-1536916620   1         0            12s

$ kubectl delete cronjob cronjob-demo
cronjob "cronjob-demo" deleted
```

当然，也可以用`kubectl run`来创建一个`CronJob`：

```
$ kubectl run hello --schedule="*/1 * * * *" --restart=OnFailure --image=busybox -- /bin/sh -c "date; echo Hello from the Kubernetes cluster"

cronjob "hello" created

$ kubectl get cronjob
NAME      SCHEDULE      SUSPEND   ACTIVE    LAST SCHEDULE   AGE
hello     */1 * * * *   False     0         <none>

$ kubectl get jobs
NAME               DESIRED   SUCCESSFUL   AGE
hello-1536916800   1         1            1m
hello-1536916860   1         0            1s

$ kubectl get pods -a
NAME                            READY     STATUS      RESTARTS   AGE
hello-1536916920-78cpw          0/1       Completed   0          2m
hello-1536916980-5458m          0/1       Completed   0          1m
hello-1536917040-tc4kw          0/1       Completed   0          53s

$ kubectl logs hello-1536916980-5458m
Fri Sep 14 09:23:17 UTC 2018
Hello from the Kubernetes cluster

$ kubectl delete cronjob hello
cronjob "hello" deleted
```

这将会终止正在创建的 `Job` 也会把当前 `Cron Job` 下面的` Job` 清空。然而，运行中的 `Job` 将不会被终止，不会删除 `Job` 或 它们的 `Pod`。

### 一旦 `Job` 被删除，由 `Job `创建的 `Pod` 也会被删除。

