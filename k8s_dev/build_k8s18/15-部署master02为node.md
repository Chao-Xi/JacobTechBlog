# Bring Master02 as Node too

I need Mater 02 as a new node for following Jenkins CI/CD practice, so I need bring this master02 as my new K8S node


### 1. Check kubelet `token.csv` exist or not 

Be beware that, this token will be generated in the step of `kube-apiserver ` start

[Reference](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_dev/build_k8s18/06-%E9%83%A8%E7%BD%B2master%E8%8A%82%E7%82%B9.md#61-%E9%85%8D%E7%BD%AE%E5%92%8C%E5%90%AF%E5%8A%A8kube-apiserver)


**So, I need check this token exist in `/etc/kubernetes/` or not**  [This step is absolutely necessary]


### 2. intsall kubectl on this machine

[Reference](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_dev/build_k8s18/04-%E9%85%8D%E7%BD%AEkubectl%E5%91%BD%E4%BB%A4%E8%A1%8C%E5%B7%A5%E5%85%B7.md)



### 3. Setup node on this machine

[Reference](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_dev/build_k8s18/08-%E9%83%A8%E7%BD%B2Node%E8%8A%82%E7%82%B9.md)


### 4. Setup Kubedns plugin on node (not necessary if already done)

[Reference](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_dev/build_k8s18/09-%E9%83%A8%E7%BD%B2kubedns%E6%8F%92%E4%BB%B6.md)

```
$ mkdir dns && cd dns

$ kubectl create -f .
Error from server (AlreadyExists): error when creating "kubedns-cm.yaml": configmaps "kube-dns" already exists
Error from server (AlreadyExists): error when creating "kubedns-controller.yaml": deployments.extensions "kube-dns" already exists
Error from server (AlreadyExists): error when creating "kubedns-sa.yaml": serviceaccounts "kube-dns" already exists
Error from server (Invalid): error when creating "kubedns-svc.yaml": Service "kube-dns" is invalid: spec.clusterIP: Invalid value: "10.254.0.2": provided IP is already allocated
```

### 5. bring the new node online

```
$ kubectl get csr
NAME                                                   AGE       REQUESTOR           CONDITION
node-csr-I1MkoxU3wE-0IFXrk5iIaVE3I0sVWZVCkpXNfl8oyV8   20s       kubelet-bootstrap   Pending
node-csr-vPloMmUo_4_Vu4PBBqtezlc2q5mC8yMGuNsI5Bi0jHw   2d        kubelet-bootstrap   Approved,Issued
```

```
$ kubectl certificate approve node-csr-I1MkoxU3wE-0IFXrk5iIaVE3I0sVWZVCkpXNfl8oyV8
certificatesigningrequest "node-csr-I1MkoxU3wE-0IFXrk5iIaVE3I0sVWZVCkpXNfl8oyV8" approved
```
```
$ kubectl get csr
NAME                                                   AGE       REQUESTOR           CONDITION
node-csr-I1MkoxU3wE-0IFXrk5iIaVE3I0sVWZVCkpXNfl8oyV8   45s       kubelet-bootstrap   Approved,Issued
node-csr-vPloMmUo_4_Vu4PBBqtezlc2q5mC8yMGuNsI5Bi0jHw   2d        kubelet-bootstrap   Approved,Issued
```

```
$ kubectl get nodes
NAME            STATUS    ROLES     AGE       VERSION
192.168.1.138   Ready     <none>    17s       v1.8.2
192.168.1.170   Ready     <none>    2d        v1.8.2
```

### 6. check the pods running on the special node

```
kubectl get pods -o wide --all-namespaces | grep <YOUR-NODE>
```

```
$ kubectl get pods -o wide --all-namespaces | grep 192.168.1.138
default       nginx-ds-mk9kl             1/1       Running   0          9m        172.17.0.2    192.168.1.138
default       nginx-ingress-j5x8n        1/1       Running   0          9m        172.17.0.3    192.168.1.138
kube-ops      node-exporter-f55gf        1/1       Running   0          9m        172.17.0.4    192.168.1.138
```

