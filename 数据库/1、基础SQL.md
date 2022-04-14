[TOC]

# 分页
* **oracle**

* sqlserver
```sql
select * from (
select t.* ROW_NUMBER() OVER(Order by xxx排序字段 ) AS RowId  from xxx (nolock) t 
　　) as b where RowId between 1 and 10
