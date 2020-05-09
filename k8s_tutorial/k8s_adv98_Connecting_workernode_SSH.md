# Connecting to a worker node using SSH

## Introduce

If you need to ssh to our JAM K8S cluster nodes which are in the private subnet of AWS or other cloud providers. You may want to creat a jumphost and then ssh to the nodes through jumphost.  
But there is security group on the nodes which will prohibit this kind of access and the security group is controlled by gardener terraform so we can't change it.   
The recommended way to connect to a JAM K8S cluster node is creating a privileged pod in the cluster and then ssh to node through the pod.

## SSH to an unspecified node

### 1. Create a new file `privileged-pod.yaml` with the content

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: privileged-pod
  namespace: default
spec:
  containers:
  - name: busybox
    image: busybox
    resources:
      limits:
        cpu: 200m
        memory: 100Mi
      requests:
        cpu: 100m
        memory: 50Mi
    stdin: true
    securityContext:
      privileged: true
    volumeMounts:
    - name: host-root-volume
      mountPath: /host
      readOnly: true
  volumes:
  - name: host-root-volume
    hostPath:
      path: /
  hostNetwork: true
  hostPID: true
  restartPolicy: Never
```

### 2. Create pod using above yaml file

```bash
kubectl create -f privileged-pod.yaml
```

### 3. Now you can look around in the pod

```bash
kubectl exec -ti privileged-pod sh
ps aux
ip a
ls -la /host
```

### 4. Run as root using the node’s filesystem instead of the filesystem in the container running on the node:

```bash
chroot /host/
```
Then you can run commands such as `docker ps`.

`chroot`命令用来在指定的根目录下运行指令。`chroot`，即 `change root directory` （更改 root 目录）。在 `linux` 系统中，系统默认的目录结构都是以`/`，即是以根 (`root`) 开始的。而在使用 `chroot` 之后，系统的目录结构将以指定的位置作为`/`位置。

```
ip-10-250-0-57 / # docker images
REPOSITORY                                                                    TAG                          IMAGE ID            CREATED             SIZE
eu.gcr.io/sap-se-gcr-k8s-public/modified3/quay_io/calico/node                 v3.13.1                      05d3ee3f3159        7 weeks ago         255MB
eu.gcr.io/sap-se-gcr-k8s-public/quay_io/calico/node                           v3.13.1-mod1                 05d3ee3f3159        7 weeks ago         255MB
eu.gcr.io/sap-se-gcr-k8s-public/modified3/quay_io/calico/pod2daemon-flexvol   v3.13.1                      5039c83179df        7 weeks ago         109MB
eu.gcr.io/sap-se-gcr-k8s-public/quay_io/calico/pod2daemon-flexvol             v3.13.1-mod1                 5039c83179df        7 weeks ago         109MB
...
```

### 5. Don’t forget to delete your pod afterwards:

```bash
kubectl delete pod privileged-pod
```

## SSH to a specified node

### 1. Get the node name which you want to connect

```bash
# kubectl get nodes -o wide
NAME                                            STATUS   ROLES    AGE    VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                                        KERNEL-VERSION   CONTAINER-RUNTIME
ip-10-250-0-189.eu-central-1.compute.internal   Ready    <none>   144m   v1.16.9   10.250.0.189   <none>        Container Linux by CoreOS 2303.3.0 (Rhyolite)   4.19.86-coreos   docker://18.6.3
ip-10-250-0-58.eu-central-1.compute.internal    Ready    <none>   144m   v1.16.9   10.250.0.58    <none>        Container Linux by CoreOS 2303.3.0 (Rhyolite)   4.19.86-coreos   docker://18.6.3
ip-10-250-0-88.eu-central-1.compute.internal    Ready    <none>   144m   v1.16.9   10.250.0.88    <none>        Container Linux by CoreOS 2303.3.0 (Rhyolite)   4.19.86-coreos   docker://18.6.3
```

### 2. Create a new file `privileged-pod-1.yaml` with the content

Note the `spec.nodeName` parameter, use the `Name` of which node you want to connect in the output above.
Also when you need to create multiple pods, you should change the `metadata.name` parameter, each pod should have different name. 

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: privileged-pod-1
  namespace: default
spec:
  containers:
  - name: busybox
    image: busybox
    resources:
      limits:
        cpu: 200m
        memory: 100Mi
      requests:
        cpu: 100m
        memory: 50Mi
    stdin: true
    securityContext:
      privileged: true
    volumeMounts:
    - name: host-root-volume
      mountPath: /host
      readOnly: true
  nodeName: ip-10-250-0-88.eu-central-1.compute.internal
  volumes:
  - name: host-root-volume
    hostPath:
      path: /
  hostNetwork: true
  hostPID: true
  restartPolicy: Never
```

### 3. Follow the remaining steps 2~5 in `SSH to an unspecified node`