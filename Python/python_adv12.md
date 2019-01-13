# Working with JSON Data using the json Module

### `import json`

```
import json

people_string = '''
{
	"people" :[
        {
           "name":"John Smith",
           "phone":"615-555-7164",
           "Email": ["JohnSmith@gmail.com","JohnSmith@outlook.com"],
           "has_licence": false  
        },
        {
           "name": "Jane Doe",
           "phone": "560-555-5153",
           "Emails": null,
           "has_licence": true
        }
        ]
}
'''

```

### `json.loads`: convert json data to dictionary

```
data=json.loads(people_string)
print(type(data))
print(type(data['people']))

>>> <class 'dict'>
>>> <class 'list'>


for person in data['people']:
	print(person)
	
>>> {'name': 'John Smith', 'phone': '615-555-7164', 'Email': ['JohnSmith@gmail.com', 'JohnSmith@outlook.com'], 'has_licence': False}
>>> {'name': 'Jane Doe', 'phone': '560-555-5153', 'Emails': None, 'has_licence': True}


for person in data['people']:
	print(person['name'])

>>> John Smith
>>> Jane Doe
```


### `json.dumps`: convert dict data to string


#### `del` keyword can also be used to delete variables, lists, or parts of a list etc.


```
for person in data['people']:
	del person['phone']

new_string1 = json.dumps(data)

print(new_string1)

>>> {"people": [{"name": "John Smith", "Email": ["JohnSmith@gmail.com", "JohnSmith@outlook.com"], "has_licence": false}, {"name": "Jane Doe", "Emails": null, "has_licence": true}]}
```

#### `dumps` with `indent` to make string to more readable json data

```
new_string2 = json.dumps(data, indent=2)

print(new_string2)

>>> {
  "people": [
    {
      "name": "John Smith",
      "Email": [
        "JohnSmith@gmail.com",
        "JohnSmith@outlook.com"
      ],
      "has_licence": false
    },
    {
      "name": "Jane Doe",
      "Emails": null,
      "has_licence": true
    }
  ]
}
```
#### `dumps` with `sort_keys` to make sort with keys

```
new_string3 = json.dumps(data, indent=2, sort_keys=True)

print(new_string3)

>>> {
  "people": [
    {
      "Email": [
        "JohnSmith@gmail.com",
        "JohnSmith@outlook.com"
      ],
      "has_licence": false,
      "name": "John Smith"
    },
    {
      "Emails": null,
      "has_licence": true,
      "name": "Jane Doe"
    }
  ]
}
```

### `json.load`: load json file data(string) to dict

```
with open('15states.json') as f:
	data = json.load(f)

for state in data['states']:
	print(state['name'], state['abbreviation'])
	
>>> Alabama AL
Alaska AK
Arizona AZ
Arkansas AR
California CA
Colorado CO
Connecticut CT
Delaware DE
Florida FL
...
```

### `json.dump`: convert json dict data to string and dump into json file

```
for state in data['states']:
  del state['area_codes']


# dump dcit => string => json file
with open('15new_states.json', 'w') as f1:
	json.dump(data, f1, indent=2)
```

#### it create a new json file `15new_states.json`

```
$ less 15new_states.json

{
  "states": [
    {
      "name": "Alabama",
      "abbreviation": "AL"
    },
    {
      "name": "Alaska",
      "abbreviation": "AK"
    },
    {
      "name": "Arizona",
      "abbreviation": "AZ"
    },
 ...

```

## Practical Example

#### `urllib.request` module and `urlopen` function can open url and fetch the data

```
with urlopen('url') as fetched_data:
	data = fetched_data.read()
```

```
import json
from urllib.request import urlopen

with urlopen("https://finance.yahoo.com/webservice/v1/symbols/allcurrencies/quote?format=json") as response:
    source = response.read()

data = json.loads(source)

# print(json.dumps(data, indent=2))

usd_rates = dict()

for item in data['list']['resources']:
    name = item['resource']['fields']['name']
    price = item['resource']['fields']['price']
    usd_rates[name] = price

print(50 * float(usd_rates['USD/INR']))
```




