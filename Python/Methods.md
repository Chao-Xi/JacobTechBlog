![Alt Image Text](https://github.com/Chao-Xi/TechBlog/blob/master/Python/images/hoboken2.jpg "Headline image")
# python中的静态方法和类方法

Though `classmethod` and `staticmethod` are quite similar, there's a slight difference in usage for both entities: `classmethod` must have a reference to a class object as the first parameter, whereas `staticmethod` can have no parameters at all.

## 静态方法：

静态方法是类中的函数，不需要实例。静态方法主要是用来存放逻辑性的代码，主要是一些逻辑属于类，但是和类本身没有交互，即在静态方法中，不会涉及到类中的方法和属性的操作。可以理解为将静态方法存在此类的名称空间中。事实上，在python引入静态方法之前，通常是在全局名称空间中创建函数。

@staticmethod means: when this method is called, we don't pass an instance of the class to it (as we normally do with methods). This means you can put a function inside a class but you can't access the instance of that class (this is useful when your method does not use the instance).


```
class Employee:
	def __init__(self, first, last, pay):
		self.first = first          
		self.last = last
		self.pay = pay
		self.email = first + '_' + last + '@company.com'

	def fullname(self):
		 return '{} {}'.format(self.first, self.last)
	
	@staticmethod
	def is_workday(day):
		if day.weekday() == 5 or day.weekday() == 6:
			return False
	return True

import datetime
today_date = datetime.datetime.now().date()
print(Employee.is_workday(today_date))    #output: True
#Employee class call the static function 
  
tom_date = datetime.datetime.now().date() + datetime.timedelta(days=1)
print(Employee.is_workday(tom_date))	      #output: False

emp_1 = Employee('Jacob','Newrton',1000 )
print(emp_1.is_workday(today_date))
#Instance call the static function
```

如上，使用静态函数，既可以将获得时间的函数功能与实例解绑，当我想判断时间是否是workday时，并不一定必须实例化对象，此时更像是一种名称空间。

***_静态函数可以通过类名以及实例两种方法调用！_***


## 类方法：

类方法是将类本身作为对象进行操作的方法。他和静态方法的区别在于：不管这个方式是从实例调用还是从类调用，它都用第一个参数把类传递过来。

@staticmethod means: when this method is called, we don't pass an instance of the class to it (as we normally do with methods). This means you can put a function inside a class but you can't access the instance of that class (this is useful when your method does not use the instance).

```
class Employee:
	raise_rate = 1.04 

	def __init__(self, first, last, pay):
		self.first = first            # instance variable unique to each instance
		self.last = last
		self.pay = pay
		self.email = first + '_' + last + '@company.com'

	def fullname(self):
		 return '{} {}'.format(self.first, self.last)
	
	@classmethod
	def set_raise_amt(cls, amount):
		cls.raise_rate = amount
    
   #class method as alternative constructive method
	@classmethod
	def from_string(cls, emp_str):
		first, last, pay = emp_str.split('-')
		return cls(first, last, pay)


emp_str_1='John-Denver-7000'
new_emp_1 = Employee.from_string(emp_str_1)
print(new_emp_1.first)      #output: John
```

Actually, we use class `Employee` to call this method and pass `variables` into method, **without instantiating the class**, the first argument for `@classmethod` function must always be `cls (class)`.

**class method can be treadted as alternative constructive method**


类方法可以对类变量产生类层面上的改变。

```
class Employee:
	raise_rate = 1.04 

	def __init__(self, first, last, pay):
		self.first = first           
		self.last = last
		self.pay = pay
		self.email = first + '_' + last + '@company.com'

	def fullname(self):
		 return '{} {}'.format(self.first, self.last)

	def pay_raise(self):
		self.pay = int(self.pay * self.raise_rate)
		return self.pay
	
	@classmethod
	def set_raise_amt(cls, amount):
		cls.raise_rate = amount
		
emp_1 = Employee('Jacob','Newrton',1000 )
emp_2 = Employee('Ana','Joy',2000)

print(emp_1.raise_rate)                 #1.04
print(emp_2.raise_rate)                 #1.04
print(Employee.raise_rate)              #1.04

Employee.set_raise_amt(1.05)
print(emp_1.raise_rate)                 #1.05
print(emp_2.raise_rate)                 #1.05
print(Employee.raise_rate)		        #1.05      
#The raise_rate will be changed from 1.04 to 1.05
    
```

***_静态函数可以通过类名以及实例两种方法调用！_***


