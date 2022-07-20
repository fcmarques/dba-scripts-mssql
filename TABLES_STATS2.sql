CREATE TABLE #temp 
  ( 
     table_name    SYSNAME, 
     row_count     INT, 
     reserved_size VARCHAR(50), 
     data_size     VARCHAR(50), 
     index_size    VARCHAR(50), 
     unused_size   VARCHAR(50) 
  ) 

SET nocount ON 

INSERT #temp 
EXEC Sp_msforeachtable 'sp_spaceused ''?''' 

SELECT a.table_name, 
       a.row_count, 
       Count(*)                                                 AS col_count, 
       Cast(Replace(a.index_size, ' KB', '') AS INTEGER) / 1024 AS 'index_size (MB)', 
       Cast(Replace(a.data_size, ' KB', '') AS INTEGER) / 1024  AS 'data_size (MB)', 
       ts.reads, 
       ts.writes 
FROM   #temp a 
       INNER JOIN information_schema.columns b 
               ON a.table_name COLLATE database_default = 
                  b.table_name COLLATE database_default 
       JOIN (SELECT TableName = Object_name(s.object_id), 
                    Sum(user_seeks + user_scans + user_lookups) AS reads, 
                    Sum(user_updates)                           AS writes 
             FROM   sys.dm_db_index_usage_stats AS s 
                    LEFT JOIN sys.indexes AS i 
                           ON s.object_id = i.object_id 
                              AND i.index_id = s.index_id 
             WHERE  Objectproperty(s.object_id, 'IsUserTable') = 1 
             --AND s.database_id = @dbid 
             GROUP  BY Object_name(s.object_id)) ts 
         ON a.table_name = ts.tablename 
GROUP  BY a.table_name, 
          a.row_count, 
          a.data_size, 
          a.index_size, 
          ts.reads, 
          ts.writes 
--ORDER BY   CAST(Replace(a.data_size, ' KB', '') as integer) desc 
--ORDER BY   CAST(Replace(a.index_size, ' KB', '') as integer) desc 
ORDER  BY a.table_name 

DROP TABLE #temp 