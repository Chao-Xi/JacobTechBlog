# `Elasticsearch unassigned` 故障排查

* 故障分析与排查
* 大量`unassigned shards`解决
* “Too many open files”

## 1. 故障分析与排查

一个 `Elasticsearch` 集群至少包括一个节点和一个索引。

或者它 **可能有一百个数据节点、三个单独的主节点，以及一小打客户端节点**——这些共同操作一千个索引（以及上万个分片）。

不管集群扩展到多大规模，你都会想要一个快速获取集群状态的途径。`Cluster Health API `充当的就是这个角色。你可以把它想象成是在一万英尺的高度鸟瞰集群。它可以告诉你安心吧一切都好，或者警告你集群某个地方有问题。

让我们执行一下 `cluster-health API` 然后看看响应体是什么样子的：

```
GET _cluster/health
```

和 `Elasticsearch` 里其他 `API` 一样，`cluster-health` 会返回一个 `JSON` 响应。这对自动化和告警系统来说，非常便于解析。响应中包含了和你集群有关的一些关键信息：

```
{
   "cluster_name": "elasticsearch_zach",
   "status": "green",
   "timed_out": false,
   "number_of_nodes": 1,
   "number_of_data_nodes": 1,
   "active_primary_shards": 10,
   "active_shards": 10,
   "relocating_shards": 0,
   "initializing_shards": 0,
   "unassigned_shards": 0
}
```
响应信息中最重要的一块就是 `status` 字段。状态可能是下列三个值之一：

* ***`green`***:  所有的主分片和副本分片都已分配。你的集群是 100% 可用的。
* ***`yellow`***: **所有的主分片已经分片了，但至少还有一个副本是缺失的。** 不会有数据丢失，所以搜索结果依然是完整的。不过，你的高可用性在某种程度上被弱化。**如果 更多的 分片消失，你就会丢数据了。把 `yellow` 想象成一个需要及时调查的警告**。
* ***`red`***: **<span style="color:red">至少一个主分片（以及它的全部副本）都在缺失中。这意味着你在缺少数据**</span>：**搜索只能返回部分数据**，而分配到这个分片上的写入请求会返回一个异常。
* ***`green/yellow/red`*** 状态是一个概览你的集群并了解眼下正在发生什么的好办法。剩下来的指标给你列出来集群的状态概要：
* `number_of_nodes` 和 `number_of_data_nodes` 这个命名完全是自描述的。
* `active_primary_shards` **指出你集群中的主分片数量**。这是涵盖了所有索引的汇总值。
* `active_shards` **是涵盖了所有索引的_所有_分片的汇总值，即包括副本分片**。
* **<span style="color:red">`relocating_shards` 显示当前正在从一个节点迁往其他节点的分片的数量。通常来说应该是 `0`</span>**，不过在 `Elasticsearch` 发现集群不太均衡时，该值会上涨。比如说：添加了一个新节点，或者下线了一个节点。
* **<span style="color:red">`initializing_shards` 是刚刚创建的分片的个数。</span>**比如，当你刚创建第一个索引，分片都会短暂的处于 `initializing` 状态。这通常会是一个临时事件，**<span style="color:green">分片不应该长期停留在 `initializing` 状态。你还可能在节点刚重启的时候看到 `initializing` 分片：当分片从磁盘上加载后，它们会从 `initializing` 状态开始</span>**。
* **<span style="color:red">`unassigned_shards` 是已经在集群状态中存在的分片，但是实际在集群里又找不着</span>**。通常未分配分片的来源是未分配的副本。比如，**一个有` 5 `分片和 `1 `副本的索引，在单节点集群上，就会有` 5 `个未分配副本分片**。**如果你的集群是 `red` 状态，也会长期保有未分配分片**（因为缺少主分片）。

### 想象一下某天碰到问题了， 而你发现你的集群健康状态看起来像是这样：

```
{
"cluster_name": "elasticsearch_zach",
"status": "red",
"timed_out": false,
"number_of_nodes": 8,
"number_of_data_nodes": 8,
"active_primary_shards": 90,
"active_shards": 180,
"relocating_shards": 0,
"initializing_shards": 0,
"unassigned_shards": 20
}
```

好了，从这个健康状态里我们能推断出什么来？嗯，我们集群是 `red` ，**意味着我们缺数据（主分片 + 副本分片）了**。

我们知道我们集群原先有 `10` 个节点，但是在这个健康状态里列出来的只有 `8` 个数据节点。**有两个数据节点不见了。我们看到有 `20 `个未分配分片。**

这就是我们能收集到的全部信息。那些缺失分片的情况依然是个谜。我们是缺了 `20` 个索引，每个索引里少 `1 `个主分片？还是缺 `1` 个索引里的 `20` 个主分片？还是 `10` 个索引里的各` 1` 主 `1 `副本分片？具体是哪个索引？

要回答这个问题，我们需要使用 `level` 参数让 `cluster-health` 答出更多一点的信息：

**`GET _cluster/health?level=indices`**

这个参数会让 `cluster-health API` 在我们的集群信息里添加一个索引清单，以及有关每个索引的细节（状态、分片数、未分配分片数等等）：

```
{
   "cluster_name":"elasticsearch_zach",
   "status":"red",
   "timed_out":false,
   "number_of_nodes":8,
   "number_of_data_nodes":8,
   "active_primary_shards":90,
   "active_shards":180,
   "relocating_shards":0,
   "initializing_shards":0,
   "unassigned_shards":20   
   	"indices":{
	     "v1":{
	         "status":"green",
	         "number_of_shards":10,
	         "number_of_replicas":1,
	         "active_primary_shards":10,
	         "active_shards":20,
	         "relocating_shards":0,
	         "initializing_shards":0,
	         "unassigned_shards":0
	      },
	     "v2":{
	         "status":"red",
	         "number_of_shards":10,
	         "number_of_replicas":1,
	         "active_primary_shards":0,
	         "active_shards":0,
	         "relocating_shards":0,
	         "initializing_shards":0,
	         "unassigned_shards":20
	      },
	     "v3":{
	         "status":"green",
	         "number_of_shards":10,
	         "number_of_replicas":1,
	         "active_primary_shards":10,
	         "active_shards":20,
	         "relocating_shards":0,
	         "initializing_shards":0,
	         "unassigned_shards":0
	      },
      "...."
   }
}
```

我们可以看到 `v2` 索引就是让集群变 `red `的那个索引。

由此明确了，`20` 个缺失分片全部来自这个索引。

一旦我们询问要索引的输出，哪个索引有问题立马就很清楚了：**`v2` 索引。我们还可以看到这个索引曾经有 `10` 个主分片和一个副本，而现在这 `20` 个分片全不见了**。可以推测，这 `20` 个索引就是位于从我们集群里不见了的那两个节点上。

**<span style="color:red">`"active_shards":0,`**</span>

level 参数还可以接受其他更多选项：

```
GET _cluster/health?level=shards
```

**`shards `选项会提供一个详细得多的输出，列出每个索引里每个分片的状态和位置。这个输出有时候很有用，但是由于太过详细会比较难用**。 如果你知道哪个索引有问题了，本章讨论的其他 API 显得更加有用一点。

### 阻塞等待状态变化编辑

当构建单元和集成测试时，或者实现和 `Elasticsearch` 相关的自动化脚本时，`cluster-health API` 还有另一个小技巧非常有用。你可以指定一个 `wait_for_status` 参数，它只有在状态达标之后才会返回。比如：

```
GET _cluster/health?wait_for_status=green
```

这个调用会 阻塞 （不给你的程序返回控制权）住直到 `cluster-health` 变成 `green` ，也就是说所有主分片和副本分片都分配下去了。这对自动化脚本和测试非常重要。

如果你创建一个索引，`Elasticsearch` 必须在集群状态中向所有节点广播这个变更。那些节点必须初始化这些新分片，然后响应给主节点说这些分片已经 `Started `。这个过程很快，但是因为网络延迟，可能要花 `10–20ms`。

如果你有个自动化脚本是 `(a)` 创建一个索引然后 `(b) `立刻写入一个文档，这个操作会失败。因为索引还没完全初始化完成。在` (a)` 和 `(b) `两步之间的时间可能不到 `1ms `—— 对网络延迟来说这可不够。

比起使用` sleep` 命令，直接让你的脚本或者测试使用 `wait_for_status` 参数调用 `cluster-health` 更好。当索引完全创建好，`cluster-health` 就会变成 `green` ，然后这个调用就会把控制权交还给你的脚本，然后你就可以开始写入了。

有效的选项是： `green` 、 `yellow` 和 `red` 。这个调回会在达到你要求（或者『更高』）的状态时返回。比如，如果你要求的是` yellow` ，状态变成 `yellow` 或者 `green` 都会打开调用。

## 2.问题提解决

经分析 应该是磁盘空间不足导致的，自盘空间使用率高于`90`，备份分片不再继续写入。

```
curl -H "Content-Type: application/json" -XPUT --user elastic:vwnzcs57xwvqwcqqx8cbqn8r 	https://10.107.168.84:9200/_cluster/settings -k -d '{
	"persistent": {
		"cluster.routing.allocation.disk.watermark.low": "90%",
		"cluster.routing.allocation.disk.watermark.high": "95%"
	}
}'
```

## 3.大量`unassigned shards`解决

其实刚搭完运行时就是`status: yellow`(所有主分片可用，但存在不可用的从分片), 只有一个节点, 主分片启动并运行正常, 可以成功处理请求, 但是存在`unassigned_shards`, 即存在没有被分配到节点的从分片.(只有一个节点…..)

当时数据量小, 就暂时没关注. 然后, 随着时间推移, 出现了大量`unassigned shards`

```
curl -XGET http://localhost:9200/_cluster/health\?pretty
{
  "cluster_name" : "elasticsearch",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 2,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 538,
  "active_shards" : 538,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 558,
"number_of_pending_tasks" : 0
}
```

处理方式: 找了台内网机器, 部署另一个节点(保证`cluster.name`一致即可, 自动发现, 赞一个). 当然, 如果你资源有限只有一台机器, 使用相同命令再启动一个`es`实例也行. 再次检查集群健康, 发现`unassigned_shards`减少, `active_shards`增多.

操作完后, 集群健康从`yellow`恢复到 `green`

### `status: red`

集群健康恶化了……

这次检查发现是`status: red`(存在不可用的主要分片)

```
curl -XGET http://localhost:9200/_cluster/health\?pretty
{
  "cluster_name" : "elasticsearch",
  "status" : "red",    // missing some primary shards
  "timed_out" : false,
  "number_of_nodes" : 4,
  "number_of_data_nodes" : 2,
  "active_primary_shards" : 538,
  "active_shards" : 1076,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 20,  // where your lost primary shards are.
  "number_of_pending_tasks" : 0
}
```

**fix unassigned shards**

查看所有分片状态

```
curl -XGET http://localhost:9200/_cat/shards
```


**找出`UNASSIGNED`分片**

```
curl -s "http://localhost:9200/_cat/shards" | grep UNASSIGNED
pv-2015.05.22                 3 p UNASSIGNED
pv-2015.05.22                 3 r UNASSIGNED
pv-2015.05.22                 1 p UNASSIGNED
pv-2015.05.22                 1 r UNASSIGNED
```

查询得到`master`节点的唯一标识

```
curl 'localhost:9200/_nodes/process?pretty'

{
  "cluster_name" : "elasticsearch",
  "nodes" : {
    "AfUyuXmGTESHXpwi4OExxx" : {
      "name" : "Master",
     ....
      "attributes" : {
        "master" : "true"
      },
.....
```

执行`reroute`(分多次, 变更`shard`的值为`UNASSIGNED`查询结果中编号, 上一步查询结果是1和3)

```
curl -XPOST 'localhost:9200/_cluster/reroute' -d '{
        "commands" : [ {
              "allocate" : {
                  "index" : "pv-2015.05.22",
                  "shard" : 1,
                  "node" : "AfUyuXmGTESHXpwi4OExxx",
                  "allow_primary" : true
              }
            }
        ]
    }' 
```

**<span style="color:red">批量处理的脚本(当数量很多的话, 注意替换node的名字)</span>**

```
#!/bin/bash

for index in $(curl  -s 'http://localhost:9200/_cat/shards' | grep UNASSIGNED | awk '{print $1}' | sort | uniq); do
    for shard in $(curl  -s 'http://localhost:9200/_cat/shards' | grep UNASSIGNED | grep $index | awk '{print $2}' | sort | uniq); do
        echo  $index $shard

        curl -XPOST 'localhost:9200/_cluster/reroute' -d "{
            'commands' : [ {
                  'allocate' : {
                      'index' : $index,
                      'shard' : $shard,
                      'node' : 'Master',
                      'allow_primary' : true
                  }
                }
            ]
        }"

        sleep 5
    done
done
```

## “Too many open files”

发现日志中大量出现这个错误, 执行

```
curl http://localhost:9200/_nodes/process\?pretty
```

可以看到

```
"max_file_descriptors" : 4096,
```

> Make sure to increase the number of open files descriptors on the machine (or for the user running elasticsearch). Setting it to 32k or even 64k is recommended.

而此时, 可以在系统级做修改, 然后全局生效

最简单的做法, 在`bin/elasticsearch`文件开始的位置加入

```
ulimit -n 64000
```

然后重启`es`, 再次查询看到

```
"max_file_descriptors" : 64000,
```










