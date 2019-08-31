# Application 5: Profile Sync（PS)

**It will also migrate PS database**

```
$ tree ps/
ps/
├── Chart.yaml
├── templates
│   ├── _helper.tpl
│   ├── _ps.tpl
│   ├── deployment.yaml
│   ├── migrate-ps.yaml
│   └── service.yaml
└── values.yaml

1 directory, 7 files
```

## `values.yaml`

```
jam:
  namespace: local700
  releaseContainerSuffix: ""
  nonce: 1
registry:
  url: jam.docker.repositories.sapcdn.io
```

## templates

* `_helper.tpl`
* `_ps.tpl` 


### `_ps.tpl`

#### `containerEnv` and `containerVolumes`

* `jam.ps.containerEnv`: `{{- define "jam.ps.containerEnv" -}}`
* `jam.ps.containerVolumes`: `{{- define "jam.ps.containerVolumes" -}}`

```
{{- define "jam.ps.containerEnv" -}}
envFrom:
- secretRef:
    name: db-ps
    # database credentials
- secretRef:
    name: email
    # smtp credentials
env:
- name: EXTERNAL_HOST_NAME
  valueFrom:
    configMapKeyRef:
      name: cluster-static
      key: EXTERNAL_HOST_NAME
- name: MYSQL_PS_DB
  valueFrom:
    configMapKeyRef:
      name: data
      key: MYSQL_PS_DB
- name: NONCE
  value: {{ .Values.jam.nonce | quote }}
- name: RAILS_ENV
  value: production
- name: ISDOCKER
  value: "1"
- name: ISK8S
  value: "1"
- name: CT_LOCATION
  value: ct-webapp
- name: INSTANCE
  value: {{ .Values.jam.namespace }}
- name: SMTP_TLS
  value: "1"
volumeMounts:
- name: instance-volume
  mountPath: /app/config/deploy/instances
- name: secrets-volume
  mountPath: /etc/cubetree
{{- end -}}
{{- define "jam.ps.containerVolumes" -}}
volumes:
  - name: instance-volume
    configMap:
      name: instance
  - name: secrets-volume
    secret:
      secretName: ct-secrets
imagePullSecrets:
  - name: registry
{{- end -}}
```

## The hook: `migrate-ps.yaml`

```
apiVersion: batch/v1
kind: Job
metadata:
  name: migrate-ps
  namespace: {{ .Values.jam.namespace }}
  annotations:
    "helm.sh/hook": pre-install,pre-upgrade
    "helm.sh/hook-delete-policy": "hook-succeeded,hook-failed"
    "helm.sh/hook-weight": "0"
spec:
  backoffLimit: 0
  template:
    metadata:
      annotations:
        "sidecar.istio.io/inject": "false"
      name: migrate-ps
      labels:
        name: migrate-ps
    spec:
      restartPolicy: Never
      containers:
      - name: migrate-ps-tasks-runner
        image: {{ .Values.registry.url }}/ps{{ .Values.jam.releaseContainerSuffix }}:{{ include "jam.release" . }}
        command: ["/migrate.sh"]
{{ include "jam.ps.containerEnv" . | indent 8 }}
{{ include "jam.ps.containerVolumes" . | indent 6 }}
```

* [`Helm Hooks` 的使用](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_helm7_hook.md)

* 预安装`pre-install`：在模板渲染后，kubernetes 创建任何资源之前执行
* 升级前`pre-upgrade`：在模板渲染后，但在任何资源升级之前执行

#### Delete policy

```
"helm.sh/hook-delete-policy": "hook-succeeded,hook-failed"
```

所以，如果我们在 `hook` 中创建了资源，那么不能依赖`helm delete`去删除资源，因为 hook 创建的资源已经不受控制了，要销毁这些资源，需要在`pre-delete`或者`post-delete`这两个 `hook` 函数中去执行相关操作，或者将`helm.sh/hook-delete-policy`这个 `annotation` 添加到 `hook` 模板文件中。

#### Pod backoff failure policy: `.spec.backoffLimit`

There are situations where you want to fail a Job after some amount of retries due to a logical error in configuration etc. 

To do so, set `.spec.backoffLimit` to specify the number of retries before considering a Job as failed. **The back-off limit is set by default to `6`.** 

Failed Pods associated with the Job are recreated by the Job controller with an exponential back-off delay `(10s, 20s, 40s …)` capped at six minutes. The back-off count is reset if no new failed Pods appear before the Job’s next status check.

* `backoffLimit: 0`

* `annotations: "sidecar.istio.io/inject": "false"`
* `image: {{ .Values.registry.url }}/ps{{ .Values.jam.releaseContainerSuffix }}:{{ include "jam.release" . }}`

* `image: jam.docker.repositories.sapcdn.io/ps:lastStableBuild`


## `deployment.yaml`

```

---
#
# ----- [ PS ] --------------------
#
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: ps
  namespace: {{ .Values.jam.namespace }}
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: ps
    spec:
      containers:
      - name: ps
        image: {{ .Values.registry.url }}/ps{{ .Values.jam.releaseContainerSuffix }}:{{ include "jam.release" . }}
        imagePullPolicy: Always
        livenessProbe:
          exec:
            command: ["curl", "--fail", "http://localhost/health/diagnose"]
          initialDelaySeconds: 60
          timeoutSeconds: 60
        readinessProbe:
          exec:
            command: ["curl", "--fail", "http://localhost/health/diagnose"]
          initialDelaySeconds: 20
          timeoutSeconds: 60
{{ include "jam.ps.containerEnv" . | indent 8 }}
{{ include "jam.ps.containerVolumes" . | indent 6 }}
```


* `{{ include "jam.ps.containerEnv" . | indent 8 }}`
* `{{ include "jam.ps.containerVolumes" . | indent 6 }}`

## `service.yaml`

```
---
# ----- [ PS ] --------------------
#
apiVersion: v1
kind: Service
metadata:
  name: ps
  namespace: {{ .Values.jam.namespace }}
spec:
  selector:
    app: ps
  ports:
  - name: http
    protocol: TCP
    port: 3001
    targetPort: 80
```

