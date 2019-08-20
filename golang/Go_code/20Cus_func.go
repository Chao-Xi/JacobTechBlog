package main

import "fmt"

type Dog struct {
	Breed  string
	Weight int
	Sound  string
}

func (d Dog) Speak() {
	fmt.Println(d.Sound)
}

// func (d Dog) Speakthree() {
// 	d.Sound = fmt.Sprintf("%v %v %v!\n", d.Sound, d.Sound, d.Sound)
// 	fmt.Print(d.Sound)
// }

func (d *Dog) Speakthree() {
	d.Sound = fmt.Sprintf("%v %v %v!", d.Sound, d.Sound, d.Sound)
	fmt.Println(d.Sound)
}

func main() {
	corji := Dog{"corji", 33, "Wo"}
	fmt.Println(corji)
	corji.Speak()

	corji.Sound = "wof"
	corji.Speak()

	corji.Speakthree()
	corji.Speakthree()

}
