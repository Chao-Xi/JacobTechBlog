# Elasticsearch Query DSL查询入门

Query DSL又叫查询表达式，是一种非常灵活又富有表现力的查询语言，采用JSON接口的方式实现丰富的查询，并使你的查询语句更灵活、更精确、更易读且易调试


## 查询与过滤


Elasticsearch（以下简称ES）中的数据检索分为两种情况：**查询和过滤**(Query and Filter)。

**`Query`查询会对检索结果进行评分，注重的点是匹配程度**，例如检索“运维”与文档的标题有**多匹配**，计算的是查询与文档的相关程度，计算完成之后会算出一个评分，记录在`_score`字段中，并最终按照`_score`字段来对所有检索到的文档进行排序

**`Filter`过滤不会对检索结果进行评分，注重的点是是否匹配**，例如检索“运维”是否匹配文档的标题，**结果只有匹配或者不匹配**，因为只是对结果进行简单的匹配，所以计算起来也非常快，并且**过滤的结果会被缓存到内存中，性能要比`Query`查询高很多**

## 简单查询

一个最简单的DSL查询表达式如下：

```
GET /_search
{
  "query":{
    "match_all": {}
  }
}
```

* `/_search` 查找整个ES中所有索引的内容
* **`query` 为查询关键字，类似的还有`aggs`为聚合关键字**
* `match_all` 匹配所有的文档，也可以写`match_none`不匹配任何文档

返回结果：

```
{
  "took": 6729,
  "timed_out": false,
  "num_reduce_phases": 6,
  "_shards": {
    "total": 2611,
    "successful": 2611,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": 7662397664,
    "max_score": 1,
    "hits": [
      {
        "_index": ".kibana",
        "_type": "doc",
        "_id": "url:ec540365d822e8955cf2fa085db189c2",
        "_score": 1,
        "_source": {
          "type": "url",
          "updated_at": "2018-05-09T07:19:46.075Z",
          "url": {
            "url": "/app/kibana",
            "accessCount": 0,
            "createDate": "2018-05-09T07:19:46.075Z",
            "accessDate": "2018-05-09T07:19:46.075Z"
          }
        }
      },
      ...省略其他的结果...
    ]
  }
}
```

* **took**： 表示我们执行整个搜索请求消耗了多少毫秒
* **`timed_out`**： 表示本次查询是否超时

这里需要注意当`timed_out`为`True`时也会返回结果，这个结果是在请求超时时`ES`已经获取到的数据，所以返回的这个数据可能不完整。

**且当你收到`timed_out`为`True`之后，虽然这个连接已经关闭，但在后台这个查询并没有结束，而是会继续执行**

* `_shards`： 显示查询中参与的分片信息，成功多少分片失败多少分片等
* `hits`： 匹配到的文档的信息，其中total表示匹配到的文档总数，`max_score`为文档中所有`_score`的最大值
* `hits`中的`hits`数组为查询到的文档结果，默认包含查询结果的前十个文档，每个文档都包含文档的`_index`、`_type`、`_id`、`_score`和`_source`数据

结果文档默认情况下是按照相关度（`_score`）进行降序排列，**也就是说最先返回的是相关度最高的文档，文档相关度意思是文档内容与查询条件的匹配程度**，上边的查询与过滤中有介绍

### 指定索引


上边的查询会搜索ES中的所有索引，但我们通常情况下，只需要去固定一个或几个索引中搜索就可以了，搜索全部无疑会造成资源的浪费，在ES中可以通过以下几种方法来指定索引

* 1.指定一个固定的索引，`ops-coffee-nginx-2019.05.15`为索引名字

```
GET /ops-coffee-nginx-2019.05.15/_search
```

以上表示在`ops-coffee-nginx-2019.05.15`索引下查找数据

* 2.指定多个固定索引，多个索引名字用逗号分割

```
GET /ops-coffee-nginx-2019.05.15,ops-coffee-nginx-2019.05.14/_search
```

* 3.用`*`号匹配，在匹配到的所有索引下查找数据

```
GET /ops-coffee-nginx-*/_search
```

当然这里也可以用逗号分割多个匹配索引

### 分页查询


**上边有说到查询结果`hits`默认只展示`10`个文档**，那我们如何查询10个以后的文档呢？ES中给了`size`和`from`两个参数

* **size**： 设置一次返回的结果数量，也就是`hits`中的文档数量，默认为`10`
* **from**： 设置从第几个结果开始往后查询，默认值为`0`

```
GET /ops-coffee-nginx-2019.05.15/_search
{
  "size": 5,
  "from": 10,
  "query":{
    "match_all": {}
  }
}
```

以上查询就表示查询`ops-coffee-nginx-2019.05.15`索引下的所有数据，**并会在`hits`中显示第`11`到第`15`个文档的数据**

## 全文查询


上边有用到一个`match_all`的全文查询关键字，`match_all`为查询所有记录，常用的查询关键字在ES中还有以下几个

### match


最简单的查询，下边的例子就表示查找`host`为`ops-coffee.cn`的所有记录

```
GET /ops-coffee-2019.05.15/_search
{
  "query":{
    "match": {
      "host":"ops-coffee.cn"
    }
  }
}
```

### `multi_match`

在多个字段上执行相同的`match`查询，下边的例子就表示查询`host`或`http_referer`字段中包含`ops-coffee.cn`的记录

```
GET /ops-coffee-2019.05.15/_search
{
  "query":{
    "multi_match": {
      "query":"ops-coffee.cn",
      "fields":["host","http_referer"]
    }
  }
}

```


### `query_string`

**可以在查询里边使用`AND`或者`OR`来完成复杂的查询**，例如：

```
GET /ops-coffee-2019.05.15/_search
{
  "query":{
    "query_string": {
      "query":"(a.ops-coffee.cn) OR (b.ops-coffee.cn)",
      "fields":["host"]
    }
  }
}
```


以上表示查找`host`为`a.ops-coffee.cn`或者`b.ops-coffee.cn`的所有记录

也可以用下边这种方式组合更多的条件完成更复杂的查询请求

```
GET /ops-coffee-2019.05.14/_search
{
  "query":{
    "query_string": {
      "query":"host:a.ops-coffee.cn OR (host:b.ops-coffee.cn AND status:403)"
    }
  }
}
```

以上表示查询（`host为a.ops-coffee.cn`）或者是（`host`为`b.ops-coffee.cn`且`status为403`）的所有记录


与其像类似的还有个`simple_query_string`的关键字，可以将`query_string`中的`AND`或`OR`用`+`或`|`这样的符号替换掉

### term

term可以用来精确匹配，精确匹配的值可以是数字、时间、布尔值或者是设置了`not_analyzed`不分词的字符串

```
GET /ops-coffee-2019.05.14/_search
{
  "query":{
    "term": {
      "status": {
        "value": 404
      }
    }
  }
}
```

`term`对输入的文本不进行分析，直接精确匹配输出结果，如果要同时匹配多个值可以使用`terms`

```
GET /ops-coffee-2019.05.14/_search
{
  "query": {
    "terms": {
      "status":[403,404]
    }
  }
}
```

### range

`range`用来查询落在指定区间内的数字或者时间

```
GET /ops-coffee-2019.05.14/_search
{
  "query": {
    "range":{
      "status":{
        "gte": 400,
        "lte": 599
      }
    }
  }
}
```

以上表示搜索所有状态为`400`到`599`之间的数据，这里的操作符主要有四个`gt`大于，`gte`大于等于，`lt`小于，`lte`小于等于

当使用日期作为范围查询时，我们需要注意下日期的格式，官方支持的日期格式主要有两种

* 时间戳，注意是毫秒粒度

```
GET /ops-coffee-2019.05.14/_search
{
  "query": {
    "range": {
      "@timestamp": {
        "gte": 1557676800000,
        "lte": 1557680400000,
        "format":"epoch_millis"
      }
    }
  }
}
```

* 日期字符串

```
GET /ops-coffee-2019.05.14/_search
{
  "query": {
    "range":{
      "@timestamp":{
        "gte": "2019-05-13 18:30:00",
        "lte": "2019-05-14",
        "format": "yyyy-MM-dd HH:mm:ss||yyyy-MM-dd",
        "time_zone": "+08:00"
      }
    }
  }
}
```

通常更推荐用这种日期字符串的方式，看起来比较清晰，日期格式可以按照自己的习惯输入，只需要`format`字段指定匹配的格式，如果格式有多个就用`||`分开，像例子中那样，不过我更推荐用同样的日期格式

如果日期中缺少年月日这些内容，那么缺少的部分会用unix的开始时间（即1970年1月1日）填充，当你将`"format":"dd"`指定为格式时，那么`"gte":10`将被转换成`1970-01-10T00:00:00.000Z`

`elasticsearch`中默认使用的是`UTC`时间，所以我们在使用时要通过`time_zone`来设置好时区，以免出错

## 组合查询

通常我们可能需要将很多个条件组合在一起查出最后的结果，这个时候就需要使用`ES`提供的`bool`来实现了

例如我们要查询`host`为`ops-coffee.cn`且`http_x_forworded_for`为`111.18.78.128`且`status`不为`200`的所有数据就可以使用下边的语句

```
GET /ops-coffee-2019.05.14/_search
{
 "query":{
    "bool": {
      "filter": [
        {"match": {
          "host": "ops-coffee.cn"
        }},
        {"match": {
          "http_x_forwarded_for": "111.18.78.128"
        }}
      ],
      "must_not": {
        "match": {
          "status": 200
        }
      }
    }
  }
}
```

主要有四个关键字来组合查询之间的关系，分别为：

* **must**： 类似于`SQL`中的`AND`，必须包含
* **`must_not`**： 类似于`SQL`中的`NOT`，必须不包含
* **should**： 满足这些条件中的任何条件都会增加评分`_score`，不满足也不影响，`should`只会影响查询结果的`_score`值，并不会影响结果的内容
* **filter**： 与`must`相似，但不会对结果进行相关性评分`_score`，大多数情况下我们对于日志的需求都无相关性的要求，所以**建议查询的过程中多用`filter`**



