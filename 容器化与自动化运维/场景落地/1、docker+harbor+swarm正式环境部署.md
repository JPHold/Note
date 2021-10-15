[TOC]

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

## 回滚
`docker service update --rollback uat-cdr-c`
![[Pasted image 20211015162450.png]]