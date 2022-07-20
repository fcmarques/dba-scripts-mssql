<<<<<<< HEAD
DECLARE @dbname VARCHAR(50) --Current DB
DECLARE @filename VARCHAR(100) --DB file name
DECLARE @SqlCmd VARCHAR(1000) --SQL Command

DECLARE db_cursor CURSOR FOR
 Select DB_NAME(database_id), name
 From sys.master_files
 Where [type] = 0 --Data files only
 
OPEN db_cursor
FETCH NEXT FROM db_cursor INTO @dbname, @filename

WHILE @@FETCH_STATUS = 0
BEGIN
 SET @SqlCmd = 'ALTER DATABASE ' + @dbname + ' MODIFY FILE (NAME = N'''+@filename+''', FILEGROWTH = 100)' --100MB
 EXEC (@SqlCmd)
 FETCH NEXT FROM db_cursor INTO @dbname, @filename

END

CLOSE db_cursor
=======
DECLARE @dbname VARCHAR(50) --Current DB
DECLARE @filename VARCHAR(100) --DB file name
DECLARE @SqlCmd VARCHAR(1000) --SQL Command

DECLARE db_cursor CURSOR FOR
 Select DB_NAME(database_id), name
 From sys.master_files
 Where [type] = 0 --Data files only
 
OPEN db_cursor
FETCH NEXT FROM db_cursor INTO @dbname, @filename

WHILE @@FETCH_STATUS = 0
BEGIN
 SET @SqlCmd = 'ALTER DATABASE ' + @dbname + ' MODIFY FILE (NAME = N'''+@filename+''', FILEGROWTH = 100)' --100MB
 EXEC (@SqlCmd)
 FETCH NEXT FROM db_cursor INTO @dbname, @filename

END

CLOSE db_cursor
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
DEALLOCATE db_cursor