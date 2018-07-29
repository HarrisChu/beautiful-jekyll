---
layout: post
title: 在阿里云部署高可用 Kubernetes
# subtitle: 
# image: 
# bigimg: /img/2018-07/kubernetes.jpg
tags: [Kubernetes]
---

Kubernetes 是开源的容器管理平台，利用 Kubernetes 可以更好的完善基础设施，比如：

* 治理测试环境
* 使用 Kubernetes 的调度，如：
    * Jenkins slave
    * Locust 等压力测试的负载机
    * Selenium grid

因为阿里云按时付费的机器，停止时不会收费，整理了一个工具，可以在阿里云上部署高可用的 Kubernetes，可以用来自学 Kubernetes 相关概念，或者部署测试用的工具。

## 基本信息

Github 地址：https://github.com/HarrisChu/sailing

Kubernetes 版本：1.10.4

Docker 版本：17.03.1.ce

### 简单网络图

![](/img/2018-07/sailing_network.png)

## 主要功能

* 因为阿里云的 SLB，不支持 ECS 即作为 Real Server， 又作为客户端向 SLB 发送请求。单独在集群外的机器部署了 Haproxy。
* 添加了阿里云的 YUM repo，可以用 yum 安装 Kubernetes。
* 同步了 Kubernetes 需要的镜像到 Docker Hub，docker pull 后再改回原来的 tag，可以不需要翻墙下载镜像。
* 同样，同步了 flannel 的镜像。
* 在 master 上安装了 etcd 集群。 （非 TLS）
* 用 kubeadm 安装 Kubernetes HA。

## 安装集群

### Docker 部署集群

```sh
git clone https://github.com/HarrisChu/sailing.git
cd sailing
cp inventory.sample inventory
# vim inventory 修改 ssh 登录密码和机器信息

# vim env 修改 VIP 地址
make run

```

正常情况下，5分钟之内就会部署完毕。

### 本地 ansible 部署

```sh
git clone https://github.com/HarrisChu/sailing.git
cd sailing
pipenv --python 3.6
pipenv install

cp inventory.sample inventory
# vim inventory 修改 ssh 登录密码和机器信息

# vim env 修改 VIP 地址
pipenv run ansible-playbook -i inventory -e @env site.yaml -f 10
```

## 验证

* 登录 master1 机器

`kubectl get nodes` 查看 node 是否正常

`kubectl get pods --all-namespaces` 查看所有的 pods

* 将 master1 手动关机

* 登录 master2 机器

`kubectl get nodes` 查看 node 是否正常

`kubectl get pods --all-namespaces` 查看所有的 pods

可以看到虽然 master1 不可用了，但是 apiserver 还是正常的。

* 部署 nginx

复制 `example` 中的 yaml 到服务器上，分别执行：

`kubectl apply -f nginx-deploy.yaml`

`kubectl apply -f nginx-svc.yaml`

会创建一个 nginx 的服务，并且通过 nodePort 透传。

`curl localhost:30080` 就可以看到成功访问到 nginx 的页面了。


搭建之后，就可以做一些基本的尝试，或者自己部署一些应用服务了。