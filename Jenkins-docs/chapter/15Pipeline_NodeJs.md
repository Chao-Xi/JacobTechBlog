# 第六章 前端发布流水线（NodeJs）

## 1. 项目设置

项目配置部分主要是将网站源代码上传到github，然后搭建用户访问的web服务器。再经过Jenkins配置发布代码到web服务器。

### 1.1 项目代码托管

* **将项目源代码上传到GitHub**

[https://github.com/alex1504/alex1504.github.io](https://github.com/alex1504/alex1504.github.io)

![Alt Image Text](images/15_1.png "Headline image")

### 1.2 搭建前端Nginx服务

* 安装Nginx服务

```
yum -y install nginx 
service nginx start 
chkconfig nginx on
```

* 创建站点目录

```
mkdir -p /opt/nginx/myweb
```

* 配置Nginx

```
vim /etc/nginx/conf.d/default.conf

server {
    listen       80 default_server;
    server_name  www.xxxxx.com;

    include /etc/nginx/default.d/*.conf;

    location / {
        root /opt/nginx/myweb;
        index index.html ;
    }
    
    error_page 404 /404.html;
        location = /40x.html {
    }

    error_page 500 502 503 504 /50x.html;
        location = /50x.html {
    }

}

service nginx restart
```

## 2. Jenkins配置

### 2.1 创建项目

* 业务名称: cxy
* 应用名称: cxy-vuedemo-ui
* 应用服务器: VM_7_14_centos
* 站点目录: /opt/nginx/myweb
* 服务端口: 80
* 发布用户: nginx
* 发布分支: master
* 项目地址: http://github.com/xxxx/cxy-webdemo-ui.git

![Alt Image Text](images/15_2.png "Headline image")

### 2.2 编写Jenkinsfile

```
#!groovy


//Getcode
String srcUrl = "${env.srcUrl}".trim()
String branchName = "${env.branchName}".trim()

//Global 
String workspace = "/opt/jenkins/workspace"
String targetHosts = "${env.targetHosts}".trim()
String credentialsId = "24982560-17fc-4589-819b-bc5bea89da77"
String serviceName = "${env.serviceName}".trim()
String port = "${env.port}".trim()
String user = "${env.user}".trim()
String targetDir = "${env.targetDir}".trim()
  

//Build
String buildShell = "${env.buildShell}".trim()

//代码检出
def GetCode(srcUrl,branchName,credentialsId) {
    checkout([$class: 'GitSCM', branches: [[name: "${pathName}"]], 
        doGenerateSubmoduleConfigurations: false, 
        extensions: [], submoduleCfg: [], 
        userRemoteConfigs: [[credentialsId: "${credentialsId}", 
        url: "${srcUrl}"]]])
}


//Pipeline

ansiColor('xterm') {
    node("master"){
        ws("${workspace}") {
            //Getcode
            stage("GetCode"){
                GetCode(srcUrl,branchName,credentialsId)
            }
            
            //Build
            stage("RunBuild"){
                sh """ 
                    ${buildShell} 
                    cd dist && tar zcf ${serviceName}.tar.gz * 
                    mkdir -p /srv/salt/${JOB_NAME}/
                    rm -fr /srv/salt/${JOB_NAME}/*
                    mv ${serviceName}.tar.gz /srv/salt/${JOB_NAME}/
                    
                   """
            }
            
            
            //Deploy
            stage("RunDeploy"){
                sh """ 
                    salt ${targetHosts} cmd.run "rm -fr ${targetDir}/*"
                    salt ${targetHosts} cp.get_file "salt://${JOB_NAME}/${serviceName}.tar.gz ${targetDir}/${serviceName}.tar.gz makedirs=True "
                    salt ${targetHosts} cmd.run "cd ${targetDir} && tar zxf ${serviceName}.tar.gz "
                    salt ${targetHosts} cmd.run "chown ${user}:${user} ${targetDir} -R  "
                    salt ${targetHosts} cmd.run "ls -l "
                
       
                   """
            
            }
        }              
    }       
}
```

## 3.构建测试


![Alt Image Text](images/15_3.png "Headline image")


