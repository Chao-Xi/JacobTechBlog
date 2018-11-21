# Git常用命令与GitHub使用技巧技巧整理

## 1. GitHub中同步远程分支

### Sync a fork of a repository to keep it up-to-date with the upstream repository.

### 查看本地已有分支

```
$ git remote -v
origin	https://github.com/Chao-Xi/TechBlog.git (fetch)
origin	https://github.com/Chao-Xi/TechBlog.git (push)
```

### 增加远程分支

Collaborating with issues and pull requests / Configuring a remote for a fork
 

```
$ git remote add upstream https://github.com/Chao-Xi/TechBlog.git
$ git remote -v
origin	https://github.com/Chao-Xi/TechBlog.git (fetch)
origin	https://github.com/Chao-Xi/TechBlog.git (push)
upstream	https://github.com/Chao-Xi/TechBlog.git (fetch)
upstream	https://github.com/Chao-Xi/TechBlog.git (push)
```

Fetch the branches and their respective commits from the upstream repository. Commits to `master` will be stored in a local branch, `upstream/master`.

```
$ git fetch upstream
From https://github.com/Chao-Xi/TechBlog
 * [new branch]      master     -> upstream/master
```

Check out your fork's local `master` branch.

```
$ git checkout master
Already on 'master'
Your branch is up-to-date with 'origin/master'.
```

Merge the changes from `upstream/master` into your local `master` branch. This brings your fork's `master` branch into sync with the upstream repository, **without losing your local changes.**

```
$ git merge upstream/master
# Merge the changes from upstream/master into your local master branch.
```
If your local branch didn't have any unique commits, Git will instead perform a **"fast-forward"**

## 2. 更新Git代码并对比

```
$ git remote -v
origin	https://github.com/Chao-Xi/TechBlog.git (fetch)
origin	https://github.com/Chao-Xi/TechBlog.git (push)
upstream	https://github.com/Chao-Xi/TechBlog.git (fetch)
upstream	https://github.com/Chao-Xi/TechBlog.git (push)

$ git fetch origin master
From https://github.com/Chao-Xi/TechBlog
 * branch            master     -> FETCH_HEAD

$ git log -p master.. origin/master

$ git merge origin/master
```

## 3. 删除远程分支

```
$ git push origin --delete <branchName>
$ git push origin --delete tag <tagName>
```