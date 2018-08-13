# Python OOP Tutorial

## Decorators

**Python decorator is a function that helps to add some additional functionalities to an already defined function.** 

Python decorator is very helpful to add functionality to a function that is implemented before without making any change to the original function. Decorator is very efficient when want to give an updated code to an existing code.

**` @property`**

**` @my_attr.setter`**

**` @my_attr.deleter`**



### Example Code:

```
class Employee:
        
        def __init__(self, first, last):
                self.first = first            # instance variable unique to each instance
                self.last = last


        @property
        def fullname(self):
            return '{} {}'.format(self.first, self.last)
            
        @property
        def email(self):
            return "{}.{}@email.com".format(self.first, self.last)   

        @fullname.setter
        def fullname(self, name):
            first, last = name.split(' ')
            self.first = first
            self.last = last

        @fullname.deleter
        def fullname(self):
            print('Delete Name')
            self.first = None
            self.last = None 
            
emp_1 = Employee('Jacob','Newrton')

emp_1.fullname = 'Captain Deadpool' 
print(emp_1.fullname)     #fullname function as a property
print(emp_1.first)        #output object.first as from @fullname.setter
print(emp_1.email)        #email function as a property

# Captain Deadpool
# Captain
# Captain.Deadpool@email.com
           
```

```
del emp_1.fullname               #call the delete function as delete attribute/property
print(emp_1.fullname)            # del obj.delproperty
print(emp_1.first)
print(emp_1.email)

# Delete Name
# None None
# None
# None.None@email.com
```