# Application 3: Jam opensocial (Version Pre-Alpha)

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

`$ helm template opensocial/`

## opensocial deployment and service

### `opensocial deployment`

```
---
#
# ----- [ Open Social ] --------------------
#

apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: opensocial
  namespace: {{ .Values.jam.namespace }}
spec:
  replicas: 2
  template:
    metadata:
      labels:
        app: opensocial
    spec:
{{ include "jam.antiaffinity" "opensocial" | indent 6 }}
      containers:
      - name: opensocial
        image: {{ .Values.registry.url }}/opensocial{{ .Values.jam.releaseContainerSuffix }}:{{ include "jam.release" . }}
        command: ["java"]
        args: [
          "-Dshindig.host=$(SHINDIG_HOST)",
          "-Dsapjam.opensocial.internalPort=6060",
          "-Dsapjam.opensocial.net.sslMode=$(SSLMODE)",
          "-Dsapjam.opensocial.net.forbiddenSubnets=10.0.0.0/8,172.0.0.0/8,100.0.0.0/8",
          "-Dsapjam.opensocial.backchannel.jamUrl=$(JAM_ROOT_URL)",
          "-Dsapjam.opensocial.cache.memcacheds=memcached-opensocial:11211",
          "-Dsapjam.opensocial.secret.fromEnvironment=true",
          "-Dsapjam.opensocial.secret.keyName=ct_opensocial_shared_secret",
          "-Djava.io.tmpdir=/app/deployed-tmp",
          "-jar","/app/target/opensocial-server.war"
        ]
        imagePullPolicy: Always
        envFrom:
        - secretRef:
            name: opensocial
            # ct_opensocial_shared_secret
        env:
        - name: EXTERNAL_HOST_NAME
          valueFrom:
            configMapKeyRef:
              name: cluster-static
              key: EXTERNAL_HOST_NAME
        - name: NONCE
          value: {{ .Values.jam.nonce | quote }}
        - name: JAM_ROOT_URL
          value: https://$(EXTERNAL_HOST_NAME)
        - name: SHINDIG_HOST
          value: gadgets-$(EXTERNAL_HOST_NAME)
        - name: SSLMODE
          value: "1"
        - name: MEMCACHEDS
          value: memcached:11211
        livenessProbe:
          exec:
            command: ["curl", "--fail", "http://localhost:6060/opensocial-server/"]
          initialDelaySeconds: 10
          timeoutSeconds: 10
      imagePullSecrets:
        - name: registry
```

* `image: {{ .Values.registry.url }}/opensocial{{ .Values.jam.releaseContainerSuffix }}:{{ include "jam.release" . }}`

```
image: jam.docker.repositories.sapcdn.io/opensocial:lastStableBuild
```

* `value: {{ .Values.jam.nonce | quote }}`

```
value: "1"
```


### `opensocial service`

```
---
# ----- [ Open Social ] --------------------
#
apiVersion: v1
kind: Service
metadata:
  name: opensocial
  namespace: {{ .Values.jam.namespace }}
  labels:
    app: opensocial
spec:
  selector:
    app: opensocial
  ports:
  - name: http
    protocol: TCP
    port: 6060
    targetPort: 6060
```

## opensocial memcached deployment and service


### `memcached-deployment`

```
---

# [START opensocial-memcached deployment]
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: memcached-opensocial
  namespace: {{ .Values.jam.namespace }}
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: memcached
        scope: opensocial
    spec:
      containers:
      - name: memcached
        image: memcached:1.5-alpine
        args: ["-p", "11211", "-l", "0.0.0.0:11211,0.0.0.0:11212"]

# [END opensocial deployment]
```

### `memcached-service`

```
apiVersion: v1
kind: Service
metadata:
  name: memcached-opensocial
  namespace: {{ .Values.jam.namespace }}
  labels:
    app: memcached
spec:
  selector:
    app: memcached
    scope: opensocial
  ports:
  - name: http1
    protocol: TCP
    port: 11211
    targetPort: 11211
  - name: http2
    protocol: TCP
    port: 11212
    targetPort: 11212
```

