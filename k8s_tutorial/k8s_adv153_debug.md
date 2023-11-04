# 掌握 Kubernetes 故障排除：有效维护集群的最佳实践和工具

Kubernetes 是一款管理容器化应用程序的强大工具。然而，与任何复杂的系统一样，使用它时也可能出错。当问题出现时，掌握有效的故障排除技术和工具非常重要。

* 检索最新事件
* 使用 Pod 模拟问题
* 在位于 PV 的 Pod 中存储事件

## 检索最新事件

对 Kubernetes 集群进行故障诊断的第一步是检索最新的事件。**Kubernetes 中的事件由集群中的各种组件和对象（如 Pod、节点和服务）生成**。它们可提供有关集群状态和可能发生的任何问题的信息

要检索最新事件，可以使用 Kubectl get events 命令。这将显示集群中所有事件的列表。

```
kubectl get events

LAST SEEN   TYPE      REASON                    OBJECT                                 MESSAGE
78s         Warning   BackOff                   pod/bbb                                Back-off restarting failed container
72s         Warning   BackOff                   pod/bbb2                               Back-off restarting failed container
12m         Normal    Pulling                   pod/bbb3                               Pulling image "busybox"
12m         Normal    Created                   pod/bbb3                               Created container bbb3
46m         Normal    Started                   pod/bbb3                               Started container bbb3
```

如上所示，它按时间排序显示了集群中所有通信口的列表。您还可以添加 `-w` 标记，以观察新事件发生的变化。


这将显示集群中发生事件的实时状态。通过观察事件，**您可以快速识别可能发生的任何问题**。

虽然 kubectl get events 命令有助于检索事件，但如果事件按时间顺序显示，则很难识别问题。

为了更容易识别问题，您可以按照 `metadata.creationTimestamp` 对事件进行排序。

```
kubectl get events --sort-by=.metadata.creationTimestamp

LAST SEEN   TYPE      REASON                    OBJECT                                 MESSAGE
104s        Normal    Pulling                   pod/busybox13                          Pulling image "busybox"
88s         Warning   FailedScheduling          pod/mysqldeployment-6f8b755598-phgzr   0/2 nodes are available: 2 Insufficient cpu. preemption: 0/2 nodes are available: 2 No preemption victims found for incoming pod.
104s        Warning   BackOff                   pod/busybox6                           Back-off restarting failed container
82s         Warning   ProvisioningFailed        persistentvolumeclaim/pv-volume        storageclass.storage.k8s.io "csi-hostpath-sc" not found
82s         Warning   ProvisioningFailed        persistentvolumeclaim/pv-volume-2      storageclass.storage.k8s.io "csi-hostpath-sc" not found
```

如上所示，按 `metada.creationTimestamp` 排序显示集群中所有事件的列表。通过这种方式对通信口进行排序，您可以快速识别最近的事件和可能出现的任何问题

## 使用 Pod 模拟问题

对 Kubernetes 集群进行故障诊断的第一步是检索最新的事件。**Kubernetes 中的事件由集群中的各种组件和对象（如 Pod、节点和服务）生成**。它们可提供有关集群状态和可能发生的任何问题的信息

如果您发现存在**与联网或服务发现相关的问题，终止 kube-proxy pod 可能会有帮助**。kube-proxy pod 负责集群中的联网和服务发现，因此终止它有助于识别与这些功能相关的任何问题。

要终止 `kube-proxy pod`，可以使用 `kubectl delete pod` 命令。如果您需要指定 `kube-proxy pod` 的名称，可以使用 `kubectl get pods` 命令找到它。

```
kubectl get pods -n kube-system
NAME                              READY   STATUS    RESTARTS      AGE
coredns-57575c5f89-66z2h          1/1     Running   1 (45h ago)   36d
coredns-57575c5f89-bcjdn          1/1     Running   1 (45h ago)   36d
etcd-k81                          1/1     Running   1 (45h ago)   36d
fluentd-elasticsearch-5fdvc       1/1     Running   2 (45h ago)   60d
fluentd-elasticsearch-wx6x9       1/1     Running   1 (45h ago)   60d
kube-apiserver-k81                1/1     Running   1 (45h ago)   36d
kube-controller-manager-k81       1/1     Running   2 (45h ago)   36d
kube-proxy-bqpb5                  1/1     Running   1 (45h ago)   36d
kube-proxy-q94sk                  1/1     Running   1 (45h ago)   36d
kube-scheduler-k81                1/1     Running   2 (45h ago)   36d
metrics-server-5c59ff65b6-s4kms   1/1     Running   2 (45h ago)   58d
weave-net-56pl2                   2/2     Running   3 (45h ago)   61d
weave-net-rml96                   2/2     Running   5 (45h ago)   62d
```

如上，将显示 Kube 系统命名空间中所有 pod 的列表，其中包括 kube-proxy pod。

获得 kube-proxy pod 的名称后，就可以使用 `kubectl delete pod` 命令将其删除。

```
kubectl delete pod -n kube-system kube-proxy-q94sk
```

这将删除 kube-system 命名空间中的 kube-proxy pod。**Kubernetes 会自动创建一个新的 kube-proxy pod 来替代它**。

您可以使用以下命令检查事件：

```
kubectl get events -n=kube-system --sort-by=.metadata.creationTimestamp

LAST SEEN   TYPE     REASON             OBJECT                 MESSAGE
4m59s       Normal   Killing            pod/kube-proxy-bqpb5   Stopping container kube-proxy
4m58s       Normal   Scheduled          pod/kube-proxy-cbkx6   Successfully assigned kube-system/kube-proxy-cbkx6 to k82
4m58s       Normal   SuccessfulCreate   daemonset/kube-proxy   Created pod: kube-proxy-cbkx6
4m57s       Normal   Pulled             pod/kube-proxy-cbkx6   Container image "registry.k8s.io/kube-proxy:v1.24.11" already present on machine
```

## 在位于 PV 的 Pod 中存储事件


**将事件存储在位于 PV 中的 Pod，是跟踪 Kubernetes 集群中所发生事件的有效方法**。下面是关于如何操作的分步讲解：

**为 Pod 添加权限**

要在 pod 中连接 Kubernetes API，您需要赋予它适当的权限。下面是一个将权限绑定到 pod 的 YAML 文件示例。

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: event-logger
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: default
  namespace: default
```

**创建持久加密卷 (PV) 和持久加密卷声明 (PVC)**

现在我们已经设置好 ClusterRoleBind，可以创建一个持久卷来存储我们的事件。下面是一个使用 hostPath 创建 PC 的 YAML 文件示例：

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: event-logger
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: default
  namespace: default
```

创建持久加密卷 (PV) 和持久加密卷声明 (PVC)

现在我们已经设置好 `ClusterRoleBind`，可以创建一个持久卷来存储我们的事件。下面是一个使用 hostPath 创建 PC 的 YAML 文件示例：

```
# pv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /mnt/data

---

# pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  volumeName: my-pv
```

创建 Pod 以收集事件

现在，我们已经设置好 PV 和 PVC，可以创建 Pod 来收集事件了。下面是一个 YAML 文件示例，用于创建一个 Pod，在 Pod 中连接到 Kubernetes API，并将所有事件存储到文件 `events.log` 中。

```
apiVersion: v1
kind: Pod
metadata:
  name: event-logger
spec:
  containers:
  - name: event-logger
    image: alpine
    command: ["/bin/sh", "-c"]
    args:
    - |
      apk add --no-cache curl jq && while true; do
        EVENTS=$(curl -s -k -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" https://${KUBERNETES_SERVICE_HOST}/api/v1/events | jq -r '.items[]')
        if [ -n "$EVENTS" ]; then
          echo "$EVENTS" >> /pv/events.log
        fi
        sleep 10
      done
    volumeMounts:
    - name: event-log
      mountPath: /pv
    - name: sa-token
      mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      readOnly: true
  volumes:
  - name: event-log
    persistentVolumeClaim:
      claimName: my-pvc
  - name: sa-token
    projected:
      sources:
      - serviceAccountToken:
          path: token
          expirationSeconds: 7200
      - configMap:
          name: kube-root-ca.crt
```

该 Pod 将运行一个安装了curl 和 jq的简单 shell 脚本，使用 `event-logger ClusterRoleBinding` 连接到 Kubernetes API，并将所有事件存储在 `/pv/events.log` 中。

可以运行以下命令检查事件：

```
kubectl exec event-logger -- cat /pv/events.log
```

通过使用这些故障排除技术和工具，您可以保持 Kubernetes 集群的健康和平稳运行。检索最新事件、模拟问题并将事件存储在位于 PV 中的 pod 中，是有效维护集群的基本步骤。

随着您对 Kubernetes 的使用经验越来越丰富，您可以探索更高级的工具，如用于分析事件的 Kibana、Prometheus 或 Grafana，以及集中式日志记录解决方案，如 Elasticsearch 或 Fluentd。