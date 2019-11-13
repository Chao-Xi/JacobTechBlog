# 18. Kubernetes : kube-state-metrics

[kube-state-metrics](https://github.com/kubernetes/kube-state-metrics/tree/master/docs)

## 18.1. Kubernetes MemoryPressure


**`{{ $labels.node }}` has MemoryPressure condition**

```
- alert: KubernetesMemorypressure
  expr: kube_node_status_condition{condition="MemoryPressure",status="true"} == 1
  for: 5m
  labels:
    severity: error
  annotations:
    summary: "Kubernetes MemoryPressure (instance {{ $labels.instance }})"
    description: "{{ $labels.node }} has MemoryPressure condition\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 18.2. Kubernetes DiskPressure

**`{{ $labels.node }}` has DiskPressure condition**

```
- alert: KubernetesDiskpressure
  expr: kube_node_status_condition{condition="DiskPressure",status="true"} == 1
  for: 5m
  labels:
    severity: error
  annotations:
    summary: "Kubernetes DiskPressure (instance {{ $labels.instance }})"
    description: "{{ $labels.node }} has DiskPressure condition\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 18.3. Kubernetes OutOfDisk

**` {{ $labels.node }}` has OutOfDisk condition**

```
- alert: KubernetesOutofdisk
  expr: kube_node_status_condition{condition="OutOfDisk",status="true"} == 1
  for: 5m
  labels:
    severity: error
  annotations:
    summary: "Kubernetes OutOfDisk (instance {{ $labels.instance }})"
    description: "{{ $labels.node }} has OutOfDisk condition\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 18.4. Kubernetes Job failed

**Job `{{$labels.namespace}}/{{$labels.exported_job}} ` failed to complete**

```
- alert: KubernetesJobFailed
  expr: kube_job_status_failed > 0
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Kubernetes Job failed (instance {{ $labels.instance }})"
    description: "Job {{$labels.namespace}}/{{$labels.exported_job}} failed to complete\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 18.5. Kubernetes CronJob suspended

**CronJob `{{ $labels.namespace }}/{{ $labels.cronjob }}` is suspended**

```
- alert: KubernetesCronjobSuspended
  expr: kube_cronjob_spec_suspend != 0
  for: 5m
  labels:
    severity: info
  annotations:
    summary: "Kubernetes CronJob suspended (instance {{ $labels.instance }})"
    description: "CronJob {{ $labels.namespace }}/{{ $labels.cronjob }} is suspended\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 18.6. Kubernetes PersistentVolumeClaim pending

**PersistentVolumeClaim `{{ $labels.namespace }}/{{ $labels.persistentvolumeclaim }} ` is pending**

```
- alert: KubernetesPersistentvolumeclaimPending
  expr: kube_persistentvolumeclaim_status_phase{phase="Pending"} == 1
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Kubernetes PersistentVolumeClaim pending (instance {{ $labels.instance }})"
    description: "PersistentVolumeClaim {{ $labels.namespace }}/{{ $labels.persistentvolumeclaim }} is pending\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 18.7. Volume out of disk space

**Volume is almost full (< 10% left)**

```
- alert: VolumeOutOfDiskSpace
  expr: kubelet_volume_stats_available_bytes / kubelet_volume_stats_capacity_bytes * 100 < 10
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Volume out of disk space (instance {{ $labels.instance }})"
    description: "Volume is almost full (< 10% left)\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```
## 18.8. Volume full in four days

**`{{ $labels.namespace }}/{{ $labels.persistentvolumeclaim }}` is expected to fill up within four days. Currently `{{ $value | humanize }}%` is available.**

```
- alert: VolumeFullInFourDays
  expr: 100 * (kubelet_volume_stats_available_bytes / kubelet_volume_stats_capacity_bytes) < 15 and predict_linear(kubelet_volume_stats_available_bytes[6h], 4 * 24 * 3600) < 0
  for: 5m
  labels:
    severity: error
  annotations:
    summary: "Volume full in four days (instance {{ $labels.instance }})"
    description: "{{ $labels.namespace }}/{{ $labels.persistentvolumeclaim }} is expected to fill up within four days. Currently {{ $value | humanize }}% is available.\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 18.9. StatefulSet down

**A StatefulSet went down**

```
- alert: StatefulsetDown
  expr: (kube_statefulset_status_replicas_ready / kube_statefulset_status_replicas_current) != 1
  for: 5m
  labels:
    severity: error
  annotations:
    summary: "StatefulSet down (instance {{ $labels.instance }})"
    description: "A StatefulSet went down\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

