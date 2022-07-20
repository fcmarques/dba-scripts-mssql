BEGIN

DECLARE @vDatabase nvarchar(128), @vTableName nvarchar(128), @vOwner nvarchar(128), @vHeader nvarchar(128)

DECLARE curDatabases CURSOR FOR
 SELECT name 
 FROM master.dbo.sysdatabases 
 WHERE name NOT IN ('master','model','msdb','tempdb')
	and databasepropertyex(name,'STATUS') = 'ONLINE'
	and databasepropertyex(name,'Updateability') = 'READ_WRITE'

	OPEN curDatabases

	FETCH NEXT FROM curDatabases INTO @vDatabase

	WHILE (@@fetch_status <> -1)
	BEGIN

		IF (@@fetch_status <> -2)
		BEGIN

		PRINT 'Atualizando estatísticas: ' + @vDatabase
		EXEC ('['+@vDatabase+'].dbo.sp_updatestats')

		END

	FETCH NEXT FROM curDatabases INTO @vDatabase

	END

	CLOSE curDatabases
	DEALLOCATE curDatabases

END