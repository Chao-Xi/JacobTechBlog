# 1. Prometheus

## 1.1. Prometheus configuration reload

###  Prometheus configuration reload error

```
- alert: PrometheusConfigurationReload
  expr: prometheus_config_last_reload_successful != 1
  for: 5m
  labels:
    severity: error
  annotations:
    summary: "Prometheus configuration reload (instance {{ $labels.instance }})"
    description: "Prometheus configuration reload error\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"

```


## 1.2. AlertManager configuration reload

###  AlertManager configuration reload error

```
- alert: AlertmanagerConfigurationReload
  expr: alertmanager_config_last_reload_successful != 1
  for: 5m
  labels:
    severity: error
  annotations:
    summary: "AlertManager configuration reload (instance {{ $labels.instance }})"
    description: "AlertManager configuration reload error\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```


## 1.3. Exporter down

### Prometheus exporter down

```
- alert: ExporterDown
  expr: up == 0
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Exporter down (instance {{ $labels.instance }})"
    description: "Prometheus exporter down\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

