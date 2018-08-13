# Python Tutorial Advance 6

## Using Try/Except Blocks for Error Handling

```
try:
	f= open('exception_test.txt')
	f2= open('copy_rename.txt')
	
	if f2.name == 'copy_rename.txt':
		raise Exception
		
except FileNotFoundError as fnfe:
	print(fnfe)
	
# [Errno 2] No such file or directory: 'exception_test1.txt'

except Exception as e:
	print('Should not read this file')
# name 'bad_var' is not defined	

else:
	print(f.read())
	f.close()
	
finally:
	print("Executing Finally")
```

```
Should not read this file
Executing Finally
```

## Unit Testing your code with the unittest Module

### calc.py

 ```
 def add(x, y):
	"Add Function"
	return x+y

def substract(x, y):
	"substract Function"
	return x-y


def multiply(x, y):
	"multiply Function"
	return x*y

def divide(x, y):
	"divide Function"
	if y == 0:
		raise ValueError('Cannot divided by zero! ')  
# raise valueError('Cannot divided by zero! ')
	return x/y
 ```

**unittest assert function**

**https://docs.python.org/3/library/unittest.html#unittest.TestCase.debug**


### testcalc.py

```
class TestCalc(unittest.TestCase):
	def test_add(self):
#This function must start with "test"		
		self.assertEqual(calc.add(10, 5), 15)
		self.assertEqual(calc.add(1, -1), 0)
		self.assertEqual(calc.add(-1, -1), -2)
		
	def test_substract(self):
#This function must start with "test"		
		self.assertEqual(calc.substract(10, 5), 5)
		self.assertEqual(calc.substract(1, -1), 2)
		self.assertEqual(calc.substract(-1, -1), 0)	

	def test_multiply(self):
#This function must start with "test"		
		self.assertEqual(calc.multiply(10, 5), 50)
		self.assertEqual(calc.multiply(1, -1), -1)
		self.assertEqual(calc.multiply(-1, -1), 1)	

	def test_divide(self):
#This function must start with "test"		
		self.assertEqual(calc.divide(10, 5), 2)
		self.assertEqual(calc.divide(1, -1), -1)
		self.assertEqual(calc.divide(-1, -1), 1)

		# self.assertEqual(ValueError, calc.divide(10,0))	
		self.assertRaises(ValueError, calc.divide, 10, 0)	
		with self.assertRaises(ValueError):
			calc.divide(10, 0)	
			
# run the command on terminal
# python3 -m unittest test1.py

if __name__ == '__main__':
	unittest.main()
#run the module directly
#run the code dependently

# run on terminal
#python3  test1.py				
```

***run in sublime***

```
Ran 4 tests in 0.000s

OK
Traceback (most recent call last):
  File "/Users/jxi/python/uni_ttest/test1.py", line 43, in <module>
    unittest.main()
  File "/usr/local/Cellar/python3/3.6.4_2/Frameworks/Python.framework/Versions/3.6/lib/python3.6/unittest/main.py", line 95, in __init__
    self.runTests()
  File "/usr/local/Cellar/python3/3.6.4_2/Frameworks/Python.framework/Versions/3.6/lib/python3.6/unittest/main.py", line 258, in runTests
    sys.exit(not self.result.wasSuccessful())
SystemExit: False
```
***run in terminal***

```
....
----------------------------------------------------------------------
Ran 4 tests in 0.000s

OK
```

## Unit Testing with requests module and unittest.mock module

```
sudo pip install requests
```

**`employee.py`**

```
import requests

class Employee:
	"""A sample Employee Class"""
	raise_amt = 1.05
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

	def apply_raise(self):
		self.pay = int(self.pay * self.raise_amt)

	def monthly_schedule(self, month):
		response = requests.get(f'http://company.com/{self.last}/{month}')
		if response.ok:
			return response.text
		else:
			return 'Bad Response!'
```

**`test_employee.py`**

```
import unittest
from unittest.mock import patch
from employee import Employee

class TestEmployee(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        print('setupClass')

    @classmethod
    def tearDownClass(cls):
        print('teardownClass')

    def setUp(self):
        print('setUp')
        self.emp_1 = Employee('Corey', 'Schafer', 50000)
        self.emp_2 = Employee('Sue', 'Smith', 60000)

    def tearDown(self):
        print('tearDown\n')

    def test_email(self):
        print('test_email')
        self.assertEqual(self.emp_1.email, 'Corey.Schafer@email.com')
        self.assertEqual(self.emp_2.email, 'Sue.Smith@email.com')

        self.emp_1.first = 'John'
        self.emp_2.first = 'Jane'

        self.assertEqual(self.emp_1.email, 'John.Schafer@email.com')
        self.assertEqual(self.emp_2.email, 'Jane.Smith@email.com')

    def test_fullname(self):
        print('test_fullname')
        self.assertEqual(self.emp_1.fullname, 'Corey Schafer')
        self.assertEqual(self.emp_2.fullname, 'Sue Smith')

        self.emp_1.first = 'John'
        self.emp_2.first = 'Jane'

        self.assertEqual(self.emp_1.fullname, 'John Schafer')
        self.assertEqual(self.emp_2.fullname, 'Jane Smith')

    def test_apply_raise(self):
        print('test_apply_raise')
        self.emp_1.apply_raise()
        self.emp_2.apply_raise()

        self.assertEqual(self.emp_1.pay, 52500)
        self.assertEqual(self.emp_2.pay, 63000)

    def test_monthly_schedule(self):
        with patch('employee.requests.get') as mocked_get:
            mocked_get.return_value.ok = True
            mocked_get.return_value.text = 'Success'

            schedule = self.emp_1.monthly_schedule('May')
            mocked_get.assert_called_with('http://company.com/Schafer/May')
            self.assertEqual(schedule, 'Success')

            mocked_get.return_value.ok = False

            schedule = self.emp_2.monthly_schedule('June')
            mocked_get.assert_called_with('http://company.com/Smith/June')
            self.assertEqual(schedule, 'Bad Response!')


if __name__ == '__main__':
    unittest.main()
```

```
setupClass
setUp
test_apply_raise
tearDown

.setUp
test_email
tearDown

setUp
test_fullname
tearDown

setUp
```