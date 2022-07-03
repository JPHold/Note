[TOC]

# 分页
* **oracle**

* **sqlserver**
```sql
select * from (
select t.* ROW_NUMBER() OVER(Order by xxx排序字段 ) AS RowId  from xxx (nolock) t 
　　) as b where RowId between 1 and 10
```

# 时间戳转日期
* **oracle**
`select 1650346277060/ (1000 * 60 * 60 * 24) + TO_DATE ('1970-01-01 08:00:00','YYYY-MM-DD hh24:MI:SS')`

* **sqlserver**
`select (1650346277060)/(1000*60*60*24)+ cast ('1970-01-01 07:59:59.944' as datetime)`

网上的资料是'1970-01-01 08:00:00'，但发现上述结果会大一些
![[Pasted image 20220420160621.png]]

**当你第一次做时间范围查找时，会漏了000到057之间的数据**

**所以减一点，比当前时间少个几十毫秒，冗余一部分数据**
![[Pasted image 20220420160739.png]]
