# 28. Minio

# 28.1. Disk down

**Minio Disk is down\n `VALUE = {{ $value }}\n LABELS: {{ $labels }}`**

```
- alert: DiskDown
  expr: minio_offline_disks > 0
  for: 5m
  labels:
    severity: error
  annotations:
    summary: "Disk down (instance {{ $labels.instance }})"
    description: "Minio Disk is down\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```