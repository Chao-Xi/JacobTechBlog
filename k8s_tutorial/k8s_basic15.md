# Kubernetes对象详解 

## ConfigMap

### `ConfigMap`用于保存配置数据的键值对:

* 可以用来**保存单个属性**，

* 也可以用来**保存配置文件**。 

* `ConfigMap`跟`secret`很类似，**但它可以更方便地处理不包含敏感信息的字符串**。

可以使用`kubectl create configmap`从`文件`、`目录`或者`key-value字符串`创建等创建`ConfigMap`。 也可以

```
kubectl create configmap
```

通过`kubectl create -f file`创建

```
kubectl create -f file
```

## 从`key-value`字符串创建

```
$ kubectl create configmap special-config --from-literal=special.how=very configmap "special- config"
```

```
created $ kubectl get configmap special-config -o go-template='{{.data}}' map[special.how:very]
```

## 从env文件创建

```
$ echo -e "a=b\nc=d" | tee config.env
a=b
c=d
```

```
$ kubectl create configmap special-config --from-env-file=config.env
configmap "special-config" created
```
```
$ kubectl get configmap
NAME                        DATA      AGE
special-config              2         20s
```
```
$ kubectl describe configmap special-config
Name:         special-config
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
c:
----
d
a:
----
b
Events:  <none>
```

```
$ kubectl get configmap special-config -o go-template='{{.data}}'

map[a:b c:d]

```

## 从目录创建

```
$ mkdir config
$ echo a>config/a
$ echo b>config/b
$ kubectl create configmap special-config1 --from-file=config/
  configmap "special-config1" created
  
$ kubectl get configmap special-config1 -o go-template='{{.data}}'

map[a:a
 b:b
]

```

## 从Spec文件创建

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: special-config2
  namespace: default
data:
  special.how: very
  special.type: charm 
```

```
$ kubectl create -f special-config2.yaml
configmap "special-config2" created
```

```
$ kubectl get configmap special-config2 -o go-template='{{.data}}'
map[special.how:very special.type:charm]
```


## 用作环境变量

```
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
spec:
  containers:
    - name: test-container
      image: gcr.io/google_containers/busybox
      command: [ "/bin/sh", "-c", "env" ]
      env:
        - name: SPECIAL_LEVEL_KEY
          valueFrom:
            configMapKeyRef:
              name: special-config
              key: special.how
        - name: SPECIAL_TYPE_KEY
          valueFrom:
            configMapKeyRef:
              name: special-config
              key: special.type
      envFrom:
        - configMapRef:
            name: env-config 
  restartPolicy: Never          
```

## 挂载volume

```
apiVersion: v1
kind: Pod
metadata:
  name: vol-test-pod
spec:
  containers:
    - name: test-container
      image: gcr.io/google_containers/busybox
      command: [ "/bin/sh", "-c", "cat/etc/config/special.how" ]
      volumeMounts:
      - name: config-volume
        mountPath: /etc/config
  volumes:
    - name: config-volume
      configMap:
        name: special-config
  restartPolicy: Never
```
 
```
$ kubectl create -f vol-test-pod.yaml
pod "vol-test-pod" created
```

```
$ kubectl get pods --show-all
NAME                            READY     STATUS      RESTARTS   AGE
vol-test-pod                    0/1       Error       0          14m
```

```
kubectl logs  vol-test-pod
/bin/sh: cat/etc/config/special.how: not found
```

     
        
