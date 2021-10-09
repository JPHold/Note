[TOC]

https://docs.docker.com/engine/swarm/admin_guide/

# 在Swarm操作管理节点
根据[Raft Consensus Algorithm](https://docs.docker.com/engine/swarm/raft)[[6、Swarm的raft集群一致性]]]这篇文档，来管理swarm节点

* 管理节点的个数没有限制
* 在性能和容错这两个维度来权衡，因为需要同步集群中每个节点的状态，过多的管理节点，会导致消耗更多的网络资源

## 配置管理节点的部署
### 维持管理节点的个数
* 最好是奇数的节点个数
* 最后一个管理节点都不可用时，之前运行的任务继续运行，只是影响swarm节点的添加、更新、删除；服务的管理
* 为何需要奇数个数：基于raft共识算法，重新选举leader，需要半数以上同意才可以当，比如4个点，一半就是2，因为是半数以上，所以要前进+1，变成3，只允许一个节点down掉
![[Pasted image 20211009234821.png]]

### 管理节点在服务器该如何分布
![[Pasted image 20211009235212.png]]

# 注意
## 管理节点必须指定静态ip
`--advertise-addr`

## 工作节点可指定动态ip