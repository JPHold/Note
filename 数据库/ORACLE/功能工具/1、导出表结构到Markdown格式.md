[TOC]

# 特性
1. 支持导出某个namespace的所有表
2. 支持导出某些表

# sql
使用plsql执行，在弹出框填写参数即可。

```sql
   
select 
  (t.OWNER || '.' || t.TABLE_NAME || '(' || t.TABLE_COMMENT ||')') || chr(13) as "fullTableName",
  ('| 代码 | 名称 | 数据类型 | 强制 | 主要的 | 注释 |')
  || chr(13) 
  || ( '| ------------ | ------------ | ------------ | ------------ | ------------ | ------------ |') 
  || chr(13) 
  || xmlagg(xmlparse(content t."all"|| '' wellformed) order by t.COLUMN_ID asc ).getclobval()
  || chr(13)
from (
      select 
             '# ' || col.OWNER as "OWNER", col.TABLE_NAME, (select tc.COMMENTS from all_tab_comments tc where tc.OWNER = col.OWNER and tc.TABLE_NAME = col.TABLE_NAME) as "TABLE_COMMENT"
              ,col.COLUMN_ID
              ,(
                 '|' || col.COLUMN_NAME
                 || '|' || comm.COMMENTS
                 || '|' || (case col.DATA_TYPE when 'DATE' then col.DATA_TYPE else col.DATA_TYPE || '(' || col.DATA_LENGTH || ')' end)
                 || '|' || (case col.NULLABLE when 'N' then 'TRUE' else 'FALSE' end )
                 || '|' || nvl2(( select a.COLUMN_NAME from user_cons_columns a where a.CONSTRAINT_NAME=(select c.CONSTRAINT_NAME from all_constraints c where c.OWNER = col.OWNER  and c.TABLE_NAME=col.TABLE_NAME and c.CONSTRAINT_TYPE='P') and a.COLUMN_NAME = col.COLUMN_NAME),'TRUE','FALSE')   
                 || '| |' 
               )|| chr(13) as "all"
       from all_tab_columns col, all_col_comments comm
       where col.OWNER = comm.OWNER
         and col.TABLE_NAME = comm.TABLE_NAME
         and col.COLUMN_NAME = comm.COLUMN_NAME
         and col.OWNER='&owner'
         and col.TABLE_NAME in(&tableNames)
         order by col.TABLE_NAME asc
)t group by t.OWNER,t.TABLE_NAME,t.TABLE_COMMENT;
   
```

# 导出结果到excle
使用plsql导出

# 格式化结果
1. 打开excle
2. 复制内容到sublime
3. `ctrl+h`全局替换`"\s*`为空

# 使用Obsidian编辑
1. 复制[[#格式化结果]]]到编辑框
2. 导出pdf