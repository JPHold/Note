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

### 仅作为管理节点，不充当工作节点
默认管理节点，也能从当工作节点，接收任务执行；但因为raft共识，需要一些资源，所以一般需要与阻止swarm操作（心跳检测和leader选举）的线程隔离开来。
所以需要限制一下，只充当管理节点
```
docker node update --availability drain <NODE>
```

# 在swarm管理工作节点
## 添加工作节点以负载均衡
直接添加即可

# 监控集群的健康
## 查看健康状况
* 获知管理状态（管理节点，是否可用）
```
docker node inspect <NODE> --format "{{ .ManagerStatus.Reachability }}"
```
`unreachable`代表不可用
**如果解决不可用**
1. 重启docker daemon
2. 重启服务器
3. 如果还不行就需要将新服务器加入，充当管理节点；并且需要将之前不可用的管理节点降级和删除
`docker node demote <NODE>`
`docker node rm <NODE>`	

* 获知工作状态（工作节点才有）
```
docker node inspect <NODE> --format "{{ .Status.State }}"
```
`ready`代表可用

* 获知集群中各个节点的健康概览
`docker node ls`

## 对管理节点的故障排除
不要通过raft从另一个节点复制数据目录到出问题的管理节点，然后重新启动。
为何这样，原理如下：
1. shu'j


# 注意
## 管理节点必须指定静态ip
`--advertise-addr`

## 工作节点可指定动态ip