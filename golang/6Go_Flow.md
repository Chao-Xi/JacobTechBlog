# Managing Program Flow

## Programming conditional logic

```
package main

import "fmt"

func main() {

	var x float64 = 42
	var result string

	if x < 0 {
		result = "Less than zero"
	} else if x == 0 {
		result = "Equal to zero"
	} else {
		result = "Greater than 0"
	}
	fmt.Println("Result:", result)
}
```
```
> Greater than 0
```

**If you want to release that memory when the conditional logic is done**

```
func main() {

	//var x float64 = 42
	var result string
   
   // You can include an initial statement as part of the if declaration.
	if x := -33; x < 0 {
		result = "Less than zero"
	} else if x == 0 {
		result = "Equal to zero"
	} else {
		result = "Greater than 0"
	}
	// fmt.Println("Result:", result)
	fmt.Println("Value of X:", x)
}
```

```
# command-line-arguments
./14Condi.go:18:29: undefined: x
```

## Evaluating expressions with switch statements

```
package main

import (
	"fmt"
	"math/rand"
	"time"
)

func main() {
	rand.Seed(time.Now().Unix())
	// dow := rand.Intn(6) + 1
	// // rand.Intn(6)  0...6
	// fmt.Println("Day", dow)

	result := ""

	switch dow := rand.Intn(6) + 1; dow {
	case 7:
		result = "It's sunday"
	case 6:
		result = "It's Saturday"
	default:
		result = "It's a Weekday"
	}
	//fmt.Println("Day", dow, ",", result)
	fmt.Println(result)

	x := -42
	switch {
	case x < 0:
		result = "Less than zero"
		//fallthrough
	case x == 0:
		result = "equal to zero"
	default:
		result = "greater than zero"
	}

	fmt.Println(result)
}
```

```
Its Saturday
Less than zero
```


* `rand.Seed()` **generate random sequence number everytime**
* `rand.Seed(time.Now().Unix())`: The first statement seeds the randomized value using a number of milliseconds from the current date and time.
* **I'll get a different number of milliseconds each time I run the code**

#### Declare a new variable within the switch statement

```
switch dow := rand.Intn(6) + 1; dow {
	case 7:
		result = "It's sunday"
	case 6:
		result = "It's Saturday"
	default:
		result = "It's a Weekday"
	}
```

`switch dow := rand.Intn(6) + 1; dow {}`


#### `fallthrough` keyword

If you add it after any code within a case if that case it true you'll execute its code, and you'll also execute the next case.

```
x := -42
	switch {
	case x < 0:
		result = "Less than zero"
		fallthrough
	case x == 0:
		result = "equal to zero"
	default:
		result = "greater than zero"
	}

	fmt.Println(result)
```

```
equal to zero
```

You've evaluated a successful case, the rest of the cases within the switch statement will be ignored.

## Creating loops with for statements

```
package main

import "fmt"

func main() {
	sum := 1
	fmt.Println("Sum:", sum)

	colors := []string{"Red", "Blue", "Green"}
	fmt.Println(colors)

	sum = 0
	for i := 0; i < 10; i++ {
		sum += 1
	}
	fmt.Println("Sum: ", sum)

	for i := 0; i < len(colors); i++ {
		fmt.Println(colors[i])
	}

	for i := range colors {
		fmt.Println(colors[i])
	}

	sum = 1
	for sum < 1000 {
		sum += sum
		fmt.Println("sum:", sum)
		if sum > 200 {
			goto endofprogram
		}
		if sum > 500 {
			break
		}
	}

endofprogram:
	fmt.Println("end of program")
}
```

* `colors := []string{}` 
* `for i := 0; i < 10; i++ { }`
* `for i := 0; i < len(colors); i++ { }`
* **`for i := range colors { }`** which is much simple and clear
* `for sum < 1000 { }`

### break 

**Break means jump to the end of the current code block** and works with both `for` and `switch` statements

```
sum = 1
for sum < 1000 {
	sum += sum
	fmt.Println("sum:", sum)
	if sum > 500 {
		break
	}
}
```

```
sum: 2
sum: 4
sum: 8
sum: 16
sum: 32
sum: 64
sum: 128
sum: 256
sum: 512
```

### goto

goto statement and go to the end of the program

```
sum = 1
	for sum < 1000 {
		sum += sum
		fmt.Println("sum:", sum)
		if sum > 200 {
			goto endofprogram
		}
	}

endofprogram:
	fmt.Println("end of program")
```

```
sum: 2
sum: 4
sum: 8
sum: 16
sum: 32
sum: 64
sum: 128
sum: 256
end of program
```


* Create a **label** named `endofprogram`, and I'll mark it as a label with a colon character

```
endofprogram:
	fmt.Println("end of program")
``