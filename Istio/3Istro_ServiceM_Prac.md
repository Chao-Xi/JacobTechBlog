# 3.Istio, Service Mesh 快速入门

本章将会用一个小例子来展示`Istio`在流童管理方面的能力，展示流程如下 

1. 使用一个现有的`Istio`部署文件的默认配置来完成`Istio`的安装； 
2. 使用`Deployment`将一个应用的两个版本作为测试服务部署到网格中； 
3. 将一个客户端服务部署到网格中进行测试； 
4. 为我们的目标服务编写策略文件，对目标服务的流量进行管理； 
5. 在测试服务中用不同的`HTTP`头调用目标服务，验证返回的内容是否符合我们在第3步中定义的流量管理策略。 


在`Istio`官网也提供`了Bookinfo`应用进行演示，然而这个应用本身就较为复杂很多结果验证都需要使用浏览器重复刷新来完成，因此本书对测试案例进行了重新设计。 

## 1.环境介绍 

本书仅围绕`Kubernetes`环境下的`Istio`安装和使用进行讲解，这里也仅给出对 Kubernetes环境的要求：

1. `Kubernetes1.9`或以上版本；
2. 具备管理权限的`kubectl`及其配置文件，能够操作测试集群； 
3. Kubernetes集群要有获取互联网镜像的能力 
4. 要支持`Istio`的自动注人功能，需要检查`Kubernetes API Server`的启动参数， 保证其中的`admission control`部分按顺序启用`MutatingAdmissionWebhhook` 和`ValidatingAdmission Webhook`


 
## 2.快速部署

* [https://github.com/istio/istio/releases](https://github.com/istio/istio/releases)
* 版本选择 **Istio 1.1.16**
* 安装包 `istio-1.1.16-mac.tar.gz`
* K8S环境 

```
NAME             STATUS   ROLES    AGE   VERSION
docker-desktop   Ready    master   32d   v1.14.6
```

### 安装`istioctl`

```
export PATH="$HOME/Istio/istio-1.1.16/bin:$PATH"
```

* 快速安装 (Quick Start Evaluation Install)

[https://istio.io/docs/setup/install/kubernetes/](https://istio.io/docs/setup/install/kubernetes/)

```
$ cd Istio/istio-1.1.16/install/kubernetes
$ ls -l
README.md				istio-citadel-plugin-certs.yaml		istio-demo.yaml
ansible					istio-citadel-standalone.yaml		mesh-expansion.yaml
global-default-sidecar-scope.yaml	istio-citadel-with-health-check.yaml	namespace.yaml
helm					istio-demo-auth.yaml
```

  
* Install CRD(`optional`)

```
$ for i in helm/istio-init/files/crd*yaml; do kubectl apply -f $i; done

customresourcedefinition.apiextensions.k8s.io/virtualservices.networking.istio.io created
customresourcedefinition.apiextensions.k8s.io/destinationrules.networking.istio.io created
customresourcedefinition.apiextensions.k8s.io/serviceentries.networking.istio.io crea
...
customresourcedefinition.apiextensions.k8s.io/orders.certmanager.k8s.io created
customresourcedefinition.apiextensions.k8s.io/challenges.certmanager.k8s.io created
```
  
  
* Install Istio-demo

```
kubectl apply -f istio-demo.yaml
secret/kiali created
configmap/istio-galley-configuration created
configmap/istio-grafana-custom-resources created
configmap/istio-grafana-configuration-dashboards-galley-dashboard created
configmap/istio-grafana-configuration-dashboards-istio-mesh-dashboard created
...
rule.config.istio.io/kubeattrgenrulerule created
rule.config.istio.io/tcpkubeattrgenrulerule created
kubernetes.config.istio.io/attributes created
destinationrule.networking.istio.io/istio-policy created
destinationrule.networking.istio.io/istio-telemetry created
```

不难看出， `Kubernetes`对象除了常一见的`Deployment`、 `Service`、 `Configmap`、 `ServiceAccount`等这里还创建了大量的`CRD`及各种`CRD`的下属资源。 

* Verifying the installation

```
$ kubectl get svc -n istio-system
NAME                     TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                                                                                                                                      AGE
grafana                  ClusterIP      10.97.103.25     <none>        3000/TCP                                                                                                                                     3m21s
istio-citadel            ClusterIP      10.100.168.139   <none>        8060/TCP,15014/TCP                                                                                                                           3m21s
istio-egressgateway      ClusterIP      10.106.95.123    <none>        80/TCP,443/TCP,15443/TCP                                                                                                                     3m22s
istio-galley             ClusterIP      10.108.209.18    <none>        443/TCP,15014/TCP,9901/TCP                                                                                                                   3m22s
istio-ingressgateway     LoadBalancer   10.107.84.164    localhost     15020:31984/TCP,80:31380/TCP,443:31390/TCP,31400:31400/TCP,15029:32733/TCP,15030:31365/TCP,15031:31173/TCP,15032:31320/TCP,15443:32343/TCP   3m21s
istio-pilot              ClusterIP      10.107.118.185   <none>        15010/TCP,15011/TCP,8080/TCP,15014/TCP                                                                                                       3m21s
istio-policy             ClusterIP      10.111.42.225    <none>        9091/TCP,15004/TCP,15014/TCP                                                                                                                 3m21s
istio-sidecar-injector   ClusterIP      10.107.211.88    <none>        443/TCP                                                                                                                                      3m21s
istio-telemetry          ClusterIP      10.98.81.13      <none>        9091/TCP,15004/TCP,15014/TCP,42422/TCP                                                                                                       3m21s
jaeger-agent             ClusterIP      None             <none>        5775/UDP,6831/UDP,6832/UDP                                                                                                                   3m20s
jaeger-collector         ClusterIP      10.103.140.100   <none>        14267/TCP,14268/TCP                                                                                                                          3m20s
jaeger-query             ClusterIP      10.107.110.32    <none>        16686/TCP                                                                                                                                    3m20s
kiali                    ClusterIP      10.100.10.115    <none>        20001/TCP                                                                                                                                    3m21s
prometheus               ClusterIP      10.108.193.251   <none>        9090/TCP                                                                                                                                     3m21s
tracing                  ClusterIP      10.102.103.34    <none>        80/TCP                                                                                                                                       3m20s
zipkin                   ClusterIP      10.111.148.171   <none>        9411/TCP                                                                                                                                     3m20s
```

运行如下命令，查看`istio-system`命名空间中的Pod启动状况，其中的`-w`参数 
用于持续查询`Pod`状态的变化： 


```
$ kubectl get pods  -n istio-sysem
tem  -w
NAME                                       READY   STATUS      RESTARTS   AGE
grafana-67c69bb567-sxtrt                   1/1     Running     0          93m
istio-citadel-5966cb6796-67zz5             1/1     Running     0          93m
istio-cleanup-secrets-1.1.16-7mrdr         0/1     Completed   0          93m
istio-egressgateway-65559f6769-5qzpq       1/1     Running     0          93m
istio-galley-84c585d695-52jvg              1/1     Running     0          93m
istio-grafana-post-install-1.1.16-wcpd9    0/1     Completed   0          93m
istio-ingressgateway-6499cc6d8b-qpj8d      1/1     Running     0          93m
istio-pilot-5546948cf8-6rf2p               2/2     Running     0          93m
istio-policy-68c98f8464-tvz8c              2/2     Running     7          93m
istio-security-post-install-1.1.16-f49mn   0/1     Completed   0          93m
istio-sidecar-injector-766758654c-8gpj4    1/1     Running     0          93m
istio-telemetry-579cfdb5b-h7l64            2/2     Running     7          93m
istio-tracing-5d8f57c8ff-j7xrn             1/1     Running     0          93m
kiali-d4d886dd7-whm5w                      1/1     Running     0          93m
prometheus-d8d46c5b5-tjhbb                 1/1     Running     0          93m
```

## 3.部署两个版本的服务

一个简单的Python脚本作为服务端。 这段脚本是一个Flask应用， 提供连个URL路径， 一个是`/env`用于获取容器中的环境变量， 例如 `http://flaskapp/env/version`; 另外一个是`/fetch`用于获取参数url中指定的网址内容， 例如`http://flaskapp/fetch?url=https://weibo.com`

```
#!/usr/bin/env python3 
from flask import Flask, request 
import os 
import url lib.request 

app=Flask(__name__) 

@app.route('/env/<env>')
def showenv(env): 
	return os.environ.get(env)
	
	 
@app.route（'/fetch'） 
def fetch_env():
	url=request.args.get('url','')
	with urllib.request.urlopen(url) as reponse:
		return reponse.read 


if __name__ ==  "__main__": 
app.run(host="0,0,0,0", port=80, debug=True)
```

我们为这个`App`创建两个`Deployment`，将其分别命名为 `flaskapp-v1`和`flaskapp-v2`; 同时创建一个`Service`，将其命名为`flask app`，将下面的内容保存为`flaskapp.istio.yaml`: 

```
apiVersion: v1 
kind: Service 
metadata: 
  name: flaskapp 
  labels: 
    app: flaskapp 
spec: 
  selector: 
    app: flaskapp 
  ports: 
    - name: http 
      port: 80 
---
apiVersion: extensions/v1beta1
kind: Deployment 
metadata: 
  name: flaskapp-v1 
spec: 
  replicas: 1
  template: 
    metadata: 
      labels: 
        app: flaskapp 
        version: v1 
      spec: 
        containers: 
        - name: flaskapp 
          image: dustise/flaskapp
          imagePullPolicy: IfNotPresent 
          env:
          - name: version
            value: v1
---
apiVersion: extensions/v1beta1
kind: Deployment 
metadata: 
  name: flaskapp-v2
spec: 
  replicas: 1
  template: 
    metadata: 
      labels: 
        app: flaskapp 
        version: v1 
      spec: 
        containers: 
        - name: flaskapp 
          image: dustise/flaskapp
          imagePullPolicy: IfNotPresent 
          env:
          - name: version
            value: v2
```

在上面的YAML源码中有以下需要注意的地方。 

* 两个版本的`Deployment`的镜像是一致的，但使用了不同的`version`标签进行区分，分别是`v1`和`v2`
* 在两个版本的`Deployment`容器中都注册了一个被命名为`version`的环境变量取值分别为`v1`和`v2` 
* 两个`Deployment`都使用了`app`和`version`标签, 在`Istio`网格应用中通常会使用这两个标签作为应用和版本的标识
* `Service`中的`Selector`仅使用了一个`app`标签 `Deployment`都是有效的。 

接下来使用`istioctl`进行注入。之后会一直用到`istioctl`命令，它的基本作用就起修改`Kubernetes Deployment`，在Pod中注入在前面提到的`Sidecar`容器，通常为了方便，我们会使用一个管道命令，在将`YAML`文们 通过`istioctl`处理之后，通过命令行管道输出给`kubectl`，最终提交到`Kubernetes`集群。 命令如下： 

```
$ cd ~/Devops_sap/Istio/flaskapp
```

```
$ istioctl kube-inject -f flask.istio.yaml | kubectl apply -f -
service/flaskapp unchanged
deployment.extensions/flaskapp-v1 created
deployment.extensions/flaskapp-v2 created
```

```
$ kubectl get pods
NAME                          READY   STATUS    RESTARTS   AGE
flaskapp-v1-bc4679d-cd54v     2/2     Running   0          50s
flaskapp-v2-89866b97c-4zsqf   2/2     Running   0          50s
```

可以看到，每个Pod都变成了两个容器， 也就是是`Istio`注入`Sidecar`的结果， 可以使用`kubectl describe pod`命令查看`Pod`的容器

```
$ kubectl describe pod flaskapp-v1-74cbbdbdf6-8wxvn

...
Init Containers:
  istio-init:              
    Container ID:
...
  istio-proxy:
    Container ID:
...
```

**不难发现，在这个`Pod`中多了一个容器，名称为`istio-proxy`，这就是注人的结果**。另外，前面还有一个名称为`istio-init`的初始化容器(job)，这个容器是用于初始化劫持的。

```
kubectl get pods -o=jsonpath='{range .items[*]}{"\n"}{.metadata.name}{":\t"}{range .spec.containers[*]}{.image}{", "}{end}{end}' |\sort
```

```
$ kubectl get pods -o custom-columns='NAME:metadata.name,ImageName:spec.containers[*].image'
NAME                          ImageName
flaskapp-v1-bc4679d-cd54v     dustise/flaskapp,docker.io/istio/proxyv2:1.1.16
flaskapp-v2-89866b97c-4zsqf   dustise/flaskapp,docker.io/istio/proxyv2:1.1.16
sleep-6c9b45d956-5hjl6        dustise/sleep,docker.io/istio/proxyv2:1.1.16
```

### `istioctl kube-inject -h`

```
kube-inject manually injects the Envoy sidecar into Kubernetes workloads.

Usage:
  istioctl kube-inject [flags]
  
Examples:

# Update resources on the fly before applying.
kubectl apply -f <(istioctl kube-inject -f <resource.yaml>)

# Create a persistent version of the deployment with Envoy sidecar injected.
istioctl kube-inject -f deployment.yaml -o deployment-injected.yaml

# Update an existing deployment.
kubectl get deployment -o yaml | istioctl kube-inject -f - | kubectl apply -f -

# Create a persistent version of the deployment with Envoy sidecar
# injected configuration from Kubernetes configmap 'istio-inject'
istioctl kube-inject -f deployment.yaml -o deployment-injected.yaml --injectConfigMapName istio-inject
```

## 4.部署客户端服务

客户端服务很简单只是使用了一个已安装好各种测试工具的镜像，具体的测试可以在其内部的`Shell`中完成。同样，编写一个、`YAML`文件将其命名为`sleep.yaml`

```
apiVersion: v1
kind: Service 
metadata: 
  name: sleep 
  labels: 
    app: sleep 
    version: v1 
spec: 
  selector: 
    app: sleep 
    version: v1 
  ports: 
    - name: ssh 
      port: 80 
--- 
apiVersion: extensions/v1beta1 
kind: Deployment 
metadata:
  name: sleep 
spec: 
  replicas: 1 
  template: 
    metadata: 
      labels: 
        app: sleep 
        version: v1 
    spec: 
      containers: 
      - name: sleep 
        image: dustise/sleep 
        imagePullPolicy: IfNotPresent
``` 

这个应用并没有提供对外服务的能力, 我们给它创建了一个`Service`。时象这同样是Istio的注人要求：

### 没有`Service`的`Deployment`是无法被`Istio`发现井进行操作的 

同样对该文件进行注人并提交到`Kubernetes`运行 

```
$ istioctl kube-inject -f sleep.yaml | kubectl apply -f -
service/sleep created
deployment.extensions/sleep created
```


```
$ kubectl get pod
NAME                           READY   STATUS    RESTARTS   AGE
flaskapp-v1-74cbbdbdf6-4mbb8   1/1     Running   0          12s
flaskapp-v2-74cbbdbdf6-zp79g   1/1     Running   0          12s
sleep-6c9b45d956-5hjl6         2/2     Running   0          4m31s
```

可以看到， `sleep` 应用的`Pod`已经开始了


## 5.验证服务

接下来，我们可以通过`kubectl exec -it` 服务的具体表现。 命令进人客户端`Pod`，来测试`flaskapp` 

使用一个简单的`for`循环，重复获取`http://flaskapp/env/version`的内容，也就是调用`flaskapp`服务，查看其返回结果： 

```
kubectl exec -it sleep-6c9b45d956-5hjl6 -c sleep bash

# -c, --container='': Container name. If omitted, the first container in the pod will be chosen


bash-4.4# for i in `seq 10`;do http --body http://flaskapp/env/version;done
v2

v1

v2

v1

v2

v1

v1

v2

v1

v2
```

从上面的运行结果中可以看到 这很容易理解，`v2`和`v1`这两种结果随机出现，大约各占一半。

**因为我们的`flaskapp`服务的选择器被定义为只根据`App`标签进行选择，两个版本的服务`Pod`数量相同，因此会出现轮流输出的效果。** 

## 6.创建目标规则和默认路由

接下来使用`Istio`来管理这两个服务的流量

首先创建 flaskapp 应用的目标规则，输入一下内容并将其保存为 `flask-detinationrule.yaml`

```
apiVersion: networking.istio.io/v1alpha3 
kind: DestinationRule 
metadata: 
	name: flaskapp 
spec: 
	host: flaskapp 
	subsets: 
	- name: v1 
	  labels: 
	    version: v1 
	- name: v2 
	  labels: 
	  	 version: v2 
```

可以看到该文件还是常见的`YAML`格式,实际上也可以使用`kubectl`命令进行操作 

**这里定义了一个名称为`flaskapp`的`DestinationRule`,它利用`Pod`标签把服务分成两个`subset` , 将写分别命名为	`v1`和`v2`** 

下面将`flask-detinationrule.yaml`提交到集群

```
$ççc
destinationrule.networking.istio.io/flaskapp created
```

```
$ kubectl get destinationrule
NAME       HOST       AGE
flaskapp   flaskapp   4m52s
```


接下来就需要为`flaskapp`服务创建默认的路由规则了,

**不论是否进行进一步的流量控制, 都建议为网格中的服务创建默认的路由规则， 以防发生意料之外的访问结果** 

便用下面的内容创建文本文件`flask-default-vs-v2.yaml`

```
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata: 
  name: flaskapp-default-v2 
spec: 
  hosts:
  - flaskapp 
  http: 
  - route: 
    - destination: 
        host: flaskapp 
        subset: v2
```


在该文本文件中我们定义了一个`VirtualService`对象, 将其命名为`flaskapp-default-v2`, 它负责接管`flaskapp`这一主机名的访问,会将所有流量都转发到`DestinationRule`定义的`v2 subset`上 
 
再次执行`kubectl`将`VirtualService`提交到集群 

```
kubectl apply -f flask-default-vs-v2.yaml
virtualservice.networking.istio.io/flaskapp-default-v2 created

$ kubectl get vs
NAME                  GATEWAYS   HOSTS        AGE
flaskapp-default-v2              [flaskapp]   48s
```

在创建成功后，可以再次进入客户端的Pod, 看看新定义的流量规则是否生效

```
$ kubectl exec -it sleep-85cfc95c7-tvlxq -c sleep bash
bash-4.4# for i in `seq 10`;do http --body http://flaskapp/env/version;done
v2

v2

v2

v2

v2

v2

v2

v2

v2

v2
```

可以看到, 默认的路由己经生, 现在复多次访问， 返回的内容来自环境变量`version`被设置为`v2`的版本. 

