package main

import "fmt"

func main() {
	// fmt.Println("Close the file!")
	defer fmt.Println("Close the file!")
	//  Each time you call the "defer" statement, it adds an instruction to a stack, and when the deferred statements are executed, they're handled in last in, first out order, known as LIFO.
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
