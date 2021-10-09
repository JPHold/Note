[TOC]

[swarm-task-states](https://docs.docker.com/engine/swarm/how-swarm-mode-works/swarm-task-states/)

通过`docker service ps <service-name>`查看状态，CURRENT STATE字段显示当前状态和处于该状态的时长

# 状态清单
| 任务状态 | 描述 |
| -------- | ---- |
| NEW | 任务已初始化。 |
| PENDING | 分配了任务的资源。 |
| ASSIGNED | Docker 将任务分配给节点。 |
| ACCEPTED | 任务已被工作节点接受。如果工作节点拒绝任务，则状态更改为REJECTED。 |
| PREPARING | Docker 正在准备任务。 |
| STARTING | Docker 正在启动任务。 |
| RUNNING | 任务正在执行。 |
| COMPLETE | 任务退出时没有错误代码。 |
| FAILED | 任务退出并显示错误代码。 |
| SHUTDOWN | Docker 请求关闭任务。 |
| REJECTED | 工作节点拒绝了该任务。 |
| ORPHANED | 节点停机时间过长。 |
| REMOVE | 任务不是终端，但相关的服务已被删除或缩小。 |