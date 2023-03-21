# **跟踪项目代码进度 Git Submodules**

在项目开发过程中，我们可能会有跨项目合作，或者项目组内部多个subgroup之间的协作，以及社区各个开源项目之间的引用，这时候repo需要有一种机制能够引用，跟踪对应的项目；submodule就是git提供的一种项目引用和跟踪的机制；基于此对引用的上游项目也可以进行很容易的进行自定义的修改，合并和推送；

## 1 新增submodule

如下，通过`git submodule add` 命令在`git-test`的项目中跟踪另一个项目draw_io；最后的路径表示`submodule`项目存放的路径，不填和`git clone`一样，会在当前目录创建repo同名的目录来存放；

```
git submodule add git@github.com:test/draw_io.git submodules/draw_io
```

执行完上述`submodule add`命令后，可以查看本地仓库的变化如下：

```

$git status
On branch master
Your branch is up to date with 'origin/master'.

Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

        new file:   .gitmodules
        new file:   submodules/draw_io
```


我们可以看到当前仓库的已经多了两个文件`.gitmodules`和`submoudles/draw_io`，且这「两个文件已经被自动加入了stage区域」；

* 其中：`.gitmodules`文件是`git`仓库用来管理所有跟踪的submodule的基本信息，主要是跟踪仓库地址和本地存放路径的一个映射（当然可以配置其他信息，后面会说），注意：**.gitmodules文件是归本仓库进行版本控制的**；

`.gitmodules`内容如下：

```
$cat .gitmodules 
[submodule "submodules/draw_io"]
        path = submodules/draw_io           // 存放路径
        url = git@github.com:test/draw_io.git   // submodule的url地址
```

* 其中另外一个变化：`submodules/draw_io`在本地是`add submodule`后，clone下来的跟踪的项目`draw_io`的仓库；「但为什么上面git status提示的是他是一个new file呢」？下面研究一下原因：

我们先把submodule的变更进行提交：

```
$git commit -m 'init submodule' .
[master 4894d7d] init submodule
 2 files changed, 4 insertions(+)
 create mode 100644 .gitmodules
 create mode 160000 submodules/draw_io
```

然后查看提交的内容如下：

```
$git show 4894d7d
commit 4894d7dbde107741a0956bc018ad1e6ec1ca80b3 (HEAD -> master)
Author: test <anonym_alias@163.com>
Date:   Thu May 12 15:31:43 2022 +0800

    init submodule

diff --git a/.gitmodules b/.gitmodules
new file mode 100644
index 0000000..df23d83
--- /dev/null
+++ b/.gitmodules
@@ -0,0 +1,3 @@
+[submodule "submodules/draw_io"]
+       path = submodules/draw_io
+       url = git@github.com:test/draw_io.git
diff --git a/submodules/draw_io b/submodules/draw_io
new file mode 160000
index 0000000..9b5dcda
--- /dev/null
+++ b/submodules/draw_io
@@ -0,0 +1 @@
+Subproject commit 9b5dcdac92b0d0e07264ae22267814fd052d4560
```

我们可以看到`submodules/draw_io`提交的内容是此跟踪项目的最新的`commitid`；所以我们得知，「**对于submodule管理的模块，会将`.gitmodules`映射的本地存储路径进行忽略，将其最新的`commitid`作为文件内容在主仓库中进行跟踪管理**」

## 2. 更新submodule

* 拉取submodule子项目最新的提交，如果子项目对应的分支上有更新，那么会拉取下来，并且修改主项目跟踪的改子项目的commitid；这种情况一般是：「**明确需要跟踪子项目的特定提交，使用其新特性**」；
* 拉取项目中跟踪的submodule的commitid对应的数据到本地；这种情况一般都是「**项目的开发者拉取submodule是否有跟踪的变化，更新一下对应的数据**」；

### 2-1 更新submodule最新的提交

默认情况下，在主仓库的根目录下，**执行git pull命令并不会主动更新submodule最新的commit**；

**可以通过`git submodule update --remote`拉取跟踪的最新的远端分支到本地**，如下：


```
$git submodule update --remote
...
From github.com:test/draw_io
   9b5dcda..26b9e31  master     -> origin/master
Submodule path 'submodules/draw_io': checked out '26b9e31e0367c16894910f3ebce4e2d334a812da'

$git status
...
Changes not staged for commit:
    ...
        modified:   submodules/draw_io (new commits)
```

更新`submodule`后，主仓库里面可以发现跟踪的`submodules/draw_io`已经发生了变化；此时可以将最新的跟踪仓库的commitid的变化进行提交；这样项目就刷新了最新跟踪的`submodule`信息；我们此时看一下跟踪项目本地目录的状态：

```
$git status
HEAD detached at 117e833
nothing to commit, working tree clean
```

「**为什么跟踪的submodule本地项目变成了detached状态呢**」？这里看一下`git submodule update`命令的`man`，简单说一下；

命令`git submodule update`更新子项目的策略有三种：

* `checkout`方式：子项目`checkout`到`detached`的分支，然后在`detached`分支上更新远端的提交；「**默认选项**」；
* `rebase`方式：将子项目本地分支上的提交在远端最新的提交上进行`rebase`；
* `merge`方式：将子项目远端分支的提交本merge到子项目本地分支上；

submodule更新策略的选择有两种方式：

* update命令执行时设置：`git submodule update --remote --rebase`;
* 修改`.gitmodules`文件，默认采用某种策略更新`git config -f .gitmodules submodule.submodules/draw_io.update rebase`，然后将变动的.gitmodules文件提交到主项目中


### 2-2 更新跟踪的commit对应的submodule最新数据

上面介绍的是更新跟踪的子项目的分支上最新的提交，「**一般在开源项目中都不会去执行`--remote`更新**」，只有需要引用子项目的特定特性的时候才会去主动更新；

一般涉及到submodule的更新都是进行`git submodule update`更新仓库中跟踪的commit对应的子项目的数据；

那么「**有没有什么方式在仓库跟踪的子项目的commitid发生变化时，不用每次都`git submodule update`来拉取子项目最新数据呢**」；

有两种方式可以在主仓库`git pull`的时候自动根据最新跟踪的commitid来刷新跟踪的子仓库数据：

* **通过`git pull --recurse-submodules`拉取跟踪commit的子项目的数据**；
* 通过`git config --global submodule.recurse true`来配置，该配置在「Git 2.15」引入，意思是「对所有主仓库的git操作都同样对跟踪的子仓库生效」，注意这里对`git clone`无效，需要在clone后的仓库中的操作；
    * 在「Git 2.34（Q4 2021）」版本开始，如果`git clone --recurse-submodules`拉取的仓库，那么默认`submodule.recurse`会被设置为`true`，这是针对社区开发者对submodule使用反馈和统计后做的一个优化；具体可以参考这里；


### 2-3 跟踪submodule特定分支

默认`submodule`在初始化的时候，跟踪的是子项目的默认分支，一般都是master，如果想跟踪特定分支的话，有两种方式：

* 在`git submodule add -b branch_name xxx`初始化的时候指定特定的分支；
* 在仓库中执行`git config -f .gitmodules submodule.submodules/draw_io.branch develop`;「**更新某个submodule跟踪的分支名；这种在基于版本发布的项目中会更常见**」，如下：

```
$git config -f .gitmodules submodule.submodules/draw_io.branch develop
$git status
On branch develop
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

        modified:   .gitmodules
```
跟踪`draw_io`的develop分支，执行完修改后`.gitmodules`发生变化，如下：

```
 [submodule "submodules/draw_io"]
        path = submodules/draw_io
        url = git@github.com:test/draw_io.git
+       branch = develop    
```

然后执行`git submoudle update --remote`就可以刷新主仓库跟踪的`commiti`d到分支的最新提交上面；


当然，如果想跟踪submodule的某个分支的某个提交，可以在跟踪到改分支后，在对应的submodule的本地目录中，**将子项目reset到特定的分支，然后提交要跟踪的commitid就可以了**；

这里需要注意的是：在主项目的特定分支跟踪submodule的特定分支后，在「Git 2.34（Q4 2021）」版本之前，如果没有设置`git config --global submodule.recurse true`，那么「**在主项目切换不同分支的时候，submodule不会自动切换过去**」，这会导致主项目在分支切换的时候跟踪的submodule发生修改，需要手动进行submodule分支的切换；所以根据「**不同版本需要进行不同的修复方案**」，如下：

* 「Git 2.15」之前，需要在切换主项目分支的时候，手动切换跟踪的submodule的分支，命令git submodule foreach git checkout branch_name，这个方式所有版本都可以使用；
* 「Git 2.15」及以后，直到「Git 2.34（Q4 2021）」版本之前，设置`git config --global submodule.recurse true`，那么在主项目切换不同分支的时候，submodule会自动切换过去；
* 「Git 2.34（Q4 2021）」版本及以后，在`git clone --recurse-submodules`拉取的仓库时，默认会设置`git config --global submodule.recurse true`，不需要再关心submodule的跟踪问题了；

### 拉取含有submodule的repo

前面都是使用submoudle的一些前置操作，那在拉取一个含有submodule repo的时候，我们需要做什么吗？

是的，默认git clone并不会拉取所有跟踪的submodule的源码数据，有两种方式可以拉取：

* 在git clone的时候带上参数，`git clone --recurse-submodules https://github.com/grpc/grpc`，其中`--recurse-submodules`选项，它会自动初始化并更新仓库中的每一个子模块， 包括可能存在的嵌套子模块。

* 在`git clone之`后，进入仓库中，执行`git submodule update --init --recursive`，其中`--recursive`选项和`git clone`时候的`--recurse-submodules`的含义是一样的；

### 推送含有变更的submodule

有时候我们可能修改了submoudle的内容，在推送主项目的时候，也希望推送跟踪的子项目，也是可以操作的，方式和拉取的时候是类似的，如下：

* 通过`git push --recurse-submodules --on-demand`；在推送主项目的时候会递归的推送子项目；
* 通过`git config --global push.recurseSubmodules=on-demand`来配置；和上述含义一样；不过这里为什么不使用`git config --global submodule.recurse true`的设置呢？「**看来submodule.recurse的配置不仅不对clone生效，在push的时候也不生效**…」

## 其他命令

### `git submodule foreach`

git提供了可以在主项目中执行所有git命令来直接操作子项目的方式，命令：`git submodule foreach 'git cmd'`，foreach可以遍历所有submodule，然后执行后面的git命令，如下查看子项目的所有分支：

```
$git submodule foreach 'git branch -av'
Entering 'submodules/draw_io'
* (HEAD detached at a62a01f) a62a01f change name
  master                     117e833 [behind 4] update README.md
  remotes/origin/HEAD        -> origin/master
  remotes/origin/develop     a62a01f change name
  remotes/origin/master      abe26b7 sync
```

我们可以`alias git-sf='git submodule foreach'`来便捷的操作submodule；
