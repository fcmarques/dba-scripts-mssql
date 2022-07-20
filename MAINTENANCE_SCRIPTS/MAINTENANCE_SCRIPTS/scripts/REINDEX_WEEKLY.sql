BEGIN

DECLARE @vDatabase nvarchar(128), @vTableName nvarchar(128), @vOwner nvarchar(128), @vHeader    nvarchar(128), @vIndexName nvarchar(256)

DECLARE curDatabases CURSOR FOR
 SELECT name FROM master.dbo.sysdatabases 
 WHERE name NOT IN ('tempdb')
 	   and databasepropertyex(name,'STATUS') = 'ONLINE'
	   and databasepropertyex(name,'Updateability') = 'READ_WRITE'

	OPEN curDatabases

	FETCH NEXT FROM curDatabases INTO @vDatabase

	WHILE (@@fetch_status <> -1)
	BEGIN

		IF (@@fetch_status <> -2)
		BEGIN

			EXEC
			('
			declare TableNames cursor for
					select A.NAME, B.NAME, QUOTENAME(D.NAME)
					from ['+@vDatabase+'].[DBO].[SYSOBJECTS] A
						, ['+@vDatabase+'].[SYS].[SCHEMAS] B
						, sys.dm_db_index_physical_stats (DB_ID('''+@vDatabase+'''), NULL, NULL , NULL, ''LIMITED'') C
						, ['+@vDatabase+'].sys.indexes D
					where A.TYPE = ''U'' AND A.uid = B.schema_id
						  AND a.id = c.object_id
						  AND c.avg_fragmentation_in_percent >= 30.0 AND c.index_id > 0
						  AND D.object_id = c.object_id AND D.index_id = c.index_id
					order by A.NAME
			')

			OPEN TableNames
			FETCH next FROM TableNames INTO @vTableName, @vOwner, @vIndexName

			WHILE (@@FETCH_STATUS <> -1)
			BEGIN
			  IF (@@FETCH_STATUS <> -2)
			  BEGIN

				SELECT @vHeader = 'Recriando '+upper('['+@vDatabase+'].['+@vOwner+'].['+@vTableName+']')
				PRINT @vHeader
				EXEC('ALTER INDEX '+@vIndexName+' ON ['+@vDatabase+'].['+@vOwner+'].['+@vTableName+'] REBUILD WITH ( PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, ONLINE = OFF, SORT_IN_TEMPDB = OFF )')

			  END
			  FETCH next FROM TableNames INTO @vTableName, @vOwner, @vIndexName
			END
			CLOSE TableNames
			DEALLOCATE TableNames

		END

	FETCH NEXT FROM curDatabases INTO @vDatabase

	END

	CLOSE curDatabases
	DEALLOCATE curDatabases

END