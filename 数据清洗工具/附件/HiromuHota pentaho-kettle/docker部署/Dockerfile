FROM hiromuhota/webspoon:latest
COPY lib/*.jar /usr/local/tomcat/lib/
COPY simple-jndi/jdbc.properties /usr/local/tomcat/simple-jndi/
RUN mkdir /home/tomcat/data \
&& chmod 666 /home/tomcat/data
