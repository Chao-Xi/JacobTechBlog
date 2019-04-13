# 基于 Jenkins、Gitlab、Harbor、Helm 和 Kubernetes 的 CI/CD(一)

使用 `Jenkins` + `Gitlab` + `Harbor` + `Helm` + `Kubernetes` 来实现一个完整的 `CI/CD` 流水线作业。

## 流程

下图是我们当前示例的流程图

![Alt Image Text](images/4_1.jpg "Headline image")

1. 开发人员提交代码到 Gitlab 代码仓库
2. 通过 Gitlab 配置的 `Jenkins Webhook` 触发 Pipeline 自动构建
3. `Jenkins` 触发构建构建任务，根据 `Pipeline` 脚本定义分步骤构建
4. **先进行代码静态分析，单元测试**
5. **然后进行 `Maven` 构建（Java 项目）**
6. 根据构建结果构建 `Docker` 镜像
7. 推送 `Docker` 镜像到 `Harbor` 仓库
8. 触发更新服务阶段，使用 `Helm `安装/更新 Release
9. 查看服务是否更新成功。

## 项目

本次示例项目是一个完整的基于 `Spring Boot`、`Spring Security`、`JWT`、`React` 和 `Ant Design` 构建的一个开源的投票应用，项目地址：[https://github.com/callicoder/spring-security-react-ant-design-polls-app](https://github.com/callicoder/spring-security-react-ant-design-polls-app)。

![Alt Image Text](images/4_2.jpg "Headline image")

我们将会在该项目的基础上添加部分代码，并实践 CI/CD 流程。

### 服务端

首先需要更改的是服务端配置，我们需要将数据库链接的配置更改成环境变量的形式，写死了的话就没办法进行定制了，修改服务端文件`src/main/resources/application.properties`，将下面的数据库配置部分修改成如下形式：

```
spring.datasource.url= jdbc:mysql://${DB_HOST:localhost}:${DB_PORT:3306}/${DB_NAME:polling_app}?useSSL=false&serverTimezone=UTC&useLegacyDatetimeCode=false
spring.datasource.username= ${DB_USER:root}
spring.datasource.password= ${DB_PASSWORD:root}
```

当环境变量中有上面的数据配置的时候，就会优先使用环境变量中的值，没有的时候就会用默认的值进行数据库配置。

由于我们要将项目部署到 `Kubernetes` 集群中去，所以我们需要将服务端进行容器化，所以我们在项目根目录下面添加一个`Dockerfile`文件进行镜像构建：

```
FROM openjdk:8-jdk-alpine

MAINTAINER jxi <xichao2014@gmail.com>

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV TZ=Asia/Shanghai

RUN mkdir /app

WORKDIR /app

COPY target/polls-0.0.1-SNAPSHOT.jar /app/polls.jar

EXPOSE 8080

ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar","/app/polls.jar"]
```

由于服务端代码是基于`Spring Boot`构建的，所以我们这里使用一个`openjdk`的基础镜像，将打包过后的`jar`包放入镜像之中，然后用过`java -jar`命令直接启动即可，这里就会存在一个问题了，我们是在 `Jenkins` 的 `Pipeline` 中去进行镜像构建的，这个时候项目中并没有打包好的`jar`包文件，那么我们应该如何获取打包好的jar包文件呢？这里我们可以使用两种方法：

**第一种就是如果你用于镜像打包的 `Docker` 版本大于17.06版本的话，那么我墙裂推荐你使用 `Docker` 的多阶段构建功能来完成镜像的打包过程，** 我们只需要将上面的`Dockerfile`文件稍微更改下即可，将使用`maven`进行构建的工作放到同一个文件中：

```
FROM maven:3.6-alpine as BUILD

COPY src /usr/app/src
COPY pom.xml /usr/app

RUN mvn -f /usr/app/pom.xml clean package -Dmaven.test.skip=true

FROM openjdk:8-jdk-alpine

MAINTAINER jxi <xichao2014@gmail.com>

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV TZ=Asia/Shanghai

RUN mkdir /app

WORKDIR /app

COPY --from=BUILD /usr/app/target/polls-0.0.1-SNAPSHOT.jar /app/polls.jar

EXPOSE 8080

ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar","/app/polls.jar"]
```

[前面课程中我们就讲解过 `Docker` 的多阶段构建](https://github.com/Chao-Xi/JacobTechBlog/blob/master/docker/10docer_stages.md)，这里我们定义了两个阶段，第一个阶段利用`maven:3.6-alpine`这个基础镜像将我们的项目进行打包，然后将该阶段打包生成的`jar`包文件复制到第二阶段进行最后的镜像打包，这样就可以很好的完成我们的 `Docker `镜像的构建工作。

第二种方式就是我们传统的方式，在 `Jenkins Pipeline` 中添加一个`maven`构建的阶段，然后在第二个 `Docker` 构建的阶段就可以直接获取到前面的`jar`包了，也可以很方便的完成镜像的构建工作，为了更加清楚的说明 `Jenkins Pipeline` 的用法，我们这里采用这种方式，所以 `Dockerfile` 文件还是使用第一个就行。

**`FROM maven:3.6-alpine as BUILD`**

**`COPY --from=BUILD /usr/app/target/polls-0.0.1-SNAPSHOT.jar /app/polls.jar`**


现在我们可以将服务端的代码推送到 Gitlab 上去

> 注意，这里我们只推送的服务端代码。

### 客户端

客户端我们需要修改 `API` 的链接地址，修改文件`src/constants/index.js`中`API_BASE_URL`的地址，我们同样通过环境变量来进行区分，如果有环境变量`APISERVER_URL`，则优先使用这个环境变量来作为 `API` 请求的地址：

```
let API_URL = 'http://localhost:8080/api';
if (process.env.APISERVER_URL) {
    API_URL = `${process.env.APISERVER_URL}/api`;
}
export const API_BASE_URL = API_URL;
```

因为我们这里的项目使用的就是前后端分离的架构，所以我们同样需要将前端代码进行单独的部署，同样我们要将项目部署到 `Kubernetes` 环境中，所以也需要做容器化，同样在项目根目录下面添加一个`Dockerfile`文件：

```
FROM nginx:1.15.10-alpine
ADD build /usr/share/nginx/html

ADD nginx.conf
/etc/nginx/conf.d/default.conf
```

由于前端页面是单纯的静态页面，所以一般我们使用一个`nginx`镜像来运行，所以我们提供一个`nginx.conf`配置文件：

```
server {
    gzip on;

    listen       80;
    server_name  localhost;

    root   /usr/share/nginx/html;
    location / {
        try_files $uri /index.html;
        expires 1h;
    }

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }

}
```

这里我们可以看到我们需要将前面页面打包到一个`build`目录，然后将改目录添加到 `nginx` 镜像中的`/usr/share/nginx/html`目录，这样当 `nginx` 镜像启动的时候就是直接使用的改文件夹下面的文件。


所以现在我们需要获取打包后的目录`build`，同样的，和上面服务端项目一样，我们可以使用两种方式来完成这个工作。

第一种方式自然是推荐的 `Docker` 的多阶段构建，我们在一个`node`镜像的环境中就可以打包我们的前端项目了，所以我们可以更改下`Dockerfile`文件，先进行 `node` 打包，然后再进行 `nginx` 启动：

```
FROM node:alpine as BUILD

WORKDIR /usr/src/app

RUN mkdir -p /usr/src/app

ADD . /usr/src/app

RUN npm install && \
    npm run build

FROM nginx:1.15.10-alpine
MAINTAINER cnych <icnych@gmail.com>

COPY --from=BUILD /usr/src/app/build /usr/share/nginx/html

ADD nginx.conf
/etc/nginx/conf.d/default.conf
```

第二种方式和上面一样在 `Jenkins Pipeline` 中添加一个打包构建的阶段即可，我们这里采用这种方式，所以 `Dockerfile` 文件还是使用第一个就行。

现在我们可以将客户端的代码推送到 Gitlab 上去

## Jenkins

现在项目准备好了，接下来我们可以开始 Jenkins 的配置，还记得前面在 Pipeline 结合 Kubernetes 的课程中我们使用了一个kubernetes的 Jenkins 插件，但是之前使用的方式有一些不妥的地方，我们 Jenkins Pipeline 构建任务绑定到了一个固定的 Slave Pod 上面，这样就需要我们的 Slave Pod 中必须包含一系列构建所需要的依赖，比如 docker、maven、node、java 等等，这样就难免需要我们自己定义一个很庞大的 Slave 镜像，**我们直接直接在 Pipeline 中去自定义 Slave Pod 中所需要用到的容器模板，这样我们需要什么镜像只需要在 `Slave Pod Template `中声明即可，完全不需要去定义一个庞大的 `Slave` 镜像了。**

首先去掉 `Jenkins` 中 `kubernetes` 插件中的 `Pod Template` 的定义，`Jenkins -> 系统管理 -> 系统设置 -> 云 -> Kubernetes区域`，删除下方的`Kubernetes Pod Template` -> 保存。

![Alt Image Text](images/4_3.jpg "Headline image")

然后新建一个名为`polling-app-server`类型为流水线(Pipeline)的任务：

![Alt Image Text](images/4_4.jpg "Headline image")

然后在这里需要勾选触发远程构建的触发器，其中令牌我们可以随便写一个字符串，然后记住下面的 URL，将 JENKINS_URL 替换成 `Jenkins` 的地址,我们这里的地址就是：`http://jenkins.example.com/job/polling-app-server/build?token=server321`

![Alt Image Text](images/4_5.jpg "Headline image")

然后在下面的流水线区域我们可以选择`Pipeline script`然后在下面测试流水线脚本，我们这里选择`Pipeline script from SCM`，意思就是从代码仓库中通过`Jenkinsfile`文件获取`Pipeline script`脚本定义，然后选择 `SCM` 来源为`Git`，在出现的列表中配置上仓库地址`http://git.example.com/course/polling-app-server.git`，由于我们是在一个 `Slave Pod` 中去进行构建，**所以如果使用 `SSH` 的方式去访问 `Gitlab` 代码仓库的话就需要频繁的去更新 `SSH-KEY`，所以我们这里采用直接使用用户名和密码的形式来方式**：

![Alt Image Text](images/4_6.jpg "Headline image")

在`Credentials`区域点击添加按钮添加我们访问 `Gitlab` 的用户名和密码：

![Alt Image Text](images/4_7.jpg "Headline image")

然后需要我们配置用于构建的分支，如果所有的分支我们都想要进行构建的话，只需要将`Branch Specifier`区域留空即可，一般情况下不同的环境对应的分支才需要构建，比如 **master、develop、test** 等，平时开发的 `feature` 或者 `bugfix` 的分支没必要频繁构建，我们这里就只配置 `master` 和 `develop` 两个分支用户构建：

![Alt Image Text](images/4_8.jpg "Headline image")

然后前往 Gitlab 中配置项目`polling-app-server Webhook`，`settings -> Integrations`，填写上面得到的 `trigger` 地址：

保存后，可以直接点击`Test -> Push Event`测试是否可以正常访问 `Webhook` 地址，**这里需要注意的是我们需要配置下 `Jenkins` 的安全配置，否则这里的触发器没权限访问 `Jenkins`**，**`系统管理 -> 全局安全配置`：取消防止跨站点请求伪造，勾选上匿名用户具有可读权限**：

![Alt Image Text](images/4_9.jpg "Headline image")

**如果测试出现了`Hook executed successfully: HTTP 201`则证明 `Webhook` 配置成功了，否则就需要检查下 Jenkins 的安全配置是否正确了。**

配置成功后我们只需要往 `Gitlab` 仓库推送代码就会触发 `Pipeline` 构建了。接下来我们直接在服务端代码仓库根目录下面添加`Jenkinsfile`文件，用于描述流水线构建流程。

首先定义最简单的流程，要注意这里和前面课程的不同之处，这里我们使用`podTemplate`来定义不同阶段使用的的容器，有哪些阶段呢？

`Clone 代码 -> 代码静态分析 -> 单元测试 -> Maven 打包 -> Docker 镜像构建/推送 -> Helm 更新服务`。

* `Clone` 代码在默认的 `Slave` 容器中即可；
* 静态分析和单元测试我们这里直接忽略，有需要这个阶段的同学自己添加上即可；
* `Maven` 打包肯定就需要 `Maven` 的容器了；
* `Docker` 镜像构建/推送是不是就需要 Docker 环境了呀；
* 最后的 `Helm` 更新服务是不是就需要一个有 Helm 的容器环境了，所以我们这里就可以很简单的定义`podTemplate`了，如下定义：(添加一个kubectl工具用于测试)

```
def label = "slave-${UUID.randomUUID().toString()}"

podTemplate(label: label, containers: [
  containerTemplate(name: 'maven', image: 'maven:3.6-alpine', command: 'cat', ttyEnabled: true),
  containerTemplate(name: 'docker', image: 'docker', command: 'cat', ttyEnabled: true),
  containerTemplate(name: 'kubectl', image: 'cnych/kubectl', command: 'cat', ttyEnabled: true),
  containerTemplate(name: 'helm', image: 'cnych/helm', command: 'cat', ttyEnabled: true)
], volumes: [
  hostPathVolume(mountPath: '/root/.m2', hostPath: '/var/run/m2'),
  hostPathVolume(mountPath: '/home/jenkins/.kube', hostPath: '/root/.kube'),
  hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock')
]) {
  node(label) {
    def myRepo = checkout scm
    def gitCommit = myRepo.GIT_COMMIT
    def gitBranch = myRepo.GIT_BRANCH

    stage('单元测试') {
      echo "测试阶段"
    }
    stage('代码编译打包') {
      container('maven') {
        echo "打码编译打包阶段"
      }
    }
    stage('构建 Docker 镜像') {
      container('docker') {
        echo "构建 Docker 镜像阶段"
      }
    }
    stage('运行 Kubectl') {
      container('kubectl') {
        echo "查看 K8S 集群 Pod 列表"
        sh "kubectl get pods"
      }
    }
    stage('运行 Helm') {
      container('helm') {
        echo "查看 Helm Release 列表"
        sh "helm list"
      }
    }
  }
}
```

### 上面这段`groovy`脚本比较简单，我们需要注意的是`volumes`区域的定义，

* 将容器中的`/root/.m2`目录挂载到宿主机上是为了给`Maven`构建添加缓存的，不然每次构建的时候都需要去重新下载依赖，这样就非常慢了；
* 挂载`.kube`目录是为了能够让`kubectl`和`helm`两个工具可以读取到 `Kubernetes` 集群的连接信息，不然我们是没办法访问到集群的；
* 最后挂载`/var/run/docker.sock`文件是为了能够让我们的`docker`这个容器获取到`Docker Daemon`的信息的，因为`docker`这个镜像里面只有客户端的二进制文件，我们需要使用宿主机的`Docker Daemon`来构建镜像，
* 当然我们也需要在运行` Slave Pod` 的节点上拥有访问集群的文件，然后在每个`Stage`阶段使用特定需要的容器来进行任务的描述即可，所以这几个volumes都是非常重要的

```
volumes: [
  hostPathVolume(mountPath: '/root/.m2', hostPath: '/var/run/m2'),
  hostPathVolume(mountPath: '/home/jenkins/.kube', hostPath: '/root/.kube'),
  hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock')
]
```

另外一个值得注意的就是`label`标签的定义，我们这里使用 `UUID` 生成一个随机的字符串，这样可以让 `Slave Pod` 每次的名称都不一样，而且这样就不会被固定在一个 `Pod` 上面了，以后有多个构建任务的时候就不会存在等待的情况了，这和我们之前的课程中讲到的固定在一个 `label` 标签上有所不同。

然后我们将上面的`Jenkinsfile`文件提交到 Gitlab 代码仓库上：

```
$ git add Jenkinsfile
$ git commit -m "添加 Jenkinsfile 文件"
$ git push origin master
```

然后切换到 Jenkins 页面上，正常情况就可以看到我们的流水线任务`polling-app-server`已经被触发构建了，然后回到我们的 `Kubernetes` 集群中可以看到多了一个 `slave` 开头的 `Pod`，里面有5个容器，就是我们上面 `podTemplate` 中定义的`4个`容器，加上一个默认的 `jenkins slave` 容器，同样的，构建任务完成后，这个 Pod 也会被自动销毁掉：

```
$ kubectl get pods -n kube-ops
NAME                                                      READY     STATUS    RESTARTS   AGE
jenkins-7fbfcc5ddc-xsqmt                                  1/1       Running   0          1d
slave-6e898009-62a2-4798-948f-9c80c3de419b-0jwml-6t6hb   5/5       Running   0          36s
......
```

正常可以看到 `Jenkins` 中的任务构建成功了：

![Alt Image Text](images/4_10.jpg "Headline image")






































