[TOC]

# 介绍
轻松管理swarm集群、k8s集群、个人docker节点

一个cli可拥有多个context，每一个context包含管理不同集群或节点所需的所有端点和安全信息，docker context用于管理这些context并切换

## 应用场景
有两个context，是dev-k8s和prod-swarm，前者负责在开发环境中包含endpoint的数据和安全凭证去管理k8s集群，后者负责在生产环境中包含所有信息去管理swarm集群。使用`docker context use <context-name>`切换

使用Docker Context去发布应用到云平台
[Deploying Docker containers on Azure](https://docs.docker.com/cloud/aci-integration/)
[Deploying Docker containers on ECS](https://docs.docker.com/cloud/ecs-integration/)

# 前置条件
1. Docker cli
2. context命令，确保Docker cli支持context
3. 测试节点或集群
docker单节点、swarm集群、k8s集群
选择其中一个进行测试即可

# context描述
包含四个属性

1.     Name
2.     Endpoint configuration
3.     TLS info
4.     Orchestrator

**通过docker context ls查看**
![1aa3eec33a4d19740220c5c7ae19915c.png](en-resource://database/1246:1)

**DOCKER ENDPOINT**
通过/var/run/docker.sock UNIX套接字与swarm集群通信

**name带***
代表所有docker命令，都会在这个context执行一次，除非使用DOCKER＿HOST或DOCKER＿CONTEXT指定，才不会执行

使用`docker context inspect default`获知context更详细的信息
![d48f642678f77a0205a609082174199b.png](en-resource://database/1248:1)
这个context使用swarm作为编排器(orchestrator)

# 创建context
$ docker context create docker-test \
  --default-stack-orchestrator=swarm \
  --docker host=unix:///var/run/docker.sock

Successfully created context "docker-test"

创建后，会在~/.docker/contexts/meta/创建自己的独立目录，并在其中创建meta.json
![6bffbc1ecb03ea171504783bf979105e.png](en-resource://database/1247:1)
```linux
{"Name":"docker-test","Metadata":{"StackOrchestrator":"swarm"},"Endpoints":{"docker":{"Host":"unix:///var/run/docker.sock","SkipTLSVerify":false}}}
```
注意的是：
**但默认的context是没有这个文件**，而且会自动根据当前配置自动更新context的配置，比如kubectl config use-context，默认context会自动更新到新的Kubernetes endpoint

使用docker context ls 或 docker context inspect <context-name>查看context信息

可以通过配置文件指定编排器（如kubernetes）：
如果您的kubeconfig具有多个上下文，则将使用当前上下文 (kubectl config current-context)。
$ docker context create k8s-test \
  --default-stack-orchestrator=kubernetes \
  --kubernetes config-file=/home/ubuntu/.kube/config \
  --docker host=unix:///var/run/docker.sock

Successfully created context "k8s-test"


# 使用不同的context
## 全局切换
* 命令切换
$ docker context use k8s-test
切换后，该context就会标记*号


* 全局变量替换
DOCKER_CONTEXT

Windows PowerShell:
> $Env:DOCKER_CONTEXT=docker-test

Linux:
$ export DOCKER_CONTEXT=docker-test

## 局部切换
* 命令参数指定
局部指定context，在每个命令加上--context
$ docker --context production container ls


# 导入导出context
* 导出到文件
docker context export [OPTIONS] CONTEXT [FILE|-]
默认导出到当前目录
1
* 导入文件
docker context import CONTEXT FILE|-

**默认情况下，导出的只是纯context，但如果该context包含Kubernetes endpoint，那么也会被导出来**


**注意的是**
还有一个选项可以只导出contexr中Kubernetes部分。这将生成本机kubeconfig文件，该文件需要在另一台安装了kubectl的服务器。导出上下文的Kubernetes部分，并不能使用docker上下文导入将其导入。**手动将其合并到现有的kubeconfig文件中(~/.kube/config文件)**。

## 导出和导入纯context
docker context export docker-test
Written file "docker-test.dockercontext
**内容如下**
```linux
meta.json0000644000000000000000000000027300000000000011030 0ustar0000000000000000{"Name":"docker-test","Metadata":{"Description":"Test Kubernetes cluster","StackOrchestrator":"swarm"},"Endpoints":{"docker":{"Host":"unix:///var/run/docker.sock","SkipTLSVerify":false}}}tls0000700000000000000000000000000000000000000007716 5ustar0000000000000000
```

$ docker context import docker-test docker-test.dockercontext
docker-test
Successfully imported context "docker-test"

## 导出kubertnetes context
docker context export k8s-test --kubeconfig
Written file "k8s-test.kubeconfig"

# 更新context
docker context update
$ docker context update k8s-test --description "Test Kubernetes cluster"
k8s-test
Successfully updated context "k8s-test"