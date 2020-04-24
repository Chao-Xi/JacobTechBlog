# Jam Argo Projects

**Projects provide a logical grouping of applications, which is useful when Argo CD is used by multiple teams**. Projects provide the following features

* restrict `what` may be deployed (trusted Git source repositories)
* restrict `where` apps may be deployed to (destination clusters and namespaces)
* restrict `what kinds` of objects may or may not be deployed (e.g. RBAC, CRDs, DaemonSets, NetworkPolicy etc...)
* defining `project roles` to provide application RBAC (bound to OIDC groups and/or JWT tokens)

ArgoCD could both deploy apps whin the same k8s cluster it been deployed at or an external cluster. So we can define multiple projects. Since we are only dealing with in-cluster apps, we use projects to distinguish deferent function modules. We have three projects defined: 

* **`$JAM_INSTANCE`**: the project contains all of our business services related to jam; 
* **logging**: the project contains EFK stack, and 
* **arogocd**: contains both ArgoCD project and ArgoCD application definitions. 
* **workzone-sealed-secrets**: All secrets contained in cluster

So the definitions for applications are self-deployed.

```
$ tree projects/
projects/
├── Chart.yaml
├── templates
│   └── projects.yaml
└── values.yaml

1 directory, 3 files
```


## Jam Projects

### `values.yaml`

```
jam:
  namespace: local700
```

### `Chart.yaml`

```
apiVersion: v1
appVersion: "1.0"
description: A Helm chart for jam-argocd-projects
name: jam-argocd-projects
version: 0.1.0
```

### `templates/projects.yaml`

```
{{range $project := tuple "logging" "argocd" .Values.jam.namespace}}
---
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: {{ $project }}
  namespace: argocd
spec:
  description: Project for {{ $project }}
  sourceRepos:
  - 'https://github.tools.sap/sap-zone/jam-on-k8s'
  destinations:
  - namespace: {{ $project }}
    server: https://kubernetes.default.svc
  clusterResourceWhitelist:
  - group: 'rbac.authorization.k8s.io'
    kind: ClusterRole
  - group: 'rbac.authorization.k8s.io'
    kind: ClusterRoleBinding
  - group: ''
    kind: Namespace
{{end}}
---
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: workzone-sealed-secrets
  namespace: argocd
spec:
  description: Project for Sync SealedSecrets
  sourceRepos:
  - 'https://github.tools.sap/sap-zone/jam-on-k8s'
  destinations:
  - namespace: '*'
    server: https://kubernetes.default.svc
  clusterResourceWhitelist:
  - group: 'bitnami.com/v1alpha1'
    kind: SealedSecret
```

**projects**:

* **logging**
* **argocd**
* **AppProject**
* **`.Values.jam.namespace`**: `dev902`
* **workzone-sealed-secrets**

```
helm install argocd-projects helm/argocd/projects -f instances/$NSTANCE-k8s.yaml --namespace argocd
```
