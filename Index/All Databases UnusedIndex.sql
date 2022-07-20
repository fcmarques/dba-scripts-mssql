If exists (select * from tempdb.sys.all_objects where name like '#UnusedIndex%' )
drop table #UnusedIndex

CREATE TABLE #UnusedIndex(
	[DatabaseName] [nvarchar](128) NULL,
	[TableName] [nvarchar](128) NULL,
	[SchemaName] [sysname] NULL,
	[IndexName] [sysname] NULL,
	[type_desc] [nvarchar](60) NULL,
	[create_date] [datetime] NOT NULL,
	[index_id] [int] NOT NULL,
	[is_disabled] [bit] NULL,
	[TotalWrites] [bigint] NOT NULL,
	[TotalReads] [bigint] NULL,
	[Difference] [bigint] NULL
) ON [PRIMARY]

GO

INSERT INTO #UnusedIndex
           ([DatabaseName]
           ,[TableName]
           ,[SchemaName]
           ,[IndexName]
           ,[type_desc]
           ,[create_date]
           ,[index_id]
           ,[is_disabled]
           ,[TotalWrites]
           ,[TotalReads]
           ,[Difference])

exec master.sys.sp_MSforeachdb ' USE [?]

SELECT db_name() as DatabaseName, OBJECT_SCHEMA_NAME(s.[object_id]) AS [TableSchema], OBJECT_NAME(s.[object_id]) AS [TableName], i.name AS [IndexName], 
o.[type_desc], o.create_date, i.index_id, i.is_disabled,
user_updates AS [TotalWrites], user_seeks + user_scans + user_lookups AS [TotalReads],
user_updates - (user_seeks + user_scans + user_lookups) AS [Difference]
FROM sys.dm_db_index_usage_stats AS s WITH (NOLOCK)
INNER JOIN sys.indexes AS i WITH (NOLOCK)
ON s.[object_id] = i.[object_id]
AND i.index_id = s.index_id
INNER JOIN sys.objects AS o WITH (NOLOCK) 
ON i.[object_id] = o.[object_id]
WHERE OBJECTPROPERTY(s.[object_id],''IsUserTable'') = 1
AND s.database_id = DB_ID()
AND user_updates > (user_seeks + user_scans + user_lookups)
AND i.index_id > 1
ORDER BY [Difference] DESC, [TotalWrites] DESC, [TotalReads] ASC OPTION (RECOMPILE);'
go

select * from #UnusedIndex
where totalreads = 0 