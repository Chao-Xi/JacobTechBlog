package main

import "fmt"

type Animal interface {
	Speak() string
}

type Dog struct {
}

// function Speak is member of Dog struct
func (d Dog) Speak() string {
	return "woo "
}

type Cat struct {
}

// function Speak is member of Cat struct
func (c Cat) Speak() string {
	return "meow"
}

type Cow struct {
}

// function Speak is member of Cow struct
func (c Cow) Speak() string {
	return "moo"
}

func main() {
	corji := Animal(Dog{})
	fmt.Println(corji)
	// {} represent the object itself, which doesn't have any fields and values
	animals := []Animal{Dog{}, Cat{}, Cow{}}

	// _ is for index
	for _, animal := range animals {
		fmt.Println(animal.Speak())
	}
}
