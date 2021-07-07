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

# 容器