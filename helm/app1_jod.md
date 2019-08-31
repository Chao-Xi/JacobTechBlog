# Application 1: Jod 

## `values.yaml`

```
jam:
  namespace: local700
  releaseContainerSuffix: ""
  deploymentLandscape: aws
registry:
  url: jam.docker.repositories.sapcdn.io
```


### `_antiaffinity.tpl`

### `_helper.tpl`： Relase name

```
{{- define "jam.release" -}}
{{- .Values.jam.release | default "lastStableBuild" -}}
{{- end -}}
```

## `templates/deployment.yaml`

```
---

# [START jod deployment]
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: jod
  namespace: {{ .Values.jam.namespace }}
spec:
  replicas: 3
  template:
    metadata:
      labels:
        app: jod
    spec:
{{ include "jam.antiaffinity" "jod" | indent 6 }}
      containers:
      - name: jod
        #image: {{ .Values.registry.url }}/jod-converter:master-5_3_7_2
        image: {{ .Values.registry.url }}/jod-converter{{ .Values.jam.releaseContainerSuffix }}:{{ include "jam.release" . }}
        livenessProbe:
          exec:
            command: [
              "curl", "--fail", "-s",
              "-o","/dev/null",
              "-F","inputDocument=@/test.docx",
              "http://localhost:8080/converter/converted/document.pdf"
            ]
          initialDelaySeconds: 60
          timeoutSeconds: 60
        readinessProbe:
          exec:
            command: [
              "curl", "--fail", "-s",
              "-o","/dev/null",
              "-F","inputDocument=@/test.docx",
              "http://localhost:8080/converter/converted/document.pdf"
            ]
          initialDelaySeconds: 20
          timeoutSeconds: 60
      imagePullSecrets:
        - name: registry
# [END jod deployment]
```

* `image: {{ .Values.registry.url }}/jod-converter{{ .Values.jam.releaseContainerSuffix }}:{{ include "jam.release" . }}`
* `image: jam.docker.repositories.sapcdn.io/jod-converter:lastStableBuild`


## `templates/service.yaml`

```
apiVersion: v1
kind: Service
metadata:
  name: jod
  namespace: {{ .Values.jam.namespace }}
  labels:
    app: jod
spec:
  selector:
    app: jod
  ports:
  - name: http
    protocol: TCP
    port: 8080
    targetPort: 8080
# [END jod service]
```

