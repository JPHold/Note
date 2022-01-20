FROM local.harbor.com/library/filebeat:6.7.0
WORKDIR /usr/share/filebeat
#RUN mkdir -p file-log

COPY config/filebeat.yml ./filebeat.yml
USER root
RUN chown root:filebeat ./filebeat.yml
USER filebeat
