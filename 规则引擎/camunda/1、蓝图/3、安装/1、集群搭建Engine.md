[TOC]

# 数据库的隔离级别(影响并发性能)[[Camunda重点]]
## 数据库的事务采用`ANSI/USO SQL`标准：
-   READ UNCOMMITTED
-   READ COMMITTED
-   REPEATABLE READS
-   SERIALIZABLE

* 先了解一下事务问题
1. 脏读
**事务A读取了事务B更新的数据，然后B回滚操作，那么A读取到的数据是脏数据**

2. 不可重复读
**事务 A 多次读取同一数据，事务 B 在事务A多次读取的过程中，对数据作了更新并提交，导致事务A多次读取同一数据时，结果 不一致。**

3. 幻读
**A将表中所有数据修改，B往表插入一条数据；A查询是否修改成功，发现还有一条数据还没修改，就会感觉出了幻觉**

### READ UNCOMMITTED（读未提交）
A修改数据，但未提交事务；
B查询数据，这时查到的是已经修改后的数据；
A回滚事务，取消修改；
B先前拿到的数据，就是脏数据

###  READ COMMITTED（读提交）
只读取提交的数据

### REPEATABLE READS（可重复读）
该级别包含[[#READ COMMITTED（读提交）]]；
涉及到行锁；
额外增加：每次查询的事务，修改和删除事务都要等待查询事务完成，才能操作

### SERIALIZABLE（可串行化）
该级别包含[[#SERIALIZABLE（可串行化）]]；
额外增加：每次查询的事务，新增的数据如果满足查询条件，则新增事务回滚

### 并发性能比较
READ UNCOMMITTED >  READ COMMITTED > REPEATABLE READS > SERIALIZABLE

## 各类数据库的隔离级别
| 数据库    | 支持的隔离级别                                             | 默认隔离级别                      |
| --------- | ---------------------------------------------------------- | --------------------------------- |
| oracle    | [[#READ COMMITTED（读提交）]][[#SERIALIZABLE（可串行化）]] | [[#READ COMMITTED（读提交）]]     |
| sqlserver |                                                            | [[#READ COMMITTED（读提交）]]     |
| mysql     |                                                            | [[#REPEATABLE READS（可重复读）]] |

## Camunba规定必须是[[#READ COMMITTED（读提交）]]
[Camunda对数据库隔离级别的要求](https://docs.camunda.org/manual/latest/user-guide/process-engine/database/database-configuration/#isolation-level-configuration)
![[Pasted image 20210822212436.png]]
使用[[#REPEATABLE READS（可重复读）]]会导致行锁，所以不能采用。
所以mysql要修改隔离级别：`set global transaction isolation level read committed`


# 初始化所需库和表（使用mysql）
## 随项目启动自动创建（推荐）
需要自行创建库[[Camunda重点]]
1. 创建camunda-db库


## 手动安装
1. 创建camunda-db库
2. [Nexus](https://app.camunda.com/nexus/service/rest/repository/browse/camunda-bpm/org/camunda/bpm/distro/camunda-sql-scripts/?__hstc=12929896.43e0e4701f19e79e9adcd7b9106a93f0.1629198964842.1629634763921.1629638918189.14&__hssc=12929896.7.1629638918189&__hsfp=1215052223)，找到对应Engine版本(pom中：artifactId=camunda-bom)
进入到create目录，找到对应数据库类型，执行那些sql即可
![[Pasted image 20210822223018.png]]

# 下载集成Engine的Springboot项目
[github找到对应项目模板](https://github.com/camunda?q=%22camunda-bpm-archetype-%22)
* 我选择的是camunda-bpm-archetype-spring-boot-demo

# 调整配置
```yaml
server.port: 1888  
#集成mysql数据库的配置  
spring.datasource:  
  url: jdbc:mysql://localhost:3306/camunda-db?useSSL=false&useUnicode=true&characterEncoding=utf-8&autoReconnect=true&serverTimezone=Asia/Shanghai  
  #shareable h2 database: jdbc:h2:./camunda-db;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE;AUTO_SERVER=TRUE  
 username: root  
  password: root  
  
camunda.bpm:  
  admin-user:  
    id: admin  
    password: admin  
    firstName: admin  
    lastName: admin  
  filter:  
    create: All Tasks  
  default-serialization-format: application/json  
  
spring.devtools:  
  restart:  
    enabled: false # Do not enable this with ObjectValues as variables!  
  
camunda.bpm.job-execution:  
  #   deployment-aware: true  
 wait-time-in-millis: 5000  
 max-wait: 10000
```

# 启动
* 为了证明集群是否搭建完成，启动了1888和1889这两端口
* 使用Camunda Model打开项目模板自带流程.bpmn，然后发布到1888这个端口
* 分别访问1888和18889驾驶舱首页
    ![[Pasted image 20210822224418.png]]
	![[Pasted image 20210822224346.png]]
	
# 外部任务启动
* 同个任务部署到不同节点
发现永远一个节点接收请求，其它节点都没接收。

* 同个任务部署多个实例到同个节点
会随机进入不同实例

负载的支持并不是很好[[Camunda重点]]