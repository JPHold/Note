[TOC]

支持overlay和overlay2这两种存储驱动程序

# 前提条件
overlay2需要内核4.0及以上

xfs文件系统上，设置d_type=true(**通过设置ftype为1**)，才会采用overlay和overlay2。

# 如何指定
1. 关掉docker
2. 备份/var/lib/docker
3. 如果不想要用/var/lib所在的文件系统，想使用其他文件系统，则需格式化原先的，并将新的文件系统mount到/var/lib/docker，还要**添加到/etc/fstab**
4. 修改/etc/docker/daemon.json
```json
{
	"storage-driver": "overlay2"
}	
```
5. 重新启动docker
6. docker info查看是否修改成功
只要关注`Storage Driver`和 `Backing filesystem`这两个属性即可

# overlay2工作原理

# overlay工作原理