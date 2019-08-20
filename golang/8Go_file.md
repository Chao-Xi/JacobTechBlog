# Go working with file

## Writing to a text file

```
package main

import (
	"fmt"
	"io"
	"io/ioutil"
	"os"
)

func main() {

	content := "Hello from GO!"

	file, err := os.Create("./25fromString.txt")
	checkError(err)
	defer file.Close()

	ln, err := io.WriteString(file, content)
	checkError(err)

	fmt.Printf("All done with file of %v characters", ln)

	bytes := []byte(content)
	ioutil.WriteFile("./25fromBytes.txt", bytes, 0644)

}

func checkError(err error) {
	if err != nil {
		panic(err)
	}
}
```

* `panic(err)`: **built-in panic function, and pass in the error object.**
* `file.Close()`: Ensures that the file will be closed 

The `WriteString` function returns the number of characters that were wrtten to the file, and potentially the error object

```
ln, err := io.WriteString(file, content)
```

* `io.WriteString`: Pass in the file and the content.

#### Convert string to a byte array

```
bytes := []byte(content)
```

#### `io/ioutil` is sub directory of the io package

WriteFile, that writes a byte array instead of a simple string

```
bytes := []byte(content)
ioutil.WriteFile("./25fromBytes.txt", bytes, 0644)
```

* `0644`: Control permissions on the file that's being written


## Reading from a text file

```
package main

import (
	"fmt"
	"io/ioutil"
)

func main() {
	filename := "./25fromString.txt"

	content, err := ioutil.ReadFile(filename)
	checkError(err)

	fmt.Println("Read from file", content)

}

func checkError(err error) {
	if err != nil {
		panic(err)
	}
}
```

* `ioutil.ReadFile()`:  **Getting back an array of bytes**

```
Read from file [72 101 108 108 111 32 102 114 111 109 32 71 79 33]
```

```
result := string(content)
fmt.Println("Read from file", result)
```
```
Read from file Hello from GO!
```

## Walking a directory tree

```
package main

import (
	"fmt"
	"os"
	"path/filepath"
)

func main() {

	root, _ := filepath.Abs(".")
	fmt.Println("Processing path", root)

	err := filepath.Walk(root, processPath)
	if err != nil {
		fmt.Println("error: ", err)
	}

}

func processPath(path string, info os.FileInfo, err error) error {
	if err != nil {
		return err
	}

	if path != "." {
		if info.IsDir() {
			fmt.Println("Directory: ", path)
		} else {
			fmt.Println("File: ", path)
		}
	}

	return nil
}
```

**Get the absolute location of this directory.`filepath.Abs(".")`**

```
root, _ := filepath.Abs(".")
```

```
func processPath(path string, info os.FileInfo, err error) error {
	if err != nil {
		return err
	}

	if path != "." {
		if info.IsDir() {
			fmt.Println("Directory: ", path)
		} else {
			fmt.Println("File: ", path)
		}
	}

	return nil
}
```

* `path string`: Represent the current directory or file name
* `info os.FileInfo`: info object and it's an instance of a structure named fileInfo that's a member of the os package
* `err error`: err error
* `info.IsDir()`: **The info object has a method named IsDir.** It returns a Boolean value, true or false.

```
err := filepath.Walk(root, processPath)
```




