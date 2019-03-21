# Adding EKS storage and networks

* Creating storage classes
* Storage persistent claims
* Clean up the storage
* Networking and EKS
* Load balancing and ingress

## 1.Creating storage classes

**By default EKS doesn't have any storage classes defined,** and we need to have a storage class model in order to be able to create persistent storage.

Luckily the 'plumbing' is already there, and we simply have to enable our storage class connection to the underlying EBS service.

**`gp-storage.yaml`**

```
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: gp2
  annotations:
    storageclass.kubernetes.io/is-default-class: 'true'. # set as default StorageClass
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
reclaimPolicy: Retain
mountOptions:
  - debug
```

**This creates a "standard" EBS based volume when a persistent volume request is created.  Size is determined by the persistent volume request.**

In addition, we have configured this resource as our default, so if an application asks for storage without defining a class, we'll get this class configured.

**Creating some `Fast (100iops/GB) SSD Storage` is also straightforward:**

**`fast-storage.yaml`**

```
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: fast-100
provisioner: kubernetes.io/aws-ebs
parameters:
  type: io1
  iopsPerGB: "100"
reclaimPolicy: Retain
mountOptions:
  - debug
```

```
$ kubectl apply -f gp-storage.yaml -f fast-storage.yaml
storageclass.storage.k8s.io/gp2 created
storageclass.storage.k8s.io/fast-100 created
```

```
$ kubectl get storageclass
NAME            PROVISIONER            AGE 
fast-100        kubernetesmio/aws-ebs  12s 
gp2 (default)   kubernetesmio/aws-ebs  12s 
```

## 2.Storage persistent claims

Once storage classes are defined, mapping uses the standard `Kubernetes` models, and as we defined "Retain" as the `reclaim policy`, 

**We have storage that maintains persistence even when we delete the `PersistentVolumeClaim` and the Pod that claimed the storage.**


Let's create a simple app that gets a `10G` volume and mounts it into the web directory:

**`hostname-volume.yaml`**

```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: hostname-volume
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: hostname-volume
        version: v1
    spec:
      volumes:
      - name: hostname-pvc
        persistentVolumeClaim:
          claimName: hostname-pvc
      containers:
      - image: rstarmer/hostname:v1
        imagePullPolicy: Always
        name: hostname
        volumeMounts:
          - mountPath: "/www"
            name: hostname-pvc
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: hostname-volume
  name: hostname-volume
spec:
  ports:
  - name: web
    port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: hostname-volume
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: hostname-pvc
spec:
  storageClassName: gp2
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

```
$ kubectl create -f hostname-volume.yaml
deployment.extensions/hostname—volume created 
service/hostname—volume created 
persistentvolumeclaim/hostname—pvc created 
```

We can see that there is now a PV that is created with a PVC that claims it, and if we check our pod, we can see that our www directory is empty (because it has a 1G volume mounted to it).

```
$ kubecti get pv 
NAME                                      CAPACITY   ACCESS MODES   RECLAIM POLICY  STATUS CLAIM                STORAGECLASS  REASON   AGE
pvc-5631eea5—c823-11e8—a59d-0269164cebd2  1Gi        RWO            Retain          Bound  default/hostname—pvc gp2                     5s   
```

```
$ kubectl get pvc -o wide
```

```
$ kubectl exec -it $(kubectl get pod -l app=hostname-volume -o jsonpath={.items..metadata.name}) -- df -h /www
Filesystem  Size Used Avail Used Mounted on 
/dev/xvdci   976M 2.6M 907M  1%   /www 
```

## 3.Clean up the storage

First remove the "stack" we created earlier:

```
$ kubectl delete -f hostname-volume.yaml
deployment.extensions "hostname—volume" deleted 
service "hostname—volume" deleted 
persistentvolumeclaim "hostname—pvc" deleted 
```
### Find and remove PVs

Then clean up the PV itself.  Note, you do _not_ want to do this if there are more than one PVs created, as this will grab _all_ of the volumes and delete them!

```
$ kubectl get pv
```
**or**

```
$ kubectl delete pv $(kubectl get pv -o jsonpath={.items..metadata.name})
persistentvolume "pvc-5631eea5—c823-11e8—a59d-0269164cebd2" deleted
```

## 4.Networking and EKS

Networking in EKS uses the **`VPC-CNI(Container Network Interface)`** project to use the AWS VPC network model to provide connectivity across the cluster.  

This is more efficient than having another layer of networking **(e.g. Flannel, Calico, Weave, etc.)** deployed as an overlay on top of the system, and maps perfectly into the VPC environment, using the **VPC network management** and **IPAM services** to support address management further improving the efficiency of the overall Kubernetes deployment.


We can see this in action by looking at the network information for any pod in the system:

```
$ kubectl run --image alpine alpine sleep 3600
deployment.app/alpine created
```

```
$ IPs=`kubectl get pod $(kubectl get pod -l run=alpine -o jsonpath={.items..metadata.name}) -o yaml | awk '/IP/ {print $2}'`
$ echo $IPs
192.168.237.184 192.168..216.173
```

```
for n in $IPs; do kubectl exec -it $(kubectl get pod -l run=alpine -o jsonpath={.items..metadata.name})  traceroute $n ; done
traceroute to 192.168.237.184 (192.168.237.184), 30 hops max, 46 byte packets 
1 ip-192-168-237-184.us—west-2.compute.internal (192.168.237.184) 0.005 ms 0.004 ms 0.002 ms 
traceroute to 192.168.216.173 (192.168.216.173), 30 hops max, 46 byte packets 
1 alpine-694f59c8cc—zhzcg (192.168.216.173) 0.004 ms 0.003 ms 0.002 ms 
```

## 5.Load balancing and ingress

We'll add the **Traefik load balancer** as an **ingress function**, and make use of the **EKS integration with Amazon ELB to enable external access**.

**As ingress can route based on DNS**, **we can also do a little DNS manipulation to get traffic routed to our resources**.

**https://github.com/containous/traefik**

1.Since we're using **1.10.0 Kubernetes** (or newer) we'll need to make sure we have a cluster role binding for the services to use:

**`kubectl apply -f https://raw.githubusercontent.com/containous/traefik/master/examples/k8s/traefik-rbac.yaml`**

```
kubectl apply -f traefik-rbac.yaml
clusterrole.rbac.authorization.k8s.io "traefik-ingress-controller" created
clusterrolebinding.rbac.authorization.k8s.io "traefik-ingress-controller" created
```

2.We'll leverage the deployment model for our ingress controller, as **we don't necessarily want to bind host address, and would rather have the ingress transit through the normal `kube-proxy` functions** (note that we're changing the default "NodePort" type to "LoadBalancer"):

```
kubectl apply -f <(curl -so - https://raw.githubusercontent.com/containous/traefik/master/examples/k8s/traefik-deployment.yaml | sed -e 's/NodePort/LoadBalancer/')
serviceaccount/traefik—ingress—controller created 
deployment.extensions/traefik—ingress—controller created 
service/traefik—ingress—service created 
```
Note that it assumes a hostname of **`traefik-ui.minikube`**, so we can confirm access as follows:

```
$ kubectl get svc —n kube—system
NAME                    TYPE         CLUSTER—IP      EXTERNAL-IP                                                           PORT(S)                       AGE 
kube—dns                ClusterIP    10.100.0.10    <none>                                                                 53/UDP,53/TCP                3h 
traefik—ingress—service LoadBalancer 10.100.218.195 ac22051dec82811e8b6210a38ble6cec-590972999.us—west-2.elbeamazonaws.com 80:30945/TCP,8080:32742/TCP  18s
```

3.Get the loadbalancer service address:

```
$ export INGRESS=`kubectl get svc -n kube-system traefik-ingress-service -o jsonpath={.status.loadBalancer.ingress[0].hostname}`
$ echo $INGRESS
ac22051dec82811e8b6210a38ble6cec-590972999.us—west-2.elbeamazonaws.com 80:30945/TCP,8080:32742/TCP
```
4.Capture the actual IP of one of the loadbalancers in the set:

```
$ export INGRESS_ADDR=`host $INGRESS | head -1 | cut -d' ' -f 4`
$ host INGRESS_ADDR
ac22051dec82811e8b6210a38ble6cec-590972999.us—west-2.elbeamazonaws.com has address 52.10.205.149
```

**`hostname-ingress.yaml`**

```
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: hostname-ingress
  namespace: default
spec:
  rules:
  - host: hostname-v1.local
    http:
      paths:
      - path: /
        backend:
          serviceName: hostname-v1
          servicePort: web
```

```
$ kubectl create -f hostname-ingress.yaml
ingress.extensions/hostname-ingress created
```

Verify that it's responding to web requests:

```
curl -sLo /dev/null -Hhost:hostname-v1.local http://${INGRESS_ADDR}/ -w "%{http_code}\n"
```

**Add an entry to the local `/etc/hosts` file to point to our resource:**

```
echo "$INGRESS_ADDR hostname-v1.local" | sudo tee -a /etc/hosts
52.10.205.149   hostname-v1.local
```

Now try pointing a web browser at that hostname:

```
$ curl http://hostname-v1.local 
<HTML> 
<HEAD> 
<TITLE>This page is on hostname v1-595b9884f7 w4n7w and is version v1</TITLE> 
</HEAD><BODY> 
<H1>THIS IS HOST hostname v1-595b9884f7—w4n7w</H1> 
<H2>And we're running version: v1</H2> 
</BODY>
</HTML> 
```