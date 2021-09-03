[TOC]

# 多个Compose文件覆盖
* **通过-f指定多个Compose文件，并且以第一个-f指定的Compose文件为基础文件（记作a），后面-f指定的Compose文件的路径都相对于a**[[Docker重点]]
* 为何需要基础文件
	因为覆盖Compose文件的内容，可以是不标准的Compose结构，可以是某个配置片段

## demo


# 继承Compose