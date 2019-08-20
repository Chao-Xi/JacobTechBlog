# Managing Simple Values

## Storing Data in Variables

* Go is a stically typed language
* **All variables have assigned types**
* You can set types `explicity` or `implicity`

### `Explicity` typed declarations

* Use var keyword and `=` assignment operator
* Setting initial value is optional

```
var anInteger int = 42
var aString string = "This is Go!"
```

### `Implicity` typed declarations

#### Use `:=` assignment operator without var


```
anInteger := 42
aString := "This is Go!"
```

**Type is still static, and can't be changed**



### Constants

A constant is a simple, unchanging value.

#### Explicit typing

```
const anInteger int = 42
```

#### Implicit typing

```
const aString = "This is Go!"
```


### Predeclared Boolean and String Types

#### Boolean value

`bool`

#### String type

`string`


#### Fixed integer types

```
unint8 unint16 unint32 unint64
int8 int16 int32 int64
```

#### Aliases

```
byte uint int uintptr
```

#### Floating values

```
float32 float64
```

#### Complex numbers

```
comlex64    comlex128
```

#### Predeclared Complex Types

**Data Collections**

```
Array Slices Maps Structs
``` 

**Language organization**

```
Functions Interfaces Channels
```

**Data management**

```
Pointers
```

## Working with string values

```
package main

import (
	"fmt"
	"strings"
)

func main() {
	str1 := "An implicity typed string"
	fmt.Printf("str1: %v:%T\n", str1, str1) //v% is value T% is Type
	str2 := "An explicity typed string"
	fmt.Printf("str2: %v:%T\n", str2, str2) //v% is value T% is Type

	fmt.Println(strings.ToUpper(str1))
	fmt.Println(strings.Title(str1))

	// compare without case sensitive
	uvalue := "HELLO"
	lvalue := "hello"
	fmt.Println("equal? ", (uvalue == lvalue))
	fmt.Println("equal? ", strings.EqualFold(lvalue, uvalue))

	fmt.Println("Contains exp?", strings.Contains(str1, "exp"))
	fmt.Println("Contains exp?", strings.Contains(str2, "exp"))
}
```

```
str1 := "An implicity typed string"
fmt.Printf("str1: %v:%T\n", str1, str1) //v% is value T% is Type
str2 := "An explicity typed string"
fmt.Printf("str2: %v:%T\n", str2, str2) //v% is value T% is Type
```

* `%v` for the value, and then after a literal colon, `%T` for the type

```
$  go run 5stringcode.go

str1: An implicity typed string:string
str2: An explicity typed string:string
```

### strings package

* `strings.ToUpper()`: return uppercase
* `strings.Title()`: The purpose of the Title method is to change the first character of each word in a string to uppercase.


### The default comparison is case-sensitive

`strings.EqualFold()`: The name of the method EqualFold refers to case folding, where you fold the case of all values to all uppercase.

```
	uvalue := "HELLO"
	lvalue := "hello"
	fmt.Println("equal? ", (uvalue == lvalue))
	fmt.Println("equal? ", strings.EqualFold(lvalue, uvalue))
```

```
$  go run 5stringcode.go

equal?  false
equal?  true
```

### `strings.Contains()`

```
fmt.Println("Contains exp?", strings.Contains(str1, "exp"))
fmt.Println("Contains exp?", strings.Contains(str2, "exp"))
```

```
Contains exp? false
Contains exp? true
```

### More string function

`https://golang.org/pkg/strings/`


## Using math operators and the math package

### Arithmetic Operators

Go supports all math operators used in C: 

* `+` Sum 
* `&` Bitwise AND 
* `-` Difference 
* `|` Bitwise OR 
* `*` Product A 
* `^` Bitwise XOR 
* `/` Quotient 
* `&^` Bit clear 
* `%` Remainder 
* `<<` Left shift 
* `>>` Right shift

### Math Requires Same Type

Numeric types don't implicitly convert. 

**Example: You can't add an int to a float.**

```
var int1 int = 5 
var float1 float64 = 42 
sum := int1 + float1 
fmt.Printf("Sum: %v, Type: %T", sum, sum) 


// invalid operation: int1 + float1 
// (mismatched types int and float64) 
```

### Convert Types before Using

Wrap value in tagret type as a function call

```
var intl int = 5 
var floatl float64 = 42 
sum := float64(intl) + floatl 
fmt.Printf("Sum: %v, Type: %T", sum, sum) 

// Sum: 47, Type: float64 
```

### The "math" Package 

For other operations, use "math" package: 

`https://golang.org/pkg/math/`

Provides mathematical constants and functions 

### Code

```
package main

import (
	"fmt"
	"math"
	"math/big"
)

func main() {

	i1, i2, i3 := 12, 45, 68
	intSum := i1 + i2 + i3
	fmt.Println("Integer sum: ", intSum)

	f1, f2, f3 := 22.5, 45.6, 77.3
	floatSum := f1 + f2 + f3
	fmt.Println("Float sum: ", floatSum)
	//Float sum:  145.39999999999998

	var b1, b2, b3, bigSum big.Float
	b1.SetFloat64(22.5)
	b2.SetFloat64(45.6)
	b3.SetFloat64(77.3)

	bigSum.Add(&b1, &b2).Add(&bigSum, &b3)
	fmt.Printf("BigSum = %.10g\n", &bigSum)

	circleRadius := 15.5
	circumference := circleRadius * math.Pi
	fmt.Printf("Circumference: %.2f", circumference)
}
```

```
$  go run 6MathCode.go

Integer sum:  125
Float sum:  145.39999999999998
BigSum = 145.4
Circumference: 48.69
```


* Set data types with `big.Float`, so float is a type of the math/big package
* `math.Pi`

## Working with dates and times


```
package main

import (
	"fmt"
	"time"
)

func main() {
	t := time.Date(2009, time.November, 10, 23, 0, 0, 0, time.UTC)
	fmt.Printf("Go launch at %s\n", t)

	now := time.Now()
	fmt.Printf("The time now is %s\n", now)

	fmt.Println("The month is", now.Month())
	fmt.Println("The day is", now.Day())
	fmt.Println("The weekday is", now.Weekday())

	tomorrow := now.AddDate(0, 0, 1)
	fmt.Printf("Tomorrow is: %v, %v %v, %v\n",
		tomorrow.Weekday(), tomorrow.Month(), tomorrow.Day(), tomorrow.Year())

	//Self define date format
	longFormat := "Monday, January 2, 2019"
	fmt.Println("Tomorrow is:", tomorrow.Format(longFormat))
	shortFormat := "1/2/19"
	fmt.Println("Tomorrow is:", tomorrow.Format(shortFormat))
}
```

* `Date.time(Year, month(time.November), day, hour, minutes, seconds, nanoseconds, a constant of time.UTC for the location (Time.Utc))`

```
fmt.Printf("Go launch at %s\n", t)

> Go launch at 2009-11-10 23:00:00 +0000 UTC
```

### Output now date

```
now := time.Now()
fmt.Printf("The time now is %s\n", now)
> The time now is 2019-07-17 16:55:10.718365 +0800 CST m=+0.000221462

fmt.Println("The month is", now.Month())
fmt.Println("The day is", now.Day())
fmt.Println("The weekday is", now.Weekday())
> The month is July
> The day is 17
> The weekday is Wednesday
```

### `AddDate(y, m, d)`

```
tomorrow := now.AddDate(0, 0, 1)
fmt.Printf("Tomorrow is: %v, %v %v, %v\n",
		tomorrow.Weekday(), tomorrow.Month(), tomorrow.Day(), tomorrow.Year())
```

```
Tomorrow is: Thursday, July 18, 2019
```

### Self define date format

```
longFormat := "Monday, January 2"
fmt.Println("Tomorrow is:", tomorrow.Format(longFormat))
shortFormat := "1/2"
fmt.Println("Tomorrow is:", tomorrow.Format(shortFormat))
```

```
Tomorrow is: Thursday, July 18
Tomorrow is: 7/18
```

