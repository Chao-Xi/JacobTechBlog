# Python Tutorial for Beginners

## 1.Strings - Working with Textual Data

### Part 1

```
str= ''  ""  """ """
print(str)
print(len(str))
```

```
message = """Assassain Creed
Nothing is true, everthing is permitted"""
print(message)
print(len(message))

#output:
#Assassain Creed
#Nothing is true, everthing is permitted
#55
```

### Part 2

```
print(str[start:end])
print(str[:end])
First bracket include the letter, but the second does not include
print(str.lower())
print(str.upper())
print(str.count('e')) // check how many e inside this string
pint(str.find('x'))  // check x inside the str or not, return the place
```

```
print(message[10:15])
#first bracket include the letter, but the second does not

print(message[:10])

print(message.lower())
print(message.upper())
print('Count how many e inside the "message" ')
print(message.count('e'))
print(message.find('true'))

#output:
#Creed
#Assassain 
#assassain creed
#nothing is true, everthing is permitted
#ASSASSAIN CREED
#NOTHING IS TRUE, EVERTHING IS PERMITTED
#Count how many e inside the "message" 
#7
#27
```
### Part 3

```
// How to deal with Multiple strings
new_str=str.replace('A','B')               // replace A with B inside the string

new_str = str1 + ' ' + str2 + ',' + ste3   //concat the strings into one new string

str_format= '{} {}, str3'.format(str1, str2)   =>  str1 str2, str3

{} is for place holder

str_format_new = f '{str1} {str2}, str3'       =>  str1 str2, str3
```

```
new_message=message.replace("Nothing is true, everthing is permitted", "We work in dark and serve the light")
print(new_message)

greet = 'Bonsoir'
name  = 'Monsieur'
greet_msg = greet + ',' + name + ' Jacob'
greet_msg_format = '{}, {} Jacob'.format(greet, name)
greet_msg_f= f'{greet.upper()}, {name} Jacob'

print(greet_msg)
print(greet_msg_format)
print(greet_msg_f)


#output:
#Assassain Creed
#We work in dark and serve the light
#Bonsoir,Monsieur Jacob
#Bonsoir, Monsieur Jacob
#BONSOIR, Monsieur Jacob
```
### Part 4

```
print(dir(message))
print(help(str))
print(help(str.upper))
```


## 2.Integers and Floats - Working with Numeric Data

```
type(num)  <class 'int'> output type of number
num += 1

abs(num)    => get absoulte value
round(num)  => get round value
round(num, dig)  => get dig num of round of number

new_num = int(num)
print(new_num)
```

```
num = 3
print (type(num))

num += 1
print (num)

print ("-3 abs is", abs (-3))
print ("3.75 round is",round(3.75))
print ("3.75 at 1 digit round is",round(3.75, 1))

num1 = 3
num2 = 2
print( num1 == num2 )
print( num1 != num2 )

num1 = '100'
num2 = '200'
print(num1 + num2)

num1 = int(num1)
num2 = int(num2)
print(num1+num2)


#output:
#<class 'int'>
#4
#-3 abs is 3
#3.75 round is 4
#3.75 at 1 digit round is 3.8
#False
#True
#100200
#300
```
