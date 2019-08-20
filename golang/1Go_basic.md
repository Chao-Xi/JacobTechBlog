# Learning Go Basic

#### Go Ancestor languages

* Based mostly on C, but it is influenced by other languages 
* Experience with C-style languages is very useful. 
  * C, C++, and C# 
  * Java 
* This course requires a basic programming vocabulary. 


## Getting started


### 1.go essential characters

#### Compiled or interpreted

* **Go is a compiled, statically typed language.** 
* **The go tool can run a file without precompiling.**
* Compiled executables are OS specific. 
* Applications have a statically linked runtime. 
* **No external virtual machine is needed.**

#### Is Go Object Oriented

**Go has some object-oriented features:**
 
* You can define custom **interfaces.** 
* Custom *types* can implement one or more *interfaces*.
* Custom *types* can have member *methods*. 
* Custom *structs* (data structures) can have member *fields*.

#### What Go `doesn't Supoort`

* Type inheritance (no classes) 
* Method or operator overloading 
* Structured exception handling 
* Implicit numeric conversions 

#### Ancestor Languages

* Go is designed as a next-gen language for C. 
* Go borrows some syntax from C. 
* It also borrows from `Pascal/Modula/Oberon` family. 
* Go tries to reduce the amount of typing. 


#### Essential Syntax rule

* Go is case sensitive. 
* Variable and package names are lower and mixed case. 
* Exported functions and fields have an initial upper-case character. 

#### Semicolons not needed (usually)

* Line feed ends a statement no semicolon required: 

```
var colors [2]string 
colors[0] = "black" 
colors[1] = "white" 
```

* Semicolons are part of the formal language spec. 
* The lexer adds them as needed. 
 
#### Code Blocks are wrapped with braces

* Code blocks are wrapped with braces
* Starting brace on same line as preceding statement:

```
package main

import "fmt"

func main() {
	sum := 0 
	for i := 0; i < 10; i++ { 
		sum += i 
	} 
fmt.Println(sum)
}
```

#### other critical chracteristic

**Built-in functions and members of builtin package:**

* len(string) — `returns the length of a string 
* panic(error) - `stops execution and displays error message` 
* recover() - `manages behavior of a panicking goroutine` 

`http://golang.org/pkg/builtin/`

## Install Go on mac

`https://golang.org/doc/install` 

Add `/usr/local/go/bin` to the PATH environment variable. You can do this by adding this line to your /etc/profile (for a system-wide installation) or `$HOME/.bash_profile`:

```
export PATH=$PATH:/usr/local/go/bin
```

## Get started Hello World


```
package main    #  The package declaration   

import (        #  The import
	"fmt"
	"strings"
)

func main() {  # The main function
	fmt.Println("Hello From Go")
	fmt.Println(strings.ToUpper("Hello from upside!"))
}
```

The basic structure of a Go package, including 

* The package declaration   
* The import
* The main function