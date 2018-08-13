# Python OOP Tutorial

## Class Introduction

```
class Employee:
	pass
	
emp1 = Employee()
emp2 = Employee()

print(emp1)
print(emp2)

# different memory location
# <__main__.Employee object at 0x10fb75ef0>
# <__main__.Employee object at 0x10fb75eb8>
```


## Common Class In RealWorld

```
class Employee:
	raise_rate = 1.04 
	
#construct function  
	def __init__(self, first, last, pay):
		self.first = first            # instance variable unique to each instance
		self.last = last
		self.pay = pay
		self.email = first + '_' + last + '@company.com'

	def pay_raise(self):
		self.pay = int(self.pay * self.raise_rate)
		return self.pay
		
emp_1 = Employee('Jacob','Newrton',1000 )

print(emp_1.raise_rate)
print(emp_1.email)

	
print(emp_1.__dict__)
print(emp_1.__dict__.keys())
print(emp_1.__dict__.values())	
```
`__dict__` attribute:  object.attribute

`__dict__.keys()`   : output dict keys  
`__dict__.values()` : output dict values

```
1.04
Jacob_Newrton@company.com

{'first': 'Jacob', 'last': 'Newrton', 'pay': 1000, 'email': 'Jacob_Newrton@company.com'}
dict_keys(['first', 'last', 'pay', 'email'])
dict_values(['Jacob', 'Newrton', 1000, 'Jacob_Newrton@company.com'])
```