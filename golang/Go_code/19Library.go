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
