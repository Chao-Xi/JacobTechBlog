# 在 Kubernetes 上调度 GPU 资源

**Kubernetes 支持对节点上的 AMD 和 NVIDIA 的 GPU 进行管理，目前处于实验状态。**

用户如何在不同的 Kubernetes 版本中使用 GPU，以及当前存在的一些限制。

## 1. 使用设备插件

Kubernetes 实现了 [Device Plugins](https://kubernetes.io/zh/docs/concepts/extend-kubernetes/compute-storage-net/device-plugins/) 以允许 Pod 访问类似 GPU 这类特殊的硬件功能特性。

**作为运维管理人员，你要在节点上安装来自对应硬件厂商的 GPU 驱动程序，并运行来自 GPU 厂商的对应的设备插件**。

* AMD - [deploying-amd-gpu-device-plugin](https://kubernetes.io/zh/docs/tasks/manage-gpus/scheduling-gpus/#deploying-amd-gpu-device-plugin)
* NVIDIA - [deploying-nvidia-gpu-device-plugin](https://kubernetes.io/zh/docs/tasks/manage-gpus/scheduling-gpus/#deploying-nvidia-gpu-device-plugin)

当以上条件满足时，Kubernetes 将暴露 `amd.com/gpu` 或 `nvidia.com/gpu` 为可调度的资源，可以通过请求 `<vendor>.com/gpu` 资源来使用 GPU 设备。

不过，使用 GPU 时，在如何指定资源需求这个方面还是有一些限制的：

* <mark>GPUs 只能设置在 limits 部分</mark>，这意味着：
	* **不可以仅指定 `requests` 而不指定 `limits`**
	* **可以同时指定 limits 和 requests，不过这两个值必须相等**
	* **可以指定 GPU 的 limits 而不指定其 requests，K8S 将使用限制值作为默认的请求值**

* **容器(Pod)之间是不共享 GPU 的，GPU 也不可以过量分配**
* **每个容器可以请求一个或者多个 GPU，但是用小数值来请求部分 GPU 是不允许的**

```
# need 2 GPUs
apiVersion: v1
kind: Pod
metadata:
  name: gpu-pod
spec:
  containers:
    - name: cuda-container
      image: nvcr.io/nvidia/cuda:9.0-devel
      resources:
        limits:
          nvidia.com/gpu: 2
    - name: digits-container
      image: nvcr.io/nvidia/digits:20.12-tensorflow-py3
      resources:
        limits:
          nvidia.com/gpu: 2
```

## **2. 部署 AMD GPU 设备插件**

节点需要使用 AMD 的 GPU 资源的话，需要先安装 [k8s-device-plugin](https://github.com/RadeonOpenCompute/k8s-device-plugin) 这个插件，并且需要 K8S 节点必须预先安装 AMD GPU 的 Linux 驱动。

```
# 安装显卡插件
$ kubectl create -f https://raw.githubusercontent.com/RadeonOpenCompute/k8s-device-plugin/r1.10/k8s-ds-amdgpu-dp.yaml
```




## **3. 部署 NVIDIA GPU 设备插件**

节点需要使用 NVIDIA 的 GPU 资源的话，需要先安装 `k8s-device-plugin` 这个插件，并且需要事先满足下面的条件

* **Kubernetes 的节点必须预先安装了 NVIDIA 驱动**
* **Kubernetes 的节点必须预先安装 nvidia-docker2.0**
* **Docker 的默认运行时必须设置为 nvidia-container-runtime，而不是 runc**
* **NVIDIA 驱动版本大于或者等于 384.81 版本**

```
# 安装nvidia-docker2.0工具
$ distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
$ curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
$ curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
$ sudo apt-get update && sudo apt-get install -y nvidia-docker2
$ sudo systemctl restart docker

# 安装nvidia-container-runtime运行时
$ cat /etc/docker/daemon.json
{
    "default-runtime": "nvidia",
    "runtimes": {
        "nvidia": {
            "path": "/usr/bin/nvidia-container-runtime",
            "runtimeArgs": []
        }
    }
}

# 安装显卡插件
$ kubectl create -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/1.0.0-beta4/nvidia-device-plugin.yml
```
也可以使用 helm 或 docker 安装:

```
$ helm repo add nvdp https://nvidia.github.io/k8s-device-plugin
$ helm repo update
$ helm install --version=0.9.0 --generate-name nvdp/nvidia-device-plugin

# 也可以使用docker安装
$ docker run -it \
    --security-opt=no-new-privileges \
    --cap-drop=ALL --network=none \
    -v /var/lib/kubelet/device-plugins:/var/lib/kubelet/device-plugins \
    nvcr.io/nvidia/k8s-device-plugin:devel
```

## **4. 结论总结陈述**

显卡插件，就是在我们通过在配置文件里面指定如下字段之后，启动 pod 的时候，系统给为我们的服务分配对应需要数量的显卡数量，让我们的程序可以使用显卡资源。

* amd.com/gpu
* nvidia.com/gpu

需要注意的是，第一次安装显卡驱动的话，是不用重启服务器的，后续更新驱动版本的话，则是需要的。但是建议第一次安装驱动之后，最好还是重启下，防止意外情况的出现和发生。