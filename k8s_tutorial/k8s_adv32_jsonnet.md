# jsonnet 和 Kubernetes

![Alt Image Text](images/adv/32_1.jpg "Body image")

`Jsonnet` 是 `Google` 开源的一门配置语言，用于增强 `JSON` 暴露出来的短板，它与 `JSON` 完全兼容并加入了一些新特性，包括注释、引用、算术运算、条件操作符、数组和对象深入、引入函数、局部变量、继承等，`Jsonnet` 程序被编译为兼容 `JSON` 的数据格式，简单来说 `Jsonnet` 就是 `JSON` 的增强版。

核心的思想就是某些 `JSON` 字段会被作为在编译时计算的变量或者表达式保留下来，比如，`JSON` 对象 `{"size":10}`可以表示为 `{size:5+5}`，除此之外，我们还可以使用在编译期间引用的 `::` 来**声明隐藏的字段**，比如 `{x::5,y::5,size:$.x+$.y}` 也会被计算成 `{"size":10}`。

`Jsonnet` **对象还可以通过将对象连接在一起来覆盖字段值来进行子类化**，例如，我们定义下面的内容：

```
local base = {
    x :: error  "必须定义'x'的值",
    y :: 2,
    size: $.x + $.y
};
```

然后 `Jsonnet` 表达式 `(base+{x::8})` 就将会被编译成 `{"size":10}`，我们需要提供属性 x的值，否则会引发错误，这样，我们就可以把 `base` 看成在 `Jsonnet `中定义抽象基类了。

当然除此之外，`Jsonnet` 还有一些其他的用法，更多关于 `Jsonnet` 的使用方法，我们可以前往官方网站 [https://jsonnet.org/](https://jsonnet.org/) 查看说明。


## Jsonnet 和 Kubernetes

`Kubernetes` 作为一个强大的容器化编排系统，可以通过 `JSON` 和 `YAML` 文件来管理各种资源对象，自然 `Jsonnet` 也是支持的。

`ksonnet` 提供的 `kubecfg` 工具（地址[https://github.com/ksonnet/kubecfg](https://github.com/ksonnet/kubecfg)）就是依赖于 `Jsonnet` 来描述 `Kubernetes` 资源，然后将 `Jsonnet` 编译成 `JSON` 文件的。

![Alt Image Text](images/adv/32_2.jpg "Body image")

如果我们只在 `Jsonnet` 中只配置一个 `Kubernetes` 对象的话，那么我们就会错过了在具有共性的对象集合之间删除重复数据的能力。幸运的是，我们有几种方法可以来配置 Kubernetes 对象集合：使用 `YAML` 流输出、多文件输出或者单个 `kubectl` 列对象，熟悉` Kubernetes` 的都知道，后面一种是 `Kubernetes` 支持的，无需 `Jsonnet` 提供任何支持，它允许我们将几个 `Kubernetes` 对象组合成一个对象，这是一个非常重要的能力，因为它不需要任何的中间文件。

`Kubernete`s 社区对 `Jsonnet` 非常活跃，下面的一些资源对你了解 `Jsonnet` 可能有所帮助：

* `Jsonnet repo` 的一个[简单例子](https://github.com/google/jsonnet/tree/master/case_studies/kubernetes)
* [Kubecfg](https://github.com/ksonnet/kubecfg) 是一个使用 `Jsonnet` 来管理 `Kubernetes` 资源的工具，另外还附带一个[模板库](https://github.com/bitnami-labs/kube-libsonnet)，可以通过[这篇文章了解更多信息](https://engineering.bitnami.com/articles/an-example-of-real-kubernetes-bitnami.html)。
* [Heptio](https://heptio.com) 是 [Ksonnet](https://ksonnet.io) 的 `Kubecfg` 的一个分支，它使用一个 `Jsonnet` 库，该库是从 `Kubernetes API` 规范中自动生成的，现在这个库已经形成了一个框架，可以使用更高级的方式来描述 Kubernetes 对象。
* [Kapitan](https://github.com/deepmind/kapitan) 是 [Deepmind](https://deepmind.com/) 与 `Jsonnet` 和文本模板驱动 `Kubernetes` 的另外一个工具。 
* [Box](https://www.box.com/) 在[博客](https://blog.box.com/blog/kubernetes-box-microservices-maximum-velocity/) 和  [Youtube ](https://www.youtube.com/watch?v=QIDrdZlEQdw&feature=youtu.be&t=10m35s)上谈到了其内部Kubernetes为主的基础设施如何使用 `Jsonnet` 的。
* [Databricks](https://databricks.com/) 写了一篇关于如何使用 `Jsonnet` 来管理 `Kubernetes` [基础设施](https://databricks.com/blog/2017/06/26/declarative-infrastructure-jsonnet-templating-language.html)的，除此之外，他们还写了一个关于  Jsonnet 的[风格指南](https://github.com/databricks/jsonnet-style-guide)。

**下面是一个我们平时经常使用的 YAML 文件来声明的对象资源** `(kube.yaml)`

```
kind: ReplicationController
apiVersion: v1
metadata:
  name: spark-master-controller
spec:
  replicas: 1
  selector:
    component: spark-master
  template:
    metadata:
      labels:
        component: spark-master
    spec:
      containers:
        - name: spark-master
          image: k8s.gcr.io/spark:1.5.2_v1
          command: ["/start-master"]
          ports:
            - containerPort: 7077
            - containerPort: 8080
          resources:
            requests:
              cpu: 100m
```


如果将上述 `YAML `文件转换成对应的 `Jsonnet` 文件的：(`output.jsonnet`)

```
{
  kind: 'ReplicationController',
  apiVersion: 'v1',
  metadata: {
    name: 'spark-master-controller',
  },
  spec: {
    replicas: 1,
    selector: {
      component: 'spark-master',
    },
    template: {
      metadata: {
        labels: {
          component: 'spark-master',
        },
      },
      spec: {
        containers: [
          {
            name: 'spark-master',
            image: 'k8s.gcr.io/spark:1.5.2_v1',
            command: [
              '/start-master',
            ],
            ports: [
              {
                containerPort: 7077,
              },
              {
                containerPort: 8080,
              },
            ],
            resources: {
              requests: {
                cpu: '100m',
              },
            },
          },
        ],
      },
    },
  },
}
```

## Kubernetes 集合


在某些地方，`Kubernetes API` **对象使用命名对象或者键值对的列表**，**而不是使用对象将名称映射到值**，这使得这些对象很难在 `Jsonnet` 中引用和扩展，例如，`Pod` 的容器声明部分如下所示：

```
local PodSpec = {
  containers: [
    {
      name: 'foo',
      env: [
        { name: 'var1', value: 'somevalue' },
        { name: 'var2', value: 'somevalue' },
      ],
    },
    {
      name: 'bar',
      env: [
        { name: 'var2', value: 'somevalue' },
        { name: 'var3', value: 'somevalue' },
      ],
    },
  ],
};
```

如果我们想要覆盖它来修改环境变量 `var3` 的值，那么我们可以使用**数组索引来引用特定的容器和环境变量**：

```
PodSpec {
  containers: [
    super.containers[0],
    super.containers[1] {
      env: [
        super.env[0],
        super.env[1] { value: 'othervalue' },
      ],
    },
  ],
}
```

但是很明显上面的代码是比较乱的，更好的解决方案是使用**对象来表示映射**，然后转换为 `Kubernetes` 对象。首先定义一个工具类：（`utils.libsonnet`）

```
// utils.libsonnet
{
  pairList(tab, kfield='name',
           vfield='value'):: [
    { [kfield]: k, [vfield]: tab[k] }
    for k in std.objectFields(tab)
  ],

  namedObjectList(tab, name_field='name'):: [
    tab[name] + { [name_field]: name }
    for name in std.objectFields(tab)
  ],
}
```

然后定义 `Pod` ：（`pod-spec.jsonnet`）

```
local utils = import 'utils.libsonnet';

local PodSpec = {
  containersObj:: {
    foo: {
      envObj:: {
        var1: 'somevalue',
        var2: 'somevalue',
      },
      env: utils.pairList(self.envObj),
    },
    bar: {
      envObj:: {
        var2: 'somevalue',
        var3: 'somevalue',
      },
      env: utils.pairList(self.envObj),
    },
  },
  containers:
    utils.namedObjectList(self.containersObj),
};

PodSpec {
  containersObj+: {
    bar+: { envObj+: { var3: 'othervalue' } }
  }
}
```

然后编译后就可以得到环境变量被替换后的结果：(`output.json`)

```
{
  "containers": [
    {
      "env": [
        {
          "name": "var2",
          "value": "somevalue"
        },
        {
          "name": "var3",
          "value": "othervalue"
        }
      ],
      "name": "bar"
    },
    {
      "env": [
        {
          "name": "var1",
          "value": "somevalue"
        },
        {
          "name": "var2",
          "value": "somevalue"
        }
      ],
      "name": "foo"
    }
  ]
}
```

这种模式也使得引用的时候更加容易，现在，我们就可以使用以下代码访问相同的环境变量

```
PodSpec.containersObj.bar.envObj.var3
```

	原文链接：`https://jsonnet.org/articles/kubernetes.html`