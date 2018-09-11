# Kubernetes对象详解 

## Secret

### Secret类型

`Opaque`:base64编码格式的Secret，用来存储密码、密钥等;但数据也通过`base64 --decode` 解码得到原始数据，所有加密性很弱。

`kubernetes.io/dockerconfigjson`:用来存储私有`docker registry`的认证信息。

`kubernetes.io/service-account-token`: 用于被`serviceaccount`引用。`serviceaccout`创建时 `Kubernetes`会默认创建对应的`secret`。Pod如果使用了`serviceaccount`，对应的`secret`会自动挂载到`Pod`的`/run/secrets/kubernetes.io/serviceaccount`目录中。

## 存储加密

v1.7+版本支持将`Secret数据`加密存储到`etcd`中，只需要在`apiserver`启动时配置`--experimental-encryption-provider-config`。

`resources.resources`是`Kubernetes`的资源名

`resources.providers`是加密方法，支持以下几种:

```
identity:不加密
aescbc:AES-CBC加密
secretbox:XSalsa20和Poly1305加密 
aesgcm:AES-GCM加密
```

```
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
    - secrets
    providers
    - aescbc:
        keys:
        - name: key1
          secret: c2VjcmV0IGlzIHNlY3VyZQ==
        - name: key2
          secret: dGhpcyBpcyBwYXNzd29yZA==
    - identity: {}
    - aesgcm:
        keys:
        - name: key1
          secret: c2VjcmV0IGlzIHNlY3VyZQ==
        - name: key2
          secret: dGhpcyBpcyBwYXNzd29yZA==
    - secretbox:
        keys:
        - name: key1
          secret: YWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXoxMjM0NTY=
```

## Secret与ConfigMap对比

### 相同点:
          

* key/value的形式
* 属于某个特定的namespace
* 可以导出到环境变量
* 可以通过目录/文件形式挂载(支持挂载所有key和部分key)
            
      
### 不同点:

* Secret可以被ServerAccount关联(使用)
* Secret可以存储register的鉴权信息，用在ImagePullSecret参数中，用于拉取私有仓库的镜像
* Secret支持Base64加密
* Secret分为Opaque，kubernetes.io/ServiceAccount，kubernetes.io/dockerconfigjson三种类型, Configmap不区分类型
* Secret文件存储在tmpfs文件系统中，Pod删除后Secret文件也会对应的删除。
      

