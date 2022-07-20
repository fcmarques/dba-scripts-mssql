<<<<<<< HEAD
SELECT
	DB_NAME() [Database name], 
	f.name AS [File Name] , 
	f.physical_name AS [Physical Name],
	CAST((f.size/128.0) AS DECIMAL(15,2))/1024 AS [Total Size in GB],
	CAST(f.size/128.0 - CAST(FILEPROPERTY(f.name, 'SpaceUsed') AS int)/128.0 AS DECIMAL(15,2))/1024 AS [Available Space In GB], 
	growth * 8/1024/1024 as [File Growth in GB],
	fg.name AS [Filegroup Name],
	vs.logical_volume_name,
	vs.volume_mount_point,
	CONVERT(DECIMAL(18,2),vs.total_bytes/1073741824.0) AS [Vl Total Size (GB)],
	CONVERT(DECIMAL(18,2),vs.available_bytes/1073741824.0) AS [Vl Available Size (GB)]
FROM sys.database_files AS f WITH (NOLOCK) 
LEFT OUTER JOIN sys.data_spaces AS fg WITH (NOLOCK) ON f.data_space_id = fg.data_space_id 
CROSS APPLY sys.dm_os_volume_stats(DB_ID(), f.[file_id]) AS vs 
=======
SELECT
	DB_NAME() [Database name], 
	f.name AS [File Name] , 
	f.physical_name AS [Physical Name],
	CAST((f.size/128.0) AS DECIMAL(15,2))/1024 AS [Total Size in GB],
	CAST(f.size/128.0 - CAST(FILEPROPERTY(f.name, 'SpaceUsed') AS int)/128.0 AS DECIMAL(15,2))/1024 AS [Available Space In GB], 
	growth * 8/1024/1024 as [File Growth in GB],
	fg.name AS [Filegroup Name],
	vs.logical_volume_name,
	vs.volume_mount_point,
	CONVERT(DECIMAL(18,2),vs.total_bytes/1073741824.0) AS [Vl Total Size (GB)],
	CONVERT(DECIMAL(18,2),vs.available_bytes/1073741824.0) AS [Vl Available Size (GB)]
FROM sys.database_files AS f WITH (NOLOCK) 
LEFT OUTER JOIN sys.data_spaces AS fg WITH (NOLOCK) ON f.data_space_id = fg.data_space_id 
CROSS APPLY sys.dm_os_volume_stats(DB_ID(), f.[file_id]) AS vs 
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
OPTION (RECOMPILE);