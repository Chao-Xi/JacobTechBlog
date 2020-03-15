# `ElasticSearch`节点(角色)类型`node.master`和`node.data`

    一般地，`ElasticSearch`集群中每个节点都有成为主节点的资格，也都存储数据，还可以提供查询服务。这些功能是由两个属性控制的（`node.master`和`node.data`）。默认情况下这两个属性的值都是`true`。

    在生产环境下，如果不修改`ElasticSearch`节点的角色信息，在高数据量，高并发的场景下集群容易出现脑裂等问题，下面详细介绍一下这两个属性的含义以及不同组合可以达到的效果。

## 一、node.master

**这个属性表示节点是否具有成为主节点的资格。** 

注意：此属性的值为`true`，并不意味着这个节点就是主节点。因为真正的主节点，是由多个具有主节点资格的节点进行选举产生的。所以，这个属性只是代表这个节点是不是具有主节点选举资格。

## 二、node.data   

**这个属性表示节点是否存储数据。**

## 三、四种组合配置方式

### （1）`node.master: true    node.data: true`

这种组合表示这个节点即有成为主节点的资格，又存储数据。


**如果某个节点被选举成为了真正的主节点，那么他还要存储数据，这样对于这个节点的压力就比较大了**。`ElasticSearch`默认每个节点都是这样的配置，在测试环境下这样做没问题。<span style="color:red">**实际工作中建议不要这样设置，因为这样相当于主节点和数据节点的角色混合到一块了。**</span>

###（2）`node.master: false    node.data: true`

**<span style="color:red">这种组合表示这个节点没有成为主节点的资格，也就不参与选举，只会存储数据。</span>**

这个节点我们称为`data`(数据)节点。在集群中需要单独设置几个这样的节点负责存储数据，**后期提供存储和查询服务**

### （3）`node.master: true    node.data: false`

这种组合表示这个节点不会存储数据，有成为主节点的资格，可以参与选举，有可能成为真正的主节点，这个节点我们称为`master`节点。

### （4）`node.master: false    node.data: false`

这种组合表示这个节点即不会成为主节点，也不会存储数据，**这个节点的意义是作为一个`client`(客户端)节点，主要是针对海量请求的时候可以进行负载均衡**。
 
## 四、其他小知识点

1. 默认情况下，每个节点都有成为主节点的资格，也会存储数据，还会处理客户端的请求。

2. 在一个生产集群中我们可以对这些节点的职责进行划分。**建议集群中设置3台以上的节点作为`master`节点【`node.master: true node.data: false`】，这些节点只负责成为主节点，维护整个集群的状态**。

3. **再根据数据量设置一批`data`节点【`node.master: false node.data: true`】**，**这些节点只负责存储数据，后期提供建立索引和查询索引的服务，这样的话如果用户请求比较频繁，这些节点的压力也会比较大**

4. **在集群中建议再设置一批`client`节点【`node.master: false node.data: true`】**，这些节点只负责处理用户请求，实现请求转发，负载均衡等功能。  

 5. `master`节点：普通服务器即可(**CPU 内存 消耗一般**)。`data`节点：**主要消耗磁盘，内存**。  ` client` 节点：普通服务器即可(如果要进行分组聚合操作的话，建议这个节点内存也分配多一点)。



## Jam ES

```
$ elasticsearch_indices_docs
```
 
``` 
elasticsearch_indices_docs{cluster="dev701-search-cluster",endpoint="9108",
es_client_node="true",
es_data_node="false",
es_ingest_node="false",
es_master_node="false",
host="elasticsearch-0.elasticsearch.dev701.svc.cluster.local",
instance="100.96.3.16:9108",
job="elasticsearch-exporter",
name="elasticsearch-0",
namespace="dev701",
pod="jam-elasticsearch-exporter-54858878dd-dn4lk",
service="jam-elasticsearch-exporter"
```