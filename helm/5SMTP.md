# SMTP (Mail)

## `values.yaml`

```
jam:
  namespace: local700
  mail:
    external: true
    externalHostName: email-smtp.com
    externalHostPort: 587
```

## `services.yaml`
 
```
# SMPT Service, mailcatcher if internal, ExternalName otherwise
apiVersion: v1
kind: Service
metadata:
  name: smtp
  namespace: {{ .Values.jam.namespace }}
  {{- if .Values.jam.mail.external | not}}
  labels:
    k8s-app: mailcatcher
    kubernetes.io/cluster-service: "true"
  {{- end}}
spec:
  {{- if .Values.jam.mail.external}}
  type: ExternalName
  externalName: {{ .Values.jam.mail.externalHostName}}
  {{- else}}
  selector:
    app: mailcatcher
  ports:
  - name: smtp
    protocol: TCP
    port: 25
    targetPort: 25
  - name: interface
    protocol: TCP
    port: 1080
    targetPort: 80
  {{- end}}
```

* **`namespace: {{ .Values.jam.namespace }}`**

* **With external email**

```
{{- if .Values.jam.mail.external | not}}
{{- end}}
```

* **Without external email**

```
{{- if .Values.jam.mail.external}}
type: ExternalName
externalName: {{ .Values.jam.mail.externalHostName}}
```

## `mailcatcher-deployment.yaml` (With use external email) 

```
{{- if .Values.jam.mail.external | not }}
# Mailcatcher

apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: mailcatcher
  namespace: {{ .Values.jam.namespace }}
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: mailcatcher
    spec:
      containers:
      - name: mailcatcher
        image: tophfr/mailcatcher
        imagePullPolicy: Always
        ports:
        - name: smtp
          protocol: TCP
          containerPort: 25
        - name: interface
          protocol: TCP
          containerPort: 80
{{- end}}
```


