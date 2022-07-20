CREATE TABLE #temp (
       table_name sysname ,
       row_count bigint,
       reserved_size varchar(50),
       data_size varchar(50),
       index_size varchar(50),
       unused_size varchar(50))
SET NOCOUNT ON
INSERT     #temp
EXEC       sp_MSforeachtable 'sp_spaceused ''?'''
SELECT     a.table_name,
           a.row_count,
           count(*) as col_count,
           CAST(Replace(a.index_size, ' KB', '') as bigint) / 1024 as 'index_size (MB)',
           CAST(Replace(a.data_size, ' KB', '') as bigint) / 1024 as 'data_size (MB)',
           (CAST(Replace(a.index_size, ' KB', '') as bigint) / 1024 + CAST(Replace(a.data_size, ' KB', '') as bigint) / 1024) as 'total_size (MB)'
FROM       #temp a
INNER JOIN INFORMATION_SCHEMA.COLUMNS b
           ON a.table_name collate database_default
                = b.table_name collate database_default
GROUP BY   a.table_name, a.row_count, a.data_size, a.index_size
--ORDER BY   CAST(Replace(a.data_size, ' KB', '') as bigint) desc
--ORDER BY   CAST(Replace(a.index_size, ' KB', '') as integer) desc
--ORDER BY  a.table_name
ORDER BY 6 DESC
DROP TABLE #temp


