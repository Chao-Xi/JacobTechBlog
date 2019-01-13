# Python Decorators - Dynamically Alter The Functionality Of Your Functions

Decorators are a way to dynamically alter the functionality of your functions. So for example, if you wanted to log information when a function is run, you could use a decorator to add this functionality without modifying the source code of your original function.


## Decorators prototype: inner and outer function

```
def outer_function(msg):

	def inner_functiom():
		print(msg)
	return inner_functiom

hi_func = outer_function('Bonjour')
bye_func = outer_function('Bonsoir')

hi_func()
bye_func()

>>> Bonjour
>>> Bonsoir
```

## Decorators function in original way

`decorated_display = decorator_function(display)`

```
def decorator_function(original_function):
	def wrapper_function():
		print(f'Wrapper executed this before {original_function.__name__}')
		return original_function
	return wrapper_function


def display():
	print('display function ran')

decorated_display = decorator_function(display) #this is decorator in original way

decorated_display()

>>> Wrapper executed this before display
>>> display function ran
```

## Decorators function in modern way

```
@decorator_function
def display:
	...
```

```
def decorator_function(original_function):
	def wrapper_funcion():
		print(f'Wrapper executed this before {original_function.__name__}')
		print('Wrapper executed this before {}'.format(original_function.__name__))
		return original_function
	return wrapper_fucntion

@decorator_function
def display1():
	print('display function ran in prevalent mode')

display1()

>>> Wrapper executed this before display1
>>> Wrapper executed this before display1
>>> display function ran in prevalent mode
```

### `decorated_display = decorator_function(display)  <=> @decorator_function`

## multiple functions call the same decorators `*args`, `**kwargs`

```
# add another function with same decorator
@decorator_function
def display_info(name, age):
	print(f'display_info ran with arguments {name}, {age}')

display_info('jj', 25)

# TypeError: wrapper_fucntion() takes 0 positional arguments but 2 were given

```
### so we need ad `*args`, `**kwargs` into the functions, allow us put any number of arguments into the decorator_function

```
def decorator_function(original_function):
	def wrapper_function(*args, **kwargs):
		print(f'Wrapper executed this before {original_function.__name__}')
		print('Wrapper executed this before {}'.format(original_function.__name__))
		return original_function(*args, **kwargs) 
	return wrapper_function


@decorator_function
def display1():
	print('display function ran in prevalent mode')

display1()

# add another function with same decorator
@decorator_function
def display_info(name, age):
	print(f'display_info ran with arguments {name}, {age}')

>>> Wrapper executed this before display_info
>>> Wrapper executed this before display_info
>>> display_info ran with arguments jj, 25
```

## `decorator_class` is similar to `decorator_function`

```
class decorator_class(object):

	def __init__(self, original_function):
		self.original_function = original_function

	def __call__(self, *args, **kwargs):
		print(f'call method executed this before {self.original_function.__name__}')
		return self.original_function(*args, **kwargs)


@decorator_class
def display1():
	print('display function ran')

display1()

@decorator_class
def display_info(name, age):
	print(f'display_info ran with arguments {name}, {age}')

display_info('xxo','26')

>>> call method executed this before display1
>>> display function ran

>>> call method executed this before display_info
>>> display_info ran with arguments xxo, 26
```

## `decorator_function` in pratical example

### Create log self define log function

```
def my_logger(orig_func):
    import logging
    logging.basicConfig(filename=f'{orig_func.__name__}.log', level=logging.INFO)

    def wrapper(*args, **kwargs):
        logging.info(
            f'Ran with args: {args}, and kwargs: {kwargs}')
        return orig_func(*args, **kwargs)

    return wrapper

@my_logger
def display_info(name, age):
	print(f'display_info ran with arguments {name} {age}')

display_info('John Wick', 36)
display_info('Taylor Swift', 30)
```

```
$ ls -lt
-rw-r--r--  1 jxi  BBBB\Domain Users     360 Jan  5 19:29 display_info.log

$ less display_info.log
INFO:root:Ran with args: ('John Wick', 36), and kwargs: {}
INFO:root:Ran with args: ('Taylor Swift', 30), and kwargs: {}
```

### Create running time cost function

```
def my_timer(orig_func):
    import time

    def wrapper(*args, **kwargs):
        t1 = time.time()
        result = orig_func(*args, **kwargs)
        t2 = time.time() - t1
        print(f'{orig_func.__name__} ran in: {t2} sec')
        return result

    return wrapper

import time
@my_timer
def display_info1(name, age):
	time.sleep(1)
	print(f'display_info ran with arguments {name} {age}')

display_info1('Aurora', 32)

display_info ran with arguments Aurora 32
display_info1 ran in: 1.004746913909912 sec
```

## One function call multiple decorators 

### Need `functools module` with  `wraps functions`

```
from functools import wraps  

def decorator_function(orig_func):
   ...
 	@wraps(orig_func)
	...

@decorator_function1
@decorator_function2
def function1():
	... 
```


```
from functools import wraps    

def my_logger(orig_func):
    import logging
    logging.basicConfig(filename='{}.log'.format(orig_func.__name__), level=logging.INFO)

    @wraps(orig_func)     # notice here
    def wrapper(*args, **kwargs):
        logging.info(
            'Ran with args: {}, and kwargs: {}'.format(args, kwargs))
        return orig_func(*args, **kwargs)

    return wrapper


def my_timer(orig_func):
    import time

    @wraps(orig_func)   # notice here
    def wrapper(*args, **kwargs):
        t1 = time.time()
        result = orig_func(*args, **kwargs)
        t2 = time.time() - t1
        print('{} ran in: {} sec'.format(orig_func.__name__, t2))
        return result

    return wrapper

import time


@my_logger
@my_timer
def display_info(name, age):
    time.sleep(1)
    print('display_info ran with arguments ({}, {})'.format(name, age))

display_info('Tom', 22)
```

## Decorators With Arguments

 How to create decorators with parameters that accept arguments

### Normal Decorators without argument input

```
def decorator_function(original_function):
    def wrapper_function(*args, **kwargs):
        print('Executed Before', original_function.__name__)
        result = original_function(*args, **kwargs)
        print('Executed After', original_function.__name__, '\n')
        return result
    return wrapper_function


@decorator_function
def display_info(name, age):
    print('display_info ran with arguments ({}, {})'.format(name, age))
    
display_info('John', 25)
display_info('Travis', 30)

>>> Executed Before display_info
>>> display_info ran with arguments (John, 25)
>>> Executed After display_info 

>>> Executed Before display_info
>>> display_info ran with arguments (Travis, 30)
>>> Executed After display_info 
```

### Decorators with parameter input

#### input one argument 'prefix' as parameter to decorator

 
```
def prefix_decorator(prefix):
	def decorator_function(original_function):
		def wrapper_function(*args, **kwargs):
			print(prefix, 'Executed Before', original_function.__name__)
			result = original_function(*args, **kwargs)
			print(prefix, 'Executed After', original_function.__name__, '\n')
			return result
		return wrapper_function
	return decorator_function


@prefix_decorator('LOG:')
def display_info(name, age):
    print(f'display_info ran with arguments {name}, {age}')



display_info('John', 25)
display_info('Travis', 30)


>>> LOG: Executed Before display_info
>>> display_info ran with arguments John, 25
>>> LOG: Executed After display_info 

>>> LOG: Executed Before display_info
>>> display_info ran with arguments Travis, 30
>>> LOG: Executed After display_info 
```


