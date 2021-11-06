[TOC]

# 配置流程
## docker层面的配置

### 安装docker-compose（用于安装harbor）
**直接到docker官方，在线安装或手动安装，只是个命令，配好链接即可**

### 安装harbor
[[2、配置和启动]]

### 安装swarm
随docker一起安装，无须再安装

### 配置管理器节点

### 配置工作节点

## 测试环境jenkins部署

## 正式环境jenkins部署



# 问题
1. 各个worker节点启动应用，会拉取镜像，但tag都为空，push到harbor资源库是带了tag，这边显示为空
![[Pasted image 20211015160331.png]]
![[Pasted image 20211015160349.png]]

2. 需要在每个worker节点，清理空tag镜像

# 经验
## service默认保留5个容器副本，超过了，会将最早的容器删除，但没有删除镜像
![[Pasted image 20211015160928.png]]
![[Pasted image 20211015160949.png]]
![[Pasted image 20211015161105.png]]

**记得在jenkins、swarm的管理器节点、工作节点执行删除**
```
docker rmi `docker images -f "dangling=true"`
```

## 回滚
`docker service update --rollback uat-cdr-c`
![[Pasted image 20211015162450.png]]

## jenkins的自定义环境变量名称不能为-
