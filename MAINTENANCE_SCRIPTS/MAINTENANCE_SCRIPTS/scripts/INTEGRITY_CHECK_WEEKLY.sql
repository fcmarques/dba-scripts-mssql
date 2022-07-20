BEGIN

DECLARE @vDatabase nvarchar(128), @vTableName nvarchar(128), @vOwner nvarchar(128), @vHeader    nvarchar(128)

DECLARE curDatabases CURSOR FOR
 SELECT name FROM master.dbo.sysdatabases 
 WHERE databasepropertyex(name,'STATUS') = 'ONLINE'

	OPEN curDatabases

	FETCH NEXT FROM curDatabases INTO @vDatabase

	WHILE (@@fetch_status <> -1)
	BEGIN

		IF (@@fetch_status <> -2)
		BEGIN

		PRINT 'Verificando Integridade: ' + @vDatabase
		EXEC ('dbcc checkdb('''+@vDatabase+''')')

		END

	FETCH NEXT FROM curDatabases INTO @vDatabase

	END

	CLOSE curDatabases
	DEALLOCATE curDatabases

END