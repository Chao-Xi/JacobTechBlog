![Alt Image Text](images/adv/adv22_0.jpg "Headline image")
# 健康检查

`PostStart`与`PreStop`，

* 其中`PostStart`是在容器创建后立即执行的，
* 而`PreStop`这个钩子函数则是在容器终止之前执行的。

除了上面这两个钩子函数以外，**还有一项配置会影响到容器的生命周期的，那就是健康检查的探针**。

在 `Kubernetes` 集群当中，我们可以通过配置`liveness probe（存活探针）`和 `readiness probe（可读性探针）` 来影响容器的生存周期。

### `kubelet` 通过使用 `liveness probe` 来确定你的`应用程序是否正在运行，通俗点将就是是否还活着`。一般来说，如果你的程序一旦崩溃了， `Kubernetes` 就会立刻知道这个程序已经终止了，然后就会重启这个程序。而我们的 `liveness probe` 的`目的就是来捕获到当前应用程序还没有终止，还没有崩溃`，如果出现了这些情况，那么就重启处于该状态下的容器，使应用程序在存在 `bug` 的情况下依然能够继续运行下去。

### `kubelet` 使用 `readiness probe` 来确定`容器是否已经就绪可以接收流量过来了。这个探针通俗点讲就是说是否准备好了，现在可以开始工作了`。只有当 `Pod` 中的容器都处于就绪状态的时候 `kubelet` 才会认定该 `Pod` 处于就绪状态，因为一个 `Pod` 下面可能会有`多个容器`。当然 `Pod` 如果处于`非就绪状态`，那么我们就会将他从我们的工作队列(实际上就是我们后面需要重点学习的 `Service`)中移除出来，这样我们的流量就不会被路由到这个 `Pod` 里面来了。

和前面的钩子函数一样的，我们这两个探针的支持两种配置方式：

* `exec`：执行一段命令
* `http`：检测某个 `http` 请求
* `tcpSocket`：使用此配置， `kubelet` 将尝试在**指定端口上打开容器的套接字**。如果可以建立连接，容器被认为是健康的，如果不能就认为是失败的。实际上就是**检查端口**

好，我们先来给大家演示下存活探针的使用方法，首先我们用 `exec` 执行命令的方式来检测容器的存活，如下:

```
apiVersion: v1
kind: Pod
metadata:
  name: liveness-exec
  labels:
    test: liveness
spec:
  containers:
  - name: liveness
    image: busybox
    args:
    - /bin/sh
    - -c
    - touch /tmp/healthy; sleep 30; rm -rf /tmp/healthy; sleep 600
    livenessProbe:
      exec:
        command:
        - cat
        - /tmp/healthy
      initialDelaySeconds: 5
      periodSeconds: 5
```


```
livenessProbe:
  exec:
    command:
      - cat
      - /tmp/healthy
    initialDelaySeconds: 5
    periodSeconds: 5
```

我们这里需要用到一个新的属性：`livenessProbe`，下面通过`exec`执行一段命令，其中`periodSeconds`属性表示让`kubelet`每隔5秒执行一次存活探针，也就是每`5`秒执行一次上面的`cat /tmp/healthy`命令，如果命令执行成功了，将返回`0`，那么`kubelet`就会认为当前这个容器是存活的并且很监控，如果返回的是`非0`值，那么`kubelet`就会把该容器杀掉然后重启它。另外一个属性`initialDelaySeconds`表示在**第一次执行探针的时候要等待5秒**，这样能够确保我们的**容器能够有足够的时间启动起来**。大家可以想象下，如果你的第一次执行探针等候的时间太短，是不是很有可能容器还没正常启动起来，所以存活探针很可能始终都是失败的，这样就会无休止的重启下去了，对吧？所以一个合理的`initialDelaySeconds`非常重要。

另外我们在容器启动的时候，执行了如下命令：

```
~ /bin/sh -c "touch /tmp/healthy; sleep 30; rm -rf /tmp/healthy; sleep 600"
```
* 意思是说在容器最开始的`30`秒内有一个`/tmp/healthy`文件，在这`30秒`内执行`cat /tmp/healthy`命令都会返回一个成功的返回码。
* `30`秒后，我们删除这个文件，现在执行`cat /tmp/healthy`是不是就会失败了，这个时候就会重启容器了

我们来创建下该`Pod`，在`30`秒内，查看`Pod`的`Event`：

我们可以观察到容器是正常启动的，在隔一会儿，比如`40s`后，再查看下`Pod`的`Event`，在最下面有一条信息显示 `liveness probe`失败了，容器被删掉并重新创建。

然后通过`kubectl get pod liveness-exec`可以看到`RESTARTS`值加`1`了。

```
$ kubectl create -f livenessProbe.yaml

# after 40 s
$ kubectl describe pod liveness-exec

...
Restart Count:  0
    Liveness:       exec [cat /tmp/healthy] delay=5s timeout=1s period=5s #success=1 #failure=3
Normal   Created                1m                 kubelet, 192.168.1.138  Created container
  Normal   Started                1m                 kubelet, 192.168.1.138  Started container
  Warning  Unhealthy              17s (x3 over 27s)  kubelet, 192.168.1.138  Liveness probe failed: cat: can't open '/tmp/healthy': No such file or directory
  
    
$ kubectl describe pod liveness-exec
Restart Count:  1
    Liveness:       exec [cat /tmp/healthy] delay=5s timeout=1s period=5s #success=1 #failure=3
Normal   Killing                28s               kubelet, 192.168.1.138  Killing container with id docker://liveness:Container failed liveness probe.. Container will be killed and recreated.
  Normal   Pulled                 22s (x2 over 1m)  kubelet, 192.168.1.138  Successfully pulled image "busybox"
  Normal   Created                22s (x2 over 1m)  kubelet, 192.168.1.138  Created container
  Normal   Started                22s (x2 over 1m)  kubelet, 192.168.1.138  Started container
```
   



同样的，我们还可以使用`HTTP GET`请求来配置我们的存活探针，我们这里使用一个`liveness`镜像来验证演示下，

```
apiVersion: v1
kind: Pod
metadata:
  labels:
    test: liveness
  name: liveness-http
spec:
  containers:
  - name: liveness
    image: cnych/liveness
    args:
    - /server
    livenessProbe:
      httpGet:
        path: /healthz
        port: 8080
        httpHeaders:
        - name: X-Custom-Header
          value: Awesome
      initialDelaySeconds: 3
      periodSeconds: 3
```

同样的，根据`periodSeconds`属性我们可以知道`kubelet`需要每隔`3`秒执行一次`liveness probe`，该探针将向容器中的 `server` 的`8080`端口发送一个 `HTTP GET `请求。如果 `server` 的 `/healthz` 路径的 `handler` 返回一个成功的返回码，`kubelet`就会认定该容器是活着的并且很健康,如果返回失败的返回码，`kubelet`将杀掉该容器并重启它。`initialDelaySeconds` 指定`kubelet`在该执行第一次探测之前需要等待3秒钟。

通常来说，任何大于`200`小于`400`的返回码都会认定是成功的返回码。其他返回码都会被认为是失败的返回码。

我们可以来查看下上面的`healthz`的实现：

```
http.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
    duration := time.Now().Sub(started)
    if duration.Seconds() > 10 {
        w.WriteHeader(500)
        w.Write([]byte(fmt.Sprintf("error: %v", duration.Seconds())))
    } else {
        w.WriteHeader(200)
        w.Write([]byte("ok"))
    }
})
```

大概意思就是最开始前`10s`返回状态码`200`，`10s`过后就返回`500`的`status_code`了。所以当容器启动`3`秒后，`kubelet` 开始执行健康检查。第一次健康监测会成功，因为是在`10s`之内，但是`10秒`后，健康检查将失败，因为现在返回的是一个错误的状态码了，所以`kubelet`将会`杀掉`和`重启`容器。

同样的，我们来创建下该Pod测试下效果，10秒后，查看 `Pod` 的 `event`，确认`liveness probe`失败并重启了容器。

```
kubectl describe pod liveness-http
```

然后我们来通过端口的方式来配置存活探针，使用此配置，`kubelet`将尝试在指定端口上打开容器的套接字。 如果可以建立连接，容器被认为是健康的，如果不能就认为是失败的。

```
apiVersion: v1
kind: Pod
metadata:
  name: goproxy
  labels:
    app: goproxy
spec:
  containers:
  - name: goproxy
    image: cnych/goproxy
    ports:
    - containerPort: 8080
    readinessProbe:
      tcpSocket:
        port: 8080
      initialDelaySeconds: 5
      periodSeconds: 10
    livenessProbe:
      tcpSocket:
        port: 8080
      initialDelaySeconds: 15
      periodSeconds: 20
```

我们可以看到，`TCP` 检查的配置与 `HTTP` 检查非常相似，只是将`httpGet`替换成了`tcpSocket`。 而且我们同时使用了`readiness probe`和`liveness probe`两种探针。 容器启动后`5`秒后，`kubelet`将发送第一个`readiness probe（可读性探针）`。 该探针会去连接容器的`8080`端，如果连接成功，则该 `Pod` 将被标记为就绪状态。然后`Kubelet`将每隔`10`秒钟执行一次该检查。

除了`readiness probe`之外，该配置还包括`liveness probe`。 容器启动`15`秒后，`kubelet`将运行第一个 `liveness probe`。 就像`readiness probe`一样，这将尝试去连接到容器的`8080`端口。如果`liveness probe`失败，容器将重新启动。

```
readinessProbe:
      tcpSocket:
        port: 8080
      initialDelaySeconds: 5
      periodSeconds: 10
    livenessProbe:
      tcpSocket:
        port: 8080
      initialDelaySeconds: 15
      periodSeconds: 20
```

### 有的时候，应用程序可能暂时无法对外提供服务，例如，应用程序可能需要在启动期间加载大量数据或配置文件。 在这种情况下，您不想杀死应用程序，也不想对外提供服务。 那么这个时候我们就可以使用`readiness probe`来检测和减轻这些情况。 `Pod`中的容器可以报告自己还没有准备，不能处理`Kubernetes`服务发送过来的流量。

从上面的`YAML`文件我们可以看出`readiness probe`的配置跟`liveness probe`很像，基本上一致的。唯一的不同是使用`readinessProbe`而不是`livenessProbe`。两者如果同时使用的话就可以确保流量不会到达还未准备好的容器，准备好过后，如果应用程序出现了错误，则会重新启动容器。

另外除了上面的`initialDelaySeconds`和`periodSeconds`属性外，探针还可以配置如下几个参数：

* `timeoutSeconds`：探测超时时间，默认`1`秒，最小`1`秒。
* `successThreshold`：探测失败后，最少连续探测成功多少次才被认定为成功。默认是 `1`，但是如果是`liveness`则必须是 `1`。最小值是 `1`。
* `failureThreshold`：探测成功后，最少连续探测失败多少次才被认定为失败。默认是 `3`，最小值是 `1`。

这就是`liveness probe（存活探针）`和`readiness probe（可读性探针）`的使用方法。


