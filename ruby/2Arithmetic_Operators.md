# Arithmetic Operators

```
puts "6 + 4 = " + (6+4).to_s
puts "6 - 4 = " + (6-4).to_s
puts "6 * 4 = " + (6*4).to_s
puts "6 / 4 = " + (6/4).to_s
puts "6 % 4 = " + (6%4).to_s
```

* Integers or Fixnums can store extremely large numbers
* They can go well beyond 4,611,686,018,427,387,903

```
numOne = 1.000
```

* You must put a 0 before your floats

```
num99 = 0.999
```

* Floating point calculations tend to be accurate

```
puts num_one.to_s + " - "+ num99.to_s + " = " + (num_one - num99).to_s
>>> 1.0 - 0.999 = 0.0010000000000000009
```

* 14 Digits of accuracy is the norm

```
big_float = 1.12345678901234
puts (big_float + 0.00000000000005).to_s
>>> 1.1234567890123899
```

### `.class`

```
puts 1.class
puts 1.234.class
puts "A string".class

>>> Fixnum
>>> Float
>>> String
```

### `CONSTANT`

```
CONSTANT = 31.22
CONSTANT = 3.4

puts CONSTANT

# warning: already initialized constant CONSTANT
# warning: previous definition of CONSTANT was here

>>> 3.4
# changed
```





