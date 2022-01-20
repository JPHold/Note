[TOC]

> 以kong记录请求日志，filebeat扫描日志并推送给logstash，logstash监听并异构格式，上传到es

# 部署logstash
* 拉取镜像，并重新打标签（用于上传到本地harbor，如果没有则忽略）
`docker pull docker.elastic.co/beats/filebeat:6.7.0`
`docker tag docker.elastic.co/beats/filebeat:6.7.0 local.harbor.com/library/filebeat:6.7.0`

* 编写Dockerfile，自定义logstash配置、将所需依赖打包进去
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
> 

# 部署filebeat