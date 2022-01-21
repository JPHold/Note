[TOC]

> 以kong记录请求日志，filebeat扫描日志并推送给logstash，logstash监听并异构格式，上传到es
> 所有的配置都在[[附件/日志/ELK/logstash/README]]

# 部署logstash
* **拉取镜像，并重新打标签（用于上传到本地harbor，如果没有则忽略）**
```shell
docker pull docker.elastic.co/logstash/logstash:6.7.0
docker tag docker.elastic.co/logstash/logstash:6.7.0 local.harbor.com/library/logstash:6.7.0
```

---

* **安装插件，并制作新镜像（以后要安装新插件，都修改这个Dockerfile）**

Dockerfile文件在：[[附件/日志/ELK/logstash/README]]目录/build-images/Dockerfile
```shell
FROM local.harbor.com/library/logstash:6.7.0
WORKDIR /usr/share/logstash

#在线安装插件
RUN ./bin/logstash-plugin install logstash-output-jdbc
```

制作镜像脚本在：[[附件/日志/ELK/logstash/README]]目录/build-images/build.sh
`docker build -t local.harbor.com/library/logstash-with-plugin:6.7.0 .`

---

* 编写Dockerfile，将所需配置文件、依赖打包进去

Dockerfile文件在：[[附件/日志/ELK/logstash/README]]目录/Dockerfile
```shell
FROM local.harbor.com/library/logstash-with-plugin:6.7.0
WORKDIR /usr/share/logstash

#拷贝处理配置文件
COPY config/logstash.conf ./pipeline/

#拷贝所需资源
RUN mkdir ./pipeline/jar
ADD jar ./pipeline/jar

#拷贝logstash本身的配置文件
COPY config/logstash.yml ./config

#拷贝日志配置文件
COPY config/log4j2.properties ./config

#logstash.conf所需的配置变量
ENV kafkaUrl xxIp0:xxxPort0,xxIp1:xxxPort1
ENV oracleUrl=jdbc:oracle:thin:@xxxIp:xxxPort/xxxServiceName
ENV oracleUserName xxxUser
ENV oraclePassword xxxPassword
ENV esUrl=xxxIp:xxxPort
ENV esUser=xxxEsUser
ENV esPassword=xxxEsPassword
ENV driverJarPath=/usr/share/logstash/pipeline/jar/ojdbc14-10.2.0.jar

ENV TZ=Asia/Shanghai
```


logstash处理程序配置文件在：[[附件/日志/ELK/logstash/README]]目录/config/logstash.conf
**通过临时字段：`add_field => { "[@metadata][type]" => "allMessages" }`或日志的特征信息，分别用不同代码去处理**
```shell
input {
   beats {
        port => 5044
   }
   kafka {
        bootstrap_servers => ["${kafkaUrl}"]
        group_id => "all_message_consumer"
        topics => ["all_message"]
        consumer_threads => 10
        client_id => "logstash-0-all_message"
        type => "allMessages"
    }
   kafka {
        bootstrap_servers => ["${kafkaUrl}"]
        group_id => "cdrReports_consumer"
        topics => ["logCdrStandard"]
        consumer_threads => 5
        client_id => "logstash-0-logCdrStandard"
        type => "cdrReports"
    }
}

filter{
  if [source] == "/usr/share/filebeat/file-log/webservice.access.log"{
    json {
        source => "message"
    }
    mutate {
        remove_field =>["@version"]
        remove_field =>["message"]
        remove_field =>["offset"]
        remove_field =>["log"]
        remove_field =>["prospector"]
        remove_field =>["host"]
        remove_field =>["tags"]
        remove_field =>["beat"]
        remove_field =>["@timestamp"]
        remove_field =>["input"]
        remove_field =>["source"]
        add_field => { "[@metadata][operation]" => "gateWayLog" }
    }
 }
 if [type] == "allMessages" {
    json {
        source => "message"
    }
    mutate {
        remove_field =>["@version"]
        remove_field =>["@timestamp"]
        remove_field =>["message"]
        remove_field =>["id"]
        remove_field =>["origin"]
        remove_field =>["ip"]
        remove_field =>["userId"]
        remove_field =>["userName"]
        remove_field =>["label"]
        remove_field =>["loginName"]
        remove_field =>["sessionId"]
        remove_field =>["method"]
        remove_field =>["arguments"]
        remove_field =>["stackTrace"]
        remove_field =>["processTime"]
        remove_field =>["status"]
        remove_field =>["createAt"]
        remove_field =>["msgId"]
        remove_field =>["type"]
        add_field => { "[@metadata][type]" => "allMessages" }
        remove_field =>["allMessages"]
    }
 }
 if [type] == "cdrReports" {
    json {
        source => "message"
    }
    mutate {
        remove_field =>["@version"]
        remove_field =>["@timestamp"]
        remove_field =>["message"]
        remove_field =>["id"]
        remove_field =>["origin"]
        remove_field =>["ip"]
        remove_field =>["userId"]
        remove_field =>["userName"]
        remove_field =>["label"]
        remove_field =>["loginName"]
        remove_field =>["sessionId"]
        remove_field =>["method"]
        remove_field =>["arguments"]
        remove_field =>["stackTrace"]
        remove_field =>["processTime"]
        remove_field =>["status"]
        remove_field =>["createAt"]
        remove_field =>["msgId"]
        remove_field =>["type"]
        add_field => { "[@metadata][type]" => "cdrReports" }
    }
    json {
        source => "cycleMessage"
    }
    mutate {
        remove_field =>["cycleMessage"]
    }
 }     
}

output {
  if [@metadata][operation] == "gateWayLog" {
    #stdout { codec => rubydebug }
    kafka {
      bootstrap_servers => "${kafkaUrl}"
      codec => json
      topic_id => "all_message" #设置topic
      message_key => "%{uuid}"
    }
  }
  if [@metadata][type] == "allMessages" {
   # stdout { codec => rubydebug }
    if [uuid] not in ["","drop"] {
      elasticsearch {
        hosts => ["${esUrl}"]
        user => "${esUser}"
        password => "${esPassword}"
        action => "update"
        index => "all_message"
        document_id => "%{uuid}"
        codec => "json"
        doc_as_upsert => true
      }
    }
   }
 if [@metadata][type] == "cdrReports" {
        if [uuid] not in ["","null"] {
            elasticsearch {
                hosts => ["${esUrl}"]
                user => "${esUser}"
                password => "${esPassword}"
                action => "update"
                index => "all_message"
                document_id => "%{uuid}"
                doc_as_upsert => true
            }
        }
    }
}

```
配置说明：
output步骤要取当前内容的数据：使用`%{}`

logstash本身配置文件在：[[附件/日志/ELK/logstash/README]]目录/config/logstash.yml
```shell
http.host: 0.0.0.0
xpack.monitoring.enabled: true
xpack.monitoring.elasticsearch.hosts: ["http://xxxIp:xxxPort"]
xpack.monitoring.elasticsearch.username: "hiphip"
xpack.monitoring.elasticsearch.password: "888888"
```
配置说明：
1. xpack的监控功能，上传到es，在kibana查看logstash的性能
![[Pasted image 20220120154631.png]]

logstash的日志配置文件在：[[附件/日志/ELK/logstash/README]]目录/config/log4j2.properties
```shell
status = error
name = LogstashPropertiesConfig

appender.console.type = Console
appender.console.name = plain_console
appender.console.layout.type = PatternLayout
appender.console.layout.pattern = [%d{ISO8601}][%-5p][%-25c] %m%n

appender.json_console.type = Console
appender.json_console.name = json_console
appender.json_console.layout.type = JSONLayout
appender.json_console.layout.compact = true
appender.json_console.layout.eventEol = true

rootLogger.level = error
rootLogger.appenderRef.console.ref = ${sys:ls.log.format}_console

#ElasticSearch打印了一堆警告，，先屏蔽掉
#logger.elasticsearchoutput.level = error
```

---

* 构建最终镜像，并启动
脚本文件在：[[附件/日志/ELK/logstash/README]]目录/start.sh
```shell
docker build -t local.harbor.com/library/logstash-custom:6.7.0 .
docker run -d --network host --name logstash-6.7.0 local.harbor.com/library/logstash-custom:6.7.0
```
使用主机网络的原因：
进入logstash容器内部，虽然能ping通es的ip，但还是无法访问，只能采用主机网络

* 关闭脚本
脚本文件在：[[附件/日志/ELK/logstash/README]]目录/shutdown.sh
```shell
docker stop logstash-6.7.0
docker rm logstash-6.7.0
```

# 部署filebeat
* **拉取镜像，并重新打标签（用于上传到本地harbor，如果没有则忽略）**
```shell
docker pull docker.elastic.co/beats/filebeat:6.7.0
docker tag docker.elastic.co/beats/filebeat:6.7.0 local.harbor.com/library/filebeat:6.7.0
```

---

* **编写Dockerfile，构建镜像，启动**

Dockerfile文件在：[[附件/日志/ELK/filebeat/README]]目录/Dockerfile
```shell
FROM local.harbor.com/library/filebeat:6.7.0
WORKDIR /usr/share/filebeat
#RUN mkdir -p file-log

COPY config/filebeat.yml ./filebeat.yml
USER root
RUN chown root:filebeat ./filebeat.yml
USER filebeat
```

脚本文件在：[[附件/日志/ELK/filebeat/README]]目录/start.sh
`docker build -t local.harbor.com/library/filebeat-custom:6.7.0 .`

```shell
docker run -d --network host \
  --name filebeat-6.7.0 \
  --user root \
  -e -strict.perms=false \
  --volume="/home/kong-log:/usr/share/filebeat/file-log" \
  --volume="/home/software/elk/filbeat/data:/usr/share/filebeat/data" \
  local.harbor.com/library/filebeat-custom:6.7.0
```

**配置说明**：
1. 挂载要读取的日志文件
2. 要挂载data目录
因为filebeat需要记录待读取的文件，读到哪了；该数据记录在registry文件中：在[[附件/日志/ELK/filebeat/README]]目录/data/registry。
[为了避免filebeat容器挂了后，新起容器，重新创建registry文件，导致重复收集日志](https://www.jianshu.com/p/c801ec3a64e5)

* **关闭**
脚本文件在：[[附件/日志/ELK/filebeat/README]]目录/shutdown.sh
```shell
docker stop filebeat-6.7.0
docker rm filebeat-6.7.0
```

# 报错处理
1.  **filebeat报错： write tcp 127.0.0.1:37020->127.0.0.1:5044**
```
2022-01-06T02:25:03.578Z        ERROR   pipeline/output.go:121  Failed to publish events: write tcp 127.0.0.1:37020->127.0.0.1:5044: write: connection reset by peer
```

**原因**：filebeat.xml配置的output是192.168.0.34:5044，而logstash的beat这个input插件只配置了port，ip默认为0.0.0.0

**解决：**
filebeat.xml配置的output改成0.0.0.0:5044

2. **logstash.conf中beat组件的filter步骤，[添加临时字段](https://my.oschina.net/iwinder/blog/4907912)，取名为type，无法生效**
**原因**：估计是type为关键词导致的，改成operation即可

# FAQ
1. **使用[[1、docker+kong+日志自动切割和清除#配置Logrotate]]的日志切割后，需要发出通知告知filebeat容器重新打开文件吗**
答案：不需要，
> 关于读取的日志文件，一般会加上自动切割管理（比如将当前文件按天切割，重新命名，然后创建跟当前文件同名的文件）
filebeat很智能，会直接读取新的文件，而不是之前的文件（句柄更新）