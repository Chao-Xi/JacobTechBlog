package main

import "fmt"

type Dog struct {
	Breed  string
	Weight int
}

func main() {

	Corji := Dog{"Corji", 14}
	fmt.Println(Corji)
	fmt.Printf("%+v\n", Corji)
	fmt.Printf("Breed: %v\nWeight: %v\n", Corji.Breed, Corji.Weight)

}
