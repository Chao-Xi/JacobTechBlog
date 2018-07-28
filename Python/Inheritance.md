![Alt Image Text](https://github.com/Chao-Xi/TechBlog/blob/master/Python/images/jc1.jpg "Headline image")
# Class Inheritance in Python 3
I will go through some of the major aspects of inheritance in Python, including how parent classes and child classes work, how to override methods and attributes, how to use the super() function, and how to make use of multiple inheritance.

## What Is Inheritance?
Inheritance is when a class uses code constructed within another class.
Classes called `child classes` or `subclasses` inherit methods and variables from `parent classes` or `base classes`.

The `Child subclass` is inheriting from the `Parent base class`, the `Child` class can reuse the code of `Parent`, **allowing the programmer to use fewer lines of code and decrease redundancy**.

## Overriding Parent Methods
Sometime we will want to make use of some of the parent class behaviors but not all of them. When we change parent class methods we override them.

```
class Employee:
	num_of_emps = 0    #class variable shared by all instances
	raise_rate = 1.04 

	def __init__(self, first, last, pay):
		self.first = first            # instance variable unique to each instance
		self.last = last
		self.pay = pay
		self.email = first + '_' + last + '@company.com'

		Employee.num_of_emps += 1   #class variable

	def fullname(self):
		 return '{} {}'.format(self.first, self.last)

	def pay_raise(self):
		self.pay = int(self.pay * self.raise_rate)
		return self.pay

class Developer(Employee):
	raise_rate = 1.10

emp_1 = Developer('Jacob','Newrton',1000 )

print(emp_1.pay)   #output 1000
emp_1.pay_raise()  #already changed to 1.1
print(emp_1.pay)   #output 1100
```

## The `super()` Function
With the `super()` function, you can gain access to inherited methods that have been overwritten in a class object.

When we use the `super()` function, we are calling a parent method into a child method to make use of it. For example, we may want to override one aspect of the parent method with certain functionality, but then call the rest of the original parent method to finish the method.

The `super()` function is most commonly used within the `__init__()` method because that is where you will most likely need to add some uniqueness to the child class and then complete initialization from the parent.

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

class Developer(Employee):
	raise_rate = 1.10
	def __init__(self, first, last, pay, prog_lang):  #pass prog_lang as new parameter
		super().__init__(first, last, pay)       
#dont have to pass 'self' into the super().__init__(first, last, pay)
#Employee.__init__(self, first, last, pay) is an alernative way
		
		self.prog_lang = prog_lang


dev_1 = Developer('Jacob','Newrton',1000,'Python')
dev_2 = Developer('Ana','Joy', 2000, 'PHP')


print(dev_1.email)                #output: Jacob_Newrton@company.com
print(dev_2.prog_lang)
```
The built-in Python function super() allows us to utilize parent class methods even when overriding certain aspects of those methods in our child classes.

## Multiple Inheritance

**Multiple inheritance** is when a class can inherit attributes and methods from more than one parent class. This can allow programs to reduce redundancy, but it can also introduce a certain amount of complexity as well as ambiguity, so it should be done with thought to overall program design.

## isinstance and issubclass

### isinstance:
Use this built-in function to find out if a given object is an instance of a certain class or any of its subclasses. You can even pass a tuple of classes to be checked for the object

### issubclass:
This built-in function is similar to isinstance, but to check if a type is an instance of a class or any of its subclasses.

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

	def pay_raise(self):
		self.pay = int(self.pay * self.raise_rate)
		return self.pay
#two subclass Developer and Manager
class Developer(Employee):
	raise_rate = 1.10
	def __init__(self, first, last, pay, prog_lang):
		super().__init__(first, last, pay)
		# Employee.__init__(self, first, last, pay)
		self.prog_lang = prog_lang

class Manager(Employee):

	def __init__(self, first, last, pay, employees = None):
		super().__init__(first, last, pay)
		if employees is None:
			self.employees = []
		else:
			self.employees = employees

	def add_emp(self, emp):
		if emp not in self.employees:
			self.employees.append(emp)

	def remove_emp(self, emp):
		if emp in self.employees:
			self.employees.remove(emp)

	def print_emps(self):
		for emp in self.employees:
			print('-->', emp.fullname())		


dev_1 = Developer('Jacob','Newrton',1000,'Python')
dev_2 = Developer('Ana','Joy', 2000, 'PHP')

mgr_1 = Manager('Sue','Smith',90000, [dev_1])

print(mgr_1.email)                #output: Sue_Smith@company.com

print(len(mgr_1.employees))       #output: 1
print(mgr_1.print_emps())         #output: --> Jacob Newrton

mgr_1.add_emp(dev_2)              
print(len(mgr_1.employees))       #output: 2
print(mgr_1.print_emps())         #output: --> Jacob Newrton
                                           --> Ana Joy 
mgr_1.remove_emp(dev_1)          
print(len(mgr_1.employees))       #output: 1
print(mgr_1.print_emps())         #output: --> Ana Joy 

print(isinstance(dev_2, Employee))        #output: True
print(isinstance(mgr_1, Manager))         #output: True
print(issubclass(Manager, Employee))      #output: True
print(issubclass(Manager, Developer))     #output: Flase
```

## Conclusion
I went through constructing parent classes and child classes, overriding parent methods and attributes within child classes, using the super() function, and using two special functions isinstance(ins, cls) and issubclass(cls1, cls2)

Inheritance in object-oriented coding can allow for adherence to the DRY (don’t repeat yourself) principle of software development, allowing for more to be done with less code and repetition. Inheritance also compels programmers to think about how they are designing the programs they are creating to ensure that code is effective and clear.

