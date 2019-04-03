# 22 款受欢迎的CI工具

市场上持续集成工具众多，找到一个合适的工具并非易事。本文将汇总介绍22个比较受欢迎的CI工具，其中有开源产品也有商业闭源产品，我们将总结每个工具的特点，并附上了下载链接。

## 1. Buddy

**对 Web 开发者来说**，Buddy 是一个智能的 CI/CD 工具，降低了 `DevOps` 的入门门槛。

`Buddy` 使用 `DeliveryPipeline` 进去软件构建、测试及发布，创建 `Pipeline` 时，`100` 多个就绪的操作可随时投入使用，就像砌砖房一样。

### 特点：

* 清晰的配置，友好的交互，15分钟快速配置
* 基于变更集（`changeset`）的快速部署
* 构建运行在使用缓存依赖的独立容器中
* 支持所有流行的语言、框架和任务管理器
* `Docker / Kubernetes` 专用操作手册
* 与 `AWS`，`Google`，`DigitalOcean`，`Azure`，`Shopify`，`WordPress` 等集成
* 支持并行和 `YAML` 配置

下载链接：[https://buddy.works](https://buddy.works)

## 2. Jenkins

**`Jenkins` 是一个开源的持续集成工具，使用 Java 编程语言编写的**。它有助于实时检测和报告较大代码库中的单一更改。该软件可帮助开发人员快速查找和解决代码库中的问题并自动测试其构建。

### 特点：

* 支持海量节点扩展并在节点中同等分发工作负载
* 在各版本`Linux`、`Mac OS` 或 `Windows` 等全平台轻松更新
* 提供了 `WAR` 格式的简易安装包，执行导入 `JEE` 容器中即可运行安装
* 可以通过 `Web` 界面轻松设置和配置 `Jenkins`
* 可轻松跨机器分发

下载链接：[https://jenkins.io/download/](https://jenkins.io/download/)

## 3. TeamCity

**`TeamCity` 是一款拥有很多强大功能的持续集成服务器。**

### 特点：

* 可扩展性和自定义
* 为项目提供更好的代码质量
* 即使没有运行构建，也能保持 CI 服务器健康稳定
* 可在 `DSL` 中配置构建
* 项目级云配置文件
* 全面的 VCS 集成
* 即时构建进度报告
* 远程运行和预先测试的提交

下载链接：[https://www.jetbrains.com/teamcity/download/#section=windows](https://www.jetbrains.com/teamcity/download/#section=windows)

## 4. Drone

`Drone` 是一个非常的开源CI工具。它其实是原生`Docker`，所有的进程都在容器内进行。这也使得`Drone`非常适合像`Kubernetes`这样的平台，因为在Kubernetes上启动容器很简单。

### 特点：

* 配置为代码：`Pipeline`配置了一个简单易读的文件，可以直接提交至`git`仓库；每个`Pipeline`步骤都在一个隔离的`Docker`容器中执行。
* 创建和共享插件：`Drone`使用容器将预先配置的步骤放入`pipeline`中，用户可以从数百个现有插件中进行选择，或创建自己的插件。
* 易于定制：实现自定义访问控制、批准工作流、机密管理、yaml语法扩展等。
* 易于安装：`Drone`为开源产品，用户可下载官方`Docker`镜像或从源代码构建。

下载链接：[https://drone.io](https://drone.io)

## 5. Travis CI

`Travis` 是一款流行的 `CI` 工具，可免费用于开源项目。**在托管时，不必依赖任何平台。此 CI 工具为许多构建配置和语言提供支持，如 Node，PHP，Python，Java，Perl 等。**

### 特点：

* `Travis` 使用虚拟机构建应用程序
* 可通过 `Slack`，`HipChat`，电子邮件等通知
* 允许运行并行测试
* 支持 `Linux`、`Mac` 以及 `iOS`
* 易于配置，无需安装
* 强大的 `API` 和命令行工具

下载链接：[https://github.com/travis-ci/travis-ci](https://github.com/travis-ci/travis-ci)


## 6. GoCD

GoCD 是一个开源的持续集成服务器。它可轻松模拟和可视化复杂的工作流程。此 CI 工具允许持续交付，并为构建 CD Pipeline 提供直观的界面。


### 特点：

* 支持并行和顺序执行，可以轻松配置依赖
* 随时部署任何版本
* 使用 Value Stream Map 实时可视化端到端工作流程
* 安全地部署到生产环境
* 支持用户身份验证和授权
* 保持配置有序
* 有大量的插件增强功能
* 活跃的社区帮助和支持

下载链接：[https://www.gocd.org/download/](https://www.gocd.org/download/)

## 7. Bamboo

`Bamboo` 是一个持续集成的构建服务器，可以自动构建、测试和发布，并可与 `JIRA` 和 `Bitbucket` 无缝协作。Bamboo 支持多语言和平台，如 `CodeDeply`、`Ducker`、`Git`，`SVN`、`Mercurial`、`AWS` 及 `Amazon S3 bucket`。

### 特点：

* 可并行运行批量测试
* 配置简单
* 分环境权限功能允许开发人员和 QA 部署到他们的环境
* 可以根据 `repository` 中检测到的更改触发构建，并从 Bitbucket 推送通知
* 可托管或内部部署
* 促进实时协作并与 HipChat 集成
* 内置 `Git` 分支和工作流程，并自动合并分支

下载链接：[https://www.atlassian.com/software/bamboo](https://www.atlassian.com/software/bamboo)


## 8. Gitlab CI

**`GitLab CI` 是 `GitLab` 的一部分。** 它是一个提供 `API` 的 `Web` 应用程序，可将其状态存储在数据库中。`GitLab CI` 可以管理项目并提供友好的用户界面，并充分利用 `GitLab` 所有功能。

### 特点：

* `GitLab Container Registry` 是安全的 `Docker` 镜像注册表
* GitLab 提供了一种方便的方法来更改 issue 或 merge request 的元数据，而无需在注释字段中添加斜杠命令
* 为大多数功能提供 API，允许开发人员进行更深入的集成
* 通过发现开发过程中的改进领域，帮助开发人员将他们的想法投入生产
* 可以通过机密问题保护您的信息安全
* `GitLab` 中的内部项目允许促进内部存储库的内部 `sourcing`

下载链接：[https://about.gitlab.com/installation/](https://about.gitlab.com/installation/)

## 9. CircleCI

**`Circle CI` 是一个灵活的 `CI` 工具，可在任何环境中运行，如跨平台移动应用程序、`Python API` 服务器或 `Docker` 集群，该工具可减少错误并提高应用程序的质量。**

### 特点：

* 允许选择构建环境
* 支持多语言及平台，如Linux，包括C ++，Javascript，NET，PHP，Python 和 Ruby
* 支持 Docker，可以配置自定义环境
* 触发较新的构建时，自动取消排队或正在运行的构建
* 跨多容器分割和平衡测试，以减少总体构建时间
* 禁止非管理员修改关键项目配置
* 通过发送无错误的应用程序提高 Android 和 iOS 商店评级
* 最佳缓存和并行性能，实现高性能
* 与 VCS 工具集成

下载链接：[https://circleci.com/](https://circleci.com/)

## 10. Codeship

`Codeship` 是一个功能强大的 CI 工具，可自动化开发和部署工作流程。**`Codeship` 通过简化到 `repository` 的 `push` 来触发自动化工作流程。**

### 特点：

* 可完全控制 CI 和 CD 系统的设计。
* 集中的团队管理和仪表板
* 轻松访问调试版本和 SSH，有助于从 CI 环境进行调试
* 可完全定制和优化 CI 和 CD 工作流程
* 允许加密外部缓存的 Docker 镜像
* 允许为您的组织和团队成员设置团队和权限
* 有两个版本1）Basic 和 2）Pro

下载链接：[https://codeship.com/](https://codeship.com/)


## 11. Buildbot

Buildbot 是一个软件开发 CI，可以自动完成编译/测试周期。**它被广泛用于许多软件项目，用以验证代码更改。它提供跨平台 Job 的分布式并行执行。**

### 特点：

* 为不同体系结构的多个测试主机提供支持。
* 报告主机的内核崩溃
* 维护单源 repository
* 自动化构建
* 每个提交都在集成机器上的主线上构建
* 自动部署
* 开源

下载链接：[https://buildbot.net/](https://buildbot.net/)

## 12. Nevercode

**`Nevercode` 是一个基于云端的 `CI` 传送服务器，可以构建、测试和分发应用程序而无需人工交互。** 此 `CI` 工具自动为每个提交构建项目，并在模拟器或真实硬件上运行所有单元测试 或 UI 测试。

### 特点：

* 基于云服务，因此无需维护服务器
* 易于学习和使用
* 良好的文档，易于阅读和理解
* 通过持续集成和交付自动化整个开发过程
* 与众多工具集成


下载链接：[https://nevercode.io/](https://nevercode.io/)

## 13. Integrity

**`Integrity` 是一个持续集成服务器，仅适用于 `GitHub`。** 在此 CI 工具中，只要用户提交代码，它就构建并运行代码。它还会生成报告并向用户提供通知。

### 特点：

* 目前仅适用于 Git，但它可以轻松地映射其他 SCM
* 支持多通知机制，如 AMQP，电子邮件，HTTP，Amazon SES，Flowdock，Shell 和 TCP
* HTTP 通告功能将以 HTTP POST 请求发送到特定URL

下载链接：[http://integrity.github.io/](http://integrity.github.io/)

## 14. Strider

**Strider 是一个开源工具，用 `Node.JS / JavaScript` 编写。它使用 `MongoDB` 作为后端存储。因此，`MongoDB `和 `Node.js` 对于安装此 `CI` 至关重要。** 该工具为不同的插件提供支持，这些插件可修改数据库 `schema` 并注册`HTTP`路由。

### 特点：

* **Strider 可与 GitHub，BitBucket，Gitlab 等集成。**
* 允许添加钩子来执行构建操作
* 持续构建和测试软件项目
* 与 GitHub 无缝集成
* 发布和订阅 socket 事件
* 支持创建和修改 Striders 用户界面
* 强大的插件，定制默认功能
* 支持 Docker

下载链接：[https://github.com/Strider-CD/strider](https://github.com/Strider-CD/strider)


## 15. AutoRABIT

**`AutoRABIT` 是一个端到端的持续交付套件，可以加快开发过程。** 它简化了完整的发布流程，并可以帮助任何规模的组织实现持续集成。

### 特点：

* 专门设计用于在 Salesforce Platform 上部署
* 支持基于 120 多种元数据类型的更改，实现精简和快速部署
* 从版本控制系统获取更改并自动部署到 Sandbox 中
* 直接从 Sandbox 自动向版本控制系统提交更改

下载链接：[http://www.autorabit.com/tag/autorabit-download/](http://www.autorabit.com/tag/autorabit-download/)

## 16. FinalBuilder

`FinalBuilder` 是 `VSoft` 的构建工具。使用 `FinalBuilder`，无需编辑 `XML `或编写脚本。**在使用 Windows 调度程序调度构建脚本时，可以定义和调试构建脚本，或者与 `Jenkins`，`Continua` CI 等集成。**

### 特点：

* 以逻辑结构化的图形界面呈现构建过程
* 使用 try 和 catch 操作处理本地错误
* 与 Windows 调度服务紧密集成，支持定时构建
* 支持十几个版本控制系统
* 提供脚本支持
* 构建过程中所有操作的输出都将定向到构建日志


下载链接：[https://www.finalbuilder.com/downloads/finalbuilde](https://www.finalbuilder.com/downloads/finalbuilde)

## 17. Wercker

`Wercker` 是一个 CI 工具，可自动构建和部署容器。**它可以创建可以通过命令行界面执行的自动化管道。**

### 特点：

* 与 GitHub 和 Bitbucket 完全集成
* 使用 Wercker CLI 进行更快的本地迭代
* 同时执行构建以保持团队的机动
* 运行并行测试以减少团队的等待时间
* 集成了 100 多种外部工具
* 通过产品和电子邮件接收系统通知

下载链接：[http://www.wercker.com/](http://www.wercker.com/)

## 18. Buildkite

**`Buildkite` 代理是一个可靠的跨平台构建工具**。**此 `CI` 工具可以在础架构上轻松地运行自动构建**。它主要用于运行构建 `Job`，报告 Job 的状态代码并输出日志。

### 特点：

* 可在各种操作系统和体系结构上运行
* 可以从任何版本控制系统运行代码
* 允许在计算机上运行任意数量的构建代理
* 可与 Slack，HipChat，Flowdock，Campfire 等工具集成
* 永远不会读取源代码或密钥
* 提供稳定的基础设施


下载链接：[https://buildkite.com/](https://buildkite.com/)

## 19. Semaphore

**`Semaphore` 是一个持续集成工具，只需按一下按钮即可测试和部署代码。** 它支持多种语言、框架并可与 GitHub 集成，还可以执行自动测试和部署。

### 特点：

* 配置简单
* 允许自动并行测试
* 市场上最快的 CI 之一
* 可以轻松覆盖不同大小的项目数量
* 与 GitHub 和 Bitbucket 无缝集成

下载链接：[https://semaphoreci.com](https://semaphoreci.com)


## 20. CruiseControl

**`CruiseControl` 既是 `CI` 工具又是一个可扩展的框架**。它用于构建自定义连续的构建。它有许多用于各种源代码控制的插件，包括针对电子邮件和即时消息的构建技术。

### 特点：

* 与许多不同的源代码控制系统集成，如 vss，csv，svn，git，hg，perforce，clearcase，filesystem 等
* 允许在单个服务器上构建多个项目
* 与其他外部工具集成，如 NAnt，NDepend，NUnit，MSBuild，MBUnit 和 Visual Studio
* 支持远程管理

下载链接：[http://cruisecontrol.sourceforge.net/download.html](http://cruisecontrol.sourceforge.net/download.html)


## 21. Bitrise


**`Bitrise` 是一个持续集成和交付 `PaaS`，它可以为整个团队提供移动持续集成和交付。**它允许与 `Slack`，`HipChat`，`HockeyApp`，`Crashlytics` 等许多流行服务集成。

### 特点：

* 允许在终端中创建和测试工作流程
* 无需手动控制即可获得应用程序
* 每个构建在其自己的虚拟机中单独运行，并且在构建结束时丢弃所有数据
* 支持第三方 beta 测试和部署服务
* 支持 GitHub Pull Request

下载链接：[https://github.com/bitrise-io/bitrise#install-and-setup](https://github.com/bitrise-io/bitrise#install-and-setup)

## 22. UrbanCode

IBM UrbanCode 是一个 CI 应用程序。它将强大的可见性，可追溯性和审计功能整合到一个软件包中。

### 特点：

* 通过自动化，可重复的部署流程提高软件交付频率
* 减少部署失败
* 简化多渠道应用程序的部署，无论是在本地还是在云中，都可以部署到所有环境
* 企业级安全性和可扩展性
* 混合云环境建模
* 拖放自动化

下载链接：[https://www.ibm.com/ms-en/marketplace/application-release-automation](https://www.ibm.com/ms-en/marketplace/application-release-automation)



## 结 语

容器技术被越来越多地用于大型项目之中，如何通过一致的流程和工作流来简化大型项目的部署，变得愈发重要。
