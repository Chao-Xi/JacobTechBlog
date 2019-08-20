package main

import "fmt"

func main() {

	//var x float64 = 42
	var result string

	if x := -33; x < 0 {
		result = "Less than zero"
	} else if x == 0 {
		result = "Equal to zero"
	} else {
		result = "Greater than 0"
	}

	fmt.Println("Result:", result)

	//  fmt.Println("Value of X:", x)
}
