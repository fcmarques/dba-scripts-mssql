
SELECT au.allocation_unit_id, OBJECT_NAME(p.object_id) AS table_name, fg.name AS filegroup_name,
au.type_desc AS allocation_type, au.data_pages, partition_number
FROM sys.allocation_units AS au
JOIN sys.partitions AS p ON au.container_id = p.partition_id
JOIN sys.filegroups AS fg ON fg.data_space_id = au.data_space_id
WHERE au.allocation_unit_id =  385157439029248
ORDER BY au.allocation_unit_id

DBCC CHECKTABLE ('qa1.MSEG') WITH PHYSICAL_ONLY;

DBCC CHECKTABLE ('qa1.MSEG') WITH REPAIR_REBUILD