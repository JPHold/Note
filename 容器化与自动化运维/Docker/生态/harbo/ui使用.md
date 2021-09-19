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
* 每次prepare后，登录的公钥和私钥都变了，必须docker-compose down先将容器卸载，再重新docker-compose up。不然docker login时会报错：401 Unauthorized
[harbor中login提示401 Unauthorized解决](https://www.developerhome.net/archives/386)

* 按照官方文档，生成https证书
[配置 HTTPS 访问 Harbor](https://goharbor.io/docs/2.3.0/install-config/configure-https/)

**将local-harbo改成你想要的域名名称，最好不要harbo.com，会冲突，跳转到其它网站**
```shell

--
openssl genrsa -out ca.key 4096


--
openssl req -x509 -new -nodes -sha512 -days 3650 \
 -subj "/C=CN/ST=Beijing/L=Beijing/O=example/OU=Personal/CN=local-harbo" \
 -key ca.key \
 -out ca.crt

--
openssl genrsa -out local-harbo.key 4096 

--
openssl req -sha512 -new \
    -subj "/C=CN/ST=Beijing/L=Beijing/O=example/OU=Personal/CN=local-harbo" \
    -key local-harbo.key \
    -out local-harbo.csr


--
cat > v3.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1=local-harbo
DNS.2=harbo
DNS.3=hostname
EOF

--
openssl x509 -req -sha512 -days 3650 \
    -extfile v3.ext \
    -CA ca.crt -CAkey ca.key -CAcreateserial \
    -in local-harbo.csr \
    -out local-harbo.crt

-- 
 cp local-harbo.crt /data/cert/
 cp local-harbo.key /data/cert/    


--
openssl x509 -inform PEM -in local-harbo.crt -out local-harbo.cert 


这一步是为了docker登录到远程资源库的https证书凭证
--
mkdir -p /etc/docker/certs.d/local-harbo/

cp local-harbo.cert /etc/docker/certs.d/local-harbo/
cp local-harbo.key /etc/docker/certs.d/local-harbo/
cp ca.crt /etc/docker/certs.d/local-harbo/
```

**