# Install prometheus-operator with Helm in Ubertest Cluster

### Step one: Create one `management` node as monitoring node from Converged Cloud in `management` nodepools

```
$ kubectl get nodes
NAME                             STATUS   ROLES    AGE    VERSION
ubertest-management-n9wws        Ready    <none>   1d     v1.10.7
```

### Step two: label all node with `kubernetes.io/os=linux`


The **prometheus-operator** resource will be installed on the nodes with label `kubernetes.io/os=linux` in default, which Converged Cloud doesn't have.

```
kubectl label nodes --all kubernetes.io/os=linux
```

### Step three: label newly added management node with `jam/ubertest=monitoring` label

```
kubectl label node ubertest-management-<node> jam/ubertest=monitoring
```

```
kubectl label node ubertest-management-n9wws jam/ubertest=monitoring
```

**Check the node labels**

```
$  kubectl get nodes ubertest-management-n9wws -o yaml
...
labels:
    beta.kubernetes.io/arch: amd64
    beta.kubernetes.io/instance-type: "60"
    beta.kubernetes.io/os: linux
    ccloud.sap.com/nodepool: management
    failure-domain.beta.kubernetes.io/region: na-ca-1
    failure-domain.beta.kubernetes.io/zone: na-ca-1a
    jam/ubertest: monitoring
    kubernetes.io/hostname: ubertest-management-n9wws.novalocal
    kubernetes.io/os: linux
...
```

### Step four: Add `monitoring` taint to the node

```
kubectl taint nodes ubertest-management-<node> ismonitoring=1:NoSchedule
kubectl taint nodes ubertest-management-<node> ismonitoring=1:NoExecute
```

```
kubectl taint nodes ubertest-management-n9wws ismonitoring=1:NoSchedule
node/ubertest-management-n9wws tainted
kubectl taint nodes ubertest-management-n9wws ismonitoring=1:NoExecute
node/ubertest-management-n9wws tainted
```


**Check the node taints**

```
$ kubectl get node ubertest-management-n9wws -o json | jq ".spec.taints"
[
  {
    "effect": "NoExecute",
    "key": "ismonitoring",
    "value": "1"
  },
  {
    "effect": "NoSchedule",
    "key": "ismonitoring",
    "value": "1"
  }
]
```


### Step five: install prometheus-operator crd in the ubertest cluster

```
$ bash create_prometheus-operator_crd.sh
```

**`create_prometheus-operator_crd.sh`**

```
#!/bin/bash
set -e 

if [ -z "$(kubectl config current-context)" ]
then
   echo "The cluster current-context is empty, please make sure you are operate in correct cluster"   
else
  current_context=$(kubectl config current-context)
  echo "Create alertmanager crd in the Cluster: $current_context"
  kubectl apply -f https://raw.githubusercontent.com/coreos/prometheus-operator/master/example/prometheus-operator-crd/alertmanager.crd.yaml

  for i in {5..1};do echo -n "." && sleep 1; done && printf "\nCreate prometheus crd in the Cluster: $current_context\n"
  kubectl apply -f https://raw.githubusercontent.com/coreos/prometheus-operator/master/example/prometheus-operator-crd/prometheus.crd.yaml
  
  for i in {5..1};do echo -n "." && sleep 1; done && printf "\nCreate prometheusrule crd in the Cluster: $current_context\n"
  kubectl apply -f https://raw.githubusercontent.com/coreos/prometheus-operator/master/example/prometheus-operator-crd/prometheusrule.crd.yaml

  for i in {5..1};do echo -n "." && sleep 1; done && printf "\nCreate servicemonitor crd in the Cluster: $current_context\n"
  kubectl apply -f https://raw.githubusercontent.com/coreos/prometheus-operator/master/example/prometheus-operator-crd/servicemonitor.crd.yaml
  
  for i in {5..1};do echo -n "." && sleep 1; done && printf "\nCreate podmonitor crd in the Cluster: $current_context\n"
  kubectl apply -f https://raw.githubusercontent.com/coreos/prometheus-operator/master/example/prometheus-operator-crd/podmonitor.crd.yaml
  
fi
```

### Step five: install prometheus-operator in the ubertest cluster with helm and launch config file

```
helm install --name monitoring --namespace monitoring -f launch-config.yaml stable/prometheus-operator
```

**`launch-config.yaml`**

```
prometheusOperator:
  createCustomResource: false
  nodeSelector:
    jam/ubertest: monitoring
  tolerations:
    - operator: Exists
    
prometheus:
  prometheusSpec:
    nodeSelector: 
      jam/ubertest: monitoring
    tolerations:
    - operator: Exists

alertmanager:
  alertmanagerSpec:
    nodeSelector:
      jam/ubertest: monitoring
    tolerations:
    - operator: Exists

grafana:
  nodeSelector: 
    jam/ubertest: monitoring
  tolerations:
    - operator: Exists
  service:
    type: NodePort
  
prometheus-node-exporter:
  tolerations:
    - operator: Exists

kube-state-metrics:
  nodeSelector:
      jam/ubertest: monitoring
  tolerations:
    - operator: Exists

```

#### Attention:

<mark>**This installation would fetch offical chart from goole storage, so may need open VPN in China to carry on this process**</mark>

* **release-name** : **monitoring**
* **namespace**:  **monitoring**


### Step six: `Port-forwad` for `prometheus-oper-alertmanager` and `prometheus-oper-prometheus`  

```
$ kubectl get svc -n monitoring
NAME                                      TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
monitoring-prometheus-oper-prometheus     ClusterIP   198.18.216.15    <none>        9090/TCP            2h
monitoring-prometheus-oper-alertmanager   ClusterIP   198.18.230.236   <none>        9093/TCP            2h
```

```
$ bash port_forward.sh
```

**`port_forward.sh`**

```
#!/bin/bash
set -e

echo "Cleaning up orphaned port-forwards"
pgrep -lf "kubectl port-forward" | awk '{ print $1 }' | xargs kill -9

# Prometheus
echo "Prometheus http://localhost:9090" &
kubectl port-forward -n monitoring service/monitoring-prometheus-oper-prometheus 9090 &

echo "Alertmanager http://localhost:9093" &
kubectl port-forward -n monitoring service/monitoring-prometheus-oper-alertmanager 9093
```

* Prometheus `http://localhost:9090`
* Alertmanager `http://localhost:9093`



### Step seven: Map DNS and loadbalancer for Grafana Service

**Since I changed monitoring-grafana service from default ClusterIP to NodePort, so I decide map DNS and loadbalancer to the service**

(This step is optional, you can delete `type: NodePort` from `launch_config.yaml`, then `helm upgrade --namespace monitoring -f launch-config.yaml stable/prometheus-operator` the chart to create CluterIP and use `kubectl port-forward` to your local machine)

```
$ kubectl get svc -n monitoring
NAME                TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
monitoring-grafana  NodePort    198.18.131.182   <none>        80:30184/TCP        2h
```

* **Outgoing port**: `30184`, this port will randomly generate

```
kubectl get node <node-name> -o custom-columns='Node_IP:status.addresses[*].address'
```
```
$ kubectl get node ubertest-management-n9wws -o custom-columns='Node_IP:status.addresses[*].address'

$ kubectl get node ubertest-management-n9wws -o custom-columns='Node_IP:status.addresses[*].address'
Node_IP
10.180.0.24,ubertest-management-n9wws.novalocal
```


####  Create Load Balancer for `monitoring-grafana` in NA-CA-1

1.The **Load Balancer Pools** setting

```
https://dashboard.na-ca-1.cloud.sap/monsoon3/jam/loadbalancing/loadbalancers/93e3565b-7415-4ac8-bf74-ab38724e89f0/pools
```

2.The **Load Balancer Pools members** setting for `kubertest-grafana`

```
https://dashboard.na-ca-1.cloud.sap/monsoon3/jam/loadbalancing/loadbalancers/93e3565b-7415-4ac8-bf74-ab38724e89f0/pools/fd18f712-d54b-4653-a483-4e439d4a15be/show_details
```

3.The **Load Balancer Listeners Policy** setting

```
https://dashboard.na-ca-1.cloud.sap/monsoon3/jam/loadbalancing/loadbalancers/93e3565b-7415-4ac8-bf74-ab38724e89f0/listeners/bd615b32-322a-429d-979a-d297d3b24ea6/l7policies
```

4.The **Load Balancer Listeners Policy L7 rule** setting

```
https://dashboard.na-ca-1.cloud.sap/monsoon3/jam/loadbalancing/loadbalancers/93e3565b-7415-4ac8-bf74-ab38724e89f0/listeners/bd615b32-322a-429d-979a-d297d3b24ea6/l7policies/f511c2d1-fbfe-4390-aba8-9f67412ba69a/l7rules
```

#### Create DNS for `monitoring-grafana` in EU-DE-1

```
https://dashboard.eu-de-1.cloud.sap/monsoon3/jam/dns-service/zones/c06478d3-e714-454e-971d-aef09954516f
```

#### After DNS created, You can access the `monitoring-grafana`

```
https://kubertest-grafana.jam.only.sap
```

* **username**: <mark>**admin**</mark>
* **password**：<mark>**prom-operator**</mark>


<mark>Because the bad internet traffic from Converged Cloud NA-CA-1, the login page will load in serveral minutes :(</mark>

#### (optional for above)Get the default admin `username` and `password` of `monitoring-grafana`

```
$ kubectl get secret --namespace monitoring monitoring-grafana -o custom-columns="admin-user:data.admin-user, admin-password:data.admin-password"
admin-user    admin-password
YWRtaW4=     cHJvbS1vcGVyYXRvcg==


$ echo YWRtaW4= | base64 --decode
admin

$ echo cHJvbS1vcGVyYXRvcg== | base64 --decode
prom-operator
```

### Step eight: Tips for using grafana dashboards

You may have trouble to match node IP (instance) and node name in `Kubernetes/Nodes` Dashboard, try to run following commmand to get corresponding information

```
$ kubectl get node -o custom-columns='Node_IP:status.addresses[*].address'
Node_IP
10.180.1.148,ubertest-management-bmxwx.novalocal
...
10.180.1.175,ubertest-worker-4xlarge-p9m46.novalocal
```

## Some useful Command

#### 1. Label all nodes

**Add label to node**

```
$ kubectl label pods my-pod new-label=awesome            # Add a Label
```

**Label all nodes**

```
$ kubectl label nodes --all kubernetes.io/os=linux
```

**Show labels**

```
$ kubectl get nodes --show-labels
```

```
$ for item in $( kubectl get node --output=name); do printf "Labels for %s\n" "$item" | grep --color -E '[^/]+$' && kubectl get "$item" --output=json | jq -r -S '.metadata.labels | to_entries | .[] | " \(.key)=\(.value)"' 2>/dev/null; printf "\n"; done
```

**Delete labels**

```
$ kubectl label node jam-m2xlarge-sxrj8 jam/ubertest-
$ kubectl label node <node-name> <label-key>-
```

```
$ kubectl label nodes --all <label-key>-
```

#### 2. Taint node

```
$ kubectl taint nodes ubertest-monitoring-<node> ismonitoring=1:NoSchedule
$ kubectl taint nodes ubertest-monitoring-<node> ismonitoring=1:NoExecute
```

**Get all node taints**

```
$ kubectl get nodes -o json | jq ".items[]|{name:.metadata.name, taints:.spec.taints}"
```

**Get node taint**

```
$ kubectl get node <node-name> -o custom-columns=Taints:.spec.taints
```

**Untaint node**

```
$ kubectl taint nodes jam-m2xlarge-fphgs ismanagement-
node/jam-m2xlarge-fphgs untainted
```

#### 3. Get pods and nodes

```
$ kubectl get pods -o custom-columns=POD:metadata.name,NODE:spec.nodeName --sort-by spec.nodeName -n monitoring
```

#### 4. Get nodes and IP address

```
kubectl get node node-name -o custom-columns='Node_IP:status.addresses[*].address'
```