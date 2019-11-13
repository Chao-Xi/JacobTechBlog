# 3. Docker containers : cAdvisor

[https://github.com/google/cadvisor](https://github.com/google/cadvisor)

## 3.1. Container killed

**A container has disappeared**

```
- alert: ContainerKilled
  expr: time() - container_last_seen > 60
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Container killed (instance {{ $labels.instance }})"
    description: "A container has disappeared\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 3.2. Container CPU usage

**Container CPU usage is above 80%**
 
```
- alert: ContainerCpuUsage
  expr: (sum(rate(container_cpu_usage_seconds_total[3m])) BY (ip, name) * 100) > 80
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Container CPU usage (instance {{ $labels.instance }})"
    description: "Container CPU usage is above 80%\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 3.3. Container Memory usage

**Container Memory usage is above 80%**

```
- alert: ContainerMemoryUsage
  expr: (sum(container_memory_usage_bytes) BY (ip) / sum(container_memory_max_usage_bytes) BY (ip) * 100) > 80
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Container Memory usage (instance {{ $labels.instance }})"
    description: "Container Memory usage is above 80%\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 3.4. Container Volume usage

**Container Volume usage is above 80%**

```
- alert: ContainerVolumeUsage
  expr: (1 - (sum(container_fs_inodes_free) BY (ip) / sum(container_fs_inodes_total) BY (ip)) * 100) > 80
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Container Volume usage (instance {{ $labels.instance }})"
    description: "Container Volume usage is above 80%\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 3.5. Container Volume IO usage


**Container Volume IO usage is above 80%**

```
- alert: ContainerVolumeIoUsage
  expr: (sum(container_fs_io_current) BY (ip, name) * 100) > 80
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Container Volume IO usage (instance {{ $labels.instance }})"
    description: "Container Volume IO usage is above 80%\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

