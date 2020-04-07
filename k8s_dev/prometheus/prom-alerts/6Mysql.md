# 6. MySQL : prometheus/mysqld_exporter

[https://github.com/prometheus/mysqld_exporter](https://github.com/prometheus/mysqld_exporter)


* MYSQLDown
* MysqlQPSTooHigh
* [基于Prometheus构建MySQL可视化监控平台](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_dev/prometheus/36Prometheus_Mysql.md)

```
groups:
- name: MYSQL服务监控
  rules: 
  - alert: MYSQLDown
    expr: mysql_up != 1
    for: 10m
    labels:
      severity: critical
    annotations:
      summary: mysql server {{ $labels.realip }} is down. please check it in time.
  - alert: MysqlQPSTooHigh
    expr: (rate(mysql_global_status_queries{job="mysql_exporter"}[5m]) or irate(mysql_global_status_queries{job="mysql_exporter"}[5m])) > 300
    for: 10m
    labels:
      severity: critical
    annotations:
      summary: mysql server {{ $labels.realip }} QPS is too high. please keep an eyes on it.
```

