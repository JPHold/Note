[TOC]

# 配置Logrotate
> Linux自带工具

`vim /etc/logrotate.d/kong-log-rotate`
> 第一行为你要切割的日志，支持模糊匹配（正则表达式）

按天自动切割，以创建日期命名文件；只保留14天，并且会压缩文件；执行完切割步骤后，执行**重新打开日志的读操作：docker container kill kong -s USR1**
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
### 非docker部署的nginx
```shell
kill -USR1 `cat /var/run/nginx.pid`
```

# 配置定时执行
crontab -e，填写如下（分 时 天 月 周）
`* 1 * * * sudo  logrotate -vf /etc/logrotate.d/kong-log-rotate`