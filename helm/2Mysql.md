# Jam MySql (Version Pre-Alpha)

```
$ tree mysql/
mysql/
├── Chart.yaml
├── templates
│   ├── deployment.yaml
│   ├── init-db.yaml
│   ├── proxy.yaml
│   └── service.yaml
└── values.yaml

1 directory, 6 files
```
```
helm install --name jam-mysql helm/jam/mysql/ -f instances/$JAM_INSTANCE-k8s.yaml --namespace $JAM_INSTANCE
```

## `Chart.yaml`

```
apiVersion: v1
appVersion: "1.0"
description: A Helm chart for mysql
name: mysql
version: 0.1.0
```

##  `values.yaml`

```
jam:
  namespace: local700
  deploymentLandscape: aws
  mysql:
    external: true
    externalHostName: dev701-db.cxqgj1lee4x0.eu-central-1.rds.amazonaws.com
    pvcStorage: 100Gi
```

* **`external: true` use outside cloud database**
* **`external: false` build inside cluster database**


##  `templates/deployment.yaml`

```
{{- if .Values.jam.mysql.external | not}}
# ----- [ mysql ] --------------------
#
apiVersion: apps/v1 # for versions before 1.9.0 use apps/v1beta2
kind: StatefulSet
metadata:
  labels:
    app: mysql
  name: mysql
  namespace: {{ .Values.jam.namespace }}
spec:
  serviceName: mysql
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - image: mysql:5.7
        name: mysql
        args:
          - "--ignore-db-dir=lost+found"
        env:
        - name: MYSQL_ROOT_PASSWORD
          # in RDS scenarios our admin user might not be root. here, we use root.
          valueFrom:
            secretKeyRef:
              name: db-admin
              key: MYSQL_ADMIN_PASSWORD
        - name: MYSQL_USER
          valueFrom:
            secretKeyRef:
              name: db-ct
              key: MYSQL_USER
        - name: MYSQL_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-ct
              key: MYSQL_PASSWORD
        - name: MYSQL_DATABASE
          valueFrom:
            configMapKeyRef:
              name: data
              key: MYSQL_CT_DB
        ports:
        - containerPort: 3306
          name: mysql
        volumeMounts:
        - name: var-lib-mysql
          mountPath: /var/lib/mysql
  volumeClaimTemplates:
  - metadata:
      name: var-lib-mysql
    spec:
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: {{ .Values.jam.mysql.pvcStorage }}
{{- end}}
```

* Only build the mysql inside cluster when `.Values.jam.mysql.external=true`
* `storage: {{ .Values.jam.mysql.pvcStorage }}` the PVC size for storage

### `templates/service.yaml` The `ExternalName` of Service for mysql

```
---
# ----- [ mysql services ] --------------------
#
apiVersion: v1
kind: Service
metadata:
  name: mysql
  namespace: {{ .Values.jam.namespace }}
spec:
  {{- if .Values.jam.mysql.external}}
  type: ExternalName
  externalName: {{ .Values.jam.mysql.externalHostName }}
  {{- else }}
  type: NodePort
  selector:
    app: mysql
  ports:
  - name: sql
    protocol: TCP
    port: 3306
    targetPort: 3306
  {{- end }}
```

* `{{- if .Values.jam.mysql.external}}` If the mysql is a external service from cloud, assign it an `ExternalName` service, otherwise give it an <mark>**`Nodeport` server**</mark>


##  `templates/proxy.yaml` 

```
---
{{- if eq .Values.jam.deploymentLandscape "gcp" }}
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  annotations:
  labels:
    app: mysql
  name: mysql
  namespace: {{ .Values.jam.namespace }}
spec:
  progressDeadlineSeconds: 600
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app: mysql
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - command:
        - /cloud_sql_proxy
        - -dir=/cloudsql
        - -instances={{ .Values.jam.mysql.externalHostName }}=tcp:0.0.0.0:3306
        - -credential_file=/credentials/credentials.json
        image: b.gcr.io/cloudsql-docker/gce-proxy:1.12
        imagePullPolicy: Always
        name: mysql
        ports:
        - containerPort: 3306
          name: port-database1
          protocol: TCP
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /cloudsql
          name: cloudsql
        - mountPath: /credentials
          name: cloudsql-instance-credentials
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
      volumes:
      - emptyDir: {}
        name: cloudsql
      - name: cloudsql-instance-credentials
        secret:
          defaultMode: 420
          secretName: cloudsql-instance-credentials
{{- end }}
```


##  `templates/init-db.yaml` After DB Service created 

```
apiVersion: batch/v1
kind: Job
metadata:
  name: init-db
  namespace: {{ .Values.jam.namespace }}
  annotations:
    "helm.sh/hook": post-install
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
      - name: mysql-init-db
        image: mysql
        command: ["mysql"]
        args: [
          "-hmysql",
          "-u$(MYSQL_USER)",
          # password is packed into MYSQL_PWD
          # https://github.wdf.sap.corp/sap-jam/chef-repo/blob/master/chef/site-cookbooks/sap-jam/files/default/init_jam_db_production.sql
          "-e",
          " \
          CREATE DATABASE IF NOT EXISTS $(CT_DB) CHARACTER SET utf8 COLLATE utf8_general_ci; \
          CREATE DATABASE IF NOT EXISTS $(PS_DB) CHARACTER SET utf8 COLLATE utf8_unicode_ci; \
          CREATE DATABASE IF NOT EXISTS tenant_migration_transient_ct CHARACTER SET utf8 COLLATE utf8_general_ci; \
          CREATE DATABASE IF NOT EXISTS tenant_migration_transient_ps CHARACTER SET utf8 COLLATE utf8_unicode_ci; \
          \
          GRANT   ALL PRIVILEGES  ON $(CT_DB).*                           TO $(CT_USER)@'%'       IDENTIFIED BY '$(CT_PW)'; \
          GRANT   ALL PRIVILEGES  ON `tenant_migration_transient_ct%`.*   TO $(CT_USER)@'%'       IDENTIFIED BY '$(CT_PW)'; \
          GRANT   ALL PRIVILEGES  ON $(PS_DB).*                           TO $(PS_USER)@'%'       IDENTIFIED BY '$(PS_PW)'; \
          GRANT   ALL PRIVILEGES  ON `tenant_migration_transient_ps%`.*   TO $(PS_USER)@'%'       IDENTIFIED BY '$(PS_PW)'; \
          \
          GRANT   SELECT          ON $(CT_DB).*                           TO $(CUBETREE_USER)@'%' IDENTIFIED BY '$(CUBETREE_PASSWORD)'; \
          GRANT   SELECT          ON $(PS_DB).*                           TO $(CUBETREE_USER)@'%' IDENTIFIED BY '$(CUBETREE_PASSWORD)'; \
          GRANT   SELECT          ON `tenant_migration_transient%`.*      TO $(CUBETREE_USER)@'%' IDENTIFIED BY '$(TM_PASSWORD)'; \
          \
          GRANT   ALL PRIVILEGES  ON `tenant_migration_transient%`.*      TO $(TM_USER)@'%'       IDENTIFIED BY '$(TM_PASSWORD)'; \
          GRANT   SELECT          ON $(CT_DB).*                           TO $(TM_USER)@'%'       IDENTIFIED BY '$(TM_PASSWORD)'; \
          GRANT   SELECT          ON $(PS_DB).*                           TO $(TM_USER)@'%'       IDENTIFIED BY '$(TM_PASSWORD)'; \
          "
        ]
        env:
        - name: MYSQL_USER
          valueFrom:
            secretKeyRef:
              name: db-admin
              key: MYSQL_ADMIN_USER
        - name: MYSQL_PWD
          valueFrom:
            secretKeyRef:
              name: db-admin
              key: MYSQL_ADMIN_PASSWORD
        - name: CT_DB
          valueFrom:
            configMapKeyRef:
              name: data
              key: MYSQL_CT_DB
        - name: CT_USER
          valueFrom:
            secretKeyRef:
              name: db-ct
              key: MYSQL_USER
        - name: CT_PW
          valueFrom:
            secretKeyRef:
              name: db-ct
              key: MYSQL_PASSWORD
        - name: PS_DB
          valueFrom:
            configMapKeyRef:
              name: data
              key: MYSQL_PS_DB
        - name: PS_USER
          valueFrom:
            secretKeyRef:
              name: db-ps
              key: MYSQL_USER
        - name: PS_PW
          valueFrom:
            secretKeyRef:
              name: db-ps
              key: MYSQL_PASSWORD
        - name: CUBETREE_USER
          valueFrom:
            secretKeyRef:
              name: db-secondary
              key: CUBETREE_USER
        - name: CUBETREE_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-secondary
              key: CUBETREE_PASSWORD
        - name: TM_USER
          valueFrom:
            secretKeyRef:
              name: db-secondary
              key: TENANT_MIGRATION_USER
        - name: TM_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-secondary
              key: TENANT_MIGRATION_PASSWORD
      restartPolicy: Never
```


### Hooks

```
annotations:
  "helm.sh/hook": post-install
  "helm.sh/hook-delete-policy": "hook-succeeded,hook-failed"
  "helm.sh/hook-weight": "0"
```

* 安装后`post-install`：在所有 kubernetes 资源安装到集群后执行
* **删除资源的策略可供选择的注释值**
* `hook-succeeded`：表示 `Tiller` 在 `hook` 成功执行后删除 `hook` 资源
* `hook-failed`：表示如果 `hook` 在执行期间失败了，`Tiller` 应该删除 `hook` 资源
* `before-hook-creation`：表示在删除新的 `hook` 之前应该删除以前的 `hook`
* 注意`Job`的`RestartPolicy`仅支持`Never`和`OnFailure`两种，不支持`Always`，我们知道Job就相当于来执行一个批处理任务，执行完就结束了，如果支持Always的话是不是就陷入了死循环了？
* `.spec.backoffLimit: 0` to specify the number of retries before considering a Job as failed













