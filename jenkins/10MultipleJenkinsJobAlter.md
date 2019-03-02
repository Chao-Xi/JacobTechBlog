# 批量修改 Jenkins 任务的技巧

## 通过脚本命令行批量修改 Jenkins 任务

我们经常碰见的问题 `Jenkins` 所在的服务器经常报硬盘空间不足。经查发现很多任务没有设置“**丢弃旧的构建(BuildDiscarder)**”。通知所有的团队检查自己的 `Jenkins` 任务有没有设置丢弃旧的构建，有些不现实。

一开始想到的是使用 `Jenkins` 的 `API` 来实现批量修改所有的 `Jenkins` 任务。笔者对这个解决方案不满意，经 Google 发现有同学和我遇到了同样的问题。他使用的更“技巧”的方式：**在 `Jenkins` 脚本命令行中，通过执行 Groovy 代码操作 `Jenkins` 任务。**

总的来说，就两步：

1. 进入菜单：`系统管理 --> 脚本命令行 | Manage Jenkins --> Script Console` 
2. 在输入框中，粘贴如下代码：

```
import jenkins.model.Jenkins
import hudson.model.Job
import jenkins.model.BuildDiscarderProperty
import hudson.tasks.LogRotator

// 遍历所有的任务

Jenkins.instance.allItems(Job).each { job ->
	
	if ( job.isBuildable() && job.supportsLogRotator() && job.getProperty(BuildDiscarderProperty) == null) {
	println " \"${job.fullDisplayName}\" dealing..."
	job.addProperty(new BuildDiscarderProperty(new LogRotator (2, 10, 2, 10)))
	println " \"${job.name} \" already updated"
	}
  }
}
return;
```

### LogRotator构造参数分别为：
* **daysToKeep**:  If not `-1`, **history is only kept up to this days**.
* **numToKeep**: If not `-1`, **only this number of build logs are kept**.
* **artifactDaysToKeep**: If not `-1` nor null, **artifacts are only kept up to this days**.
* **artifactNumToKeep**: If not `-1` nor null, **only this number of builds have their artifacts kept**.


## 脚本

脚本命令行（`Jenkins Script Console`），它是 `Jenkins` 的一个特性，允许你在 `Jenkins master` 和 `Jenkins agent` 的运行时环境执行任意的 `Groovy` 脚本。

这意味着，我们可以在脚本命令行中做任何的事情，包括关闭 `Jenkins`，执行操作系统命令 `rm -rf /`（所以不能使用 root 用户运行 Jenkins agent）等危险操作。

除了上文中的，使用界面来执行 `Groovy` 脚本，还可以通过 `Jenkins HTTP API：/script`执行。

## 问题：代码执行完成后，对任务的修改有没有被持久化？

当我们代码`job.addProperty(new BuildDiscarderProperty(new LogRotator (2, 10, 2, 10)))`执行后，这个修改到底有没有持久化到文件系统中呢（Jenkins 的所有配置默认都持久化在文件系统中）？我们看下 `hudson.model.Job `的源码，在`addProperty`方法背后是有进行持久化的：

```
public void addProperty(JobProperty<? super JobT> jobProp) throws IOException {
    ((JobProperty)jobProp).setOwner(this);
    properties.add(jobProp);
    save();
}
```


