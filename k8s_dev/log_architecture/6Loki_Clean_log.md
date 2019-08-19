# Clean log in Log aggregator System (Loki)

## Use job to clean logs

```
apiVersion: batch/v1
kind: Job
metadata:
  name: log-cleaner
  namespace: logging
spec:
  template:
    metadata:
      name: log-cleaner
    spec:
      restartPolicy: Never
      containers:
      - name: log-cleaner
        image: busybox
        command: 
        - "bin/sh"
        - "-c"
        - "find /data/loki/chunks -mtime +7 -delete"
        # - "ls -lt /data/loki/chunks"
        # https://askubuntu.com/questions/589210/removing-files-older-than-7-days
        volumeMounts:
        - name: log-data
          mountPath: /data
      affinity:
        podAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - loki
            topologyKey: kubernetes.io/hostname  
      volumes:
      - name: log-data
        persistentVolumeClaim:
          claimName: storage-loki-0
```

### Attention:

* **affinity is needed to attach the job(pod) with loki pod on the same node**

## Use job to clean logs

```
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: cron-log-cleaner
  namespace: logging
spec:
    successfulJobsHistoryLimit: 5
    failedJobsHistoryLimit: 5
    schedule: "0 0 * * SUN"
    jobTemplate:
      spec:
        template:
          spec:
            restartPolicy: OnFailure
            containers:
            - name: log-cleaner
              image: busybox
              command: 
              - "bin/sh"
              - "-c"
              - "find /data/loki/chunks -mtime +7 -delete"
              volumeMounts:
              - name: log-data
                mountPath: /data
            affinity:
              podAffinity:
                requiredDuringSchedulingIgnoredDuringExecution:
                - labelSelector:
                    matchExpressions:
                    - key: app
                      operator: In
                      values:
                      - loki
                  topologyKey: kubernetes.io/hostname  
            volumes:
            - name: log-data
              persistentVolumeClaim:
                claimName: storage-loki-0
# kubectl create job --from=cronjob/<cronjob-name> <job-name>
```

## Use loki `retention`arguments 

[https://github.com/grafana/loki/blob/master/docs/operations.md#retentiondeleting-old-data](https://github.com/grafana/loki/blob/master/docs/operations.md#retentiondeleting-old-data)

Retention in Loki can be done by configuring Table Manager. You need to set a retention period and enable deletes for retention using yaml config as seen [here](https://github.com/grafana/loki/blob/39bbd733be4a0d430986d9513476a91334485e9f/production/ksonnet/loki/config.libsonnet#L128-L129) or using `table-manager.retention-period` and `table-manager.retention-deletes-enabled` command line args. Retention period needs to be a duration in string format that can be parsed using 


**[NOTE]** Retention period should be at **least twice the [duration of periodic table config](https://github.com/grafana/loki/blob/347a3e18f4976d799d51a26cee229efbc27ef6c9/production/helm/loki/values.yaml#L53)**, which currently defaults to 7 days.



```
loki:
  config:
    table_manager:
      retention_deletes_enabled: true
      retention_period: 336h. 
# 2 weeks
operations.md#retentiondeleting-old-data
  persistence:
    enabled: true
    storageClassName: cinder-default
  nodeSelector: 
      jam/ubertest: monitoring
  tolerations:
  - operator: Exists
```


```
helm upgrade --install -f loki-config.yaml loki --namespace=logging loki/
```


### You can check the update config on the `loki0` pod

```
$ kubectl exec -it loki-0 -n logging sh
# less /etc/loki/loki.yaml
...
table_manager:
  retention_deletes_enabled: true
  retention_period: 336h
...
```



