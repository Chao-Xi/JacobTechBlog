# Go input and output

## Outputting strings with the fmt package

```
package main

import (
	"fmt"
)

//:= declare /  = assign
func main() {
	str1 := "The quick red fox"
	str2 := "jumped over"
	str3 := "the lazy brown dog."
	aNumber := 42
	isTrue := true

	fmt.Println(str1, str2, str3)
}
```

* `:=`: **declare**
* `=`: **assign**
* `fmt.Println()`:  Patch three values as a comma delimited list.


```
stringLength, err := fmt.Println(str1, str2, str3) 

if err == nil {
	fmt.Println("String Length:", stringLength)
}

// `=` Inferred type asignment operator
// Whether I got non-nil error object back
// Error equals to nil
```

```
$ go run 3fmtoutput.go 
The quick red fox jumped over the lazy brown dog.
String Length: 50
```

#### If not go through the `non-nil error` check

```
stringLength, err := fmt.Println(str1, str2, str3) 
fmt.Println("String Length:", stringLength)

$ go run 3fmtoutput.go 
# command-line-arguments
./3fmtoutput.go:15:16: err declared and not used
```

#### Print without `non-nil error` check

```
stringLength, _ := fmt.Println(str1, str2, str3)
fmt.Println("String Length:", stringLength)

The quick red fox jumped over the lazy brown dog.
String Length: 50
```

### `Printf` function

This function lets you create strings that have placeholders known as `verbs`, that define how values will be formatted. 

I'll start with a string of value of a number, and then instead of using a comma delimited list, I'll use a verb,` %V`. 

This verb means output the value of the variable.

```
# code
fmt.Printf("Value of aNumber: %v\n", aNumber)
fmt.Printf("Value of isTrue: %v\n", isTrue)
fmt.Printf("Value pf aNumber as float: %.2f\n", float64(aNumber))

$ go run 3fmtoutput.go 
Value of aNumber: 42
Value of isTrue: true
Value pf aNumber as float: 42.00
```

* `\n` add new line, `Printf` must add this to start new line
* **`PrintLine` function**, which adds the line feed automatically
* `%.2f`, which means give me a floating number with two decimal points
* `float64()`, wrapping the number with float64 and it would convert an **integer to a float**

### Datatype

```
fmt.Printf("Data Types: %T, %T, %T, %T, and %T\n",
		str1, str2, str3, aNumber, isTrue)


$ go run 3fmtoutput.go 
Data Types: string, string, string, int, and bool
```


### `SPrintF` to create a string variable

```
myString := fmt.Sprintf("Data Types as var: %T, %T, %T, %T, and %T\n",
		str1, str2, str3, aNumber, isTrue)
fmt.Print(myString)

$ go run 3fmtoutput.go 
Data Types as var: string, string, string, int, and bool
```



## Get input from console

```
package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

func main() {
	// var s string
	// fmt.Scanln(&s)
	// fmt.Println(s)

	reader := bufio.NewReader(os.Stdin) //Declare
	fmt.Print("Enter text: ")
	str, _ := reader.ReadString('\n')
	fmt.Println(str)

	fmt.Print("Enter a number: ")
	str, _ = reader.ReadString('\n') //Assign
	f, err := strconv.ParseFloat(strings.TrimSpace(str), 64)
	if err != nil {
		fmt.Println(err)
	} else {
		fmt.Println("Value of number:", f)
	}
}
```

### Scan method

The scan methods. These are designed to get input from the console, files, variables, and other input sources and **automatically separate values** from each other by looking for space characters

### `fmt.Scanln`

```
var s string
fmt.Scanln(&s)
fmt.Println(s)
```

I'll pass it in as a reference. 

* `&s`: The syntax for that is the name of the variable with an ampersand prefix.


```
$ go run 4ftminput.go 
test
test
```

```
$ go run 4ftminput.go 
one two three
one
```

**It automatically breaks up the string wherever it finds space characters.**

### Buifo and os package

If you want simply to collect user input, in a console application, you should instead use a couple of packages named `bufio` and `os`


```
import (
	"bufio"
	"fmt"
	"os"
)

func main() {

	reader := bufio.NewReader(os.Stdin) //Declare
	fmt.Print("Enter text: ")
	str, _ := reader.ReadString('\n')
	fmt.Println(str)
}
```

* Create reader.object with `buifo.NewReader()` and a reader object can collect information from a variety of inputs
* Pass in a value of `os.Stdin`
* This means this **reader object is looking for information from standard input**.
* Underscore character `_` ignore error objects 


```
$ go run 4ftminput.go 
Enter text: on two three
on two three
```

### input numeric data: Convert string into floating number



```
fmt.Print("Enter a number: ")
	str, _ = reader.ReadString('\n') //Assign
	f, err := strconv.ParseFloat(strings.TrimSpace(str), 64)
	if err != nil {
		fmt.Println(err)
	} else {
		fmt.Println("Value of number:", f)
	}
```

* `=`: assign this value to this pre-declared type.
* `str.conv`, for string conversion, `.ParseFloat`, Convert string into floating number
* `strings.TrimSpace()` wrap the string in a call to the function Trim Space. This function will remove the white space from the beginning or the ending of the string.



```
$ go run 4ftminput.go 
Enter text: testtext
testtext

Enter a number: 12
Value of number: 12
```










