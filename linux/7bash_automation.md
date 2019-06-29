# Bash Shell Scripting for Automation

* Intorduction to Linux Scripting
 *  Using debugging mode
 *  Variable Scope
* Using outside data in a Script
 * 1. positional argument
 * 2. Loading files using while read
 * 3. Load files into arrays with mapfile
 * 4. Prompt for input
 * 5. pipe data into a script
 * 6. Process shell options
* Outputting Data from a script
 * 	Saving data to files
 * Outputing to stdout and stderr
* Bash Logic
 * Conditional flow with if, then fi
 * Conditional flow with case
 * Numeric conditions
 * String condition
 * File condition
* Bash loops
 * For loop
 * while loop 


## Intorduction to Linux Scripting

### Using debugging mode

**debugging in command**

```
bash -x debugger.sh
```

##### **Turn on and off debugging mode in script**

```
#!/bin/bash
set -x
# turn on the debugging mode
for i in {1..10} ;do
    echo $i
done

# turn off the debugging mode
set +x
for i in {A..Z} ;do
    echo $i
done
```

```
set -x    # turn on the debugging mode
set +x    # turn off the debugging mode
```

### Variable Scope

#### Environmental Variable

```
$ export PATH USER LOGNAME MAIL HOSTNAME HISIZE
```

#### Exported Variable

```
VAR 10
export VAR
```

#### Variables in Scripts

#### Local variables


## Using outside data in a Script

### 1. positional argument

```
# !/bin/bash
echo '$0 is' "$0"  # Dollar sign zero is the path to the script. 
echo '$1 is' "$1"  # Dollar sign one is the first argument,
echo '$2 is' "$2"  # Dollar sign two is the second argument
echo '$@ is' "$@"  # Dollar sign @ is all arguments
echo '$* is' "$*"  # Dollar sign asterisk is also all arguments.

# Dollar sign asterisk is also all arguments. 
```

* `$0` is the path to the script. 
* `$1` is the first argument,
* `$2` is the second argument
* `$@` is all arguments
* `$*` is also all arguments.


**No arguments**

```
$ bash positional_arg.sh
$0 is 2positional_arg.sh
$1 is 
$2 is 
$@ is
$* is 
```
```
$ bash 2positional_arg.sh dog cat hose
$0 is 2positional_arg.sh
$1 is dog
$2 is cat
$@ is dog cat hose
$* is dog cat hose
```

### 2. Loading files using while read

`while_read.sh`

```
#! /bin/bash

while IFS= read -r LINE; do
  echo "$LINE"
done < "$1"
```

The command that actually reads the file and places each line into the variable named line is read.

> IFS= read

> To preserve white space at the beginning or the end of a line, it's common to specify IFS= (with no value) immediately before the read command. After reading is completed, the IFS returns to its previous value. 


```
$ bash 3while_read.sh /etc/passwd 
##
# User Database
# 
# Note that this file is consulted directly only when the system is running
# in single-user mode.  At other times this information is provided by
# Open Directory.
#
# See the opendirectoryd(8) man page for additional information about
# Open Directory.
##
nobody:*:-2:-2:Unprivileged User:/var/empty:/usr/bin/false
```

* The condition being that we have lines to read. What we're reading is the file that's redirected into the loop.
* In our case, it is $1 which is the first argument passed to our script
* `IFS= read -r` We are also changing the IFS or internal field separator to nothing, so the line won't break on spaces or other character 

[Bash read builtin command](https://www.computerhope.com/unix/bash/read.htm)

```
Use "raw input". Specifically, this option causes read to interpret backslashes 
literally, rather than interpreting them as escape characters.
```

* We're using the `-r option` which **prevents backslash interpretation**. Without this, any unescaped backslashes will be discarded. You should always use the `-r` with read in this case

**Display the file with spaces instead of colons.** To the end of the echo line append, `| sed 's/:/ /g'`.

```
#! /bin/bash

while IFS= read -r LINE; do
  # echo "$LINE"
  echo "$LINE" | sed 's/:/ /g'
done < "$1"
```

```
$ bash 3while_read.sh /etc/passwd 

nobody * -2 -2 Unprivileged User /var/empty /usr/bin/false
```


**We're going to change the IFS to colon.** 

Go into insert mode and change the while line to read 

`while IFS=: read -r user pass uid gid gecos home shell; do.`

For the echo line, we're going to change it to read `echo "$user $shell"`, and the rest we'll keep the same.

```
while IFS=: read -r user pass uid gid gecos home shell; do
  echo "$user $shell"
done < "$1"
```
```
$ bash 3while_read.sh /etc/passwd
nobody /usr/bin/false
root /bin/sh
daemon /usr/bin/false
```
We're using lower case variable names as the system already has uppercase variables named user, uid, gid, home and shell.

**We're not keeping it in RAM**, so if you want to go back to a previous line, you're out of luck


### 3.Load files into arrays with mapfile

```shell
#!/bin/bash

declare -a passarray
mapfile passarray < "$1"

echo ${passarray[@]}
```

```
$ bash mapfile.sh /etc/passwd
root:x:0:0:root:/root:/bin/bash bin:x:1:1:bin:/bin:/sbin/nologin daemon:x:2:2:daemon:/sbin:/sbin/nologin 
```

It reads lines from standard input into an indexed array variable.
 

[Bash mapfile builtin command](https://www.computerhope.com/unix/bash/mapfile.htm)

### 4.Prompt for input

```shell
#!/bin/bash

read -p "Enter your name: " username
echo "Your name is: " $username
```

```
$ bash 5prompter.sh
bash 5prompter.sh
Enter your name: jacob
Your name is:  jacob
```

#### Read Options

* `-p`: Print the string prompt, without a newline, before beginning to read.
* `-r`: Backslash is not an escape character
* `-t`: Time out reading from stdin
* `-s`: Dont echo typed chracter

We can read any input from the keyboard, for instance if we wanted to create our own custom prompt using echo we would follow it with the read line. Whatever we type in until we hit enter, will end up in the variable named car

```shell
#!/bin/bash

echo "Enter your favorite car"
read CAR
```

```
$ bash 5prompter.sh
Enter your favorite car
golf
```

#### For username and password input like normal world

```
#!/bin/bash

read -p "Enter your name: " username
read -sp "Enter your password: " password

if [ $password = "123" ] 
then
    echo "Your name is: " $username
else
    echo $password " is not correct password"
fi
```


```
$ bash 5prompter.sh
bash 5prompter.sh
Enter your name: jacob
Enter your password: Your name is:  jacob
```


### 5. pipe data into a script

```
#!/bin/bash

if [[ -p /dev/stdin ]]; then
    while IFS= read -r LINE; do
        echo "Line: $LINE"
    done
fi
```

```
$ cat /etc/passwd | bash 6pipereader.sh
Line: ##
Line: # User Database
Line: # 
Line: # Note that this file is consulted directly only when the system is running
Line: # in single-user mode.  At other times this information is provided by
Line: # Open Directory.
Line: #
Line: # See the opendirectoryd(8) man page for additional information about
Line: # Open Directory.
Line: ##
Line: nobody:*:-2:-2:Unprivileged User:/var/empty:/usr/bin/false
```

#### This will load each line into an indexed array named pipe array

```
#!/bin/bash

if [[ -p /dev/stdin ]]; then 
    while IFS= read -r LINE; do
        pipearray+=( "$LINE" )
    done
fi

echo ${pipearray[@]}
```

```
echo ${pipearray[@]}
```

`echo all info from array`

### 6.Process shell options

`7getopts.sh`

```
#!/bin/bash

while getopts ":a" opt; do
    case $opt in
        a) echo "You passed the -a option" >&2 ;;
        \?) echo "Invalid option: -$opt" >&2 ;;
    esac
done
```

**getopts** puts the option in the opt variable which is something we specify. And the case statement provides conditional branches depending on what's in opt. The possible options are presented inside the double quotes.

In our case, it's colon a, which turns off verbose errors and a is the only option.

```
$ bash 7getopts.sh -a
bash 7getopts.sh -a
You passed the -a option

$ bash 7getopts.sh -x
bash 7getopts.sh -x
Invalid option: -?
```

```
while getopts ":a:" opt; do
    case $opt in
        a) echo "You passed the -a option with the $OPTARG argument" >&2 ;;
        :) echo "Option -$opt requires an argument" >&2 ; exit 1 ;;
        \?) echo "Invalid option: -$opt" >&2 ;;
    esac
done
```

```
$ bash 7getopts.sh -a
Option -: requires an argument
```
```
$ bash 7getopts.sh -a testArg
You passed the -a option with the testArg argument
```
```
$ bash 7getopts.sh -x
Invalid option: -?
```

```
while getopts ":a:" opt; do
    case $opt in
        a) echo "You passed the -a option with the $OPTARG argument" >&2 ;;
        :) echo "Option -$opt requires an argument" >&2 ; exit 1 ;;
        \?) echo "Invalid option: -$opt" >&2 ;;
    esac
done

echo '$1 is' "$1"
```
```
$ bash 7getopts.sh -a testArg
You passed the -a option with the testArg argument
$1 is -a
```

## Outputting Data from a script

### Saving data to files

* **Overwritting a File**

```
echo "data"  > file.txt
```

* **Appending to file**

```
echo "data" >> file.txt
```

* Displaying on the screen and overwritting a File

```
echo "data" | tee file.txt
```

**tee**:  Redirect output to multiple files, copies standard input to standard output and also to any files given as arguments. This is useful when you want not only to send some data down a pipe, but also to save a copy.

#### Syntax

```  
tee [options]... [file]...
```

```
Options
   -a
   --append
        Append standard input to the given files rather than overwriting
        them.

   -i
   --ignore-interrupts'
        Ignore interrupt signals.
```

* **less** - Display output one screen at a time
* **more** - Display output one screen at a time 


```
$  ps -ax | tee processes.txt | more
 ps -ax | tee processes.txt | more
  PID TTY           TIME CMD
    1 ??        39:20.41 /sbin/launchd
   39 ??         1:16.60 /usr/sbin/syslogd
   40 ??         0:16.59 /usr/libexec/UserEventAgent (System)
   42 ??         0:16.34 /System/Library/PrivateFrameworks/Uninstall.framework/Resources/uninstalld
...
   89 ??         1:24.22 /usr/sbin/securityd -i
   90 ??         0:02.27 /System/Library/PrivateFrameworks/MobileDevice.framework/Versions/A/Resources/usbmuxd -launchd
   92 ??         3:47.45 /usr/libexec/locationd
```

* Displaying on the screen and **appending a File**

```
echo "new_data" | tee -a file.txt

data
new_data
```

* Create a temporary file

```
$tmpfile = $(mktemp -t ourscript.xxxxx)
echo "message" >> $tempfile
```

* Create unqiue fiel names with template

```
$ mktemp -t ourscript
/var/folders/xk/xqdfrnyj0h9bzm2xd7_72bdw0000gn/T/ourscript.8Cm5s7Zh
```

* create unqiue file name

```
mktemp
```

* Create unqiue directory

```
temp = $(mktemp -d)
```

```
#!/bin/bash

exec 200>/tmp/${0}-lock || exit 1
flock 200 || exit 1

while true ; do
    sleep 1
done

flock -u 200
```

```
$ bash -x lockfile.sh
```


```
$ bash -x lockfile.sh
+ exec
+ flock 200
+ true
+ sleep 1
```


### outputing to stdout and stderr

```
#!/bin/bash

echo "This part of script worked"
echo "Error: this part failed" >&2
```

`echo "Error: this part failed" >&2`

* `>` redirect standard output (implicit 1>)

* `&` what comes next is a file descriptor, not a file (only for right hand side of >)

* `2` stderr file descriptor number

```
$ bash 11scriptoutput.sh 
This part of script worked
Error: this part failed


$ bash 11scriptoutput.sh > stdout.txt 2>stderr.txt
bash 11scriptoutput.sh > stdout.txt 2>stderr.txt

$ cat stdout.txt 
This part of script worked

$ cat stderr.txt
Error: this part failed
```

## 4. Bash Logic

### Conditional flow with if, then fi

#### If conditional

```
if <condition>
then
	<run code>
fi
```

#### If, Else conditional

```
if <condition> ;then
	<run code>
else
	<run code>
fi
```

#### If, Else If, Else conditional

```
if <condition> ;then
	<run code>
elif <condition> ;then
	<run code>
else 
	<run code>
fi
```

#### Return code as a Codition

```
if grep root /etc/passwd  ;then
	<run code>
else
	<run code>
fi 
```

#### Negated return code as a Codition

```
if ! grep root /etc/passwd  ;then
	<run code>
else
	<run code>
fi 
```

#### Old and new style tests

```
if [ "$VAR"=5 ] ;then
	<run code>
fi
``` 

```
if [[ "$VAR"=5 ]] ;then
	<run code>
fi
``` 

#### Coditional Tests using `[]`

* POSIX compliant 
* Works with older shells including Bourne 
* Are commands that then test the condition 
* File name expansion and word splitting happen 
* Parameter expansion happens 
* &&, ||, <, and > operators get interpreted by the shell 

#### Conditional Tests Using `[[ ]] `

* Specific to bash and ksh 
* Does not work on older shells 
* No file name expansion between brackets 
* No word splitting between brackets 
* Parameter expansion between brackets 
* Command substitution between brackets 
* Supports `&&`, `||`, <, and > operators 
* Automatic arithmetic evaluation of octal/hexadecimal 
* Supports extended regular expression matches
* Quoting not required 

**I recommend in almost every case to use double square brackets**


### Conditional flow with case

#### Case statement

```
#!/bin/bash

read -p "Enter your Age: " AGE

case $AGE in 
         [1-9]) echo "You are under age 9 & You're quite young"  ;;
         [5-9]) echo "Time for elementary school"  ;;
        1[0-9]) echo "Time for middle school"  ;;
    [2-9][0-9]) echo "You are an adult"  ;;
             *) echo "That doesn't seem to be an age"
esac
```

```
$ bash 12casescript.sh 
Enter your Age: 29
You are an adult

$ bash 12casescript.sh 
Enter your Age: 5
You are under age 9
```

#### Action list terminator `;;&` and `;&`

* `;;&`  **Instead of exiting after the first match, it continues to process matches.**
* `;&` **Will execute next line and ignore match or not**

```
#!/bin/bash

read -p "Enter your Age: " AGE

case $AGE in 
         [1-9]) echo "You are under age 9"  ;;&
         [5-9]) echo "Time for elementary school"  ;;
        1[0-9]) echo "Time for middle school"  ;&
    [2-9][0-9]) echo "You are an adult"  ;;
             *) echo "That doesn't seem to be an age"
esac
```

##### `;;&` match

```
$ bash casescript.sh
Enter your Age: 5
You are under age 9
```

##### `;&` doesn'y match

```
$ bash casescript.sh
Enter your Age: 18
Time for middle school
You are an adult
```

### Numeric conditions

#### Numeric comparison opearators

* `if [[ 1 -lt 5 ]]`
* `if [[ 1 -gt 5 ]]`
* `if [[ 1 -eq 5 ]]`
* `if [[ 1 -le 5 ]]`
* `if [[ 1 -ge 5 ]]`

Not numeric comparison operators

* `if [[ 1 > 5 ]]`
* `if [[ 1 < 5 ]]`
* `if [[ 1 = 5 ]]`


#### New bash integer math

```
let a =" 17+23 "
a =$(expr 17+23 )
a =$[17+23]

((a=17+23))
a=$((17+23))
```

```
#!/bin/bash

if (($1 > $2)) ;then
    echo "The first argument is larger than the second"
else
    echo "The second argument is larger than the first"
fi

sum=$(($1+$2))

if [[ "$sum" -ge 10 ]] ;then
    echo "The sum of the first two argument is greater than or equal to 10"
else
     echo "The sum of the first two argument is less than 10"
fi
```

```
$ bash 13bashinteger.sh 7 5
The first argument is larger than the second
The sum of the first two argument is greater than or equal to 10
```

### String condition

#### String comparisons

`if [[ dog = cat ]]`

 
#### Comparing Numbers as strings

`if [[ 4=4 ]]`

#### Zero Length

`if [ -z $Var ]]`

#### Not zero length

`if [[ -n $Var ]]`

#### E	quality

`if [[ dog = cat ]]`

#### Inequality

`if [[ dog != cat ]]`


### File condition

* `-e` if the file exists 
* `-f` if a file exists and is a file 
* `-d` if a file exists and is a directory 
* `-c` if a file exists and is a character device 
* `-b` if a file exists and is a block device 
* `-p` if a file exists and is a pipe 
* `-S` if a file exists and is a socket 
*  `-L` if a file exists and is a symbolic link 
*  `-g` if a file exists and has the SGID bit set 
*  `-u` if a file exists and has the SUID bit set 
*  `-r` if a file exists and is readable by the current user 
*  `-w` if a file exists and is writable by the current user 
*  `-x` if a file exists and is executable by the current user 
*  `-s` if a file exists and has a size larger than 0 bytes 
*  `-nt` if a file is newer than another 
*  `-ot` if a file is older than another 
*  `-ef` if two files have the same inode numbers 

```
#!/bin/bash
FILE="$1"
 
if [ -f "$FILE" ];
then
   echo "File $FILE exist."
else
   echo "File $FILE does not exist" >&2
fi
```
```
$ bash 14filecondition.sh ../README.md
File ../README.md exist.

$ bash 14filecondition.sh ../README1.md
File ../README1.md does not exist
```

## Bash Loop

### for loop

#### For loop Syntax

```
for item in <list>; do
	<work on $item>
done
```

#### Static List

```
for item in 1 2 3 4 5 ;do 
	echo "$item" 
done
```

#### Dynamatic List using seq

**Seq**: seq command in Linux is used to generate numbers from **FIRST** to **LAST** in steps of **INCREMENT**.

```
for item in $(seq 1 10) ;do
	echo "$item"
done
```

#### Dynamatic List using parameter expansion

```
for item in {1..10} ;do
	echo "$item"
done
```

#### Dynamatic List using command substitution

```
for item in $(find /etc) ;do
	echo "$item"
done
```

```
$ bash 16forloop.sh 
/etc
```

#### Modified IFS

```
OLDIFS = "$IFS"
IFS =$'\n'

for file in $(find /etc) ;do
	echo "$file"
done

IFS = "$OLDIFS"
```

#### List from an array

```
OLDIFS = "$IFS"
IFS =$'\n'

for file in ${array[@]} ;do
	echo "$file"
done

IFS = "$OLDIFS"
```

#### Loop through array indices

```
#!/bin/bash
array = (one two three)
for i in $(seq 0 $(( ${#array[@] - 1 )) ) ;do
	echo "${#array[$i]}"
done
```

### While loop 

#### while loop syntax

```
while [ condition ] ; do
	<do stuff>
done 
```

```
#!/bin/bash

for item in {1..100}; do
    if [[ $item = 100 ]] ;then
        echo "Ha it is the time"
        break;
    fi
done
```

#### while infinte loop

```
while true; do
	if [[ <condition> ]] ;then
		brak;
	fi
done
```

#### while loop with condition


```
#!/bin/bash

i='0'

while [[ $i -lt 4 ]] ;do
	echo ”$i is still less than 4“
    ((i++))
done
```

```
bash 17whileloop.sh 
”0 is still less than 4“
”1 is still less than 4“
”2 is still less than 4“
”3 is still less than 4“
```

#### while read loop

```
#! /bin/bash

while IFS= read -r LINE; do
  echo "$LINE"
done < "$1"

```
