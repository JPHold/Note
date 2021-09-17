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