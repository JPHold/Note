[TOC]

# 镜像
## 减少层数
少一层，则减少一个目录及其涵盖的文件(/var/lib/docker/overlay2)/。下面列出证据

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
差别是第二个是将第一个的第3、4行，浓缩到一行命令
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
### 下载文件啥的，用完后就删除掉
### 
    ●当想创建的容器是一样的(比如同个程序，不容环境)，那么把动态变量抽出来，作为构建变量ARG，构建时传入这些变量值，就节省了复制同一份Dockerfile。
    ●环境变量，如果只是某个RUN命令使用，那就不要设置环境变量，因为会传递到子镜像，可以使用export
RUN export DEBIAN_FRONTEND=noninteractive ;\
    apt-get update ;\
    echo and so forth
    ●用好tag，标记tag 命令https://docs.docker.com/engine/reference/commandline/tag/
    ●日志滚动
避免日志盲目增长，最终导致存储满了
修改/etc/docker/daemon.json，使用log-opts或启动容器时指定--log-opt
https://docs.docker.com/engine/admin/logging/overview/#/json-file-options

# 容器
●容器创建和启动时间要快，要保证扩缩容迅速
满足应用开发的十二准则：https://12factor.net/disposability

    ●保证PID为自己运行的程序，方便在docker stop型信号后，可以转发关闭信号给子线程，防止出现僵尸进程。上面所述是一个容器一个进程，但实际有时不遵守，一个容器多个应用，那就需要tini的帮助了(docker 从某个版本开始支持tini)
https://github.com/krallin/tini/issues/8

    ●确保一个容器一个责任一个流程
只放一个应用
    ●使用共享卷volume，共享数据
https://docs.docker.com/engine/tutorials/dockervolumes/