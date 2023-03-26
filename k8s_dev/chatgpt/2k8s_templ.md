# 2 使用 OpenAI GPT 生成和应用 Kubernetes 清单

## Kubectl OpenAI插件 ✨

该项目是一个kubectl插件，使用OpenAI GPT生成和应用Kubernetes清单。

[https://github.com/sozercan/kubectl-ai](https://github.com/sozercan/kubectl-ai)

### 用法

**先决条件**

`kubectl-ai`需要OpenAI API密钥或Azure OpenAI服务 API密钥和端点以及有效的Kubernetes配置。

对于OpenAI和Azure OpenAI，您可以使用以下环境变量：

```
export OPENAI_API_KEY=<your OpenAI key>
export OPENAI_DEPLOYMENT_NAME=<your OpenAI deployment/model name. defaults to "gpt-3.5-turbo">
```

支持以下模型：

* code-davinci-002
* text-davinci-003
* gpt-3.5-turbo-0301（Azure的部署必须命名为gpt-35-turbo-0301）
* gpt-3.5-turbo
* gpt-35-turbo-0301


对于Azure OpenAI服务，您可以使用以下环境变量：

```
export AZURE_OPENAI_ENDPOINT=<your Azure OpenAI endpoint, like "<https://my-aoi-endpoint.openai.azure.com>">
```

如果设置了`AZURE_OPENAI_ENDPOINT`变量，则将使用Azure OpenAI服务。否则，它将使用OpenAI API。

**安装**

* 从GitHub releases下载二进制文件。
* 如果您想将其用作[kubectl插件](https://kubernetes.io/docs/tasks/extend-kubectl/kubectl-plugins/)，则将kubectl-ai二进制文件复制到您的PATH。如果不是，则也可以单独使用二进制文件。


**标志和环境变量**

* 可以设置`-require-confirmation`标志或`REQUIRE_CONFIRMATION`环境变量，以在应用清单之前提示用户进行确认。默认为true。
* 可以将`-temperature`标志或`TEMPERATURE`环境变量设置在0到1之间。较高的温度将导致更具创意的完成。较低的温度将导致更确定性的完成。默认为0。

```
subl .bash_profile
```

创建具有特定值的对象：

```
$ kubectl ai "create an nginx deployment with 3 replicas"
✨ 尝试应用以下清单：
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
EOF
使用箭头键导航：↓ ↑ → ←
? 是否要应用此内容？[应用/不应用]：
  ▸ 应用
    不应用
```

```
$ kubectl ai "scale nginx-deployment to 5 replicas"
✨ 尝试应用以下清单：
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 5
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
EOF
使用箭头键导航：↓ ↑ → ←
? 是否要应用此内容？[应用/不应用]：
  ▸ 应用
    不应用
```

可选的`--require-confirmation`标志：

```

$ kubectl ai "create a service with type LoadBalancer with selector as 'app:nginx'" --require-confirmation=false
✨ 尝试应用以下清单：
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer
```

多个对象：

```
$ kubectl ai "create a foo namespace then create nginx pod in that namespace"
✨ 尝试应用以下清单：
apiVersion: v1
kind: Namespace
metadata:
  name: foo
---
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  namespace: foo
spec:
  containers:
  - name: nginx
    image: nginx:latest
EOF
使用箭头键导航：↓ ↑ → ←
? 是否要应用此内容？[应用/不应用]：
  ▸ 应用
    不应用
```

