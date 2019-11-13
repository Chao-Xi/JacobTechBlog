# 7. PostgreSQL

[https://github.com/wrouesnel/postgres_exporter/](https://github.com/wrouesnel/postgres_exporter/)

## 7.1. PostgreSQL down

**PostgreSQL instance is down**

```
- alert: PostgresqlDown
  expr: pg_up == 0
  for: 5m
  labels:
    severity: error
  annotations:
    summary: "PostgreSQL down (instance {{ $labels.instance }})"
    description: "PostgreSQL instance is down\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 7.2. Replication lag

**PostgreSQL replication lag is going up (> 10s)**

```
- alert: ReplicationLag
  expr: pg_replication_lag > 10
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Replication lag (instance {{ $labels.instance }})"
    description: "PostgreSQL replication lag is going up (> 10s)\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 7.3. Table not vaccumed

**Table has not been vaccum for 24 hours**

```
- alert: TableNotVaccumed
  expr: time() - pg_stat_user_tables_last_autovacuum > 60 * 60 * 24
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Table not vaccumed (instance {{ $labels.instance }})"
    description: "Table has not been vaccum for 24 hours\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 7.4. Table not analyzed

**Table has not been analyzed for 24 hours**
 
```
- alert: TableNotAnalyzed
  expr: time() - pg_stat_user_tables_last_autoanalyze > 60 * 60 * 24
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Table not analyzed (instance {{ $labels.instance }})"
    description: "Table has not been analyzed for 24 hours\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 7.5. Too many connections

**PostgreSQL instance has too many connections**

```
- alert: TooManyConnections
  expr: sum by (datname) (pg_stat_activity_count{datname!~"template.*|postgres"}) > 100
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Too many connections (instance {{ $labels.instance }})"
    description: "PostgreSQL instance has too many connections\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```


## 7.6. Not enough connections

**PostgreSQL instance should have more connections (> 5)**
 
```
- alert: NotEnoughConnections
  expr: sum by (datname) (pg_stat_activity_count{datname!~"template.*|postgres"}) < 5
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Not enough connections (instance {{ $labels.instance }})"
    description: "PostgreSQL instance should have more connections (> 5)\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 7.7. Dead locks

**PostgreSQL has dead-locks**

```
- alert: DeadLocks
  expr: rate(pg_stat_database_deadlocks{datname!~"template.*|postgres"}[1m]) > 0
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Dead locks (instance {{ $labels.instance }})"
    description: "PostgreSQL has dead-locks\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```


## 7.8. Slow queries

**PostgreSQL executes slow queries (> 1min)**

```
- alert: SlowQueries
  expr: avg(rate(pg_stat_activity_max_tx_duration{datname!~"template.*"}[1m])) BY (datname) > 60
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Slow queries (instance {{ $labels.instance }})"
    description: "PostgreSQL executes slow queries (> 1min)\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

## 7.9. High rollback rate

**Ratio of transactions being aborted compared to committed is > 2 %**

```
- alert: HighRollbackRate
  expr: rate(pg_stat_database_xact_rollback{datname!~"template.*"}[3m]) / rate(pg_stat_database_xact_commit{datname!~"template.*"}[3m]) > 0.02
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "High rollback rate (instance {{ $labels.instance }})"
    description: "Ratio of transactions being aborted compared to committed is > 2 %\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

