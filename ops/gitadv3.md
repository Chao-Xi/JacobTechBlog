# Interactive Staging

* Interactive Mode
* Patch Mode
* Split a hunk `s`
* Edit a hunk  with `e` option mamually change

## Interactive Mode

### Interactive Staging 

* Stage changes interactively  
* Allows staging portions of changed files 
* Helps to make smaller, focused commits 
* Feature of many Git GUI tools 

```
$ git add --interactive
$ git add -i
```

### Demo

**There some un-commit changes**

```
(master) $ git status 
On branch master
Your branch is up-to-date with 'origin/master'. 
Changes not staged for commit: 
	(use "git add <file>..." to update what will be committed) 
	(use "git checkout -- <file>..." to discard changes in working directory) 
	
	modified: README.md
	modified: shopping.txt
	modified: to_do.txt
Untracked files: 
	(use "git add <file>..." to include in what will be committed) 
	
	party_invites.txt 
no changes added to commit (use "git add" and/or "git commit -a") 
```

### interactive update 

```
(master) $ git add -i
		staged      	unstaged path
	1: unchanged 	  	+1/-2 README.md 
	2: unchanged 	  	+1/-2 shopping.txt 
	3: unchanged 	  	+1/-0 to.do.txt 

*** Commands ***
  1: status	  2: update	  3: revert   4: add untracked
  5: patch	  6: diff	  7: quit	  8: help
What now> s (1)
	staged      	unstaged path
	1: unchanged 	  	+1/-2 README.md 
	2: unchanged 	  	+1/-2 shopping.txt 
	3: unchanged 	  	+1/-0 to.do.txt 
...
What now> u     (check update)
	staged      		unstaged path
	1: unchanged 	  	+1/-2 README.md 
	2: unchanged 	  	+1/-2 shopping.txt 
	3: unchanged 	  	+1/-0 to.do.txt 
Update>> 1
	staged      		unstaged path
*	1: unchanged 	  	+1/-2 README.md 
	2: unchanged 	  	+1/-2 shopping.txt 
	3: unchanged 	  	+1/-0 to.do.txt 
Update>> 3
	staged      		unstaged path
*	1: unchanged 	  	+1/-2 README.md 
	2: unchanged 	  	+1/-2 shopping.txt 
*	3: unchanged 	  	+1/-0 to.do.txt
Update>> (enter)
updated 2 paths
What now> s   (check status)
		staged      	unstaged path
  1: +1/-2	  	       nothing  README.md 
  2: unchanged 	  	  +1/-2 shopping.txt 
  3: +1/-0 	  	    nothing  to.do.txt
```

### interactive `revert` 

```
What now> r   (revert)
	staged      	unstaged path
  1: +1/-2	  	       nothing  README.md 
  2: unchanged 	  	  +1/-2 shopping.txt 
  3: +1/-0 	  	    nothing  to.do.txt
Revert>> 1
			staged      	 unstaged path
*    1: 	+1/-2	  	    nothing  README.md 
  	 2: 	unchanged 	   	+1/-2 shopping.txt 
  	 3: 	+1/-0 	  	    nothing  to.do.txt
Revert>> (enter)
reverted one path
What now> s
		staged      		unstaged path
   	1: unchanged 	  	+1/-2   README.md 
	2: unchanged 	  	+1/-2   shopping.txt 
	3: +1/-0  	  		nothing to.do.txt
```

### interactive `add untracked` 

```
What now> a 
	1: party_invites.txt 
Add untracked» 1 
* 1: party.invites.txt 
Add unttocked>> 
added one path 
```

### interactive `diff`

```
What now> d 
	staged 			 unstaged path 
	1: +8/-0         nothing party_invites.txt 
	2: +1/-0 		 nothing to_do.txt 
Review diff> 2 
...
``` 

### Check final result

```
(master) > git status 
On branch master 
Your branch is up-to-date with 'origin/master'.
Changes to be committed: 
	(use "git reset HEAD <file>..." to unstage) 
	new file: modified: 
	party_invites.txt to_do.txt 

Changes not staged for commit: 
	(use "git add <file>..." to update what will be committed)
	(use "git checkout -- <file>..." to discard changes in working directory) 
	
	modified: modified: 
	README.md shopping.txt 
```

## Patch Mode

### Patch Mode 

* Allows staging portions of a changed file (part of file)
* "Hunk": an area where two files differ 
* Hunks can be staged, skipped, or split into smaller hunks 

### Demo: Patch Mode in interactive mode

```
(master) > git add -i 
		staged 			unstaged path 
	1: unchanged 	+1/-2 README.md 
	2: unchanged 	+3/-2 shopping.txt 
	
What now> 5 
	staged 			unstaged path 
	1: unchanged 	+1/-2 README.md 
	2: unchanged 	+3/-2 shopping.txt 

Patch update>> 2
	staged 		unstaged path 
	1: unchanged 	+1/-2 README.md 
*	2: unchanged 	+3/-2 shopping.txt 

Patch update>> 
diff --git a/shopping.txt b/shopping.txt 
index e7c5dab..5e69d04 100644 
--- a/shopping.txt 
+++ b/shopping.txt 
@@ -1,12 +1,12 @@ 
Shopping List 

-apples 
+red apples 
bananas y
ogurt 
milk 
bread 
cereal 
-eggs 
+12 eggs 
bacon 
orange 
juice 
grapes 
Stage this hunk? n (no)
ice cream
sugar
flour
+butter
Stage this hunk? y (yes)

what now> s 
		staged 			unstaged path 
	1: unchanged 	+1/-2 README.md 
	2: +1/-0		+2/-2 shopping.txt 

# One line add to stage
# two lines stay in unstaged
```

### the difference in the files that are in our staging area versus what's in our HEAD.

```
(master) > git diff --cached 
dif --git a/shopping.txt b/shopping.txt 
index e7c5dab..478eff1 100644 
--- a/shopping.txt 
+++ b/shopping.txt 
@@ -17,4 +17,5 @@ soup 
ice cream 
sugar 
flour 
+butter 
```

### Patch mode not in interactive mode

```
$ git add --patch 
$ git add -p 

$ git stash -p 
$ git reset -p 
$ git checkout -p 
$ git commit -p 
```

### Demo: Patch Mode in normal mode `git add -p shopping.txt`

```
(master) > git add -p shopping.txt 

diff --git a/shopping.txt b/shopping.txt 
index 478eff1..5e69d04 100644 
--- a/shopping.txt 
+++ b/shopping.txt 
@@ -1,12 +1,12 @@ 
Shopping List 

-apples 
+red apples 
bananas 
yogurt 
milk 
bread 
cereal 
-eggs 
+12 eggs 
bacon 
orange 
juice 
grapes 
Stage this hunk? 
```

## Split a hunk

**A hunk can contain multiple changes and it can seem sometimes arbitrary how Git decides which changes get put into each hunk.**

Sometimes we want those changes to be split up so that we can stage only a portion of that hunk. 

* Hunks can contain multiple changes 
* Tell Git to try to split a hunk further 
* Requires one or more unchanged lines between changes 


### Demo: split the hunk

```
Patch update>> 2 
		staged 		unstaged path 
	  1: unchanged   +1/-2 README.md 
    * 2: unchanged  +6/-4 hopping.txt 
Patch update>> 
diff --git a/shopping.txt b/shopping.txt 
index 478effl..c5e5bc3 100644 
--- a/shopping.txt 
+++ b/shopping.txt MD 
@@ -1,12+1,12 @@
MD Shopping List 

-apples 
+red apples 
bananas 
yogurt milk 
-bread 
+wheat 
bread 
cereal 
-eggs 
+12 eggs 
bacon 
orange 
juice 
grapes 

Stage this hunk? s (split)
Split into 3 hunks. 
Shopping List 
-apples 
+red apples 
bananas 
yogurt 
milk 
Stage this hunk? n 

bananas 
yogurt milk 
-bread 
+wheat 
cereal 
Stage this hunk? y

cereal 
-eggs 
+12 eggs 
bacon 
orange 
juice 
grapes
Stage this hunk? n

sugar
flour
butter

+ coffee
+ tomatoes
+ pear
Stage this hunk? y (no more `s` in this options)
```
### Check which parts already added into stage

```
What now> d 
		staged  unstaged path 
	1: +4/-2  +2/-2   shopping.txt 

Review diff>> 1 
diff --git a/shopping.txt b/shopping.txt 
index 478effl..6163ea8 100644 
--- a/shopping.txt 
+++ b/shopping.txt 
@@ -4,7 +4,7 @@ 
apples 
bananas 
yogurt 
milk 
-bread 
+wheat bread 
cereal 
eggs 
bacon 
@@ -18,4 +18,6 @@ 
ice cream 
sugar 
flour 
butter 
+coffee 
+tomatoes 
+pears 
```

```
git diff cached
diff --git a/shopping.txt b/shopping.txt 
index 478effl..6163ea8 100644 
--- a/shopping.txt 
+++ b/shopping.txt 
@@ -4,7 +4,7 @@ 
apples 
bananas 
yogurt 
milk 
-bread 
+wheat bread 
cereal 
eggs 
bacon 
@@ -18,4 +18,6 @@ 
ice cream 
sugar 
flour 
butter 
+coffee 
+tomatoes 
+pears 
```

## Edit a hunk  with `e` option mamually change

* Can edit a hunk manually 
* Most useful when a hunk cannot be split automatically 
* Diff-style line prefixes: `+, -, #, space `


```
-apples 
-bananas 
-yogurt 
-milk 
+red apples 
+6 bananas 
+vanilla yogurt  
+2% milk 
 wheat bread 
 cereal 
Stage this hunk? e
```

* No more `s` option left use `e`

**Manually edit hunk**

```
# Manual hunk edit mode -- see bottom for a quick guide 
@@ -1,8 +1,8 @@ 
Shopping List 

-apples 
-bananas 
-yogurt 
-milk 
+red apples 
+6 bananas 
+vanilla yogurt 
+2% milk 
 wheat bread 
 cereal 

# ---
# To remove '-' tines, make them " tines (context). 
# To remove '+' lines, delete them. 
# Lines starting with # will be removed. 
# 
# If the patch applies cleanly, the edited hunk will immediately be 
# marked for staging. If it does not apply cleanly, you wilt be given 
# an opportunity to edit again. If all lines of the hunk are removed, 
# then the edit is aborted and the hunk is left unchanged. 
```