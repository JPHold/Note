# Docker

## 特性

### 网络隔离

### 服务自动发现

### 跟应用同生命周期，对后面的容器编排尤为重要

### 单进程模型

* 容器内的应用进程，是PID=1的进程
* 容器无法启动多个应用
* 如果要启动多个应用，需要一个公共pid-1的程序来充当父进程，然后管理子进程：多个应用
* 因此会使用systemd 或者 supervisord来代替 应用本身，作为容器的启动进程

### 镜像由只读层构成，每一层代表Dockerfile命令

### docker build

#### 会将当前目录的所有内容传输到docker守护进程

#### 可以使用构建缓存

## 工具

### CLI

### Docker Machine

### Docker Compose

#### docker-compose.yml

#### 用于调试，并且可以服务依赖启动

#### 支持按不同分类，使用多个compose文件

* 按一定规则对这些compose配置进行合并
* 在2.1版本开始支持，3.0版本不再支持

#### 支持部署到远程主机

* 指定三个环境变量
DOCKER_HOST, DOCKER_TLS_VERIFY,  DOCKER_CERT_PATH

### Docker Swarm

### Kubernetes

### buildx

### Dockerfile

#### 学习顺序

##### 1、build

###### 无上下文环境

* 无法ADD文件，会报错
ADD failed: file not found in build context or excluded by .dockerignore: stat test.txt: file does not exist

####### docker build - > Dockerfile

####### docker build - < archive.tar.gz（自动解压）

###### 有上下文环境

####### docker build .

##### 2、.dockerignore

###### 语法

####### # comment

注释

####### */temp*

排除根目录下，以temp开头的文件或目录

####### */*/temp*

两个层级，排除以temp开头的文件或目录

####### temp?

排除根目录下，以temp开头的文件或目录

####### !temp

除了temp文件或目录以外，其他一律排除

###### 忽略某些文件或目录，上传到守护进程，并影响ADD和COPY

###### 原理

####### go的filePath.Match和Clean

####### 后面覆盖前面排除规则

```
!README*.md
README-secret.md
```
!README*.md本来是不排除README-secret.md。
但因为最后一行包含README-secret.md，则上面的规则作废

##### 3、构建缓存

##### 4、buildkit

###### 支持密钥、用户凭证等私密信息的保护

##### 5、格式

###### 1、为了兼容旧版本，因此注释和RUN之前的空格是会被忽略

###### 2、RUN 参数，带了空格，则会保留下来

* Dockerfile如下
```shell
RUN echo "\
     hello\
     world"
```
docker build .结果如下：
     hello     world

##### 5、编写语法

###### 1、注释

* 注释分成两种，普通注释和带有功能的解释器指令
* 这种带有功能的解释器指令不能在构建时添加镜像层，所以zhineng放在注释中
* 不支持换行符

####### 解释器指令

######## 规则

######### 1、换行则无效： # direc 

######### 2、出现两次则无效：# directive=value1 # directive=value2

######### 3、没放在首行则有效，包含这两种情况：在构建器命令之后、在普通注释之后

######## syntax

######### 只能在buildkit才生效

######### 作用

########## 语法规则同步

* # syntax=docker/dockerfile:1
代表只要1版本更新，就会一直同步

* # syntax=docker/dockerfile:1.2
代表只要1.2版本更新，就会一直同步

* # syntax=docker/dockerfile:1.2.1
固定版本，从不gengxin

########## 貌似还支持自动升级依赖的服务，比如redis

######## escape

######### 作用

########## 转义字符

* \是换行
* \\是\

########## 默认转义字符是\

###### 2、ENV变量

####### 语法

* 定义
ENV var1=value1
ENV var2=

* 使用
${var1}、$var1

* 一些计算
${var2:-value2}：var1为空则值为value2；
${var1:+value3}：var1不为空则值为value3

* 一些注意3
ENV var3=3
ENV var3=4 var4=${var3}
var4的值是3


####### 特性

######## 1、即使docker build完后，依然存在于镜像中

###### 4.1 ARG

####### 实践

####### 特性

######## 1、docker build --build-arg设置的值，只在ARG声明之后才有效，之前使用，比如RUN echo ${user}，结果肯定为空

* Dockerfile
```
FROM redis
RUN echo ${user:-user1}
ARG user
RUN echo "${user}"
```

* 执行构建
docker build --build-arg user=user2 -t arg1 .
**结果**
```
Sending build context to Docker daemon  2.048kB
Step 1/4 : FROM redis
 ---> fad0ee7e917a
Step 2/4 : RUN echo ${user:-user1}
 ---> Running in 0a43db3ebe7c
user1
Removing intermediate container 0a43db3ebe7c
 ---> 860439000d10
Step 3/4 : ARG user
 ---> Running in 282c6dc7c269
Removing intermediate container 282c6dc7c269
 ---> 1802d2798563
Step 4/4 : RUN echo "${user}"
 ---> Running in f37b1075ab15
user2
Removing intermediate container f37b1075ab15
 ---> 46ddf23602e6
Successfully built 46ddf23602e6
Successfully tagged arg1:latest
```

######## 2、一次性参数，docker build后就消失

######## 3、原生字典变量

* HTTP_PROXY
* http_proxy
* HTTPS_PROXY
* https_proxy
* FTP_PROXY
* ftp_proxy
* NO_PROXY
* no_proxy

######### 特性

########## 1、docker build --build-arg 直接设置，则下次构建修改该变量值，并不会生效

<!--Note-->
########### Dockerfile没有声明HTTP_PRO

* Dockerfile
```
FROM redis
RUN echo "${HTTP_PROXY}"
```

* 执行构建
```
docker build --build-arg HTTP_PROXY=http://192.168.9.111:55555 -f Dockerfile2 -t arg2 .
```
**结果**
```
Step 1/2 : FROM redis
 ---> fad0ee7e917a
Step 2/2 : RUN echo "${HTTP_PROXY}"
 ---> Using cache
 ---> 6f7c395a97b4
Successfully built 6f7c395a97b4
Successfully tagged arg2:latest
```

* 第二次构建

**修改HTTP_PROXY的端口为5556**
```
docker build --build-arg HTTP_PROXY=http://192.168.9.111:55556 -f Dockerfile2 -t arg2 .
```
会发现一直踩中缓存，新的值并没有生效
**结果**
```
Step 1/2 : FROM redis
 ---> fad0ee7e917a
Step 2/2 : RUN echo "${HTTP_PROXY}"
 ---> Using cache
 ---> 6f7c395a97b4
Successfully built 6f7c395a97b4
Successfully tagged arg2:latest
```

########### Dockerfile声明HTTP_PROXY
```
FROM redis
ARG HTTP_PROXY
RUN echo "${HTTP_PROXY}"
```

**结果**
每次修改成新值都会缓存失效，采用新值
```
Step 1/3 : FROM redis
 ---> fad0ee7e917a
Step 2/3 : ARG HTTP_PROXY
 ---> Using cache
 ---> 9785fc4d6d3c
Step 3/3 : RUN echo "${HTTP_PROXY}"
 ---> Running in aefd4d65fc15
http://192.168.9.111:55556
Removing intermediate container aefd4d65fc15
 ---> 8b38a4e289b5
Successfully built 8b38a4e289b5
Successfully tagged arg3:latest
```

<!--/Note-->

######## 4、全局的构建变量

* 适用buildkit
* TARGETPLATFORM- 构建结果的平台。例如linux/amd64, linux/arm/v7, windows/amd64。
* TARGETOS - TARGETPLATFORM 的操作系统组件
* TARGETARCH - TARGETPLATFORM 的架构组件
* TARGETVARIANT - TARGETPLATFORM 的变体组件
* BUILDPLATFORM - 执行构建的节点的平台。
* BUILDOS - BUILDPLATFORM 的操作系统组件
* BUILDARCH - BUILDPLATFORM 的架构组件
* BUILDVARIANT - BUILDPLATFORM 的变体组件

######### 实践

* Dockerfile
```
FROM redis
ARG TARGETPLATFORM
RUN echo "TARGETPLATFORM: ${TARGETPLATFORM}"
```

* 执行构建
```
docker buildx build -t arg4 -f Dockerfile4 .
```
**结果**
```
[+] Building 0.6s (6/6) FINISHED                             
 => [internal] load build definition from Dockerfile4                                    0.0s
 => => transferring dockerfile: 172B                                                     0.0s
 => [internal] load .dockerignore                                                        0.0s
 => => transferring context: 2B                                                          0.0s
 => [internal] load metadata for docker.io/library/redis:latest                          0.0s
 => [1/2] FROM docker.io/library/redis                                                   0.0s
 => => resolve docker.io/library/redis:latest                                            0.0s
 => [2/2] RUN echo "TARGETPLATFORM: linux/amd64"                                         0.5s
 => exporting to image                                                                   0.0s
 => => exporting layers                                                                  0.0s
 => => writing image sha256:94f4266daebc049862b6d938aae8df97acb5fbd5e1a96d5a34bec1495cbecf57     0.0s
 => => naming to docker.io/library/arg4                                                  0.0s
```

######## 5、ARG声明变量，始终踩中缓存

###### 4、FROM

####### 学习顺序

######## ARG

######### 配合FROM使用，用于定义参数，比如tag

####### 语法

######## FROM [--platform=<platform>] <image>[:<tag>] [AS <name>]

######## FROM [--platform=<platform>] <image>[@<digest>] [AS <name>]

######## 说明

* platform指定目标系统，也就是你要将镜像放在哪个系统运行(比如linux/amd64、linux/arm64、windows/amd64)
* tag和digest是指定镜像的版本
* As name是对镜像起别名，方便后续其它FROM或COPY使用，只在当前构建过程生效

####### 特性

######## 1、支持多个FROM

######## 2、每个FROM执行，之前的状态都会被重置

* ENV会被重置
* ARG不会被重置

###### 7、LABEL

* 只是用于打标签，分类的功能

####### 语法

######## LABEL key1="value1" key2="value2"（所有标签都放在一行，以空格分隔每个键值对）

######## LABEL key1="value1"（每个LABEL独立一行，对应一个键值对）

####### 实践

######## docker image inspect xxxImage，可查看这个镜像有什么label

###### 10、USER

* 使用的用户是容器内部的，而不是主机的
* 用于RUN、CMD、ENTRYPOINT的权限控制

####### 语法

######## USER <UID>[:<GID>]

####### 特性

######## 如果使用的用户没有root权限，那么关闭时会遇到些问题

* Dockerfile
```shell
FROM redis
RUN useradd docker
USER docker
```

* 关闭时，发现无法关闭

^C1:signal-handler (1623661824) Received SIGINT scheduling shutdown...
1:M 14 Jun 2021 09:10:24.923 # User requested shutdown...
1:M 14 Jun 2021 09:10:24.923 * Saving the final RDB snapshot before exiting.
1:M 14 Jun 2021 09:10:24.923 # Failed opening the RDB file dump.rdb (in server root dir /data) for saving: Permission denied
1:M 14 Jun 2021 09:10:24.923 # Error trying to save the DB, can't exit.
1:M 14 Jun 2021 09:10:24.923 # SIGTERM received but errors trying to shut down the server, check the logs for more information

######## 受影响的有RUN、CMD、ENTRYPOINT

###### 11、WORKDIR

####### 语法

######## WORKDIR /path/to/workdir

####### 特性

######## 1、影响RUN、CMD、ENTRYPOINT、COPY、ADD

####### 实践

* Dockerfile
```
FROM redis
WORKDIR /a
WORKDIR b
WORKDIR c
RUN pwd
```

* 构建镜像，即可看到输出结果
docker build -t workdir1 .
```
Sending build context to Docker daemon  2.048kB
Step 1/5 : FROM redis
 ---> fad0ee7e917a
Step 2/5 : WORKDIR /a
 ---> Using cache
 ---> 08a9fe4f4910
Step 3/5 : WORKDIR b
 ---> Using cache
 ---> 5109743f9ab8
Step 4/5 : WORKDIR c
 ---> Using cache
 ---> 109d2abdf59a
Step 5/5 : RUN pwd
 ---> Running in 1a6d6d5004e8
/a/b/c
Removing intermediate container 1a6d6d5004e8
 ---> fab569a914f5
Successfully built fab569a914f5
Successfully tagged workdir1:latest
```

###### 9、VOLUME

只是声明镜像的卷，还没挂载到主机目录，需要docker run -v指定

####### 特性

######## 1、因为每个主机不一样，因此无法在Dockerfile指定卷挂载到主机上的目录，需要在docker run -v指定

######## 2、如果docker run -v没指定挂载的目录，默认是挂载到匿名卷，这样也可以保证容器不会写入内容，确保无状态

* 匿名卷的位置在/var/lib/docker/volumes
**卷的名称是随机生成**
**所以最好docker run时，手动指定，方便控制**

####### 实践

* Dockerfile
```
FROM primetoninc/jdk
RUN mkdir /myvol
RUN echo "hello world" > /myvol/greeting
VOLUME /myvol
```

* docker run -it -v /home/docker/dockerFile/volumeLearn:/myvol volume1
**进入到容器内部**
cd /myvol
touch test.txt

**退出容器**
exit

会在/home/docker/dockerFile/volumeLearn看到刚创建的test.txt

###### ADD

####### 语法

######## ADD [--chown=<user>:<group>] <src>... <dest>

######## ADD [--chown=<user>:<group>] ["<src>",... "<dest>"]

####### 特性

######## 1、支持正则表达式，原理是Go 的filepath.Match

######## 2、src只能在Dockerfile所在目录，不然会报错：ADD failed: forbidden path outside the build context: ../test2.txt ()

######## 3、chown可以是user、group的id或者是name，如果是name，docker会根据/etc/passwd和/etc/group转换成id

######## 4、src可以是远程文件，如果该文件存在访问权限，则无法使用ADD，只有wget或curl才可以配置权限

######## 5、src如果是本地压缩包（dentity、gzip、bzip2 或 xz），则会自动解压。但如果是远程地址的压缩包，则不会自动解压

####### 注意

######## 特殊字符转义

* []
文件名:arr[0].txt
在ADD时需要这么写：ADD arr[[]0].txt /mydir/

###### COPY

####### 语法

######## COPY [--chown=<user>:<group>] <src>... <dest>

######## COPY [--chown=<user>:<group>] ["<src>",... "<dest>"]

####### 特性

######## 如果src的内容已更改，则COPY后面的操作，缓存全部失效

####### 与ADD的区别

######## 1、不支持本地压缩包解压缩

######## 2、同样需求，首选COPY

###### 5、RUN

####### 语法

######## RUN <command>

* linux默认是使用/bin/sh -c执行命令
* window默认是使用cmd /S /C
* 可以使用/bin/bash -c

######## RUN ["executable", "param1", "param2"]

* RUN ["/bin/bash","-c","pwd"]

####### 特性

######## 1、RUN ["executable", "param1", "param2"]，如果没有指定executable，也就是不使用shell来执行命令，会导致无法正常shell处理：比如变量没有替换，只是当作普通字符串

```shell
FROM redis
RUN echo "shell形式，值：${HOME}"
RUN ["echo","exec形式，值：${HOME}"]
```
**结果**
```shell
Sending build context to Docker daemon  2.048kB
Step 1/3 : FROM redis
 ---> fad0ee7e917a
Step 2/3 : RUN echo "shell形式，值：${HOME}"
 ---> Running in 86bc54e9ab85
shell形式，值：/root
Removing intermediate container 86bc54e9ab85
 ---> a7ac4cfb6144
Step 3/3 : RUN ["echo","exec形式，值：${HOME}"]
 ---> Running in 2aff063c4673
exec形式，值：${HOME}
Removing intermediate container 2aff063c4673
 ---> 7f9c0775344d
Successfully built 7f9c0775344d
```

######## 2、RUN指令所操作的，会缓存起来，在下次构建，还能继续使用，比如：RUN apt-get dist-upgrade -y。如果不想缓存：docker build --no-cache

######## 3、ADD和COPY后，RUN指令的缓存就会失效

###### 6、CMD

####### 语法

######## CMD ["executable","param1","param2"]：exec方式

######## CMD ["param1","param2"]：ENTRYPOINT 方式

######## CMD command param1 param2：shell方式

####### 特性

######## 1、只支持一个CMD命令，如果多个，只有最后一个生效

######## 2、exec方式，如果没有指定executable，也就是不使用shell来执行命令，会导致无法正常shell处理：比如变量没有替换，只是当作普通字符串

######## 3、使用shell方式，默认使用/bin/sh -c执行

######## 4、docker run镜像时，就会触发CMD命令的执行

######## 5、如果docker run 带命令，则该命令替换掉CMD命令

```shell
FROM redis
CMD echo "12345"
```

docker run redis:latest redis-server

并没有打印12345，而是启动了redis

####### 实践

```shell
FROM redis
CMD echo "12345"
```

docker run后，打印：12345，而没有启动redis

###### ENTRYPOINT

####### 特性

######## 1、只有docker run <image>带了参数，ENTRYPINT才生效，才会覆盖CMD命令

* Dockerfile
```shell
FROM redis
CMD echo "hello"
ENTRYPOINT ["echo"]
```

* 执行命令后的结果
[root@basic ~]# docker run entrypoint
/bin/sh -c echo "hello"

**发现直接输出CMD的字符串，而不是执行命令**

######## 2、docker run <image>后面的参数，会替换掉ENTRYPOINT指定参数

* Dockerfile
```shell
FROM redis
CMD echo "hello"
ENTRYPOINT ["echo","hello2"]
```

* 执行命令后的结果
[root@basic entryPointLearn]# docker run entrypoint hello3
hello3

**Dockerfile中ENTRYPOINT指定的参数并没有效果**

######## 3、与CMD的互动

######### 1、如果CMD从FROM指定的基础镜像中定义，那么ENTYRPOINT会重置CMD，所以需要在当前Dockerfile再次定义

###### 8、EXPOSE

####### 语法

######## EXPOSE <port> [<port>/<protocol>...]

####### 特性

######## 1、不指定protocol，默认为tcp

######## 2、并不会发布端口，只是一种声明而已

######## 3、需要与docker run -p配合使用

####### 实践

######## EXPOSE 80

######## EXPOSE 80/tcp

####### 关联知识

######## Network

###### 12、ONBUILD

* 作为基础镜像时，想对使用该基础镜像的子镜像进行一些操作，就可以使用这个特性

* 工作原理如下：
1. 当构建镜像时，发现ONBUILD

2. 会在构建结束后，将这个触发器添加到当前镜像的元数据中，也就是镜像清单：通过docker inspect xxxImages看到OnBuild:[]存在命令集

3. 当子镜像以这个镜像为基础镜像，则ONBUILD是作为FROM的一部分来执行，如果执行失败，则FROM失败

4. ONBUILD并不会二次继承，只会触发一次

####### 语法

######## ONBUILD RUN xxxCmd

####### 特性

###### 13、STOPSIGNAL

* 向容器所处系统发出退出指令，应该是发给PID=1的进程

####### 语法

######## STOPSIGNAL signal, signal可以是 信号名称或编码

###### 14、HEALTHCHECK

* 支持以下参数
--interval=DURATION（默认值：30s）
--timeout=DURATION（默认值：30s）
--start-period=DURATION（默认值：0s）
--retries=N（默认值：3）

####### 语法

######## 1、HEALTHCHECK [OPTIONS] CMD command

######## 2、HEALTHCHECK NONE（禁用从基础镜像继承的任何健康检查）

####### 状态

1. 0（成功）
2. 1（不健康）
2. 预留

在Dockerfile中这么使用：
|| exit 1

####### 特性

######## 1. 只能有一个，最后一个才生效

####### 实践

* Dockerfile
```
FROM ubuntu
#RUN ["/bin/yum","install","curl"]
HEALTHCHECK --interval=5s --timeout=3s --retries=1  CMD curl http://localhost/ || exit 1
```

* 通过docker ps可以看到当前容器的状态
**初始状态：** starting
**不健康状态：** unhealthy
**健康状态：** healthy

* 通过docker inspect xxxContainerId
state.Health可查看详细的健康检查日志

###### 15、SHELL

* 可节省RUN、CMD、ENTRYPOINT，每次都要指定用哪种shell。用了SHELL后，只需指定一次，后面的RUN、CMD、ENTRYPOINT都按照这个shell来执行

* 特别适用于window系统，因为有CMD和POWERSHELL。当然linux系统也可以使用(比如要对一个shell使用多次)


####### 语法

######## SHELL ["executable", "parameters"]

####### 实践

* Dockerfile
```
FROM ubuntu
WORKDIR /home
SHELL ["/bin/mkdir"]
RUN a
CMD b
```

* 进去该容器
只创建a目录，b目录并没有创建
怀疑CMD没法用

#### 技巧

##### 1、通过dockerignore，可减少内容推送到守护进程以及copy到容器内部

## 学习资源

### docker-curriculum

## 延伸词汇

### OCI image

## 必须掌握

### Dockerfile文件的编写

### compose文件的编写

## 疑问

### 一个容器只能启动一个容器

## 坑

### 即使使用CGroup后，查看top的信息依然是宿主的信息

https://zhuanlan.zhihu.com/p/101059102
* 查看/pro/meminfo文件和free -m，会发现是宿主机的资源信息，而不是容器的

* 但top看到的是容器的

* 可用lxcfs解决
原理是重新挂载容器的/pro/meminfo到lxcfs自己的文件。由他来拦截去获取cgroup的信息

* k8s也可以使用lxcfs
阿里云提供了解决方案：通过启动lxcfs的pod，作为监听事件来处理proc挂载到lxcfs

### 主机和容器的时间相差8小时(时区不同)

## 网络

### 原始三种方式

### ICC

* Inter Container Communication

### 链接(被自定义网络所替代)

* 早期的网络安全策略
* 启动容器时指定--link为某个容器名，代表可以访问该容器

### 自定义网络

* 自定义网路中别名
* 配置链接(支持修改链接容器的引用别名)


### 嵌入式的DNS服务器

* docker守护进程中已注册

## 命令

### docker system(存储相关清理)

### docker-compose

* docker-compose up
前台启动
* docker-compose up -d
后台启动
* docker-compose ps
查看通过compose启动的容器列表
* docker-compose run web env
一次性启动命令，可理解为不会真实启动和绑定端口，但会创建容器。

这里用来查看web这个service有哪些环境变量
* docker-compose stop
退出，并删除容器
* docker-compose down --volumes
不仅是退出，而且是完全删除容器，这里是删除redis容器使用的数据量

#### .env

* 默认是当前项目目录，通过--env-file修改路径
* shell定义的变量，其优先级高于.env

#### run service

#### 分支主题

### docker build

### docker history

查看某个镜像的构建历史，并且跟缓存有关

### docker info

## 原理

### docekr build创建镜像原理

1. 镜像由只读层构成 
Dockerfile的每条指令都独立运行，互不影响，并且每条指令都会创建一个只读层，然后堆叠起来，每一层都是前一层的增量

#### 学习顺序

##### 1、关于存储驱动程序

* 创建容器时，会在镜像层之上增加一层读写层。容器的所有文件都操作都在这层操作
* 读写层的读写速率比原生文件系统慢
* docker ps -s查看容器的所占大小
这个大小并不是所有容器的总大小，因为有些容器是共享同一个镜像；或者是共享某一镜像层，就会导致总大小偏大

### docker run创建容器原理

## 不懂的

### Dockerfile的注释：syntax

## 词汇表

## Docker桌面

### window下Docker集成

#### 开发环境(还处于测试阶段)

##### 支持常规Docker使用(拉取镜像、启动容器)，首选界面操作，当然也可以命令操作(使用wsl2 ，使得window可支持linux)

##### 团队协助（只是一种结合git拉取项目，并启动容器而已）
