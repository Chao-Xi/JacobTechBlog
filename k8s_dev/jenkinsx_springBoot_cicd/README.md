# 使用 `Jenkins X`、`Kubernetes` 和 `Spring Boot` 实现 `CI/CD`

过去五年中的变化，如迁移到公有云以及从虚拟机向容器的转变，已经彻底改变了构建和部署软件的意义。

以 `Kubernetes` 为例。`Google` 于2014年开源，现在所有主流的公有云供应商都支持它---它为开发人员提供了一种很好的方式，可以将应用程序打包到 `Docker` 容器中，并部署到任意 `Kubernetes` 集群中。

## 使用 `CI/CD`、`Kubernetes` 和 `Jenkins X` 进行高性能开发

在技术上，高性能团队几乎总是成功的必要条件，**而`持续集成`、`持续部署(CI/CD)`、`小迭代`以及快速反馈是构建模块。** 为你的云原生应用程序设置 CI/CD 可能比较困难。通过自动化所有内容，开发人员可以花费宝贵的时间来交付实际的业务。

### 如何使用容器、持续交付和 `Kubernetes` 成为高效团队？这就是 `Jenkins X` 的切入点。

> “Jenkins X 的理念是为所有开发人员提供他们自己的海军航海管家，可以帮助你航行持续交付的海洋。” - James Strachan


### `Jenkins X` 帮助你自动化你在 `Kubernetes` 中的 `CI/CD` - 你甚至不需要学习 Docker 或 Kubernetes！

* [项目连接/okta-spring-jx-example](https://github.com/oktadeveloper/okta-spring-jx-example)


1. [Jenkins X](1JenkinsX.md)
   * 在 `Google Cloud` 上安装 `Jenkins X` 并创建群集
2. [创建一个 `Spring Boot` 应用程序](2SpringBoot.md)
   * 从 `Cloud Shell` 创建一个简单的 `Spring Boot` 应用程序：
   * 使用 `Jenkins X` 将 `Spring Boot` 应用程序部署到生产环境中
   * 保护你的 `Spring Boot` 应用程序并添加 `Angular PWA`
   * 增加 `Actuator` 并关闭 `HTTPS`
   * 调整 `Dockerfile` 和 `Jenkinsfile` 中的路径
3. [为什么使用Okta？](3Okta.md)
   * 在 Okta 中为 `Spring Boot` 应用程序创建一个 Web 应用程序
   * 将环境变量转移到 Docker 容器
   * 在 Okta 中自动添加重定向 URI
4. [在 Jenkins X 中运行 Protractor 测试](4Protractor.md) 


## Learn More About Jenkins X, Kubernetes, and Spring Boot

Jenkins X 还包括一个 [DevPods](https://dzone.com/articles/achieve-cicd-with-jenkins-x-kubernetes-and-spring) 功能，可以在笔记本电脑上进行开发时，可以自动部署保存。我不确定 DevPods 是否适用于需要具有生产转换步骤的 JavaScript 应用程序。我宁愿让 `webpack` 和 `Browsersync` 在几秒钟内刷新我的本地浏览器，而不是等待几分钟创建并部署 Docker 镜像到 Kubernetes。

To get an excellent overview and demo of Jenkins X, watch [James Strachan’s Jenkins X: Continuous Delivery for Kubernetes](https://www.youtube.com/watch?v=53AtxQGXnMk&feature=youtu.be) from the June 2018 Virtual JUG meetup.

