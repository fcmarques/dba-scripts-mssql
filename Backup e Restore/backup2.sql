<<<<<<< HEAD
SELECT  sd.name AS [Database],
        CASE WHEN bs.type = 'D' THEN 'Full backup'
             WHEN bs.type = 'I' THEN 'Differential'
             WHEN bs.type = 'L' THEN 'Log'
             WHEN bs.type = 'F' THEN 'File/Filegroup'
             WHEN bs.type = 'G' THEN 'Differential file'
             WHEN bs.type = 'P' THEN 'Partial'
             WHEN bs.type = 'Q' THEN 'Differential partial'
             ELSE 'Unknown (' + bs.type + ')'
        END AS [Backup Type],
        bs.backup_start_date AS [Date],
        bs.backup_finish_date
FROM    master..sysdatabases sd
        LEFT OUTER JOIN msdb..backupset bs ON RTRIM(bs.database_name) = RTRIM(sd.name)
        LEFT OUTER JOIN msdb..backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
WHERE bs.backup_start_date > GETDATE() - 5
and bs.type='L'
and sd.name='BWP'
ORDER BY  [Date] desc



SELECT  sd.name AS [Database],
        CASE WHEN bs.type = 'D' THEN 'Full backup'
             WHEN bs.type = 'I' THEN 'Differential'
             WHEN bs.type = 'L' THEN 'Log'
             WHEN bs.type = 'F' THEN 'File/Filegroup'
             WHEN bs.type = 'G' THEN 'Differential file'
             WHEN bs.type = 'P' THEN 'Partial'
             WHEN bs.type = 'Q' THEN 'Differential partial'
             ELSE 'Unknown (' + bs.type + ')'
        END AS [Backup Type],
        bs.backup_start_date AS [Date],
        bs.backup_finish_date,
        bs.
FROM    master..sysdatabases sd
        LEFT OUTER JOIN msdb..backupset bs ON RTRIM(bs.database_name) = RTRIM(sd.name)
        LEFT OUTER JOIN msdb..backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
WHERE bs.backup_start_date > GETDATE() - 5
and bs.type='L'
and sd.name='BWP'
ORDER BY  [Date] desc
select * from backupmediafamily
--select a.logical_name, a.backup_size, b.backup_start_date, b.backup_finish_date,
--		 b.backup_size,b.database_name,
--		    CASE WHEN b.type = 'D' THEN 'Full backup'
--             WHEN b.type = 'I' THEN 'Differential'
--             WHEN b.type = 'L' THEN 'Log'
--             WHEN b.type = 'F' THEN 'File/Filegroup'
--             WHEN b.type = 'G' THEN 'Differential file'
--             WHEN b.type = 'P' THEN 'Partial'
--             WHEN b.type = 'Q' THEN 'Differential partial'
--             ELSE 'Unknown (' + b.type + ')'
--        END AS [Backup Type]
--from msdb..backupfile as a join msdb..backupset as b on a.backup_set_id = b.backup_set_id


--select a.logical_name, a.backup_size, b.backup_start_date, b.backup_finish_date,
--		 b.backup_size,b.database_name,b.type
--from msdb..backupfile as a join msdb..backupset as b on a.backup_set_id = b.backup_set_id
--where b.database_name = 'R3P'
--and b.type= 'L'
--and b.backup_start_date > '2013-07-22'


--use msdb
--go
--sp_delete_backuphistory @oldest_date =  '01/01/2013'
=======
SELECT  sd.name AS [Database],
        CASE WHEN bs.type = 'D' THEN 'Full backup'
             WHEN bs.type = 'I' THEN 'Differential'
             WHEN bs.type = 'L' THEN 'Log'
             WHEN bs.type = 'F' THEN 'File/Filegroup'
             WHEN bs.type = 'G' THEN 'Differential file'
             WHEN bs.type = 'P' THEN 'Partial'
             WHEN bs.type = 'Q' THEN 'Differential partial'
             ELSE 'Unknown (' + bs.type + ')'
        END AS [Backup Type],
        bs.backup_start_date AS [Date],
        bs.backup_finish_date
FROM    master..sysdatabases sd
        LEFT OUTER JOIN msdb..backupset bs ON RTRIM(bs.database_name) = RTRIM(sd.name)
        LEFT OUTER JOIN msdb..backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
WHERE bs.backup_start_date > GETDATE() - 5
and bs.type='L'
and sd.name='BWP'
ORDER BY  [Date] desc



SELECT  sd.name AS [Database],
        CASE WHEN bs.type = 'D' THEN 'Full backup'
             WHEN bs.type = 'I' THEN 'Differential'
             WHEN bs.type = 'L' THEN 'Log'
             WHEN bs.type = 'F' THEN 'File/Filegroup'
             WHEN bs.type = 'G' THEN 'Differential file'
             WHEN bs.type = 'P' THEN 'Partial'
             WHEN bs.type = 'Q' THEN 'Differential partial'
             ELSE 'Unknown (' + bs.type + ')'
        END AS [Backup Type],
        bs.backup_start_date AS [Date],
        bs.backup_finish_date,
        bs.
FROM    master..sysdatabases sd
        LEFT OUTER JOIN msdb..backupset bs ON RTRIM(bs.database_name) = RTRIM(sd.name)
        LEFT OUTER JOIN msdb..backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
WHERE bs.backup_start_date > GETDATE() - 5
and bs.type='L'
and sd.name='BWP'
ORDER BY  [Date] desc
select * from backupmediafamily
--select a.logical_name, a.backup_size, b.backup_start_date, b.backup_finish_date,
--		 b.backup_size,b.database_name,
--		    CASE WHEN b.type = 'D' THEN 'Full backup'
--             WHEN b.type = 'I' THEN 'Differential'
--             WHEN b.type = 'L' THEN 'Log'
--             WHEN b.type = 'F' THEN 'File/Filegroup'
--             WHEN b.type = 'G' THEN 'Differential file'
--             WHEN b.type = 'P' THEN 'Partial'
--             WHEN b.type = 'Q' THEN 'Differential partial'
--             ELSE 'Unknown (' + b.type + ')'
--        END AS [Backup Type]
--from msdb..backupfile as a join msdb..backupset as b on a.backup_set_id = b.backup_set_id


--select a.logical_name, a.backup_size, b.backup_start_date, b.backup_finish_date,
--		 b.backup_size,b.database_name,b.type
--from msdb..backupfile as a join msdb..backupset as b on a.backup_set_id = b.backup_set_id
--where b.database_name = 'R3P'
--and b.type= 'L'
--and b.backup_start_date > '2013-07-22'


--use msdb
--go
--sp_delete_backuphistory @oldest_date =  '01/01/2013'
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
