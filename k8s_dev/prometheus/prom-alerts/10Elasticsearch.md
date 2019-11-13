# 10. Elasticsearch: `elasticsearch_exporter`

[https://github.com/justwatchcom/elasticsearch_exporter](https://github.com/justwatchcom/elasticsearch_exporter)

## 10.1. Elastic Heap Usage Too High

**The heap usage is over 90% for 5m**

```
- alert: ElasticHeapUsageTooHigh
  expr: (elasticsearch_jvm_memory_used_bytes{area="heap"} / elasticsearch_jvm_memory_max_bytes{area="heap"}) * 100 > 90
  for: 5m
  labels:
    severity: error
  annotations:
    summary: "Elastic Heap Usage Too High (instance {{ $labels.instance }})"
    description: "The heap usage is over 90% for 5m\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 10.2. Elastic Heap Usage warning

**The heap usage is over 80% for 5m**

```
- alert: ElasticHeapUsageWarning
  expr: (elasticsearch_jvm_memory_used_bytes{area="heap"} / elasticsearch_jvm_memory_max_bytes{area="heap"}) * 100 > 80
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Elastic Heap Usage warning (instance {{ $labels.instance }})"
    description: "The heap usage is over 80% for 5m\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 10.3. Elastic Cluster Red

**Elastic Cluster Red status**

```
- alert: ElasticClusterRed
  expr: elasticsearch_cluster_health_status{color="red"} == 1
  for: 5m
  labels:
    severity: error
  annotations:
    summary: "Elastic Cluster Red (instance {{ $labels.instance }})"
    description: "Elastic Cluster Red status\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 10.4. Elastic Cluster Yellow

**Elastic Cluster Yellow status**

```
- alert: ElasticClusterYellow
  expr: elasticsearch_cluster_health_status{color="yellow"} == 1
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Elastic Cluster Yellow (instance {{ $labels.instance }})"
    description: "Elastic Cluster Yellow status\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 10.5. Number of Elastic Healthy Nodes

**Number Healthy Nodes less then `number_of_nodes`**

```
- alert: NumberOfElasticHealthyNodes
  expr: elasticsearch_cluster_health_number_of_nodes < number_of_nodes
  for: 5m
  labels:
    severity: error
  annotations:
    summary: "Number of Elastic Healthy Nodes (instance {{ $labels.instance }})"
    description: "Number Healthy Nodes less then number_of_nodes\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```


## 10.6. Number of Elastic Healthy Data Nodes

**Number Healthy Data Nodes less then `number_of_data_nodes`**

```
- alert: NumberOfElasticHealthyDataNodes
  expr: elasticsearch_cluster_health_number_of_data_nodes < number_of_data_nodes
  for: 5m
  labels:
    severity: error
  annotations:
    summary: "Number of Elastic Healthy Data Nodes (instance {{ $labels.instance }})"
    description: "Number Healthy Data Nodes less then number_of_data_nodes\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 10.7. Number of relocation shards

**Number of relocation shards for 20 min**

```
- alert: NumberOfRelocationShards
  expr: elasticsearch_cluster_health_relocating_shards > 0
  for: 5m
  labels:
    severity: error
  annotations:
    summary: "Number of relocation shards (instance {{ $labels.instance }})"
    description: "Number of relocation shards for 20 min\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 10.8. Number of initializing shards

**Number of initializing shards for 10 min**

```
- alert: NumberOfInitializingShards
  expr: elasticsearch_cluster_health_initializing_shards > 0
  for: 5m
  labels:
    severity: error
  annotations:
    summary: "Number of initializing shards (instance {{ $labels.instance }})"
    description: "Number of initializing shards for 10 min\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 10.9. Number of unassigned shards

**Number of unassigned shards for 2 min**

```
- alert: NumberOfUnassignedShards
  expr: elasticsearch_cluster_health_unassigned_shards > 0
  for: 5m
  labels:
    severity: error
  annotations:
    summary: "Number of unassigned shards (instance {{ $labels.instance }})"
    description: "Number of unassigned shards for 2 min\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 10.10. Number of pending tasks

**Number of pending tasks for 10 min. Cluster works slowly.**

```
- alert: NumberOfPendingTasks
  expr: elasticsearch_cluster_health_number_of_pending_tasks > 0
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Number of pending tasks (instance {{ $labels.instance }})"
    description: "Number of pending tasks for 10 min. Cluster works slowly.\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 10.11. Elastic no new documents

**No new documents for 10 min!**

```
- alert: ElasticNoNewDocuments
  expr: rate(elasticsearch_indices_docs{es_data_node="true"}[10m]) < 1
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Elastic no new documents (instance {{ $labels.instance }})"
    description: "No new documents for 10 min!\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```
