# Functions

* Functions start with def, function name, parameters if any
* They can return, or not a value

```
def add_nums(num_1, num_2)
	return num_1.to_i + num_2.to_i
end

> 7
```

### Variables are passed by value so the'r value can't be changed in a function


```
x = 1

def change_x(x)
	x = 4
end 

change_x(x)

puts "x = #{x}"

> x = 1
```



