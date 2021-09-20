[TOC]

# 概念
The routing mesh enables each node in the swarm to accept connections on published ports for any service running in the swarm, even if there’s no task running on the node.
这一句跟前一句不一致
The routing mesh routes all incoming requests to published ports on available nodes to an active container.
routing mesh将访问publish port的请求，路由到可用节点上活着的容器

# 特性
* 默认对外发布的协议是tcp

## 外部负载均衡器
### 路由网络（route mesh）
* **当创建对外发布服务，即使某个集群节点没有运行该服务对应的容器（任务），swarm也会在每个集群监听该端口，route mesh就出来将该请求负载到有容器运行的其它集群节点上**[[Docker重点]]
![[Pasted image 20210920132624.png]]
[13-Docker Swarm(三)：集群服务间通信之RoutingMesh](https://blog.csdn.net/huangjun0210/article/details/86478157)（待学习）[[2021-09(38)]]

# 参数
| 参数名 | 描述 | 例子 |
| ------ | ---- | ---- |
|        |      |      |



 # 实操
 1. 创建服务
 指定对外发布端口和容器内部端口、副本数
 `docker service create --name helloSwarmPublish --publish published=18080,target=8080 --replicas 3 local.harbor.com/library/swarm-publishport-helloworld:latest`

2. 中途增加对外发布
```
docker service update --publish-add published=<PUBLISHED-PORT>,target=<CONTAINER-PORT> <SERVICE>
```