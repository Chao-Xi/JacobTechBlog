# Git技巧：修改历史

## 修改历史

### 修改最新一条历史

如果内容需要改就直接改，然后 `git add` 进去，然后执行

```
git commit --amend
```

会弹出 `git commit message` 的编辑窗口，会填充之前 `commit` 时写的 `message` 内容，如果需要改就直接编辑，不需要改就不动，最后保存退出 (`:wq`)

### 修改指定某条历史

不小心暴露敏感信息到历史？使用如下操作修改历史：

* 找到需要修改的历史更前面的一条 commit 的 id 并复制，记为 `<commit id>`
* `git rebase -i <commit id>`
* 将显示的第一个 `pick` 改为 `edit`
* 保存并退出 (`:wq`)
* 对需要修改的文件进行修改，然后 `git add` 进去
* 提交：`git commit --amend`
* 完成: `git rebase --continue`

### 同步代码

强制 `push` 到远程：

```
git push -f origin <local-branch>:<remote-branch>
```

其它伙伴同步到自己机器：

```
git fetch
git reset --hard origin/<remote-branch>
```

