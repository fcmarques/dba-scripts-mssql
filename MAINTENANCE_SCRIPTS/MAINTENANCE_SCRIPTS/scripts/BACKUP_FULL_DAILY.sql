BEGIN

DECLARE @VcDbName nvarchar(128), @vSql nvarchar(1024)

DECLARE cDatabases CURSOR FOR
	select name from master..sysdatabases 
	where name <> 'tempdb'
			and databasepropertyex(name,'STATUS') = 'ONLINE'

	OPEN cDatabases

	FETCH NEXT FROM cDatabases INTO @VcDbName

	WHILE (@@fetch_status <> -1)
	BEGIN

		IF (@@fetch_status <> -2)
		BEGIN

		SET @vSql = 
				'BACKUP DATABASE ['+@VcDbName+'] 
						TO  DISK = N''C:\DBACORPteste\backup\BKP_FULL_'+@VcDbName+'_'+replace(convert(varchar, getdate(), 112), '-', '')+'.bak'' 
							WITH NOFORMAT
						, INIT
						,  NAME = N'''+@VcDbName+'-FULL Database Backup''
				, SKIP
				, NOREWIND
				, NOUNLOAD,  STATS = 10'

		EXEC (@vSql)

		FETCH NEXT FROM cDatabases INTO @VcDbName

		END

	END

	CLOSE cDatabases
	DEALLOCATE cDatabases

END