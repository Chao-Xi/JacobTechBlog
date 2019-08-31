# Jam Loadbalancer (Version Pre-Alpha)


```
$ tree loadbalancer 
.
├── Chart.yaml
├── templates
│   ├── _antiaffinity.tpl
│   ├── _helper.tpl
│   ├── deployment.yaml
│   └── service.yaml
└── values.yaml

1 directory, 6 files
```
```
$ helm install --name jam-load-balancer helm/jam/load-balancer/ -f instances/$JAM_INSTANCE-k8s.yaml --namespace $JAM_INSTANCE
```

* [Chart 文件结构](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_helm12_Charts.md#chart-%E6%96%87%E4%BB%B6%E7%BB%93%E6%9E%84)

* `Chart.yaml`  # A YAML file containing information about the chart
* `templates/`  # A directory of templates that, when combined with values, will generate valid Kubernetes manifest files.
* `values.yaml` # The default configuration values for this chart

## `Chart.yaml`

[`Chart.yaml` 文件](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_helm12_Charts.md#chartyaml-%E6%96%87%E4%BB%B6)

`Chart.yaml` 文件是 `chart `所必需的。它包含以下字段：

```
apiVersion: The chart API version, always "v1" (required)
name: The name of the chart (required)
version: A SemVer 2 version (required)
kubeVersion: A SemVer range of compatible Kubernetes versions (optional)
description: A single-sentence description of this project (optional)
keywords:
  - A list of keywords about this project (optional)
home: The URL of this project's home page (optional)
sources:
  - A list of URLs to source code for this project (optional)
maintainers: # (optional)
  - name: The maintainer's name (required for each maintainer)
    email: The maintainer's email (optional for each maintainer)
    url: A URL for the maintainer (optional for each maintainer)
engine: gotpl # The name of the template engine (optional, defaults to gotpl)
icon: A URL to an SVG or PNG image to be used as an icon (optional).
appVersion: The version of the app that this contains (optional). This needn't be SemVer.
deprecated: Whether this chart is deprecated (optional, boolean)
tillerVersion: The version of Tiller that this chart requires. This should be expressed as a SemVer range: ">2.0.0" (optional)
```

**`loadbalancer/Chart.yaml`**

```
apiVersion: v1
appVersion: "1.0"
description: A Helm chart for load balancer
name: load-balancer
version: 0.1.0
```

## `values.yaml`

```
jam:
  namespace: local700
  releaseContainerSuffix: ""
  deploymentLandscape: aws
  nonce: 1  
  loadBalancer:
    aws:
      sslCert: "arn:aws:acm:eu-central-1:371089343861:certificate/fd0341da-6fef-47fd-b954-b59fd2cb1991"
    gcp:
      loadBalancerIP:
registry:
  url: jam.docker.repositories.sapcdn.io
```

* `nonce: 1` changed for rolling update and can be set as timestap  

## `templates/`

### `partials` 和 `_` 文件 (`_antiaffinity.tpl` and `_help.tpl`)

[`partials` 和 `_` 文件](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_helm6_definename.md#partials-和-_-文件)

#### **1.`_antiaffinity.tpl`**

```
{{- define "jam.antiaffinity" -}}
affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        labelSelector:
          matchExpressions:
          - key: app
            operator: In
            values:
            - {{ . | quote }}
        topologyKey: kubernetes.io/hostname
{{- end -}}
```

* [控制空格](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_helm5_process.md#%E6%8E%A7%E5%88%B6%E7%A9%BA%E6%A0%BC)

`{{-` and `-}}`


> 1.我们可以通过使用在模板标识`{{`后面添加破折号和空格`{{-`来表示将**空白左移**，
> 
> 2.而在`}}`前面添加一个空格和破折号`-}}`表示应该**删除右边的空格**。 注意！换行符也是空格！

* **` {{ . | quote }}` 顶级范围变量**

* `Deployment.yml`调用`_antiaffinity.tpl`

```
{{ include "jam.antiaffinity" "load-balancer" | indent 6 }}
```

* "load-balancer" 作为传入的变量


#### **2.`_heper.tpl`**

```
{{- define "jam.release" -}}
{{- .Values.jam.release | default "lastStableBuild" -}}
{{- end -}}
```

* `-`: 一行输出

* 我们看到一个叫做文件 `_helpers.tpl`。该文件是模板 `partials` 的默认位置。
* `_helpers.tpl`：放置模板助手的地方，可以在整个 `chart` 中重复使用

* `default "lastStableBuild"`

[`default` 函数](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_helm4_template_pipe.md#default-%E5%87%BD%E6%95%B0)

一个我们会经常使用的一个函数是`default` 函数：`default DEFAULT_VALUE GIVEN_VALUE`。

* `Deployment.yml`调用`_helper.tpl`

```
 image: {{ .Values.registry.url }}/load-balancer{{ .Values.jam.releaseContainerSuffix }}:{{ include "jam.release" . }}
```

```
{{ include "jam.release" . }}
```

## `deployment.yaml`


```
apiVersion: v1
kind: ConfigMap
metadata:
  name: haproxy-config
  namespace: {{ .Values.jam.namespace }}
data:
  haproxy.cfg: |
    resolvers dockerdns
      # Internal DNS inside the new load balancer container (provided by dnsmasq, forwards to resolv.conf)
      nameserver dns1 127.0.0.1:53
      resolve_retries       3
      timeout resolve       1s
      timeout retry         1s
      hold other           30s
      hold refused         30s
      hold nx              30s
      hold timeout         30s
      hold valid           10s
      hold obsolete        30s

    global
      # SSL Tuning done here: https://mozilla.github.io/server-side-tls/ssl-config-generator/
      tune.ssl.default-dh-param 2048
      ssl-default-bind-ciphers ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS
      ssl-default-bind-options no-sslv3 no-tls-tickets
      ssl-default-server-ciphers ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS
      ssl-default-server-options no-sslv3 no-tls-tickets

    defaults
      mode    http
      option  dontlognull
      log /dev/log local0
      log /dev/log local1 notice
      log     global
      option  logasap
      option  httplog
      timeout connect 5000
      timeout client  120000
      timeout server  120000
      timeout http-keep-alive 5000
      timeout http-request 95000
      option forwardfor
      # Disable attempting to do DNS resolution on bootup
      default-server init-addr last,libc,none

    global
      stats socket /var/run/haproxy.sock mode 777 level admin expose-fd listeners
      stats timeout 2m

    listen stats
      bind *:8999
      mode http
      stats enable
      stats uri /

    frontend ct
      # Port 83 handles SSL termination at Ext LB. Port 443 handles SSL termination at haproxy
{{- if eq .Values.jam.deploymentLandscape "aws" }}
      bind *:83 accept-proxy
      bind *:443 accept-proxy ssl crt /certs/default.pem crt /certs/certs
{{- else }}
      bind *:443 ssl crt /certs/default.pem crt /certs/certs
{{- if eq .Values.jam.deploymentLandscape "gcp" }}
      bind *:83
      acl isNotHttps hdr(x-forwarded-proto) -i http
      http-request redirect scheme https if isNotHttps
{{- end }}
{{- end }}
      acl ishttps dst_port 443
      mode http
      http-request set-header X-JAM-CUSTOM-DOMAIN Yes if ishttps
      http-request set-header X-Forwarded-Proto https
      http-request set-header X-Forwarded-Port 443
      http-request set-header X-SF-CT-API Success123!
      # HAProxy appears to correctly be adding the x-forwarded-for header

      # Log some headers
      # capture request header Host len 25

      acl isopensocial path_beg /opensocial-server
      http-request deny if !METH_GET !METH_POST !METH_DELETE !METH_PUT !METH_OPTIONS isopensocial

      acl isagentserver path_beg /rt/

      acl isdocconversion path /api/services/v1/healthcheck/summarytext
      http-request deny if !METH_GET isdocconversion

      acl hasconnection res.hdr(Connection) -m found
      acl hasstricttransport res.hdr(Strict-Transport-Security) -m found
      rspadd "Strict-Transport-Security: max-age=63072000; includeSubdomains;" if !hasstricttransport
      rspadd "Connection: keep-alive" if !hasconnection
      rspadd "Keep-Alive: timeout=5, max=95"
      use_backend agentservernodes if isagentserver
      use_backend opensocialnodes if isopensocial
      use_backend docconversionnodes if isdocconversion
      default_backend ctnodes

    backend ctnodes
      balance leastconn
      option httpchk GET / HTTP/1.1\r\nHost:jam.healthcheck.com
      http-check disable-on-404
      http-check expect status 200
      default-server inter 2s fall 2
      timeout check 10000
      server ct-webapp ct-webapp.{{ .Values.jam.namespace }}.svc.cluster.local:80 resolvers dockerdns check resolve-prefer ipv4

    frontend httpredirect
{{- if eq .Values.jam.deploymentLandscape "aws" }}
      bind *:80 accept-proxy
{{- else }}
      bind *:80
{{- end }}
      http-request redirect scheme https

    backend opensocialnodes
      option httpchk GET /opensocial-server/ HTTP/1.1\r\nHost:jam.healthcheck.com
      http-check disable-on-404
      http-check expect status 200
      http-request set-header X-Forwarded-Proto https
      http-request set-header X-Forwarded-Port 443
      balance leastconn
      default-server inter 2s fall 2
      server opensocial opensocial.{{ .Values.jam.namespace }}.svc.cluster.local:6060 resolvers dockerdns check resolve-prefer ipv4

    backend agentservernodes
      balance leastconn
      default-server inter 2s fall 2
      server agent-server-realtime agent-server-realtime.{{ .Values.jam.namespace }}.svc.cluster.local:7200 resolvers dockerdns check resolve-prefer ipv4

    backend docconversionnodes
      balance leastconn
      default-server inter 2s fall 2
      server doc doc.{{ .Values.jam.namespace }}.svc.cluster.local:7100 resolvers dockerdns check resolve-prefer ipv4

    frontend incomingmail
{{- if eq .Values.jam.deploymentLandscape "aws" }}
      bind *:25 accept-proxy
{{- else }}
      bind *:25
{{- end }}
      mode tcp
      no option http-server-close
      option tcplog
      timeout client 1m
      default_backend incomingmailnodes

    backend incomingmailnodes
      mode tcp
      option smtpchk
      no option http-server-close
      option tcplog
      timeout server 1m
      timeout connect 5s
      default-server inter 2s fall 2
      server mail-inbound mail-inbound.{{ .Values.jam.namespace }}.svc.cluster.local:25 resolvers dockerdns check send-proxy resolve-prefer ipv4

---
# ----- [ load-balancer deployment ] --------------------
#
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: load-balancer
  namespace: {{ .Values.jam.namespace }}
spec:
  replicas: 3
  template:
    metadata:
      labels:
        app: load-balancer
    spec:
{{ include "jam.antiaffinity" "load-balancer" | indent 6 }}
      containers:
      - name: load-balancer
        image: {{ .Values.registry.url }}/load-balancer{{ .Values.jam.releaseContainerSuffix }}:{{ include "jam.release" . }}
        imagePullPolicy: Always
        envFrom:
        - secretRef:
            name: db-ct
            # database credentials (MYSQL_PASSWORD and MYSQL_USER)
        env:
        - name: MYSQL_DB
          valueFrom:
            configMapKeyRef:
              name: data
              key: MYSQL_CT_DB
        - name: DB_CRYPTO_KEY
          valueFrom:
            secretKeyRef:
              name: db-ct
              key: CRYPTO_PASSPHRASE
        - name: MYSQL_HOST
          value: mysql
        - name: NONCE
          value: {{ .Values.jam.nonce | quote }}
        volumeMounts:
          - name: lb-config
            mountPath: /usr/local/etc/haproxy
{{- if eq .Values.jam.deploymentLandscape "azure" }}
          - name: ssl-cert-volume
            mountPath: /etc/cubetree/secrets/
{{- end }}
      volumes:
        - name: lb-config
          configMap:
            name: haproxy-config
            items:
            - key: haproxy.cfg
              path: haproxy.cfg
{{- if eq .Values.jam.deploymentLandscape "azure" }}
        - name: ssl-cert-volume
          secret:
            secretName: termination-cert-for-load-balancer
{{- end }}
      imagePullSecrets:
        - name: registry

```

### `configmap`

```
data:
  haproxy.cfg: |
  ...
```

**`if/else 条件`**

```
{{- if eq .Values.jam.deploymentLandscape "aws" }}
      bind *:83 accept-proxy
      bind *:443 accept-proxy ssl crt /certs/default.pem crt /certs/certs
{{- else }}
      bind *:443 ssl crt /certs/default.pem crt /certs/certs
{{- if eq .Values.jam.deploymentLandscape "gcp" }}
      bind *:83
      acl isNotHttps hdr(x-forwarded-proto) -i http
      http-request redirect scheme https if isNotHttps
{{- end }}
```


**其中运算符`eq`是判断是否相等的操作，除此之外，还有`ne`、`lt`、`gt`、`and`、`or`等运算符都是 Helm 模板已经实现了的，直接使用即可。**

```
image: {{ .Values.registry.url }}/load-balancer{{ .Values.jam.releaseContainerSuffix }}:{{ include "jam.release" . }}
```

```
 - name: NONCE
   value: {{ .Values.jam.nonce | quote }}
```   

### `deployment.yaml`


[更新 `Secret` 和 `ConfigMap`](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_adv5_ConfigMap_Secrets.md#6-%E6%9B%B4%E6%96%B0-secret-%E5%92%8C-configmap)

```
...
env:
- name: MYSQL_DB
  valueFrom:
    configMapKeyRef:
      name: data
      key: MYSQL_CT_DB
- name: DB_CRYPTO_KEY
  valueFrom:
    secretKeyRef:
      name: db-ct
      key: CRYPTO_PASSPHRASE
...
```

      

## `service.yaml`

```
# ----- [ CT ] --------------------
#
apiVersion: v1
kind: Service
metadata:
  name: load-balancer
  namespace: {{ .Values.jam.namespace }}
{{- if eq .Values.jam.deploymentLandscape "aws" }}
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-proxy-protocol: "*"
    service.beta.kubernetes.io/aws-load-balancer-ssl-cert: {{ .Values.jam.loadBalancer.aws.sslCert }}
    service.beta.kubernetes.io/aws-load-balancer-ssl-ports: ssl
    service.beta.kubernetes.io/aws-load-balancer-backend-protocol: tcp
{{- end }}
spec:
{{- if eq .Values.jam.deploymentLandscape "gcp" }}
  type: NodePort
{{- else }}
  type: LoadBalancer
{{- end }}
  selector:
    app: load-balancer
  ports:
{{- if not (eq .Values.jam.deploymentLandscape "gcp") }}
  - name: ssl
    protocol: TCP
    port: 443
{{- if eq .Values.jam.deploymentLandscape "azure" }}
    targetPort: 443
{{- else }}
    targetPort: 83
{{- end }}
{{- end }}
  - name: http
    protocol: TCP
    port: 80
{{- if eq .Values.jam.deploymentLandscape "gcp" }}
    targetPort: 83
{{- else }}
    targetPort: 80
{{- end }}
{{- if eq .Values.jam.deploymentLandscape "azure" }}
  - name: smtp
    protocol: TCP
    port: 25
    targetPort: 25
{{- end }}
  - name: stats
    protocol: TCP
    port: 8999

---

{{- if not (eq .Values.jam.deploymentLandscape "azure") }}
apiVersion: v1
kind: Service
metadata:
  name: load-balancer-custom-domain
  namespace: {{ .Values.jam.namespace }}
{{- if eq .Values.jam.deploymentLandscape "aws" }}
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-proxy-protocol: "*"
    service.beta.kubernetes.io/aws-load-balancer-backend-protocol: tcp
{{- end }}
spec:
  type: LoadBalancer
{{- if eq .Values.jam.deploymentLandscape "gcp" }}
  loadBalancerIP: {{ .Values.jam.loadBalancer.gcp.loadBalancerIP }}
{{- end }}
  selector:
    app: load-balancer
  ports:
  - name: ssl
    protocol: TCP
    port: 443
    targetPort: 443
  - name: http
    protocol: TCP
    port: 80
    targetPort: 80
  - name: smtp
    protocol: TCP
    port: 25
    targetPort: 25
{{- end }}

---
```
 





