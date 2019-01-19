# `if __name__ == '__main__'`

`if __name__ == '__main__':` This conditional is used to check whether a python module is being run directly or being imported.

## `26name_main.py`

```
print(__name__)

>>> __main__

print(f"First Module's Name: {format(__name__)}")
>>> First Module's Name: __main__
```


## `namemain26.py`

```
print(f"Second Imported Module's Name: {format(__name__)}")


def main():
	print('Run Directly')

# This is a check for runner is main or not
if __name__ == '__main__':
	main()
else:
	print('Run from import')

>>> Second Imported Module's Name: __main__
>>> Run Directly
```


## import `namemain26.py` to the `26name_main.py`

### Inside `26name_main.py`

```
import namemain26 

>>> Second Imported Module's Name: namemain26
>>> Run from import
```

### But we can run main function directly

```
namemain26.main()
>>> Run Directly
```





