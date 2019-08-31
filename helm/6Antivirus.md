# Antivirus 

### `values.yaml`

```
jam:
  namespace: local700
  releaseContainerSuffix: ""
  nonce: 1
registry:
  url: jam.docker.repositories.sapcdn.io
```


## `templates`

### `_affinity.tpl`

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

### `_helper.tpl`

```
{{- define "jam.release" -}}
{{- .Values.jam.release | default "lastStableBuild" -}}
{{- end -}}
```

### `service.yaml`

```
---
# ----- [ Antivirus ] --------------------
#
apiVersion: v1
kind: Service
metadata:
  name: antivirus
  namespace: {{ .Values.jam.namespace }}
  labels:
    app: antivirus
spec:
  selector:
    app: antivirus
  ports:
  - name: tcp
    protocol: TCP
    port: 3310
    targetPort: 3310
```

### `deployment.yaml`

```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: antivirus
  namespace: {{ .Values.jam.namespace }}
spec:
  replicas: 2
  template:
    metadata:
      labels:
        app: antivirus
    spec:
{{ include "jam.antiaffinity" "antivirus" | indent 6 }}
      containers:
        - name: antivirus
          image: {{ .Values.registry.url }}/antivirus{{ .Values.jam.releaseContainerSuffix }}:{{ include "jam.release" . }}
          imagePullPolicy: Always
          env:
          - name: NONCE
            value: {{ .Values.jam.nonce | quote }}
          - name: ISK8S
            value: "1"
          livenessProbe:
            exec:
              command: ["curl", "--fail", "http://localhost:3310"]
            initialDelaySeconds: 30
      imagePullSecrets:
        - name: registry
```

