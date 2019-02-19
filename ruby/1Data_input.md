# Version, Comment, Input and output

* Ruby is a dynamic, interpreted, object oriented language
* Everything is an object and all of those objects can be overwritten
* Ruby is one of the easiest languages to read and with Rails it may be the best web development option period
 
 
## Check ruby version

```
$ ruby -v
ruby 2.3.7p456 (2018-03-28 revision 63024) [universal.x86_64-darwin18]
```

## Ruby Comment

### single comment

```
# This is ruby comment
```

### multiple lines comment

```
=begin
Multiline Comment
=end
```


## Print without newline

```
# print prints the string to screen without a newline
print "Enter a Value: "

>>> Enter a Value:
```

## Terminal Input and output

* Variables start with a lowercase letter or _ and may contain numbers
* gets stores input from the user and `to_i` turns it into an integer

### `to_i` and `gets`

```
print "Enter a Value: "

first_num = gets.to_i

print "Enter another Value: "

second_num = gets.to_i
```

### `to_s`, `puts` and `+`

* **`puts` prints output plus a newline**, 
* `to_s` converts the variable into a
* string, you can combine values using `+`

```
puts first_num.to_s + " + " + second_num.to_s + " = " +
(first_num + second_num).to_s

>>> Enter a Value: 2
>>> Enter another Value: 1
>>> 2 + 1 = 3
```

