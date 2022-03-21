[TOC]
**因为是rac集群，会有个节点，如果使用service_name，那么导出时会随机保存到某个节点上：/oracle/app/19.3.0/grid/bin/expdp xxxUser/xxPassword@xxxServiceName，而这个serviceName对应的是scan_ip，配置的映射在：/oracle/app/19.3.0/grid/network/admin/tnsnames.ora**
![[Pasted image 20211119104029.png]]

** 如果要固定保存到某个节点，则使用ip：/oracle/app/19.3.0/grid/bin/expdp xxxUser/xxPassword@192.168.5.85/cdrdb**[[注意点]]


# 创建导出目录并授予权限
`create or replace directory dump_dir as '/home/oracle-backup';`
`grant read,write on directory dump_dir to RHIN_CDR;`
`select * from dba_directories;`

# 在oracle服务器为导出目录赋予写权限
`chmod 777 /home/oracle-backup`

# 设置oracle相关环境变量
> 设置oracle安装目录和实例名
export ORACLE_HOME=/oracle/app/19.3.0/grid
export ORACLE_SID=cdrdb

# 配置连接实例
路径：`/oracle/app/19.3.0/grid/network/admin/tnsnames.ora`
> （没有该文件则创建）
> CDRDB就是我们的连接实例，请将HOST、PORT、SERVICE_NAME改成自己的

```
CDR =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.5.90)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = cdr)
    )
  )

CDRDB =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.5.90)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = cdrdb)
    )
  )
```

# 导出脚本
> 执行目录是 `/oracle/app/19.3.0/grid/bin`，命令是expdp
```
#!/bin/sh
#set -e

# 两天前的日期
firstBackUpFileName=`date -d "2 day ago" +%Y-%m-%d`
# 当天的日期
currBackUpFileName=`date +%Y-%m-%d`
# 需要导出的命名空间列表
#namespaces=(RHIN_CDR CDR_EMPI CDR_ACCESS RHIN_CDR_INDEX)
namespaces=(RHIN_CDR_INDEX)
# 导出的目录
dumpDir=/home/oracle-backup

echo "开始备份oracle"
export ORACLE_HOME=/oracle/app/19.3.0/grid
export ORACLE_SID=cdrdb
# 解决控制台打印日志，中文乱码
export NLS_LANG=AMERICAN_AMERICA.UTF8

cd ${dumpDir}

for ns in ${namespaces[*]}
do
 echo "---开始删除${ns}命名空间两天前的备份文件"
 rm -f ${ns}-${firstBackUpFileName}.*
 echo -e "---结束删除${ns}命名空间两天前的备份文件\n"

 echo "---开始备份${ns}命名空间,日期：${currBackUpFileName}"
 /oracle/app/19.3.0/grid/bin/expdp ${ns}/qazCdr90#@cdrdb directory=dump_dir owner=${ns}  dumpfile=${ns}-${currBackUpFileName}.dmp    logfile=${ns}-${currBackUpFileName}.log  content=ALL
 echo -e "---结束备份${ns}命名空间\n"

done

echo "结束备份oracle"
```
| 参数        | 描述                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | 实践 |
| ----------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---- |
| compression | 是否压缩。**ALL ：对导出的元数据和表数据都进行压缩**，得到的导出文件是最小的，耗时也是最长的。**DATA_ONLY ：仅对表数据进行压缩**，对于大数据量的导出效果明显，会比METADATA_ONLY方式得到更小的压缩文件。**METADATA_ONLY ：仅对元数据进行压缩**，而不会对表数据进行压缩，这种压缩执行后效果一般不是很明显，不过速度比较快。**NONE ：不进行任何的压缩**，导出后的文件也是最大的。  **DEFAULT ：默认方式，即不指定COMPRESSION参数**，会采用默认的压缩方式METADATA_ONLY。 | 压缩前dmp文件是60g，压缩后是12g，压缩比是80%     |