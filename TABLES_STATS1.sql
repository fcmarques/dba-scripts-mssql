DECLARE @dbid int
SELECT @dbid = db_id('Corporate1')

SELECT TableName = object_name(s.object_id),
       SUM(user_seeks + user_scans + user_lookups) as reds, SUM(user_updates) as writes
FROM sys.dm_db_index_usage_stats AS s
left JOIN sys.indexes AS i
ON s.object_id = i.object_id
AND i.index_id = s.index_id
WHERE objectproperty(s.object_id,'IsUserTable') = 1
--AND s.database_id = @dbid
GROUP BY object_name(s.object_id)
ORDER BY TableName