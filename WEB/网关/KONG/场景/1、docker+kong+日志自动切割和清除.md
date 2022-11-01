[TOC]

# 部署kong，并记录日志

1. 前提
> 需要部署postgres，创建的容器名称必须为postgres

2. Dockerfile
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

3. 构建镜像：[[附件/网关/kong/build.sh]]
`docker build -t local.harbor.com/library/kong-custom:2.0.4 .`

4. 配置文件：[[附件/网关/kong/config/nginx_kong.lua]]
	[官方配置例子](https://github.com/Kong/kong/blob/5de2641ecd919002a935297cd8e3e7c37417721d/kong/templates/nginx_kong.lua)

> 以http查询接口为例，打印访问日志和请求体信息

```
log_format grab_dataserver_access escape=json '{"uuid":"$arg_uuid", "body_id":"$arg_uuid", "head": {"Status":"$status", "Request-Method":"$request_method", "Time":"$time_now", "Host":"$upstream_x_forwarded_host", "Uri":"$uri", "Body-Bytes-Sent":"$body_bytes_sent", "Remote-Addr":"$upstream_x_forwarded_for", "Content-Type":"$content_type", "useTime":"$request_time", "token":"$arg_accessKey"}, "reports" : {"orangeapigate_report" : {"report_name" : "API网关74", "layer":"0", "isError":"false", "exception":"", "report_time" : "$time_now"}}}';
log_format grab_dataserver_body escape=json '{"uuid":"$arg_uuid", "body":"$request_body"}';
```

> 变量解释

`使用了nginx作为入口，负载两个kong实例，请求地址和请求体如下：`
```
http://192.168.5.74:8000/data-server/query?uuid=111x8688-ad4c-40a7-b94e-729eb199adcb&action=TO0016&accessKey=b7eef217-16be-a0b4-cc92-be7ac46b3ad9&creationTime=20221028105459
```

```json
{
    "isPage": true,
    "pageNo": 1,
    "pageSize": 10,
    "visitTypeCode": "1",
    "visitNo": "000921617700",
    "visitTimes": "31"
}
```


| 名称                       | 说明                                                                               |
| -------------------------- | ---------------------------------------------------------------------------------- |
| $arg_uuid                  | arg为nginx内置变量。url上的参数：?后面的参数                                                           |
| $status                    | nginx内置变量：HTTP响应码                                                          |
| $request_method            | nginx内置变量：请求方法（GET、POST、DELETE等）                                     |
| $time_now                  | 自定义时间变量（精确到毫秒），在pre-function插件编写赋值。![[Pasted image 20221101114536.png]]```lua</br>local nowMill=tostring(ngx.now()) local m, err = ngx.re.match(nowMill, "[\\.]+[\\d]+") if m then nowMill = m[0] else nowMill = "" end local nowIsoTime = ngx.var.time_iso8601 nowIsoTime = ngx.re.gsub(nowIsoTime, "\\+", nowMill .."+" ) ngx.var.time_now = nowIsoTime</br>```                           |
| $upstream_x_forwarded_host | kong内置变量：请求链路上经过的所有中转机器的IP（不包含客户端IP） 。[官方源码](https://github.com/Kong/kong/blob/f3ddf498ad029226b85261060f1a00507e059f2a/kong/runloop/handler.lua#L1513)                 |
| $uri                       | nginx内置变量：没携带请求参数的URL。比如`/data-server/query`                       |
| $body_bytes_sent           | nginx内置变量：nginx响应给客户端的请求体大小（不包含响应header的大小，单位为字节） |
| $upstream_x_forwarded_for  | kong内置变量：请求链路上经过的所有机器的IP（包含客户端IP，以`,`隔开：`10.101.12.25, 192.168.5.74`）。[官方源码](https://github.com/Kong/kong/blob/f3ddf498ad029226b85261060f1a00507e059f2a/kong/runloop/handler.lua#L1504)                                                                 |
| $content_type              | nginx内置变量：请求体的格式（如`application/jso`）                                                                                   |
| $request_time              | nginx内置量：从客户端读取第一个字节数开始，到读取完的时间（单位：毫秒，可以理解为客户端接收到upstream响应的时间）                                                                                   |
| $arg_accessKey             | arg为nginx内置变量。url上的参数：?后面的参数                                                                        |
[nginx内置变量清单](http://nginx.org/en/docs/varindex.html)

4. 在你指定的目录，创建日志文件和授权
```shell
touch dataServer.access.log
chmod 777 dataServer.access.log

touch dataServer.body.log
chmod 777 dataServer.body.log
```

5. 启动：[[附件/网关/kong/start.sh]]
>需要挂载nginx_kong配置和日志目录
```shell
docker run -d --name kong --restart=always  --link postgres:kong-database  -p 8000:8000 -p 8443:8443   -p 8001:8001  -p 8444:8444 --volume="/home/software/kong/config/nginx_kong.lua:/usr/local/sha
re/lua/5.1/kong/templates/nginx_kong.lua" --volume="/home/kong-log/:/home/kong-log/"  local.harbor.com/library/kong-custom:2.0.4
```

6. 查看日志：[[附件/网关/kong/log.sh]]
```
./log.sh
```

6. 关闭：[[附件/网关/kong/shutdown.sh]]
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
2. 只保留7天，并且会压缩文件
3. 执行完切割步骤后，执行**重新打开kong日志的写操作：docker container kill kong -s USR1**：是为了确保新日志保存到新创建的文件

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

[参数讲解](https://zhuanlan.zhihu.com/p/265812809)
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
    rotate 7
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
每天执行凌晨1点执行一次

crontab -e，填写如下（分 时 天 月 周）
`* 1 * * * sudo  logrotate -vf /etc/logrotate.d/kong-log-rotate`