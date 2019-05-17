# BB AWS Cluster Autoscaler 

**bb install `aws_cluster_autoscaler` by helm**

```
$ cat shared-services/kubernetes/releases/animal/us-east-1/cluster01/kube-system/system-services/requirements.yaml

...
- name: cluster-autoscaler
  version: 0.7.0
  repository: https://kubernetes-charts.storage.googleapis.com
...
```

```
$ kubectl get deploy  system-services-aws-cluster-autoscaler -n=kube-system -o=yaml --export
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  annotations:
    deployment.kubernetes.io/revision: "24"
  creationTimestamp: null
  generation: 1
  labels:
    app: aws-cluster-autoscaler
    chart: cluster-autoscaler-0.7.0
    heritage: Tiller
    release: system-services
  name: system-services-aws-cluster-autoscaler
  selfLink: /apis/extensions/v1beta1/namespaces/kube-system/deployments/system-services-aws-cluster-autoscaler
spec:
  progressDeadlineSeconds: 600
  replicas: 2
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app: aws-cluster-autoscaler
      release: system-services
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
    type: RollingUpdate
  template:
    metadata:
      annotations:
        prometheus.io/port: "8085"
        prometheus.io/scrape: "true"
      creationTimestamp: null
      labels:
        app: aws-cluster-autoscaler
        release: system-services
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: release
                  operator: In
                  values:
                  - system-services
                - key: app
                  operator: In
                  values:
                  - cluster-autoscaler
              topologyKey: failure-domain.beta.kubernetes.io/zone
            weight: 100
      containers:
      - command:
        - ./cluster-autoscaler
        - --cloud-provider=aws
        - --namespace=kube-system
        - --nodes=0:20:learn-operations-autoscale-us-east-1a.cluster01-us-east-1.animal.bbsaas.io
        - --nodes=0:20:learn-operations-autoscale-us-east-1b.cluster01-us-east-1.animal.bbsaas.io
        - --nodes=0:20:learn-operations-autoscale-us-east-1c.cluster01-us-east-1.animal.bbsaas.io
        - --nodes=0:20:learnci-autoscale-us-east-1a.cluster01-us-east-1.animal.bbsaas.io
        - --nodes=0:20:learnci-autoscale-us-east-1b.cluster01-us-east-1.animal.bbsaas.io
        - --nodes=0:20:learnci-autoscale-us-east-1c.cluster01-us-east-1.animal.bbsaas.io
        - --nodes=0:105:performance-autoscale-us-east-1a.cluster01-us-east-1.animal.bbsaas.io
        - --nodes=0:105:performance-autoscale-us-east-1b.cluster01-us-east-1.animal.bbsaas.io
        - --nodes=0:100:performance-autoscale-us-east-1c.cluster01-us-east-1.animal.bbsaas.io
        - --nodes=0:30:performance-dev-autoscale-us-east-1a.cluster01-us-east-1.animal.bbsaas.io
        - --nodes=0:30:performance-dev-autoscale-us-east-1b.cluster01-us-east-1.animal.bbsaas.io
        - --nodes=0:30:performance-dev-autoscale-us-east-1c.cluster01-us-east-1.animal.bbsaas.io
        - --nodes=0:10:learn-deployments-autoscale-us-east-1a.cluster01-us-east-1.animal.bbsaas.io
        - --nodes=0:10:learn-deployments-autoscale-us-east-1b.cluster01-us-east-1.animal.bbsaas.io
        - --nodes=0:10:learn-deployments-autoscale-us-east-1c.cluster01-us-east-1.animal.bbsaas.io
        - --nodes=0:10:performance-deployments-autoscale-us-east-1a.cluster01-us-east-1.animal.bbsaas.io
        - --nodes=0:10:performance-deployments-autoscale-us-east-1b.cluster01-us-east-1.animal.bbsaas.io
        - --nodes=0:10:performance-deployments-autoscale-us-east-1c.cluster01-us-east-1.animal.bbsaas.io
        - --balance-similar-node-groups=true
        - --logtostderr=true
        - --scale-down-unneeded-time=1m
        - --stderrthreshold=info
        - --v=4
        env:
        - name: AWS_REGION
          value: us-east-1
        image: k8s.gcr.io/cluster-autoscaler:v1.2.2
        imagePullPolicy: IfNotPresent
        livenessProbe:
          failureThreshold: 3
          httpGet:
            path: /health-check
            port: 8085
            scheme: HTTP
          periodSeconds: 10
          successThreshold: 1
          timeoutSeconds: 1
        name: aws-cluster-autoscaler
        ports:
        - containerPort: 8085
          protocol: TCP
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /etc/ssl/certs/ca-certificates.crt
          name: ssl-certs
          readOnly: true
      dnsPolicy: ClusterFirst
      nodeSelector:
        kubernetes.io/role: master
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      serviceAccount: system-services-aws-cluster-autoscaler
      serviceAccountName: system-services-aws-cluster-autoscaler
      terminationGracePeriodSeconds: 30
      tolerations:
      - effect: NoSchedule
        key: node-role.kubernetes.io/master
        operator: Exists
      volumes:
      - hostPath:
          path: /etc/ssl/certs/ca-certificates.crt
          type: ""
        name: ssl-certs
status: {}
```

**`https://github.com/helm/charts/tree/master/stable/aws-cluster-autoscaler`**

### Verifying Installation

The chart will succeed even if the three required parameters are not supplied. To verify the aws-cluster-autoscaler is configured properly find a pod that the deployment created and describe it. It must have a `--nodes` argument supplied to the `./cluster-autoscaler` app under `Command`. For example (all other values are omitted for brevity):

```
Containers:
  aws-cluster-autoscaler:
    Command:
      ./cluster-autoscaler
      --cloud-provider=aws
      --nodes=1:10:your-asg-name
      --scale-down-delay=10m
      --skip-nodes-with-local-storage=false
      --skip-nodes-with-system-pods=true
      --v=4
```

### Configuration

The following table lists the configurable parameters of the `aws-cluster-autoscaler` chart and their default values.

Parameter | Description | Default
--- | --- | ---
`autoscalingGroups[].name` | autoscaling group name | None. You *must* supply at least one.
`autoscalingGroups[].maxSize` | maximum autoscaling group size | None. You *must* supply at least one.
`autoscalingGroups[].minSize` | minimum autoscaling group size | None. You *must* supply at least one.
`awsRegion` | AWS region | `us-east-1`
`image.repository` | Image | `k8s.gcr.io/cluster-autoscaler`
`image.tag` | Image tag | `v0.5.4`
`image.pullPolicy` | Image pull policy | `IfNotPresent`
`extraArgs` | additional container arguments | `{}`
`nodeSelector` | node labels for pod assignment | `{}`
`podAnnotations` | annotations to add to each pod | `{}`
`replicaCount` | desired number of pods | `1`
`resources` | pod resource requests & limits | `{}`
`scaleDownDelay` | time to wait between scaling operations | `10m` (10 minutes)
`service.annotations` | annotations to add to service | none
`service.clusterIP` | IP address to assign to service | `""`
`service.externalIPs` | service external IP addresses | `[]`
`service.loadBalancerIP` | IP address to assign to load balancer (if supported) | `""`
`service.loadBalancerSourceRanges` | list of IP CIDRs allowed access to load balancer (if supported) | `[]`
`service.servicePort` | service port to expose | `8085`
`service.type` | type of service to create | `ClusterIP`
`skipNodes.withLocalStorage` | don't terminate nodes running pods that use local storage | `false`
`skipNodes.withSystemPods` | don't terminate nodes running pods in the `kube-system` namespace | `true`

### IAM Permissions

The worker running the cluster autoscaler will need access to certain resources and actions:

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup"
            ],
            "Resource": "*"
        }
    ]
}
```
