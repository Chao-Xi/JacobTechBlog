# Logging Basic and Advanced

## Logging Basic - Logging to Files, Setting Levels, and Formatting

### Format

* **DEBUG**: Detailed information, typically of interest only when diagnosing problems.
* **INFO**: Confirmation that things are working as expected.
* **WARNING**: An indication that something unexpected happened, or indicative of some problem in the near future (e.g. ‘disk space low’). The software is still working as expected.
* **ERROR**: Due to a more serious problem, the software has not been able to perform some function.
* **CRITICAL**: A serious error, indicating that the program itself may be unable to continue running.


### Output log into console

```
import logging

logging.basicConfig(level=logging.DEBUG)

def add(x, y):
    """Add Function"""
    return x + y


def subtract(x, y):
    """Subtract Function"""
    return x - y


def multiply(x, y):
    """Multiply Function"""
    return x * y


def divide(x, y):
    """Divide Function"""
    return x / y


num_1 = 20
num_2 = 10

add_result = add(num_1, num_2)
logging.debug('Add: {} + {} = {}'.format(num_1, num_2, add_result))

sub_result = subtract(num_1, num_2)
logging.debug('Add: {} - {} = {}'.format(num_1, num_2, sub_result))


mul_result = multiply(num_1, num_2)
logging.debug('Mul: {} * {} = {}'.format(num_1, num_2, mul_result))


div_result = divide(num_1, num_2)
logging.debug('Div: {} / {} = {}'.format(num_1, num_2, div_result))

>>> DEBUG:root:Add: 20 + 10 = 30
>>> DEBUG:root:Sub: 20 - 10 = 10
>>> DEBUG:root:Mul: 20 * 10 = 200
>>> DEBUG:root:Div: 20 / 10 = 2.0
```

### output log into log file with log records attributes

**Log Record Attribute**: [https://docs.python.org/3/library/logging.html#logrecord-attributes](https://docs.python.org/3/library/logging.html#logrecord-attributes)

```
logging.basicConfig(filename='23test.log', level=logging.DEBUG, format='%(asctime)s:%(levelname)s:%(message)s')
```

```
$ ls -lth 
-rw-r--r--  1 jxi  660531311   424B Jan 15 11:28 23test.log

$ less 23test.log
2019-01-15 11:28:57,596:DEBUG:Add: 20 + 10 = 30
2019-01-15 11:28:57,596:DEBUG:Add: 20 - 10 = 10
2019-01-15 11:28:57,596:DEBUG:Add: 20 * 10 = 200
2019-01-15 11:28:57,596:DEBUG:Add: 20 / 10 = 2.0
```

### Put Info log into log file

```
import logging

logging.basicConfig(filename='23employee.log', level=logging.INFO,
                    format='%(levelname)s:%(message)s')


class Employee:
    """A sample Employee class"""

    def __init__(self, first, last):
        self.first = first
        self.last = last

        logging.info('Created Employee: {} - {}'.format(self.fullname, self.email))

    @property
    def email(self):
        return '{}.{}@email.com'.format(self.first, self.last)

    @property
    def fullname(self):
        return '{} {}'.format(self.first, self.last)


emp_1 = Employee('John', 'Smith')
emp_2 = Employee('Corey', 'Schafer')
emp_3 = Employee('Jane', 'Doe')
```


```
$ less 23employee.log
INFO:Created Employee: John Smith - John.Smith@email.com
INFO:Created Employee: Corey Schafer - Corey.Schafer@email.com
INFO:Created Employee: Jane Doe - Jane.Doe@email.com
INFO:Created Employee: John Smith - John.Smith@email.com
INFO:Created Employee: Corey Schafer - Corey.Schafer@email.com
INFO:Created Employee: Jane Doe - Jane.Doe@email.com
```

## Logging Advanced - Loggers, Handlers, and Formatters

### employe24.py

* `logger = logging.getLogger(__name__)` 
* `logger.setLevel(logging.INFO)`
* `formatter = logging.Formatter('%(levelname)s:%(name)s:%(message)s')`
* `file_handler = logging.FileHandler("24employee.log")`
* `file_handler.setFormatter(formatter)`
* `logger.addHandler(file_handler)`

#### The output message

**`logger.info('Created Employee: {} - {}'.format(self.fullname, self.email))`**

```
import logging


logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

formatter = logging.Formatter('%(levelname)s:%(name)s:%(message)s')

file_handler = logging.FileHandler("24employee.log")
file_handler.setFormatter(formatter)


logger.addHandler(file_handler)

class Employee:
    """A sample Employee class"""

    def __init__(self, first, last):
        self.first = first
        self.last = last
        logger.info('Created Employee: {} - {}'.format(self.fullname, self.email))

    @property
    def email(self):
        return '{}.{}@email.com'.format(self.first, self.last)

    @property
    def fullname(self):
        return '{} {}'.format(self.first, self.last)


emp_1 = Employee('John', 'Smith')
emp_2 = Employee('Corey', 'Schafer')
emp_3 = Employee('Jane', 'Doe')

```

```
$ less 24employee.log

INFO:employee24:Created Employee: John Smith - John.Smith@email.com
INFO:employee24:Created Employee: Corey Schafer - Corey.Schafer@email.com
INFO:employee24:Created Employee: Jane Doe - Jane.Doe@email.com
INFO:employee24:Created Employee: John Smith - John.Smith@email.com
INFO:employee24:Created Employee: Corey Schafer - Corey.Schafer@email.com
INFO:employee24:Created Employee: Jane Doe - Jane.Doe@email.com
INFO:employee24:Created Employee: John Smith - John.Smith@email.com
INFO:employee24:Created Employee: Corey Schafer - Corey.Schafer@email.com
INFO:employee24:Created Employee: Jane Doe - Jane.Doe@email.com
```

* **`StreamHandler()` can also output error message into the console**
* **`try` -> `except` -> `else`**

```
stream_handler = logging.StreamHandler()
stream_handler.setFormatter(formatter)
```

```
from employee24 import Employee
import logging

logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)

formatter = logging.Formatter('%(asctime)s:%(name)s:%(message)s')

file_handler = logging.FileHandler("24logging1.log")
file_handler.setFormatter(formatter)


stream_handler = logging.StreamHandler()
stream_handler.setFormatter(formatter)

logger.addHandler(file_handler)
logger.addHandler(stream_handler) #also output error message into the console


def add(x, y):
    """Add Function"""
    return x + y


def subtract(x, y):
    """Subtract Function"""
    return x - y


def multiply(x, y):
    """Multiply Function"""
    return x * y


def divide(x, y):
    """Divide Function"""
    # return x / y
    try:
    	result = x / y
    except ZeroDivisionError:
    	logger.exception('Tried to divide by zero')
    else:
    	return result


num_1 = 20
num_2 = 0

add_result = add(num_1, num_2)
logger.debug('Add: {} + {} = {}'.format(num_1, num_2, add_result))

sub_result = subtract(num_1, num_2)
logger.debug('Sub: {} - {} = {}'.format(num_1, num_2, sub_result))

mul_result = multiply(num_1, num_2)
logger.debug('Mul: {} * {} = {}'.format(num_1, num_2, mul_result))

div_result = divide(num_1, num_2)

2019-01-15 22:55:28,651:__main__:Sub: 20 - 0 = 20
2019-01-15 22:55:28,651:__main__:Mul: 20 * 0 = 0
2019-01-15 22:55:28,651:__main__:Tried to divide by zero
Traceback (most recent call last):
  File "/Users/jxi/python/adv1/24logging1.py", line 39, in divide
    result = x / y
ZeroDivisionError: division by zero
2019-01-15 22:55:28,652:__main__:Div: 20 / 0 = None
```

```
$ less 24logging1.log

2019-01-15 22:55:28,651:__main__:Add: 20 + 0 = 20
2019-01-15 22:55:28,651:__main__:Sub: 20 - 0 = 20
2019-01-15 22:55:28,651:__main__:Mul: 20 * 0 = 0
2019-01-15 22:55:28,651:__main__:Tried to divide by zero
Traceback (most recent call last):
  File "/Users/jxi/python/adv1/24logging1.py", line 39, in divide
    result = x / y
ZeroDivisionError: division by zero
2019-01-15 22:55:28,652:__main__:Div: 20 / 0 = None
```