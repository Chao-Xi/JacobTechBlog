# Send Log from EFK to S3 Bucket

## Overview

We use EFK (elasticsearch, fluentd, kibana) as our logging system in jam multicloud. Fluentd is deployed as daemonset to each node in a jam k8s cluster, collect the logs in the node and sync the logs to elasticsearch and s3 bucket. Elasticsearch receive the logs from fluentd and store them in its own local storage. We can use elasticsearch to search and analytics the logs and see the logs in kibana easily.


## Create S3 bucket with terraform for storing 

### `main.tf`

* `"aws_s3_bucket"`: `"jam-logging"`
* `"aws_iam_user"`: `"jam-logging"`
* `"aws_iam_access_key"`: `"jam-logging"`
* `"aws_iam_user_policy"`: `"jam-logging_policy"`



```
terraform {
  backend "s3" {
    bucket               = "jam-terraform-backend"
    key                  = "tfstate"
    region               = "ap-southeast-1"
    dynamodb_table       = "terraform_lock"
    workspace_key_prefix = "logging"
  }
}


resource "aws_s3_bucket" "jam-logging" {
  bucket = var.bucket_name
  region = var.region

  lifecycle_rule {
    id      = "log"
    enabled = true

    prefix = "log/"

    tags = {
      "rule"      = "log"
      "autoclean" = "true"
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    expiration {
      days = 180
    }
  }
}

resource "aws_iam_user" "jam-logging" {
  name = "${aws_s3_bucket.jam-logging.id}"
}

resource "aws_iam_access_key" "jam-logging" {
  user = "${aws_iam_user.jam-logging.name}"
}

resource "aws_iam_user_policy" "jam-logging_policy" {
  name = "${aws_s3_bucket.jam-logging.id}"
  user = "${aws_iam_user.jam-logging.name}"


  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [{
		"Sid": "VisualEditor0",
		"Effect": "Allow",
		"Action": ["s3:ListAllMyBuckets", "s3:HeadBucket"],
		"Resource": "*"
	}, {
		"Sid": "VisualEditor1",
		"Effect": "Allow",
		"Action": "s3:*",
		"Resource": ["${aws_s3_bucket.jam-logging.arn}", "${aws_s3_bucket.jam-logging.arn}/*"]
	}]
}
EOF
}
```

### `var.tf`

```
variable "region" {
  type    = string
  default = "eu-central-1"
}
variable "bucket_name" {
  type    = string
  default = "jam-logging-multicloud"
}
```

### `output.tf`

```
output "jam-logging_access_key_id" {
  value       = "${aws_iam_access_key.jam-logging.id}"
  description = "The access key for jam-logging bucket, need to be configured in secrets."
}

output "jam-logging_access_secret" {
  value       = "${aws_iam_access_key.jam-logging.encrypted_secret}"
  sensitive   = true
  description = "The access key secret for jam-logging bucket, need to be configured in secrets."
}
```


## Deploying the EFK Stack

### Get the access key for the logging s3 bucket

The access key and s3 bucket was created by terraform, we can use below command to get the access key id and secret. Run the command in `logging/aws` folder of `orchestrated-jam` project. Save the result in `kustomize/bases/logging/log-bucket.yaml`, but don't commit the change to github.

```
terraform state pull | jq '.resources[0].instances[0].attributes.id'
terraform state pull | jq '.resources[0].instances[0].attributes.secret'
```

## Seal the access key and apply to k8s cluster

Seal the `kustomize/bases/logging/log-bucket.yaml` to the path created by loader script in previous step, the path looks like `stage/aws/701/secrets`, then apply it to your jam k8s cluster.

```
$ kubeseal -n logging -o yaml <kustomize/bases/logging/log-bucket.yaml > path/sealed-log-bucket.yaml

$ kubectl apply -f path/sealed-log-bucket.yaml
```

**`log-bucket.yaml`**


```
# Guard access to the s3 log object store.
apiVersion: v1
kind: Secret
metadata:
  name: log-bucket
stringData:
  # Created by terraform, to get: `terraform state show aws_iam_access_key.jam-logging`
  # Or terraform state pull | jq '.resources[0].instances[0].attributes.id' for LOG_BUCKET_KEY in logging/aws folder of this project
  # And terraform state pull | jq '.resources[0].instances[0].attributes.secret' for LOG_BUCKET_SECRET  in logging/aws folder of this project
  LOG_BUCKET_KEY: aws_iam_access_key.id
  LOG_BUCKET_SECRET: aws_iam_access_key.secret
  LOG_BUCKET_NAME: jam-logging-multicloud
  LOG_BUCKET_REGION: eu-central-1
```

## install the efk stack


```
$ tree logging/
logging/
├── Chart.yaml
├── templates
│   ├── es-index-rotator.yaml
│   ├── es-service.yaml
│   ├── es-statefulset.yaml
│   ├── fluentd-es-configmap.yaml
│   ├── fluentd-es-ds.yaml
│   ├── kibana-deployment.yaml
│   └── kibana-service.yaml
└── values.yaml

1 directory, 9 files
```

### `values.yaml`

```
logging:
  elasticsearch:
    replicas: 5
    storageClassName: default
    resources:
      memory:
        min: 8Gi
        max: 16Gi
    pvcStorage: 100Gi
    # Default days that logs kept in elasticsearch of logging
    logRotateDays: 15
    # Default run time of logging rotate cron job
    logRotateSchedule: "03 16 */1 * *"
  fluentd:
    s3PluginVersion: 1.3.0
```

## ElasticSearch

### 1.`es-index-rotator.yaml` for log rotate

```
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: es-index-rotator
  namespace: logging
spec:
  schedule: {{ .Values.logging.elasticsearch.logRotateSchedule | quote }}
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: es-index-rotator
            image: jam.docker.repositories.sapcdn.io/sles12sp1:B1811
            command: ["/bin/sh", "-c"]
            args: ["for day in $(curl elasticsearch-logging:9200/_cat/indices? 2>&1|grep logstash|cut -d' ' -f3|cut -d'-' -f2|sort -r|tail -n +$LOG_ROTATE_DAYS) ; do curl -X DELETE elasticsearch-logging:9200/logstash-$day; done"]
            env:
              - name: LOG_ROTATE_DAYS
                value: {{ .Values.logging.elasticsearch.logRotateDays | quote }}
          restartPolicy: OnFailure
          imagePullSecrets:
          - name: registry
  concurrencyPolicy: Forbid
  successfulJobsHistoryLimit: 2
  failedJobsHistoryLimit: 1
```

### 2.`es-service.yaml`

```
apiVersion: v1
kind: Service
metadata:
  name: elasticsearch-logging
  namespace: logging
  labels:
    k8s-app: elasticsearch-logging
    kubernetes.io/cluster-service: "true"
    kubernetes.io/name: "Elasticsearch"
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
    k8s-app: elasticsearch-logging
```

### 3.`es-statefulset.yaml`

```
# RBAC authn and authz
apiVersion: v1
kind: ServiceAccount
metadata:
  name: elasticsearch-logging
  namespace: logging
  labels:
    k8s-app: elasticsearch-logging
    kubernetes.io/cluster-service: "true"
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: elasticsearch-logging
  labels:
    k8s-app: elasticsearch-logging
    kubernetes.io/cluster-service: "true"
rules:
- apiGroups:
  - ""
  resources:
  - "services"
  - "namespaces"
  - "endpoints"
  verbs:
  - "get"
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: logging
  name: elasticsearch-logging
  labels:
    k8s-app: elasticsearch-logging
    kubernetes.io/cluster-service: "true"
subjects:
- kind: ServiceAccount
  name: elasticsearch-logging
  namespace: logging
  apiGroup: ""
roleRef:
  kind: ClusterRole
  name: elasticsearch-logging
  apiGroup: "rbac.authorization.k8s.io"
---
# Elasticsearch deployment itself
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: elasticsearch-logging
  namespace: logging
  labels:
    k8s-app: elasticsearch-logging
    version: v6.6.0
    kubernetes.io/cluster-service: "true"
spec:
  serviceName: elasticsearch-logging
  replicas: {{ .Values.logging.elasticsearch.replicas }}
  selector:
    matchLabels:
      k8s-app: elasticsearch-logging
      version: v6.6.0
  template:
    metadata:
      labels:
        k8s-app: elasticsearch-logging
        version: v6.6.0
        kubernetes.io/cluster-service: "true"
    spec:
      serviceAccountName: elasticsearch-logging
      containers:
      - image: docker.elastic.co/elasticsearch/elasticsearch-oss:6.6.0
        name: elasticsearch-logging
        resources:
          # need more cpu upon initialization, therefore burstable class
          limits:
            cpu: 1000m
          requests:
            cpu: 100m
          requests:
            memory: {{ .Values.logging.elasticsearch.resources.memory.min }}
          limits:
            memory: {{ .Values.logging.elasticsearch.resources.memory.max }}
        ports:
        - containerPort: 9200
          name: db
          protocol: TCP
        - containerPort: 9300
          name: transport
          protocol: TCP
        volumeMounts:
        - name: es-logging-data
          mountPath: /usr/share/elasticsearch/data
        env:
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
          value: elasticsearch-logging
        - name: discovery.zen.minimum_master_nodes
          value: {{ div .Values.logging.elasticsearch.replicas 2 | add 1 | quote }}
        #- name: bootstrap.memory_lock
        #  value: "true"
        - name: gateway.recover_after_nodes
          value: {{ div .Values.logging.elasticsearch.replicas 2 | add 1 | quote }}
        - name: gateway.expected_nodes
          value: {{ .Values.logging.elasticsearch.replicas | quote }}
        - name: gateway.recover_after_time
          value: 5m
      # Elasticsearch requires vm.max_map_count to be at least 262144.
      # If your OS already sets up this number to a higher value, feel free
      # to remove this init container.
      initContainers:
      - image: alpine:3.6
        command: ["/sbin/sysctl", "-w", "vm.max_map_count=262144"]
        name: elasticsearch-logging-init-max-map
        securityContext:
          privileged: true
      - image: alpine:3.6
        command: ["chown", "-R", "1000:1000","/usr/share/elasticsearch/data"]
        name: elasticsearch-logging-init-chown
        volumeMounts:
        - name: es-logging-data
          mountPath: /usr/share/elasticsearch/data
        securityContext:
          privileged: true
  volumeClaimTemplates:
  - metadata:
      name: es-logging-data
    spec:
      accessModes:
        - ReadWriteOnce
      storageClassName: {{ .Values.logging.elasticsearch.storageClassName }}
      resources:
        requests:
          storage: {{ .Values.logging.elasticsearch.pvcStorage }}
```


## Fluentd

### [`fluentd-es-configmap.yaml`](9Adv_fluentd_es_configmap.md)

```
kind: ConfigMap
apiVersion: v1
metadata:
  name: fluentd-es-config-v0.1.4
  namespace: logging
data:
  system.conf: |-
    <system>
      root_dir /tmp/fluentd-buffers/
    </system>
  containers.input.conf: |-
		...
      <store>
        @type s3
        @log_level info
        include_tag_key true
        logstash_format true
        aws_key_id  "#{ENV['LOG_BUCKET_KEY']}"
        aws_sec_key  "#{ENV['LOG_BUCKET_SECRET']}"
        s3_bucket  "#{ENV['LOG_BUCKET_NAME']}"
        s3_region  "#{ENV['LOG_BUCKET_REGION']}"
        path log/{{ .Values.jam.namespace }}/jam/%Y/%m/%d/%Y-%m-%d
        s3_object_key_format %{path}_jam_%{index}.%{file_extension}
        <buffer>
          @type file
          path /var/log/fluentd-buffers/s3/jam
          timekey 3600  # 1 hour
          timekey_wait 10m
          chunk_limit_size 256m
        </buffer>
        time_slice_format %Y-%m-%d/%H
      </store>
    </match>
```

### Store log in s3

```
<store>
	@id s3
	@type s3
	@log_level info
	include_tag_key true
	logstash_format true
	aws_key_id  "#{ENV['LOG_BUCKET_KEY']}"
	aws_sec_key  "#{ENV['LOG_BUCKET_SECRET']}"
	s3_bucket  "#{ENV['LOG_BUCKET_NAME']}"
	s3_region  "#{ENV['LOG_BUCKET_REGION']}"
	path log/{{ .Values.jam.namespace }}/
	<buffer>
	  @type file
	  path /var/log/fluentd-buffers/s3
	  timekey 3600  # 1 hour
	  timekey_wait 10m
	  chunk_limit_size 256m
	</buffer>
	time_slice_format %Y-%m-%d/%H
</store>
```

### `fluentd-es-ds.yaml`

```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: fluentd-es
  namespace: logging
  labels:
    k8s-app: fluentd-es
    kubernetes.io/cluster-service: "true"
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: fluentd-es
  labels:
    k8s-app: fluentd-es
    kubernetes.io/cluster-service: "true"
rules:
- apiGroups:
  - ""
  resources:
  - "namespaces"
  - "pods"
  verbs:
  - "get"
  - "watch"
  - "list"
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: fluentd-es
  labels:
    k8s-app: fluentd-es
    kubernetes.io/cluster-service: "true"
subjects:
- kind: ServiceAccount
  name: fluentd-es
  namespace: logging
  apiGroup: ""
roleRef:
  kind: ClusterRole
  name: fluentd-es
  apiGroup: "rbac.authorization.k8s.io"
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd-es-v2.0.4
  namespace: logging
  labels:
    k8s-app: fluentd-es
    version: v2.0.4
    kubernetes.io/cluster-service: "true"
spec:
  selector:
    matchLabels:
      k8s-app: fluentd-es
      version: v2.0.4
  template:
    metadata:
      labels:
        k8s-app: fluentd-es
        kubernetes.io/cluster-service: "true"
        version: v2.0.4
      # This annotation ensures that fluentd does not get evicted if the node
      # supports critical pod annotation based priority scheme.
      # Note that this does not guarantee admission on the nodes (#40573).
      annotations:
        scheduler.alpha.kubernetes.io/critical-pod: ''
        seccomp.security.alpha.kubernetes.io/pod: 'docker/default'
    spec:
      priorityClassName: infra-priority
      serviceAccountName: fluentd-es
      containers:
      - name: fluentd-es
        image: k8s.gcr.io/fluentd-elasticsearch:v2.0.4
        # A simple method to install plugins.
        # It is best not to follow this way elsewhere.
        command: ["/bin/sh", "-c"]
        args: ["gem install fluent-plugin-s3 -v $S3_PLUGIN_VERSION; fluentd;"]
        envFrom:
        - secretRef:
            name: log-bucket    # log object store settings
        env:
        - name: FLUENTD_ARGS
          value: --no-supervisor -q
        - name: S3_PLUGIN_VERSION
          value: {{ .Values.logging.fluentd.s3PluginVersion | quote }}
        resources:
          limits:
            memory: 500Mi
          requests:
            cpu: 100m
            memory: 200Mi
        volumeMounts:
        - name: varlog
          mountPath: /var/log
        - name: varlibdockercontainers
          mountPath: /var/lib/docker/containers
          readOnly: true
        - name: config-volume
          mountPath: /etc/fluent/config.d
      terminationGracePeriodSeconds: 30
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
      - name: varlibdockercontainers
        hostPath:
          path: /var/lib/docker/containers
      - name: config-volume
        configMap:
          name: fluentd-es-config-v0.1.4
```

### A simple method to install plugins.

```
command: ["/bin/sh", "-c"]
args: ["gem install fluent-plugin-s3 -v $S3_PLUGIN_VERSION; fluentd;"]
envFrom:
- secretRef:
   name: log-bucket  
```

```
- name: S3_PLUGIN_VERSION
  value: {{ .Values.logging.fluentd.s3PluginVersion | quote }}
```

## kibana

### `kibana-deployment.yaml`

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kibana-logging
  namespace: logging
  labels:
    k8s-app: kibana-logging
    kubernetes.io/cluster-service: "true"
spec:
  replicas: 1
  selector:
    matchLabels:
      k8s-app: kibana-logging
  template:
    metadata:
      labels:
        k8s-app: kibana-logging
      annotations:
        seccomp.security.alpha.kubernetes.io/pod: 'docker/default'
    spec:
      containers:
      - name: kibana-logging
        image: docker.elastic.co/kibana/kibana-oss:6.6.0
        resources:
          # need more cpu upon initialization, therefore burstable class
          limits:
            cpu: 1000m
          requests:
            cpu: 100m
        env:
          - name: ELASTICSEARCH_HOSTS
            value: http://elasticsearch-logging:9200
          - name: SERVER_BASEPATH
            value: ""
          # SERVER_BASEPATH is required if we want to use the api-server proxy
          #  otherwise, assume we're going to use the port-forwarding mechanisms
          #- name: SERVER_BASEPATH
          #  value: /api/v1/namespaces/logging/services/kibana-logging/proxy
        ports:
        - containerPort: 5601
          name: ui
          protocol: TCP
```

### `kibana-service.yaml`

```
apiVersion: v1
kind: Service
metadata:
  name: kibana-logging
  namespace: logging
  labels:
    k8s-app: kibana-logging
    kubernetes.io/cluster-service: "true"
    kubernetes.io/name: "Kibana"
spec:
  ports:
  - port: 5601
    protocol: TCP
    targetPort: ui
  selector:
    k8s-app: kibana-logging
```

### Install EFK

```
helm install jam-efk helm/charts/logging -f instances/$JAM_INSTANCE-k8s.yaml --namespace logging
```

- To view the Kibana instance:  
  `./helm/ports.sh`  
  and open: <localhost:5601>

- Configure Kibana:  
  Management (left side panel) -> Kibana -> Index Patterns
  - Index pattern -> `logstash-*` -> 'Next Step'
  - Timestamp -> `@timestamp` -> 'Create Index Pattern'
  
- Verify Logging:  
  Discover tab (left side panel)
  - Select `kubernetes.container_name` (click 'add')
  - Select `log_level` (click 'add')
  - Select `log` (click 'add')
  - Lastly, to view only your services, in the search box at the top enter:
    `kubernetes.namespace_name:<namespace>`