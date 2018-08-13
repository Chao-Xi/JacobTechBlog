# Python OOP Tutorial

## Magic Methods


### Guide Book to Python's Magic Methods

[https://rszalski.github.io/magicmethods/](https://rszalski.github.io/magicmethods/)

## Magic Methods Basic Category

### Construction and Initialization


**`__init__(self, [...)`**

The initializer for the class. It gets passed whatever the primary constructor was called with, `__init__` is almost universally used in Python class definitions.

### Representing your Classes

**`__repr__(self)`**

Defines behavior for when repr() is called on an instance of your class. The major difference between str() and repr() is intended audience. repr() is intended to produce output that is mostly machine-readable, whereas str() is intended to be human-readable.

**`__str__(self)`**

Defines behavior for when str() is called on an instance of your class.


### Numeric magic methods

**`__add__(self, other)`**

Implements addition.

### Making Custom Sequences

**`__len__(self)`**

Returns the length of the container. Part of the protocol for both immutable and mutable containers.


### Example Code:

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

        def __repr__(self):
            return "Employee('{}', '{}', '{}')".format(self.first, self.last, self.pay)

        def __str__(self):
            return '{} - {}'.format(self.fullname(), self.email) 

        def __add__(self, other):
            return self.pay + other.pay

        def __len__(self):
            return len(self.fullname())

emp_1 = Employee('Jacob','Newrton',1000)
emp_2 = Employee('Ana','Joy', 2000)

print(emp_1)               #with str attr: Defines behavior of class
print(repr(emp_1))         
print(str(emp_2))


# Jacob Newrton - Jacob_Newrton@company.com      
# Employee('Jacob', 'Newrton', '1000')
# Ana Joy - Ana_Joy@company.com
```

```
print(1+2)
print(int.__add__(1, 2))
print(str.__add__("a", "b"))

# 3
# 3
# ab
```

```
print(emp_1 + emp_2)

# 3000
```

```
print(len('test'))
print('test'.__len__())

# 4
# 4
```

```
print(len(emp_2))

# 7
```
