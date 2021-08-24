[TOC]

# 前期准备
## 打包项目时，会发现少了很多特定版本的jar
[Not able to compile the whole pentaho-kettle project in my local system](https://github.com/HiromuHota/pentaho-kettle/issues/130)

最终发现这个issue，描述的是必须先构建这些项目
[Not able to compile the whole pentaho-kettle project in my local system](https://github.com/HiromuHota/pentaho-kettle/issues/130)
改成特定分支即可。我当前的kettle版本是9.0；rap版本是3.12.0
![[Pasted image 20210824151211.png]]

### 缺失快照版本
* org.eclipse.rap.rwt:3.12.0-SNAPSHOT
* org.eclipse.rap.jface:3.12.0-SNAPSHOT
* org.eclipse.rap.fileupload:3.12.0-SNAPSHOT
* org.eclipse.rap.filedialog:3.12.0-SNAPSHOT
* org.eclipse.rap.rwt.testfixture:3.12.0-SNAPSHOT
[解决办法](https://github.com/HiromuHota/pentaho-kettle/issues/153)
![[Pasted image 20210824150635.png]]
![[Pasted image 20210824150712.png]]
(https://github.com/HiromuHota/pentaho-kettle/pull/64)

git clone这个项目
![[Pasted image 20210824150815.png]]
进入该项目，打开命令窗口执行`maven clean`
![[Pasted image 20210824150735.png]]


* pentaho-vfs-browser:9.0.0.0-423-22
* commons-xul-swt:9.0.0.0-423-22

