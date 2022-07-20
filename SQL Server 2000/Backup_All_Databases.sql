DECLARE @BackupFile varchar(255), @DB varchar(100), @Description varchar(255), @LogFile varchar(50)
DECLARE @Name varchar(200), @MediaName varchar(30), @BackupDirectory nvarchar(200) 
SET @BackupDirectory = 'D:\MSSQL\BACKUP\'
--Add a list of all databases you don't want to backup to this.
DECLARE Database_CURSOR CURSOR FOR 
SELECT name FROM MASTER.DBO.SYSDATABASES
WHERE name NOT IN('MODEL', 'tempdb', 'NORTHWIND', 'PUBS', 'msdb', 'master')
OPEN Database_Cursor
FETCH next FROM Database_CURSOR INTO @DB
WHILE @@fetch_status = 0

    BEGIN
    	SET @Name = @DB + '( Daily BACKUP )'
    	SET @MediaName = @DB + '_Dump' + CONVERT(varchar, CURRENT_TIMESTAMP , 112)
    	SET @BackupFile = @BackupDirectory + + @DB + '_' + 'Full' + '_' + 
    		CONVERT(varchar, CURRENT_TIMESTAMP , 112) + '.bak'
    	SET @Description = 'Normal' + ' BACKUP at ' + CONVERT(varchar, CURRENT_TIMESTAMP) + '.' 

    	IF (SELECT COUNT(*) FROM msdb.dbo.backupset WHERE database_name = @DB) > 0 OR @DB = 'master'
    		BEGIN
    			SET @BackupFile = @BackupDirectory + @DB + '_' + 'Full' + '_' + 
    				CONVERT(varchar, CURRENT_TIMESTAMP , 112) + '.bak'
    			--SET some more pretty stuff for sql server.
    			SET @Description = 'Full' + ' BACKUP at ' + CONVERT(varchar, CURRENT_TIMESTAMP) + '.' 
    		END	
    	ELSE
    		BEGIN
    			SET @BackupFile = @BackupDirectory + @DB + '_' + 'Full' + '_' + 
    				CONVERT(varchar, CURRENT_TIMESTAMP , 112) + '.bak'
    			--SET some more pretty stuff for sql server.
    			SET @Description = 'Full' + ' BACKUP at ' + CONVERT(varchar, CURRENT_TIMESTAMP) + '.' 
    		END
    		BACKUP DATABASE @DB TO DISK = @BackupFile 
    		WITH NAME = @Name, DESCRIPTION = @Description , 
    		MEDIANAME = @MediaName, MEDIADESCRIPTION = @Description , 
    		STATS = 10
    	FETCH next FROM Database_CURSOR INTO @DB
END
CLOSE Database_Cursor
DEALLOCATE Database_Cursor