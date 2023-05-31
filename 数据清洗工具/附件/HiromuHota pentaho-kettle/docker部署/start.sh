docker run -it -d -p 16680:8080 --name webspoon -v /home/software/kettle/save:/home/tomcat/data --cpus=1.5 --memory=10240m --log-opt max-size=5g --log-opt max-file=1 -e "TZ=Asia/Shanghai" -e "JAVA_OPTS=-Dfile.encoding=UTF-8 -Xms1024m -Xmx10240m" webspoon:latest

