# STRINGS

* Strings are a series of characters between " or '
* String interpolation doesn't work with '' and neither do backslash
* characters like newline

```
puts "Add Them #{4+5} \n\n"
puts 'Add Them #{4+5} \n\n'

Add Them 9 

Add Them #{4+5} \n\n
```

### A here-doc is normally used when you want a multiline string

```
multiline_string = <<EOM
This is a very long string
that contains interpolation
like #{600 + 66} \n\n
EOM

puts multiline_string

> This is a very long string
  that contains interpolation
  like 666 
 
```


### Find all string methods by typing irb in terminal and "string".methods

```
first_name = 'Jacob'
last_name = 'Stevens'
```

### You can combine or concatenate strings with `+`

```
full_name1 = first_name + " "+ last_name
```

### Combining strings with interpolation

```
middle_name = "Justin"
full_name = "#{first_name} #{middle_name} #{last_name}"
```

### You can check if a string contains a string with `include`

```
puts full_name2.include?("Justin")
puts full_name1.include?("Justin")

> true
> false
```

### Get the `length` of a string

```
puts full_name1.size

>>> 13
```

### `Count` the number of vowels and Count the consonants

```
puts "Vowels : " + full_name.count("aeiou").to_s
puts "Consonants : " + full_name.count("^aeiou").to_s
 
> Vowels : 6
> Consonants : 14
```

### You can check if a string starts with another string

```
puts full_name2.start_with?("Stevens")

> false
```
 
### Return the index for the match

```
puts "Index : " + full_name2.index("Stevens").to_s

> 13
```

### Check equality of strings

```
puts "a == a : " + ("a" == "a").to_s

> a == a : true
```

### Check if they are the same object

```
puts "\"a\".equal?(\"a\") : " + ("a".equal?"a").to_s
puts first_name.equal?first_name

> "a".equal?("a") : false
> true
```

### Changing Case

```
puts full_name1.upcase
puts full_name1.downcase
puts full_name1.swapcase

> JACOB STEVENS
> jacob stevens
> jACOB sTEVENS
```

### Stripping white space

```
full_name = "       " + full_name
 
full_name = full_name.lstrip
full_name = full_name.rstrip
full_name = full_name.strip
 
puts full_name
```

### Formatting Strings

```
puts full_name.rjust(20, '.')
puts full_name.ljust(20, '.')
puts full_name.center(20, '.')

> .......Jacob Stevens
> Jacob Stevens.......
> ...Jacob Stevens....
```

### Chop eliminates the last character

```
puts full_name2.chop

> Jacob Justin Steven
```

### Chomp eliminates `\n` or a specific string

```
puts full_name2.chomp
puts full_name2.chomp("ns")

> Jacob Justin Stevens
> Jacob Justin Stev
```

### Delete deletes provided characters

```
puts full_name.delete("a")

> Jcob Stevens
```

### Split a string into an array

```
name_array = full_name.split(//)
puts name_array

J
a
c
o
b
 
S
t
e
v
e
n
s
```

```
name_array = full_name2.split(/ /)
puts name_array

Jacob
Justin
Stevens
```

### String Conversions

```
puts "a".to_i
puts "2".to_f
puts "2".to_sym

> 0
> 2.0
> 2
```

```
# Escape sequences
# \\  Backslash
# \'  Single-quote
# \"  Double-quote
# \a  Bell
# \b  Backspace
# \f  Formfeed
# \n  Newline
# \r  Carriage
# \t  Tab
# \v  Vertical tab
```















