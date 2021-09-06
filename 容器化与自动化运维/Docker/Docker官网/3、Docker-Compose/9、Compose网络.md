[TOC]

# 版本问题
* v1版本已经弃用
* 支持v2及以上

# 基础特性
 * 以当前目录名或指定的目录名，创建默认网络
 * 当前compose文件内的服务容器都加入到该网络
 * 服务之间通过hostname访问，而hostname是以compose文件中该服务定义的名称
 * 重新启动时docker-compose up，会为服务分配新ip，通过hostname访问时，会自动发现改了ip，而使用新ip
 * 通过links给其他服务起别名，同时hostname也会改成这个名字，[compose-link](https://docs.docker.com/compose/compose-file/compose-file-v2/#links)
web服务可以使用db或database访问db服务
```yaml
version: "3.9"
services:

  web:
    build: .
    links:
      - "db:database"
  db:
    image: postgres
```

# 几种网络方式
## 多主机网络
启用swarm集群方式的docker引擎主机，可使用overlay驱动程序启用多主机通信[[Docker重点]]。[swarm-多主机网络入门](https://docs.docker.com/network/network-tutorial-overlay/)

## 支持自定义网络
```yaml
version: "3.9"

services:
  proxy:
    build: ./proxy
    networks:
      - frontend
  app:
    build: ./app
    networks:
      - frontend
      - backend
  db:
    image: postgres
    networks:
      - backend

networks:
  frontend:
    # Use a custom driver
    driver: custom-driver-1
  backend:
    # Use a custom driver which takes special options
    driver: custom-driver-2
    driver_opts:
    foo: "1"
    bar: "2"
```

# 配置
## 支持修改默认网络的配置
    3.支持将默认网络改成外部创建的网络(已存在的网络，即不是compose文件创建的网络)
    4.自定义网络支持指定静态ip(v4和v6都可以)
    5.从compose文件的version3.5开始，支持自定义名