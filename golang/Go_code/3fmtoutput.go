package main

import "fmt"

//:= declare /  = assign
func main() {
	str1 := "The quick red fox"
	str2 := "jumped over"
	str3 := "the lazy brown dog."
	aNumber := 42
	isTrue := true

	// fmt.Println(str1, str2, str3)
	// stringLength, err := fmt.Println(str1, str2, str3) //inferred type asignment operator
	// Whether I got non-nil error object back
	// Error equals to nil

	// fmt.Println("String Length:", stringLength)
	// # command-line-arguments
	// ./3fmtoutput.go:15:16: err declared and not used

	// if err == nil {
	// 	fmt.Println("String Length:", stringLength)
	// }

	stringLength, _ := fmt.Println(str1, str2, str3)
	fmt.Println("String Length:", stringLength)

	// fmt.Printf("Value of aNumber: %v\n", aNumber)
	// fmt.Printf("Value of isTrue: %v\n", isTrue)
	// fmt.Printf("Value pf aNumber as float: %.2f\n", float64(aNumber))

	// fmt.Printf("Data Types: %T, %T, %T, %T, and %T\n",
	// 	str1, str2, str3, aNumber, isTrue)

	myString := fmt.Sprintf("Data Types as var: %T, %T, %T, %T, and %T\n",
		str1, str2, str3, aNumber, isTrue)
	fmt.Print(myString)
}
