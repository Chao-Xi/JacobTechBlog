# HELM Script


## SAP Jam Helm Script

![Alt Image Text](images/0_1.png "Body image")

### Rolling out the Application

| Label | Description | Objectives & Motivation |
| --- | --- | --- |
|  1 | Inbound Traffic Configuration | Set up HAProxy frontend so we know where to route DNS (this is the front door to our application) - this should already be done|
| 2 | Basic Services | Establish basic services like elasticsearch, rabbitMQ, MySQL... |
| 3 | Applications | Bring up the application |


### 1. Inbound Traffic Configuration

**Setup HAProxy kubernetes service (AWS & Azure)**

```
$ helm install --name jam-load-balancer helm/jam/load-balancer/ -f instances/$JAM_INSTANCE-k8s.yaml --namespace $JAM_INSTANCE
```

* [jam-load-balancer(Haproxy helm)](1LoadBalancer.md)

> You should be able to proceed with your cloud-specific DNS and CDN configuration after completing this step

### 2 Basic Services

**1.Database Creation & User Provisioning**

It will also init the DB.

* [Jam MySql(helm)](2Mysql.md)

**2. Elasticsearch & Elasticsearch6 :**[ElasticSearch and ElasticSearch6(helm)](3elasticsearch.md)

**3. RabbitMQ :** [RabbitMQ(helm)](4rabbitmq.md)

**4. SMTP :** [SMTP(mailcatcher helm)](5SMTP.md)


**5. mail-inbound :**[mail-inbound](5mail-inbound.md)

**6. antivirus :** [Antivirus](6Antivirus.md)

**7. Memcached for CT :** [CT-Memcached](7ct-memcached.md)

### 3. Launch Application

**1. jod:** [Jam Jod](app1_jod.md)

**For excel conversion**

**2. doc :** [Jam Doc Conversion](app2_doc.md)

**3. opensocial :** [Jam opensocial](app3_opensocial.md)

**4. agent-server :**[Jam agent-server-realtime](app4_agent-server.md)

**5. Profile Sync（PS) :** [Jam Profile Sync（PS)](app5_profile_sync.md)

It will also migrate PS database

**6. Jam Cubetree(CT)**

```
helm install --name jam-ct helm/jam/ct/ -f instances/$JAM_INSTANCE-k8s.yaml --namespace $JAM_INSTANCE --timeout 1000 --debug
```

It will also init CT database, which is a time consuming job. So we need to add `--wait --timeout 1000` to prevent helm installation fails

[Jam CT :](app6_ct.md)

* ct-webapp
* worker
* ct-scheduler
* Rpush