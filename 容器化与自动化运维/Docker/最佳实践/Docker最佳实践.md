[TOC]

# 镜像
## 减少层数
少一层，则减少一个目录及其涵盖的文件(/var/lib/docker/overlay2/)。下面列出证据

* 现有两个Dockerfile

第一个
```Dockerfile
FROM primetoninc/jdk 
COPY obsidian-git-1.9.2.zip .
RUN unzip obsidian-git-1.9.2.zip
RUN rm obsidian-git-1.9.2.zip
```
第二个
```Dockerfile
FROM primetoninc/jdk 
COPY obsidian-git-1.9.2.zip .
RUN unzip obsidian-git-1.9.2.zip\
 &&  rm obsidian-git-1.9.2.zip
```
差别：第二个是将第一个的第3、4行，浓缩到一行命令

**接下来实操验证**
1. 使用docker build 分别打包
![[Pasted image 20210707234805.png]]
2. 查看存储驱动程序创建的层目录
使用`docker image inspect xxxTag`查看
这是第一个
`docker image inspect image-layer-best`
![[Pasted image 20210707235209.png]]
这是第二个
`docker image inspect image-layer-best-1`
![[Pasted image 20210707235351.png]]

**发现第二个镜像层数(4)比第一个镜像层数(5)少了一层。恰好说明了合并命令的重要性**
**但带来一个新问题：阅读性差，因此还要格式化命令行，可以使用换行来达到清晰易阅读的效果**

## 控制层的大小
* 下载文件啥的，用完后就删除掉
[container best practices](http://docs.projectatomic.io/container-best-practices/#_clear_packaging_caches_and_temporary_package_downloads)
 
## 相似的Dockerfile，要合并复用
* 当想创建的容器，Dockerfile是一样的(比如同个程序，但不容环境)，那么把动态部分抽象出来，作为构建变量ARG，构建时传入这些变量值，就节省了复制同一份Dockerfile
[build-time arguments](https://docs.docker.com/engine/reference/builder/#arg)

## 慎用ENV
* 环境变量，如果只是某个RUN命令使用，那就不要设置环境变量，因为会传递到子镜像，可以使用export。应如下使用
	```
	RUN export DEBIAN_FRONTEND=noninteractive ;\
    apt-get update ;\
    echo and so forth
	```

## 标记
* 区分版本
* CI(如Jenkins)打包时，必须指定一个构建id以识别本次构建的镜像

[The tag command](https://docs.docker.com/engine/reference/commandline/tag/)
	
## 日志
* 日志滚动
避免日志盲目增长，最终导致存储满了
修改/etc/docker/daemon.json，使用log-opts或启动容器时指定--log-opt

[the log driver options](https://docs.docker.com/engine/admin/logging/overview/#/json-file-options)

# 容器
## 容器创建和启动时间要快，要保证扩缩容迅速
[满足应用开发的十二准则](https://12factor.net/disposability)
[best practices for writing Dockerfiles](https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/#containers-should-be-ephemeral).

## 确保PID=1的进程可杀死僵尸进程
一般我们都是部署自己的应用或中间件，所以PID=1的进程就由他们来担当了。
PID=1的进程，责任在docker stop型信号后，可以转发关闭信号给子线程，**这样可以防止出现僵尸进程**。

上面所述只适用于一个容器一个应用或中间件的情况；但实际有时不遵守，一个容器多个应用，那就需要tini的帮助了(docker 从某个版本开始支持tini)
[Complete explanation by Krallin, creator of Tini](https://github.com/krallin/tini/issues/8)
[tini](https://github.com/krallin/tini)

## 确保一个容器一个责任一个流程
只放一个应用、一个中间件
[Best practices for writing Dockerfiles](https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/#run-only-one-process-per-container).

## 使用共享卷volume，共享数据
 [Manage data in containers](https://docs.docker.com/engine/tutorials/dockervolumes/).
 
 # 注册表
## 垃圾回收
[Garbage Collection](https://github.com/docker/docker.github.io/blob/master/registry/garbage-collection.md)

涉及两个东西
1. manifest
2. 层引用

manifest应该是描述镜像的具体信息，包括层信息和层的存储目录位置

### 回收规则
1. 如果manifest依然存在层的引用，则无法垃圾回收
2. 删掉了manifest，如果没有其他manifest引用该层，则该层也会被删除


### 垃圾回收流程(跟jvm回收相似)
1. 标记 ^83163d
扫描注册表中的manifest清单，标记依然还在使用的层地址。将这些地址存放在集合中 
2. 扫描和删除
扫描所有blob集，不在[[#^83163d]]第一步标记的集合，则删除
**要注意执行回收时，要保证注册表只读或不可用，避免这时上传一个新的镜像，导致该镜像损坏，基于这个特性，这样的回收取名为stop-the-world**

# 安全
## 使用自定义网络，将不同组的应用隔离开
同组应用使用同个网络，将访问权限局限在一小块，非开放
```
$ docker network create --driver bridge isolated_nw
$ docker run --network=isolated_nw --name=container busybox
```

## 不要轻易信任未知的镜像
1. 对于官方没有接入docker镜像的，自己下载官方的二进制包，然后创建新镜像并放入其中
2. 如果没有提供二进制包，最好自己编译。而不是从别人那下载

[alexellis/docker-arm](https://github.com/alexellis/docker-arm)
 [5 things about Docker on Raspberry Pi](http://blog.alexellis.io/5-things-docker-rpi/)
 
## 禁止访问文件系统
两种方式
1. 全都只读--read-only
```
$ docker run --read-only ...
```
2. 限定某些volume只读
```
$ docker run -v /my/data:/data:ro ...
```

## 限制资源
**这个非常重要，因为没有限制的话，所有容器共用主机的资源，假如某个容器把线程耗尽，cpu飙满，那么其他容器直接歇菜了**

内存：-m、-memory-swap等
cpu：-cpu等
具体docker run --help查看参数清单

## 漏洞扫描
这是收费功能，docker scan
 [Docker Security Scanning](https://docs.docker.com/docker-cloud/builds/image-scan/)
 [Clair](https://github.com/coreos/clair).
 
## 避免root用户
无需很多权限，就不要使用root用户，正确做法：
在Dockerfile中创建普通用户，并指定用户环境：USER xxxuser
```
RUN groupadd -r myapp && useradd -r -g myapp myapp
USER myapp
```
    
## 移除没用的功能命令(capabilities)
将一些比较危险的功能禁掉，保证容器被干掉啥的，比如kill。下面列出一些功能
`chown`, `dac_override`, `fowner`, `fsetid`, `kill`, `setgid`, `setuid`, `setpcap`, `net_bind_service`, `net_raw`, `sys_chroot`, `mknod`, `audit_write`, `setfcap`

[Secure Your Containers (rhelblog)](http://rhelblog.redhat.com/2016/10/17/secure-your-containers-with-this-one-weird-trick/).

## 凭证和密码
很多时候，我们的做法是，将凭证和密码放在环境变量，这就有问题：
1. 镜像存在这些信息，通过docker image inspect xxxImage可查看到
2. 尽管最终的镜像会移除掉中间层，但依然可以从构建缓存中查看到

[container best practices](http://docs.projectatomic.io/container-best-practices/#_passing_credentials_and_secrets).

# 使用docker部署的应用
## 日志输出
为了更好处理应用的输出日志，最好都打印到stdout(这个意思应该是不要自己写日志到文件)，统一交给docker daemon去抓取输出流以控制日志输出
[The Twelve-Factor App](https://12factor.net/logs) 
[Configure logging drivers](https://docs.docker.com/engine/admin/logging/overview/).