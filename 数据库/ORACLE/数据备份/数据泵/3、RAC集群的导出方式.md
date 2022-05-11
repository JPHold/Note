[TOC]

> 在[[1、非集群的导出方式]]的基础上，做一些调整


* **因为是rac集群，所以会有多个节点**，如果只使用service_name：：`/oracle/app/19.3.0/grid/bin/expdp xxxUser/xxPassword@xxxServiceName`，那么导出时会随机保存到某个节点上，而这个serviceName对应的是scan_ip，配置的映射在：`/oracle/app/19.3.0/grid/network/admin/tnsnames.ora`
![[Pasted image 20211119104029.png]]

* ** 如果要固定保存到某个节点，则指定某个节点：`/oracle/app/19.3.0/grid/bin/expdp xxxUser/xxPassword@192.168.5.85/cdrdb`**  [[ORACLE/注意/注意点]]