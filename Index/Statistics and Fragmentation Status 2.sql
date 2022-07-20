DECLARE @table_name varchar(100)
DECLARE @schemaName varchar(100)
DECLARE @object_id int

DECLARE curTables CURSOR FOR
    select object_id, name from sys.tables
    order by name

OPEN curTables

FETCH NEXT FROM curTables INTO @object_id, @table_name

WHILE @@FETCH_STATUS = 0
BEGIN
    
    print 'analisando - ' + @table_name
    insert into dba_fragmentation
    SELECT ss.NAME AS SchemaName
	    ,st.NAME AS TableName
	    ,s.NAME AS IndexName
	    ,STATS_DATE(s.id, s.indid) AS 'Statistics Last Updated'
	    ,ips.avg_fragmentation_in_percent
	    ,s.rowcnt AS 'Row Count'
	    ,s.rowmodctr AS 'Number Of Changes'
	    ,CAST((CAST(s.rowmodctr AS DECIMAL(28, 8)) / CAST(s.rowcnt AS DECIMAL(28, 2)) * 100.0) AS DECIMAL(28, 2)) AS '% Rows Changed' 
    FROM sys.sysindexes s
    INNER JOIN sys.tables st ON st.[object_id] = s.[id]
    INNER JOIN sys.schemas ss ON ss.[schema_id] = st.[schema_id]
    INNER JOIN sys.dm_db_index_physical_stats(db_id(), @object_id, NULL, NULL, 'LIMITED') AS ips ON s.indid = ips.index_id
    WHERE s.id > 100
	    AND s.indid > 0
	    AND s.rowcnt >= 500
	    AND st.NAME = @table_name

    ORDER BY '% Rows Changed' DESC
	    ,SchemaName
	    ,TableName
	    ,IndexName
    FETCH NEXT FROM curTables INTO @object_id, @table_name
END

CLOSE curTables

DEALLOCATE curTables
--select * from dba_fragmentation
--order by avg_fragmentation_in_percent desc

--truncate table dba_fragmentation