# 2. Host : node-exporter

## 2.1. Out of memory

###  Node memory is filling up (< 10% left)

```
- alert: OutOfMemory
  expr: node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes * 100 < 10
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Out of memory (instance {{ $labels.instance }})"
    description: "Node memory is filling up (< 10% left)\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 2.2. Unusual network throughput in

### Host network interfaces are probably receiving too much data (> `100` MB/s)

```
- alert: UnusualNetworkThroughputIn
  expr: sum by (instance) (irate(node_network_receive_bytes_total[2m])) / 1024 / 1024 > 100
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Unusual network throughput in (instance {{ $labels.instance }})"
    description: "Host network interfaces are probably receiving too much data (> 100 MB/s)\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 2.3. Unusual network throughput out

###  Host network interfaces are probably sending too much data (> 100 MB/s)

```
- alert: UnusualNetworkThroughputOut
  expr: sum by (instance) (irate(node_network_transmit_bytes_total[2m])) / 1024 / 1024 > 100
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Unusual network throughput out (instance {{ $labels.instance }})"
    description: "Host network interfaces are probably sending too much data (> 100 MB/s)\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```


## 2.4. Unusual disk read rate

###  Disk is probably reading too much data (> 50 MB/s)

```
- alert: UnusualDiskReadRate
  expr: sum by (instance) (irate(node_disk_read_bytes_total[2m])) / 1024 / 1024 > 50
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Unusual disk read rate (instance {{ $labels.instance }})"
    description: "Disk is probably reading too much data (> 50 MB/s)\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 2.5. Unusual disk write rate

###  Disk is probably writing too much data (> 50 MB/s)

```
- alert: UnusualDiskWriteRate
  expr: sum by (instance) (irate(node_disk_written_bytes_total[2m])) / 1024 / 1024 > 50
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Unusual disk write rate (instance {{ $labels.instance }})"
    description: "Disk is probably writing too much data (> 50 MB/s)\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 2.6. Out of disk space

###  Disk is almost full (< 10% left)

```
- alert: OutOfDiskSpace
  expr: node_filesystem_free_bytes{mountpoint ="/rootfs"} / node_filesystem_size_bytes{mountpoint ="/rootfs"} * 100 < 10
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Out of disk space (instance {{ $labels.instance }})"
    description: "Disk is almost full (< 10% left)\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 2.7. Out of inodes

Disk is almost running out of available inodes (< 10% left)

```
- alert: OutOfInodes
  expr: node_filesystem_files_free{mountpoint ="/rootfs"} / node_filesystem_files{mountpoint ="/rootfs"} * 100 < 10
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Out of inodes (instance {{ $labels.instance }})"
    description: "Disk is almost running out of available inodes (< 10% left)\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 2.8. Unusual disk read latency

Disk latency is growing (read operations > 100ms)
 
```
- alert: UnusualDiskReadLatency
  expr: rate(node_disk_read_time_seconds_total[1m]) / rate(node_disk_reads_completed_total[1m]) > 100
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Unusual disk read latency (instance {{ $labels.instance }})"
    description: "Disk latency is growing (read operations > 100ms)\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```


## 2.9. Unusual disk write latency

Disk latency is growing (write operations > 100ms)

```
- alert: UnusualDiskWriteLatency
  expr: rate(node_disk_write_time_seconds_total[1m]) / rate(node_disk_writes_completed_total[1m]) > 100
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Unusual disk write latency (instance {{ $labels.instance }})"
    description: "Disk latency is growing (write operations > 100ms)\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 2.10. High CPU load

CPU load is > 80%
 
```
- alert: HighCpuLoad
  expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "High CPU load (instance {{ $labels.instance }})"
    description: "CPU load is > 80%\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 2.11. Context switching

Context switching is growing on node (> 1000 / s)

```
# 1000 context switches is an arbitrary number.
# Alert threshold depends on nature of application.
# Please read: https://github.com/samber/awesome-prometheus-alerts/issues/58

- alert: ContextSwitching
  expr: rate(node_context_switches_total[5m]) > 1000
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Context switching (instance {{ $labels.instance }})"
    description: "Context switching is growing on node (> 1000 / s)\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 2.12. Swap is filling up

Swap is filling up (>80%)

```
- alert: SwapIsFillingUp
  expr: (1 - (node_memory_SwapFree_bytes / node_memory_SwapTotal_bytes)) * 100 > 80
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Swap is filling up (instance {{ $labels.instance }})"
    description: "Swap is filling up (>80%)\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 2.13. SystemD service crashed

SystemD service crashed

```
- alert: SystemdServiceCrashed
  expr: node_systemd_unit_state{state="failed"} == 1
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "SystemD service crashed (instance {{ $labels.instance }})"
    description: "SystemD service crashed\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```