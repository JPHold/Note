[TOC]

# 部署kong，并记录日志
* Dockerfile
```docker
FROM kong:2.0.4

ENV TZ=Asia/Shanghai
ENV KONG_PG_PASSWORD=kongpw
ENV KONG_DATABASE=postgres
ENV KONG_PG_HOST=kong-database
ENV KONG_CASSANDRA_CONTACT_POINTS=kong-database
ENV KONG_PROXY_ACCESS_LOG=/dev/stdout
ENV KONG_ADMIN_ACCESS_LOG=/dev/stdout
ENV KONG_PROXY_ERROR_LOG=/dev/stderr
ENV KONG_ADMIN_ERROR_LOG=/dev/stderr
ENV KONG_ADMIN_LISTEN="0.0.0.0:8001, 0.0.0.0:8444 ssl"
````

* 构建镜像：build.sh
`docker build -t local.harbor.com/library/kong-custom:2.0.4 .`

* 启动：start.sh
>需要挂载nginx_kong配置和日志目录
```shell
docker run -d --name kong --restart=always  --link postgres:kong-database  -p 8000:8000 -p 8443:8443   -p 8001:8001  -p 8444:8444 --volume="/home/software/kong/config/nginx_kong.lua:/usr/local/sha
re/lua/5.1/kong/templates/nginx_kong.lua" --volume="/home/kong-log/:/home/kong-log/"  local.harbor.com/library/kong-custom:2.0.4
```

* 关闭：shutdown.sh
```shell
docker stop kong
docker rm kong
```

# 配置Logrotate
> Linux自带工具

`vim /etc/logrotate.d/kong-log-rotate`
> 第一行为你要切割的日志，支持模糊匹配（正则表达式）

原理：
1. 按天自动切割，将当前文件改名成昨天日期，然后以当前日期创建新文件
2. 只保留14天，并且会压缩文件
3. 执行完切割步骤后，执行**重新打开日志的读操作：docker container kill kong -s USR1**：是为了确保新日志保存到新创建的文件

```shell
/home/kong-log/webservice.*.log {
    daily
    rotate 14
    dateext
    compress
    delaycompress
    missingok
    notifempty
    create 777 root root
    postrotate
        docker container kill kong -s USR1
    endscript 
}
```

[参数讲解](https://segmentfault.com/a/1190000013191786)
[部分参数讲解和配置讲解](https://blog.huoding.com/2013/04/21/246)
[docker+nginx启动切割，并告知重新打开文件](https://www.jb51.net/article/146513.htm)

## 模拟测试
* 测试功能（查看日志）
`logrotate -d /etc/logrotate.d/kong-log-rotate`

* 强制切割（真实执行）
`logrotate -vf /etc/logrotate.d/kong-log-rotate`

## 其它场景的配置
### 采用拷贝、清除内容方式来自动切割
原理:
1. 拷贝当前文件的内容
2. 将当前文件清空日志
3. 拷贝的内容保存到新创建的昨天日期文件
```shell
/home/kong-log/webservice.*.log {
    daily
    rotate 14
    dateext
    compress
    delaycompress
    missingok
    notifempty
    create 644 root root
    copytruncate
}
```

### 非docker部署的nginx，执行**重新打开日志的读操作**是不一样的
```shell
/home/kong-log/webservice.*.log {
    daily
    rotate 14
    dateext
    compress
    delaycompress
    missingok
    notifempty
    create 644 root root
    postrotate
        kill -USR1 `cat /var/run/nginx.pid`
    endscript
}
```

# 配置定时执行
crontab -e，填写如下（分 时 天 月 周）
`* 1 * * * sudo  logrotate -vf /etc/logrotate.d/kong-log-rotate`