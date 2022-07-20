<<<<<<< HEAD
select count(*) from DBADB.DBO.ALLTABLES

SELECT 'ALTER TABLE ' + TABLE_NAME + ' REBUILD WITH (DATA_COMPRESSION = PAGE);' 
FROM DBADB.DBO.ALLTABLES 
where
TABLE_NAME not like 'master.%' and
TABLE_NAME not like 'tempdb.%' and
TABLE_NAME not like 'model.%' and
TABLE_NAME not like 'msdb.%' and
TABLE_NAME not like 'distribution.%'
ORDER BY 1


SET NOCOUNT ON
--DECLARE @AllTables table (CompleteTableName nvarchar(4000))
DECLARE @Search nvarchar(4000)
       ,@SQL   nvarchar(4000)
SET @Search=null --all rows
SET @SQL='select ''?''+''.''+s.name+''.''+t.name from [?].sys.tables t inner join sys.schemas s on t.schema_id=s.schema_id WHERE @@SERVERNAME+''.''+''?''+''.''+s.name+''.''+t.name LIKE ''%'+ISNULL(@SEARCH,'')+'%'''

INSERT INTO DBADB.DBO.ALLTABLES (TABLE_NAME)
    EXEC sp_msforeachdb @SQL
SET NOCOUNT OFF
=======
select count(*) from DBADB.DBO.ALLTABLES

SELECT 'ALTER TABLE ' + TABLE_NAME + ' REBUILD WITH (DATA_COMPRESSION = PAGE);' 
FROM DBADB.DBO.ALLTABLES 
where
TABLE_NAME not like 'master.%' and
TABLE_NAME not like 'tempdb.%' and
TABLE_NAME not like 'model.%' and
TABLE_NAME not like 'msdb.%' and
TABLE_NAME not like 'distribution.%'
ORDER BY 1


SET NOCOUNT ON
--DECLARE @AllTables table (CompleteTableName nvarchar(4000))
DECLARE @Search nvarchar(4000)
       ,@SQL   nvarchar(4000)
SET @Search=null --all rows
SET @SQL='select ''?''+''.''+s.name+''.''+t.name from [?].sys.tables t inner join sys.schemas s on t.schema_id=s.schema_id WHERE @@SERVERNAME+''.''+''?''+''.''+s.name+''.''+t.name LIKE ''%'+ISNULL(@SEARCH,'')+'%'''

INSERT INTO DBADB.DBO.ALLTABLES (TABLE_NAME)
    EXEC sp_msforeachdb @SQL
SET NOCOUNT OFF
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
