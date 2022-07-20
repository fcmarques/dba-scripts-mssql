declare @DBName varchar(200)
declare @MdCmd varchar(1000)
declare @BackBaseDir varchar(1000)
declare @BackDir varchar(1000)
declare @Filename varchar(1000)
declare @Name varchar(1000)
declare @Description varchar(1000)
declare @TimeStamp varchar(1000)

set @BackBaseDir = 'D:\MSSQL\BACKUP\'
set @TimeStamp = replace(replace(replace(CONVERT(varchar, CURRENT_TIMESTAMP , 120), '-',''),':',''),' ','')

DECLARE AllDatabases CURSOR FOR
SELECT name AS Name
FROM MASTER.DBO.SYSDATABASES
WHERE [NAME] NOT IN('MODEL', 'tempdb', 'NORTHWIND', 'PUBS', 'msdb', 'master')

OPEN AllDatabases

FETCH NEXT FROM AllDatabases INTO @DBName

WHILE @@FETCH_STATUS = 0
BEGIN

print ''
print ''
print 'Backing up database ' + @DBName

-- Create directory for backup
set @MdCmd = 'md ' + @BackBaseDir + @DBName
exec master..xp_cmdshell @MdCmd, no_output
set @BackDir = @BackBaseDir + @DBName + '\'

-- Backup the database
set @Filename =  @BackDir + @DBName + '_FULL_' + @TimeStamp + '.bak'
set @Name = 'Full backup (' + @DBName + ')'
set @Description = 'Full backup of database ' + @DBName + 'on ' + @Filename
BACKUP DATABASE @DBName TO DISK = @Filename WITH INIT , NOUNLOAD , NAME = @Name, DESCRIPTION = @Description,NOSKIP , STATS = 10, NOFORMAT

FETCH NEXT FROM AllDatabases INTO @DBName
END

CLOSE AllDatabases
DEALLOCATE AllDatabases
