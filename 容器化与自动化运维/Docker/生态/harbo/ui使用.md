[TOC]

默认帐号密码：admin、Harbor12345

记得新建用户，权限是developer

# docker集成harbo
**http方式，每次上传镜像，在打tag时，需要写上ip和port，很麻烦**
**https方式，就不用**

## http方式
* 修改http方式的注册地址
`vim /etc/docker/daemon.json`，增加
"insecure-registries": ["192.168.86.148:5050"]

* 登录
`docker login 192.168.86.148:5050`
输入创建的用户和密码即可

* 上传镜像
1. 将某个镜像以下格式，重新打tag
`xxxHarboIp:xxxHarboPort/xxxProject/xxxYourImage`
xxxProject是在harbo管理界面上创建的项目名
![[Pasted image 20210916073903.png]]
`docker tag swarm-publishport-helloworld:latest 192.168.86.148:5050/library/swarm-publishport-helloworld`

`docker push 192.168.86.148:5050/library/swarm-publishport-helloworld`
![[Pasted image 20210916074109.png]]

* 查看上传的镜像
![[Pasted image 20210916074135.png]]

## 拉取镜像
**我们在另一台服务器，拉取镜像**

### pull命令携带ip:port/xxxProject
* 编辑`vim /etc/docker/daemon.json`
因为部署harbo采用http方式，因此要增加`"insecure-registries":["192.168.86.148:5050"]`，不然会报错
![[Pasted image 20210916223222.png]]
 ^7a6ad4

* 重启docker
 `systemctl restart docker`
 
* 拉取
`docker pull 192.168.86.148:5050/library/swarm-publishport-helloworld`
![[Pasted image 20210916224018.png]]

### pull命令只有资源库名称
* 无须配置insecure-registries[[#^7a6ad4]]，配置registry-mirrors即可
`"registry-mirrors": ["http://192.168.86.148:5050"]`

 * 重启docker
 `systemctl restart docker`

* 拉取
`docker pull swarm-publishport-helloworld`
![[Pasted image 20210916224000.png]]
![[Pasted image 20210916224028.png]]


## https方式
* 每次prepare后，登录的公钥和私钥都变了，必须docker-compose down先将容器卸载，再重新docker-compose up -d。不然docker login时会报错：401 Unauthorized
[harbor中login提示401 Unauthorized解决](https://www.developerhome.net/archives/386)

### 关闭harbor
`docker-compose stop`

### 按照官方文档，生成https证书
[配置 HTTPS 访问 Harbor](https://goharbor.io/docs/2.3.0/install-config/configure-https/)

**调用脚本时，传入你想要的域名名称，最好不要harbo.com，会域名冲突，跳转到其它网站**
我自定义的域名是local.harbor.com
`vim makeCert.sh`
./makeCert.sh local.harbor.com
```shell

openssl genrsa -out ca.key 4096

openssl req -x509 -new -nodes -sha512 -days 3650 -subj "/C=CN/ST=Beijing/L=Beijing/O=example/OU=Personal/CN=$1" -key ca.key -out ca.crt

openssl genrsa -out $1.key 4096 


openssl req -sha512 -new -subj "/C=CN/ST=Beijing/L=Beijing/O=example/OU=Personal/CN=$1" -key $1.key -out $1.csr



cat > v3.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1=$1
DNS.2=harbo
DNS.3=hostname
EOF


openssl x509 -req -sha512 -days 3650 -extfile v3.ext -CA ca.crt -CAkey ca.key -CAcreateserial -in $1.csr -out $1.crt


mkdir -p /data/cert/
cp $1.crt /data/cert/
cp $1.key /data/cert/    


openssl x509 -inform PEM -in $1.crt -out $1.cert 


mkdir -p /etc/docker/certs.d/$1/
cp $1.cert /etc/docker/certs.d/$1/
cp $1.key /etc/docker/certs.d/$1/
cp ca.crt /etc/docker/certs.d/$1/
```

### 修改harbor配置
`vim harbor.yml`
![[Pasted image 20210919131515.png]]
```yml
# The IP address or hostname to access admin UI and registry service.
# DO NOT use localhost or 127.0.0.1, because Harbor needs to be accessed by external clients.
hostname: local.harbor.com

# http related config
http:
  # port for http, default is 80. If https enabled, this port will redirect to https port
  port: 80

# https related config
https:
  # https port for harbor, default is 443
  port: 443
  # The path of cert and key files for nginx
  certificate:  /data/cert/local.harbor.com.crt
  private_key: /data/cert/local.harbor.com.key
```
**hostname**：改成上一步定义的域名
**http.port**：https方式时，访问该端口会重定向到https方式的端口
**https.certificate**：上一步安装的证书路径
**https.private_key**：上一步安装的私钥

### 重新初始化harbor
`./prepare`

### 重新安装和启动
`./install.sh`

```
systemctl restart docker
--重新启动harbor
docker-compose stop
docker-compose start
```




## 注意
* 每次重启docker后，harbor也要重新启动后，不然访问不了

* **docker login xxx域名，提示报错：denied: requested access to the resource is denied**
![[Pasted image 20210919125301.png]]
域名不能是带-
https://github.com/goharbor/harbor/issues/2383
![[Pasted image 20210919132300.png]]
如果指定的registry地址无法访问，则会默认推送到docker.io这个registry