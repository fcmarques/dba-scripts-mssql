--USE [DB_MERCURY_SBV]
DECLARE @table VARCHAR(50),
    @column VARCHAR(50),
    @cmd VARCHAR(500)
DECLARE TABLES_CURSOR CURSOR
    FOR
SELECT  TABLE_NAME,
        COLUMN_NAME
FROM    INFORMATION_SCHEMA.COLUMNS
WHERE   COLUMN_NAME LIKE '%ISS_ID%'
ORDER BY 1

OPEN TABLES_CURSOR

FETCH NEXT FROM TABLES_CURSOR INTO @table, @column
--PRINT @table + ' - ' + @column
WHILE @@FETCH_STATUS = 0
    BEGIN
        declare @aa varchar(100),
            @tabname varchar(100),
            @wherevalue varchar(100),
            @statement VARCHAR(200)

        SELECT  @statement = 'DEClARE c CURSOR FOR Select top 1 ' + @column + ' from ' + @table + ' where ' + @column + ' is not null and ' + @column + '= 56'

        EXEC ( @statement )
        OPEN c
        fetch next from c into @aa

        while ( @@fetch_status = 0 )
		begin
            PRINT @table + ' - ' + @column
        fetch next from c into @aa
		END
        close c
        deallocate c

        FETCH NEXT FROM TABLES_CURSOR INTO @table, @column
    END
CLOSE TABLES_CURSOR
DEALLOCATE TABLES_CURSOR

	