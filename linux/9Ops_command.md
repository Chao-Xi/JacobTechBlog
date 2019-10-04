# Ops Terminal Common Commands

* `Crontab` job
* `find` Command
* `Curl` Command
* `grep` command

## 1. Cron job

[https://crontab.guru/](https://crontab.guru/)

### List all currently running job

```
$ crontab -l
no crontab for vagrant
```

### Add new Cron job

```
$ crontab -e
no crontab for vagrant - using an empty one
crontab: no changes made to crontab
```

### Template for crontab

```
# ┌───────────── minute (0 - 59)
# │ ┌───────────── hour (0 - 23)
# │ │ ┌───────────── day of month (1 - 31)
# │ │ │ ┌───────────── month (1 - 12)
# │ │ │ │ ┌───────────── day of week (0 - 6) (Sunday to Saturday;
# │ │ │ │ │                                       7 is also Sunday on some systems)
# │ │ │ │ │
# │ │ │ │ │
# * * * * *  command_to_execute
```

### Examples for crontab

* Every minute

```
* * * * * echo 'Hello' >> $HOME/temp/test.txt
```

* 0 minutes , 0 hour => midnight
* 1st day, 15th day of every month
* `At 00:00 on day-of-month 1 and 15`.

```
0 0 1,15 * *
```

* Every 10 minutes

```
*/10 * * * *
```

* At minute 0 past every 6th hour

```
0 */6 * * * 
```

* At minute 0 past every hour from 0 through 5

```
0 0-5 * * *
```

* At 12:00 in every month from May through August

```
0 12 * 5-8 * 
```

* 30 minute Mon-Fri 9am-5pm
*  At every 30 minute past every hour from 9 through 17 on every day-of-week from Monday through Friday

```
*/30 9-17 * * 1-5
```

### Sample crontab

* empty temp folder every Friday at 5pm

```
0 5 * * 5 rm -rf /tmp/*
```

* Backup images to Google Drive every night at midnight

```
0 0 * * * rsync -a ~/Pictures/ ~/Google\ Drive/Pictures/
```

### Change crontab user

* Use user2

```
crontab -u user2 -e 
```

* sudoer

```
sudo crontab -l 
```

## 2. find Command

```
$ find .
$ find temp/
```

### `-type`

* d is directory, find all directory

```
find . -type d
```

* f is file, return all file

```
find . -type f
```

### special name: `-name`

```
find . -type f -name "loop.sh"
./loop.sh
```

* **Use asterisk as wildcard** 

```
find . -type f -name "*sh"
```

####  `name` is case sensitive

#### `iname` is case insensitive

```
find . -type f -iname "*sh"
```

### modified Minute and modified time

#### Minutes

* Find modeifed time less than 10 minutes

```
find . -type f -mmin -10
```

* Find modeifed time more than 10 minutes

```
find . -type f -mmin +10
```

* Find modeifed time more than 1 minute and less tha 10 minute

```
find . -type f -mmin +1 -mmin -10
```

#### Days

*  Find modeifed time less than 20 day

```
find . -type f -mtime -20
```

* Find modeifed time more than 20 day

```
find . -type f -mtime +20
```

* `amin` `atime` for access minute and access time
* `cmin` `ctime` for changed minute and changed time

#### Size

* bigger than 5m

```
find . -size +5M
```

#### Permission

* Find by permission

```
find . -perm 755
```

#### Exec

* Change all files group and users in dir

```
find temp -exec chown vagrant:vagrant {} +
```

* `{}` is for all the result
* `+`: optional `\;` 
* `-exec rm -rf {} \;` : Delete all files matched by file pattern.


#### Change mode

```
find . -type f -exec chmod 664 {} +
```

#### Find before delete like dryrun before execution

```
$ find temp -type f -name "*.txt"
$ find temp -type f -name "*.txt" -maxdepth 1
```


## 3. `grep` command

```
$ grep "string" file
```

### Options

* `-w` : output the whole word
* `-i` : case senstive
* `-n` : output line number
* `-B` num: Output number of lines **before** the word
* `-A num`: Output number of lines **after** the word
* `-C num`: Output number of lines **around** the word
* `./*` : Find the string in all files inside the directory 
* `-r (./ is ok)`: recursive search
* `-l` : only return the file contain the word
* `-c`: output the number of files contain the word

#### output line number

```
$ grep  -win "echo" color.sh
2:echo  -e '\033[34;42mColor Text\033[0m'
7:echo -e $flasherd"ERROR: "$none$red"Something went wrong."$none
8:echo -e "\033[5;31;40mERROR: \033[31;40mSomething went wrong again.\033[31;0m"
```

#### Output number of lines **after** the word

```
$ grep -win -A 4 "bin" condition.sh
1:#!/bin/bash
2-
3-if (($1 > $2)) ;then
4-    echo "The first argument is larger than the second"
5-else
```

#### Output number of lines **around** the word

```
$ grep -win -C 2 "ge" condition.sh
8-
9-sum=$(($1+$2))
10:if [[ "$sum" -ge 10]];then
11-    echo "The sum of the first two argument is greater than or equal to 10"
12-else
```

#### Find the string at all files inside the directory

```
$ grep -win "if" ./*
./condition.sh:3:if (($1 > $2)) ;then
./condition.sh:10:if [[ "$sum" -ge 10]];then
```

#### Recursive search inside dir

```
$  grep  -winr "if" ./
./condition.sh:3:if (($1 > $2)) ;then
./condition.sh:10:if [[ "$sum" -ge 10]];then
```

#### Only return the file contain the word

```
$  grep -wirl "if" .
./condition.sh
```

#### Output the number of files contain the word

```
$ grep -wirc  "if" .
./mapfile.sh:0
./lockfile.sh:0
./casescript.sh:0
./condition.sh:2
./loop.sh:0
./sub.sh:0
./comp.sh:0
./color.sh:0
./array.sh:0
./for.sh:0
./input.sh:0
```

#### Use regular expression on linux

```
grep -P "\d{3}-\d{3}-\d{4}" names.txt
```

### On mac

```
brew install grep --with-default-names

grep -P "\d{3}-\d{3}-\d{4}" names.txt 
```

## Curl Command

#### output reponse header `-i`

```
curl -i url
```

#### Send post data to url api  `-d`

```
curl -d "data" url
```

#### Put method `-X PUT`

```
curl -X PUT -d  "data" url 
```

Send put request to url api

#### Send delete request to url api  `-X DELETE`

```
curl -X DELETE url
```

#### Input username and password

```
curl -u username:password url 
```

#### download from url

```
curl -o test.jpg url 
```

## How To Use The rsync Command 

```
rsync Oringinal/* Backup/
```

#### Recursively copy `contents` from Oringinal to backup

```
rysnc -r  Oringinal/ Backup/
```

#### Recursively copy `dir` Oringinal to backup

```
rysnc -r  Oringinal Backup/
```

* `-a, --archive` : archive mode;
* `-n, --dry-run` : perform a trial run with no changes made
* `-v, --verbose` : increase verbosity
* `--delete` : **delete extraneous files from destination dirs**


```
rsync -av --dry-run Oringinal/ Backup/
```

```
rsync -av --dry-run --delete Oringinal/ Backup/
```


* `-z, --compress`              compress file data during the transfer
* `-P`                          same as `--partial --progress`

#### Sync Remotely

```
$ rsync -zaP  Oringinal/  vagrant@192.168.33.10:/home/vagrant/
$ rsync -zaP  vagrant@192.168.33.10:/home/vagrant/ Oringinal/  
```