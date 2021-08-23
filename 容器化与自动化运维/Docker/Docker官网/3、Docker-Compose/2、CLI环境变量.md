[TOC]

# 说明
* 跟docker-compose命令带变量是一个效果
* 只是才用了环境变量方式

| 环境变量名           | 描述                                                                                                                                                                                                                          |
| -------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| COMPOSE_PROJECT_NAME | 为了避免不同项目，在yaml中配置服务时，配置了相同服务名，导致互相干扰；**因此需要加上项目名，加以区分**，启动compose时，这些服务会生成容器并启动，容器名称：xxxProject_xxxServiceName                                          |
| COMPOSE_FILE         | 支持Compose配置文件的路径，默认是当前目录下的`docker-compose.yml`；支持指定多个，分隔符视系统不同而不同(在 Linux 和 macOS 上，路径分隔符是`:`，在 Windows 上是`;`)：`COMPOSE_FILE=docker-compose.yml:docker-compose.prod.yml` |
| COMPOSE_PROFILES | 环境切换；’Compose yaml配置服务，可指定profiles属性，意味着只有这个profile环境才启动该服务；没有指定profile的服务则默认启动。 [Using profiles with Compose_](https://docs.docker.com/compose/profiles/) |
|  |  |
|  |  |
|  |  |
|  |  |
|  |  |
|  |  |
|  |  |
|  |  |
|  |  |
|  |  |
|  |  |
|  |  |
|  |  |







