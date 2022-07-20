use AUTCOM
go
SELECT OBJECT_NAME(SI.object_id),SI.name,* 
FROM sys.dm_db_index_usage_stats IUS INNER JOIN sys.indexes SI ON SI.index_id = IUS.index_id
AND SI.object_id = IUS.object_id INNER JOIN sys.partitions SP ON SP.object_id = IUS.object_id
AND SP.index_id = IUS.index_id INNER JOIN sys.allocation_units AU ON AU.container_id = SP.partition_id
WHERE IUS.database_id = db_id('AUTCOM')
	AND IUS.object_id > 100 AND SI.index_id > 0
	AND IUS.last_user_lookup is null
	and IUS.last_user_scan is null
	and IUS.last_user_lookup is null
	and IUS.last_user_seek is null
	and SI.type_desc ='NONCLUSTERED'
	--and IUS.last_user_seek < GETDATE() - 14)
ORDER BY user_updates DESC
