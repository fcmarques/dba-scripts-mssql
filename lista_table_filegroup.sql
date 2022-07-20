use sicc_band

go
select * from sys.sysfilegroups
SELECT 'exec sp_move_tables 1,3,'''+o.[name]+''',1,1'
--, o.[type], i.[name], i.[index_id], f.[name]
FROM sys.indexes i
INNER JOIN sys.filegroups f
ON i.data_space_id = f.data_space_id
INNER JOIN sys.all_objects o
ON i.[object_id] = o.[object_id]
WHERE i.data_space_id = f.data_space_id
AND o.type = 'U' -- User Created Tables
and f.name='PRIMARY' 
and i.index_id <= 1
GO