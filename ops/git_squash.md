# Git Tools - Rewriting History

## Changing the Last Commit

If you simply want to modify your last commit message, that’s easy:

```
$ git commit --amend
```

## Changing Multiple Commit Messages

For example, if you want to change the last three commit messages, or any of the commit messages in that group, you supply as an argument to `git rebase -i` the parent of the last commit you want to edit, which is `HEAD~2^` or `HEAD~3`. It may be easier to remember the `~3` because you’re trying to **edit the last three commits**, 

**but keep in mind that you’re actually designating four commits ago, the parent of the last commit you want to edit:**

```
$ git rebase -i HEAD~3
```
**Every commit included in the range `HEAD~3..HEAD` will be rewritten, whether you change the message or not.**

Don’t include any commit you’ve already pushed to a central server – doing so will confuse other developers by providing an alternate version of the same change.

```
pick f7f3f6d changed my name a bit
pick 310154e updated README formatting and added blame
pick a5f4a0d added cat-file

# Rebase 710f0f8..a5f4a0d onto 710f0f8
#
# Commands:
#  p, pick = use commit
#  r, reword = use commit, but edit the commit message
#  e, edit = use commit, but stop for amending
#  s, squash = use commit, but meld into previous commit
#  f, fixup = like "squash", but discard this commit's log message
#  x, exec = run command (the rest of the line) using shell
#
# These lines can be re-ordered; they are executed from top to bottom.
#
# If you remove a line here THAT COMMIT WILL BE LOST.
#
# However, if you remove everything, the rebase will be aborted.
#
# Note that empty commits are commented out
```
It’s important to note that these commits are listed in the opposite order than you normally see them using the `log` command. If you run a log, you see something like this:

```
$ git log --pretty=format:"%h %s" HEAD~3..HEAD
a5f4a0d added cat-file
310154e updated README formatting and added blame
f7f3f6d changed my name a bit
```

```
Auto-merging metadata.rb
CONFLICT (content): Merge conflict in metadata.rb
error: could not apply 102a57d... update cookbook_cloud_learn to update bb-newrelic

Resolve all conflicts manually, mark them as resolved with
"git add/rm <conflicted_files>", then run "git rebase --continue".
You can instead skip this commit: run "git rebase --skip".
To abort and get back to the state before "git rebase", run "git rebase --abort".

Could not apply 102a57d... update cookbook_cloud_learn to update bb-newrelic
```



