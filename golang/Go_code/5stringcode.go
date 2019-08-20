package main

import (
	"fmt"
	"strings"
)

func main() {
	str1 := "An implicity typed string"
	fmt.Printf("str1: %v:%T\n", str1, str1) //v% is verb T% is Type
	str2 := "An explicity typed string"
	fmt.Printf("str2: %v:%T\n", str2, str2) //v% is verb T% is Type

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
