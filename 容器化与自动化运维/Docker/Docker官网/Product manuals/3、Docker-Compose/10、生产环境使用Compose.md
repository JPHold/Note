[TOC]

# 上正式环境的提前
正式环境都是部署多点的应用

* 去除卷绑定到主机目录，防止从外部修改代码
* 绑定到主机的不同端口
* 以不同方式设置环境变量，比如减少日志的详细程度、指定电子邮件
* 指定重启策略：restart:alway避免停机
* 添加额外服务：日志聚合器(如ELK)
* 使用另一个compose文件，比如production.yml，使用正式环境配置（如中间件）

# 更新部署
`docker-compose up`的流程：重建镜像、停止容器、销毁容器、重建web服务容器、启动

`docker-compose up --no-deps web`不会重建任何web依赖的服务

# 负载部署
通过compose可将一个应用部署到其他docker主机上：需要这些配置`DOCKER_HOST`、`DOCKER_TLS_VERIFY`、 `DOCKER_CERT_PATH`