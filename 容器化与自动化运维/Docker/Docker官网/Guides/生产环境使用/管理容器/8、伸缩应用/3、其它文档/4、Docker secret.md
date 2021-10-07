[TOC]

[Manage sensitive data with Docker secrets](https://docs.docker.com/engine/swarm/secrets/)

# 好处
* 避免密码、私钥、证书等存储在Dockefile或容器中，导致泄漏
*  docke secret创建的敏感数据以文件形式保存
* docke secret创建的敏感数据，只有在使用该敏感数据的服务处于启动状态才能访问，直接启动对应的容器并无法操作该敏感数据