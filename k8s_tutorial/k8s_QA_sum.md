![Alt Image Text](images/qa/qa0.jpg "headline image")

# K8S Issues List

1. [污点和容忍](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_QA1.md#1%E6%B1%A1%E7%82%B9%E5%92%8C%E5%AE%B9%E5%BF%8D)

2. [镜像时区问题](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_QA1.md#2-%E9%95%9C%E5%83%8F%E6%97%B6%E5%8C%BA%E9%97%AE%E9%A2%98)

3. [`kubelet sidecar`镜像问题](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_QA1.md#3-kubelet-sidecar%E9%95%9C%E5%83%8F%E9%97%AE%E9%A2%98) 

4. [`kubernetes` 集群访问外部服务](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_QA1.md#3-kubelet-sidecar%E9%95%9C%E5%83%8F%E9%97%AE%E9%A2%98)

5. [`Helm` 安装问题](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_QA2.md#1-helm-%E5%AE%89%E8%A3%85%E9%97%AE%E9%A2%98)

6. [`nodeAffinity` 问题](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_QA2.md#1-helm-%E5%AE%89%E8%A3%85%E9%97%AE%E9%A2%98)

7. [怎样理解 `ingress` 和 `ingress-controller`](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_QA2.md#3-%E6%80%8E%E6%A0%B7%E7%90%86%E8%A7%A3-ingress-%E5%92%8C-ingress-controller)

8. [`flannel` 网络问题](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_QA2.md#4-flannel-%E7%BD%91%E7%BB%9C%E9%97%AE%E9%A2%98)

9. [节点资源配置问题](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_QA2.md#5-%E8%8A%82%E7%82%B9%E8%B5%84%E6%BA%90%E9%85%8D%E7%BD%AE%E9%97%AE%E9%A2%98)
 
10. [`Helm` 命令补全方法](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_QA2.md#6-helm-%E5%91%BD%E4%BB%A4%E8%A1%A5%E5%85%A8%E6%96%B9%E6%B3%95)

11. [`docker` 启动 `jenkins` 问题](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_QA2.md#7-docker-%E5%90%AF%E5%8A%A8-jenkins-%E9%97%AE%E9%A2%98)

12. [节点资源驱逐问题 `DiskPressure`](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_QA3.md#1-%E8%8A%82%E7%82%B9%E8%B5%84%E6%BA%90%E9%A9%B1%E9%80%90%E9%97%AE%E9%A2%98)

13. [集群部署方式的选择](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_QA3.md#2-%E9%9B%86%E7%BE%A4%E9%83%A8%E7%BD%B2%E6%96%B9%E5%BC%8F%E7%9A%84%E9%80%89%E6%8B%A9)

14. [`kubectl` 出现 `no such host` 的错误](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_QA3.md#3-kubectl-%E5%87%BA%E7%8E%B0-no-such-host-%E7%9A%84%E9%94%99%E8%AF%AF)

15. [`kubeadm` 证书有效期问题](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_QA4.md#1-kubeadm-%E8%AF%81%E4%B9%A6%E6%9C%89%E6%95%88%E6%9C%9F%E9%97%AE%E9%A2%98)

16. [关于`java`应用中资源限制的问题 CPU and Memory](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_QA4.md#2-%E5%85%B3%E4%BA%8Ejava%E5%BA%94%E7%94%A8%E4%B8%AD%E8%B5%84%E6%BA%90%E9%99%90%E5%88%B6%E7%9A%84%E9%97%AE%E9%A2%98)

17. [Critical Pod 的使用](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_QA4.md#3-critical-pod-%E7%9A%84%E4%BD%BF%E7%94%A8)

18. [Prometheus 管理数据指标的方法(删除)](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_QA4.md#4-prometheus-%E7%AE%A1%E7%90%86%E6%95%B0%E6%8D%AE%E6%8C%87%E6%A0%87%E7%9A%84%E6%96%B9%E6%B3%95)

19. [`Statefulset Pod` 的管理策略](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_QA4.md#5-statefulset-pod-%E7%9A%84%E7%AE%A1%E7%90%86%E7%AD%96%E7%95%A5)

20. [`kubectl exec` 参数问题](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_QA4.md#6-kubectl-exec-%E5%8F%82%E6%95%B0%E9%97%AE%E9%A2%98)

21. [`Systemd` 连接词号`“-”`的作用](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_QA5.md#1-systemd-%E8%BF%9E%E6%8E%A5%E8%AF%8D%E5%8F%B7-%E7%9A%84%E4%BD%9C%E7%94%A8)

22. [外网访问 `Kubernetes` 集群](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_QA5.md#2%E5%A4%96%E7%BD%91%E8%AE%BF%E9%97%AE-kubernetes-%E9%9B%86%E7%BE%A4)

23. [`Jenkins Slave Pod` 启动错误](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_QA5.md#3-jenkins-slave-pod-%E5%90%AF%E5%8A%A8%E9%94%99%E8%AF%AF)

24. [`Gitlab CI Runner` 域名解析问题](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_QA5.md#4-gitlab-ci-runner-%E5%9F%9F%E5%90%8D%E8%A7%A3%E6%9E%90%E9%97%AE%E9%A2%98)

25. [`Kubectl` 高级使用](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_QA5.md#5-kubectl-%E9%AB%98%E7%BA%A7%E4%BD%BF%E7%94%A8)

26. [`Groovy` 脚本问题](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_QA5.md#6-groovy-%E8%84%9A%E6%9C%AC%E9%97%AE%E9%A2%98)

27. [Fluentd 日志收集问题](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_QA5.md#7-fluentd-%E6%97%A5%E5%BF%97%E6%94%B6%E9%9B%86%E9%97%AE%E9%A2%98)

28. [kubeadm 指定初始化集群镜像](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_QA5.md#8-kubeadm-%E6%8C%87%E5%AE%9A%E5%88%9D%E5%A7%8B%E5%8C%96%E9%9B%86%E7%BE%A4%E9%95%9C%E5%83%8F)

29. [YAML 文件格式](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_QA5.md#9-yaml-%E6%96%87%E4%BB%B6%E6%A0%BC%E5%BC%8F)

30. [如果`pod`长期不重启，容器输出到 `emptydir` 的日志文件，有什么好的清理办法呢？](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_QA6.md#1-%E5%A6%82%E6%9E%9Cpod%E9%95%BF%E6%9C%9F%E4%B8%8D%E9%87%8D%E5%90%AF%E5%AE%B9%E5%99%A8%E8%BE%93%E5%87%BA%E5%88%B0-emptydir-%E7%9A%84%E6%97%A5%E5%BF%97%E6%96%87%E4%BB%B6%E6%9C%89%E4%BB%80%E4%B9%88%E5%A5%BD%E7%9A%84%E6%B8%85%E7%90%86%E5%8A%9E%E6%B3%95%E5%91%A2)

31. [`kubeadm` 搭建集群忘记了 `join` 的命令](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_QA6.md#2-kubeadm-%E6%90%AD%E5%BB%BA%E9%9B%86%E7%BE%A4%E5%BF%98%E8%AE%B0%E4%BA%86-join-%E7%9A%84%E5%91%BD%E4%BB%A4)

32. [`ServiceAccount` 如何进行权限控制](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_QA6.md#3-serviceaccount-%E5%A6%82%E4%BD%95%E8%BF%9B%E8%A1%8C%E6%9D%83%E9%99%90%E6%8E%A7%E5%88%B6)

33. [`Docerfile` 中添加交互式命令](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_QA6.md#4--docerfile-%E4%B8%AD%E6%B7%BB%E5%8A%A0%E4%BA%A4%E4%BA%92%E5%BC%8F%E5%91%BD%E4%BB%A4)

34. [`kubeadm` 升级集群配置](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_QA6.md#5-kubeadm-%E5%8D%87%E7%BA%A7%E9%9B%86%E7%BE%A4%E9%85%8D%E7%BD%AE)

35. [`Pod `时区同步](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_QA6.md#6-pod-%E6%97%B6%E5%8C%BA%E5%90%8C%E6%AD%A5)

36. [`Prometheus` 采集 `Kubelet` 指标](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_QA6.md#7-prometheus-%E9%87%87%E9%9B%86-kubelet-%E6%8C%87%E6%A0%87)

37. [`Lease API`](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_QA6.md#8-lease-api)

38. [`Prometheus` 报警规则](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_QA6.md#9-prometheus-%E6%8A%A5%E8%AD%A6%E8%A7%84%E5%88%99)

39. [启动探针](https://github.com/Chao-Xi/JacobTechBlog/blob/master/k8s_tutorial/k8s_QA6.md#10%E5%90%AF%E5%8A%A8%E6%8E%A2%E9%92%88)