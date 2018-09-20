![Alt Image Text](images/adv/adv15_0.jpg "Headline image")
## Pod 中挂载单个文件的方法

有很多同学发现在`Pod`中通过`volume`挂载数据的时候，**如果挂载目录下原来有文件，挂载后将被覆盖掉**。有的时候，我们希望**将文件挂载到某个目录，但希望只是挂载该文件，不要影响挂载目录下的其他文件**。有办法吗？

### 可以用`subPath`，`subPath`的目的是为了在单一`Pod`中多次使用同一个`volume`而设计的。

示例：

## 比如我们要通过`ConfigMap`的形式挂载 `Nginx` 的配置文件：

### 1.保存下面文件为：`nginx.conf`

```
user  nginx;
worker_processes  1;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                        '$status $body_bytes_sent "$http_referer" '
                        '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    #gzip  on;

    include /etc/nginx/conf.d/*.conf;
}

```

### 2.通过文件创建`ConfigMap`对象：

```
$ kubectl create configmap confnginx --from-file=nginx.conf
```

```
$ kubectl get cm
NAME        DATA      AGE
confnginx   1         23s
```

```
$ kubectl describe cm  confnginx
Name:         confnginx
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
nginx.conf:
----
user  nginx;
worker_processes  1;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                        '$status $body_bytes_sent "$http_referer" '
                        '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    #gzip  on;

    include /etc/nginx/conf.d/*.conf;
}

Events:  <none>
```

### 3.创建一个 `nginx` 的 `Pod`，通过上面的 `configmap` 挂载 `nginx.conf` 配置文件，保存为 `nginx.yaml`：

```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: ngtest
spec:
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
          volumeMounts:
            - name: nginx-config
              mountPath: /etc/nginx/nginx.conf
              subPath: nginx.conf
      volumes:
        - name: nginx-config
          configMap:
            name: confnginx
```


### 4.创建上面的`Deployment`：

```
$ kubectl apply -f nginx.yaml

deployment "ngtest" created
```

### 5.验证： 下面是我们生成的 `Pod`，看状态可以看出已经正常运行了

```
$ kubectl get pods -o wide

NAME                        READY     STATUS    RESTARTS   AGE       IP            NODE
ngtest-7bc778df5c-kmmt7     1/1       Running   0          35s       172.17.0.5    192.168.1.138
```

现在我们进入容器中查看下 `nginx.conf ` 文件：

```
$ kubectl exec -it ngtest-7bc778df5c-kmmt7 /bin/bash
root@ngtest-7bc778df5c-kmmt7:/# ls /etc/nginx/
conf.d	fastcgi_params	koi-utf  koi-win  mime.types  nginx.conf  scgi_params  uwsgi_params  win-utf
root@ngtest-7bc778df5c-kmmt7:/# cat /etc/nginx/nginx.conf
user  nginx;
worker_processes  1;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                        '$status $body_bytes_sent "$http_referer" '
                        '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    #gzip  on;

    include /etc/nginx/conf.d/*.conf;
}
root@ngtest-7bc778df5c-kmmt7:/#

```

可以看到 `nginx.conf` 文件正是我们上面的 `ConfigMap` 对象中的内容，验证成功。

6.原理： 下面是绑定 `subPath` 的源码部分，我们可以看到下面的 `t.Model()&os.ModeDir` 部分，如果 `subPath` **是一个文件夹的话就会去创建这个文件夹，如果是文件的话就可以进行单独挂载了**。


```
func doBindSubPath(mounter Interface, subpath Subpath, kubeletPid int) (hostPath string, err error) {
    ...
    // Create target of the bind mount. A directory for directories, empty file
    // for everything else.
    t, err := os.Lstat(subpath.Path)
    if err != nil {
        return "", fmt.Errorf("lstat %s failed: %s", subpath.Path, err)
    }
    if t.Mode() & os.ModeDir > 0 {
        if err = os.Mkdir(bindPathTarget, 0750); err != nil && !os.IsExist(err) {
            return "", fmt.Errorf("error creating directory %s: %s", bindPathTarget, err)
        }
    } else {
        // "/bin/touch <bindDir>".
        // A file is enough for all possible targets (symlink, device, pipe,
        // socket, ...), bind-mounting them into a file correctly changes type
        // of the target file.
        if err = ioutil.WriteFile(bindPathTarget, []byte{}, 0640); err != nil {
            return "", fmt.Errorf("error creating file %s: %s", bindPathTarget, err)
        }
    }
    ...
}
```





