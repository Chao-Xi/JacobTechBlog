# Generate Random Numbers and Data Using the random Module

In this Python Programming Tutorial, we will be learning how to generate random numbers and choose random data from lists using the random module. I personally use the random module pretty often in my tutorials to generate random data. This can also be used be games, simulations, and plenty of other useful tasks.


## Random number


### 1.random number (0...1)

```
import random

value = random.random()
print(value)     # random value between 0 ... 1

>>> 0.6941455054115302

print(round(value, 2))
>>> 0.69
```

### 2.Random value in specific range

```
t_value = random.uniform(1,10)
print(t_value) 

>>> 8.391530760306122
```

### 3.Random int value in specific range

```
t_int_value = random.randint(1,6)   # 1 and 6 are inclusive
print(t_int_value)

>>> 3
```

## random string 

### 1.random string

```
greetings = ['Hello', 'Hi', 'Hey', 'Salut', 'Hola', 'Howdy', 'Bonjour', 'Bonsoir']
ran_choice = random.choice(greetings)
print(ran_choice+', Jacob!')

>>> Bonjour, Jacob!
```

### 2.random string with `k times`

```
colors=['green', 'red', 'black']
ran_choices = random.choices(colors, k=10)  
print(ran_choices)

>>> ['red', 'green', 'green', 'black', 'black', 'black', 'black', 'red', 'red', 'black']
```

### 3.random string with `k times` and `different weight`

```
ran_weight_choices = random.choices(colors, weights=[18, 18, 2], k=10) 
print(ran_weight_choices)

# green: 18/38
# red: 18/38
# black: 2/38

>>> ['red', 'green', 'red', 'red', 'green', 'green', 'green', 'green', 'black', 'green']
```

### 4. shuffle and sample

```
deck = list(range(1,53))   # 53 in exclusive
print(deck)

>>> [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52]
```


### shuffle deck

```
random.shuffle(deck)
print(deck)

>>> [36, 9, 43, 42, 16, 2, 27, 4, 35, 3, 11, 26, 33, 5, 40, 1, 31, 44, 6, 45, 28, 48, 39, 52, 13, 30, 19, 7, 50, 24, 51, 23, 41, 17, 22, 32, 20, 21, 46, 47, 37, 29, 25, 34, 38, 8, 10, 12, 18, 49, 14, 15]
```

### shuffle deck with 5 in hand

```
hand = random.sample(deck, k=5)
print(hand)

>>> [47, 34, 6, 19, 23]
```

## Random Example

```
''' Super simple module to create basic random data for tutorials'''
import random

first_names = ['John', 'Jane', 'Corey', 'Travis', 'Dave', 'Kurt', 'Neil', 'Sam', 'Steve', 'Tom', 'James', 'Robert', 'Michael', 'Charles', 'Joe', 'Mary', 'Maggie', 'Nicole', 'Patricia', 'Linda', 'Barbara', 'Elizabeth', 'Laura', 'Jennifer', 'Maria']

last_names = ['Smith', 'Doe', 'Jenkins', 'Robinson', 'Davis', 'Stuart', 'Jefferson', 'Jacobs', 'Wright', 'Patterson', 'Wilks', 'Arnold', 'Johnson', 'Williams', 'Jones', 'Brown', 'Davis', 'Miller', 'Wilson', 'Moore', 'Taylor', 'Anderson', 'Thomas', 'Jackson', 'White', 'Harris', 'Martin']

street_names = ['Main', 'High', 'Pearl', 'Maple', 'Park', 'Oak', 'Pine', 'Cedar', 'Elm', 'Washington', 'Lake', 'Hill']

fake_cities = ['Metropolis', 'Eerie', "King's Landing", 'Sunnydale', 'Bedrock', 'South Park', 'Atlantis', 'Mordor', 'Olympus', 'Dawnstar', 'Balmora', 'Gotham', 'Springfield', 'Quahog', 'Smalltown', 'Epicburg', 'Pythonville', 'Faketown', 'Westworld', 'Thundera', 'Vice City', 'Blackwater', 'Oldtown', 'Valyria', 'Winterfell', 'Braavos‎', 'Lakeview']

states = ['AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DC', 'DE', 'FL', 'GA', 'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD', 'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ', 'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC', 'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY']


for num in range(100):
    first = random.choice(first_names)
    last = random.choice(last_names)

    phone = f'{random.randint(100, 999)}-555-{random.randint(1000,9999)}'

    street_num = random.randint(100, 999)
    street = random.choice(street_names)
    city = random.choice(fake_cities)
    state = random.choice(states)
    zip_code = random.randint(10000, 99999)
    address = f'{street_num} {street} St., {city} {state} {zip_code}'

    email = first.lower() + last.lower() + '@bogusemail.com'

    print(f'{first} {last}\n{phone}\n{email}\n{address}\n')
```

```
Traceback (most recent call last):
  File "/Users/jxi/python/adv1/12_random_data.py", line 30, in <module>
    print(f'{first} {last}\n{phone}\n{email}\n{(address)}\n')
UnicodeEncodeError: 'ascii' codec can't encode character '\u200e' in position 72: ordinal not in range(128)
```

**fix problem:**

```
address = address.encode("utf-8")
```

```
Michael Taylor
659-555-2341
michaeltaylor@bogusemail.com
b'868 High St., Springfield CO 90082'

Kurt Doe
298-555-4327
kurtdoe@bogusemail.com
b'265 Lake St., Faketown GA 76196'

Michael Johnson
107-555-4531
michaeljohnson@bogusemail.com
b'440 Elm St., Balmora NM 42894'

Maria Miller
957-555-8567
mariamiller@bogusemail.com
b'990 Maple St., Bedrock NH 62079'
...
```






