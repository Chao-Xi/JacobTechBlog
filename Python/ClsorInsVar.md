![Alt Image Text](https://github.com/Chao-Xi/TechBlog/blob/master/Python/images/hoboken5.jpg "Headline image")

 #Python类变量和实例变量

##大纲：
![Alt Image Text](https://github.com/Chao-Xi/TechBlog/blob/master/Python/images/ClsorInsVar.jpg "ABs image")

##1. 类变量和实例变量(Class and Instance Variables)
Generally speaking, instance variables are for data unique to each instance and class variables are for attributes and methods shared by all instances of the class: ([Reference](https://docs.python.org/3/tutorial/classes.html#class-and-instance-variables))

实例变量是对于每个实例都独有的数据，而类变量是该类所有实例共享的属性和方法。

```
class Employee:     
	raise_rate = 1.04                    #class variable shared by all instances

	def __init__(self, first, last, pay):
		self.first = first               # instance variable unique to each instance
		self.last = last
		self.pay = pay
		self.email = first + '_' + last + '@company.com'

```

类`Employee`中，类变量`raise_rate`为所有实例所共享；实例变量`first, last, pay`为每个`Employee`的实例独有。

## 2. 类对象和实例对象
### 2.1 类对象
`Python`中一切皆对象；类定义完成后，会在当前作用域中定义一个以类名为名字，指向类对象的名字。如

```
class Employee:
	pass
```

会在当前作用域定义名字`Employee`，指向类对象`Employee`。

**类对象支持的操作**：

总的来说，类对象仅支持两个操作：

1. 实例化；使用`instance_name = class_name()`的方式实例化，实例化操作创建该类的实例。例如： `emp_1 = Employee('Jacob','Newrton',1000 )`
2. 变量引用；使用`class_name.var_name`的方式引用类变量。例如：
`Employee.num_of_emps += 1` 

### 2.2 实例对象

实例对象是类对象实例化的产物，实例对象仅支持一个操作：

1. 变量引用；与类对象变量引用的方式相同，使用instance_name.var_name的方式

按照严格的面向对象思想，所有变量都应该是实例的，类变量不应该存在。那么在`Python`中，由于类变量绑定就不应该存在，类定义中就只剩下函数定义了。

In practice, the statements inside a class definition will usually be function definitions, but other statements are allowed, and sometimes useful.([Reference](https://docs.python.org/3/tutorial/classes.html#class-definition-syntax)) 

# 3. 变量绑定

在定义类时，通常我们说的定义变量，其实是分为两个方面的：

* 类变量绑定
* 实例变量绑定

用绑定这个词更加确切；**不管是类对象还是实例对象，变量都是依托对象而存在的**。

我们说的变量绑定，首先需要一个可变对象，才能执行绑定操作，使用

`objname.var = var_value`
的方式，为对象`objname`绑定变量`var`。

例如： `emp_2.raise_rate = 1.05 #instance variable` 

这分两种情况：

* 若变量var已经存在，绑定操作会将变量指向新的对象；
* 若不存在，则为该对象添加新的的变量，后面就可以引用新增变量了。

## 3.1 类属性绑定

`python`作为动态语言，类对象和实例对象都可以在运行时绑定任意变量。因此，类变量的绑定发生在两个地方：

1. 类定义时；
2. 运行时任意阶段。

下面这个例子说明了类变量绑定发生的时期：

```
class Employee:
	num_of_emps = 0    #class variable shared by all instances
	raise_rate = 1.04 

Employee.new_raise_rate = 1.10

print(Employee.raise_rate, ' - ',Employee.new_raise_rate) # output: 1.04  -  1.1
del Employee.raise_rate
print(Employee.raise_rate, ' - ',Employee.new_raise_rate) #AttributeError: type object 'Employee' has no attribute 'raise_rate'
```

在类定义中，类变量的绑定并没有使用`objname.var = var_value`的方式，这是一个特例，其实是等同于后面使用类名绑定变量的方式。
因为是动态语言，所以可以在运行时增加变量，删除变量。

## 3.2 实例变量绑定
与类变量绑定相同，实例变量绑定也发生在两个地方：

1. 类定义时；
2. 运行时任意阶段。

示例：

```
class Employee:

	def __init__(self, first, last, pay):
		self.first = first           
		self.last = last
		self.pay = pay
		self.email = first + '_' + last + '@company.com'
		
	def pay_raise(self):
		self.pay = int(self.pay * self.raise_rate)
		return self.pay

emp_1 = Employee('Ana','Joy',2000)
print(emp_1.__dict__) 
>>> {'first': 'Ana', 'last': 'Joy', 'pay': 2000, 'email': 'Ana_Joy@company.com'}
emp_1.raise_rate = 1.05   ##实例变量绑定
print(emp_1.__dict__) 
>>> {'first': 'Ana', 'last': 'Joy', 'pay': 2000, 'email': 'Ana_Joy@company.com', 'raise_rate': 1.05}
emp_1.pay_raise()      
print(emp_1.pay)
>>> 2100
```

`Python`类实例有两个特殊之处：

1. `__init__`在实例化时执行
2. `Python`实例调用方法时，会将实例对象作为第一个参数传递

因此，`__init__`方法中的`self`就是实例对象本身，这里是emp_1，语句

```
self.first = first           
self.last = last
self.pay = pay
```

以及后面的语句

`emp_1.raise_rate = 1.05 `

为实例emp_1增加四个变量first, last, pay, raise_rate。

# 4. 变量引用
变量的引用与直接访问名字不同，不涉及到作用域。

## 4.1 类变量引用
类属性的引用，肯定是需要类对象的，属性分为两种：

1. 数据变量
2. 函数变量

数据变量引用很简单，示例：

```
class Employee:
	num_of_emps = 0    #class variable shared by all instances
	raise_rate = 1.04 

Employee.new_raise_rate = 1.10

print(Employee.raise_rate, ' - ',Employee.new_raise_rate) # output: 1.04  -  1.1
```
通常很少有引用类函数变量的需求，示例

```
class Employee:
	num_of_emps = 0    #class variable shared by all instances

	def __init__(self, first, last, pay):
		self.first = first            # instance variable unique to each instance
		self.last = last
		self.pay = pay
		self.email = first + '_' + last + '@company.com'
		Employee.num_of_emps += 1 


print('Number of employee: ', Employee.num_of_emps)   # Output: 0
emp_1 = Employee('Jacob','Newrton',1000 )
emp_2 = Employee('Ana','Joy',2000)  
print('Number of employee: ', Employee.num_of_emps)   # Output: 2
```
输出的结果，并不是直接输出`num_of_emps`， 而是输出`Employee.num_of_emps`

## 4.2 实例变量引用

使用实例对象引用变量稍微复杂一些，因为实例对象可引用类变量以及实例变量。但是实例对象引用属性时遵循以下规则：

1. 总是先到实例对象中查找变量，再到类变量中查找变量；
2. 变量绑定语句总是为实例对象创建新变量，变量存在时，更新变量指向的对象。

### 4.2.1 数据变量引用
示例1：

```
class Employee:
	raise_rate = 1.04 

	def __init__(self, first, last, pay):
		self.first = first            # instance variable unique to each instance
		self.last = last
		self.pay = pay
		self.email = first + '_' + last + '@company.com'

	def pay_raise(self):
		self.pay = int(self.pay * self.raise_rate)
		return self.pay

emp_1 = Employee('Jacob','Newrton',1000 )
print(emp_1.raise_rate)       #output 1.04 

emp_2 = Employee('Ana','Joy',2000)
print(emp_2.pay)             # output:  2000
emp_2.pay_raise()
print(emp_2.pay)             # output:  2080, according to rule, raise_rate already used as class attr 
```
实例对象emp_1没有raise_rate，按照规则会引用类对象的变量。

示例2：

```
class Employee:
	raise_rate = 1.04 

	def __init__(self, first, last, pay):
		self.first = first            # instance variable unique to each instance
		self.last = last
		self.pay = pay
		self.email = first + '_' + last + '@company.com'

		Employee.num_of_emps += 1   #class variable


	def pay_raise(self):
		self.pay = int(self.pay * self.raise_rate)
		return self.pay

emp_1 = Employee('Jacob','Newrton',1000 )
emp_1.raise_rate = 1.05 
print(emp_1.raise_rate)       #output 1.05
print(emp_1.__dict__)         #output {'first': 'Jacob', 'last': 'Newrton', 'pay': 1000, 'email': 'Jacob_Newrton@company.com', 'raise_rate': 1.05}   
print(Employee.raise_rate)    #output 1.04
```

使用变量语句`emp_1.raise_rate = 1.05` ，按照规则，为实例对象`emp_1`增加了属性`raise_rate`，后面使用`emp_1.raise_rate`引用到实例对象的属性。

这里不要以为会改变类属性`Employee.raise_rate`的指向，实则是为实例对象新增变量，可以使用查看`__dict__`的方式证明这一点。

### 4.2.2 方法属性引用
与数据成员不同，类函数属性在实例对象中会变成方法属性。

先看一个示例：

```
class MethodTest:

    def inner_test(self):
        print('in class')

def outer_test():
    print('out of class')

mt = MethodTest()
mt.outer_test = outer_test

print(type(MethodTest.inner_test))  # <class 'function'>
print(type(mt.inner_test))          #<class 'method'>
print(type(mt.outer_test))          #<class 'function'>
```
可以看到，类函数属性在实例对象中变成了方法属性，但是并不是实例对象中所有的函数都是方法。

When an instance attribute is referenced that isn’t a data attribute, its class is searched. If the name 
denotes a valid class attribute that is a function object, a method object is created by packing (pointers to)
the instance object and the function object just found together in an abstract object: this is the method 
object. When the method object is called with an argument list, a new argument list is constructed from the 
instance object and the argument list, and the function object is called with this new argument list.([Reference](https://docs.python.org/3/tutorial/classes.html#method-objects))

引用非数据属性的实例属性时，会搜索它对应的类。如果名字是一个有效的函数对象，Python会将实例对象连同函数对象打包到一个抽象的对象中并且依据这个对象创建方法对象：这就是被调用的方法对象。当使用参数列表调用方法对象时，会使用实例对象以及原有参数列表构建新的参数列表，并且使用新的参数列表调用函数对象。

那么，实例对象只有在引用方法属性时，才会将自身作为第一个参数传递；调用实例对象的普通函数，则不会。
所以可以使用如下方式直接调用方法与函数：

```
mt.inner_test()
mt.outer_test()
```
除了方法与函数的区别，其引用与数据属性都是一样的


## 虽然`Python`作为动态语言，支持在运行时绑定属性，但是从面向对象的角度来看，还是在定义类的时候将属性确定下来。
