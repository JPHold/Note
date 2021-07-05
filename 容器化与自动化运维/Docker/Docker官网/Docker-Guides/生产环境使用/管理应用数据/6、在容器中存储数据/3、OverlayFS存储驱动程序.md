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
* 先看下目录结构
1. l目录是存放每一层的简短标识，对应到每层目录的软连接
2. 最低层目录有这些子目录/文件：diff/、link
diff是当前层的内容；
link是文本，存放着l目录里的简短表标识
3. 每个上层，除了diff、link，还有这些子目录/文件：lower/、merged/、work/
lower是父层的内容
merged是合并lower和diff后的内容
work是内部使用的目录

# overlay工作原理