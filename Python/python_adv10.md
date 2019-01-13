# Duck Typing and Asking Forgiveness, Not Permission (EAFP)

In this Python Tutorial, we will look at a couple of the aspects of being "Pythonic". If you've never heard the term Pythonic before, basically it means that you are following conventions and coding styles of the Python language in order to write clean and readable code.


### Example 1


```
class Duck:

    def quack(self):
        print('Quack, quack')

    def fly(self):
        print('Flap, Flap!')


class Person:

    def quack(self):
        print("I'm Quacking Like a Duck!")

    def fly(self):
    	 print("I'm Flapping my Arms!")
```

```
#none Duck-typed("Non-Pythonic")
def quack_and_fly(thing):
	if isinstance(thing, Duck):
		thing.quack()
		thing.fly()
	else:
		print('This is has to be a Duck')

d = Duck()
quack_and_fly(d)

p = Person()
quack_and_fly(p)

>>> Quack, quack
>>> Flap, Flap!
>>> This is has to be a Duck
```

```
## LBYL (Non-Pythonic)
def quack_and_fly(thing):

	if hasattr(thing, 'quack'):
		if callable(thing.quack):
			thing.quack()

	if hasattr(thing, 'fly'):
		if callable(thing.fly):
			thing.fly()

	print()

d = Duck()
quack_and_fly(d)

p = Person()
quack_and_fly(p)

>>> Quack, quack
>>> Flap, Flap!

>>> I'm Quacking Like a Duck!
>>> I'm Flapping my Arms!
```

#### EAFP with `try ... except AttributeError as e:`

```
# EAFP (Pythonic)

def quack_and_fly(thing):
	try:
		thing.quack()
		thing.fly()
		thing.bark()
	except AttributeError as e:
		print(e)

	print()

	
d = Duck()
quack_and_fly(d)

p = Person()
quack_and_fly(p)

>>> Quack, quack
>>> Flap, Flap!
>>> 'Duck' object has no attribute 'bark'

>>> I'm Quacking Like a Duck!
>>> I'm Flapping my Arms!
>>> 'Person' object has no attribute 'bark'
```

### Example 2

```
my_list = [1,2,3,4,5]

# Non-Pythonic 
if len(my_list) >= 6:
	print(my_list[5])
else:
	print('That index does not exist')

print()

>>> That index does not exist
```

#### EAFP with `try ... except IndexError:`

```
# Pythonic
try:
	print(my_list[5])
except IndexError:
	print('That index does not exist')

>>> That index does not exist
```

