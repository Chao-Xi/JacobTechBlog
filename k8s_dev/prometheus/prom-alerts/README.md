# Marvelous Prometheus alerts

**Reference**: [https://awesome-prometheus-alerts.grep.to/rules](https://awesome-prometheus-alerts.grep.to/rules)

1. [**Prometheus**](1Prometheus.md)
  * **Prometheus configuration reload**(Prometheus configuration reload error)
  * **AlertManager configuration reload**(AlertManager configuration reload error)
  * **Exporter down**(Prometheus exporter down)

2. [**Host : node-exporter**](2Host_node-exporter.md)
  * **Out of memory** [Node memory is filling up (`< 10% left`)]
  * **Unusual network throughput out** [Host network interfaces are probably sending too much data (`> 100 MB/s`)]
  * **Unusual disk read rate**[Disk is probably reading too much data (`> 50 MB/s`)]
  * **Unusual disk write rate**[Disk is probably writing too much data (`> 50 MB/s`)]
  * **Out of disk space**[Disk is almost full (`< 10% left`)]
  * **Out of inodes**[Disk is almost running out of available inodes (`< 10% left`)]
  * **Unusual disk read latency**[Swap is filling up (`>80%`)]
  * **Unusual disk write latency**[Disk latency is growing (`write operations > 100ms`)]
  * **High CPU load**[`CPU load is > 80%`]
  * **Context switching**[Context switching is growing on node (> 1000 / s)]
  * **Swap is filling up**[Swap is filling up (`>80%`)]
  * **SystemD service crashed**[SystemD service crashed]

3. [**Docker containers : cAdvisor**](3Docker_cadvisor.md)
  * **Container killed** [A container has disappeared] 
  * **Container CPU usage**[Container CPU usage is above `80%`]
  * **Container Memory usage**[Container Memory usage is above `80%`]
  * **Container Volume usage**[Container Volume usage is above `80%`]
  * **Container Volume IO usage**[Container Volume IO usage is above `80%`]
4. [**Nginx : nginx-lua-prometheus**](4Nginx.md)
  * **HTTP errors 4xx**[Too many HTTP requests with status `4xx (> 5%)`]
  * **HTTP errors 5xx**[Too many HTTP requests with status `5xx (> 5%)`]
5. [**RabbitMQ : kbudde/rabbitmq-exporter**](5RabbitMQ.md) 
  * **Rabbitmq down**[RabbitMQ node down]
  * **Cluster down**[Less than 3 nodes running in RabbitMQ cluster]
  * **Cluster partition**
  * **Out of memory**[Memory available for RabbmitMQ is low (`< 10%`)]
  * **Too many connections**[RabbitMQ instance has too many connections (`> 1000`)]
  * **Dead letter queue filling up**[Dead letter queue is filling up `(> 10 msgs`)]
  * **Too many messages in queue**[Queue is filling up (> 1000 msgs)]
  * **Slow queue consuming**[Queue messages are consumed slowly (> 60s)]
  * **No consumer**[Queue has no consumer]
  * **Too many consumers**[Queue should have only 1 consumer]
  * **Unactive exchange**[Exchange receive less than 5 msgs per second]
6. [**MySQL : prometheus/mysqld_exporter**](6Mysql.md)
  * MYSQLDown
  * MysqlQPSTooHigh
  * [基于Prometheus构建MySQL可视化监控平台](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_dev/prometheus/36Prometheus_Mysql.md)
7. [**PostgreSQL**](7PostgreSQL.md)
  * **PostgreSQL down**[PostgreSQL instance is down]
  * **Replication lag**[PostgreSQL replication lag is going up (`> 10s`)]
  * **Table not vaccumed**[Table has not been vaccum for 24 hours]
  * **Table not analyzed**[Table has not been analyzed for 24 hours]
  * **Too many connections**[PostgreSQL instance has too many connections]
  * **Not enough connections**[PostgreSQL instance should have more connections `(> 5)`]
  * **Dead locks**[PostgreSQL has dead-locks]
  * **Slow queries**[PostgreSQL executes slow queries (`> 1min`)]
  * **High rollback rate**[Ratio of transactions being aborted compared to committed is > `2 %`]
8. [**Redis**](8Redis.md)
  * **Redis down**[Redis instance is down] 
  * **Missing backup**[Redis has not been backuped for 24 hours]
  * **Out of memory**[Redis is running out of memory (`> 90%`)]
  * **Replication broken**[Redis instance lost a slave]
  * **Too many connections**[Redis instance has too many connections]
  * **Not enough connections**[Redis instance should have more connections (`> 5`)]
  * **Rejected connections**[Some connections to Redis has been rejected]
9. [**MongoDB `mongodb_exporter`**](9Mongodb.md)
  * **MongoDB replication lag**[Mongodb replication lag is more than 10s]
  * **MongoDB replication headroom**[MongoDB replication headroom is `<= 0`]
  * **MongoDB replication Status 3**[MongoDB Replication set member either perform startup self-checks, or transition from completing a rollback or resync]
  * **MongoDB replication Status 6**[MongoDB Replication set member as seen from another member of the set, is not yet known]
  * **MongoDB replication Status 8**[MongoDB Replication set member as seen from another member of the set, is unreachable]
  * **MongoDB replication Status 9**[MongoDB Replication set member is actively performing a rollback. Data is not available for reads]
  * **MongoDB replication Status 10**[MongoDB Replication set member was once in a replica set but was subsequently removed]
  * **MongoDB number cursors open**[Too many cursors opened by MongoDB for clients (`> 10k`)]
  * **MongoDB cursors timeouts**[Too many cursors are timing out]
  * **MongoDB too many connections**[Too many connections]
  * **MongoDB virtual memory usage**[High memory usage]
10. [Elasticsearch: `elasticsearch_exporter`](10Elasticsearch.md)
  * **Elastic Heap Usage Too High** `The heap usage is over 90% for 5m`
  * **Elastic Heap Usage warning** `The heap usage is over 80% for 5m`
  * **Elastic Cluster Red**`Elastic Cluster Red status`
  * **Elastic Cluster Yellow**`Elastic Cluster Yellow status`
  * **Number of Elastic Healthy Nodes** Number Healthy Nodes less then `number_of_nodes`
  * **Number of Elastic Healthy Data Nodes** Number Healthy Data Nodes less then `number_of_data_nodes`
  * **Number of relocation shards**[Number of relocation shards for 20 min]
  * **Number of initializing shards**[Number of initializing shards for 10 min]
  * **Number of unassigned shards**[Number of unassigned shards for 2 min]
  * **Number of pending tasks**[Number of pending tasks for 10 min. Cluster works slowly]
  * **Elastic no new documents**[No new documents for 10 min!]

11. [Cassandra `cassandra_exporter`](11Cassandra.md)
12. [Apache `apache_exporter`](12Apache.md)
13. [HaProxy `haproxy_exporter`](13HaProxy.md)
14. [Traefik v1.*](14Traefikv1.md)
  * **Traefik backend down**[All Traefik backends are down]
  * **Traefik backend errors**[Traefik backend error rate is above 10%]
15. [PHP-FPM `php-fpm-exporter`](15PHP-FPM.md)
16. [Java : java-client](16Java.md)
  * **JVM memory filling up**
17. [ZFS : node-exporter](17zfs.md)
18. [Kubernetes : kube-state-metrics](18Kubernetes.md)
  * **Kubernetes MemoryPressure**[`{{ $labels.node }}` has MemoryPressure condition]
  * **Kubernetes DiskPressure**[`{{ $labels.node }}` has DiskPressure condition]
  * **Kubernetes OutOfDisk**
19. [Nomad : prometheus-nomad-exporter](19Nomad.md)
20. [Consul : prometheus/consul_exporter](20Consul.md)
  * **Service healthcheck failed**[Service: `{{ $labels.service_name }}` and Healthcheck: `{{ $labels.service_id }}`]
  * **Missing Consul master node**[Numbers of consul raft peers less then expected` <https://example.ru/ui/{{ $labels.dc }}/services/consul|Consul masters>`]
21. [Etcd](21Etcd.md)
  * **Insufficient Members**[Etcd cluster should have an odd number of members]
  * **No Leader**[Etcd cluster have no leader]
  * **High number of leader changes**[Etcd leader changed more than 3 times during last hour]
  * **High number of failed GRPC requests**[More than 1% GRPC request failure detected in Etcd for 5 minutes]
  * **High number of failed GRPC requests**[More than 5% GRPC request failure detected in Etcd for 5 minutes]
  * **GRPC requests slow**[GRPC requests slowing down, 99th percentil is over 0.15s for 5 minutes]
  * **High number of failed HTTP requests**[More than 1% HTTP failure detected in Etcd for 5 minutes]
  * **High number of failed HTTP requests**[More than 5% HTTP failure detected in Etcd for 5 minutes]
  * **HTTP requests slow**[HTTP requests slowing down, 99th percentil is over 0.15s for 5 minutes]
  * **Etcd member communication slow**[Etcd member communication slowing down, 99th percentil is over 0.15s for 5 minutes]
  * **High number of failed proposals**[Etcd server got more than 5 failed proposals past hour]
  * **High fsync durations**[Etcd WAL fsync duration increasing, 99th percentil is over 0.5s for 5 minutes]
  * **High commit durations**[Etcd commit duration increasing, 99th percentil is over 0.25s for 5 minutes]
22. [Zookeeper: kafka_zookeeper_exporter](22Zookkeeper.md)
23. [Kafka : `kafka_exporter`](23Kafka.md)
  * **Kafka Topics**[Kafka topic in-sync partition]
  * **Kafka consumers group**[Kafka consumers group]
24. [Linkerd](24Linkerd.md)
25. [Istio](25Istio.md)
26. [Blackbox : `prometheus/blackbox_exporter`](26Blackbox.md)
  * **Probe failed**[Probe failed]
  * **Slow probe**[Blackbox probe took more than 1s to complete]
  * **HTTP Status Code**[HTTP status code is not`200-399`]
  * **SSL certificate will expire soon**[SSL certificate expires in 30 days]
  * **SSL certificate expired**[SSL certificate has expired already]
  * **HTTP slow requests**[HTTP request took more than 1s]
  * **Slow ping**[Blackbox ping took more than 1s]
27. [OpenEBS](27OpenEBS.md)
  * **Used pool capacity**[OpenEBS Pool use more than 80% of his capacity ` \n VALUE = {{ $value }}\n LABELS: {{ $labels }}`]
28. [Minio](28Minio.md)
  *  **Disk down**[Minio Disk is down`\n VALUE = {{ $value }}\n LABELS: {{ $labels }}`]
29. [Juniper : `junos_exporter`](29Juniper.md)
  * **Switch is down**[The switch appears to be down]
  * **High Bandwith Usage 1GiB**[Interface is highly saturated for at least 1 min. `(> 0.90GiB/s)`]
  * **High Bandwith Usage 1GiB**[Interface is getting saturated for at least 1 min. `(> 0.80GiB/s)`]
30. [CoreDNS](30CoreDNS.md)
  * **CoreDNS Panic Count**
  
## AlertManager configuration

```
# alertmanager.yml

route:
  # When a new group of alerts is created by an incoming alert, wait at
  # least 'group_wait' to send the initial notification.
  # This way ensures that you get multiple alerts for the same group that start
  # firing shortly after another are batched together on the first
  # notification.
  group_wait: 10s

  # When the first notification was sent, wait 'group_interval' to send a betch
  # of new alerts that started firing for that group.
  group_interval: 5m

  # If an alert has successfully been sent, wait 'repeat_interval' to
  # resend them.
  repeat_interval: 30m

  # A default receiver
  receiver: "slack"

  # All the above attributes are inherited by all child routes and can
  # overwritten on each.
  routes:
    - receiver: "slack"
      group_wait: 10s
      match_re:
        severity: error|warning
      continue: true

    - receiver: "sms"
      group_wait: 10s
      match_re:
        severity: error
      continue: true

receivers:
  - name: "slack"
    slack_configs:
      - api_url: 'https://hooks.slack.com/services/XXXXXXXXX/XXXXXXXXX/xxxxxxxxxxxxxxxxxxxxxxxxxxx'
        send_resolved: true
        channel: 'monitoring'
        text: "{{ range .Alerts }}<!channel> {{ .Annotations.summary }}\n{{ .Annotations.description }}\n{{ end }}"

  - name: "sms"
    webhook_config:
      - url: http://a.b.c:8080/send/sms
        send_resolved: true
```

