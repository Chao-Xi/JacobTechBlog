# Jam on Argocd


```
$ tree argocd/
argocd/
├── applications
│   ├── Chart.yaml
│   ├── templates
│   │   ├── argocd.yaml
│   │   ├── jam.yaml
│   │   └── logging.yaml
│   └── values.yaml
└── projects
    ├── Chart.yaml
    ├── templates
    │   └── projects.yaml
    └── values.yaml

4 directories, 8 files
```

### Project

ArgoCD could both deploy apps whin the same k8s cluster it been deployed at or an external cluster. So we can define multiple projects. Since we are only dealing with in-cluster apps, we use projects to distinguish deferent function modules. We have three projects defined: 

* **`$JAM_INSTANCE`**: the project contains all of our business services related to jam; 
* **logging**: the project contains EFK stack, and 
* **arogocd**: contains both ArgoCD project and ArgoCD application definitions. 

So the definitions for applications are self-deployed.

### Application:

An application equals a helm release. We have all the jam services application definitions in our repository. We can define the helm chart path, value path, sync policy, and target GitHub branch for a certain application.

### Sync:

Sync means deployment. ArgoCD will sync with the target repository every couple minutes and use helm to render templates. 

* If the rendered manifest is different from the online manifest, ArgoCD will mark the application as **"out of sync"**. 
* If the application is configured as **"auto sync"**, ArgoCD will automatically deploy the outdated applications, or we need to deploy it manually.
*  ArgoCD will also convert helm hook to Argo hook, but not 100% precise. **The pre-install and post-install hooks will become pre-sync and post-sync hooks**. **So they will be executed every sync**.

```
$ argocd repo add https://github.... --username github-serviceuser --password github-token
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
  - 'https://github....'
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
```

**projects**:

* **logging**
* **argocd**
* **`.Values.jam.namespace`**: `dev902`

```
helm install argocd-projects helm/argocd/projects -f instances/$NSTANCE-k8s.yaml --namespace argocd
```

## applications


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
version: 
```



### argocd application: `templates/argocd.yaml`

```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: argocd-projects
  namespace: argocd
spec:
  project: argocd
  source:
    repoURL: https://github...
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
    repoURL: https://...
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

* Application: `argocd-projects`
* Application: `argocd-applications`


### logging application: `templates/logging.yaml`

```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: logging
  namespace: argocd
spec:
  project: logging
  source:
    repoURL: https://github...
    targetRevision: {{ $.Values.argocd.targetRevision }}
    path: helm/charts/logging
    helm:
      valueFiles:
      - ../../../instances/{{ $.Values.jam.namespace }}-k8s.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: logging
```

* Application: `logging `


### jam application: `templates/jam.yaml`


```
{{- $allApps := list "elasticsearch" "elasticsearch6" "mail" "memcached" "rabbitmq" "agent-server" "antivirus" "ct" "doc" "jod" "load-balancer" "mail-inbound"  "opensocial" "ps" }}
{{- $applyCdApps := list "agent-server" "antivirus" "ct" "doc" "jod" "load-balancer" "mail-inbound"  "opensocial" "ps" }}
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
    repoURL: https://github....
    targetRevision: {{ $.Values.argocd.targetRevision }}
    path: helm/jam/{{ $application }}
    helm:
      values: |
        argocd:
          runningInArgo: true
      valueFiles:
      - ../../../instances/{{ $.Values.jam.namespace }}-k8s.yaml
{{- if and (has $application $applyCdApps) (eq $.Values.argocd.dailyBuild true)  }}
      - ../../../instances/argo_nonce.yaml
{{- end }}
{{- if and (has $application $applyCdApps) (eq $.Values.argocd.syncWithCurrentRelease true)  }}
      - ../../../instances/current_release.yaml
{{- end }}
{{- if eq $.Values.argocd.autoSync true  }}
  syncPolicy:
    automated:
      prune: false
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
	* mail-inbound, opensocial, ps
* **applyCdApps:**
	* agent-server, antivirus, ct, doc, jod, load-balancer
	* mail-inbound, opensocial, ps
* **Excluede**
	*  mail, memcached, rabbitmq

	
### argocd jam application related value

```
argocd:
	dayilyBuild: false
	autoSync: false
	syncWithCurrentRelease: false
	targetRevision: master
```


```
{{range $application := $allApps}}
	

{{- if has $application $applyCdApps  }}
labels:
	apply-cd: "true"
{{- end }}
	

{{- if and (has $application $applyCdApps) (eq $.Values.argocd.dailyBuild true)  }}
	- ../../../instances/argo_nonce.yaml
{{- end }}


{{- if and (has $application $applyCdApps) (eq $.Values.argocd.syncWithCurrentRelease true)  }}
    - ../../../instances/current_release.yaml
{{- end }}

{{- if eq $.Values.argocd.autoSync true  }}
  syncPolicy:
    automated:
      prune: false
      selfHeal: false
{{- end }}

{{end}}
```

### `argo_nonce.yaml`

```
argocd:
  nonce: '20200229000022'
```

### `current_release.yaml`

```
jam:
  release: RNumber
```

```
helm install argocd-applications helm/argocd/applications -f instances/$..-k8s.yaml --namespace argocd
```