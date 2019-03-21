# Network policy with Calico

In order to enable policy, a CNI network needs to be in place, and by default the VPC based networking in EKS is already configured appropriately.  

**Policy however is not part of the VPC networking provided by Amazon, and instead, an integration with the `Calico policy manager` has been integrated with the VPC CNI service.**


[What is Network policy?](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_cloudnative/5K8S_Network_Model.md#network-policy-1)

```
kubectl apply -f https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/release-1.1/config/v1.1/calico.yaml 
# kubectl apply -f https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/release-1.1/config/v1.1/calico.yaml --validate=false
daemonset.extensions/calico-node configured
customresourcedefinition.apiextensions.k8s.io/felixconfigurations.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/bgpconfigurations.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/ippools.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/hostendpoints.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/clusterinformations.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/globalnetworkpolicies.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/globalnetworksets.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/networkpolicies.crd.projectcalico.org created
serviceaccount/calico-node created
clusterrole.rbac.authorization.k8s.io/calico-node created
clusterrolebinding.rbac.authorization.k8s.io/calico-node created
deployment.extensions/calico-typha created
clusterrolebinding.rbac.authorization.k8s.io/typha-cpha created
clusterrole.rbac.authorization.k8s.io/typha-cpha created
configmap/calico-typha-horizontal-autoscaler created
deployment.extensions/calico-typha-horizontal-autoscaler created
role.rbac.authorization.k8s.io/typha-cpha created
serviceaccount/typha-cpha created
rolebinding.rbac.authorization.k8s.io/typha-cpha created
service/calico-typha created
```


This will create a daemonset running the calico policy engine on each configured node.


Let's run a container with `curl` enabled to test our target system (`hostname-v1` from the initial install):

```
kubectl run --image rstarmer/curl:v1 curl
kubectl run --generator=deployment/apps.v1beta1 is DEPRECATED and will be removed in a future version. Use kubectl create instead. 
deployment.apps/curl created 
```

And let's verify that we can communicate to the `http://hostname-v1` service endpoint:

```
$ kubectl get pods
Name                           READY  STATUS   RESTARTS AGE
curl-c5d4d7cff-496r7           1/1    Running  0        45s 
hostname—v1-595b9884f7-qxts2   1/1    Running  0        1h 
hostname—v2-6bfdf4c55f—vkvls   1/1    Running  0        1h 
```

```
$ kubectl exec -it $(kubectl get pod -l run=curl -o jsonpath={.items..metadata.name})  -- curl --connect-timeout 5 http://hostname-v1

<HTML> 
<HEAD> 
<TITLE>This page is on hostname v1-595b9884f7 w4n7w and is version v1</TITLE> 
</HEAD><BODY> 
<H1>THIS IS HOST hostname v1-595b9884f7—w4n7w</H1> 
<H2>And we're running version: v1</H2> 
</BODY>
</HTML> 
```


Now, we can first disable network access by installing the baseline "Default Deny" policy, which will break our application access:

**`default-deny.yaml`**

[What is NetworkPolicy Deny?](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_cloudnative/5K8S_Network_Model.md#%E6%8B%92%E7%BB%9D%E6%89%80%E6%9C%89%E6%B5%81%E9%87%8F%E8%BF%9B%E5%85%A5)

```
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: default-deny
  namespace: default
spec:
  podSelector:
    matchLabels: {}
```

```
$ kubectl apply -f default-deny.yaml
networkpolicy.networking.k8s.io/default—deny created 
```

```
$ kubectl exec -it $(kubectl get pod -l run=curl -o jsonpath={.items..metadata.name})  -- curl --connect-timeout 5 http://hostname-v1

curl: (28) Connection timed out after 5001 milliseconds 
command terminated with exit code 28 
```
**`allow-hostname.yaml`**

```
kind: NetworkPolicy
apiVersion: extensions/v1beta1
metadata:
  namespace: default
  name: allow-hostname
spec:
  podSelector:
    matchLabels:
      app: hostname-v1
  ingress:
    - from:
        - namespaceSelector:
            matchLabels: {}
```
```
$ kubectl apply -f allow-hostname.yaml
networkpolicy.networking.k8s.io/allow-hostname created 
```
```
$ kubectl exec -it $(kubectl get pod -l run=curl -o jsonpath={.items..metadata.name})  -- curl --connect-timeout 5 http://hostname-v1

<HTML> 
<HEAD> 
<TITLE>This page is on hostname v1-595b9884f7 w4n7w and is version v1</TITLE> 
</HEAD><BODY> 
<H1>THIS IS HOST hostname v1-595b9884f7—w4n7w</H1> 
<H2>And we're running version: v1</H2> 
</BODY>
</HTML> 
```