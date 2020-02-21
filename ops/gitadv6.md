# Track down the problems

* Log Options 
* Blame
* Bisect

## Log Options 

* Log is the primary interface to Git 
* Log has many options 
* Sorting, filtering, output formating 
* git help log 

```
# List commits as patches (diffs) 
git log -p

git log --patch


# List edits to lines 100-150
git log -L 100,150:filename.txt 
```

```
$ git log -p
commit 908774cd80634a0a82b9f8bb9d1f12413265cd3a Author: ks <someone@nowhere.com> 
Date: Thu Feb 1 16:17:01 2018 -0500 

	Specify which grapes to buy 

dff --git a/shopping.txt b/shopping.txt 
index adcc58d..ae6bf80 100644 
--- a/shopping.txt 
b/shopping.txt 
@@ -9,7 +9,7 @@ 
cereal 
12 eggs 
bacon 
orange juice 
-grapes 
+ red grapes 
  lemons 
  limes 
  lettuce 
```

```
$ git log -L 1,5:shopping.txt

...
@@ -1,5 +1,5 @@ 
...
```


## Blame

* Browse annotated file 
* Determine who changed which lines in a file and why 
* **Useful for probing the history behind a file's contents** 
* Useful for identifying which commit introduced a bug


```
# Annotate'e with commit details 
git blame filename.txt 

# Ignore whitespace 
git blame -w filename.txt 
```

```
# Annotate lines 100-150 
git blame -L 100,150 filename.txt 

# Annotate lines 100-105 
git blame -L 100,+5 filename.txt 

# Annotate file at revision d9dba0 
git blame d9dba0 filename.txt 
git blame d9dba0 -- filename.txt 
```

```
# Add a global alias for "praise" 
git config --global alias.praise blame 


# Similar to blame, different output format 
git annotate filename.txt 
```

### Demo

```
(master) $ git blame shopping.txt 
1d8pfcb9 (ks 2018-01-23 15:55:13 -0500  1) Shopping List
1d8afcb9 (ks 2018-01-23 15:55:13 -0500  2)
e24cf053 (ks 2018-01-26 10:59:25 -0500  3) red apples
8527e7ad (ks 2018-01-25 15:09:48 -0500  4) 6 bananas
e24cf053 (ks 2018-01-26 10:59:25 -0500  5) vanilla yogurt
```
```
(master) $ git blame -L 5,+3 shopping.txt 
e24cf053 (kss 2018-01-26 10:59:25 -0500 5) vanilla yogurt 
8527e7ad (ks 2018-01-25 15:09:48 -0500  6) 2% milk 
ec41a80c (ks 2018-01-25 14:52:50 -0500  7) wheat bread 
```

## Bisect

* Find the commit that introduced a bug or regression 
* **Mark last good revision and first bad revision** 
* **Resets code to mid-point** 
* Mark as good or bad revision 
* Repeat 

```
$ git bisect start 
$ git bisect bad <treeish> 
$ git bisect good <treeish> 

$ git bisect reset 
```

### `$ git bisect start `

It starts one of these bisect sessions. Then we have to **tell Git which ones are the good and bad versions**.


### `git bisect good <treeish> & git bisect bad <treeish>`

git bisect bad and you provide it a treeish:. 

* Branch name
* SHA 
* A tag 
* Blank 
* Current pointer for head.

### `$ git bisect reset `

Exit out

### Demo

**Step by step to find error code with bisect way**

```
(master) > git bisect start 
(master|BISECTING) $ git bisect bad 
(master|BISECTING) $ git bisect good 1a5aeOe 
Bisecting: 5 revisions left to test after this (roughly 3 steps) 
[e24cf053950621f542ac192b771c74ecf53cdf3f] Update shopping items 

((e24cf05...)|BISECTING) $ git bisect good 
Bisecting: 2 revisions left to test after this (roughly 2 steps) [443ea3af62f4b4845111eaf601a680e51f2b1d8c) Clarify which rice 

((443ea3a...)IBISECTING) $ git bisect bad 
Bisecting: 0 revisions left to test after this (roughly 1 step) [4611a0cb30822c1609033d9dba03a4771ddab5eb] Add clean closet to do 

((4611a0c...)IBISECTING) $ git bisect bad 
Bisecting: 0 revisions left to test after this (roughly 0 steps) 
(676da05fbflbfa7adlbaa32fa470e7ec0f4102b1] Add limes to shopping list 

((676da05...)IBISECTING) $ git bisect bad 
676da05fbflbfa7adlbaa32fa470e7ec0f4102b1 is the first bad commit commit 
676da05fbflbfa7adlbaa32fa470e7ec0f4102b1 
Author: ks <someone@nowhere.com> 
Date: Wed Jan 31 13:46:43 2018 -0500 

	Add limes to shopping list
	 
:100644 	100644 	80de87464cc2e8293bac38e53009dd884bad2212 db309960e00419988c565196c0cbc49 
7dd9efl9f M shopping.txt 
```

### Exit out

```
((676da05...)IBISECTING) $ git bisect reset 
Previous HEAD position was 676da05... Add limes to shopping list 
Switched to branch 'master' 
Your branch is ahead of 'origin/master' by 1 commit. 
	(use "git push" to publish your local commits) 
```
