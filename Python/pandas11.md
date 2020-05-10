# Reading/Writing Data to Different Sources - Excel, JSON, SQL, Etc

```
import pandas as pd

df = pd.read_csv('data/survey_results_public.csv', index_col='Respondent')
schema_df = pd.read_csv('data/survey_results_schema.csv', index_col='Column')

pd.set_option('display.max_columns',85)
pd.set_option('display.max_rows',85)


filt = (df['Country'] == 'India')
india_df = df.loc[filt]
india_df.head()
```


### write CSV

```
# export to csv
india_df.to_csv('data/modified.csv')
```

### export to tsv

```
india_df.to_csv('data/modified.tsv', sep='\t')
```


### export to xlsx

**`pip3 install xlwt openpyxl xlrd`**

```
india_df.to_excel('data/modified.xlsx')
```

![Alt Image Text](images/pd11_1.png "Body image")

### read to xlsx

```
excel_test = pd.read_excel('data/modified.xlsx', index_col='Respondent')
excel_test.head()
```

![Alt Image Text](images/pd11_1.png "Body image")

### export to json

```
india_df.to_json('data/modified.json', lines= True, orient='records')
```

### read to json

```
json_test = pd.read_json('data/modified.json', lines= True, orient='records')
json_test.head()
```

![Alt Image Text](images/pd11_1.png "Body image")


## Export and read from postgre sql

### Object relational mapper （ORM)

```
pip3 install SQLAlchemy

pip3 install psycopg2-binary
```

`kubectl port-forward -n postgres svc/my-pgadmin 8080:80`

* `chart@example.local`
* SuperSecret

![Alt Image Text](images/pd11_3.png "Body image")


**`kubectl port-forward --namespace postgres svc/my-postgresql 5432:5432`**

```
from sqlalchemy import create_engine
import psycopg2

engine = create_engine('postgresql://admin:admin@localhost:5432/sample_db')

india_df.to_sql('sample_db', engine, if_exists='replace')

sql_df = pd.read_sql('sample_db', engine, index_col='Respondent')

sql_df.head()
```

![Alt Image Text](images/pd11_2.png "Body image")

![Alt Image Text](images/pd11_1.png "Body image")


```
sql_query = pd.read_sql_query('select * from sample_db', engine, index_col='Respondent')

sql_query.head()
```

### Read from online json

```
posts_df = pd.read_json('https://raw.githubusercontent.com/CoreyMSchafer/code_snippets/master/Python/Flask_Blog/snippets/posts.json')

posts_df.head()
```

![Alt Image Text](images/pd11_4.png "Body image")
