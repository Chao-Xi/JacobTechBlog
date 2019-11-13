# 20. Consul : prometheus/consul_exporter

[Consul Exporter](https://github.com/prometheus/consul_exporter)

## 20.1. Service healthcheck failed

* **Service: `{{ $labels.service_name }}`** 
* **Healthcheck: `{{ $labels.service_id }}`**

```
- alert: ServiceHealthcheckFailed
  expr: consul_catalog_service_node_healthy == 0
  for: 5m
  labels:
    severity: error
  annotations:
    summary: "Service healthcheck failed (instance {{ $labels.instance }})"
    description: "Service: `{{ $labels.service_name }}` Healthcheck: `{{ $labels.service_id }}`\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 20.2. Missing Consul master node

**Numbers of consul raft peers less then expected` <https://example.ru/ui/{{ $labels.dc }}/services/consul|Consul masters>`**

```
- alert: MissingConsulMasterNode
  expr: consul_raft_peers < number_of_consul_master
  for: 5m
  labels:
    severity: error
  annotations:
    summary: "Missing Consul master node (instance {{ $labels.instance }})"
    description: "Numbers of consul raft peers less then expected <https://example.ru/ui/{{ $labels.dc }}/services/consul|Consul masters>\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```