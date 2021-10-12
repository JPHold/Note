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
1. 数据目录跟节点id是绑定的，全局唯一的；意味着到其它节点并不能使用
2. 分配的一个节点id，节点只能加入一次swarm

所以要将管理节点，干净地重新加入集群，只能如下：
1. 降级到工作节点：`docker node demote <NODE>`
2. 移除节点：`docker node rm <NODE>`
3. 重新加入：`docker swarm join`

## 节点无响应（可能被入侵），需退出集群
普通删除节点的前提：必须先停用节点。
但因无法访问，这时就需要强制删除该节点，并且删除节点的前提是降级到工作节点，失去操纵集群的能力
```
docker node rm --force <NODE>
```

## 备份swarm集群数据
* 是在管理节点上备份
* 待备份数据在`/var/lib/docker/swarm/`目录，所以备份整个目录即可
* 当前管理节点必须关闭docker，不然恢复备份数据，可能会出错
* 当前管理节点关闭后，其它节点会继续产生数据，所以是一种冷备方式
* 因为关闭docker，管理节点也会退出集群，需要保证剩余管理节点个数满足[[#维持管理节点的个数]]
* 最后重启管理节点

## 灾难恢复
### 使用备份数据恢复swarm状态到新集群
1. 关掉新集群中的主机的docker
2. 删除源`/var/lib/docker/swarm/`目录
3. 将备份的该目录复制过去
4. 初始化启动，按正常启动，可能会连接到旧swarm中已经不存在的节点，因此要执行如下命令
```
docker swarm init --force-new-cluster
```
5. 验证集群是否可用
`docker service ls`
6. 添加新管理节点和工作节点，具备执行能力


### 恢复可用节点数
当发生一些问题，导致管理节点不可用，剩余的管理节点个数必须满足[[#维持管理节点的个数]]的中间那栏定义的数目，不然无法管理swarm，包含：新增更新服务、新增删除节点，但之前的任务依然继续运行。

* 无法管理swarm的容错数的计算公式：(N-1)/2，比如5，则容错为2
* 当不可用的管理节点个数超过容错数，就需要恢复，如果依然无法恢复，则需要如下命令：
`docker swarm init --force-new-cluster`
强制初始化为单节点集群，除了当前节点，其它管理节点都从集群移除。
移除后，因为是一个节点，个数为1，符合法定人数，因此可以管理swarm。
这时就要一个个将之前的管理节点，重新加入到集群中：
```
docker swarm init --force-new-cluster --advertise-addr node01:2377
```

## 绝对负载均衡
当一个新节点加入到集群中或恢复后加入到集群中，swarm采取的策略：即使当前节点很空闲，也不会重新平均分配，因为这会中断客户端的访问。

* 如果想平均分配
`docker service update --force`，会滚动更新

* 也可以再次修改任务实例数，达到平均分配
`docker service scale`

* 通过如下命令，查看服务的配置比例
`docker service inspect --pretty <servicename>`

# 注意
## 管理节点必须指定静态ip
`--advertise-addr`

## 工作节点可指定动态ip