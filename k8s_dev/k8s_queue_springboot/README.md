# 如何使用`Message Queues`, `Spring Boot`, 以及 `Kubernetes`构建高可用的微服务架构

![Alt Image Text](images/0_1.png "Body image")

1. [项目背景介绍，以及消息队列相对传统服务的优势](1Background_intro.md)
2. [编写Spring应用程序,模拟应用程序的运行以及使用JMS发送和接收消息](2Write_program.md)
   * 编写Spring应用程序
   * 模拟应用程序的运行
   * 使用JMS发送和接收消息
3. [使用容器打包应用程序并将应用程序部署到Kubernetes](3Deploy_in_K8S.md)
   * 启动`minikube`作为项目集群
   * 将项目代码打包到`docker image`
   * 将你的应用程序部署到Kubernetes
   * 部署`ActiveMQ`
   * 部署前端
   * 部署后端
4. [手动扩展集群以满足不断增长的需求](4Manually_Scale_cluster.md)
5. [在Kubernetes中利用`Prometheus`以及`Metrics`进行自动扩展部署以及负载测试](5AutoScale_with_Prometheus_Metrics.md)
   * 公开应用程序指标(`metrics`)
   * 在Kubernetes中使用应用程序指标
   * 在Kubernetes中进行自动扩展部署(HPA)
   * 负载测试
   * 什么比自动缩放实例更好？自动缩放集群

* [原文地址](https://medium.freecodecamp.org/how-to-scale-microservices-with-message-queues-spring-boot-and-kubernetes-f691b7ba3acf)
* [项目github地址](https://github.com/learnk8s/spring-boot-k8s-hpa)
