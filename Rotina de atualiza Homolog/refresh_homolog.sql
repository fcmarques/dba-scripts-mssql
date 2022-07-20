/*
	Rotina de atualização de ambiente de homolog

	CLIENTE   : Grupo Itavema
	TECNICO   : Fabio Marques
	ARQUIVO   : refresh_homolog.sql 
	OBJETIVO  : Realizar atualização de ambiente de homolog com arquivos de backup do ambiente de produção
	VERSAO    : 1.0 Criado em 26/09/2013
	HISTORICO :	<Nome> - <Data> - <Resumo>
				Fabio - 26/09/2013 - Versão inicial
*/

USE [master] 

SET NOCOUNT ON

DECLARE @BackupFilesProdPath nvarchar(max)
DECLARE @BackupFilesHmlPath nvarchar(max)
DECLARE @DataFilePath nvarchar(max)
DECLARE @LogFilePath nvarchar(max)

SET @BackupFilesProdPath = '\\GISD0013SQL\'
SET @BackupFilesHmlPath = 'C:\Backup-Full'
SET @DataFilePath = 'D:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA'
SET @LogFilePath = 'D:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA'

SELECT 
   'COPY ' + '"' + @BackupFilesProdPath + replace(B.physical_device_name,':','$') + '" "' + @BackupFilesHmlPath + '"' as copy_command,
   'RESTORE DATABASE [' + B.database_name + '] FROM  DISK = N''' + @BackupFilesHmlPath + '\' + reverse(left(reverse(B.physical_device_name), charindex('\',reverse(B.physical_device_name),1 ) - 1)) + ''' WITH  FILE = 1,  NOUNLOAD,  REPLACE,  STATS = 10' as restore_command,
   B.backup_start_date,  
   B.physical_device_name,
   B.database_name
FROM 
   ( 
   SELECT   
       CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server, 
       msdb.dbo.backupset.database_name,  
       MAX(msdb.dbo.backupset.backup_finish_date) AS last_db_backup_date 
   FROM    msdb.dbo.backupmediafamily  
       INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id 
   WHERE   msdb..backupset.type = 'D'
   AND msdb.dbo.backupset.database_name NOT IN ('master','model','msdb','tempdb')
   GROUP BY 
       msdb.dbo.backupset.database_name  
   ) AS A 
    
   LEFT JOIN  

   ( 
   SELECT   
   CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server, 
   msdb.dbo.backupset.database_name,  
   msdb.dbo.backupset.backup_start_date,  
   msdb.dbo.backupset.backup_finish_date, 
   msdb.dbo.backupset.expiration_date, 
   msdb.dbo.backupset.backup_size,  
   msdb.dbo.backupmediafamily.logical_device_name,  
   msdb.dbo.backupmediafamily.physical_device_name,   
   msdb.dbo.backupset.name AS backupset_name, 
   msdb.dbo.backupset.description 
FROM   msdb.dbo.backupmediafamily  
   INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id  
WHERE  msdb..backupset.type = 'D' 
	   
   ) AS B 
   ON A.[server] = B.[server] 
   AND A.[database_name] = B.[database_name] 
   AND A.[last_db_backup_date] = B.[backup_finish_date] 
ORDER BY  
   A.database_name