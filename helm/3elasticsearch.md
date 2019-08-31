# ElasticSearch and ElasticSearch6

## ElasticSearch

### `values.yaml`

```
jam:
  namespace: local700
  deploymentLandscape: aws
  elasticsearch:
    #Number of elastic search replicas desired
    replicas: 1
    storageClassName: standard
    jvm: # -Xms, -Xmx
      min: 1g
      max: 2g
    resources:
      memory:
        min: 1Gi
        max: 4Gi
    pvcStorage: 5Gi
registry:
  url: jam.docker.repositories.sapcdn.io
```

### `templates/_heper.tpl` 

```
{{- define "jam.esReplicas" -}}
{{- .Values.jam.elasticsearch.replicas | default 3 -}}
{{- end -}}
```

**`.Values.jam.elasticsearch.replicas=3`**

### `service.yaml`

```
---
# ----- [ elasticsearch ] --------------------
#
apiVersion: v1
kind: Service
metadata:
  name: elasticsearch
  namespace: {{ .Values.jam.namespace }}
  labels:
    service: elasticsearch
spec:
  clusterIP: None
  ports:
  - port: 9200
    name: serving
  - port: 9300
    name: node-to-node
  selector:
    service: elasticsearch
```

### `deployment.yaml`

```

---
# ----- [ elasticsearch ] --------------------
#
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: elasticsearch
  namespace: {{ .Values.jam.namespace }}
  labels:
    service: elasticsearch
spec:
  serviceName: elasticsearch
  replicas: {{ include "jam.esReplicas" . }}
  selector:
    matchLabels:
      service: elasticsearch
  template:
    metadata:
      labels:
        service: elasticsearch
    spec:
      terminationGracePeriodSeconds: 300
      initContainers:
      # NOTE:
      # This is to fix the permission on the volume
      # By default elasticsearch container is not run as
      # non root user.
      # https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html#_notes_for_production_use_and_defaults
      - name: fix-the-volume-permission
        image: busybox
        command:
        - sh
        - -c
        - chown -R 1000:1000 /usr/share/elasticsearch/data
        securityContext:
          privileged: true
        volumeMounts:
        - name: data
          mountPath: /usr/share/elasticsearch/data
      # NOTE:
      # To increase the default vm.max_map_count to 262144
      # https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html#docker-cli-run-prod-mode
      - name: increase-the-vm-max-map-count
        image: busybox
        command:
        - sysctl
        - -w
        - vm.max_map_count=262144
        securityContext:
          privileged: true
      # To increase the ulimit
      # https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html#_notes_for_production_use_and_defaults
      - name: increase-the-ulimit
        image: busybox
        command:
        - sh
        - -c
        - ulimit -n 65536
        securityContext:
          privileged: true
      containers:
      - name: elasticsearch
        image: {{ .Values.registry.url }}/elasticsearch:master
        imagePullPolicy: Always
        command: ["elasticsearch"]
        # this is broken.
        # we should be able to go with multicast and not need an explicit list of hosts here
        # refer to the es-statefulset in our elk stack. clearly works in es 6.2+
        args:
        - "--cluster.name=$(NAMESPACE)-search-cluster"
        - "--node.name=$(node.name)"
        {{- $namespace := .Values.jam.namespace }}
        - "--discovery.zen.ping.unicast.hosts={{range $i, $e := until (int (include "jam.esReplicas" .)) }}{{if ne 0 $i }},{{end}}elasticsearch-{{ . }}.elasticsearch.{{ $namespace }}.svc.cluster.local{{ end }}"
        - "--discovery.zen.minimum_master_nodes={{ div (include "jam.esReplicas" .) 2 | add 1 }}"
        - "-Xms{{ .Values.jam.elasticsearch.jvm.min }}"
        - "-Xmx{{ .Values.jam.elasticsearch.jvm.max }}"
        ports:
        - containerPort: 9200
          name: http
        - containerPort: 9300
          name: tcp
        resources:
          requests:
            memory: {{ .Values.jam.elasticsearch.resources.memory.min | quote }}
          limits:
            memory: {{ .Values.jam.elasticsearch.resources.memory.max | quote }}
        env:
        - name: NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: node.name
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        volumeMounts:
        - name: data
          mountPath: /usr/share/elasticsearch/data
      imagePullSecrets:
        - name: registry
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes:
        - ReadWriteOnce
      storageClassName: {{ .Values.jam.elasticsearch.storageClassName }}
      resources:
        requests:
          storage: {{ .Values.jam.elasticsearch.pvcStorage | quote }}
```

* `replicas: {{ include "jam.esReplicas" . }}`
* `image: {{ .Values.registry.url }}/elasticsearch:master`
* `{{- $namespace := .Values.jam.namespace }}`


```
- "--discovery.zen.ping.unicast.hosts={{range $i, $e := until (int (include "jam.esReplicas" .)) }}{{if ne 0 $i }},{{end}}elasticsearch-{{ . }}.elasticsearch.{{ $namespace }}.svc.cluster.local{{ end }}"
```


###

```
- "--discovery.zen.minimum_master_nodes={{ div (include "jam.esReplicas" .) 2 | add 1 }}"
```



```
discover.zen.minimum_master_nodes=N/2+1
3 / 2 + 1
```

```
discovery.zen.minimum_master_nodes

{{range $i, $e := until (int (include "jam.esReplicas" .)) }}
{{if ne 0 $i }}
,
{{end}}
elasticsearch-{{ . }}.elasticsearch.{{ $namespace }}.svc.cluster.local
{{ end }}
```

* `storageClassName: {{ .Values.jam.elasticsearch.storageClassName }}`
* `storage: {{ .Values.jam.elasticsearch.pvcStorage | quote }}`


## ElasticSearch6

### `values.yaml`

```
jam:
  namespace: local700
  releaseContainerSuffix: ""
  deploymentLandscape: aws
registry:
  url: jam.docker.repositories.sapcdn.io
```

### `service.yaml`

```
apiVersion: v1
kind: Service
metadata:
  name: elasticsearch-jam
  namespace: {{ .Values.jam.namespace }}
  labels:
    k8s-app: elasticsearch-logging
spec:
  clusterIP: None
  ports:
  - port: 9200
    protocol: TCP
    targetPort: db
    name: api
  - port: 9300
    name: node-to-node
  selector:
    k8s-app: elasticsearch-jam
```

### `tepmplates/deployment.yaml`

```
# Elasticsearch deployment itself
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: elasticsearch-jam
  namespace: {{ .Values.jam.namespace }}
  labels:
    k8s-app: elasticsearch-jam
spec:
  serviceName: elasticsearch-jam
  replicas: {{ .Values.jam.elasticsearch6.replicas }}
  selector:
    matchLabels:
      k8s-app: elasticsearch-jam
  template:
    metadata:
      annotations:
        "sidecar.istio.io/inject": "false"
      labels:
        k8s-app: elasticsearch-jam
    spec:
      containers:
      - image: {{ .Values.registry.url }}/elasticsearch6:master
        name: elasticsearch-jam
        resources:
          # need more cpu upon initialization, therefore burstable class
          limits:
            cpu: 1000m
          requests:
            cpu: 100m
          requests:
            memory: {{ .Values.jam.elasticsearch6.resources.memory.min }}
          limits:
            memory: {{ .Values.jam.elasticsearch6.resources.memory.max }}
        ports:
        - containerPort: 9200
          name: db
          protocol: TCP
        - containerPort: 9300
          name: transport
          protocol: TCP
        volumeMounts:
        - name: es6-jam-data
          mountPath: /usr/share/elasticsearch/data
        env:
        - name: ES_JAVA_OPTS
          value: "-Xms{{ .Values.jam.elasticsearch6.jvm.min }} -Xmx{{ .Values.jam.elasticsearch6.jvm.max }}"
        - name: NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: POD_IP
          valueFrom:
            fieldRef:
              fieldPath: status.podIP
        - name: cluster.name
          value: elasticsearch-${NAMESPACE}
        - name: node.name
          value: ${POD_NAME}-${NAMESPACE}
        - name: transport.host
          value: ${POD_IP}
        - name: discovery.zen.ping.unicast.hosts
          value: elasticsearch-jam
        - name: discovery.zen.minimum_master_nodes
          value: {{ div .Values.jam.elasticsearch6.replicas 2 | add 1 | quote }}
        #- name: bootstrap.memory_lock
        #  value: "true"
        - name: gateway.recover_after_nodes
          value: {{ div .Values.jam.elasticsearch6.replicas 2 | add 1 | quote }}
        - name: gateway.expected_nodes
          value: {{ .Values.jam.elasticsearch6.replicas | quote }}
        - name: gateway.recover_after_time
          value: 5m
      # Elasticsearch requires vm.max_map_count to be at least 262144.
      # If your OS already sets up this number to a higher value, feel free
      # to remove this init container.
      initContainers:
      - image: alpine:3.6
        command: ["/sbin/sysctl", "-w", "vm.max_map_count=262144"]
        name: elasticsearch-jam-init-max-map
        securityContext:
          privileged: true
      - image: alpine:3.6
        command: ["chown", "-R", "1000:1000","/usr/share/elasticsearch/data"]
        name: elasticsearch-jam-init-chown
        volumeMounts:
        - name: es6-jam-data
          mountPath: /usr/share/elasticsearch/data
        securityContext:
          privileged: true
      imagePullSecrets:
      - name: registry
  volumeClaimTemplates:
  - metadata:
      name: es6-jam-data
    spec:
      accessModes:
        - ReadWriteOnce
      storageClassName: {{ .Values.jam.elasticsearch6.storageClassName }}
      resources:
        requests:
          storage: {{ .Values.jam.elasticsearch6.pvcStorage }}
```

```
- name: discovery.zen.minimum_master_nodes
  value: {{ div .Values.jam.elasticsearch6.replicas 2 | add 1 | quote }} 
```

```
env:
- name: ES_JAVA_OPTS
  value: "-Xms{{ .Values.jam.elasticsearch6.jvm.min }} -Xmx{{ .Values.jam.elasticsearch6.jvm.max }}"
```

```
- name: POD_NAME
  valueFrom:
    fieldRef:
      fieldPath: metadata.name
```
              