# Managing Complex Types and Collection

## 1.Referencing values with pointers

Go supports the use of pointers, **variables that store the address of another value**

You can declare a pointer with a particular type, but you don't have to point it at an initial value. 

```
package main

import (
	"fmt"
)

func main() {
	var p *int

	if p != nil {
		fmt.Println("Value of p:", *p)
	} else {
		fmt.Println("p is nil")
	}

	var v int = 44
	p = &v
	if p != nil {
		fmt.Println("Value of p:", *p)
	} else {
		fmt.Println("p is nil")
	}

	var value1 float64 = 44.32
	pointer1 := &value1
	fmt.Println("value 1:", *pointer1)

	*pointer1 = *pointer1 / 2
	fmt.Println("Value 1: ", *pointer1)
	fmt.Println("Value 1: ", value1)
}

```

#### `asterisk operator: *`

* `var p *int` Declare a variable, and `*int` so the pointer can point any variable 

```
var p *int

	if p != nil {
		fmt.Println("Value of p:", *p)
	} else {
		fmt.Println("p is nil")
	}
```

```
p is nil
```

#### `ampersand operator: &`

* The ampersand means connect the pointer to this variable.

```
var v int = 44
p = &v

if p != nil {
	fmt.Println("Value of p:", *p)
} else {
	fmt.Println("p is nil")
}
```

`&v` is address in memeory

```
fmt.Println(&v)
0xc000018098
```

```
fmt.Println(*p)
44
```
#### `&`: ampersand means connect the pointer and the value to each other

```
var value1 float64 = 44.32
pointer1 := &value1
fmt.Println("value 1:", *pointer1)
```	

* `pointer1 := &value1` create a new pointer **pointer1** and setting it using the ampersand and value1.
* **output value with asterisk ahead** `*pointer1`

#### change reference value also change original value

```
*pointer1 = *pointer1 / 2
fmt.Println("Value 1: ", *pointer1)
fmt.Println("Value 1: ", value1)
```
```
Value 1:  22.16
Value 1:  22.16
```

## 2.Storing ordered values in arrays

```
package main

import (
	"fmt"
)

func main() {

	var colors [3]string
	colors[0] = "pink"
	colors[1] = "black"
	colors[2] = "brown"

	fmt.Println(colors)
	fmt.Println(colors[1])

	numbers := [5]int{5, 3, 4, 2, 1}
	// var numbers = [5]int{5, 3, 4, 2, 1}
	fmt.Println(numbers)

	fmt.Println("Number of colors", len(colors))
	fmt.Println("Number of numbers", len(numbers))
}
```

### Declare a array

```
var colors [3]string
```

```
numbers := [5]int{5, 3, 4, 2, 1}
var numbers = [5]int{5, 3, 4, 2, 1}
```

```
for i := 0; i < len(colors); i++ {
	fmt.Println("Output each color:", colors[i])
}
```

```
Out put each color: pink
Out put each color: black
Out put each color: brown
```

### multi-dimensional data structures.

```
    var twoD [2][3]int
    for i := 0; i < 2; i++ {
        for j := 0; j < 3; j++ {
            twoD[i][j] = i + j
        }
    }
    fmt.Println("2d: ", twoD)
```

```
2d:  [[0 1 2] [1 2 3]]
```

## 3.Storing ordered values in slices


```
package main

import (
	"fmt"
	"sort"
)

func main() {
	var colors = []string{"deepblue", "watermelon", "cheery"}
	fmt.Println(colors)

	var colors_appended = append(colors, "grape")
	fmt.Println(colors_appended)

	// remove first element in array
	colors = append(colors_appended[1:len(colors_appended)])
	fmt.Println(colors)

	// remove last element in array
	colors = append(colors_appended[:len(colors_appended)-1])
	fmt.Println(colors)

	numbers := make([]int, 5, 5) // initial size of five, and a capacity of five
	numbers[0] = 1
	numbers[1] = 2222
	numbers[2] = 44
	numbers[3] = 33
	numbers[4] = 323

	fmt.Println(numbers)

	numbers = append(numbers, 2333)
	fmt.Println(numbers)
	fmt.Println(cap(numbers)) // Report the current capacity.

	sort.Ints(numbers)
	fmt.Println(numbers)
}
```

### Create a new no-length limit array

```
var colors = []string{"deepblue", "watermelon", "cheery"}
```
```
[deepblue watermelon cheery]
```

#### append a new value into array

```
var colors_appended = append(colors, "grape")
```

```
[deepblue watermelon cheery grape]
```

**`var new_array_name = append(array_name, element)`**


#### remove first element `[0]` in array

```
colors = append(colors_appended[1:len(colors_appended)])
fmt.Println(colors)
```
```
[watermelon cheery grape]
```

####  remove last element in array `[len(colors_appended)-1]`

```
colors = append(colors_appended[:len(colors_appended)-1])
fmt.Println(colors)
```
```
[deepblue watermelon cheery]
```

####  declare a slice 

Declare a slice with a type, such as int, or string, and so on, and an **initial size**, with the **built-in make function**

`make([]type, ini_size, cap_size)`

```
numbers := make([]int, 5, 5) // initial size of five, and a capacity of five
numbers[0] = 1
numbers[1] = 2222
numbers[2] = 44
numbers[3] = 33
numbers[4] = 323

fmt.Println(numbers)
```

```
[deepblue watermelon cheery]
```

```
numbers = append(numbers, 2333)
fmt.Println(numbers)
fmt.Println(cap(numbers)) // Report the current capacity.
```
```
[1 2222 44 33 323 2333]
10
```

#### Sort string

```
sort.Ints(numbers)
fmt.Println(numbers)
```	
```
[1 33 44 323 2222 2333]
```

## 4.How memory is allocated and managed

### Memory Is Managed by the Runtime 

The Go runtime is statically linked into the application. 

**Memory is allocated and deallocated automatically.** 

**Use `make()` or `new()` to initialize**


`Maps, slices, channels`

### Memeory Allocation

#### The `new()` function

* **Allocate but does not initialize memory**
* Results in zerod storage but returns a memory address

#### The `new()` function

* **Allocate and initilizes memory**
* Allocate non-zeroed storage and returns a memory address


#### Creating nil Object

You must initialize complex object before adding values

Declarations without `make()` can cause a `panic`

```
var m map[string]int
m["key"] = 42
fmt.Println(m)
``` 

```
panic: assignment to entry in nil map
```

#### Correct Memory Initialization

Use `make()` to allocate amd initialize memory

```
m := make(map[string]int)
m["key"] = 42
fmt.Println(m)

// map[key:42]
```

#### Memory Deallocation 

* Memory is deallocated by garbage collector (GC). 
* Objects out of scope or set to nil are eligible. 
* GC was rebuilt in Go 1.5 for very low latency. 

`https://golang.org/pkg/runtime/`


## 5.Storing unordered values in maps

```
package main

import (
	"fmt"
	"sort"
)

func main() {
	states := make(map[string]string)

	states["NY"] = "New York"
	states["NJ"] = "New Jersey"
	states["CA"] = "California"

	fmt.Println(states)

	california := states["CA"]
	fmt.Println(california)

	delete(states, "NJ")
	fmt.Println(states)

	states["WA"] = "Washington"

	for k, v := range states {
		fmt.Printf("%v: %v\n", k, v)
	}

	keys := make([]string, len(states))
	// fmt.Println(len(keys))
	i := 0
	for k := range states {
		keys[i] = k
		i++
	}
	sort.Strings(keys)
	fmt.Println("\nSorted")

	for i := range keys {
		fmt.Println(states[keys[i]])
	}

}
```

#### `A Map` in Go is an `unordered collection` of `key value pairs`

It's essentially a hash table that lets you store collections of data and then arbitrarily find items in the collection by their keys


You can declare an empty map and initialize it with built-in `make` function

```
# map := make(map[key-type]value-type)

states := make(map[string]string)

# So my map will have keys and values that are both strings
```

```
states := make(map[string]string)
states["NY"] = "New York"
states["NJ"] = "New Jersey"
states["CA"] = "California"

fmt.Println(states)

california := states["CA"]
fmt.Println(california)
```
```
$ go run 12Map.go 
map[CA:California NJ:New Jersey NY:New York]
California
```

### Delete

To delete an item from the map, use the built-in Delete function and pass in the map and the key of the item that you want to delete as separate arguments

```
delete(states, "NJ")
fmt.Println(states)

> map[CA:California NY:New York]
```

### Loop the map and out put key and value

```
### Add new element

states["WA"] = "Washington"

for k, v := range states {
	fmt.Printf("%v: %v\n", k, v)
}
```

```
NY: New York
WA: Washington
CA: California
```


### Sort the value by keys

#### 1. Extract the keys from the map as a slice of strings

Declare a **slice(array)** using the make function, and I'll declare it as a slice of strings, and **I'll set the size of the slice using the length of the states.**

```
keys := make([]string, len(states))
fmt.Println(len(keys))
> 3

```

**import the `sort` package**

```
import (
	"fmt"
	"sort"
)


keys := make([]string, len(states))

for k := range states {
		keys[i] = k
		i++
}

sort.Strings(keys) # sort the keys

fmt.Println("\nSorted")

for i := range keys {
		fmt.Println(states[keys[i]])
}	
```

Then, I sorted that slice, and then, I iterating through that slice to output the values from the map in the order 

```
Sorted
California
New York
Washington
```


## 6.Grouping related values in structs

```
package main

import "fmt"

type Dog struct {
	Breed  string
	Weight int
}

func main() {

	Corji := Dog{"Corji", 14}
	fmt.Println(Corji)
	fmt.Printf("%+v\n", Corji)
	fmt.Printf("Breed: %v\nWeight: %v\n", Corji.Breed, Corji.Weight)

}
```

* The struct type in Go is a data structure
* **`Go doesn't have an inheritance model.` You don't have concepts like `super` or `sub-structs`. `Each structure is independent,` with its own fields for data management and optionally its own methods**
* **The struct's name typically has an initial uppercase character**. 
* **Start with type, then the struct name,**
* **Then the keyword struct. Within the braces**

```
type Dog struct {
	Breed  string
	Weight int
}
```

```
func main() {

	Corji := Dog{"Corji", 14}
	fmt.Println(Corji)
}

> {Corji 14}
```

### Dump the contents of structs

**You can dump the complete contents of a struct, including its field names and values using the Printf function and a verb spelled `%+v`**

```
fmt.Printf("%+v\n", Corji)

> {Breed:Corji Weight:14}
```

**So this is a great way to debug and see what's in the data**


**You access the struct's individual fields with the `. operator`.**

```
fmt.Printf("Breed: %v\nWeight: %v\n", Corji.Breed, Corji.Weight)
```

```
Breed: Corji
Weight: 14
```
 