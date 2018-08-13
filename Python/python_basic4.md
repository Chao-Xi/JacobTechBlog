# Python Tutorial for Beginners

## 1. Conditionals and Booleans - If, Else, and Elif Statements

```
if A == B:
	print()
elif A == C:
	print()
else:
	print()


and or not
if user == 'Admin' and password == 'Password' or ...:
	print()
else:
	print()
```

```
#and  #or  #not
user= 'Admin'
Password ='Password'
logged_in = True

if user == 'Admin' and Password == 'Password' and logged_in:
	print('welcome to the admin page')
else:
	print('stay at login page')
# welcome to the admin page


a = [1, 2, 3]
b = [1, 2, 3]
print('a==b: ',a == b)
print('a is b: ',a is b)
print(id(a))
print(id(b))
# a==b:    True
# a is b:  False
# 4418846152
# 4416294664

c = a
print(id(a) == id(c))
# True
```

## 2. Loops and Iterations - For/While Loops

```
//for ... in list:  
//    if:
//		continue		
for ls in list:
	if ls == 'Value':
		print('Found This Value')
		continue
	print(ls)
```
```
for ac in AC_list:
	if ac == 'Revolution':
		print('Found, it is supposed to be Unity')
		continue
	print(ac)
```

```
//for ... in list:
//	for ... in list:

for ac in AC_list:
	for rank in ['good', 'ok', 'bad']:
		print(ac, rank)
```
```
for ac in AC_list:
	for rank in ['good', 'ok', 'bad']:
		print(ac, rank)
```		
```
//range(1, 11)
for i in range(1, 11):
	print(i)
# 0...10	
```

```
//do .. while
x = 0	
while x < 10:
	print(x)
	x += 1
# 0...9

//while ... until ... break
x = 0
while True:
	if x == 5:
		break
	print(x)
	x += 1	
# 0...4
```

## 3. Functions

```
def func():
	return ""
print(func().upper())	

def func(x):
	return '{}'.format(x)

def func(x, y='a')
	return '{}{}'.format(x, y)
```

```
def hello_func():
	return "Assassin's Creed"
print(hello_func().upper())	
#Bonsoir Mademoiselle


def bonjour_func(greeting):
	return '{} Mademoiselle'.format(greeting)
print(bonjour_func('Bonsoir'))
# Bonsoir, Mademoiselle Louise


def bonjour_lady(greeting, name='Louise'):
	return '{}, Mademoiselle {}'.format(greeting, name)
	
print(bonjour_lady('Bonsoir'))
print(bonjour_lady('Bonsoir','Chloe'))

# Bonsoir, Mademoiselle Louise
# Bonsoir, Mademoiselle Chloe
```


```
# * and ** for unpack list or dict
def func(*list, **dict):
	print(list)
	print(dict)

func(list, dict)
func(*list, dict)
func(*list, *dict)
func(*list, **dict)
```

```
def student_info(*args, **kwargs):
	print(args)
	print(kwargs)

courses = ['Math', 'Art']
info = {'name':'John', 'age':'22'}

student_info(courses, info)
# (['Math', 'Art'], {'name': 'John', 'age': '22'})
# {}

student_info(*courses, info)
#('Math', 'Art', {'name': 'John', 'age': '22'})
#{}

student_info(courses, *info)
#(['Math', 'Art'], 'name', 'age')
#{}

student_info(courses, **info)
#(['Math', 'Art'],)
#{'name': 'John', 'age': '22'}

student_info(*courses, **info)
#('Math', 'Art')
#{'name': 'John', 'age': '22'}

```