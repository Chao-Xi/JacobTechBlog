# Arrays

## Creating arrays

```
array_1 = Array.new
array_2 = Array.new(5)           # Gets nil as default
array_3 = Array.new(5, "empty")  
array_4 = [1, "two", 3, 3.5]     # You can store multiple object types


puts array_1   
>
puts array_2
>
>
>
>
>
puts array_3
> empty
> empty
> empty
> empty
> empty
puts array_4
> 1
> two
> 3
> 3.5
```

### Indexes start at 0

```
puts array_4[2]

> 3
```

### Return 2 values starting at the 2nd index

```
puts array_4[2, 2].join(", ")

> 3, 3.5
```

### Return values in index 0, 1 and 3

```
puts array_4.values_at(0,1,3).join(", ")
1, two, 3.5
```

### Add 0 at the beginning of the array

```
array_4.unshift(0) # add 0 to the start
puts array_4[0]

> 0
```

### Remove the first item in the array

```
array_4.shift()
puts array_4.join(", ")

> 1, two, 3, 3.5
```

### Add 100 and 200 to the end of the array

```
array_4.push(100,200) #add to the end
puts array_4.join(", ")
> 1, two, 3, 3.5, 100, 200
```

### Remove item at the end of the array

```
array_4.pop
puts array_4.join(", ")

> 1, two, 3, 3.5, 100
```

### Add one array to the end of another

```
array_4.concat([10,20,30]) # add to the array
puts array_4.join(", ")

> 1, two, 3, 3.5, 100, 10, 20, 30
```

### Array Methods

```
puts "Array Size : " + array_4.size().to_s
puts "Array Contains 100 : " + array_4.include?(100).to_s
puts "How Many 100s: " + array_4.count(100).to_s
puts "Array Empty : " + array_4.empty?.to_s 

> Array Size : 8
> Array Contains 100 : true
> How Many 100s: 1
> Array Empty : false
```

### Convert an array into a string

```
puts array_4.join(", ")
> 1 ,two ,3 ,3.5 ,100 ,10 ,20 ,30
```

### Print and Inspect the array

```
p array_4 

> [1, "two", 3, 3.5, 100, 10, 20, 30]
```

### Output array in loop

```
array_4.each do |value|
	puts value
end

> 1
> two
> 3
> 3.5
> 100
> 10
> 20
> 30
```






