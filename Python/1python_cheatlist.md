# 熟悉Python2.7语句表达式

### 以下命令和代码依据`CentOS7`系统内`Python2.7.5`版本操作

## 一、Python安装

### 1、Windows系统安装：

* 到`Python`官网下载`Python`
* 不能安装到长目录文件下
* 新建Python文件，安装到`C:\Python`文件下即可

### 2、Unix系统安装：

* 下载`tar.gz`文件，然后解压文件
* 编译`Python`
* `./configure`
* `make`
* `make install`
* 一般默认安装在`/usr/bin`或`/usr/local/bin`子目录中

### 3、Linux + Pyenv

* [How to install pyenv](https://github.com/Chao-Xi/JacobTechBlog/blob/master/Python/PythonVirtualEnv.md)

* **How to install Pyenv 2.7.5 locally**

```
$ pyenv versions
* system (set by /home/vagrant/.pyenv/version)
  2.7.15
  3.6.4

$ pyenv install -v 2.7.5
$ pyenv versions
  system
  2.7.5 (set by /home/vagrant/python2/.python-version)
* 3.6.4

$ mkdir python2 && cd python2
$ pyenv local 2.7.5
$ pyenv versions
  system
* 2.7.5 (set by /home/vagrant/python2/.python-version)
  3.6.4
 
$ python
Python 2.7.5 (default, Dec 24 2018, 07:01:59)
[GCC 4.8.4] on linux2
Type "help", "copyright", "credits" or "license" for more information. 
```

## 初始Python代码，入门操作

### 1、程序输出：print

把字符串赋值给变量`myString`

```
myString = "Hello World"
print  myString
```
```
Hello World
[Finished in 0.2s]
```

`print` 语句调用`str()`函数表示对象；交互式解释器调用`repr()`函数显示对象。

`下划线(_)`表示最后一个表达式的值。

`print`语句，与`字符串格式操作符(%)`结合使用，可实现字符串替换功能，和C语言中的`printf()`函数非常相似：

```
print  "%s is number %d!" %("python", 1)
```
```
python is number 1!
[Finished in 0.1s]
```

`%s`表示由一个字符串来替换，而`%d`表示由一个整型来替换，另外一个很常用的就是`%f`，用一个浮点型来替换。

#### `print`支持将输出重定向到文件；符号`>>`用来重定向输出

```
import sys
print >> sys.stderr, 'Fatal error: invalid input!'
```
```
Fatal error: invalid input!
[Finished in 0.1s]
```

例：将输出重定向到日志文件

```
logfile = open('/Users/jxi/Desktop/mylog.txt','a')
print >> logfile, 'Fatalerror: invalid input!'
logfile.close()
```

### 2、程序输入和`raw_input()`内建函数


`raw_input()`内建函数，可以**读取标准输入**，**并将读取到的数据赋值给指定的变量**；然后使用`int()`内建函数将用**户输入的字符串转换为整型**

```
>>> user = raw_input('Enter loginname: ')
Enter loginname: toot
>>> print 'Your login is:', user
Your login is: toot
>>>
```

**例：输入一个数值字符串(并将字符串转换为整型)**

```
>>> num = raw_input('Now enter a number: ')
Now enter a number: 1024
>>> print 'Doubling your number:%d' % (int(num) * 2)
Doubling your number: 2048
>>> print 'Doubling your number:%d' % (int(num) * 4)
Doubling your number: 4096
>>> print 'Doubling your number:%d' % (int(num) * 10)
Doubling your number: 10240
```

### 3、注释(#)

`Python`也使用`#`符号标示注释，从`#`开始，知道一行结束的内容都是注释

```
>>> print 'Hello World!'        #another comment
Hello World!
```

### 4、操作符

```
+ -  *  / //  %  **
```

加、减、乘、除和取余都是标准操作符，**Python有两种除法操作符**，

* 单斜杠用作传统除法，
* 双斜杠用作浮点除法(`对结果进行四舍五入`)；
* 还有一个乘方操作符，双星号(`**`)

```
>>> print -2 * 4 + 3 ** 2
1
```

操作符的优先级和运算是一样的:`+`和`-`优先级最低，`*`、`/`、`//`、`%`优先级最高，单目操作符`+`和`-`优先级更高，乘方的优先级最高。

Python也有标准比较操作符，**比较运算根据表达式的值的真假返回布尔值**

```
< <=  >  >= ==  !=  <>
```

例：

```
>>> 2 < 4
True
>>> 2 == 4
False(错误的)
>>> 2 > 4
False
>>> 6.2 <= 6.2
True
>>> 6.2 <= 6.20001
True
```

Python目前支持两种“不等于”比较操作符，`!=`和`<>`，分别是C风格和ABC/Pascal风格；也提供了逻辑操作符`and`  `or`  `not`

例：使用逻辑操作符将任意表达式连接在一起

```
>>> 6.2 <= 6.20001
True
>>> 2 < 4 and 2 == 4
False
>>> 2 > 4 or 2 < 4
True
>>> not 6.2 <= 6
True
```

```
>>> 3 < 4 < 5
True
```
**最后一个例子在其她语言中通常是不合法的，不过在Python中支持这样的表达式，实际是：**

```
>>> 3 < 4 and 4 < 5
True
```

### 5、变量和赋值

变量名仅仅是一些字母开头的标识符——所谓字母开头——意指大写或小写字母，另外还包括下划线(_)，其它的字符可以是数字、字母或下划线。

#### 变量名是大小写敏感的，case与CaSe是两个不同变量。

**Python属于动态类型语言，不需要预先声明变量的类型。**

```
>>> counter = 0
>>> miles = 1000.0
>>> name = 'Bob'
>>> counter = counter + 1
>>> kilometers = 1.609 * miles
>>> print '%f miles is the same as %f km' % (miles, kilometers)
1000.000000 miles is the same as1609.000000 km
```

* 第一个是整型赋值；
* 第二个是浮点型赋值；
* 第三个是字符串赋值；
* 第四个是对一个整型增1，最后一个是浮点乘法赋值。

Python也支持增量赋值，也就是操作符和等号合并在一起

```
>>> n = n * 10
```

改成增量赋值方式

```
>>> n *= 10
```

### 6、数字

#### 支持五种基本数字类型，其中三种是整型类型

**有符号整型(长整型、布尔值)、浮点值、复数**

例：

```
int  0101   84   -237  0x80   017   -680  -0X92

long 29979062458L  -841401  0xDECADEDEADBEEFBADFEEDDEAL

bool  True   False

float  3.14159   4.2E-10   -90.  6.022e23   -1.609E-19

complex  6.23+1.5j   -1.23-875J   0+1j  9.80665-8.31441J   -.0224+0j
```


### 7、字符串

`Python` 中字符串被定义为引号之间的字符集合，支持使用成对的`单引号`或`双引号`，`三引号`(**三个连续的单引号或者双引号**)可以用来包含特殊字符；

* 使用索引操作符`([])`和切片操作符`([:])`可以得到子字符串；
* 字符串特有的索引规则：
  * 第一字符的索引是`0`，
  * 最后一个字符的索引是`-1`
  * 加号`(+)`用于字符**串连接运算**
  * 星号`(*)`用于**字符串重复**。

例：

```
>>> pystr = 'python'
>>> iscool = 'is cool!'
>>> pystr[0]
'p'
>>> pystr[2:5]
'tho'
>>> iscool[:2]
'is'
>>> iscool[3:]
'cool!'
>>> iscool[-1]
'!'
>>> pystr + iscool
'pythonis cool!'
>>> pystr + ' ' + iscool
'python is cool!'
>>> pystr * 2
'pythonpython'


>>> '-' * 20       # funny
'--------------------'


>>> pystr = '''python
... is cool'''

>>> print pystr
python
is cool

>>> pystr
'python\nis cool'
```

### 8.列表[list]和元组(Tuple)

可以保存任意数量任意类型的Python对象；

#### 列表list元素用中括号`([])`包裹，元素的个数及元素的值可以改变； 
#### 元组tuple元素用小括号`(())`包裹，不可以更改(尽管他们的内容可以)；元组可以看成是只读的列表，通过切片运算`([])`和`([:])`可以得到子集。

```
>>> aList = [1,2,3,4]

>>> aList
[1, 2, 3, 4]

>>> aList[0]
1

>>> aList[2:]
[3, 4]

>>> aList[:3]
[1, 2, 3]

>>> aList[1] = 5      # 元素的值可以改变
>>> aList
[1, 5, 3, 4]
```
#### 元组也可以进行切片运算，得到的结果也是元组(不能被修改)


```
Tuple = ('robots',77,93,'try')
print aTuple
print  aTuple[:3]

aTuple[1] = 5
```

```
('robots', 77, 93, 'try')
('robots', 77, 93)

Traceback (most recent call last):
  File "/Users/jxi/Desktop/test.py", line 4, in <module>
    aTuple[1] = 5
TypeError: 'tuple' object does not support item assignment
```

### 9、字典

是Python中的映射数据类型，有键-值`(key-value)`对构成；值可以是任意类型的`Python`对象，字典元素用大括号`({})`包裹

```
aDict = {'host': 'earth'}   # create dict
aDict['port'] = 80          # add to dict
print aDict
print aDict.keys()
print aDict['host']

print '-'*20

for key in aDict:
  print key, aDict[key]
```

```
{'host': 'earth', 'port': 80}
['host', 'port']
earth
--------------------
host earth
port 80
```

### 10、if语句

标准if条件语句的语法：

```
if expression:
   if_suite
```

* 如果表达式的值`非0`或者为`布尔值True`，则代码组`if_suite`被执行；
* 否则就去执行下一条语句；`代码组(suite)`是一个Python术语，由一条或多条语句组成，表示一个子代码块。


```
if -1 < 0:
  print '-1 is less than 0!'

-1 is less than 0!
[Finished in 0.1s]
```

Python也支持`else`和`elif`语句

```
if expression:
  if_suite
else:
  else_suite
```

```
if expression1:
  if_suite
elif expression2:
  elif_suite
else:
  else_suite
```

### 11、while循环

标准`while`条件循环语句类似`if`；要使用缩进来分隔每个子代码块

```
while expression:
  while_suite
```
`while_suite`会被连续不断的循环执行，知道表达式的值变成`0`或`False`,接着`Pthon`会执行下一句代码

```
counter = 0

while counter < 3:
 print 'loop #%d' % (counter)
 counter += 1
```
```
loop #0
loop #1
loop #2
[Finished in 0.1s]
```

### 12、for循环和range()内建函数

Python中的`for`接受**可迭代对象(例如序列或迭代器)作为其参数，每次迭代其中一个元素**

```
for item in ['e-mail','net-surfing', 'homework', 'chat']:
  print item
  
e-mail
net-surfing
homework
chat
[Finished in 0.1s]
```
**在print语句的最后添加一个逗号`(,)` ，就可以改变它的输出**

```
for item in ['e-mail','net-surfing', 'homework', 'chat']:
  print item,
  

e-mail net-surfing homework chat
[Finished in 0.1s]
```
**为了输出美观，带逗号的print语句输出的元素之间会自动添加一个空格**

```
who = 'knights'
what = 'Ni!'
print 'We are the %s who say %s' % (who, ((what + ' ') * 4))

We are the knights who say Ni! Ni! Ni! Ni! 
[Finished in 0.1s]
```

演示一个让Python for循环更像传统循环

```
for eachNum in [0, 1, 2]:
  print eachNum,
  
0 1 2
[Finished in 0.1s]
```

对字符串来说，很容易迭代每一个字符

```
foo = 'abc'
for c in foo:
  print c,
  
a b c
[Finished in 0.1s]
```

#### `range()`函数经常和`len()`函数一起用于字符串索引；显示下每一个元素及其索引值

```
foo = 'abc'
for i in range(len(foo)):
  print foo[i], '(%d)' % i
```
```
a (0)
b (1)
c (2)
```
#### `enumerate()`函数同时做到了这两点

```
foo = 'abc'
for i, ch in enumerate(foo):
  print ch, '(%d)' % i
```

```
a (0)
b (1)
c (2)
```

### 13、列表解析

可以在一行中使用一个`for`循环将所有值放到一个列表当中

```
squared = [x ** 2 for x in range (4)]
for i in squared:
  print i,
```
```
0 1 4 9
```
列表解析甚至做更复杂的事情；**例如挑选出符合要求的值放入列表**

```
qdEvens = [x ** 2 for x in range(8) if not x % 2]
for i in sqdEvens:
  print i,
```
```
0 4 16 36
```

### 14、文件和内建函数`open()`、`file()`

如何打开文件

```
handle = open(file_name,access_mode = 'r')
```

* `file_name`变量包含希望打开的文件的字符串名字；
* `access_mode`中`'r'`表示读取，`'w'`表示写入，`'a'`表示添加；
* 其它可能用到的标识`'+'`标识读写，`'b'`标识二进制访问；
* 如果未提供`access_mode`，默认值为`'r'`；
* 如果`open()`成功，一个文件对象句柄会被返回。


### 15、错误和异常

编译时会检查语法错误，不过Python也允许在程序运行时检测错误

要给代码添加错误检测及异常处理，只要将他们“封装”在`try-except`语句当中；

* `try`之后的代码组，就是打算管理的代码；
* `except`之后的代码组，则是处理错误的代码

```
try:
  filename = raw_input('Enter file name: '
  fobj = open(filename, 'r')
  for eachLine in fobj:
    print eachLine,
  fobj.close()
except IOError, e:
   print 'file open error:', e
```


### 16、函数

Python中的函数使用小括号 `()` 调用，函数在调用之前必须先定义，如果函数中没有`return`语句，就会自动返回`None`对象

```
def function_name(arguments):   # "optional documentation string"
  function_suite
```

定义一个函数的语法有`def`关键字及紧随其后的函数名，再加上该函数需要的几个参数组成

例：“在我的值上加我”，它接受一个对象，将它的值加到自身，然后返回和

```
def addMe2Me(x):
	return (x + x)

print addMe2Me(4.25)
8.5
``` 

```
print addMe2Me('Python')
PythonPython
```

```
print addMe2Me([-1, 'abc'])
[-1, 'abc', -1, 'abc']
```

```
def foo(debug=True):
    if debug:
    	print 'in debug mode'
    print 'done'

print foo()
in debug mode
done
      
print foo(False)
done
```

上面的例子中，debug参数有一个默认值True；

* 如果没有传递参数给函数foo()，`debug`自动拿到一个值`True`；
* 在第二次调用`foo()`时，故意传递一个参数`False`给`foo()`，这样，默认参数就没有被使用。


### 17、类

类是面向对象编程的核心，它扮演相关数据及逻辑容器的角色；提供了创建“真实”对象(也就是实例)的蓝图

#### 如何定义类

```
classClassName(base_class[es]):
    static_member_declarations
    method_declarations
```

例：

使用`class`关键字定义类，可以提供一个可选的父类或者说基类

```
class FooClass(object):
  version = 0.1           #class(data) attribute
  
  def __init__(self, nm='JohnDoe'):
    self.name = nm # class instance(data) attribute
    print 'Created a class instance for', nm
    
  def showname(self):
    print 'Your name is', self.name
    print 'My name is',self.__class__.__name__
  
  def showver(self):
    print self.version      # references FooClass.version
    
  def addMe2Me(self, x):      #doesn't use 'self'
    return x + x

``` 

上面的类中，定义了一个静态变量`version`，它将被所有实例及4个方法共享`_init_()`、`showname()`、`showver()`及熟悉的`addMe2Me()`；这些`show()`方法并没有做什么有用的事情，仅仅输出对应的信息。

#### 创建类实例

```
fool = FooClass()
Created a class instancefor JohnDoe

```

#### 方法调用

```
fool.showname()
Your name is JohnDoe
My name is FooClass
```

```
fool.showver()
0.1
```

```
print fool.addMe2Me(5)
10
```

```
print fool.addMe2Me('xyz')
xyzxyz
```

### 18、模块

#### 模块是一种组织形式，可以包含执行代码、函数和类，或者这些东西的组合

**导入模块**

```
import module_name
```

访问模块函数或者模块变量

导入之后，模块的属性（函数和变量）可以通过 .（句点）属性标识法访问。

```
module.function()
module.variable
```
例：使用`sys`模块中的输出函数输出`HelloWorld！`

```
import sys
sys.stdout.write('HelloWorld!\n')

HelloWorld!

print sys.platform
darwin

print sys.version
2.7.10 (default, Aug 17 2018, 19:45:58) 
[GCC 4.2.1 Compatible Apple LLVM 10.0.0 (clang-1000.0.42)]
```

这些的代码输出与之前使用的print语句完全相同；
唯一的区别在于这次调用了标准输出的write()方法，而且这次需要显示地在字符中提供换行字符；
**不同于print语句，write()不会自动在字符串后面添加换行符号。**





   







