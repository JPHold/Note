[TOC]

> 以kong记录请求日志，filebeat扫描日志并推送给logstash，logstash监听并异构格式，上传到es
> 所有的配置都在[[README]]

# 部署logstash
* **拉取镜像，并重新打标签（用于上传到本地harbor，如果没有则忽略）**
`docker pull docker.elastic.co/beats/filebeat:6.7.0`
`docker tag docker.elastic.co/beats/filebeat:6.7.0 local.harbor.com/library/filebeat:6.7.0`
---

* **安装插件，并制作新镜像（以后要安装新插件，都修改这个Dockerfile）**

Dockerfile文件在：[[README]]目录/build-images/Dockerfile
```shell
FROM local.harbor.com/library/logstash:6.7.0
WORKDIR /usr/share/logstash

#在线安装插件
RUN ./bin/logstash-plugin install logstash-output-jdbc
```

制作镜像脚本在：[[README]]目录/build-images/build.sh
`docker build -t local.harbor.com/library/logstash-with-plugin:6.7.0 .`

---

* 编写Dockerfile，自定义logstash配置、将所需依赖打包进去

Dockerfile文件在：[[README]]目录/Dockerfile
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


logstash处理程序配置文件在：[[README]]目录/config/logstash.conf
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

Dockerfile文件在：[[README]]目录/config/logstash.yml
```shell
http.host: 0.0.0.0
xpack.monitoring.enabled: true
xpack.monitoring.elasticsearch.hosts: ["http://xxxIp:xxxPort"]
xpack.monitoring.elasticsearch.username: "hiphip"
xpack.monitoring.elasticsearch.password: "888888"
```
配置说明：
1. xpack的监控功能，上传吧da监控logstash的性能
![[Pasted image 20220120154631.png]]

---

# 部署filebeat