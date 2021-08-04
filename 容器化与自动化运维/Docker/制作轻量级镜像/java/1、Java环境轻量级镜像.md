[TOC]

总共尝试三种方式
* 使用现成
* 使用alpine+glibc+jre自定义制作
* 使用alpine-glibc+jre自定义制作

# 使用现成
[frolvlad/alpine-java](https://hub.docker.com/r/frolvlad/alpine-java)
选择：`docker pull frolvlad/alpine-java:jre8.202.08-slim`

# 使用alpine+glibc+jre自定义制作
[参考这个](https://blog.csdn.net/weixin_42687829/article/details/104234334)
[jre依赖glibc](https://www.cnblogs.com/klvchen/p/11015267.html)
[安装glibc](https://github.com/sgerrand/alpine-pkg-glibc)

1. 下载jre
![[Pasted image 20210804155207.png]]

2. 删除jre没用的文件和目录 ^80e4e4
```
rm -rf COPYRIGHT LICENSE README release THIRDPARTYLICENSEREADME-JAVAFX.txt THIRDPARTYLICENSEREADME.txt Welcome.html 
```
```
rm -rf lib/plugin.jar \
lib/ext/jfxrt.jar \
bin/javaws \
lib/javaws.jar \
lib/desktop \
plugin \
lib/deploy* \
lib/*javafx* \
lib/*jfx* \
lib/amd64/libdecora_sse.so \
lib/amd64/libprism_*.so \
lib/amd64/libfxplugins.so \
lib/amd64/libglass.so \
lib/amd64/libgstreamer-lite.so \
lib/amd64/libjavafx*.so \
lib/amd64/libjfx*.so
```

2. 重新打包 ^2d50cb
```linux
cd jre1.8.0_301/
tar -cf jre1.8.0_301.tar.gz bin/ lib/ man/
```

**在构建这个方式的镜像比[[#使用现成]]的镜像大，对比后，发现未删干净，继续删除** ^15e333
1. legal目录
`rm -rf legal`

2. bin目录还有一些文件、目录可删除
现成镜像
![[Pasted image 20210804130223.png]]
自定义镜像
![[Pasted image 20210804130238.png]]
```
rm -f bin/jjs \
rm -f bin/keytool \
rm -f bin/orbd \
rm -f bin/pack200 \
rm -f bin/policytool \
rm -f bin/rmid \
rm -f bin/rmiregistry \
rm -f bin/servertool \
rm -f bin/tnameserv \
rm -f bin/unpack200 
```

3. lib/jfr和lib/jfr.jar
用于分析代码的性能
`rm -rf lib/jfr lib/jfr.jar`

4. lib/oblique-fonts
样式
 `rm -rf lib/oblique-fonts`

2. 编写Dockerfile
```Dockerfile
FROM alpine:latest
WORKDIR /usr/local/jre

ADD jre1.8.0_301.tar.gz .

COPY sgerrand.rsa.pub .
COPY glibc-2.33-r0.apk .
COPY glibc-bin-2.33-r0.apk .
COPY glibc-i18n-2.33-r0.apk .

ENV JAVA_HOME=/usr/local/jre
ENV PATH=$JAVA_HOME/bin:$PATH

RUN echo http://mirrors.aliyun.com/alpine/v3.10/main/ > /etc/apk/repositories \
    && echo http://mirrors.aliyun.com/alpine/v3.10/community/ >> /etc/apk/repositories  \
    && apk update && apk upgrade   \
    && apk --no-cache add ca-certificates  \
    && apk add --allow-untrusted glibc-2.33-r0.apk glibc-bin-2.33-r0.apk glibc-i18n-2.33-r0.apk \
    && rm -rf /var/cache/apk/* glibc-2.31-r0.apk glibc-bin-2.31-r0.apk glibc-i18n-2.31-r0.apk
```

3. 打镜像
`docker build -t alpine-glibc-jre:8.0_301 -f Dockerfile .`

```linux
Sending build context to Docker daemon  343.1MB
Step 1/11 : FROM alpine:latest
 ---> d4ff818577bc
Step 2/11 : WORKDIR /usr/local/jre
 ---> Using cache
 ---> b2ee0969ac01
Step 3/11 : ADD jre1.8.0_301.tar.gz .
 ---> 43d5dc6971c8
Step 4/11 : COPY sgerrand.rsa.pub .
 ---> 327e64c00e22
Step 5/11 : COPY glibc-2.33-r0.apk .
 ---> 218b84cc6974
Step 6/11 : COPY glibc-bin-2.33-r0.apk .
 ---> fbb5aba32876
Step 7/11 : COPY glibc-i18n-2.33-r0.apk .
 ---> b3244ecc2186
Step 8/11 : ENV JAVA_HOME=/usr/local/jre
 ---> Running in f113ceeb4f93
Removing intermediate container f113ceeb4f93
 ---> 8cbbaaf7374f
Step 9/11 : ENV PATH=$JAVA_HOME/bin:$PATH
 ---> Running in e5797fec6fa2
Removing intermediate container e5797fec6fa2
 ---> ccac2158ea4b
Step 10/11 : RUN echo http://mirrors.aliyun.com/alpine/v3.10/main/ > /etc/apk/repositories     && echo http://mirrors.aliyun.com/alpine/v3.10/community/ >> /etc/apk/repositories      && apk update && apk upgrade       && apk --no-cache add ca-certificates      && apk add --allow-untrusted glibc-2.33-r0.apk glibc-bin-2.33-r0.apk glibc-i18n-2.33-r0.apk     && rm -rf /var/cache/apk/* glibc-2.31-r0.apk glibc-bin-2.31-r0.apk glibc-i18n-2.31-r0.apk
 ---> Running in 5f9001f35814
fetch http://mirrors.aliyun.com/alpine/v3.10/main/x86_64/APKINDEX.tar.gz
fetch http://mirrors.aliyun.com/alpine/v3.10/community/x86_64/APKINDEX.tar.gz
v3.10.9-41-g4102bc5821 [http://mirrors.aliyun.com/alpine/v3.10/main/]
v3.10.6-10-ged79a86de3 [http://mirrors.aliyun.com/alpine/v3.10/community/]
OK: 10357 distinct packages available
OK: 6 MiB in 14 packages
fetch http://mirrors.aliyun.com/alpine/v3.10/main/x86_64/APKINDEX.tar.gz
fetch http://mirrors.aliyun.com/alpine/v3.10/community/x86_64/APKINDEX.tar.gz
(1/1) Installing ca-certificates (20191127-r2)
Executing busybox-1.33.1-r2.trigger
Executing ca-certificates-20191127-r2.trigger
OK: 6 MiB in 15 packages
(1/4) Installing glibc (2.33-r0)
(2/4) Installing libgcc (8.3.0-r0)
(3/4) Installing glibc-bin (2.33-r0)
(4/4) Installing glibc-i18n (2.33-r0)
Executing glibc-bin-2.33-r0.trigger
/usr/glibc-compat/sbin/ldconfig: /usr/glibc-compat/lib/ld-linux-x86-64.so.2 is not a symbolic link

OK: 44 MiB in 19 packages
Removing intermediate container 5f9001f35814
 ---> 9550a94848a1
Step 11/11 : CMD ["java","-version"]
 ---> Running in 481645476ce8
Removing intermediate container 481645476ce8
 ---> b9326b35cf64
Successfully built b9326b35cf64
Successfully tagged alpine-glibc-jre:8.0_301

```

# 使用alpine-glibc+jre自定义制作
[参考这个](https://wuyeliang.blog.csdn.net/article/details/99455104)
1. 删除jre没用的文件和目录[[#^80e4e4]][[#^15e333]][[#^2d50cb]]
2. 编写Dockerfile
```Dockerfile
FROM frolvlad/alpine-glibc

WORKDIR /usr/local/jre

ADD jre1.8.0_301.tar.gz .

ENV JAVA_HOME=/usr/local/jre
ENV PATH=$JAVA_HOME/bin:$PATH
```
3. 打镜像
`docker build -t alpineglibc-jre:8.0_301 -f Dockerfile .`
```
Sending build context to Docker daemon  343.1MB
Step 1/6 : FROM frolvlad/alpine-glibc
 ---> 88bf31db0e54
Step 2/6 : WORKDIR /usr/local/jre
 ---> Running in 5d053b5f43f8
Removing intermediate container 5d053b5f43f8
 ---> 2654e0094467
Step 3/6 : ADD jre1.8.0_301.tar.gz .
 ---> fa3a6536ba72
Step 4/6 : ENV JAVA_HOME=/usr/local/jre
 ---> Running in 82c0e1986c1c
Removing intermediate container 82c0e1986c1c
 ---> 777749c15e87
Step 5/6 : ENV PATH=$JAVA_HOME/bin:$PATH
 ---> Running in 7548474a882b
Removing intermediate container 7548474a882b
 ---> 12153c800d0c
Step 6/6 : CMD ["java","-version"]
 ---> Running in 4fbdb815e2bf
Removing intermediate container 4fbdb815e2bf
 ---> d8a7f2923054
Successfully built d8a7f2923054
Successfully tagged alpineglibc-jre:8.0_301
```

# 对比镜像大小
![[Pasted image 20210804154351.png]]
最佳的是[[#使用现成]]
最差的是[[#使用alpine glibc jre自定义制作]]

**建议：**
1. 如果不放心别人的镜像，那就使用[[#使用alpine-glibc jre自定义制作]]
2. 放心别人的镜像，那就使用[[#使用现成]]，毕竟大小是最小的