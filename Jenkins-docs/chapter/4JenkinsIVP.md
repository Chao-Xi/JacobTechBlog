# 第三章 管理Jenkins（项目、视图、插件）


## 1. 项目管理

### 1.1 命名规范

**业务名称-应用名称-应用类型_环境类型**： `cxy-wlck-ui_TEST`, **只有命名规范才方便管理项目**。

### 1.2 新建项目

![Alt Image Text](images/4_1.png "Body image") 

**设置构建历史**

![Alt Image Text](images/4_2.png "Body image") 

**选择参数化构建**

![Alt Image Text](images/4_3.png "Body image") 

**设置构建触发器**

![Alt Image Text](images/4_4.png "Body image") 

**设置Jenkinsfile**

![Alt Image Text](images/4_5.png "Body image") 

**构建项目**

![Alt Image Text](images/4_6.png "Body image") 

**查看构建日志**

![Alt Image Text](images/4_7.png "Body image") 

**调试Pipeline**

![Alt Image Text](images/4_8.png "Body image") 


### 1.3 删除/禁用项目

![Alt Image Text](images/4_9.png "Body image") 

### 1.4 项目分类

* 以业务简称为名，创建工程文件夹。将同一个业务的工程全部放到同一个文件夹中。 

![Alt Image Text](images/4_10.png "Body image") 

* 移动项目 

![Alt Image Text](images/4_11.png "Body image") 

* 外部

![Alt Image Text](images/4_13.png "Body image") 

* 内部

![Alt Image Text](images/4_14.png "Body image") 

## 2. 视图管理

**默认会创建一个all视图里面存放所有的项目。**

### 2.1 创建视图

**凭据-> 系统-> 全局凭据**

![Alt Image Text](images/4_15.png "Body image") 

![Alt Image Text](images/4_16.png "Body image") 

![Alt Image Text](images/4_17.png "Body image") 


### 2.2 删除视图

![Alt Image Text](images/4_18.png "Body image") 

### 2.3 更新视图

![Alt Image Text](images/4_19.png "Body image") 


## 3. 插件管理

**系统设置->插件管理**

![Alt Image Text](images/4_20.png "Body image") 

### 3.1 安装插件

**勾选要安装的插件，选择安装后不重启。（有些插件需要安装后重启）**

![Alt Image Text](images/4_21.png "Body image") 

**安装**

![Alt Image Text](images/4_22.png "Body image") 

### 3.2 卸载插件

![Alt Image Text](images/4_23.png "Body image") 

### 3.3 上传插件

![Alt Image Text](images/4_24.png "Body image") 

### 3.4 切换插件更新站点

![Alt Image Text](images/4_25.png "Body image") 

