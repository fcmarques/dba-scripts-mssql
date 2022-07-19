<<<<<<< HEAD
SELECT bs.machine_name, bs.server_name, bs.database_name AS [Database Name], bs.recovery_model,
Case
	WHEN bs.type = 'D' THEN 'Full backup'
	WHEN bs.type = 'I' THEN 'Differential'
	WHEN bs.type = 'L' THEN 'Log'
	WHEN bs.type = 'F' THEN 'File/Filegroup'
	WHEN bs.type = 'G' THEN 'Differential file'
	WHEN bs.type = 'P' THEN 'Partial'
	WHEN bs.type = 'Q' THEN 'Differential partial'
    ELSE bs.type
END AS Backup_Type_Desc,
CONVERT (BIGINT, bs.backup_size / 1048576 ) AS [Uncompressed Backup Size (MB)],
CONVERT (BIGINT, bs.compressed_backup_size / 1048576 ) AS [Compressed Backup Size (MB)],
CONVERT (NUMERIC (20,2), (CONVERT (FLOAT, bs.backup_size) /
CONVERT (FLOAT, bs.compressed_backup_size))) AS [Compression Ratio], bs.has_backup_checksums, bs.is_copy_only,
DATEDIFF (SECOND, bs.backup_start_date, bs.backup_finish_date) AS [Backup Elapsed Time (sec)],
bs.backup_start_date AS [Backup Start Date],bs.backup_finish_date AS [Backup Finish Date], bmf.physical_device_name AS [Backup Location], bmf.physical_block_size
FROM msdb.dbo.backupset AS bs WITH (NOLOCK)
INNER JOIN msdb.dbo.backupmediafamily AS bmf WITH (NOLOCK)
ON bs.media_set_id = bmf.media_set_id  
WHERE DATEDIFF (SECOND, bs.backup_start_date, bs.backup_finish_date) > 0 
AND bs.backup_size > 0
AND backup_start_date between  GETDATE() - 15 and GETDATE()
=======
SELECT bs.machine_name, bs.server_name, bs.database_name AS [Database Name], bs.recovery_model,
Case
	WHEN bs.type = 'D' THEN 'Full backup'
	WHEN bs.type = 'I' THEN 'Differential'
	WHEN bs.type = 'L' THEN 'Log'
	WHEN bs.type = 'F' THEN 'File/Filegroup'
	WHEN bs.type = 'G' THEN 'Differential file'
	WHEN bs.type = 'P' THEN 'Partial'
	WHEN bs.type = 'Q' THEN 'Differential partial'
    ELSE bs.type
END AS Backup_Type_Desc,
CONVERT (BIGINT, bs.backup_size / 1048576 ) AS [Uncompressed Backup Size (MB)],
CONVERT (BIGINT, bs.compressed_backup_size / 1048576 ) AS [Compressed Backup Size (MB)],
CONVERT (NUMERIC (20,2), (CONVERT (FLOAT, bs.backup_size) /
CONVERT (FLOAT, bs.compressed_backup_size))) AS [Compression Ratio], bs.has_backup_checksums, bs.is_copy_only,
DATEDIFF (SECOND, bs.backup_start_date, bs.backup_finish_date) AS [Backup Elapsed Time (sec)],
bs.backup_start_date AS [Backup Start Date],bs.backup_finish_date AS [Backup Finish Date], bmf.physical_device_name AS [Backup Location], bmf.physical_block_size
FROM msdb.dbo.backupset AS bs WITH (NOLOCK)
INNER JOIN msdb.dbo.backupmediafamily AS bmf WITH (NOLOCK)
ON bs.media_set_id = bmf.media_set_id  
WHERE DATEDIFF (SECOND, bs.backup_start_date, bs.backup_finish_date) > 0 
AND bs.backup_size > 0
AND backup_start_date between  GETDATE() - 15 and GETDATE()
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
ORDER BY 1,2,3,12 DESC OPTION (RECOMPILE);