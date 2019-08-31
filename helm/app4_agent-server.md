# Application 4: Aggent-Server


```
$ tree agent-server/
agent-server/
├── Chart.yaml
├── templates
│   ├── _agentserver_env.tpl
│   ├── _antiaffinity.tpl
│   ├── _helper.tpl
│   ├── realtime-deployment.yaml
│   ├── service.yaml
│   └── webhook-statefulset.yaml
└── values.yaml

1 directory, 8 files
```


## `values.yaml`

```
jam:
  namespace: local700
  releaseContainerSuffix: ""
  nonce: 1
  agentserver:
    webhook:
      replicas: 2
    realtime:
      replicas: 3
registry:
  url: jam.docker.repositories.sapcdn.io
```

### `Special Values`

* `agentserver.webhook.replicas: 2`
* `agentserver.realtime.replicas: 3`


## `templates/_agentserver_env.tpl`

### templates

* `_agentserver_env.tpl`
* `_antiaffinity.tpl`
* `_helper.tpl`

```
{{- define "jam.agentserver.containerEnv" }}
  envFrom:
  - secretRef:
      name: realtime
      # ct_agent_shared_secret
  env:
  - name: NONCE
    value: {{ .Values.jam.nonce | quote }}
  - name: MY_POD_NAME
    valueFrom:
      fieldRef:
        fieldPath: metadata.name
  - name: MY_POD_IP
    valueFrom:
      fieldRef:
        fieldPath: status.podIP
  - name: RABBIT_USERNAME
    valueFrom:
      secretKeyRef:
        name: rabbit
        key: username
  - name: RABBIT_PASSWORD
    valueFrom:
      secretKeyRef:
        name: rabbit
        key: password
  livenessProbe:
    exec:
      command: ["curl", "--fail", "http://localhost:7200/loadbalancer.html"]
    initialDelaySeconds: 60
    timeoutSeconds: 10
  readinessProbe:
    exec:
      command: ["curl", "--fail", "http://localhost:7200/loadbalancer.html"]
    initialDelaySeconds: 20
    timeoutSeconds: 10
imagePullSecrets:
  - name: registry
{{- end }}
```

```
env:
- name: NONCE
  value: "1"
```

### Pod infos: `metadata.name` and `status.podIP`

```
- name: MY_POD_NAME
  valueFrom:
    fieldRef:
      fieldPath: metadata.name
```



### RABBIT `username` and `password`

```
- name: RABBIT_USERNAME
  valueFrom:
    secretKeyRef:
      name: rabbit
      key: username
```

```
- name: RABBIT_PASSWORD
  valueFrom:
    secretKeyRef:
      name: rabbit
      key: password
```

## `agent-server-webhook`

```
---
#
# ----- [ Agent Server ] --------------------
#

# agent-server-webhook
#
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: agent-server-webhook
  namespace: {{ .Values.jam.namespace }}
spec:
  serviceName: agent-server-webhook
  replicas: {{ include "jam.webhookReplicas" . }}
  selector:
    matchLabels:
      service: agent-server-webhook
  template:
    metadata:
      labels:
        app: agent-server
        mode: webhook
        service: agent-server-webhook
    spec:
      containers:
      - name: agent-server
        image: {{ .Values.registry.url }}/agent-server{{ .Values.jam.releaseContainerSuffix }}:{{ include "jam.release" . }}
        imagePullPolicy: Always
        command: ["java"]
        args: ["-Xmx2g",
          "-Dsapjam.secret.fromEnvironment=true",
          "-Dsapjam.rabbitmq.user.keyName=RABBIT_USERNAME",
          "-Dsapjam.rabbitmq.password.keyName=RABBIT_PASSWORD",
          "-Dsapjam.secret.masterKey.keyName=ct_agent_shared_secret",
          "-Dsapjam.agents.web.requireSSL=",
          "-Dsapjam.agents.web.loadbalancerCheck.filePath=/app/loadbalancer.html",
          "-Dsapjam.agents.presenceHub.persistentAgentId=$(MY_POD_NAME)",
          "-Dsapjam.rabbitmq.ha.hosts=rabbitmq-ha",                       # rabbitmq ha service frontend
          "-Dsapjam.rabbitmq.transient.hosts=rabbitmq-transient",         # rabbitmq transient service frontend
          "-Dsapjam.agents.webhookHub.clusterSize=-1",
          "-Djava.io.tmpdir=/app/deployed-tmp",
          "-jar",
          "/app/agent-server-0.0.1-SNAPSHOT.jar"
        ]
{{ include "jam.agentserver.containerEnv" . | indent 6 }}
# [END agent deployment]
---
```

* `namespace: {{ .Values.jam.namespace }}`: `namespace: local700`
* `replicas: {{ include "jam.webhookReplicas" . }}`: `replicas: 2`
* `image: {{ .Values.registry.url }}/agent-server{{ .Values.jam.releaseContainerSuffix }}:{{ include "jam.release" . }}`: `image: jam.docker.repositories.sapcdn.io/agent-server:lastStableBuild`


## `realtime-deployment.yaml`

```
---
#
# ----- [ Agent Server ] --------------------
#

# agent-server-realtime
#
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: agent-server-realtime
  namespace: {{ .Values.jam.namespace }}
spec:
  replicas: {{ include "jam.realtimeReplicas" . }}
  template:
    metadata:
      labels:
        app: agent-server
        mode: realtime
    spec:
{{ include "jam.antiaffinity" "agent-server-realtime" | indent 6 }}
      containers:
      - name: agent-server
        image: {{ .Values.registry.url }}/agent-server{{ .Values.jam.releaseContainerSuffix }}:{{ include "jam.release" . }}
        imagePullPolicy: Always
        command: ["java"]
        args: ["-Xmx2g",
          "-Dsapjam.secret.fromEnvironment=true",
          "-Dsapjam.rabbitmq.user.keyName=RABBIT_USERNAME",
          "-Dsapjam.rabbitmq.password.keyName=RABBIT_PASSWORD",
          "-Dsapjam.secret.masterKey.keyName=ct_agent_shared_secret",
          "-Dsapjam.agents.web.requireSSL=",
          "-Dsapjam.agents.web.loadbalancerCheck.filePath=/app/loadbalancer.html",
          "-Dsapjam.agents.presenceHub.persistentAgentId=$(MY_POD_IP)",
          "-Dsapjam.rabbitmq.ha.hosts=rabbitmq-ha",                       # rabbitmq ha service frontend
          "-Dsapjam.rabbitmq.transient.hosts=rabbitmq-transient",         # rabbitmq transient service frontend
          "-Djava.io.tmpdir=/app/deployed-tmp",
          "-jar",
          "/app/agent-server-0.0.1-SNAPSHOT.jar"
        ]
{{ include "jam.agentserver.containerEnv" . | indent 6 }}
```

## `service.yaml`

```
---
# ----- [ Agent Server ] --------------------
#
apiVersion: v1
kind: Service
metadata:
  name: agent-server-realtime
  namespace: {{ .Values.jam.namespace }}
spec:
  selector:
    app: agent-server
    mode: realtime
  ports:
  - name: http
    protocol: TCP
    port: 7200
    targetPort: 7200
```

