# Python data Science tutorial 1 (module collections)

## module collections

This module implements specialized **container datatypes** providing alternatives to Python's general purpose **built-in containers, dict, list, set, and tuple**


### The Counter

**Counter** is a `subclass` of dictionary object. The `Counter()` function in collections module takes an iterable or a mapping as the argument and returns a Dictionary. 


In this dictionary, 

* **key is an element in the iterable or the mapping**
* **value is the number of times that element exists** in the iterable or the mapping.

#### Create Counter Objects

```
cnt = Counter()
```

You can pass an iterable (list) to `Counter()` function to create a counter object.

```
list = [1,2,3,4,1,2,6,7,3,8,1]
Counter(list)
```

Finally, the `Counter()` function can take a dictionary as an argument. In this dictionary, the value of a key should be the 'count' of that key.

```
Counter({1:3,2:4})
```

```
list = [1,2,3,4,1,2,6,7,3,8,1]
cnt = Counter(list)
print(cnt[1])

# 3
```


### The `most_common()` Function

The `Counter()` function returns a dictionary which is unordered. You can sort it according to the number of counts in each element using `most_common()` function of the Counter object.

```
list = [1,2,3,4,1,2,6,7,3,8,1]
cnt = Counter(list)
print(cnt.most_common())


# [(1, 3), (2, 2), (3, 2), (4, 1), (6, 1), (7, 1), (8, 1)]
```

You can see that `most_common` function returns a list, which is sorted based on the count of the elements. 1 has a count of three, therefore it is the first element of the list.


## The defaultdict


The `defaultdict` works exactly like a python dictionary, except for it does not throw KeyError when you try to access a non-existent key.

Instead, it initializes the key with the element of the data type that you pass as an argument at the creation of `defaultdict`. The data type is called `default_factory`.

### Create a defaultdict

You can create a `defaultdict` with the `defaultdict()` constructor. You have to specify a data type as an argument. Check the following code:

```
nums = defaultdict(int)
nums['one'] = 1
nums['two'] = 2
print(nums['three'])

# 0
```

### Data Ressouce 

[http://bit.ly/SO-Survey-2019](http://bit.ly/SO-Survey-2019)

## Data Suvery one 

```
import csv
from collections import defaultdict, Counter

with open('data/survey_results_public.csv') as f:
    csv_reader = csv.DictReader(f)

    language_counter = Counter()
    total = 0

    for line in csv_reader:
        lanaguages = line['LanguageWorkedWith'].split(';')
        language_counter.update(lanaguages)
        
        # for langauge in lanaguages:
        #     language_counter[langauge] += 1
        
        language_counter.update(lanaguages)
			# Update the dictionary with the key/value pairs from other, overwriting existing keys
			total += 1


for language, value in language_counter.most_common(5):
    language_pct = (value / total ) * 100
    language_pct = round(language_pct, 2)

    print(f'{language}: {language_pct}')
```

```
JavaScript: 66.63
HTML/CSS: 62.4
SQL: 53.49
Python: 41.0
Java: 40.41
```

## Data Suvery two

```
import csv
from collections import defaultdict, Counter

with open('data/survey_results_public.csv') as f:
    csv_reader = csv.DictReader(f)

    dev_type_info = {}

    for line in csv_reader:
        dev_types = line['DevType'].split(';')

        for dev_type in dev_types:
            dev_type_info.setdefault(dev_type, {
            # Set default for dev_type key, if it dees not exist, put default value  'total': 0 and   'language_counter': Counter()
            # setdefault check we already have a value for the key of the dev_type
            # If exist, return those value and leave modified
            # If not , create new dict {'total': 0, 'language_counter': Counter()}
                'total': 0,
                'language_counter': Counter()
            })
          
            languages = line['LanguageWorkedWith'].split(';')
            dev_type_info[dev_type]['language_counter'].update(languages)
            dev_type_info[dev_type]['total'] += 1


for dev_type, info in dev_type_info.items():
    print(dev_type)

    for language, value in info['language_counter'].most_common(5):
        language_pct = (value / info['total']) * 100
        language_pct = round(language_pct, 2)

        print(f'\t{language}: {language_pct}%')
```


```
$ python3 32suvery2.py 
NA
        HTML/CSS: 54.9%
        Python: 51.09%
        JavaScript: 50.58%
        Java: 42.71%
        C++: 35.02%
Developer, desktop or enterprise applications
        JavaScript: 67.84%
        HTML/CSS: 64.55%
        SQL: 63.56%
        C#: 53.69%
        Java: 44.69%
Developer, front-end
        JavaScript: 87.72%
        HTML/CSS: 83.62%
        SQL: 58.65%
        Java: 37.6%
        PHP: 35.94%
Designer
        HTML/CSS: 78.88%
        JavaScript: 78.33%
        SQL: 60.18%
        PHP: 40.23%
        Java: 39.44%
Developer, back-end
        JavaScript: 72.23%
        HTML/CSS: 65.42%
        SQL: 64.01%
        Java: 44.03%
        Python: 40.67%
Developer, full-stack
        JavaScript: 86.15%
        HTML/CSS: 78.94%
        SQL: 65.54%
        Java: 40.74%
        Bash/Shell/PowerShell: 37.91%
Academic researcher
        Python: 61.06%
        HTML/CSS: 55.87%
        JavaScript: 54.25%
        SQL: 47.55%
        Java: 42.26%
Developer, mobile
        JavaScript: 67.72%
        HTML/CSS: 62.46%
        Java: 57.21%
        SQL: 51.27%
        C#: 34.34%
Data or business analyst
        SQL: 73.88%
        HTML/CSS: 62.11%
        JavaScript: 61.33%
        Python: 51.86%
        Bash/Shell/PowerShell: 38.43%
Data scientist or machine learning specialist
        Python: 79.33%
        SQL: 58.44%
        JavaScript: 51.38%
        HTML/CSS: 50.43%
        Bash/Shell/PowerShell: 44.49%
Database administrator
        SQL: 81.7%
        JavaScript: 78.11%
        HTML/CSS: 76.19%
        Bash/Shell/PowerShell: 45.2%
        PHP: 44.16%
Engineer, data
        SQL: 66.75%
        Python: 64.31%
        JavaScript: 60.13%
        HTML/CSS: 56.47%
        Bash/Shell/PowerShell: 48.55%
Engineer, site reliability
        JavaScript: 69.43%
        Bash/Shell/PowerShell: 64.05%
        HTML/CSS: 62.79%
        SQL: 61.37%
        Python: 59.23%
Developer, QA or test
        JavaScript: 73.38%
        HTML/CSS: 70.31%
        SQL: 64.81%
        Bash/Shell/PowerShell: 45.73%
        Java: 45.23%
DevOps specialist
        JavaScript: 73.67%
        HTML/CSS: 66.66%
        SQL: 64.56%
        Bash/Shell/PowerShell: 63.98%
        Python: 52.44%
Developer, game or graphics
        JavaScript: 69.02%
        HTML/CSS: 66.37%
        C#: 54.31%
        SQL: 48.91%
        C++: 47.85%
Educator
        JavaScript: 70.15%
        HTML/CSS: 70.15%
        SQL: 56.92%
        Python: 47.02%
        Java: 44.26%
Student
        HTML/CSS: 68.13%
        JavaScript: 63.53%
        Java: 54.37%
        Python: 54.37%
        SQL: 51.83%
Engineering manager
        JavaScript: 72.35%
        HTML/CSS: 65.02%
        SQL: 60.4%
        Bash/Shell/PowerShell: 49.1%
        Python: 46.86%
Senior executive/VP
        JavaScript: 75.94%
        HTML/CSS: 71.81%
        SQL: 64.12%
        Bash/Shell/PowerShell: 46.8%
        Python: 46.37%
System administrator
        JavaScript: 73.45%
        HTML/CSS: 72.57%
        SQL: 67.94%
        Bash/Shell/PowerShell: 58.44%
        Python: 51.36%
Developer, embedded applications or devices
        JavaScript: 60.89%
        HTML/CSS: 57.75%
        C++: 51.08%
        SQL: 50.97%
        Python: 50.95%
Product manager
        JavaScript: 75.0%
        HTML/CSS: 71.92%
        SQL: 63.42%
        Python: 39.63%
        Bash/Shell/PowerShell: 38.96%
Scientist
        Python: 69.48%
        HTML/CSS: 51.04%
        JavaScript: 48.77%
        Bash/Shell/PowerShell: 47.83%
        SQL: 44.21%
Marketing or sales professional
        HTML/CSS: 76.82%
        JavaScript: 71.79%
        SQL: 58.97%
        PHP: 44.21%
        Python: 38.26%
```

    
    
    

	
