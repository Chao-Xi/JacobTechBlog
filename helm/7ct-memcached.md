# CT-Memcached

### `values.yaml`

```
jam:
  namespace: local700
```

### `service.yaml`

```
#
# Service heads for dependencies
#
---
# ----- [ memcached ] --------------------
#
apiVersion: v1
kind: Service
metadata:
  name: memcached
  namespace: {{ .Values.jam.namespace }}
  labels:
    app: memcached
spec:
  selector:
    app: memcached
    scope: cache
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

### `deployment.yaml`

```
---
# ----- [ memcached ] --------------------
#
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: cache-memcached
  namespace: {{ .Values.jam.namespace }}
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: memcached
        scope: cache
    spec:
      containers:
      - name: memcached
        image: memcached:1.5-alpine
        args: ["-p", "11211", "-l", "0.0.0.0:11211,0.0.0.0:11212"]
```

