# mail-inbound

## `values.yaml`

```
jam:
  namespace: local700
  releaseContainerSuffix: ""
registry:
  url: jam.docker.repositories.sapcdn.io
```


## `_helper.tpl`

```
{{- define "jam.release" -}}
{{- .Values.jam.release | default "lastStableBuild" -}}
{{- end -}}
```


### `service.yaml`

```
# Inbounce email.
#
apiVersion: v1
kind: Service
metadata:
  name: mail-inbound
  namespace: {{ .Values.jam.namespace }}
spec:
  selector:
    app: mail-inbound
  ports:
  - name: http
    protocol: TCP
    port: 25
    targetPort: 25
```

### `deployment.yaml`

```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: mail-inbound
  namespace: {{ .Values.jam.namespace }}
spec:
  replicas: 1
  template:
    metadata:
      annotations:
        "sidecar.istio.io/inject": "false"
      labels:
        app: mail-inbound
    spec:
      containers:
      - name: postfix-inbound
        image: {{ .Values.registry.url }}/postfix-inbound{{ .Values.jam.releaseContainerSuffix }}:{{ include "jam.release" . }}
        imagePullPolicy: Always
        env:
        - name: EXTERNAL_HOST_NAME
          valueFrom:
            configMapKeyRef:
              name: cluster-static
              key: EXTERNAL_HOST_NAME
        - name: NONCE
          value: "1"
        - name: ISK8S
          value: "1"
        - name: WEBHOOK_URL
          value: "https://$(EXTERNAL_HOST_NAME)/rpc/status_by_mail"
        - name: EMAIL_DOMAIN
          value: "updates-$(EXTERNAL_HOST_NAME)"
      imagePullSecrets:
        - name: registry
```

* `image: {{ .Values.registry.url }}/postfix-inbound{{ .Values.jam.releaseContainerSuffix }}:{{ include "jam.release" . }}`


