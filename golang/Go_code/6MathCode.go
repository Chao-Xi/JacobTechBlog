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
