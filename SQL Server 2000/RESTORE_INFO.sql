RESTORE HEADERONLY 
FROM DISK = 'F:\MSSQL\BACKUP\SANTOS\MERCURY01.BAK'
GO

RESTORE FILELISTONLY  
FROM DISK = 'F:\MSSQL\BACKUP\SANTOS\MERCURY01.BAK'
GO

RESTORE LABELONLY   
FROM DISK = 'F:\MSSQL\BACKUP\SANTOS\MERCURY01.BAK'
GO

RESTORE VERIFYONLY 
FROM DISK = 'F:\MSSQL\BACKUP\SANTOS\MERCURY01.BAK',
     DISK = 'F:\MSSQL\BACKUP\SANTOS\MERCURY02.BAK',
     DISK = 'F:\MSSQL\BACKUP\SANTOS\MERCURY03.BAK'
GO

select * from msdb..backupset
GO

select * from msdb..backupmediaset
GO

select * from msdb..backupmediafamily
GO

select * from msdb..backupfile
GO

select * from msdb..backupset bset
left join msdb..backupfile bfile on bset.backup_set_id = bfile.backup_set_id
left join msdb..backupmediaset mset on bset.media_set_id = mset.media_set_id
left join msdb..backupmediafamily mfam on mset.media_set_id = mfam.media_set_id

select * from msdb..restorehistory 
select * from msdb..restorefile
select * from msdb..restorefilegroup
