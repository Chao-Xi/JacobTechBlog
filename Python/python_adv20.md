# SQLite Tutorial: Creating a Database, Table, and Running Queries

SQLite allows us to quickly get up and running with databases, without spinning up larger databases like MySQL or Postgres. We will be creating a database, creating a table, insert, select, update, and delete data. 


## Sample

### Create table with sqlite

```
import sqlite3
conn = sqlite3.connect('22employee.db')

c = conn.cursor()

c.execute("""CREATE TABLE employees (
	  first text,
	  last text,
	  pay integer)""")

```

### Insert data into table

```
c.execute("INSERT INTO employees VALUES ('Jacky', 'Austin', 50000)")
c.execute("INSERT INTO employees VALUES ('Mary', 'Austin', 60000)")

conn.commit() 
```

### Fetch data from table

```
c.execute("SELECT * FROM employees where last= 'Austin' ")

print(c.fetchone())   #fetchone() and output a tuple
>>> ('Jacky', 'Austin', 50000)


print(c.fetchall())  #fetchall() and output a dictionary
>>> [('John', 'Doe', 80000), ('Jane', 'Doe', 70000)]

# c.fetchmany(5)

conn.commit() 

conn.close()
```

## How to avoid SQL injection with placeholder

#### Employee.py

```
class Employee:
    """A sample Employee class"""

    def __init__(self, first, last, pay):
        self.first = first
        self.last = last
        self.pay = pay

    @property
    def email(self):
        return '{}.{}@email.com'.format(self.first, self.last)

    @property
    def fullname(self):
        return '{} {}'.format(self.first, self.last)

    def __repr__(self):
        return "Employee('{}', '{}', {})".format(self.first, self.last, self.pay)
```

#### `conn = sqlite3.connect(':memory:')` can be refresh the database

```
import sqlite3
from Employee import Employee   #import is class name

conn = sqlite3.connect('22employee.db')

c = conn.cursor()

c.execute("""CREATE TABLE employees (
	  first text,
	  last text,
	  pay integer)""")

emp_1 = Employee('John','Doe', 80000)
emp_2 = Employee('Jane', 'Doe', 70000)

print(emp_1.first)
print(emp_1.last)
print(emp_1.pay)
>>> John
>>> Doe
>>> 80000
```

#### `Inject tuple`

```
# ? => Insert tuple into db
c.execute("INSERT INTO employees VALUES (?, ?, ?)", (emp_1.first, emp_1.last, emp_1.pay))
conn.commit() 
```
#### `Inject dictionary`

```
# :key => Insert dictionary into the db, while :key is the key of dict
c.execute("INSERT INTO employees VALUES (:first,:last,:pay)", {'first':emp_2.first, 'last':emp_2.last, 'pay':emp_2.pay})
conn.commit() 
```

#### Select from from db 

```
c.execute("SELECT * FROM employees WHERE last=?", ('Austin',))
print(c.fetchall())
>>> [('Jacky', 'Austin', 50000), ('Mary', 'Austin', 60000)]



c.execute("SELECT * FROM employees WHERE last=:last", {'last': 'Doe'})
print(c.fetchall())
>>>  [('John', 'Doe', 80000), ('Jane', 'Doe', 70000)]

conn.commit() 
conn.close()
```


## DML in Functions (Insert, Select, Update, Delete)

**insert, update and delete work with content manager**

```
with conn:
	c.execute()
```

```
from Employee import Employee   #import is class name

conn = sqlite3.connect('22employee.db')

conn = sqlite3.connect(':memory:')

c = conn.cursor()

c.execute("""CREATE TABLE employees (
	  first text,
	  last text,
	  pay integer)""")

# with is content manager
def insert_emp(emp):
	with conn:
		c.execute("INSERT INTO employees VALUES (:first,:last,:pay)", {'first':emp.first, 'last':emp.last, 'pay':emp.pay})


def get_emps_by_name(lastname):
	c.execute("SELECT * FROM employees WHERE last=:last", {'last': lastname})
	return c.fetchall()


def update_pay(emp, pay):
	with conn:
		c.execute("UPDATE employees SET pay = :pay WHERE first = :first AND last = :last", {'first': emp.first, 'last': emp.last, 'pay': pay})


def remove_emp(emp):
	 with conn:
	 	c.execute("DELETE from employees WHERE first = :first AND last = :last", {'first': emp.first, 'last': emp.last})

emp_1 = Employee('John','Doe', 80000)
emp_2 = Employee('Jane', 'Doe', 70000)

insert_emp(emp_1)
insert_emp(emp_2)

emps = get_emps_by_name('Doe')
print(emps)

update_pay(emp_2, 95000)
remove_emp(emp_1)

emps = get_emps_by_name('Doe')
print(emps)

conn.close()
```