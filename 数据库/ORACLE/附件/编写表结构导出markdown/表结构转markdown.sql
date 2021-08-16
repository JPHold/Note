   
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
         and col.OWNER='RHIN_CDR'
         --and col.TABLE_NAME in('T_CDR_SYSTEM_THD','T_DC_DIC_SYSTEM')
         order by col.TABLE_NAME asc
)t group by t.OWNER,t.TABLE_NAME,t.TABLE_COMMENT;
   