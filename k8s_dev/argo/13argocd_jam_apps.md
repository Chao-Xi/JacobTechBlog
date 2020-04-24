# Jam Argo Applications

### Application:

An application equals a helm release. We have all the jam services application definitions in our repository. We can define the helm chart path, value path, sync policy, and target GitHub branch for a certain application.

```
$ tree applications/
applications/
├── Chart.yaml
├── templates
│   ├── argocd.yaml
│   ├── config.yaml
│   ├── jam.yaml
│   ├── logging.yaml
│   └── sealded_secrets.yaml
└── values.yaml

1 directory, 7 files
```


### Sync:

Sync means deployment. ArgoCD will sync with the target repository every couple minutes and use helm to render templates. 

* If the rendered manifest is different from the online manifest, ArgoCD will mark the application as **"out of sync"**. 
* If the application is configured as **"auto sync"**, ArgoCD will automatically deploy the outdated applications, or we need to deploy it manually.
*  ArgoCD will also convert helm hook to Argo hook, but not 100% precise. **The pre-install and post-install hooks will become pre-sync and post-sync hooks**. **So they will be executed every sync**.

```
$ argocd repo add https://github.... --username github-serviceuser --password github-token
```

### `values.yaml`

```
jam:
  namespace: local700
argocd:
  autoSync: false
  targetRevision: master
```

### Chart.yaml

```
apiVersion: v1
appVersion: "1.0"
description: A Helm chart for jam-argocd-applications
name: jam-argocd-applications
version: 0.1.0
```

### `templates/argocd.yaml`

```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: argocd-projects
  namespace: argocd
spec:
  project: argocd
  source:
    repoURL: https://github.tools.sap/sap-zone/jam-on-k8s
    targetRevision: {{ $.Values.argocd.targetRevision }}
    path: helm/argocd/projects
    helm:
      valueFiles:
      - ../../../instances/{{ $.Values.jam.namespace }}-k8s.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  syncPolicy:
    automated:
      prune: false
      selfHeal: false
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: argocd-applications
  namespace: argocd
spec:
  project: argocd
  source:
    repoURL: https://github.tools.sap/sap-zone/jam-on-k8s
    targetRevision: {{ $.Values.argocd.targetRevision }}
    path: helm/argocd/applications
    helm:
      valueFiles:
      - ../../../instances/{{ $.Values.jam.namespace }}-k8s.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  syncPolicy:
    automated:
      prune: false
      selfHeal: false
```

### [Automated Sync Policy](https://argoproj.github.io/argo-cd/user-guide/auto_sync/)

Argo CD has the ability to automatically sync an application when it detects differences between the desired manifests in Git, and the live state in the cluster.

A benefit of automatic sync is that CI/CD pipelines no longer need direct access to the Argo CD API server to perform the deployment. Instead, the pipeline makes a commit and push to the Git repository with the changes to the manifests in the tracking Git repo.

To configure automated sync run:

```
argocd app set <APPNAME> --sync-policy automated
```

Alternatively, if creating the application an application manifest, specify a syncPolicy with an `automated` policy.

```
spec:
  syncPolicy:
    automated: {}
```

**Automatic Pruning**

By default (and as a safety mechanism), automated sync will not delete resources when `Argo CD` detects the resource is no longer defined in Git. **To prune the resources, a manual sync can always be performed (with pruning checked)**. Pruning can also be enabled to happen automatically as part of the automated sync by running:

```
argocd app set <APPNAME> --auto-prune
```

Or by setting the prune option to true in the automated sync policy:

```
spec:
  syncPolicy:
    automated:
      prune: true
```

**Automatic Self-Healing**

By default, changes that are made to the live cluster will not trigger automated sync. **To enable automatic sync when the live cluster's state deviates from the state defined in Git**, run:

```
argocd app set <APPNAME> --self-heal
```

Or by setting the self heal option to true in the automated sync policy:

```
spec:
  syncPolicy:
    automated:
      selfHeal: true
```

### logging.yaml

```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: logging
  namespace: argocd
spec:
  project: logging
  source:
    repoURL: https://github.tools.sap/sap-zone/jam-on-k8s
    targetRevision: {{ $.Values.argocd.targetRevision }}
    path: helm/charts/logging
    helm:
      valueFiles:
      - ../../../instances/{{ $.Values.jam.namespace }}-k8s.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: logging
```

### sealded_secrets.yaml

```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: sealed-secrets
  namespace: argocd
  labels:
    apply-cd: "true"
spec:
  project: workzone-sealed-secrets
  source:
    repoURL: https://github.tools.sap/sap-zone/jam-on-k8s
    targetRevision: {{ $.Values.argocd.targetRevision }}
    path: {{ $.Values.kustomize_path }}secrets
  syncPolicy:
    automated:
      prune: false
      selfHeal: false
  destination:
    server: https://kubernetes.default.svc
    namespace: '*'
{{- if eq $.Values.argocd.autoSync true  }}
  syncPolicy:
    automated:
      prune: false
      selfHeal: false
{{- end }}
```

### jam.yaml

```
{{- $allApps := list "elasticsearch" "elasticsearch6" "mail" "memcached" "rabbitmq" "agent-server" "antivirus" "ct" "doc" "jod" "load-balancer" "mail-inbound"  "opensocial" "ps" "mysql"}}
{{- $applyCdApps := list "agent-server" "antivirus" "ct" "doc" "jod" "load-balancer" "mail-inbound"  "opensocial" "ps" "mysql" }}
{{range $application := $allApps}}
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: {{ $application }}
  namespace: argocd
{{- if has $application $applyCdApps  }}
  labels:
    apply-cd: "true"
{{- end }}
spec:
  project: {{ $.Values.jam.namespace }}
  source:
    repoURL: https://github.tools.sap/sap-zone/jam-on-k8s
    targetRevision: {{ $.Values.argocd.targetRevision }}
    path: helm/jam/{{ $application }}
    helm:
      values: |
        argocd:
          runningInArgo: true
      valueFiles:
      - ../../../instances/{{ $.Values.jam.namespace }}-k8s.yaml
{{- if eq $.Values.argocd.autoSync true  }}
  syncPolicy:
    automated:
      prune: true
      selfHeal: false
{{- end }}
  destination:
    server: https://kubernetes.default.svc
    namespace: {{ $.Values.jam.namespace }}
{{end}}
```

* **allApps:**
	* elasticsearch, elasticsearch6, mail, memcached, rabbitmq
	* agent-server, antivirus, ct, doc, jod, load-balancer
	* mail-inbound, opensocial, ps, mysql
* **applyCdApps:**
	* agent-server, antivirus, ct, doc, jod, load-balancer
	* mail-inbound, opensocial, ps, mysql

### config.yaml

```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: config
  namespace: argocd
  labels:
    apply-cd: "true"
spec:
  project: {{ .Values.jam.namespace }}
  source:
    repoURL: https://github.tools.sap/sap-zone/jam-on-k8s
    targetRevision: {{ $.Values.argocd.targetRevision }}
    path: helm/jam/config
    helm:
      valueFiles:
      - ../../../instances/{{ $.Values.jam.namespace }}-k8s.yaml
      - ../../../instances/{{ $.Values.jam.namespace }}-config.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: {{ .Values.jam.namespace }}
{{- if eq $.Values.argocd.autoSync true  }}
  syncPolicy:
    automated:
      prune: false
      selfHeal: false
{{- end }}
```

### Sync argocd config

```
# after ArgoCD is installed and configured
argocd app sync config
```

```
helm install argocd-applications helm/argocd/applications -f instances/$..-k8s.yaml --namespace argocd
```

