<<<<<<< HEAD
WITH LastRestores AS
(
SELECT
    DatabaseName = 
	[d].[name] ,
    [d].[create_date] ,
    [d].[compatibility_level] ,
    [d].[collation_name] ,
    rh.restore_date,
	bmf.physical_device_name,
    RowNum = ROW_NUMBER() OVER (PARTITION BY d.Name ORDER BY rh.[restore_date] DESC)
FROM master.sys.databases d
LEFT OUTER JOIN msdb.dbo.[restorehistory] rh ON rh.[destination_database_name] = d.Name
left outer join msdb.dbo.backupset bs on rh.backup_set_id = bs.backup_set_id
left outer join msdb.dbo.backupmediafamily bmf on bmf.media_set_id = bs.media_set_id and bmf.family_sequence_number = bs.first_family_number
)
SELECT *
FROM [LastRestores]
=======
WITH LastRestores AS
(
SELECT
    DatabaseName = 
	[d].[name] ,
    [d].[create_date] ,
    [d].[compatibility_level] ,
    [d].[collation_name] ,
    rh.restore_date,
	bmf.physical_device_name,
    RowNum = ROW_NUMBER() OVER (PARTITION BY d.Name ORDER BY rh.[restore_date] DESC)
FROM master.sys.databases d
LEFT OUTER JOIN msdb.dbo.[restorehistory] rh ON rh.[destination_database_name] = d.Name
left outer join msdb.dbo.backupset bs on rh.backup_set_id = bs.backup_set_id
left outer join msdb.dbo.backupmediafamily bmf on bmf.media_set_id = bs.media_set_id and bmf.family_sequence_number = bs.first_family_number
)
SELECT *
FROM [LastRestores]
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
WHERE [RowNum] = 1