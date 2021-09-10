[TOC]

# 概念
The routing mesh enables each node in the swarm to accept connections on published ports for any service running in the swarm, even if there’s no task running on the node.
这一句跟前一句不一致
The routing mesh routes all incoming requests to published ports on available nodes to an active container.
routing mesh将访问publish port的请求，路由到可用节点上活着的容器