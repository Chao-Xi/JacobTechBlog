# 14. Traefik v1.*



## 14.1. Traefik backend down
 
**All Traefik backends are down**

```
- alert: TraefikBackendDown
  expr: count(traefik_backend_server_up) by (backend) == 0
  for: 5m
  labels:
    severity: error
  annotations:
    summary: "Traefik backend down (instance {{ $labels.instance }})"
    description: "All Traefik backends are down\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 14.2. Traefik backend errors

**Traefik backend error rate is above 10%**

```
- alert: TraefikBackendErrors
  expr: sum(rate(traefik_backend_requests_total{code=~"5.*"}[5m])) by (backend) / sum(rate(traefik_backend_requests_total[5m])) by (backend) > 0.1
  for: 5m
  labels:
    severity: error
  annotations:
    summary: "Traefik backend errors (instance {{ $labels.instance }})"
    description: "Traefik backend error rate is above 10%\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

