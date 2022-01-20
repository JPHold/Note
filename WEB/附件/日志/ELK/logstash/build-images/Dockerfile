FROM local.harbor.com/library/logstash:6.7.0
WORKDIR /usr/share/logstash

#在线安装插件
RUN ./bin/logstash-plugin install logstash-output-jdbc

