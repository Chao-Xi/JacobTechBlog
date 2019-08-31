# Jam Doc Conversion (Version Pre-Alpha)

### `values.yaml`

```
jam:
  namespace: local700
  releaseContainerSuffix: ""
  nonce: 1
registry:
  url: jam.docker.repositories.sapcdn.io
```


### Helm template

* `_helper.tpl`
* `_antiaffinity.tpl`



## `templates/deployment.yaml` => doc deployment

```
---

# [START doc deployment]
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: doc
  namespace: {{ .Values.jam.namespace }}
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  template:
    metadata:
      labels:
        app: doc
    spec:
{{ include "jam.antiaffinity" "doc" | indent 6 }}
      containers:
      - name: doc
        image: {{ .Values.registry.url }}/doc-conversion{{ .Values.jam.releaseContainerSuffix }}:{{ include "jam.release" . }}
        imagePullPolicy: Always
        envFrom:
        - secretRef:
            name: stats
            # stats console credentials
        - configMapRef:
            name: data
            # object store settings
        - secretRef:
            name: object-doc
            # object store credentials
        - secretRef:
            name: microservices
            # microservices bearer tokens
        env:
        - name: WEBSERVER_NAME
          valueFrom:
            configMapKeyRef:
              name: cluster-static
              key: EXTERNAL_HOST_NAME
        - name: DATA_STORAGE_BUCKET
          valueFrom:
            configMapKeyRef:
              name: data
              key: DATA_STORAGE_BUCKET_DOC
              # plug the DOC-scoped bucket into our bucket parameter
        - name: MEMCACHED_HOSTS
          value: "doc-memcached:11211"
        - name: AV_HOST
          value: antivirus
        - name: DISABLE_ALTERNATE_CONVERTER
          value: "true"
        - name: NONCE
          value: {{ .Values.jam.nonce | quote }}
        - name: ISK8S
          value: "1"
        - name: LOGDEBUG
          value: "1"
        livenessProbe:
          exec:
            command: ["curl", "--fail", "http://localhost:7100/api/services/v1/healthcheck/summarytext"]
          initialDelaySeconds: 10
          timeoutSeconds: 20
        readinessProbe:
          exec:
            command: ["curl", "--fail", "http://localhost:7100/api/services/v1/healthcheck/summarytext"]
          initialDelaySeconds: 10
          timeoutSeconds: 20
      imagePullSecrets:
        - name: registry
# [END doc deployment]
```

* `{{ include "jam.antiaffinity" "doc" | indent 6 }}`

```
- name: NONCE
  value: {{ .Values.jam.nonce | quote }}
```

```
- name: NONCE
  value: "1"
```

### `templates/service.yaml` => doc service

```
---
#
# ----- [ DOC Conversion ] --------------------
#

# [START doc service]
#   as much as i hate this,
#   nobody's taking ownership of pushing jod into doc-conversion for excel use cases
#   so for the time being, jod gets to be it's own service.
apiVersion: v1
kind: Service
metadata:
  name: doc
  namespace: {{ .Values.jam.namespace }}
  labels:
    app: doc
spec:
  selector:
    app: doc
  ports:
  - name: http
    protocol: TCP
    port: 7100
    targetPort: 7100
# [END doc service]
```

* `namespace: {{ .Values.jam.namespace }}`: `namespace: local700`


## `doc-memcached`

### `memcached-deployment.yaml`

```
---

# [START doc-memcached deployment]
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: doc-memcached
  namespace: {{ .Values.jam.namespace }}
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: memcached
        scope: doc
    spec:
      containers:
      - name: memcached
        image: memcached:1.5-alpine
        args: ["-p", "11211", "-l", "0.0.0.0:11211,0.0.0.0:11212"]

# [END jod deployment]
```

### `memcached-service.yaml`

```
---
#
# ----- [ DOC Conversion memcached ] --------------------
#
# [START doc-memcached service]
#   SPOF for memcached replicas to know about each other?
#   TODO: review & affirm or replace this approach
apiVersion: v1
kind: Service
metadata:
  name: doc-memcached
  namespace: {{ .Values.jam.namespace }}
  labels:
    app: memcached
spec:
  selector:
    app: memcached
    scope: doc
  ports:
  - name: http1
    protocol: TCP
    port: 11211
    targetPort: 11211
  - name: http2
    protocol: TCP
    port: 11212
    targetPort: 11212
# [END doc-memcached service]
```

