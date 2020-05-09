# JAM Service Mesh with Istio

##  Deploying service mesh(istio)

Verify that you can locally craft the istio, and access to kiali locally. Notes that we are not deploying istio via ArgoCD because ArgoCD has some issues with rendering sub charts.

```
# add istio repo to helm
helm repo add istio https://storage.googleapis.com/istio-release/releases/1.4.6/charts
# create namespace for istio
kubectl create namespace istio-system
# install CRD
helm install istio-init istio/istio-init --namespace istio-system
# install istio
helm install --dependency-update jam-istio helm/jam-istio -f instances/$JAM_INSTANCE-k8s.yaml -f instances/$JAM_INSTANCE-config.yaml --namespace istio-system
```

* `--dependency-update`: run helm dependency update before installing the chart

## `jam-istio`

```
$ tree jam-istio/
jam-istio/
├── Chart.lock
├── Chart.yaml
├── templates
│   ├── kiali-secret.yaml
│   ├── mysql-service-entry.yaml
│   ├── s3-bucket-service-entry.yaml
│   └── smtp-service-entry.yaml
└── values.yaml

1 directory, 7 files
``` 

**values.yaml**

```
jam:
  namespace: local700
  mysql:
    external: true
    externalHostName: dev701-db.cxqgj1lee4x0.eu-central-1.rds.amazonaws.com

istio:
  kiali:
    enabled: true
  gateways:
    enabled: false
```

**Chart.yaml**

```
apiVersion: v1
appVersion: "1.0"
description: A Helm chart for istio
name: jam-istio
version: 0.1.0
dependencies:
  - name: istio
    version: 1.4.6
    repository: https://storage.googleapis.com/istio-release/releases/1.4.6/charts
```

**Chart.lock**

The Chart dependency management system moved from **`requirements.yaml` and `requirements.lock` to `Chart.yaml` and `Chart.lock`**

```
dependencies:
- name: istio
  repository: https://storage.googleapis.com/istio-release/releases/1.4.6/charts
  version: 1.4.6
digest: sha256:4377b2bb6c83d43ea05ce1240417c85778eff86b82665b41ec0c6408de756321
generated: "2020-03-16T16:03:34.166755+08:00"
```

### Templates

**kiali-secret.yaml**

[使用Kiali](https://github.com/Chao-Xi/JacobTechBlog/blob/master/Istio/8Istio_func4_Kiali.md)

```
apiVersion: v1
kind: Secret
metadata:
  name: kiali
  namespace: {{ .Release.Namespace }}
  labels:
    app: kiali
type: Opaque
data:
  username: 
  passphrase: 
```

**`mysql-service-entry.yaml`**

[设置`ServiceEntry`](https://github.com/Chao-Xi/JacobTechBlog/blob/master/Istio/11Istio_http3.md#1142-%E8%AE%BE%E7%BD%AEserviceentry)

```
{{- if .Values.jam.mysql.external}}
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  labels:
    app: mysql
  name: mysql
  namespace: {{ .Values.jam.namespace }}
spec:
  hosts:
  - {{ .Values.jam.mysql.externalHostName }}
  ports:
  - number: 3306
    name: tcp
    protocol: TCP
  resolution: DNS
  location: MESH_EXTERNAL
{{- end}}
```

**`s3-bucket-service-entry.yaml`**

```
{{- if eq .Values.jam.dataStorage.mode "aws"}}
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  labels:
    app: bucket
  name: bucket
  namespace: {{ .Values.jam.namespace }}
spec:
  hosts:
  - s3.{{ .Values.jam.dataStorage.region }}.amazonaws.com
  ports:
  - number: 80
    name: http
    protocol: TCP
  - number: 443
    name: https
    protocol: TCP
  resolution: NONE
  location: MESH_EXTERNAL
{{- end}}
```


**smtp-service-entry.yaml**

```
{{- if .Values.jam.mail.external}}
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  labels:
    app: smtp
  name: smtp
  namespace: {{ .Values.jam.namespace }}
spec:
  hosts:
  - {{ .Values.jam.mail.externalHostName }}
  ports:
  - number: {{ .Values.jam.mail.externalHostPort | default 587 }}
    name: tcp
    protocol: TCP
  resolution: DNS
  location: MESH_EXTERNAL
{{- end}}
```

## How to upgrade istio for jam

refer: https://istio.io/docs/setup/upgrade/cni-helm-upgrade/

**It's a zero-downtime process as long as deployments/sts have replicas greater than 1**

Assume that we are going to upgrade istio to version `x.y.z`

### 1. Upgrade CRD

```
helm repo add istio https://storage.googleapis.com/istio-release/releases/x.y.z/charts

helm upgrade istio-init istio/istio-init --namespace istio-system
```

Wait for all Istio CRDs to be created:

```
kubectl -n istio-system wait --for=condition=complete job --all
```

### 2. Upgrade jam-istio

Modify `helm/jam-istio/Chart.yaml`, referring istio `x.y.z`

```
apiVersion: v1
appVersion: "1.0"
description: A Helm chart for istio
name: jam-istio
version: 0.1.0
dependencies:
  - name: istio
    version: x.y.z
    repository: https://storage.googleapis.com/istio-release/releases/x.y.z/charts
```

Update istio chart

```
helm dependency update helm/jam-istio
```

* `helm dependency`: manage a chart’s dependencies
* `helm dependency update`: update charts/ based on the contents of Chart.yaml

Apply istio to cluster

```
helm template jam-istio helm/jam-istio -f instances/$JAM_INSTANCE-k8s.yaml -f instances/$JAM_INSTANCE-config.yaml --namespace istio-system |  kubectl apply -f -
```

### 3. Update sidecar

```
kubectl rollout restart deployment --namespace $JAM_INSTANCE # restart all deployment
kubectl rollout restart sts --namespace $JAM_INSTANCE # restart all statefulSet
watch -t -n1 kubectl get pods -n $JAM_INSTANCE # wait for all pods become healthy
```

> Note: Please ensure kubectl version is greater than 1.15


Verify the istio version in the cluster:

```
brew install istioctl  # Please install istioctl if not yet, here is the sample on Mac.

istioctl version
```

You would get report like this:

```
client version: 1.4.6
control plane version: 1.4.6
data plane version: 1.4.6 (35 proxies)
```

## Reliablity Validation with Istio Fault Injection


[HTTPS流量管理 —— 故障注入测试](https://github.com/Chao-Xi/JacobTechBlog/blob/master/Istio/12Istio_http4.md#122-%E6%95%85%E9%9A%9C%E6%B3%A8%E5%85%A5%E6%B5%8B%E8%AF%95)



### Introduce

Istio provides a flexible mechanisms to test the failure recovery capacity of the k8s instance as a whole.


### Fault Injection Types

Beside the literal fault injection feature, Istio also provides several traffic management mechanisms can be used to verify the stability.

This doc will show how to configure istio to manage traffic for internal and external services.


**1. External Service**


There are two external services: mysql and smtp

We configure `'ServiceEntry'` type to describe the properties of the **`mysql` and `smtp` service**, to verify how the Jam instance handle the **DB failure**. 

We can easily change the 'hosts' field to a fake address to fail the mysql connection.

```
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  labels:
    app: mysql
  name: mysql![architecture](assets/azure_network_architecture.png?raw=true)
  namespace: {$JAM_NAMESPACE}
spec:
  hosts:
  - {$JAM_ExternalMySQLHostName}
  ports:
  - number: 3306
    name: tcp
    protocol: TCP
  resolution: DNS
  location: MESH_EXTERNAL
```

![Alt Image Text](images/23_1.png "Body image")

**2. Internal Services**

there are two protocols for internal services: http and tcp Istio `'VirtualService'` provides feature to do `http/tcp` fault injection.


![Alt Image Text](images/23_2.png "Body image")

**2.1 Http fault injection**

This example shows a VirtualService which routes all http requests to ct-webapp service to `'ct-webapp'` and return 100% `503 abort error`.

```
kind: VirtualService
apiVersion: networking.istio.io/v1alpha3
metadata:
  name: ct-webapp
  namespace: {$JAM_NAMESPACE}
spec:
  hosts:
    - ct-webapp
  http:
    - fault:
        abort:
          httpStatus: 503
          percentage:
            value: 100
      route:
        - destination:
            host: ct-webapp
```

**注入中断**: 

注人一个`HTTP 503`错误, 和延迟注人一样，中断注人也可以使用 `percent` 字段来设置注入百分比。

**NOTE** Beside the '**abort**' type fault, istio also provide injecting '**delay**' fault, we can leverage this feature to simulate a slow respponse scenario. 

Here is an example of injecting 7s delay when client hitting /auth url, and keep ct-webapp behaving normal for other requests.

```
kind: VirtualService
apiVersion: networking.istio.io/v1alpha3
metadata:
  name: ct-webapp
  namespace: {$JAM_NAMESPACE}
spec:
  hosts:
    - ct-webapp
  http:
  - fault:
      delay:
        fixedDelay: 7s
        percentage:
          value: 100
    match:
    - uri:
        prefix: "/auth"
    route:
    - destination:
        host: ct-webapp
  - route:
    - destination:
        host: ct-webapp
```

**注入延迟**

* `percent`：是一个百分比，用于指定注人延迟的比率，其默认值为`1000 `。
* `fixedDelay`：表明延迟的时间长度，必须大于`1`毫秒。


**2.2 Tcp fault injection**

Istio official document mentions the fault injection feature support tcp protocol, it does not work in version 1.4.6. The workaround is leveraging tcp traffic shifting. We can redirect the internal tcp requests to an invaild services to reject the operation. Here is an example

```
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: doc-memcached-fault-traffic-shift
  namespace: {$JAM_NAMESPACE}
spec:
  hosts:
  - doc-memcached
  tcp:
  - match:
    - port: 11212
    route:
    - destination:
        host: fake_service
        port:
          number: 9000
      weight: 100
  - match:
    - port: 11211
    route:
    - destination:
        host: fake_service
        port:
          number: 9000
      weight: 100
```

**Note**: After apply the VirtualService to the cluster, the envoy on specific pod needs wait for a while to get the updates from the pliot. By rollout restart the pods could get the changes applied immediately.


## `fault-injection`

```
fault-injection/
├── Chart.yaml
├── templates
│   ├── ct-webapp-fault-injection.yaml
│   ├── memcached-fault-injection.yaml
│   └── services.yaml
└── values.yaml

1 directory, 5 files
```

**values.yaml**

```
jam:
  namespace: local700
  fake_service:
    enabled: false
  memcached:
    faultinject: false
  ctWebapp:
    faultinject: false
```

**Chart.yaml**

```
apiVersion: v1
appVersion: "1.0"
description: A Helm chart for managing Jam fault injections
name: fault-injection
version: 0.1.0
```

 **templates/ct-webapp-fault-injection.yaml**
 
```
 {{- if .Values.jam.ctWebapp.faultinject}}
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ct-webapp-fault-inject
  namespace: {{ .Values.jam.namespace }}
spec:
  hosts:
  - ct-webapp
  http:
    - fault:
        abort:
          percentage:
            value: 100.0
          httpStatus: 503
      route:
        - destination:
            host: ct-webapp
{{- end}}
```

**templates/memcached-fault-injection.yaml**

```
{{- if .Values.jam.memcached.faultinject }}
kind: VirtualService
apiVersion: networking.istio.io/v1alpha3
metadata:
  name: memcached-fault-inject
  namespace: {{ .Values.jam.namespace }}
spec:
  hosts:
  - memcached
  tcp:
  - match:
    - port: 11212
    route:
    - destination:
        host: fake-service
        port:
          number: 9000
      weight: 100
  - match:
    - port: 11211
    route:
    - destination:
        host: fake-service
        port:
          number: 9000
      weight: 100
{{- end}}
```

**templates/services.yaml**

```
{{- if .Values.jam.fake_service.enabled }}
apiVersion: v1
kind: Service
metadata:
  name: fake-service
  namespace: {{ .Values.jam.namespace }}
  labels:
    app: fake-service
spec:
  ports:
  - name: fake-service
    protocol: TCP
    port: 9999
    targetPort: 9999
  - name: fake-service
    protocol: HTTP
    port: 80
    targetPort: 80
{{- end}}
```

## Troubleshooting on istio

### Introduce

[Istio](https://istio.io/) is the service mesh framework for Jam on K8S. It uses [Envoy](https://www.envoyproxy.io/) as sidecar to proxy the network traffic between pods.

### Issue symptom

Envoy will return status code `503` for every failed TCP connection. You can simply run `curl -v` on pod to test that weather your request is blocked by Envoy or not. Like:

```
ps-79797bf8f6-gm6xh:> curl -v doc-memcached:11212
# * Rebuilt URL to: doc-memcached:11212/
# * Hostname was NOT found in DNS cache
# *   Trying 100.65.43.50...
# * Connected to doc-memcached (100.65.43.50) port 11212 (#0)
# > GET / HTTP/1.1
# > User-Agent: curl/7.37.0
# > Host: doc-memcached:11212
# > Accept: */*
# > 
# < HTTP/1.1 503 Service Unavailable
# < content-length: 95
# < content-type: text/plain
# < date: Mon, 23 Mar 2020 04:26:33 GMT
# * Server envoy is not blacklisted
# < server: envoy
# < x-envoy-upstream-service-time: 85
# < 
# * Connection #0 to host doc-memcached left intact
# upstream connect error or disconnect/reset before headers. reset reason: connection termination
```

If you saw return code `503` by server `server: envoy`, then there's high chance that your request is blocked by Enovy.

### Troubleshooting

**1. Test your request without envoy**

The simplest way to test your request without Envoy sidecar is `curl` directly from your `istio-proxy`.

For example, If you want to test your `11212` port of `doc-memcached` pod, you can run:

```
kubectl exec -n $JAM_INSTANCE doc-memcached-8764bbbbf-pbl4k  -c istio-proxy -- curl -vs localhost:11212
# * Rebuilt URL to: localhost:11212/
# *   Trying 127.0.0.1...
# * TCP_NODELAY set
# * Connected to localhost (127.0.0.1) port 11212 (#0)
# > GET / HTTP/1.1
# > Host: localhost:11212
# > User-Agent: curl/7.58.0
# > Accept: */*
# > 
# * Empty reply from server
# * Connection #0 to host localhost left intact
# command terminated with exit code 52
```

**You can see that at least it not returns `503`, and TCP connection was successfully established. Means that something went wrong in envoy side.**


**2. Get log from Envoy**

Envoy not output debug level log by default. You need to enable debug logging by:

```
kubectl exec -n $JAM_INSTANCE ${POD_NAME} -c istio-proxy -- curl -XPOST -s http://localhost:15000/logging?level=debug

# active loggers:
#   admin: debug
#   aws: debug
#   assert: debug
#   backtrace: debug
#   client: debug
#   config: debug
#   connection: debug
#   conn_handler: debug
#   dubbo: debug
#   file: debug
#   filter: debug
#   forward_proxy: debug
#   grpc: debug
#   hc: debug
#   health_checker: debug
#   http: debug
#   http2: debug
#   hystrix: debug
#   init: debug
#   io: debug
#   jwt: debug
#   kafka: debug
#   lua: debug
#   main: debug
#   misc: debug
#   mongo: debug
#   quic: debug
#   pool: debug
#   rbac: debug
#   redis: debug
#   router: debug
#   runtime: debug
#   stats: debug
#   secret: debug
#   tap: debug
#   testing: debug
#   thrift: debug
#   tracing: debug
#   upstream: debug
#   udp: debug
#   wasm: debug
```

Then you can replay the request that returns `503`, and lookup the output from logs. **Tips: Download full log from k8s dashboard**.

You're looking for something like

```
':authority', 'doc-memcached:11212'
':path', '/'
':method', 'GET'
':scheme', 'http'
'user-agent', 'curl/7.37.0'
'accept', '*/*'
'x-forwarded-proto', 'http'
'x-request-id', '07059fa1-d488-43d6-acea-38dd50f41d63'
'x-b3-traceid', '107286de00870c2ab8e358f1c125a49c'
'x-b3-spanid', 'b8e358f1c125a49c'
'x-b3-sampled', '0'

[Envoy (Epoch 0)] [2020-03-20 03:34:48.600][30][debug][client] [external/envoy/source/common/http/codec_client.cc:31] [C260] connecting
[Envoy (Epoch 0)] [2020-03-20 03:34:48.600][30][debug][connection] [external/envoy/source/common/network/connection_impl.cc:718] [C260] connecting to 127.0.0.1:11212
[Envoy (Epoch 0)] [2020-03-20 03:34:48.600][30][debug][connection] [external/envoy/source/common/network/connection_impl.cc:727] [C260] connection in progress
[Envoy (Epoch 0)] [2020-03-20 03:34:48.600][30][debug][http2] [external/envoy/source/common/http/http2/codec_impl.cc:905] [C260] setting max concurrent streams to 1073741824
[Envoy (Epoch 0)] [2020-03-20 03:34:48.600][30][debug][http2] [external/envoy/source/common/http/http2/codec_impl.cc:912] [C260] setting stream-level initial window size to 268435456
[Envoy (Epoch 0)] [2020-03-20 03:34:48.600][30][debug][http2] [external/envoy/source/common/http/http2/codec_impl.cc:934] [C260] updating connection-level initial window size to 268435456
[Envoy (Epoch 0)] [2020-03-20 03:34:48.600][30][debug][pool] [external/envoy/source/common/http/conn_pool_base.cc:20] queueing request due to no available connections
[Envoy (Epoch 0)] [2020-03-20 03:34:48.600][30][debug][connection] [external/envoy/source/common/network/connection_impl.cc:566] [C260] connected
[Envoy (Epoch 0)] [2020-03-20 03:34:48.600][30][debug][client] [external/envoy/source/common/http/codec_client.cc:69] [C260] connected
[Envoy (Epoch 0)] [2020-03-20 03:34:48.600][30][debug][pool] [external/envoy/source/common/http/http2/conn_pool.cc:98] [C260] creating stream
[Envoy (Epoch 0)] [2020-03-20 03:34:48.600][30][debug][router] [external/envoy/source/common/router/router.cc:1618] [C259][S17875777386769025078] pool ready
[Envoy (Epoch 0)] [2020-03-20 03:34:48.600][30][debug][connection] [external/envoy/source/common/network/connection_impl.cc:534] [C260] remote close
[Envoy (Epoch 0)] [2020-03-20 03:34:48.600][30][debug][connection] [external/envoy/source/common/network/connection_impl.cc:193] [C260] closing socket: 0
[Envoy (Epoch 0)] [2020-03-20 03:34:48.600][30][debug][client] [external/envoy/source/common/http/codec_client.cc:88] [C260] disconnect. resetting 1 pending requests
[Envoy (Epoch 0)] [2020-03-20 03:34:48.600][30][debug][client] [external/envoy/source/common/http/codec_client.cc:111] [C260] request reset
[Envoy (Epoch 0)] [2020-03-20 03:34:48.600][30][debug][pool] [external/envoy/source/common/http/http2/conn_pool.cc:236] [C260] destroying stream: 0 remaining
[Envoy (Epoch 0)] [2020-03-20 03:34:48.600][30][debug][router] [external/envoy/source/common/router/router.cc:911] [C259][S17875777386769025078] upstream reset: reset reason connection termination
[Envoy (Epoch 0)] [2020-03-20 03:34:48.600][30][debug][http] [external/envoy/source/common/http/conn_manager_impl.cc:1354] [C259][S17875777386769025078] Sending local reply with details upstream_reset_before_response_started{connection termination}
[Envoy (Epoch 0)] [2020-03-20 03:34:48.600][30][debug][filter] [src/envoy/http/mixer/filter.cc:135] Called Mixer::Filter : encodeHeaders 2
[Envoy (Epoch 0)] [2020-03-20 03:34:48.600][30][debug][http] [external/envoy/source/common/http/conn_manager_impl.cc:1552] [C259][S17875777386769025078] encoding headers via codec (end_stream=false):
':status', '503'
'content-length', '95'
'content-type', 'text/plain'
'date', 'Fri, 20 Mar 2020 03:34:48 GMT'
'server', 'istio-envoy'
'x-envoy-decorator-operation', 'doc-memcached.integration702.svc.cluster.local:11212/*'
```

In some case you can see HTTP error code and do further digging. But in this case, you can only find `[C260] remote close` which means TCP connection failed. Which means we need to do some `TCP dumping`

**3. TCP dumping**

TCP dumping is quite easy on K8S with correct tools. You'll need [krew](https://github.com/kubernetes-sigs/krew), [ksniff](https://github.com/eldadru/ksniff) and [wireshark](https://www.wireshark.org/).

Now you need to sniff the `istio-proxy` container on your target pod.

```
kubectl sniff ${POD_NAME} -p -n $JAM_INSTANCE -c istio-proxy -o ${LOCAL_DUMP_FILE_PATH}
```

It will run a pod in your target namespace and TCP dump to your local file. If you are just looking for localhost traffic(no outbound traffic involved), then you can use `-i lo` flag.

You can also add filter to narrow down the log scope by flag `-f`, like `-f ‘tcp[tcpflags] & (tcp-syn|tcp-fin|tcp-rst) != 0’` to only dump `SYN`, `FIN` and `RST` fragments.

Finally, you can analyze the TCP traffic using wireshark.

**4. Cleanup**

You should change the log level of istio-proxy to info for avoiding too many log files.

```
kubectl exec -n $JAM_INSTANCE ${POD_NAME} -c istio-proxy -- curl -XPOST -s http://localhost:15000/logging?level=info
```

And Don't forget to delete ksniff pods.

``
kubectl get pod -n $JAM_INSTANCE | grep ksniff`
```

**tips**

* `istioctl` is a handy tool to query all `clusters`,` route`s, `endpoints` and `listeners` in in istio.
* The traffic in cluster is normally `container-envoy-envoy-container`. So you'd better to test both inbound and outbound envoy to get full picture.
* Not familiar with istio? Check it out https://jimmysong.io/istio-handbook/!


**reference:**

1. https://blog.fleeto.us/post/istio-503-uc-debug/
2. https://www.servicemesher.com/istio-handbook/