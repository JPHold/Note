[TOC]

[Docker buildx](https://docs.docker.com/buildx/working-with-buildx/)

参考这个文章[如何构建多架构 Docker 镜像？(部分概念和例子讲解)](https://www.infoq.cn/article/V9Qj0fJj6HsGYQ0LpHxg)
[[Docker特性]]

# 文档

## 介绍
基于[moby/buildkit](https://github.com/moby/buildkit)，保留了所有功能。
**从并发、缓存等维度提升docker构建的速度，与Dockerfile无关的构建工具[[Docker特性]]**

* 是个CLI插件，扩展了Docker命令
 
### 优势
* 支持docker build的功能
* 创建作用域构建器实例
* 并发构建多个node（不明白）[[2021-08(32)]]
* 指定构建镜像后，保存的位置
* 内联构建缓存
* 支持构建多平台架构(如amd)的镜像
* docker build不支持的功能：构建清单列表(manifest)、分布式缓存、导出OCI规范镜像tarballs(开放容器标准)（待学习）[[2021-08(32)]]

## 安装
* Docker19.03包含该插件。
* Docker桌面版也包含，但需要以下条件
1. Docker Desktop Enterprise version 2.1.0
2. Docker Desktop Edge version 2.0.4.0 or higher

* 使用DEB或RPM的安装方式，默认就安装了buildx[[Docker重点]]
* 可以手动安装
下载二进制文件[buildx](https://github.com/docker/buildx/)

## 开始构建
`docker buildx build .`
**使用BuildKit引擎，而且不需要DOCKER_BUILDKIT=1环境变量的设置去开启构建功能**
![[Pasted image 20210815183926.png]]

--- 
可以在已公开的驱动概念的配置来执行Buildx，目前支持两种驱动
1、**docker驱动**
    使用绑定在docker daemon二进制包中的BuildKit库
2、**docker-container驱动**
   Docker container内自动启动BuildKit
   
不同驱动的用户体验是非常相似的，然而有些特性，docker驱动是无法支持的：**因为绑定在docker daemon的BuildKit库使用了不同的存储组件**。**通过docker驱动程序构建的所有镜像都自动添加到docker image中；其它驱动程序需要指定镜像的输出位置：--output**

## 构建器实例的运行
如果支持docker驱动，Buildx默认使用docker驱动。注意的是：**必须使用本地共享守护进程来构建应用程序**。

Buildx允许创建独立构建器的新实例，通过CLI build命令集，**可以得到不改变共享守护进程状态的临时环境或者不同项目的独立构建器**。可以为一组远程节点创建一个新实例，形成构建厂，并且快速切换

使用`docker buildx create`来创建实例，基于现有配置，为单个节点创建一个新构建器实例

如果使用远程节点的话，在创建构建器实例时，指定DOCKER_HOST或远程上下文名称。

在创建实例后，可使用inspect,、stop 、rm进行管理。使用ls列举出构建器实例的清单。**在创建实例后，也可以绑定新节点在这个实例上**

通过docker buildx use <name>切换构建器实例，切换后，build命令就自动使用这个实例

**Docker19.03有个新特性：docker context命令，为远程API endpoints提供名称**，**Buildx结合docker context，保证所有context都能自动获得默认构建器实例**。也可以在创建新构建器实例或添加节点到这个构建器实例时，设置context名称

## 构建多系统的镜像
**Buildx本身是为了支持构建多系统，而不是仅仅是用户所在操作系统和体系架构**

`--platform`指定构建输出的系统(如linux/amd64, linux/arm64, darwin/amd64)

**如果当前构建器实例使用docker-container驱动，你可以指定多个系统**。构建后，可查询获得镜像清单(manifest，列出了一组指定的系统对应的镜像信息)，**当使用docker run或docker service使用这个镜像时，docker对照这份镜像清单，根据节点的系统类型自动选择对应镜像**

**可使用Buildx和Dockerfiles都支持的三种策略来构建多系统镜像**
* 使用内核支持的QEMU仿真
* 在多个原生节点上，使用同一个构建器实例
* 使用Dockerfile的stage去交叉编译不同的系统

**使用内核支持的QEMU仿真**
如果你的节点支持的话(比如使用Docker Desktop)，QEMU是最简单的方式。无须修改Dockerfile，Buildx会自动选择可用的体系架构。
结合[如何构建多架构 Docker 镜像？](https://www.infoq.cn/article/V9Qj0fJj6HsGYQ0LpHxg)中执行其他体系架构的二进制包的几种方式的描述：因为QEMU是模拟整个硬件系统(相当于是一整个虚拟机)，但我们一般不关心这些硬件特性。所以这很浪费资源。

可以使用QEMU另一种操作模式：binfmt_misc，结合[github-binfmt-misc](https://github.com/torvalds/linux/blob/master/Documentation/admin-guide/binfmt-misc.rst)的描述，是linux的特性，**类似于window的根据扩展名自动选择对应软件来打开(并且可配置默认打开的软件)，但不仅仅只有扩展名方式，还有另一种方式：字节匹配**
在binfmt_misc handler注册二进制转换程序，来自动转换

使用多组原生节点，为QEMU无法处理的复杂情况提供更好的支持和拥有更好的性能，可以通过--append将节点添加到构建器实例上

**使用Dockerfile的stage去交叉编译不同的系统**
不同语言，可能会对交叉编译提供更好的支持，Dockerfile的多个stage构建(多阶段构建)用于为指定的系统构建二进制包。可在Dockerfile中使用BUILDPLATFORM、TARGETPLATFORM参数

```shell
FROM --platform=$BUILDPLATFORM golang:alpine AS build
ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN echo "I am running on $BUILDPLATFORM, building for $TARGETPLATFORM" > /log
FROM alpine
COPY --from=build /log /log
```

## 高级选项
不只是单一build命令，还支持高级功能
Buildx可有效地处理多个并发构建请求和重复构建，build命令可与通用命令结合使用(如make)。**然而这些工具按顺序调用构建，因此无法很好利用Buildx 并行的特点，也不能将输出组合在一起给到用户**。在这个例子，docker buildx bake，支持从compose文件构建镜像(跟compose命令差不多)，但不同的是：bake允许所有services作为单个请求的一部分，并行构建

## 将buildx作为默认构建方式

docker buildx install将docker build设置为docker buildx的别名(也就是设为默认方式)，所以使用docker build，底层使用buildx来构建

**通过docker buildx uninstall**

# 疑惑点攻破

## 两种驱动
1. docker和docker-container应用场景

* docker-container
翻阅buildx命令的官方文档
指定--output，将镜像保存到本地
`docker buildx build --platform linux/arm,linux/arm64,linux/amd64 -t orangebudd/hello-buildx-container-driver -o "type=local,dest=/home/docker/buildx/build-images/hello" . `
![de3a7a27a2fd2b8ed1ffeff657036ab9.png](en-resource://database/1279:1)
![602d440a30416c7ff94d54fc4d8eded4.png](en-resource://database/1280:1)
![cc7f4794199a7fcb2b03e238f29eadb0.png](en-resource://database/1281:1)


[「Docker Buildx」- 构建“跨平台”镜像（学习笔记）](https://k4nz.com/Kubernetes_and_Docker/01.Docker_-_OS-level_virtualization/Docker_Image/0.Building_Docker_Images/buildx.html)
**试了这个命令，通过docker images都没找到**
docker buildx build --progress plain --output "type=image,push=false" --file "/home/docker/buildx/hello/Dockerfile" --tag orangebudd/hello-buildx-container-driver-image --platform linux/arm64,linux/amd64 /home/docker/buildx/hello

2. 怎么查询构建器实例用哪个驱动
3. docker-container没有指定--output，但也可以构建，究竟存在哪里

## 创建作用域构建器实例
是context吗

## 如果当前构建器实例使用docker-container驱动，你可以指定多个系统
docker驱动就不行吗


## 构建方式binfmt_misc
    是QEMU的另外一种方法，不用像QEMU那样，模拟整个系统硬件。而是在linux内核注册一个个二进制格式转换程序，运行其他系统的程序时，会找到对应的转换程序来将目标系统的二进制指令转换成本机系统的二进制指令(2021年3月7日 15:00:23 猜测是**为了服务于测试Buildx构建出来的多系统的镜像是否能正常运行**)
    
### linux官方介绍    
    看一下linux官方怎么解释[github-binfmt-misc](https://github.com/torvalds/linux/blob/master/Documentation/admin-guide/binfmt-misc.rst)， 全称是miscellaneous Binary Formats，原理是识别二进制文件，找到对应的解释器，binfmt-misc就像是个清单。有两种识别文件类型的方式：

1. 文件开头的一些字节与您提供的魔法字节序列(屏蔽指定的位)匹配来识别二进制类型
2. 识别文件名扩展名，如com、exe。

   必须挂载：mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc
   添加新的二进制文件类型，需在/proc/sys/fs/binfmt_misc/register文件按格式添加：`:name:type:offset:magic:mask:interpreter:flags`
* name
    是个标识名称，在/proc/sys/fs/binfmt_misc下会创建文件
* type
    识别的类型，M：通过字节匹配；E：通过扩展名
* offset
    与type指定M有关，文件的魔法/掩码的偏移量，默认是0(不指定offset则为0：:name:type::magic)。type指定为E则忽略offset的设置
* magic
* mask
* interpreter
    解释器，是一个二进制文件作为第一个参数的程序(需指定完整路径)
* flags
是一个可选字段，它控制解释器调用的几个方面。它是一串大写字母，每个字母控制一个特定的方面。支持以下标志:


### 配置转换程序与体系架构的映射规则
**在window和mac无须设置，linux需要设置**
`docker run --rm --privileged docker/binfmt:820fdd95a9972a5308930a2bdfb8573dd4447ad3`

**然而报错了： Cannot write to /proc/sys/fs/binfmt_misc/register: write /proc/sys/fs/binfmt_misc/register: invalid argument**

# 实操
* **创建构建器(默认的构建器不能多体系架构构建)**
`docker buildx create --name mybuilder --driver docker-container`

* 查看创建的构建器
`docker buildx ls`

* 构建多体系架构的镜像并推送到hub
`docker buildx build --platform linux/arm,linux/arm64,linux/amd64 -t orangebudd/hello-buildx . --push`
![db9f4596c660cf5d8d4f9e443cf011fd.png](en-resource://database/1273:1)

```shell
[root@basic hello]# docker buildx build --platform linux/arm,linux/arm64,linux/amd64 -t orangebudd/hello-buildx . --push
[+] Building 49.3s (15/15) FINISHED                                                                                                                                                      
 => [internal] load build definition from Dockerfile                                                                                                                                0.0s
 => => transferring dockerfile: 173B                                                                                                                                                0.0s
 => [internal] load .dockerignore                                                                                                                                                   0.0s
 => => transferring context: 2B                                                                                                                                                     0.0s
 => [linux/amd64 internal] load metadata for docker.io/library/alpine:latest                                                                                                       30.7s
 => [linux/arm/v7 internal] load metadata for docker.io/library/alpine:latest                                                                                                      12.3s
 => [linux/arm64 internal] load metadata for docker.io/library/alpine:latest                                                                                                       10.5s
 => [auth] library/alpine:pull token for registry-1.docker.io                                                                                                                       0.0s
 => [linux/arm/v7 1/2] FROM docker.io/library/alpine@sha256:a75afd8b57e7f34e4dad8d65e2c7ba2e1975c795ce1ee22fa34f8cf46f96a3be                                                        0.0s
 => => resolve docker.io/library/alpine@sha256:a75afd8b57e7f34e4dad8d65e2c7ba2e1975c795ce1ee22fa34f8cf46f96a3be                                                                     0.0s
 => [linux/arm64 1/2] FROM docker.io/library/alpine@sha256:a75afd8b57e7f34e4dad8d65e2c7ba2e1975c795ce1ee22fa34f8cf46f96a3be                                                         0.0s
 => => resolve docker.io/library/alpine@sha256:a75afd8b57e7f34e4dad8d65e2c7ba2e1975c795ce1ee22fa34f8cf46f96a3be                                                                     0.0s
 => [linux/amd64 1/2] FROM docker.io/library/alpine@sha256:a75afd8b57e7f34e4dad8d65e2c7ba2e1975c795ce1ee22fa34f8cf46f96a3be                                                         0.0s
 => => resolve docker.io/library/alpine@sha256:a75afd8b57e7f34e4dad8d65e2c7ba2e1975c795ce1ee22fa34f8cf46f96a3be                                                                     0.0s
 => CACHED [linux/arm/v7 2/2] RUN uname -a >/os.txt                                                                                                                                 0.0s
 => CACHED [linux/amd64 2/2] RUN uname -a >/os.txt                                                                                                                                  0.0s
 => CACHED [linux/arm64 2/2] RUN uname -a >/os.txt                                                                                                                                  0.0s
 => exporting to image                                                                                                                                                             18.5s
 => => exporting layers                                                                                                                                                             0.0s
 => => exporting manifest sha256:e9bcf009be661a6acdfcc00502d9b95c37b6d8c24b5ab56f4c9ec2fd4bed241e                                                                                   0.0s
 => => exporting config sha256:ff3db57e65894cc9387e51818ba1c459bd23731dd87ceabc8bb881a44708cf2d                                                                                     0.0s
 => => exporting manifest sha256:cec1606d9235ac4b9f6d6c991ccde0d23d1397666f641cf84ba39aba38737274                                                                                   0.0s
 => => exporting config sha256:3663c7970934553f7556302e428a45530edcdf2f228d7d7b3eba6970972b730d                                                                                     0.0s
 => => exporting manifest sha256:5a8eb4050b27e3477135500809fcdaf74d7b7c62d82022b1e486a2244801b4c4                                                                                   0.0s
 => => exporting config sha256:c6b57aef3eb99b012e6474ec8cafc0473d748b4ba723207af4a902680c2d0e9d                                                                                     0.0s
 => => exporting manifest list sha256:39aa598d714ef7b677582e2bf186ca6f5642759e70b4ef5425dfdf9b85aa936d                                                                              0.0s
 => => pushing layers                                                                                                                                                               6.9s
 => => pushing manifest for docker.io/orangebudd/hello-buildx:latest                                                                                                               11.6s
 => [auth] orangebudd/hello-buildx:pull,push token for registry-1.docker.io                                                                                                         0.0s
 => [auth] orangebudd/hello-buildx:pull,push orangebudd/hello-builxs:pull token for registry-1.docker.io 
```

* 查看镜像清单
`docker buildx imagetools inspect orangebudd/hello-buildx`
![42ebf92f93cfa449087bf568578e7aff.png](en-resource://database/1274:1)

或者
`docker manifest inspect orangebudd/hello-buildx`
![b81f62993066ad95b05a471eb07cc353.png](en-resource://database/1275:1)

* 配置binfmt_misc
[参考-通过qemu binfmt_misc在Docker LCOW上运行linux / arm容器](https://dockerquestions.com/2019/03/28/run-linux-arm-container-via-qemu-binfmt_misc-on-docker-lcow/)
**添加规则到binfmt_msc：/proc/sys/fs/binfmt_misc**
docker run --rm --privileged multiarch/qemu-user-static:register --reset
![6f5f45e89ed820e413a9808283f72d8f.png](en-resource://database/1276:1)

但运行非本地架构，依然提示找不到解释器

想手动添加规则到/proc/sys/fs/binfmt_misc/register文件
**虽然register显示是可写，但vim后却提示readonly**
![aa7656a38872da64943813fa618db84c.png](en-resource://database/1277:1)

**cat register提示Invalid argument**
翻阅[qemu-user-static-issue](https://github.com/multiarch/qemu-user-static/issues/38)，应该是linux内核过低导致，我的如下
![e1e2912b71d123abef6dc298c64fee7f.png](en-resource://database/1278:1)
升级了，依然不行[linux系统内核版本升级](https://www.cnblogs.com/jinyuanliu/p/10368780.html)

**添加规则到register**
 echo :qemu-arm:M:0:7f454c4601010100000000000000000002002800:ffffffffffffff00fffffffffffffffffeffffff:/usr/bin/qemu-arm:OCF > register 
 
 **重启虚拟机后，/proc/sys/fs/binfmt_misc下消失了**
 
 
 # 命令集清单


# 命令集清单
* **创建构建器实例**
`docker buildx create --name mybuilder --driver docker-container`

* **查看构建器清单**
`docker buildx ls`

* **构建**
-- 全体系架构构建
`docker buildx build .`
-- 指定体系架构构建并推到hub
`docker buildx build --platform linux/arm,linux/arm64,linux/amd64 -t orangebudd/hello-buildx . --push`

* **查看镜像清单(manifest)**
`docker buildx imagetools inspect orangebudd/hello-buildx`
或
`docker manifest inspect orangebudd/hello-buildx`

* **切换构建器实例**
`docker buildx use <name>`

* **创建上下文环境**
`docker context`

* **设置和取消buildx为默认构建方式**
`docker buildx install`
`docker buildx uninstall`