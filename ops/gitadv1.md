# Branch Management

* 1.Force push to remote
* 2.Identify merged branches
* 3.Delete local and remote branches
* 4.Prune stale(`remote-tracking`) branches

### Start

```
# List existing remotes 
$ git remote -v 

# Use HTTPS
$ git remote set-url https://github.com/USERNAME/REPO.git 

# Use SSH 
$ git remote set-url git@githubscom/USERNAME/REPO.git 
```

## Force push to remote

* **Why need force push?**

Our collaborator screwed things up in a really big way

```
$ git push -f
$ git push --force
```

### Force Push to a Remote 

* Use with extreme caution 
* Easy way to anger your whole development team 
* Disruptive for others using the remote branch
* Commits disappear 
* Subsequent commits are orphaned 


* 1. From **User1: Me**

```
$ git log

commit a4974b2e6413a358e8dc5f3334d799b1e77493f5 
author: KS <someone@nowhere.com> 
Date: Tue Jan 23 16:28:44 2018 -0500 

	Add to do list 

commit 1d8afcb9ec2b88bfl3c9Olaald725f26d15e7b72 
Author: KS <someone@nowhere.com> 
Date: Tue Jan 23 15:55:13 2018 -0500 
	
	Added shopping list 

commit d55bc490e301a135e095f3cb00d8bfd9bb6adebf 
Author: KS <someone@nowhere.com> 
Date: Tue Jan 23 15:22:28 2018 -0500 

	First commit 
``` 

* 2. From **User2: Collaborators**: commit some changes to the remote

```
git push 
```

* 3. **User1: Me**: fetch from remote

```
$ git fetch

remote: Counting objects: 3, done. 
remote: Compressing objects: 100% (2/2), done. 
remote: Total 3 (delta 1), reused 3 (delta 1), pack-reused 0 
Unpacking objects: 100% (3/3), done. 
From github.com:ks/demo_repo 
	a4974b2..08ab5lb master -> origin/master 
```

* I didn't pull it, I just `fetched` it so that **I'm able to inspect it but I didn't actually do a merge yet**. 
* If we had pulled it, **we would just need to do a `reset` later on to get the changes undone**. 


* 4. Check remote log

```
$ git log origin/master
commit 08ab5b45457333b863f5e9e526e45a4dad5033 
Author: KS <someone@nowhere.com>
Date: Wed Jan 24 11:11:48 2018 -0500 

	Add Seinfeld characters 

commit a4974b2e6413a358e8dc5f3334d799b1e77493f5 
author: KS <someone@nowhere.com> 
Date: Tue Jan 23 16:28:44 2018 -0500 

	Add to do list 

...
```

* 5. **User1: Me**: There is new commit, check what's going on

```
$ git show origin/master
```
**The new commit should git rid off**

We could:

* **revert this commit**
* **Delete these lines and then do a merge commit and push it back up**


* 6.Check local log, it's **unchanged** since **fetch instead of pull**

```
$ git log 

commit a4974b2e6413a358e8dc5f3334d799b1e77493f5 
author: KS <someone@nowhere.com> 
Date: Tue Jan 23 16:28:44 2018 -0500 

	Add to do list 
...
```

* 7. **Push my commit in instead of Collaborators' commit**

```
$ git push --force 
Total 0 (delta 0), reused 0 (delta 0) 
To github.com:ks/demo_repo.git 
	+ 08ab51b...a4974b2 master -> master (forced update) 
```

* 8. check remote log, remote back to normal

```
$ git log origin/master
commit a4974b2e6413a358e8dc5f3334d799b1e77493f5 
author: KS <someone@nowhere.com> 
Date: Tue Jan 23 16:28:44 2018 -0500 

	Add to do list 
```

### From Collaborators (`git reset --hard origin/master`)

```
$ git fetch 
From github.com:ks/demo_repo 
+ 08ab51b...a4974b2 master -> origin/master collaborator_version(master) (forced update) 
```

```
$ git pull 
Already up-to-date
# it's empty， since no additional commit

$  git log
# wrong commit still exists
commit 08ab5b45457333b863f5e9e526e45a4dad5033 
Author: KS <someone@nowhere.com>
Date: Wed Jan 24 11:11:48 2018 -0500 

	Add Seinfeld characters 
	
# Collaborators branch is still head origin/master
$ git status 
On branch master 
Your branch is ahead of 'origin/master' by 1 commit. 
	(use "git push" to publish your local commits) 
nothing to commit, working tree clean 

# undone Collaborators false commit
$ git reset --hard origin/master 
HEAD is now at a4974b2 Add to do lis
``` 


## Identify merged branches

### Identify Merged Branches 

I want to make sure that, **before I delete those feature branches, that they are fully merged into the branch**, and I don't accidentally delete something that has some commits that have not yet been merged in

* List branches that have been merged into a branch 
* Useful for knowing what features have been incorporated 
* Useful for cleanup after merging many features 

```
# which branch have been merged
git branch --merged 
# Give back a list of branches in our local repository which have been merged into the current branch fully

# Not been merged into the current branch
git branch --no-merged 

# It list off the remote branches that are either merged or unmerged with the current branch
git branch -r --merged 
```

### Demo

**We are on the master branh**

```
(master)$ git branch 
key_feature 
*  master 
old_topic 
```

```
(master)$ git branch --merged
*  master 
```
None branchs have been merged to master

```
(master)$ git branch --no-merged
key_feature 
old_topic 
```

**Switch to `old_topic`**

```
$ git checkout old_topic

(old_topic)$ git branch 
key_feature 
master 
*  old_topic 
```

```
(old_topic)$ git branch --merged 
master 
* old_topic

(old_topic)$ git branch --no-merged 
key_feature 
```

**Shows:**

master branch is merged into `old_topic`, but `key_feature` is not. 

**Means:**

This means that all the commits that are in master are also in `old_topic`. 

Now, it turns out that `old_topic` is a topic branch that comes off of the master branch, so it makes sense that it contains all of those. 

**The master branch has not progressed and added new commits that have not yet been incorporated to `old_topic`. Everything in master is in `old_topic`.**


**Switch to `key_feature`**

```
$ git checkout key_feature 
Switched to branch 'key_features 
Your branch is up-to-date with 'origin/key_feature' 

(key_feature)$ git branch --merged 
* key_feature 

(key_feature)$ git branch --no-merged 
master 

(key_feature) > git merge master 
Merge made by the 'recursive' strategy. 
to.do.txt | 11 +++++++++++ 
1 file changed, 11 insertions(+) 
create mode 100644 to_do.txt 
```

* There are commits that exist in master which are **not yet incorporated** into `key_feature`. 
* So since `key_feature` is a topic branch that comes off of master, we probably want to `incorporate` those. We want to get whatever new things are in `master` and incorporate them into `key_feature`

```
(key_feature)$ git branch --merged 
* key_feature 
  master
 
(key_feature)$ git branch --no-merged 
old_topic
```

* **All of the commits that are in master are now in `key_feature`**.

### Remote repository

Merge your master branch into the key_feature branch, and then push it up

```
(key_feature)$ git branch -r --merged
origin/key_feature
origin/master
```

It's comparing our **current branch**, and it wants to know, does our **current branch** have all of the **same commits** that are in the **remote branch for `key_feature` and the remote branch for `master`**?

### Identify Merged Branches 

* Use current branch by default 
* "Branches whose tips are reachable from the specified commit (HEAD if not specified)" 
* Branch tip is in the history of the specified commit 
* Can specify other branch names or commits 

```
$ git branch --merged HEAD 
$ git branch --merged july_release 
$ git branch --merged origin/july_release 
$ git branch --merged b325a7c49 
```

## Delete local and remote branches


### Remove local branch

```
# Delete branch 
# (Must be on a different branch) 
$ git branch -d new feature 

# Delete not yet merged branch 
$ git branch -D new feature 
```

### Remove remlote branch

```
# Delete remote branch 
git push origin :new_feature 
git push origin <local>:<remote> 


# Delete remote branch, v1.7.0+ 
$ git push --delete origin new_feature 



# Delete remote branch, v2.8.0+ 
$ git push -d origin new feature 
```


### Demo: delete un-merged branch

```
(master)$ git checkout -b delete_test
(delete_test) $ git commit -am "some changes"
(delete_test)$ git checkout master
(master)$ git branch -d delete_test 
error: The branch 'delete_test' is not fully merged. 
If you are sure you want to delete it, run 'git branch -D delete_test'. 

(master)$ git branch --merged
* master
# delete_test unmerged into master

(master)git branch -D delete_test
# delete the delete_test forcely
```

### Demo: delete remote branch
```
$ git push -u origin delete_test
$ git push -d origin delete_test
```

## Prune stale(remote-tracking) branches

* Delete all stale **remote-tracking branches** 
* **Remote-tracking branches, not remote branches** 
* tale branch: **a remote-tracking branch that no longer tracks anything because the actual branch in the remote repository has been deleted** 

### Remote Branches 

* Branch on the remote repository (bugfix) 
* **Local snapshot of the remote branch (`origin/bugfix`)** 
* Local branch, tracking the remote branch (**bugfix**) 


### What is `remote-tracking` branches why it's snapshot of of the remote bracnh

* It's what happens when we call **git fetch**. 
* We fetch the changes from the remote repository and we sync up our tracking branch so that the same changes are there. 
* This tracking branch can be handy because **it actually allows us to work offline, off of the origin**. 
* Even though we can't fetch or push to the remote, **we still can access the contents of what was up there**

### Features

* Deleting a remote prunes the remote-tracking branch automatically with `push -d`
* Necessary when **collaborators delete branches**
* Fetch does not automatically prune 

```
# Delete remote tacking branches 

$ git remote prune origin 
$ git remote prune origin --dry-run 
```

### Demo - User1

```
(master)$ git checkout -b prune_test
(prune_test)$ git push -u origin prune_test
(prune_test)$ git branch
...
* prune_test

(prune_test)$ git branch -r
...
origin/prune_test
```

### Demo - collaborator

```
(master)$ git branch -r
origin/master
...

(master)$ git fetch
(master)$ git branch -r
origin/master
...
origin/prune_test

# delete remote branch prune_test from collaborator
git push origin :prune_test

(master)$ git branch -r
origin/master
...
```

### Demo - User1

```
(prune_test)$ git fetch
(prune_test)$ git branch -r
origin/master
...
origin/prune_test
```

```
(prune_test) $ git remote prune origin --dry-run 
Pruning origin URL: git@github.com:ks/demo_repo.git 
	* [would prune] origin/prune_test 

(prune_test) $ git remote prune origin 
Pruning origin 
URL: git@github.com:ks/demo_repo.git 
	* [pruned] origin/prune_test 

	
(prune_test) $ git branch -r
origin/master
...

No more origin/prune_test as `remote-tracking` branches
```

### Other way to prune

* fetch way to prune automatically

```
# Shortcut: prune, then fetch 
$ git fetch --prune 
git fetch -p 

# or

git config --global fetch.prune true
```

### `git prune` is totally different from `git remote prune`


```
# Prune all unreachable objects 
# Do not need to use! 
$ git prune 

# Part of garbage collection 
git gc 
```
