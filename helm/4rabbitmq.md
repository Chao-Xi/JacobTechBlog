# Rabbitmq 

### Two types of `Rabbitmq`

* **`rabbitmq-ha` for webhook**
* **`rabbitmq-transient` for delay job**

## `values.yaml`

```
jam:
  namespace: local700
```

## rabbitmq-ha


### **rabbitmq-ha**: `ha-service.yaml`


```
kind: Service
apiVersion: v1
metadata:
  name: rabbitmq-ha
  namespace: {{ .Values.jam.namespace }}
  labels:
    app: rabbitmq
    scope: ha
    type: LoadBalancer
spec:
  ports:
   - name: http
     protocol: TCP
     port: 15672
     targetPort: 15672
   - name: amqp
     protocol: TCP
     port: 5672
     targetPort: 5672
  selector:
    app: rabbitmq
    scope: ha
```

### **rabbitmq-ha**: `ha-deployment.yaml`

```
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: rabbitmq-ha
  namespace: {{ .Values.jam.namespace }}
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: rabbit-ha-endpoint-reader
  namespace: {{ .Values.jam.namespace }}
rules:
- apiGroups: [""]
  resources: ["endpoints"]
  verbs: ["get"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: rabbit-ha-endpoint-reader
  namespace: {{ .Values.jam.namespace }}
subjects:
- kind: ServiceAccount
  name: rabbitmq-ha
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: rabbit-ha-endpoint-reader

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: rabbitmq-ha-config
  namespace: {{ .Values.jam.namespace }}
data:
  enabled_plugins: |
      [rabbitmq_management,rabbitmq_peer_discovery_k8s].
  rabbitmq.conf: |
      ## Clustering
      cluster_formation.peer_discovery_backend  = rabbit_peer_discovery_k8s
      cluster_formation.k8s.host = kubernetes.default.svc.cluster.local
      cluster_formation.k8s.address_type = ip
      cluster_formation.node_cleanup.interval = 10
      # RH/SAP: since we're running multiple rabbits, explicitly set the service name
      cluster_formation.k8s.service_name = rabbitmq-ha
      # Set to false if automatic removal of unknown/absent nodes
      # is desired. This can be dangerous, see
      #  * http://www.rabbitmq.com/cluster-formation.html#node-health-checks-and-cleanup
      #  * https://groups.google.com/forum/#!msg/rabbitmq-users/wuOfzEywHXo/k8z_HWIkBgAJ
      cluster_formation.node_cleanup.only_log_warning = true
      cluster_partition_handling = autoheal
      ## queue master locator
      queue_master_locator=min-masters
      ## See http://www.rabbitmq.com/access-control.html#loopback-users
      loopback_users.guest = false

---
apiVersion: apps/v1beta1
kind: StatefulSet
metadata:
  name: rabbitmq-ha
  namespace: {{ .Values.jam.namespace }}
spec:
  serviceName: rabbitmq-ha
  updateStrategy:
    type: RollingUpdate
  replicas: 1
  template:
    metadata:
      annotations:
        "sidecar.istio.io/inject": "false"
      labels:
        app: rabbitmq
        scope: ha
    spec:
      serviceAccountName: rabbitmq-ha
      terminationGracePeriodSeconds: 10
      initContainers:
        - name: copy-rabbitmq-config
          image: busybox
          command: ['sh', '-c', 'cp /configmap/* /etc/rabbitmq']
          volumeMounts:
            - name: config-volume
              mountPath: /configmap
            - name: config
              mountPath: /etc/rabbitmq
      containers:
      - name: rabbitmq-k8s
        image: rabbitmq:3.7
        imagePullPolicy: Always
        volumeMounts:
          - name: config
            mountPath: /etc/rabbitmq
        ports:
          - name: http
            protocol: TCP
            containerPort: 15672
          - name: amqp
            protocol: TCP
            containerPort: 5672
        livenessProbe:
          exec:
            command: ["rabbitmqctl", "status"]
          initialDelaySeconds: 60
          timeoutSeconds: 60
        readinessProbe:
          exec:
            command: ["rabbitmqctl", "status"]
          initialDelaySeconds: 20
          timeoutSeconds: 60
        env:
          - name: MY_POD_IP
            valueFrom:
              fieldRef:
                fieldPath: status.podIP
          - name: RABBITMQ_DEFAULT_USER
            valueFrom:
              secretKeyRef:
                name: rabbit
                key: username
          - name: RABBITMQ_DEFAULT_PASS
            valueFrom:
              secretKeyRef:
                name: rabbit
                key: password
          - name: RABBITMQ_DEFAULT_VHOST
            value: /jam
          - name: RABBITMQ_USE_LONGNAME
            value: "true"
          - name: RABBITMQ_NODENAME
            value: "rabbit@$(MY_POD_IP)"
          - name: K8S_SERVICE_NAME
            value: "rabbitmq-ha"
          - name: RABBITMQ_ERLANG_COOKIE
            value: "mycookie-ha"
          - name: NONCE
            value: "1"
      volumes:
        - name: config
          emptyDir: {}
        - name: config-volume
          configMap:
            name: rabbitmq-ha-config
            items:
            - key: rabbitmq.conf
              path: rabbitmq.conf
            - key: enabled_plugins
              path: enabled_plugins
```

```
env:
  - name: MY_POD_IP
    valueFrom:
      fieldRef:
         fieldPath: status.podIP
```

**`value: "rabbit@$(MY_POD_IP)"`**


## rabbitmq-transient


### **rabbitmq-transient**: `transient-service.yaml`

```
kind: Service
apiVersion: v1
metadata:
  name: rabbitmq-transient
  namespace: {{ .Values.jam.namespace }}
  labels:
    app: rabbitmq
    scope: transient
    type: LoadBalancer
spec:
  ports:
   - name: http
     protocol: TCP
     port: 15672
     targetPort: 15672
   - name: amqp
     protocol: TCP
     port: 5672
     targetPort: 5672
  selector:
    app: rabbitmq
    scope: transient
```

### **rabbitmq-deployment**: `transient-deployment.yaml`

```
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: rabbitmq-transient
  namespace: {{ .Values.jam.namespace }}
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: rabbit-transient-endpoint-reader
  namespace: {{ .Values.jam.namespace }}
rules:
- apiGroups: [""]
  resources: ["endpoints"]
  verbs: ["get"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: rabbit-transient-endpoint-reader
  namespace: {{ .Values.jam.namespace }}
subjects:
- kind: ServiceAccount
  name: rabbitmq-transient
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: rabbit-transient-endpoint-reader
  

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: rabbitmq-transient-config
  namespace: {{ .Values.jam.namespace }}
data:
  enabled_plugins: |
      [rabbitmq_management,rabbitmq_peer_discovery_k8s].
  rabbitmq.conf: |
      ## Clustering
      cluster_formation.peer_discovery_backend  = rabbit_peer_discovery_k8s
      cluster_formation.k8s.host = kubernetes.default.svc.cluster.local
      cluster_formation.k8s.address_type = ip
      cluster_formation.node_cleanup.interval = 10
      # RH/SAP: since we're running multiple rabbits, explicitly set the service name
      cluster_formation.k8s.service_name = rabbitmq-transient
      # Set to false if automatic removal of unknown/absent nodes
      # is desired. This can be dangerous, see
      #  * http://www.rabbitmq.com/cluster-formation.html#node-health-checks-and-cleanup
      #  * https://groups.google.com/forum/#!msg/rabbitmq-users/wuOfzEywHXo/k8z_HWIkBgAJ
      cluster_formation.node_cleanup.only_log_warning = true
      cluster_partition_handling = autoheal
      ## queue master locator
      queue_master_locator=min-masters
      ## See http://www.rabbitmq.com/access-control.html#loopback-users
      loopback_users.guest = false

---
apiVersion: apps/v1beta1
kind: StatefulSet
metadata:
  name: rabbitmq-transient
  namespace: {{ .Values.jam.namespace }}
spec:
  serviceName: rabbitmq-transient
  updateStrategy:
    type: RollingUpdate
  replicas: 1
  template:
    metadata:
      annotations:
        "sidecar.istio.io/inject": "false"
      labels:
        app: rabbitmq
        scope: transient
    spec:
      serviceAccountName: rabbitmq-transient
      terminationGracePeriodSeconds: 10
      initContainers:
        - name: copy-rabbitmq-config
          image: busybox
          command: ['sh', '-c', 'cp /configmap/* /etc/rabbitmq']
          volumeMounts:
            - name: config-volume
              mountPath: /configmap
            - name: config
              mountPath: /etc/rabbitmq
      containers:
      - name: rabbitmq-k8s
        image: rabbitmq:3.7
        imagePullPolicy: Always
        volumeMounts:
          - name: config
            mountPath: /etc/rabbitmq
        ports:
          - name: http
            protocol: TCP
            containerPort: 15672
          - name: amqp
            protocol: TCP
            containerPort: 5672
        livenessProbe:
          exec:
            command: ["rabbitmqctl", "status"]
          initialDelaySeconds: 60
          timeoutSeconds: 60
        readinessProbe:
          exec:
            command: ["rabbitmqctl", "status"]
          initialDelaySeconds: 20
          timeoutSeconds: 60
        env:
          - name: MY_POD_IP
            valueFrom:
              fieldRef:
                fieldPath: status.podIP
          - name: RABBITMQ_DEFAULT_USER
            valueFrom:
              secretKeyRef:
                name: rabbit
                key: username
          - name: RABBITMQ_DEFAULT_PASS
            valueFrom:
              secretKeyRef:
                name: rabbit
                key: password
          - name: RABBITMQ_DEFAULT_VHOST
            value: /jam
          - name: RABBITMQ_USE_LONGNAME
            value: "true"
          - name: RABBITMQ_NODENAME
            value: "rabbit@$(MY_POD_IP)"
          - name: K8S_SERVICE_NAME
            value: "rabbitmq-transient"
          - name: RABBITMQ_ERLANG_COOKIE
            value: "mycookie-transient"
          - name: NONCE
            value: "1"
      volumes:
        - name: config
          emptyDir: {}
        - name: config-volume
          configMap:
            name: rabbitmq-transient-config
            items:
            - key: rabbitmq.conf
              path: rabbitmq.conf
            - key: enabled_plugins
              path: enabled_plugins
```



