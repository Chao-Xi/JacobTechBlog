# F-Strings - How to Use Them and Advanced String Formatting


### Python3.6+ and are extremely useful once you learn how to use them

```
first_name = 'Jacob'
last_name = 'GodSon'
```

### Format:   '{} {}'.format(x,y)

```
sentence = 'My name is  {} {}'.format(first_name, last_name)
print(sentence)
```

```
My name is  Jacob GodSon
```

### f:  f'{x} {y}'

```
sentence1 = f'My name is {first_name} {last_name}'
print(sentence1)
```

```
My name is  Jacob GodSon
```


### f:  f'{x} {y}' + functions()

```
sentence1 = f'My name is {first_name.upper()} {last_name.upper()}'
print(sentence1)
```

```
My name is JACOB GODSON
```

### f:  f'{x} {y}' + dictionary :  f'{D["x"] D["y"]}'

```
person = {'name':'Jelen', 'age':'23'}
sentence2=f'My name is {person["name"]} and I am {person["age"]} years old'
print(sentence2)
```

```
My name is Jelen and I am 23 years old
```

### f:  f'{x} {y}' + range

```
for n in range (1,11):
    sentence3 = f'The value is {n}, '
    print(sentence3, end='')
```

```
The value is 1, The value is 2, The value is 3, The value is 4, The value is 5, The value is 6, The value is 7, The value is 8, The value is 9, The value is 10, 
```

### f:  f'{x} {y}' + digits

```
for n in range (1,11):
    sentence3 = f'The value is {n:04}, '   # start with 0, and contains 4 digits
    print(sentence3, end='')
```

```
The value is 0001, The value is 0002, The value is 0003, The value is 0004, The value is 0005, The value is 0006, The value is 0007, The value is 0008, The value is 0009, The value is 0010, 
```

### f:  f'{x} {y}' + float

```
pi = 3.14159265

sentence = f'Pi is equal to {pi:.4f}'    # 4 digits, and float
print(sentence)
```

```
Pi is equal to 3.1416
```


### f:  f'{x} {y}' + module

```
from datetime import datetime

birthday = datetime(1990, 1, 1)

sentence = f'Jenn has a birthday on {birthday: %B %d, %Y}'
print(sentence)
```

```
Jenn has a birthday on  January 01, 1990
```




















