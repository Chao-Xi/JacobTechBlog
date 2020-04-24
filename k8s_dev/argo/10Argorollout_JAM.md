# Apply Argocd rollout to JAM ct-webapp

## Install ArgoCD rollout

[ArgoCD rollout](https://argoproj.github.io/argo-rollouts/) is a CRD to replace Deployment for blue-green deployment. Currently we only apply it to ct-webapp.

```
kubectl create namespace argo-rollouts
kubectl apply -n argo-rollouts -f https://raw.githubusercontent.com/argoproj/argo-rollouts/stable/manifests/install.yaml
```


## JAM CT helm chart

### `jam/ct/templates/deployment.yaml`

```
...
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: ct-webapp
  namespace: {{ .Values.jam.namespace }}
spec:
  selector:
    matchLabels:
      app: ct # has to match .spec.template.metadata.labels
  # replicas: {{ .Values.jam.ctWebapp.replicas }}
  revisionHistoryLimit: 3
  strategy:
    blueGreen:
      activeService: ct-webapp
      autoPromotionEnabled: true
  template:
    metadata:
      labels:
        app: ct # has to match .spec.selector.matchLabels
        mode: webapp
      annotations:
        "traffic.sidecar.istio.io/excludeOutboundPorts": "11212"
    spec:
      containers:
{{ include "jam.ct.container" $ctParams | indent 6 }}
      volumes:
{{ include "jam.ct.containerVolumes" . | indent 6 }}
      imagePullSecrets:
      - name: registry
...
```


* `apiVersion: argoproj.io/v1alpha1`
* `kind: Rollout`
* `strategy`

```
strategy:
  blueGreen:
    activeService: ct-webapp
    autoPromotionEnabled: true
```

### `jam/ct/templates/hpa.yaml`

```
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: ct-webapp
  namespace: {{ .Values.jam.namespace }}
spec:
  minReplicas: {{ or .Values.jam.ctWebapp.minReplicas .Values.jam.ctWebapp.replicas | default 2 }}
  maxReplicas: {{ .Values.jam.ctWebapp.maxReplicas | default 5 }}
  scaleTargetRef:
    apiVersion: argoproj.io/v1alpha1
    kind: Rollout
    name: ct-webapp
  targetCPUUtilizationPercentage: 80
---
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: ct-worker
  namespace: {{ .Values.jam.namespace }}
spec:
  minReplicas: {{ or .Values.jam.ctWorker.minReplicas .Values.jam.ctWorker.replicas | default 5 }}
  maxReplicas: {{ .Values.jam.ctWorker.maxReplicas | default 10 }}
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: ct-worker
  targetCPUUtilizationPercentage: 80
```

* `minReplicas: {{ or .Values.jam.ctWebapp.minReplicas .Values.jam.ctWebapp.replicas | default 2 }}`
	* `.Values.jam.ctWebapp.minReplicas`
	* `.Values.jam.ctWebapp.replicas`