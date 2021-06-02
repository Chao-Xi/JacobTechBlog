# sed命令

```
brew install gnu-sed
alias sed=gsed
```

## **p 命令，用来打印文件内容**

### **打印整个文本**，

`n` 命令，仅显示 script 处理后的结果，不加 n 命令，会把待处理的信息也输出。

```
$ sed -n p test.txt

tom likes to play football
kevin likes to eat cabbage
frank likes to drink beer
cary doesn't like smoking
```

* 打印第一行到最后一行的内容。**1表示第一行， $表示最后一行**。

```
$ sed -n "1,$"p test.txt


tom likes to play football
kevin likes to eat cabbage
frank likes to drink beer
cary doesn't like smoking
```

* **过滤带 to 的行**， 类似于 grep 命令。

```
$ sed -n "/to/"p test.txt
tom likes to play football
kevin likes to eat cabbage
frank likes to drink beer
```

* 打印匹配 kevin 开始，frank 为结束的行。

```
# sed -n "/kevin/,/frank/"p test.txt

kevin likes to eat cabbage
frank likes to drink beer
```

## s 命令，用于替换

### 将 kevin 替换成 kkk

```
$ sed  "s/kevin/kkk/g" test.txt

tom likes to play football
kkk likes to eat cabbage
frank likes to drink beer
cary doesn't like smoking
```

### 只针对第二行进行判断。

```
$ sed  "2s/kevin/xxx/g" test.txt
tom likes to play football
xxx likes to eat cabbage
frank likes to drink beer
cary doesn't like smoking
```

### 针对多行进行替换。

```
$ sed  "1,4s/kevin/xxx/g" test.txt

tom likes to play football
xxx likes to eat cabbage
frank likes to drink beer
cary doesn't like smoking
```

### 只替换第1个 to 为 tt 。

```
$ sed "s/to/tt/1" test.txt

ttm likes to play football
kevin likes tt eat cabbage
frank likes tt drink beer
cary doesn't like smoking
```

### 只替换第 2 个 to

```
$ sed "s/to/tt/2" test.txt

tom likes tt play football
kevin likes to eat cabbage
frank likes to drink beer
cary doesn't like smoking
```

###  开头加点东西(注释)

```
$ sed "s/^/\/\/ /" test.txt
// tom likes to play football
// kevin likes to eat cabbage
// frank likes to drink beer
// cary doesn't like smoking
```

### 末尾加点东西。

```
$  sed "s/$/  \/\/ comment /" test.txt
tom likes to play football  // comment 
kevin likes to eat cabbage  // comment 
frank likes to drink beer  // comment 
cary doesn't like smoking  // comment 
```

## c 命令，用于行替换

### 将第二行的内容替换 hehe。

```
$ sed "2 c hehe" test.txt
tom likes to play football
hehe
frank likes to drink beer
cary doesn't like smoking
```

###  仅仅替换有 tom 的行。

```
$ sed "/tom/c cat" test.txt
cat
kevin likes to eat cabbage
frank likes to drink beer
cary doesn't like smoking
```

## i 命令， 表示行插入

### 在第一行前面插入。

```
$ sed "1 i love you" test.txt
love you
tom likes to play football
kevin likes to eat cabbage
frank likes to drink beer
cary doesn't like smoking
```

### 在最后一行前面插入。

```
 sed "$ i love you" test.txt
 
$ sed "$ i love you" test.txt
tom likes to play football
kevin likes to eat cabbage
frank likes to drink beer
love you
cary doesn't like smoking
```

## a 命令， 用于依附

### 在第一行后依附。

```
$  sed "1 a love you" test.txt

tom likes to play football
love you
kevin likes to eat cabbage
frank likes to drink beer
cary doesn't like smoking
```

### 在最后一行后依附。

```
$ sed "$ a love you" test.txt

tom likes to play football
kevin likes to eat cabbage
frank likes to drink beer
cary doesn't like smoking
love you
```

## d 命令，删除所匹配的行

### 删除有kevin的行。

```
sed "/kevin/d" test.txt

sed "/kevin/d" test.txt
tom likes to play football
frank likes to drink beer
cary doesn't like smoking
```

### 删除第 1 行。


```
sed "1d" test.txt

$ sed "1d" test.txt
kevin likes to eat cabbage
frank likes to drink beer
cary doesn't like smoking
```


###  删除第 2-4 行。

```
 sed "2,4d" test.txt
 
  sed "2,4d" test.txt
tom likes to play football
```