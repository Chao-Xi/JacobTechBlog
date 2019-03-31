# Jenkins集成Ant

## 1. 先决条件

下载. [Download](https://ant.apache.org/bindownload.cgi)

![Alt Image Text](images/6_1.png "body image")

## 2.安装ant

```
tar zxf apache-ant-1.10.5-bin.tar.gz -C /usr/local/
#添加全局变量（/etc/profile）
export ANT_HOME=/usr/local/apache-ant-1.10.5
export PATH=$PATH:$MAVEN_HOME/bin:$ANT_HOME/bin
source /etc/profile
```

**测试**

![Alt Image Text](images/6_2.png "body image")

```
ant -version
```

## 3 Jenkins配置ant


![Alt Image Text](images/6_3.png "body image")

**编写Jenkinsfile**

```
node {
    stage ("build"){
        antHome = tool 'ANT'
        sh "${antHome}/bin/ant -version"
    }
}
```

**构建测试**

![Alt Image Text](images/6_4.png "body image")

到此ant的集成就完成了

## 4.Ant常用命令

```
ant -buildfile -f build.xml
```

