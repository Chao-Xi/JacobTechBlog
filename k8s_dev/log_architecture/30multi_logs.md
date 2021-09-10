# 如何收集管理多行日志？

多行日志（例如异常信息）为调试应用问题提供了许多非常有价值的信息，在分布式微服务流行的今天基本上都会统一将日志进行收集，比如常见的 ELK、EFK 等方案，但是这些方案如果没有适当的配置，它们是不会将多行日志看成一个整体的，而是每一行都看成独立的一行日志进行处理，这对我们来说是难以接受的。

在本文中，我们将介绍一些常用日志收集工具处理多行日志的策略。

## JSON

保证多行日志作为单个事件进行处理最简单的方法就是以 JSON 格式记录日志，比如下面是常规 Java 日常日志的示例：

```
# javaApp.log
2019-08-14 14:51:22,299 ERROR [http-nio-8080-exec-8] classOne: Index out of range
java.lang.StringIndexOutOfBoundsException: String index out of range: 18
 at java.lang.String.charAt(String.java:658)
 at com.example.app.loggingApp.classOne.getResult(classOne.java:15)
 at com.example.app.loggingApp.AppController.tester(AppController.java:27)
 at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
 at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
 at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
 at java.lang.reflect.Method.invoke(Method.java:498)
 at org.springframework.web.method.support.InvocableHandlerMethod.doInvoke(InvocableHandlerMethod.java:190)
 at org.springframework.web.method.support.InvocableHandlerMethod.invokeForRequest(InvocableHandlerMethod.java:138)
[...]
```

如果直接收集上面的日志会识别为多行日志，如果我们用 JSON 格式来记录这些日志，然后介绍 JSON 的数据就简单多了，比如使用 `Log4J2` 来记录，变成下面的格式：

```
{"@timestamp":"2019-08-14T18:46:04.449+00:00","@version":"1","message":"Index out of range","logger_name":"com.example.app.loggingApp.classOne","thread_name":"http-nio-5000-exec-6","level":"ERROR","level_value":40000,"stack_trace":"java.lang.StringIndexOutOfBoundsException: String index out of range: 18\n\tat java.lang.String.charAt(String.java:658)\n\tat com.example.app.loggingApp.classOne.getResult(classOne.java:15)\n\tat com.example.app.loggingApp.AppController.tester(AppController.java:27)\n\tat sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)\n\tat sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)\n\tat sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)\n\tat java.lang.reflect.Method.invoke(Method.java:498)\n\tat org.springframework.web.method.support.InvocableHandlerMethod.doInvoke(InvocableHandlerMethod.java:190)\n\tat org.springframework.web.method.support.InvocableHandlerMethod.invokeForRequest(InvocableHandlerMethod.java:138)\n\tat
[...]
}
```

这样整个日志消息都包含在单个 JSON 对象汇总了，其中就包含完整的异常堆栈信息，绝大多数工具都支持直接解析 JSON 日志数据，这是最简单的一种方法，对于运维同学来说也是最省心的，但是大部分开发人员是抵触用 JSON 格式来记录日志的~~~

## Logstash

对于使用 Logstash 的用户来说，要支持多行日志也不困难，Logstash 可以使用插件解析多行日志，该插件在日志管道的 input 部分进行配置。**例如，下面的配置表示让 Logstash 匹配你的日志文件中 ISO8601 格式的时间戳，当匹配到这个时间戳的时候，它就会将之前所有不以时间戳开头的内容折叠到之前的日志条目中去。**

```
input {
  file {
    path => "/var/app/current/logs/javaApp.log"
    mode => "tail"
    codec => multiline {
      pattern => "^%{TIMESTAMP_ISO8601} "
      negate => true
      what => "previous"
    }
  }
}
```

## Fluentd

和 Logstash 类似，Fluentd 也允许我们使用一个插件来处理多行日志，我们可以配置插件接收一个或多个正则表达式，以下面的 Python 多行日志为例：

```
2019-08-01 18:58:05,898 ERROR:Exception on main handler
Traceback (most recent call last):
  File "python-logger.py", line 9, in make_log
    return word[13]
IndexError: string index out of range
```

如果没有 `multiline` 多行解析器，Fluentd 会把每行当成一条完整的日志，我们可以在 `<source>` 模块中添加一个 `multiline` 的解析规则，必须包含一个 `format_firstline` 的参数来指定一个新的日志条目是以什么开头的，此外还可以使用正则分组和捕获来解析日志中的属性，如下配置所示：


```
<source>
  @type tail
  path /path/to/pythonApp.log
  tag sample.tag
  <parse>
    @type multiline
    format_firstline /\d{4}-\d{1,2}-\d{1,2}/
    format1 /(?<timestamp>[^ ]* [^ ]*) (?<level>[^\s]+:)(?<message>[\s\S]*)/
  </parse>
</source>
```

在解析部分我们使用 `@type multiline` 指定了多行解析器，然后使用 `format_firstline` 来指定我们多行日志开头的规则，这里我们就用一个简单的正则匹配日期，然后指定了其他部分的匹配模式，并为它们分配了标签，这里我们将日志拆分成了 timestamp、level、message 这几个字段。


经过上面的规则解析过后，现在 Fluentd 会将每个 traceback 日志看成一条单一的日志了：

```
{
  "timestamp": "2019-08-01 19:22:14,196",
  "level": "ERROR:",
  "message": "Exception on main handler\nTraceback (most recent call last):\n  File \"python-logger.py\", line 9, in make_log\n    return word[13]\nIndexError: string index out of range"
}
```

该日志已被格式化为 JSON，我们匹配的标签也被设置为了 Key。

在 Fluentd 官方文档中也有几个示例说明：

### Rails 日志

比如输入的 Rails 日志如下所示：

```
Started GET "/users/123/" for 127.0.0.1 at 2013-06-14 12:00:11 +0900
Processing by UsersController#show as HTML
  Parameters: {"user_id"=>"123"}
  Rendered users/show.html.erb within layouts/application (0.3ms)
Completed 200 OK in 4ms (Views: 3.2ms | ActiveRecord: 0.0ms)
```

我们可以使用下面的解析配置进行多行匹配：

```
我们可以使用下面的解析配置进行多行匹配：

<parse>
  @type multiline
  format_firstline /^Started/
  format1 /Started (?<method>[^ ]+) "(?<path>[^"]+)" for (?<host>[^ ]+) at (?<time>[^ ]+ [^ ]+ [^ ]+)\n/
  format2 /Processing by (?<controller>[^\u0023]+)\u0023(?<controller_method>[^ ]+) as (?<format>[^ ]+?)\n/
  format3 /(  Parameters: (?<parameters>[^ ]+)\n)?/
  format4 /  Rendered (?<template>[^ ]+) within (?<layout>.+) \([\d\.]+ms\)\n/
  format5 /Completed (?<code>[^ ]+) [^ ]+ in (?<runtime>[\d\.]+)ms \(Views: (?<view_runtime>[\d\.]+)ms \| ActiveRecord: (?<ar_runtime>[\d\.]+)ms\)/
</parse>
```

解析过后得到的日志如下所示：


```
{
  "method"           :"GET",
  "path"             :"/users/123/",
  "host"             :"127.0.0.1",
  "controller"       :"UsersController",
  "controller_method":"show",
  "format"           :"HTML",
  "parameters"       :"{ \"user_id\":\"123\"}",
  ...
}
```

### Java 堆栈日志


比如现在我们要解析的日志如下所示：

```
2013-3-03 14:27:33 [main] INFO  Main - Start
2013-3-03 14:27:33 [main] ERROR Main - Exception
javax.management.RuntimeErrorException: null
    at Main.main(Main.java:16) ~[bin/:na]
2013-3-03 14:27:33 [main] INFO  Main - End
```

则我们可以使用下面的解析规则进行多行匹配：

```
<parse>
  @type multiline
  format_firstline /\d{4}-\d{1,2}-\d{1,2}/
  format1 /^(?<time>\d{4}-\d{1,2}-\d{1,2} \d{1,2}:\d{1,2}:\d{1,2}) \[(?<thread>.*)\] (?<level>[^\s]+)(?<message>.*)/
</parse>
```


解析过后的日志为：


```
{
  "thread" :"main",
  "level"  :"INFO",
  "message":"  Main - Start"
}
{
  "thread" :"main",
  "level"  :"ERROR",
  "message":" Main - Exception\njavax.management.RuntimeErrorException: null\n    at Main.main(Main.java:16) ~[bin/:na]"
}
{
  "thread" :"main",
  "level"  :"INFO",
  "message":"  Main - End"
}
```

上面的多行解析配置中除了 `format_firstline` 指定多行日志的开始行匹配之外，还用到了 format1、format2…formatN 这样的配置，其中 N 的范围是 1...20，是多行日志的 Regexp 格式列表，为了便于乐队，可以将 Regexp 模式分割成多个 regexpN 参数，将这些匹配模式连接起来构造出多行模式的正则匹配。


## Fluent Bit

Fluent Bit 的 tail input 插件也提供了处理多行日志的配置选项，比如现在我们还是来处理之前的 Python 多行日志：

```
2019-08-01 18:58:05,898 ERROR:Exception on main handler
Traceback (most recent call last):
  File "python-logger.py", line 9, in make_log
    return word[13]
IndexError: string index out of range
```

如果不用多行解析器 Fluent Bit 同样会将每一行当成一条日志进行处理，我们可以配置使用 Fluent Bit 内置的 regex 解析器插件来结构化多行日志：

```
  [PARSER]
      Name         log_date
      Format       regex
      Regex        /\d{4}-\d{1,2}-\d{1,2}/

  [PARSER]
      Name        log_attributes
      Format      regex
      Regex       /(?<timestamp>[^ ]* [^ ]*) (?<level>[^\s]+:)(?<message>[\s\S]*)/

   [INPUT]
      Name              tail
      tag               sample.tag
      path              /path/to/pythonApp.log
      Multiline         On
      Parser_Firstline  log_date
      Parser_1          log_attributes
```

**和 Fluentd 类似，`Parser_Firstline` 参数指定了与多行日志开头相匹配的解析器的名称，当然我们也可以包含额外的解析器来进一步结构化你的日志。这里我们配置了首先使用 `Parser_Firstline` 参数来匹配 `ISO8601` 日期开头的日志行，然后使用 `Parser_1` **参数来指定匹配模式，以匹配日志消息的其余部分，并为它们分配了 timestamp、level、message 标签。

最终转换过后我们的日志变成了如下所示的格式：

```
最终转换过后我们的日志变成了如下所示的格式：

{
  "timestamp": "2019-08-01 19:22:14,196",
  "level": "ERROR:",
  "message": "Exception on main handler\nTraceback (most recent call last):\n  File \"python-logger.py\", line 9, in make_log\n    return word[13]\nIndexError: string index out of range"
}
```


