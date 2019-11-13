# 4. Nginx : nginx-lua-prometheus

[https://github.com/knyar/nginx-lua-prometheus](https://github.com/knyar/nginx-lua-prometheus)

## 4.1. HTTP errors 4xx

**Too many HTTP requests with status 4xx (> 5%)**

```
- alert: HttpErrors4xx
  expr: sum(rate(nginx_http_requests_total{status=~"^4.."}[1m])) / sum(rate(nginx_http_requests_total[1m])) * 100 > 5
  for: 5m
  labels:
    severity: error
  annotations:
    summary: "HTTP errors 4xx (instance {{ $labels.instance }})"
    description: "Too many HTTP requests with status 4xx (> 5%)\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 4.2. HTTP errors 5xx

**Too many HTTP requests with status 5xx (> 5%)**

```
- alert: HttpErrors5xx
  expr: sum(rate(nginx_http_requests_total{status=~"^5.."}[1m])) / sum(rate(nginx_http_requests_total[1m])) * 100 > 5
  for: 5m
  labels:
    severity: error
  annotations:
    summary: "HTTP errors 5xx (instance {{ $labels.instance }})"
    description: "Too many HTTP requests with status 5xx (> 5%)\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```


