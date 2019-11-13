# 23. Kafka : `kafka_exporter`

[`kafka_exporter`](https://github.com/danielqsj/kafka_exporter)

## 23.1. Kafka Topics

**Kafka topic in-sync partition**

```
- alert: KafkaTopics
  expr: sum(kafka_topic_partition_in_sync_replica) by (topic) < 3
  for: 5m
  labels:
    severity: error
  annotations:
    summary: "Kafka Topics (instance {{ $labels.instance }})"
    description: "Kafka topic in-sync partition\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 23.2. Kafka consumers group

**Kafka consumers group**

```
- alert: KafkaConsumersGroup
  expr: sum(kafka_consumergroup_lag) by (consumergroup) > 50
  for: 5m
  labels:
    severity: error
  annotations:
    summary: "Kafka consumers group (instance {{ $labels.instance }})"
    description: "Kafka consumers group\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```