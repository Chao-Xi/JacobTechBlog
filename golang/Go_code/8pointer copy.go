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

	fmt.Println(&v)
	fmt.Println(*p)

	var value1 float64 = 44.32
	pointer1 := &value1
	fmt.Println("value 1:", *pointer1)

	*pointer1 = *pointer1 / 2
	fmt.Println("Value 1: ", *pointer1)
	fmt.Println("Value 1: ", value1)
}
