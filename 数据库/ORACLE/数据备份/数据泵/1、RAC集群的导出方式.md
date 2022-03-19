[TOC]
**因为是rac集群，会有个节点，如果使用service_name，那么导出时会随机保存到某个节点上：/oracle/app/19.3.0/grid/bin/expdp xxxUser/xxPassword@xxxServiceName，而这个serviceName对应的是scan_ip，配置的映射在：/oracle/app/19.3.0/grid/network/admin/tnsnames.ora**
![[Pasted image 20211119104029.png]]

** 如果要固定保存到某个节点，则使用ip：/oracle/app/19.3.0/grid/bin/expdp xxxUser/xxPassword@192.168.5.85/cdrdb**[[注意点]]


1. 创建导出目录并授予权限
`create or replace directory dump_dir as '/home/oracle-backup';`
`grant read,write on directory dump_dir to RHIN_CDR;`
`select * from dba_directories;`

2. 在oracle服务器为导出目录赋予写权限
`chmod 777 /home/oracle-backup`

3. oracle服务器需设置环境变量
export ORACLE_HOME=/oracle/app/19.3.0/grid
export ORACLE_SID=cdrdb

4. 导出
--进入oracle命令目录
cd /oracle/app/19.3.0/grid/bin

--得注意tns有配置cdrdb这个实例的连接配置（没有该文件则创建）（CDRDB就是我们的连接实例）（请讲HOST、PORT、SERVICE_NAME改成自己的）
/oracle/app/19.3.0/grid/network/admin
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