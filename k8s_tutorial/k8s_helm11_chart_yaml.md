# `HELM` 开发 `YAML` 技巧

### 标量和集合

根据YAML规范`YAML spec`，有两种类型的集合，以及许多标量类型。

**这两种类型的集合是`maps`和`sequence`**：

```
map:
  one: 1
  two: 2
  three: 3

sequence:
  - one
  - two
  - three
```

标量值是单个值（与集合相对）


### YAML中的标量类型


在`Helm`的`YAML`语言中，值的标量数据类型由一组复杂的规则确定，包括用于资源定义的`Kubernetes schema`。但是，在推断类型时，以下规则成立。

**如果一个整数或浮点数是不加引号的单词，它通常被视为一个数字类型**：


```
count: 1
size: 2.34
```

但如果他们被引号括起来，他们被视为字符串：

```
count: "1" # <-- string, not int
size: '2.34' # <-- string, not float
```

布尔值也是如此：

```
isGood: true   # bool
answer: "true" # string
```

空值的词是`null`（not nil）。

请注意，这`port: "80"`是有效的`YAML`，并且将通过模板引擎和`YAML`分析器，但如果`Kubernetes`预期`port`为整数，则会失败。

在某些情况下，您可以使用`YAML`节点标签强制进行特定的类型推断：

```
coffee: "yes, please"
age: !!str 21
port: !!int "80"
```

* `!!str 21`: 在上面，`!!str`告诉解析器`age`是一个字符串，即使它看起来像一个`int`
* `!!int "80"`: 而`port`被视为一个`int`，即使它被引号括起来。


### YAML中的字符串


我们放在YAML文档中的大部分数据都是字符串。YAML有多种表示字符串的方式。本节将介绍这些方法并演示如何使用其中的一些方法。


有三种内置方式来声明一个字符串：


```
way1: bare words
way2: "double-quoted strings"
way3: 'single-quoted strings'
```

所有内置样式必须位于同一行上。

* 单词没有被引用，并且没有`escape`。出于这个原因，你必须小心你使用什么字符。
* 双引号的字符串可以使用特定的字符`\`进行转义。例如`"\"Hello\", she said"`。你也可以用换行符换行`\n`。
* 单引号字符串是“文字”字符串，并且不使用`\`转义字符。唯一的转义序列是`''`，它被解码为一个单独的。


除了单行字符串外，还可以声明多行字符串：

```
coffee: |
  Latte
  Cappuccino
  Espresso
```

以上将把`coffee`的值视为等价于单独字符串**`Latte\nCappuccino\nEspresso\n`**。


请注意，`|`必须后的第一行正确缩进。所以我们可以通过这样做来破坏上面的例子：

```
coffee: |
         Latte
  Cappuccino
  Espresso
```

由于Latte不正确缩进，我们会得到如下错误：

```
Error parsing file: error converting YAML to JSON: yaml: line 7: did not find expected key
```

在模板中，为了防止出现上述错误，在多行文档中放置假“第一行”内容有时更安全：

```
coffee: |
  # Commented first line
         Latte
  Cappuccino
  Espresso
```

请注意，无论第一行是什么，它都将保留在字符串的输出中。因此，例如，如果使用这种技术将文件内容注入到`ConfigMap`中，那么该注释应该是任何正在读取该条目的预期类型。

### 控制多行字符串中的空格


在上面的例子中，我们用来`|`表示一个多行字符串。 但请注意，我们的字符串的内容后跟着`\n`。

如果我们希望`YAML`处理器去掉尾随的换行符，我们可以在`|`后添加`-`：

```
coffee: |-
  Latte
  Cappuccino
  Espresso
```

现在的 `coffee` 值将是: `Latte\nCappuccino\nEspresso`(没有尾随`\n`）。

其他时候，我们可能希望保留所有尾随空格。我们可以用`|+`符号来做到这一点：

```
coffee: |+
  Latte
  Cappuccino
  Espresso
  
another: value
```

现在的值`coffee`将会是`Latte\nCappuccino\nEspresso\n\n\n`。


文本块内部的缩进被保留，并保留换行符：

```
coffee: |-
  Latte
    12 oz
    16 oz
  Cappuccino
  Espresso
```

在上述情况下，`coffee`将是`Latte\n 12 oz\n 16 oz\nCappuccino\nEspresso`。

### 缩进和模板


在编写模板时，可能会发现自己希望将文件内容注入模板。正如我们在前几章中看到的，有两种方法可以做到这一点：

* 使用`{{ .Files.Get "FILENAME" }}`得到`chart`中的文件的内容。
* 使用`{{ include "TEMPLATE" . }}`渲染模板，然后其内容放入`chart`。


将文件插入`YAML`时，最好理解上面的多行规则。通常情况下，插入静态文件的最简单方法是做这样的事情：

```
myfile: |
{{ .Files.Get "myfile.txt" | indent 2 }}
```

请注意我们如何执行上面的缩进：`indent 2`告诉模板引擎使用两个空格缩进`“myfile.txt”`中的每一行。请

注意，我们不缩进该模板行。那

是因为如果我们做了，第一行的文件内容会缩进两次。


### 折叠多行字符串

有时候你想在你的`YAML`中用多行代表一个字符串，但是当它被解释时，要把它当作一个长行。这被称为“折叠”。要声明一个折叠块，使用`>`代替`|`：

```
coffee: >
  Latte
  Cappuccino
  Espresso
```

`coffee` 的值将会是`Latte Cappuccino Espresso\n`。请注意，除最后一个换行符之外的所有内容都将转换为空格。您可以将空格控件与折叠文本标记组合起来，因此·将替换或去掉所有换行符。


请注意，在折叠语法中，缩进文本将导致行被保留。

```
coffee: >-
  Latte
    12 oz
    16 oz
  Cappuccino
  Espresso
```

以上将产生`Latte\n 12 oz\n 16 oz\nCappuccino Espresso`。请注意，空格和换行符都还在那里。



### 将多个文档嵌入到一个文件中

可以将多个`YAML`文档放入单个文件中。这是通过在一个新文档前加`---,`在文档结束加`...`来完成的

```
---
document:1
...
---
document: 2
...
```

在许多情况下，无论是`---`或`...`可被省略。

`Helm`中的某些文件不能包含多个文档。例如，如果文件内部提供了多个`values.yaml`文档，则只会使用第一个文档。

但是，模板文件可能有多个文档。发生这种情况时，文件（及其所有文档）在模板渲染期间被视为一个对象。但是，最终的`YAML`在被送到`Kubernetes`之前被分成多个文件。

我们建议每个文件在绝对必要时才使用多个文档。在一个文件中有多个文件可能很难调试。


### `YAML`是`JSON`的`Superset`

因为`YAML`是`JSON`的超集，所以任何有效的`JSON`文档都应该是有效的`YAML`。

```
{
  "coffee": "yes, please",
  "coffees": [
    "Latte", "Cappuccino", "Espresso"
  ]
}
```

以上是下面另一种表达方式：

```
coffee: yes, please
coffees:
- Latte
- Cappuccino
- Espresso
```

这两者可以混合使用（小心使用）：

```
coffee: "yes, please"
coffees: [ "Latte", "Cappuccino", "Espresso"]
```
所有这三个都应该解析为相同的内部表示。

虽然这意味着诸如`values.yaml`可能包含`JSON`数据的文件，但`Helm`不会将文件扩展名`.json`视为有效的后缀。

### YAML锚

YAML规范提供了一种方法来存储对某个值的引用，并稍后通过引用来引用该值。`YAML`将此称为`“锚定”`：

```
coffee: "yes, please"
favorite: &favoriteCoffee "Cappucino"
coffees:
  - Latte
  - *favoriteCoffee
  - Espresso
```

在上面，`&favoriteCoffee`设置一个引用到`Cappuccino`。之后，该引用被用作`*favoriteCoffee`。所以`coffees`变成了 `Latte`, `Cappuccino`, `Espresso`。

虽然在少数情况下锚点是有用的，但它们的一个方面可能导致细微的错误：第一次使用YAML时，引用被扩展，然后被丢弃。


所以如果我们要解码然后重新编码上面的例子，那么产生的YAML将是：

```
coffee: yes, please
favorite: Cappucino
coffees:
- Latte
- Cappucino
- Espresso
```

因为`Helm`和`Kubernetes`经常读取，修改并重写`YAML`文件，锚将会丢失。
