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
	// fmt.Printf("%T\n", values)
	return sum
}
