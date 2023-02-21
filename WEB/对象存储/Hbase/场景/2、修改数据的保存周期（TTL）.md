1. 进入脚本空间
	`./hbase shell`

 2. 列出表清单
	 list
![[Pasted image 20230103094749.png]]

3. 查看表定义
	` desc 'objectStorage'`
![[Pasted image 20230103095022.png]]
NAME => 'metadata'，下面会用到

4. 修改
	`alter_async 'objectStorage',{NAME => 'metadata',TTL => '31536000'}`
	`alter_async 'objectStorage',{NAME => 'object',TTL => '31536000'}`