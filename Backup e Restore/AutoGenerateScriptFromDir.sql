<<<<<<< HEAD
/*
   Auto generate SQL Server restore script from backup files in a directory
   The following is one simple approach of reading the contents of a directory and creating the restore commands that need to be issued to restore the database.  This script will work for full, differential and transaction log backups.
   
   Before we get started the script below assumes the following:
   
   1 - The restored database will have the same name as the backed up database
   2 - The restored database will be restored in the same location as the backed up database
   3 - The files have the following naming format dbName_YYYYMMDDHHMM.xxx
   4 - File extensions are as follows
      Full backup - BAK
      Differential backup - DIF
      Transaction log backup - TRN
   5 - XP_CMDSHELL is enabled
   6 - There are no missing transaction logs that may break the restore chain

*/

USE Master; 
GO
SET NOCOUNT ON

-- 1 - Variable declaration 
DECLARE @dbName sysname
DECLARE @backupPath NVARCHAR(500)
DECLARE @cmd NVARCHAR(500)
DECLARE @fileList TABLE (backupFile NVARCHAR(255))
DECLARE @lastFullBackup NVARCHAR(500)
DECLARE @lastDiffBackup NVARCHAR(500)
DECLARE @backupFile NVARCHAR(500)

-- 2 - Initialize variables 
SET @dbName = 'P11PRD'
SET @backupPath = '\\192.168.254.171\bkp_dbs\TOTVS\MBS-79a39df2-8354-469f-a344-f5abd8b7e908\CBB_CP-DBS01\CBB_Database\CP-DBS01\TOTVS\P11PRD\20211031053140\'

-- 3 - get list of files 
SET @cmd = 'DIR /b /on ' + @backupPath

INSERT INTO @fileList
   (backupFile)
EXEC master.sys.xp_cmdshell @cmd

-- 4 - Find latest full backup 
SELECT @lastFullBackup = MAX(backupFile)
FROM @fileList
WHERE backupFile LIKE '%.BAK'
   AND backupFile LIKE @dbName + '%'

SET @cmd = 'RESTORE DATABASE ' + @dbName + ' FROM DISK = '''  
       + @backupPath + @lastFullBackup + ''' WITH NORECOVERY, REPLACE'
PRINT @cmd

-- 4 - Find latest diff backup 
SELECT @lastDiffBackup = MAX(backupFile)
FROM @fileList
WHERE backupFile LIKE '%.DIF'
   AND backupFile LIKE @dbName + '%'
   AND backupFile > @lastFullBackup

-- check to make sure there is a diff backup 
IF @lastDiffBackup IS NOT NULL 
BEGIN
   SET @cmd = 'RESTORE DATABASE ' + @dbName + ' FROM DISK = '''  
       + @backupPath + @lastDiffBackup + ''' WITH NORECOVERY'
   PRINT @cmd
   SET @lastFullBackup = @lastDiffBackup
END

-- 5 - check for log backups 
DECLARE backupFiles CURSOR FOR  
   SELECT backupFile
FROM @fileList
WHERE backupFile LIKE '%.TRN'
   AND backupFile LIKE @dbName + '%'
   AND backupFile > @lastFullBackup

OPEN backupFiles

-- Loop through all the files for the database  
FETCH NEXT FROM backupFiles INTO @backupFile

WHILE @@FETCH_STATUS = 0  
BEGIN
   SET @cmd = 'RESTORE LOG ' + @dbName + ' FROM DISK = '''  
       + @backupPath + @backupFile + ''' WITH NORECOVERY,  NOUNLOAD,  STATS = 10;'
   PRINT @cmd
   FETCH NEXT FROM backupFiles INTO @backupFile
END

CLOSE backupFiles
DEALLOCATE backupFiles

-- 6 - put database in a useable state 
SET @cmd = 'RESTORE DATABASE ' + @dbName + ' WITH RECOVERY'
PRINT @cmd 

=======
/*
   Auto generate SQL Server restore script from backup files in a directory
   The following is one simple approach of reading the contents of a directory and creating the restore commands that need to be issued to restore the database.  This script will work for full, differential and transaction log backups.
   
   Before we get started the script below assumes the following:
   
   1 - The restored database will have the same name as the backed up database
   2 - The restored database will be restored in the same location as the backed up database
   3 - The files have the following naming format dbName_YYYYMMDDHHMM.xxx
   4 - File extensions are as follows
      Full backup - BAK
      Differential backup - DIF
      Transaction log backup - TRN
   5 - XP_CMDSHELL is enabled
   6 - There are no missing transaction logs that may break the restore chain

*/

USE Master; 
GO
SET NOCOUNT ON

-- 1 - Variable declaration 
DECLARE @dbName sysname
DECLARE @backupPath NVARCHAR(500)
DECLARE @cmd NVARCHAR(500)
DECLARE @fileList TABLE (backupFile NVARCHAR(255))
DECLARE @lastFullBackup NVARCHAR(500)
DECLARE @lastDiffBackup NVARCHAR(500)
DECLARE @backupFile NVARCHAR(500)

-- 2 - Initialize variables 
SET @dbName = 'P11PRD'
SET @backupPath = '\\192.168.254.171\bkp_dbs\TOTVS\MBS-79a39df2-8354-469f-a344-f5abd8b7e908\CBB_CP-DBS01\CBB_Database\CP-DBS01\TOTVS\P11PRD\20211031053140\'

-- 3 - get list of files 
SET @cmd = 'DIR /b /on ' + @backupPath

INSERT INTO @fileList
   (backupFile)
EXEC master.sys.xp_cmdshell @cmd

-- 4 - Find latest full backup 
SELECT @lastFullBackup = MAX(backupFile)
FROM @fileList
WHERE backupFile LIKE '%.BAK'
   AND backupFile LIKE @dbName + '%'

SET @cmd = 'RESTORE DATABASE ' + @dbName + ' FROM DISK = '''  
       + @backupPath + @lastFullBackup + ''' WITH NORECOVERY, REPLACE'
PRINT @cmd

-- 4 - Find latest diff backup 
SELECT @lastDiffBackup = MAX(backupFile)
FROM @fileList
WHERE backupFile LIKE '%.DIF'
   AND backupFile LIKE @dbName + '%'
   AND backupFile > @lastFullBackup

-- check to make sure there is a diff backup 
IF @lastDiffBackup IS NOT NULL 
BEGIN
   SET @cmd = 'RESTORE DATABASE ' + @dbName + ' FROM DISK = '''  
       + @backupPath + @lastDiffBackup + ''' WITH NORECOVERY'
   PRINT @cmd
   SET @lastFullBackup = @lastDiffBackup
END

-- 5 - check for log backups 
DECLARE backupFiles CURSOR FOR  
   SELECT backupFile
FROM @fileList
WHERE backupFile LIKE '%.TRN'
   AND backupFile LIKE @dbName + '%'
   AND backupFile > @lastFullBackup

OPEN backupFiles

-- Loop through all the files for the database  
FETCH NEXT FROM backupFiles INTO @backupFile

WHILE @@FETCH_STATUS = 0  
BEGIN
   SET @cmd = 'RESTORE LOG ' + @dbName + ' FROM DISK = '''  
       + @backupPath + @backupFile + ''' WITH NORECOVERY,  NOUNLOAD,  STATS = 10;'
   PRINT @cmd
   FETCH NEXT FROM backupFiles INTO @backupFile
END

CLOSE backupFiles
DEALLOCATE backupFiles

-- 6 - put database in a useable state 
SET @cmd = 'RESTORE DATABASE ' + @dbName + ' WITH RECOVERY'
PRINT @cmd 

>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
