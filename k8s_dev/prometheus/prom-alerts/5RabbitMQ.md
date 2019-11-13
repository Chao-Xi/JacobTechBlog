# 5. RabbitMQ : kbudde/rabbitmq-exporter

[https://github.com/kbudde/rabbitmq_exporter](https://github.com/kbudde/rabbitmq_exporter)

## 5.1. Rabbitmq down


**RabbitMQ node down**

```
- alert: RabbitmqDown
  expr: rabbitmq_up == 0
  for: 5m
  labels:
    severity: error
  annotations:
    summary: "Rabbitmq down (instance {{ $labels.instance }})"
    description: "RabbitMQ node down\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 5.2. Cluster down

**Less than 3 nodes running in RabbitMQ cluster**

```
- alert: ClusterDown
  expr: rabbitmq_running < 3
  for: 5m
  labels:
    severity: error
  annotations:
    summary: "Cluster down (instance {{ $labels.instance }})"
    description: "Less than 3 nodes running in RabbitMQ cluster\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 5.3. Cluster partition

**Cluster partition**

```
- alert: ClusterPartition
  expr: rabbitmq_partitions > 0
  for: 5m
  labels:
    severity: error
  annotations:
    summary: "Cluster partition (instance {{ $labels.instance }})"
    description: "Cluster partition\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 5.4. Out of memory

**Memory available for RabbmitMQ is low (< 10%)**

```
- alert: OutOfMemory
  expr: rabbitmq_node_mem_used / rabbitmq_node_mem_limit * 100 > 90
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Out of memory (instance {{ $labels.instance }})"
    description: "Memory available for RabbmitMQ is low (< 10%)\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
 ```
 
 
## 5.5. Too many connections

**RabbitMQ instance has too many connections (> 1000)**

```
- alert: TooManyConnections
  expr: rabbitmq_connectionsTotal > 1000
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Too many connections (instance {{ $labels.instance }})"
    description: "RabbitMQ instance has too many connections (> 1000)\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 5.6. Dead letter queue filling up

**Dead letter queue is filling up (> 10 msgs)**

```
- alert: DeadLetterQueueFillingUp
  expr: rabbitmq_queue_messages{queue="my-dead-letter-queue"} > 10
  for: 5m
  labels:
    severity: error
  annotations:
    summary: "Dead letter queue filling up (instance {{ $labels.instance }})"
    description: "Dead letter queue is filling up (> 10 msgs)\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 5.7. Too many messages in queue

**Queue is filling up (> 1000 msgs)**

```
- alert: TooManyMessagesInQueue
  expr: rabbitmq_queue_messages_ready{queue="my-queue"} > 1000
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Too many messages in queue (instance {{ $labels.instance }})"
    description: "Queue is filling up (> 1000 msgs)\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 5.8. Slow queue consuming

**Queue messages are consumed slowly (> 60s)**

```
- alert: SlowQueueConsuming
  expr: time() - rabbitmq_queue_head_message_timestamp{queue="my-queue"} > 60
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Slow queue consuming (instance {{ $labels.instance }})"
    description: "Queue messages are consumed slowly (> 60s)\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 5.9. No consumer

**Queue has no consumer**

```
- alert: NoConsumer
  expr: rabbitmq_queue_consumers == 0
  for: 5m
  labels:
    severity: error
  annotations:
    summary: "No consumer (instance {{ $labels.instance }})"
    description: "Queue has no consumer\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 5.10. Too many consumers

**Queue should have only 1 consumer**

```
- alert: TooManyConsumers
  expr: rabbitmq_queue_consumers > 1
  for: 5m
  labels:
    severity: error
  annotations:
    summary: "Too many consumers (instance {{ $labels.instance }})"
    description: "Queue should have only 1 consumer\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 5.11. Unactive exchange


**Exchange receive less than 5 msgs per second**

```
- alert: UnactiveExchange
  expr: rate(rabbitmq_exchange_messages_published_in_total{exchange="my-exchange"}[1m]) < 5
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Unactive exchange (instance {{ $labels.instance }})"
    description: "Exchange receive less than 5 msgs per second\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

