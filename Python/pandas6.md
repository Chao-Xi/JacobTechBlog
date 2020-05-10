# Add/Remove Rows and Columns From DataFrames

## Add Columns

```
people = {
    "first" : ["Jacob","Jane","John"],
    "last" : ["Xi","Doe","Wick"],
    "email" : ["jacobxi@outlook.com","JaneDone@outlook.com", "JohnWick@outlook.com"]
}

import pandas as pd

df = pd.DataFrame(people)
```

```
df['first']+ ' '+ df['last']

0     Jacob Xi
1     Jane Doe
2    John Wick
dtype: object
```

### Add one column

```
df['fullname']=df['first']+ ' '+ df['last']
df
```

![Alt Image Text](images/pd6_1.png "Body image")

### Drop columns

```
df.drop(columns=['first','last'],inplace=True)
df
```

![Alt Image Text](images/pd6_2.png "Body image")

### Add dopped columns back

```
df['fullname'].str.split(' ', expand=True)
```

![Alt Image Text](images/pd6_3.png "Body image")

```
df[['first','last']] = df['fullname'].str.split(' ', expand=True)
df
```

![Alt Image Text](images/pd6_4.png "Body image")


## Add row values

### Add one row value

```
df.append({'first':'tony'}, ignore_index=True)
```

![Alt Image Text](images/pd6_5.png "Body image")


### Add multiple row value

```
avengers = {
    "first" : ["Tony","Steve"],
    "last" : ["Stark","Rogers"],
    "email" : ["IronMan@avenge.com","Cap@avenge.com"]
}

df2 = pd.DataFrame(avengers)

df.append(df2)

/usr/local/lib/python3.7/site-packages/pandas/core/frame.py:7138: FutureWarning: Sorting because non-concatenation axis is not aligned. A future version
of pandas will change to not sort by default.

To accept the future behavior, pass 'sort=False'.

To retain the current behavior and silence the warning, pass 'sort=True'.

  sort=sort,
```

![Alt Image Text](images/pd6_6.png "Body image")

* **`sort=False`**

```
df=df.append(df2, ignore_index=True, sort=False)
df
```

![Alt Image Text](images/pd6_7.png "Body image")

### Drop special one row value

```
df.drop(index=4)
```

![Alt Image Text](images/pd6_8.png "Body image")

### Drop multiple rows value with `filter`

```
filt = df['last'] == 'Doe'
df.drop(index=df[filt].index)
```

![Alt Image Text](images/pd6_9.png "Body image")