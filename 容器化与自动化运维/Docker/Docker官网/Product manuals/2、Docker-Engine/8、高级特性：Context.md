[TOC]
[[Docker特性]]

# 介绍
在一台主机上，轻松管理个人docker节点、swarm集群、k8s集群

一个cli可拥有多个context，每一个context包含管理不同集群或节点所需的daemon操作入口endpoint和安全信息.

`docker context`命令用于管理这些context并切换。

**context中最主要的是Endpoint配置，指定当前context操作的daemon是哪个地方的：本地、远程地址**[[重点]]

## 应用场景
* 官方描述
有两个context，是dev-k8s和prod-swarm，前者负责在开发环境中包含endpoint的数据和安全凭证去管理k8s集群，后者负责在生产环境中包含所有信息去管理swarm集群。使用`docker context use <context-name>`切换

* 使用Docker Context去发布应用到云平台
[Deploying Docker containers on Azure](https://docs.docker.com/cloud/aci-integration/)
[Deploying Docker containers on ECS](https://docs.docker.com/cloud/ecs-integration/)

* 与前面[[4、安装后可选后续步骤#开启端口访问]]文章有点联系
启用daemon的远程访问，该ip:port可作为context中endpoint配置[[Docker重点]]


# 前置条件
1. Docker cli
2. context命令，确保Docker cli支持context
3. 测试节点或集群
docker单节点、swarm集群、k8s集群
选择其中一个进行测试即可

# context结构
包含四个属性
1. Name
2. Endpoint configuration
3. TLS info
4. Orchestrator编排器

* **通过docker context ls查看**
![[Pasted image 20210815205209.png]]

* **DOCKER ENDPOINT**
通过/var/run/docker.sock UNIX套接字与swarm集群通信

* **name带***
代表当前才用的默认上下文，所有docker命令，都会在这个context配置的ENDPOINT执行；可以被环境变量DOCKER_HOST或环境变量DOCKER_CONTEXT覆盖，也可以在执行cli命令时指定--context或--host覆盖。
[[Docker重点]]

使用`docker context inspect default`获知context更详细的信息
![[Pasted image 20210815205342.png]]
这个context使用swarm作为编排器(orchestrator)

# 创建context
```
docker context create docker-test \
  --default-stack-orchestrator=swarm \
  --docker host=unix:///var/run/docker.sock
  
Successfully created context "docker-test"  
```

* 创建后，会在~/.docker/contexts/meta/创建自己的独立目录，并在其中创建meta.json
![[Pasted image 20210815205720.png]]
```json
{"Name":"docker-test","Metadata":{"StackOrchestrator":"swarm"},"Endpoints":{"docker":{"Host":"unix:///var/run/docker.sock","SkipTLSVerify":false}}}
```
注意的是：
**默认的context是没有这个文件**
而且会自动根据当前配置自动更新context的配置，比如`kubectl config use-context`，默认context会自动更新为Kubernetes endpoint[[Docker重点]]（待学习，docker与k8s如何交互）[[2021-08(32)]]

* 使用`docker context ls` 或 `docker context inspect <context-name>`查看context信息

可以通过配置文件指定编排器（如kubernetes）：
如果您的kubeconfig具有多个上下文，则将使用当前上下文 (kubectl config current-context)。（待学习，docker与k8s如何交互）[[2021-08(32)]]
```
$ docker context create k8s-test \
  --default-stack-orchestrator=kubernetes \
  --kubernetes config-file=/home/ubuntu/.kube/config \
  --docker host=unix:///var/run/docker.sock
  
Successfully created context "k8s-test"

```


# 使用不同的context
## 全局切换
### 命令切换
`docker context use k8s-test`
切换后，该context就会标记为\*号，代表当前默认上下文

### 全局变量替换
DOCKER_CONTEXT

Windows PowerShell:
`> $Env:DOCKER_CONTEXT=docker-test`

Linux:
`export DOCKER_CONTEXT=docker-test`

## 局部切换
* 命令参数指定
局部指定context，在每个命令加上--context
`docker --context docker-test container ls`

或者
`docker --host tcp://192.168.10.103:2375 container ls`
采用了daemon的远程访问：[[4、安装后可选后续步骤#开启端口访问]]

# 导入导出context
* 导出到文件
`docker context export [OPTIONS] CONTEXT [FILE|-]`
默认导出到当前目录

* 导入文件
`docker context import CONTEXT FILE|-`

**默认情况下，导出的只是纯context；但如果是Kubernetes endpoint的context，那么也会被导出来，但其.kubeconfig文件不会导出**[[Docker重点]]


## 导出和导入纯context

^ad71a7

**因为kubertnetes还包含一个.kubeconfig文件，因此这里的命令只是导出基本配置，剩下具体的配置还需第二步[[#^7005fd]]**
* **导出**
```
$ docker context export docker-test
Written file "docker-test.dockercontext
```
**内容如下**
```linux
meta.json0000644000000000000000000000027300000000000011030 0ustar0000000000000000{"Name":"docker-test","Metadata":{"Description":"Test Kubernetes cluster","StackOrchestrator":"swarm"},"Endpoints":{"docker":{"Host":"unix:///var/run/docker.sock","SkipTLSVerify":false}}}tls0000700000000000000000000000000000000000000007716 5ustar0000000000000000
```

* **导入**
```
$ docker context import docker-test docker-test.dockercontext
docker-test
Successfully imported context "docker-test"
```

## 导出kubertnetes context
^7005fd
[[#^ad71a7]]第一步之后，还需进行第二步

导出.kubeconfig文件，**然后在另一个主机，手动将其合并到现有的kubeconfig文件中(~/.kube/config文件)**。（待学习）[[2021-08(32)]]
```
$ docker context export k8s-test --kubeconfig
Written file "k8s-test.kubeconfig"
```
.kubeconfig文件大概长这个样子
```yaml
$ cat k8s-test.kubeconfig
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data:
    <Snip>
    server: https://35.226.99.100
  name: cluster
contexts:
- context:
    cluster: cluster
    namespace: default
    user: authInfo
  name: context
current-context: context
kind: Config
preferences: {}
users:
- name: authInfo
  user:
    auth-provider:
      config:
        cmd-args: config config-helper --format=json
        cmd-path: /snap/google-cloud-sdk/77/bin/gcloud
        expiry-key: '{.credential.token_expiry}'
        token-key: '{.credential.access_token}'
      name: gcp
```

# 更新context
`docker context update`

```
$ docker context update k8s-test --description "Test Kubernetes cluster"
k8s-test
Successfully updated context "k8s-test"
```