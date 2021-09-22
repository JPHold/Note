[TOC]

1、提供者使用默认网络：桥接网络部署，其它服务器（消费者）无法访问
因为桥接网络是子网，比如：  172.17.0.14，dubbo会将这个ip注册到注册中心，原理如下：
![[Pasted image 20210922174145.png]]

* 参考资料
[主机配置](https://dubbo.apache.org/zh/docs/v2.7/user/examples/set-host/#%E5%9C%A8%E4%BD%BF%E7%94%A8-docker-%E6%97%B6%E6%9C%89%E6%97%B6%E9%9C%80%E8%A6%81%E8%AE%BE%E7%BD%AE%E7%AB%AF%E5%8F%A3%E6%98%A0%E5%B0%84%E6%AD%A4%E6%97%B6%E5%90%AF%E5%8A%A8-server-%E6%97%B6%E7%BB%91%E5%AE%9A%E7%9A%84-socket-%E5%92%8C%E5%90%91%E6%B3%A8%E5%86%8C%E4%B8%AD%E5%BF%83%E6%B3%A8%E5%86%8C%E7%9A%84-socket-%E4%BD%BF%E7%94%A8%E4%B8%8D%E5%90%8C%E7%9A%84%E7%AB%AF%E5%8F%A3%E5%8F%B7%E6%AD%A4%E6%97%B6%E5%8F%88%E8%AF%A5%E5%A6%82%E4%BD%95%E8%AE%BE%E7%BD%AE)
[[Proposal]support hostname or domain in service discovery](https://github.com/apache/dubbo/issues/2043)

官网给出解决方案是：
-   DUBBO_IP_TO_REGISTRY — 注册到注册中心的ip地址
-   DUBBO_PORT_TO_REGISTRY — 注册到注册中心的port端口
-   DUBBO_IP_TO_BIND — 监听ip地址
-   DUBBO_PORT_TO_BIND — 监听port端口
**手动指定注册中心的ip地址**
自己试了试，没成功：
`docker run --rm --name hjp-files-p -p 20997:20997  -e DUBBO_IP_TO_REGISTRY=cdrtestserver01 -e DUBBO_PORT_TO_REGISTRY=20997 hjp-files-p`

* 使用主机网络，成功访问
`docker run -d --name hjp-files-p --network=host hjp-files-p`
[Docker 容器内运行 Dubbo 服务](https://blog.csdn.net/my___dream/article/details/90489984)
这个篇文章描述，当有多个虚拟网卡时，会有提供者注册不上，消费者无法知道提供者（待核查）[[Docker重点]]
[Dubbo多虚拟网卡情况下 怎么配置消费者指定真实ip](https://github.com/apache/dubbo/issues/6588)
提供了解决方案，手动指定网卡：`-Ddubbo.network.interface.preferred=${your-network-interface-name}`

* 使用主机网络+写死host，成功访问
`docker run -d --name hjp-files-p --network=host hjp-files-p`
![[Pasted image 20210922175920.png]]

* 使用主机网络，性能会提升，同时也导致端口很容器冲突
比如使用同一个tomcat镜像来启动应用，那么就会端口冲突，所以需要将配置作为环境变量配置：
[Tomcat Server.xml引环境变量、指定webapps下的项目启动、访问加前缀](https://blog.csdn.net/u014203449/article/details/110850774)