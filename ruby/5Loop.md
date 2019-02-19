# LOOP

## loop

### Loops until you break out of loop

```
x = 1
 
# Loops until you break out of loop
 
loop do
  # Shortcut for x = x + 1
  x += 1
 
  # Slips this iteration of the loop
  next unless (x % 2) == 0
  puts x
 
  # Ends the looping
  break if x >= 10
end

> 2
> 4
> 6
> 8
> 10
```

## WHILE LOOP

### Do stuff while the condition is met

```
y = 1
while y <= 10
	y += 1
	next unless ( y % 2) == 0
	puts y
end 

> 2
> 4
> 6
> 8
> 10
```

```
z = 1
 
begin
  z += 1
  next unless (z % 2) == 0
  puts z
  break if z >= 10
end while z <= 10

> 2
> 4
> 6
> 8
> 10
```

## UNTIL LOOP

### Do stuff until a condition is met

```
a = 1
 
until a >= 10
  a += 1
  next unless (a % 2) == 0
  puts a
end

> 2
> 4
> 6
> 8
> 10
```


## FOR LOOPS 

### Create an array of numbers

```
numbers = [1, 2, 3, 4, 5]
```

```
Cycles through every item in numbers temporarily storing them in number
 #{variable} can be used to insert values
```
 
```
for number in numbers
  puts "#{number}, "
end

> 1, 
> 2, 
> 3, 
> 4, 
> 5,
```

```
groceries = ["bananas", "sweet potatoes", "pasta", "tomatoes"]
```

### Cycles through every item in groceries temporarily storing them in food


```
groceries.each do |food|
  puts "Get some #{food}"
end

Gets some bananas
Gets some sweet potatoes
Gets some pasta
Gets some tomato
```

### Cycles through numbers 0 through 5
 
```
(0..5).each do |i|
	puts "# #{i}"
end 

# 0
# 1
# 2
# 3
# 4
# 5
```

 
 


