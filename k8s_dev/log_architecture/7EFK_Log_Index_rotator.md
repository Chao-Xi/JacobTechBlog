# Create CronJob to rotate(Clean) EFK logs

## YAML file

```
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: es-index-rotator
  namespace: logging
spec:
  schedule: "03 16 */1 * *"
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
                value: "15"
          restartPolicy: OnFailure
          imagePullSecrets:
          - name: registry
  concurrencyPolicy: Forbid
  successfulJobsHistoryLimit: 2
  failedJobsHistoryLimit: 1
```

* `"03 16 */1 * *"`: At 16:03 on every day-of-month.
* `LOG_ROTATE_DAYS`: Clean logs longer than 15 day

## Helm File

### `charts/logging/values.yaml`

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

### `charts/logging/values.yaml`

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
```




