# Application 6: CT(Cubetree) Application (Jam Main Service)

**It will also init CT database, which is a time consuming job. So we need to add `--wait --timeout 1000` to prevent helm installation fails**


```
$ tree ct/
ct/
├── Chart.yaml
├── templates
│   ├── _ct.tpl
│   ├── _helper.tpl
│   ├── deploy-tasks-ct.yaml
│   ├── deployment.yaml
│   ├── init-ct.yaml
│   ├── migrate-ct.yaml
│   └── service.yaml
└── values.yaml

1 directory, 9 files
```

## values.yaml

```
jam:
  namespace: local700
  releaseContainerSuffix: ""
  nonce: 1
  ctWebapp:
    replicas: 3
    resources:
      memory:
        min: 2Gi
        max: 32Gi
      cpu:
        min: 4
        max: 16
    disableProbes: false
  ctWorker:
    replicas: 5
    resources:
      memory:
        min: 2Gi
        max: 4Gi
      cpu:
        min: 4
        max: 4
  ctScheduler:
    replicas: 1
  ctRpush:
    replicas: 1
  elasticsearch:
    replicas: 3
  elasticsearch6:
    replicas: 3
  mail:
    # Set to true for production systems where email sending is desired. Otherwise mailcatcher is used.
    external: false
    externalHostName: mailservice.cloudProvider.com
    externalHostPort: 25
  initialize:
    # Use integration for viral companies. Not recommended for int, stage or prod systems.
    data: production
    resetDb: false
registry:
  url: jam.docker.repositories.sapcdn.io
```

## templates 

* `_ct.tpl`
* `_helper.tpl` 

### `_ct.tpl`

* `{{- define "jam.ct.container" -}}`
* `{{- define "jam.ct.containerVolumes" -}}`

#### `{{- define "jam.ct.container" -}}`

```
{{- define "jam.ct.container" -}}
- name: {{ .Name }}
  image: {{ .Values.registry.url }}/ct{{ .Values.jam.releaseContainerSuffix }}:{{ include "jam.release" . }}
  imagePullPolicy: Always
{{- if .Command }}
  command: [{{ .Command | quote }}]
{{- end }}
{{- if .Args }}
  args:
{{- range .Args }}
  - {{ . | quote }}
{{- end -}}
{{- end }}
{{- if .Ports }}
  ports:
  - name: http
    containerPort: 80
{{- end }}
{{- if .Resources }}
  resources:
    requests:
      memory: {{ .Resources.memory.min | quote }}
      cpu: {{ .Resources.cpu.min | quote }}
    limits:
      memory: {{ .Resources.memory.max | quote }}
      cpu: {{ .Resources.cpu.max | quote }}
{{- end }}
{{- if .Probes }}
  livenessProbe:
    exec:
      command:
      {{- range .Probes.liveness }}
      - {{ . | quote }}
      {{- end }}
    initialDelaySeconds: 60
    timeoutSeconds: 60
  readinessProbe:
    exec:
      command:
      {{- range .Probes.readiness }}
      - {{ . | quote }}
      {{- end }}
    initialDelaySeconds: 20
    timeoutSeconds: 60
{{- end }}
  envFrom:
  - configMapRef:
      name: data
      # db & object store settings
  - secretRef:
      name: db-ct
      # database credentials
  - secretRef:
      name: object-ct
      # object store credentials
  - secretRef:
      name: email
      # smtp credentials
  env:
  - name: EXTERNAL_HOST_NAME
    valueFrom:
      configMapKeyRef:
        name: cluster-static
        key: EXTERNAL_HOST_NAME
  - name: DEFAULT_WORKER_QUEUE
    valueFrom:
      configMapKeyRef:
        name: default-worker-queue
        key: DEFAULT_WORKER_QUEUE
  - name: SSL_REQUIRED
    valueFrom:
      configMapKeyRef:
        name: cluster-static
        key: SSL_REQUIRED
  - name: DATA_STORAGE_BUCKET
    valueFrom:
      configMapKeyRef:
        name: data
        key: DATA_STORAGE_BUCKET_CT
        # plug the CT-scoped bucket into our bucket parameter
  - name: D_RABBITMQ_HA
    value: RABBITMQ_SERVICE
  - name: D_RABBITMQ_TRANSIENT
    value: RABBITMQ_SERVICE
  - name: D_JOD_ALTERNATE
    value: JOD_SERVICE
  - name: D_DOCCONVERSION
    value: DOC_SERVICE
{{- if .Values.jam.mail.external }}
  - name: SMTP_SERVICE_HOST
    value: {{ .Values.jam.mail.externalHostName}}
  # @TODO this default needs to be removed after R502 ships
  - name: SMTP_SERVICE_PORT
    value: {{ .Values.jam.mail.externalHostPort | default 587 | quote }}
{{- end }}
  - name: NONCE
    value: {{ .Values.jam.nonce | quote }}
  - name: RAILS_ENV
    value: production
  - name: ISDOCKER
    value: "1"
  - name: ISK8S
    value: "1"
  - name: INTERNAL_DOC_CONVERSION_HOST
    value: doc:7100
  - name: INSTANCE
    value: {{ .Values.jam.namespace }}
  - name: SMTP_ENABLE_STARTTLS_AUTO
    value: "true"
  - name: ELASTICSEARCH_REPLICAS
    value: {{ .Values.jam.elasticsearch.replicas | quote }}
  - name: ELASTICSEARCH6_REPLICAS
    value: {{ .Values.jam.elasticsearch6.replicas | quote }}
  - name: USE_ES6
    value: "true"
  volumeMounts:
  - name: instance-volume
    mountPath: /app/config/deploy/instances
  - name: secrets-volume
    mountPath: /etc/cubetree/secrets.yml
    subPath: "secrets.yml"
  - name: opensocial-credentials-volume
    mountPath: /etc/cubetree/secrets/opensocial
  - name: extranet-keys-volume
    mountPath: /etc/cubetree/secrets/extranet
  - name: master-sso-volume
    mountPath: /etc/cubetree/secrets/master-sso
  - name: saml-signing-external-volume
    mountPath: /etc/cubetree/secrets/saml-signing-external
  - name: realtime-credentials-volume
    mountPath: /etc/cubetree/secrets/realtime
  - name: microservices-tokens-volume
    mountPath: /etc/cubetree/secrets/microservices
  - name: media-credentials-volume
    mountPath: /etc/cubetree/secrets/media
  - name: stats-credentials-volume
    mountPath: /etc/cubetree/secrets/stats
  - name: rabbit-credentials-volume
    mountPath: /etc/cubetree/secrets/rabbit
  - name: rpush-certificate-volume
    mountPath: /etc/cubetree/secrets/Production_Push_Certificates.pem
    subPath: "Production_Push_Certificates.pem"
  - name: box-keys-volume
    mountPath: /etc/cubetree/secrets/box_keys.yml
    subPath: "box_keys.yml"
{{- end -}}
```

[Helm 模板之控制流程](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_helm5_process.md)

**Command**

```
{{- if .Command }}
  command: [{{ .Command | quote }}]
{{- end }}
```
**Args**

```
{{- if .Args }}
  args:
{{- range .Args }}
  - {{ . | quote }}
{{- end -}}
{{- end }}
```
**Ports** 

```
{{- if .Ports }}
  ports:
  - name: http
    containerPort: 80
{{- end }}
```

**Resource**

```
{{- if .Resources }}
  resources:
    requests:
      memory: {{ .Resources.memory.min | quote }}
      cpu: {{ .Resources.cpu.min | quote }}
    limits:
      memory: {{ .Resources.memory.max | quote }}
      cpu: {{ .Resources.cpu.max | quote }}
{{- end }}
```

**Probes**

```
{{- if .Probes }}
  livenessProbe:
    exec:
      command:
      {{- range .Probes.liveness }}
      - {{ . | quote }}
      {{- end }}
    initialDelaySeconds: 60
    timeoutSeconds: 60
  readinessProbe:
    exec:
      command:
      {{- range .Probes.readiness }}
      - {{ . | quote }}
      {{- end }}
    initialDelaySeconds: 20
    timeoutSeconds: 60
{{- end }}
```


#### `{{- define "jam.ct.containerVolumes" -}}`

```
{{- define "jam.ct.containerVolumes" -}}
- name: instance-volume
  configMap:
    name: instance
- name: secrets-volume
  secret:
    secretName: ct-secrets
- name: extranet-keys-volume
  secret:
    secretName: extranet
- name: master-sso-volume
  secret:
    secretName: master-sso
- name: saml-signing-external-volume
  secret:
    secretName: saml-signing-external
- name: opensocial-credentials-volume
  secret:
    secretName: opensocial
- name: realtime-credentials-volume
  secret:
    secretName: realtime
- name: microservices-tokens-volume
  secret:
    secretName: microservices
- name: media-credentials-volume
  secret:
    secretName: media
- name: stats-credentials-volume
  secret:
    secretName: stats
- name: rabbit-credentials-volume
  secret:
    secretName: rabbit
- name: rpush-certificate-volume
  secret:
    secretName: rpush-certificate
- name: box-keys-volume
  secret:
    secretName: box-keys
{{- end -}}
```

## jobs

### `init-ct.yaml`

```
{{- $ctParams := dict "Name" "init-ct" "Values" .Values}}
{{- $_ := set $ctParams "Command" "/data-init.sh" }}
{{- $_ := set $ctParams "Args" ((eq .Values.jam.initialize.data "production") | ternary (list "--production") (list "--site-admin")) }}
apiVersion: batch/v1
kind: Job
metadata:
  name: init-ct
  namespace: {{ .Values.jam.namespace }}
  annotations:
    "helm.sh/hook": pre-install
    "helm.sh/hook-delete-policy": "hook-succeeded,hook-failed"
    "helm.sh/hook-weight": "0"
spec:
  backoffLimit: 0
  template:
    metadata:
      annotations:
        "sidecar.istio.io/inject": "false"
    spec:
      containers:
{{ include "jam.ct.container" $ctParams | indent 6 }}
      volumes:
{{ include "jam.ct.containerVolumes" . | indent 6 }}
      imagePullSecrets:
      - name: registry
      restartPolicy: Never
```

`{{- $ctParams := dict "Name" "init-ct" "Values" .Values}}`

```
{{- $_ := set $ctParams "Command" "/data-init.sh" }}
{{- $_ := set $ctParams "Args" ((eq .Values.jam.initialize.data "production") | ternary (list "--production") (list "--site-admin")) }}
```

```
{{ include "jam.ct.container" $ctParams | indent 6 }}
```

```
{{ include "jam.ct.containerVolumes" . | indent 6 }}
```

**After `helm template ct/`**

```
containers:
- name: init-ct
  image: jam.docker.repositories.sapcdn.io/ct:lastStableBuild
  imagePullPolicy: Always
  command: ["/data-init.sh"]
```


### `migrate-ct.yaml`

```
{{- $ctParams := dict "Name" "migrate-ct-tasks-runner" "Values" .Values}}
{{- $_ := set $ctParams "Command" "/migrate.sh" }}
apiVersion: batch/v1
kind: Job
metadata:
  name: migrate-ct
  namespace: {{ .Values.jam.namespace }}
  annotations:
    "helm.sh/hook": pre-upgrade
    "helm.sh/hook-delete-policy": "hook-succeeded,hook-failed"
    "helm.sh/hook-weight": "0"
spec:
  backoffLimit: 0
  template:
    metadata:
      annotations:
        "sidecar.istio.io/inject": "false"
      name: migrate-ct
      labels:
        name: migrate-ct
    spec:
      restartPolicy: Never
      containers:
{{ include "jam.ct.container" $ctParams | indent 6 }}
      volumes:
{{ include "jam.ct.containerVolumes" . | indent 6 }}
      imagePullSecrets:
      - name: registry
```

```
{{- $ctParams := dict "Name" "migrate-ct-tasks-runner" "Values" .Values}}
{{- $_ := set $ctParams "Command" "/migrate.sh" }}
```

```
containers:
- name: migrate-ct-tasks-runner
  image: jam.docker.repositories.sapcdn.io/ct:lastStableBuild
  imagePullPolicy: Always
  command: ["/migrate.sh"]
```

### `deploy-task-ct.yaml`

```
{{- $ctParams := dict "Name" "deploy-tasks-ct-tasks-runner" "Values" .Values}}
{{- $_ := set $ctParams "Command" "/deploy_tasks.sh" }}
{{- $_ := set $ctParams "Args" (list (include "jam.release" .)) }}
apiVersion: batch/v1
kind: Job
metadata:
  name: deploy-tasks-ct
  namespace: {{ .Values.jam.namespace }}
  annotations:
    "helm.sh/hook": post-upgrade
    "helm.sh/hook-delete-policy": "hook-succeeded,hook-failed"
    "helm.sh/hook-weight": "0"
spec:
  backoffLimit: 0
  template:
    metadata:
      annotations:
        "sidecar.istio.io/inject": "false"
      name: deploy-tasks-ct
      labels:
        name: deploy-tasks-ct
    spec:
      restartPolicy: Never
      containers:
{{ include "jam.ct.container" $ctParams | indent 6 }}
      volumes:
{{ include "jam.ct.containerVolumes" . | indent 6 }}
      imagePullSecrets:
      - name: registry
```

```
{{- $ctParams := dict "Name" "deploy-tasks-ct-tasks-runner" "Values" .Values}}
{{- $_ := set $ctParams "Command" "/deploy_tasks.sh" }}
{{- $_ := set $ctParams "Args" (list (include "jam.release" .)) }}
```

```
containers:
- name: deploy-tasks-ct-tasks-runner
  image: jam.docker.repositories.sapcdn.io/ct:lastStableBuild
  imagePullPolicy: Always
  command: ["/deploy_tasks.sh"]
```


##  `deployment.yaml`

```
apiVersion: policy/v1beta1
kind: PodDisruptionBudget
metadata:
  name: ct-webapp-pdb
  namespace: {{ .Values.jam.namespace }}
spec:
  maxUnavailable: 0
  selector:
    matchLabels:
      app: ct
      mode: webapp

---
{{- $curl_health := list "curl" "--fail" "http://localhost/site/healthcheck" }}

{{- $ctParams := dict "Name" "ct" "Values" .Values}}
{{- $_ := set $ctParams "Ports" true }}
{{- $_ := set $ctParams "Resources" .Values.jam.ctWebapp.resources }}
{{- $_ := set $ctParams "Probes" (dict "liveness" $curl_health "readiness" $curl_health ) }}

apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: ct-webapp
  namespace: {{ .Values.jam.namespace }}
spec:
  replicas: {{ .Values.jam.ctWebapp.replicas }}
  template:
    metadata:
      labels:
        app: ct
        mode: webapp
    spec:
      containers:
{{ include "jam.ct.container" $ctParams | indent 6 }}
      volumes:
{{ include "jam.ct.containerVolumes" . | indent 6 }}
      imagePullSecrets:
      - name: registry

---

{{ if gt .Values.jam.ctWorker.replicas 0.0 }}

{{- /*
# pgrep (ps with grep) for processes named "bundle", comma separated
# use ps to generate a verbose list,
# chop off the ps header
# then grep for our specific worker script, surpress output and fail if no results
*/}}
{{- $grep_worker := list "bash" "-c" "pgrep -d, -x bundle | xargs -r ps -fp | tail -n +2 | grep -q script/single_worker.rb" }}

{{- $ctParams := dict "Name" "ct" "Values" .Values}}
{{- $_ := set $ctParams "Command" "/single_worker.sh" }}
{{- $_ := set $ctParams "Args" (list "$(DEFAULT_WORKER_QUEUE)") }}
{{- $_ := set $ctParams "Resources" .Values.jam.ctWorker.resources }}
{{- $_ := set $ctParams "Probes" (dict "liveness" $grep_worker "readiness" $grep_worker ) }}

# worker
#
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: ct-worker
  namespace: {{ .Values.jam.namespace }}
spec:
  replicas: {{ .Values.jam.ctWorker.replicas }}
  template:
    metadata:
      labels:
        app: ct
        mode: worker
    spec:
      containers:
{{ include "jam.ct.container" $ctParams | indent 6 }}
      volumes:
{{ include "jam.ct.containerVolumes" . | indent 6 }}
      imagePullSecrets:
      - name: registry

---
{{ end }}
{{ if gt .Values.jam.ctScheduler.replicas 0.0 }}

{{- /*
# pgrep (ps with grep) for processes named "ruby", comma separated
# use ps to generate a verbose list,
# chop off the ps header
# then grep for our specific clockwork script, surpress output and fail if no results
*/}}
{{- $grep_clockwork := list "bash" "-c" "pgrep -d, -x ruby | xargs -r ps -fp | tail -n +2 | grep -q script/clockwork.rb" }}

{{- $ctParams := dict "Name" "ct" "Values" .Values}}
{{- $_ := set $ctParams "Command" "/scheduler.sh" }}
{{- $_ := set $ctParams "Resources" .Values.jam.ctScheduler.resources }}
{{- $_ := set $ctParams "Probes" (dict "liveness" $grep_clockwork "readiness" $grep_clockwork ) }}

# Scheduler (clockwork trigger)
#
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: ct-scheduler
  namespace: {{ .Values.jam.namespace }}
spec:
  replicas:  {{ .Values.jam.ctScheduler.replicas }}
  template:
    metadata:
      labels:
        app: ct
        mode: scheduler
    spec:
      containers:
{{ include "jam.ct.container" $ctParams | indent 6 }}
      volumes:
{{ include "jam.ct.containerVolumes" . | indent 6 }}
      imagePullSecrets:
      - name: registry

---
{{ end }}
{{ if gt .Values.jam.ctRpush.replicas 0.0 }}

{{- /*
# pgrep (ps with grep) for processes named "bundle", comma separated
# use ps to generate a verbose list,
# chop off the ps header
# then grep for our specific rpush script, surpress output and fail if no results
*/}}
{{- $grep_rpush := list "bash" "-c" "pgrep -d, -x bundle | xargs -r ps -fp | tail -n +2 | grep -q rpush" }}

{{- $ctParams := dict "Name" "ct" "Values" .Values}}
{{- $_ := set $ctParams "Command" "/rpush.sh" }}
{{- $_ := set $ctParams "Resources" .Values.jam.ctRpush.resources }}
{{- $_ := set $ctParams "Probes" (dict "liveness" $grep_rpush "readiness" $grep_rpush ) }}
# Rpush
#
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: ct-rpush
  namespace: {{ .Values.jam.namespace }}
spec:
  replicas:  {{ .Values.jam.ctRpush.replicas }}
  template:
    metadata:
      labels:
        app: ct
        mode: rpush
    spec:
      containers:
{{ include "jam.ct.container" $ctParams | indent 6 }}
      volumes:
{{ include "jam.ct.containerVolumes" . | indent 6 }}
      imagePullSecrets:
      - name: registry
---
{{ end }}
```

### ct-webapp

```
{- $curl_health := list "curl" "--fail" "http://localhost/site/healthcheck" }}

{{- $ctParams := dict "Name" "ct" "Values" .Values}}
{{- $_ := set $ctParams "Ports" true }}
{{- $_ := set $ctParams "Resources" .Values.jam.ctWebapp.resources }}
{{- $_ := set $ctParams "Probes" (dict "liveness" $curl_health "readiness" $curl_health ) }}
```

```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: ct-webapp
  namespace: local700
spec:
  replicas: 3
  template:
    metadata:
      labels:
        app: ct
        mode: webapp
    spec:
      containers:
      - name: ct
        image: jam.docker.repositories.sapcdn.io/ct:lastStableBuild
        imagePullPolicy: Always
        ports:
        - name: http
          containerPort: 80
        resources:
          requests:
            memory: "2Gi"
            cpu: "4"
          limits:
            memory: "32Gi"
            cpu: "16"
        livenessProbe:
          exec:
            command:
            - "curl"
            - "--fail"
            - "http://localhost/site/healthcheck"
          initialDelaySeconds: 60
          timeoutSeconds: 60
        readinessProbe:
          exec:
            command:
            - "curl"
            - "--fail"
            - "http://localhost/site/healthcheck"
          initialDelaySeconds: 20
          timeoutSeconds: 60
```

### worker

```
{{- $grep_worker := list "bash" "-c" "pgrep -d, -x bundle | xargs -r ps -fp | tail -n +2 | grep -q script/single_worker.rb" }}

{{- $ctParams := dict "Name" "ct" "Values" .Values}}
{{- $_ := set $ctParams "Command" "/single_worker.sh" }}
{{- $_ := set $ctParams "Args" (list "$(DEFAULT_WORKER_QUEUE)") }}
{{- $_ := set $ctParams "Resources" .Values.jam.ctWorker.resources }}
{{- $_ := set $ctParams "Probes" (dict "liveness" $grep_worker "readiness" $grep_worker ) }}
```

```
# worker
#
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: ct-worker
  namespace: local700
spec:
  replicas: 5
  template:
    metadata:
      labels:
        app: ct
        mode: worker
    spec:
      containers:
      - name: ct
        image: jam.docker.repositories.sapcdn.io/ct:lastStableBuild
        imagePullPolicy: Always
        command: ["/single_worker.sh"]
        args:
        - "$(DEFAULT_WORKER_QUEUE)"
        resources:
          requests:
            memory: "2Gi"
            cpu: "4"
          limits:
            memory: "4Gi"
            cpu: "4"
        livenessProbe:
          exec:
            command:
            - "bash"
            - "-c"
            - "pgrep -d, -x bundle | xargs -r ps -fp | tail -n +2 | grep -q script/single_worker.rb"
          initialDelaySeconds: 60
          timeoutSeconds: 60
        readinessProbe:
          exec:
            command:
            - "bash"
            - "-c"
            - "pgrep -d, -x bundle | xargs -r ps -fp | tail -n +2 | grep -q script/single_worker.rb"
          initialDelaySeconds: 20
          timeoutSeconds: 60
```

### ct-scheduler

```
{{- /*
# pgrep (ps with grep) for processes named "ruby", comma separated
# use ps to generate a verbose list,
# chop off the ps header
# then grep for our specific clockwork script, surpress output and fail if no results
*/}}
{{- $grep_clockwork := list "bash" "-c" "pgrep -d, -x ruby | xargs -r ps -fp | tail -n +2 | grep -q script/clockwork.rb" }}

{{- $ctParams := dict "Name" "ct" "Values" .Values}}
{{- $_ := set $ctParams "Command" "/scheduler.sh" }}
{{- $_ := set $ctParams "Resources" .Values.jam.ctScheduler.resources }}
{{- $_ := set $ctParams "Probes" (dict "liveness" $grep_clockwork "readiness" $grep_clockwork ) }}
```

```
# Scheduler (clockwork trigger)
#
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: ct-scheduler
  namespace: local700
spec:
  replicas:  1
  template:
    metadata:
      labels:
        app: ct
        mode: scheduler
    spec:
      containers:
      - name: ct
        image: jam.docker.repositories.sapcdn.io/ct:lastStableBuild
        imagePullPolicy: Always
        command: ["/scheduler.sh"]
        livenessProbe:
          exec:
            command:
            - "bash"
            - "-c"
            - "pgrep -d, -x ruby | xargs -r ps -fp | tail -n +2 | grep -q script/clockwork.rb"
          initialDelaySeconds: 60
          timeoutSeconds: 60
        readinessProbe:
          exec:
            command:
            - "bash"
            - "-c"
            - "pgrep -d, -x ruby | xargs -r ps -fp | tail -n +2 | grep -q script/clockwork.rb"
          initialDelaySeconds: 20
          timeoutSeconds: 60
```

### Rpush

```
{{- $grep_rpush := list "bash" "-c" "pgrep -d, -x bundle | xargs -r ps -fp | tail -n +2 | grep -q rpush" }}

{{- $ctParams := dict "Name" "ct" "Values" .Values}}
{{- $_ := set $ctParams "Command" "/rpush.sh" }}
{{- $_ := set $ctParams "Resources" .Values.jam.ctRpush.resources }}
{{- $_ := set $ctParams "Probes" (dict "liveness" $grep_rpush "readiness" $grep_rpush ) }}
```

```
# Rpush
#
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: ct-rpush
  namespace: local700
spec:
  replicas:  1
  template:
    metadata:
      labels:
        app: ct
        mode: rpush
    spec:
      containers:
      - name: ct
        image: jam.docker.repositories.sapcdn.io/ct:lastStableBuild
        imagePullPolicy: Always
        command: ["/rpush.sh"]
        livenessProbe:
          exec:
            command:
            - "bash"
            - "-c"
            - "pgrep -d, -x bundle | xargs -r ps -fp | tail -n +2 | grep -q rpush"
          initialDelaySeconds: 60
          timeoutSeconds: 60
        readinessProbe:
          exec:
            command:
            - "bash"
            - "-c"
            - "pgrep -d, -x bundle | xargs -r ps -fp | tail -n +2 | grep -q rpush"
          initialDelaySeconds: 20
          timeoutSeconds: 60
```
 
## Service.yaml

```
# ----- [ CT ] --------------------
#
apiVersion: v1
kind: Service
metadata:
  name: ct-webapp
  namespace: {{ .Values.jam.namespace }}
  labels:
    app: ct
    mode: webapp
spec:
  selector:
    app: ct
    mode: webapp
  ports:
  - name: http
    protocol: TCP
    port: 80
    targetPort: 80
```

* `namespace: local700`
 
 



