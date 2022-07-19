<<<<<<< HEAD
------------------------------------------------------------------------------------------- 
--Most Recent Database Backup for Each Database 
------------------------------------------------------------------------------------------- 
SELECT  
   CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server, 
   bs.database_name,  
   MAX(bs.backup_finish_date) AS last_db_backup_date
FROM   msdb.dbo.backupmediafamily  bf
   INNER JOIN msdb.dbo.backupset bs ON bf.media_set_id = bs.media_set_id  
WHERE  bs.type = 'D' 
GROUP BY 
   bs.database_name  
ORDER BY  
=======
------------------------------------------------------------------------------------------- 
--Most Recent Database Backup for Each Database 
------------------------------------------------------------------------------------------- 
SELECT  
   CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server, 
   bs.database_name,  
   MAX(bs.backup_finish_date) AS last_db_backup_date
FROM   msdb.dbo.backupmediafamily  bf
   INNER JOIN msdb.dbo.backupset bs ON bf.media_set_id = bs.media_set_id  
WHERE  bs.type = 'D' 
GROUP BY 
   bs.database_name  
ORDER BY  
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
   bs.database_name