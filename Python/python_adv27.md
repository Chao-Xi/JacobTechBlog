# Iterators and Iterables

## Loop the list

```
nums = [1, 2 ,3]

for i in nums:
	print(i, end=" ")

print()

>>> 1 2 3 
```

## dir function

The `dir()` method tries to return a list of valid attributes of the object.

### So I get list of attributes and functions of the "list"

```
print (dir(nums))

>>>
['__add__', '__class__', '__contains__', '__delattr__', '__delitem__', '__dir__', '__doc__', 
'__eq__', '__format__', '__ge__', '__getattribute__', '__getitem__', '__gt__', '__hash__', 
'__iadd__', '__imul__', '__init__', '__init_subclass__', '__iter__', '__le__', '__len__', 
'__lt__', '__mul__', '__ne__', '__new__', '__reduce__', '__reduce_ex__', '__repr__', 
'__reversed__', '__rmul__', '__setattr__', '__setitem__', '__sizeof__', '__str__', 
'__subclasshook__', 'append', 'clear', 'copy', 'count', 'extend', 'index', 'insert', 'pop', 
'remove', 'reverse', 'sort']
```

### So we can see `'__iter__' ` is dunder, special, magic function

## `list.__iter__` or `iter(list)`

```
i_nums = iter(nums)

print(i_nums)
print(dir(i_nums))

>>> <list_iterator object at 0x10eb74358>
>>> ['__class__', '__delattr__', '__dir__', '__doc__', '__eq__', '__format__', '__ge__', 
'__getattribute__', '__gt__', '__hash__', '__init__', '__init_subclass__', '__iter__', 
'__le__', '__length_hint__', '__lt__', '__ne__', '__new__', '__next__', '__reduce__', 
'__reduce_ex__', '__repr__', '__setattr__', '__setstate__', '__sizeof__', '__str__', '__subclasshook__']
```

### how to output iterator one by one

```
# print(next(i_nums))
# print(next(i_nums))
# print(next(i_nums))
# print(next(i_nums))

>>> 1
>>> 2
>>> 3
>>> Traceback (most recent call last):
  File "/Users/jxi/python/adv1/31iterator1.py", line 22, in <module>
    print(next(i_nums))
StopIteration
```

### how to prevent `StopIteration`: `try ... except StopIteration ...`

**The iterator is only going forward**

```
while True:
	try:
		item = next(i_nums)
		print(item)
	except StopIteration:
		break
>>> 1
>>> 2
>>> 3
```

## Self designed iterator class

```
class MyRange:

	def __init__(self, start, end):
		self.value = start
		self.end = end

	def __iter__(self):
		return self

	def __next__(self):
		if self.value >= self.end:
			raise StopIteration
		current = self.value
		self.value += 1
		return current

new_nums = MyRange(1,10)

# for i in new_nums:
# 	print(i)

print(next(new_nums))
print(next(new_nums))
print(next(new_nums))
print(next(new_nums))

>>> 1
>>> 2
>>> 3
>>> 4
```

## Self designed iterator function with `Generator`

```
def g_range(start, end):
	current = start
	while current < end:
		yield current
		current += 1

g_nums = g_range(1,10)

# for i in g_nums:
# 	print(i)

print(dir(g_nums))
>>> ['__class__', '__del__', '__delattr__', '__dir__', '__doc__', '__eq__', '__format__', 
'__ge__', '__getattribute__', '__gt__', '__hash__', '__init__', '__init_subclass__', 
'__iter__', '__le__', '__lt__', '__name__', '__ne__', '__new__', '__next__', '__qualname__', 
'__reduce__', '__reduce_ex__', '__repr__', '__setattr__', '__sizeof__', '__str__', 
'__subclasshook__', 'close', 'gi_code', 'gi_frame', 'gi_running', 'gi_yieldfrom', 'send', 
'throw']

# we can see the next function inside the attributess

print(next(g_nums))
print(next(g_nums))
print(next(g_nums))
print(next(g_nums))

>>> 1
>>> 2
>>> 3
>>> 4
```

## Creating Your Own text Iterators 

```
class Sentence:

	def __init__(self, sentence):
		self.sentence = sentence
		self.index = 0
		self.words = self.sentence.split()

	def __iter__(self):
		return self

	def __next__(self):
		if self.index >= len(self.words):
			raise StopIteration
		index = self.index
		self.index += 1
		return self.words[index]

my_sentence = Sentence('This is a test')

print(next(my_sentence))
print(next(my_sentence))

>>> This
>>> is

for word in my_sentence:
	print(word)

>>> a
>>> test
```

## Creating Your Own text Iterators with generator

```
def sentense(sentense):
	for word in sentense.split():
		yield word

g_sentence = sentense('this is a test2')


for word in g_sentence:
	print(word)	

>>> this
>>> is
>>> a
>>> test2	
```

