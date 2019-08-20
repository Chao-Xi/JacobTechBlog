# Essential Go skills

## go help

```
Usage:

	go <command> [arguments]

The commands are:

	bug         start a bug report
	build       compile packages and dependencies
	clean       remove object files and cached files
	doc         show documentation for package or symbol
	env         print Go environment information
	fix         update packages to use new APIs
	fmt         gofmt (reformat) package sources
	generate    generate Go files by processing source
	get         download and install packages and dependencies
	install     compile and install packages and dependencies
	list        list packages or modules
	mod         module maintenance
	run         compile and run Go program
	test        test packages
	tool        run specified go tool
	version     print Go version
	vet         report likely mistakes in packages
```

## go packages


### 1. gofmt

fmt package, which has all of the functions for formatting and outputting strings.

```
gofmt
```

```
$ gofmt 2badformatting.go
```

Notice that the main function's code is now indented, but if I go back to Visual Studio code and I close the file and open it again, I will see that nothing's actually changed in the file itself.


```
gofmt -w 2badformatting.go 
```

This will write a `indent` and `reformatted code` into the original file  permanently


### 2.gobuild

`gobuild`

compile packages and dependencies and **generate a executable file**

```
$ go build 2badformatting.go
$ ls -lah
-rwxr-xr-x  1 i515190  staff   2.0M Jul 11 15:18 2badformatting
-rwxr-xr-x@ 1 i515190  staff   432B Jul 11 15:01 2badformatting.go
```

### 3.goinstall

`goinstall`

```
$ go install
go install: no install location for directory /Users/i515190/Devops_sap/go_basic/Go_code outside GOPATH
        For more details see: 'go help gopath'
```

**If you type that command without any other information, you'll get this message asking you to type the command go help gopath.** 

**The install command is recommended for compiling more complete applications, but it requires a special directory structure and an environment variable**


       