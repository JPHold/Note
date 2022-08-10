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
ENV kafkaUrl 192.168.0.35:19092,192.168.0.35:29092,192.168.0.35:39092
ENV oracleUrl=jdbc:oracle:thin:@192.168.0.30:1521/cdrdb
ENV oracleUserName RHIN_CDR
ENV oraclePassword qazCdr90#
ENV esUrl=192.168.0.34:9200
ENV esUser=hiphip
ENV esPassword=888888
ENV driverJarPath=/usr/share/logstash/pipeline/jar/ojdbc8-19.7.0.0.jar

ENV TZ=Asia/Shanghai



