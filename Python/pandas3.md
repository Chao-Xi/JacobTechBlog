# Pandas Indexes - How to Set, Reset, and Use Indexes

## `set_index`

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
df.set_index('email')
```

![Alt Image Text](images/pd3_1.png "body image") 

### set_index(inplace=True)

```
df.set_index('email', inplace=True)
```

![Alt Image Text](images/pd3_2.png "body image") 

### df.index

```
df.index
```

```
Index(['jacobxi@outlook.com', 'JaneDone@outlook.com', 'JohnWick@outlook.com'], dtype='object', name='email')
```

```
df.loc['jacobxi@outlook.com']

df.loc['jacobxi@outlook.com','first']
```

![Alt Image Text](images/pd3_3.png "body image") 


### Currently default integer is no longer the index

```
df.loc[0]
```

## `set_index` in real world example

![Alt Image Text](images/pd3_4.png "body image") 

### Set `index_col`

```
import pandas as pd

df = pd.read_csv('data/survey_results_public.csv', index_col='Respondent')
schema_df = pd.read_csv('data/survey_results_schema.csv', index_col='Column')

pd.set_option('display.max_columns',85)
pd.set_option('display.max_rows',85)
```

![Alt Image Text](images/pd3_5.png "body image") 

```
df.loc[1]  # 1 is Respondent number
```

```
MainBranch                           I am a student who is learning to code
Hobbyist                                                                Yes
OpenSourcer                                                           Never
OpenSource                The quality of OSS and closed source software ...
Employment                           Not employed, and not looking for work
Country                                                      United Kingdom
Student                                                                  No
EdLevel                                           Primary/elementary school
UndergradMajor                                                          NaN
EduOther                  Taught yourself a new language, framework, or ...
OrgSize                                                                 NaN
DevType                                                                 NaN
YearsCode                                                                 4
Age1stCode                                                               10
YearsCodePro                                                            NaN
CareerSat                                                               NaN
JobSat                                                                  NaN
...
```

```
schema_df
```

![Alt Image Text](images/pd3_6.png "body image") 

```
schema_df.loc['Hobbyist']

schema_df.loc['MgrIdiot']

schema_df.loc['MgrIdiot','QuestionText']
```

![Alt Image Text](images/pd3_7.png "body image") 

### Sort_index

```
schema_df.sort_index(ascending=False)
```

![Alt Image Text](images/pd3_8.png "body image") 

### `schema_df.sort_index(inplace=True)`

```
schema_df.sort_index(inplace=True)
schema_df
```
![Alt Image Text](images/pd3_9.png "body image") 
