# Enumerable

**Classes that include the Enumerable module gain collection capabilities but they must define a function called each**

```
class Menu
	include Enumerable

	def each 
		yield "pizza"
		yield "spaghetti"
		yield "salad"
		yield "water"
		yield "bread"
	end
end

menu_options = Menu.new 

menu_options.each do |item|
	puts "would you like : #{item}"
end

> would you like : pizza
> would you like : spaghetti
> would you like : salad
> would you like : water
> would you like : bread
```

### Check to see if we have pizza

```
p menu_options.find {|item| item == "pizza"}
> "pizza"
```

### Return items 5 letters in length

```
p menu_options.select{|item| item.size <=5 }
> ["pizza", "salad", "water", "bread"]
```
### Reject items that meet the criteria

```
p menu_options.reject{|item| item.size <=5 }
> ["spaghetti"]
```

### Return the first item

```
p menu_options.first
> "pizza"
```

### Return the first 2

```
p menu_options.take(2)
> ["pizza", "spaghetti"]
```

### Return the everything except the first 2

```
p menu_options.drop(2)
> ["salad", "water", "bread"]
```

### Return the minimum item

```
p menu_options.min
> "bread"
```

### Return the maximum item

```
p menu_options.max
> "water"
```
### Sort the items

```
p menu_options.sort
["bread", "pizza", "salad", "spaghetti", "water"]
```

### Return each item in reverse order

```
menu_options.reverse_each {|item| puts item}
> bread
> water
> salad
> spaghetti
> pizza
```


