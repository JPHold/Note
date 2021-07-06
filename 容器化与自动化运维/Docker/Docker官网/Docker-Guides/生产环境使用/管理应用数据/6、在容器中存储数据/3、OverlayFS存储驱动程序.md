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

# 驱动程序如何读取/写入文件/目录
今天科普lowedir和upperdir
前者是镜像层，后者是容器层

## 读取
### 镜像层存在，容器层不存在
读取镜像层，性能依旧强悍

### 镜像层不存在，容器层存在
直接读取容器层
    
### 镜像层和容器层都存在该文件
因同名会覆盖，所以直接读取容器层


 ## 修改文件/目录
### 写入文件
* 第一次该文件不存在于uperdir，则向下查找lowerdir，找到则复制到uperdir，后续的操作都在这个副本上操作。(因为是文件级操作，所以即使只是修改某一小部分，也是整个文件复制)。
 * overlayfs只有两层，因此查找性能比aufs好；而overlayfs2有多层，因此比overlayfs性能差，但他支持缓存，所以其实还好

### 修改名字
必须整个文件路径上的目录和文件，都在upperdir(也就是必须是容器层的文件，而不是镜像层的文件)，不然会报错EXDEV 错误(不允许跨设备链接的错误)

### 删除
文件和目录的处理是不一样的

#### 文件
会创建without文件，防止要删除的文件被访问

#### 目录
会创建opaque目录，防止要删除的目录被访问

# OverlayFS 和 Docker 性能
overlay和overlay2，比aufs和devicemapper性能都要好，甚至比btrfs好。只要体现如下
    1. 缓存
访问同个文件的不同容器，共享同个页面的缓存页，
    2. 写时复制
虽然大文件性能不太行，但只是第一次复制时才这样，后续就很快的，都是在容器层操作
    3. 搜索层数(写时复制的相关)
overlay比aufs少层，搜索快。而overlay2虽然层数多，但有缓存结果啊，搜索性能也还可以
    4. inode限制
overlay因为只有两层，所以共享的镜像层不是很多，所以在拥有很多镜像和容器，会冗余很多相同的层；进而导致创建更多的inode，而inode的增加后，想修复，只能格式化文件系统，所以建议使用overlay2

## 性能再次提升的实践
1. 使用ssd而非机械硬盘
2. 使用volume，而非存储驱动程序来操作文件，支持频繁负载操作、容器间共享，持久化存储

# OverlayFS的兼容性
与其他文件系统的不兼容，体现如下两个方面
* 打开文件，指向的引用不一样
两个操作，一个以只读方式打开文件、一个以可写方式打开文件
```
fd1=open("foo", O_RDONLY)
fd2=open("foo", O_RDWR)
```
前面的知识可知：写入文件，会从镜像层拷贝一个副本到容器层；而读we