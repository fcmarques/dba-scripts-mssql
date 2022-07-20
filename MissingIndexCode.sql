SELECT user_seeks * avg_total_user_cost * ( avg_user_impact * 0.01 ) AS index_advantage, 
       migs.last_user_seek, 
       mid.[statement]                                               AS Database_Schema_Table,
       mid.equality_columns, 
       mid.inequality_columns, 
       mid.included_columns, 
       migs.unique_compiles, 
       migs.user_seeks, 
       migs.avg_total_user_cost, 
       migs.avg_user_impact, 
       RowNumber = IDENTITY(int, 1, 1), 
       'CREATE INDEX IX_' 
       + Replace(Replace(Replace(mid.[statement], '[PRODUCAO].[widl].', ''), '[', ''), ']', '') 
       + '_'                                                         AS Statment 
INTO   #missingindexes 
FROM   sys.dm_db_missing_index_group_stats AS migs WITH (nolock) 
       INNER JOIN sys.dm_db_missing_index_groups AS mig WITH (nolock) 
               ON migs.group_handle = mig.index_group_handle 
       INNER JOIN sys.dm_db_missing_index_details AS mid WITH (nolock) 
               ON mig.index_handle = mid.index_handle 
WHERE  mid.database_id = Db_id() -- Remove this to see for entire instance  
ORDER  BY index_advantage DESC 
OPTION (recompile); 

SELECT rownumber, 
	   index_advantage,
       Database_Schema_Table as [Table],
       statment + CONVERT(VARCHAR, rownumber) + ' ON ' 
       + database_schema_table + '(' 
       + Isnull(equality_columns, inequality_columns) 
       + ') ' 
       + Isnull('INCLUDE (' + included_columns + ');', ';') AS Statment 
FROM   #missingindexes 
WHERE avg_user_impact > 50
ORDER BY 3,2 desc

DROP TABLE #missingindexes 