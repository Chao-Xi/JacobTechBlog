# Structuring Go code

1. Defining and calling functions
2. Returning multiple values from functions
3. Creating packages as function libraries
4. Defining functions as methods of custom types
5. Defining and implementing interfaces
6. Deferring function calls

## 1.Defining and calling functions

```
package main

import "fmt"

func main() {
	doSomething()

	sum := addValues(22, 45)
	fmt.Println("sum:", sum)

	sum = addAllValues(12, 34, 45)
	fmt.Println("New sum:", sum)
}

func doSomething() {
	fmt.Println("This comes from doSomething function")
}

func addValues(values1, values2 int) int {
	return values1 + values2
}

func addAllValues(values ...int) int {
	sum := 0
	for i := range values {
		sum += values[i]
	}
	fmt.Printf("%T\n", values)
	return sum
}
```

```
func addValues(values1 int, values2 int) int {
	return values1 + values2
}
```

* Two arguments, and both are integer
* `int { ...` is reutrn value type


If you have arguments of the same type. **You can pass in the list of arguments and only declare the type once**, after the last argument in the list

```
func addValues(values1, values2 int) int {
	return values1 + values2
}
```

```
$ go run 17Func.go 
This comes from doSomething function
sum: 67
```

### Arbitrary numbers of values with the same type

```
func addAllValues(values ...int) int { 

}
```

`fmt.Printf("%T\n", values)`

 `[]int`: **The output should be a slice**
 
 
```
func addAllValues(values ...int) int {
	sum := 0
	for i := range values {
		sum += values[i]
	}
	// fmt.Printf("%T\n", values)
	return sum
}
```

```
sum = addAllValues(12, 34, 45)
fmt.Println("New sum:", sum)
```

`New sum: 91`

### Go there's no function or method overloading. 

So each function of a particular name has its own number of arguments and those arguments have their own specific types, and you can't have two functions of the same name within the same package, even if they differ in their function signatures.

### Lower case initial function are private functions. 

That is they aren't exported for use outside this package

### Upper case fucntions are public function

Public function are accessible to the rest of the application. 

## 2.Returning multiple values from functions

```
package main

import "fmt"

func main() {
	n1, l1 := Fullname("foo", "bar")
	fmt.Printf("Fullname: %v, numer of chars :%v \n\n", n1, l1)

	n2, l2 := FullnameNakedReturn("Jacob", "Hill")
	fmt.Printf("Fullname: %v, numer of chars :%v \n", n2, l2)
}

func Fullname(f, l string) (string, int) {
	full := f + " " + l
	length := len(full)
	return full, length
}

func FullnameNakedReturn(f, l string) (full string, length int) {
	full = f + " " + l
	length = len(full)
	return
}
```

```
$ go run 18Multi_return.go 
Fullname: foo bar, numer of chars :7 

Fullname: Jacob Hill, numer of chars :10
```

### Opt1

```
func Fullname(f, l string) (string, int) {
    full := f + " " + l
    length := len(full)
    return full, length
}
```

In the first example, you have to remember to **return the values in the same order in which you declared them**

### Opt2 (more common and readable)

```
func FullnameNakedReutrn(f, l string) (full string, length int) {
	full = f + " " + l
	length = len(full)
	return
}
```


## 3.Creating packages as function libraries

### Main function `19Library.go `

```
package main

import (
	"fmt"
	"stringutil"
)

func main() {
	n1, l1 := stringutil.Fullname("foo", "bar")
	fmt.Printf("Fullname: %v, numer of chars :%v \n\n", n1, l1)

	n2, l2 := stringutil.FullnameNakedReutrn("Jacob", "Hill")
	fmt.Printf("Fullname: %v, numer of chars :%v \n", n2, l2)
}
```

* **`import stringutil`**
* **`stringutil.Fullname()`**


### Package function

```
~/go/src
```

```
$ mkidr stringutil/
$ touch stringutil.go
```

```
package stringutil

func Fullname(f, l string) (string, int) {
	full := f + " " + l
	length := len(full)
	return full, length
}

func FullnameNakedReutrn(f, l string) (full string, length int) {
	full = f + " " + l
	length = len(full)
	return
}
```

* **`package stringutil`**

```
$ go run 19Library.go 
Fullname: foo bar, numer of chars :7 

Fullname: Jacob Hill, numer of chars :10
```


## 4.Defining functions as methods of custom types

**Go also supports the concept of methods**, which are essentially functions, but they're owned by some structure or other type

```
package main

import "fmt"

type Dog struct {
	Breed  string
	Weight int
	Sound  string
}

func (d Dog) Speak() {
	fmt.Println(d.Sound)
}

// func (d Dog) Speakthree() {
// 	d.Sound = fmt.Sprintf("%v %v %v!\n", d.Sound, d.Sound, d.Sound)
// 	fmt.Print(d.Sound)
// }

func (d *Dog) Speakthree() {
	d.Sound = fmt.Sprintf("%v %v %v!", d.Sound, d.Sound, d.Sound)
	fmt.Println(d.Sound)
}

func main() {
	corji := Dog{"corji", 33, "Wo"}
	fmt.Println(corji)
	corji.Speak()

	corji.Sound = "wof"
	corji.Speak()

	corji.Speakthree()
	corji.Speakthree()
}
```

### In Go, a method is a member of a type

```
type Dog struct {
	Breed  string
	Weight int
	Sound  string
}

func (d Dog) Speak() {
	fmt.Println(d.Sound)
}

```

#### In main function

```
corji := Dog{"corji", 33, "Wo"}
fmt.Println(corji)
corji.Speak()

corji.Sound = "wof"
corji.Speak()
```

```
{corji 33 Wo}
Wo
wof
```

Now `(d Dog)` is variable. When the variable is passed into the function, **a copy of the original object is made, and if any changes to the object are made within the function then those changes will not affect the original object outside the function itself**.

```
func (d Dog) Speakthree() {
	d.Sound = fmt.Sprintf("%v %v %v!\n", d.Sound, d.Sound, d.Sound)
	fmt.Print(d.Sound)
}


corji.Speakthree()
> wof wof wof!

```

* **`%v` is a literal character**
* `Sprintf()` formats according to a format specifier and returns the resulting string.

```
corji.Speakthree()
corji.Speakthree()

wof wof wof!
wof wof wof!
```

**Run again, the value of the object doesn't change the original version**


##### Add asterisk`(*)` operator before the type. And now I'll receive the Dog object as a pointer

```
func (d *Dog) Speakthree() {
	d.Sound = fmt.Sprintf("%v %v %v!", d.Sound, d.Sound, d.Sound)
	fmt.Println(d.Sound)
}
```

```
corji.Speakthree()
corji.Speakthree()

> wof wof wof!
> wof wof wof! wof wof wof! wof wof wof!!
```

**The ability to create custom methods for your own types makes Go behave more like a fully object-oriented language even without the sort of type inheritance**

## 5.Defining and implementing interfaces

Go supports the use of interfaces to define high-level abstractions and create programming contracts.

**If a type implements all of the methods defined in an interface, then it's an implementation of that interface.**

**Interface and type relationships are implied by the presence of the methods**

```
package main

import "fmt"

type Animal interface {
	Speak() string
}

type Dog struct {
}

// function Speak is member of Dog struct
func (d Dog) Speak() string {
	return "woo "
}

type Cat struct {
}

// function Speak is member of Cat struct
func (c Cat) Speak() string {
	return "meow"
}

type Cow struct {
}

// function Speak is member of Cow struct
func (c Cow) Speak() string {
	return "moo"
}

func main() {
	corji := Animal(Dog{})
	fmt.Println(corji)
	// {} represent the object itself, which doesn't have any fields and values
	animals := []Animal{Dog{}, Cat{}, Cow{}}

	// _ is for index
	for _, animal := range animals {
		fmt.Println(animal.Speak())
	}
}

```

* `_`is for index
* `for _, animal := range animals { }`

```
$ go run 21interface.go 
{}
woo 
meow
moo
```

## 7. Handling errors

**Go doesn't support classic exception-handling syntax, with the usual try and catch keywords**

In Go, an error in Go is an **instance of an interface** that defines a single method, named **error**, and that method returns a string and that string is the error message.


```
package main

import (
	"errors"
	"fmt"
	"os"
)

func main() {
	f, err := os.Open("filename.ext")

	if err == nil {
		fmt.Println(f)
	} else {
		fmt.Println(err.Error())
	}

	myError := errors.New("My error String")
	fmt.Println(myError)

	attendene := map[string]bool{
		"Anne": true,
		"Mike": true}
	attended, ok := attendene["Ann"]

	if ok {
		fmt.Println("Anne attended?", attended)
	} else {
		fmt.Println("No info for Anne")
	}

}
```

* `err.Error()`:  Return error message

### Create error message

```
errors.New("Error Message")
```

* `map[string]bool{}` 
  * **key is string**
  * **value is boolean value**

```
attendene := map[string]bool{
		"Anne": true,
		"Mike": true}
```

**`attended, ok := attendene["Ann"]`**

**ok is boolean value** 
   
```
if ok {
		fmt.Println("Anne attended?", attended)
	} else {
		fmt.Println("No info for Anne")
	}
```
```
No info for Anne
```

## 6.Deferring function calls

```
package main

import "fmt"

func main() {
	// fmt.Println("Close the file!")
	defer fmt.Println("Close the file!")
	
	fmt.Println("Open the file!")

	defer fmt.Println("sts 1!")
	defer fmt.Println("sts 2!")

	myFunc()

	defer fmt.Println("sts 3!")
	defer fmt.Println("sts 4!")
	fmt.Println("Undefered statement!")

	x := 1000
	defer fmt.Println("Value of x: ", x)
	x++
	fmt.Println("Value of x after incrementing: ", x)
}

func myFunc() {
	defer fmt.Println("Deferred in the function")
	fmt.Println("Not deferred in the function")
}
```

`defer`: Each time you call the "defer" statement, it adds an instruction to a stack, and when the deferred statements are executed, **they're handled in last in, first out order, known as LIFO.**

```
Open the file!
Not deferred in the function
Deferred in the function
Undefered statement!
Value of x after incrementing:  1001
Value of x:  1000
sts 4!
sts 3!
sts 2!
sts 1!
Close the file!
```


```
sts 4!
sts 3!
sts 2!
sts 1!
Undefered statement!
```

First output only other undeferred statement in the function. Then I see all the **deferred statements in reverse order of their declaration**

```
Not deferred in the function
Deferred in the function
Undefered statement!
```

**The deffered function was called before any other deferred statements, since it has undeferred statement**


```
Value of x after incrementing:  1001
Value of x:  1000
```

The original value of "x" is still 1000, **so it was evaluated and its value was saved at the moment of deferring, rather than wait until execution happens**

### Example code

```
package main

import "fmt"

var isConnected bool = false

func main() {
	fmt.Printf("Connection open: %v\n", isConnected)
	doSomething()
	fmt.Printf("Connection open: %v\n", isConnected)
}

func doSomething() {
	connect()
	fmt.Println("Deferring disconnect!")
	defer disconnect()
	fmt.Printf("Connection open: %v\n", isConnected)
	fmt.Println("Doing something!")
}

func connect() {
	isConnected = true
	fmt.Println("Connected to database!")
}

func disconnect() {
	isConnected = false
	fmt.Println("Disconnected!")
}
```

```
Connection open: false
Connected to database!
Deferring disconnect!
Connection open: true
Doing something!
Disconnected!
Connection open: false
```



