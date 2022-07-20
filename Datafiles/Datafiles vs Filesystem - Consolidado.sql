<<<<<<< HEAD
SET NOCOUNT ON

CREATE TABLE #tb_db_files_space(
	[Database name] [nvarchar](128) NULL,
	[DB Category] [nvarchar](4) NULL,
	[File Name] [sysname] NOT NULL,
	[Physical Name] [nvarchar](260) NOT NULL,
	[Total Size in MB] [decimal](15, 2) NULL,
	[Available Space In MB] [decimal](15, 2) NULL,
	[File Growth in MB] [int] NULL,
	[Filegroup Name] [sysname] NULL,
	[Logical Volume Name] [nvarchar](256) NULL,
	[Volume Mount Point] [nvarchar](256) NULL,
	[Vl Total Size (MB)] [decimal](18, 2) NULL,
	[Vl Available Size (MB)] [decimal](18, 2) NULL,
	[Vl Space Free %] [decimal](22, 2) NULL
);

EXECUTE master.sys.sp_MSforeachdb '
USE [?]; 

INSERT INTO #tb_db_files_space
SELECT
	DB_NAME() [Database name],
	CASE 
		WHEN (select sum(size*8/1024) from sys.database_files) > 1000000 THEN ''VLDB''
		WHEN (select sum(size*8/1024) from sys.database_files) BETWEEN 100000	AND 1000000 THEN ''LDB''
		WHEN (select sum(size*8/1024) from sys.database_files) < 100000 THEN ''SDB''
	END AS [DB Category],
	f.name AS [File Name] , 
	f.physical_name AS [Physical Name],
	CAST((f.size/128.0) AS DECIMAL(15,2)) AS [Total Size in MB],
	CAST(f.size/128.0 - CAST(FILEPROPERTY(f.name, ''SpaceUsed'') AS int)/128.0 AS DECIMAL(15,2)) AS [Available Space In MB], 
	growth * 8/1024 as [File Growth in MB],
	fg.name AS [Filegroup Name],
	vs.logical_volume_name as [Logical Volume Name],
	vs.volume_mount_point as [Volume Mount Point],
	CONVERT(DECIMAL(18,2),vs.total_bytes/1048576.0) AS [Vl Total Size (MB)],
	CONVERT(DECIMAL(18,2),vs.available_bytes/1048576.0) AS [Vl Available Size (MB)],
	CAST(CAST(vs.available_bytes AS FLOAT)/ CAST(vs.total_bytes AS FLOAT) AS DECIMAL(18,2)) * 100 AS [Vl Space Free %] 
FROM sys.database_files AS f WITH (NOLOCK) 
LEFT OUTER JOIN sys.data_spaces AS fg WITH (NOLOCK) ON f.data_space_id = fg.data_space_id 
CROSS APPLY sys.dm_os_volume_stats(DB_ID(), f.[file_id]) AS vs 
order by 1,2
OPTION (RECOMPILE);
'

select [Database name], 
		SUM([Total Size in MB]) as [Total Size in MB], 
		SUM([Available Space In MB]) as [Available Space In MB], 
		[Filegroup Name],
		[Volume Mount Point],
		SUM([Vl Total Size (MB)]) as [Vl Total Size (MB)],
		SUM([Vl Available Size (MB)]) as [Vl Available Size (MB)],
		[Vl Space Free %] 
from #tb_db_files_space
--where [Database name] = 'P11PRD'
group by [Database name],
		 [Filegroup Name],
		 [Volume Mount Point],
		 [Vl Space Free %]
order by 1,3;


select * from #tb_db_files_space
order by 1,3;

=======
SET NOCOUNT ON

CREATE TABLE #tb_db_files_space(
	[Database name] [nvarchar](128) NULL,
	[DB Category] [nvarchar](4) NULL,
	[File Name] [sysname] NOT NULL,
	[Physical Name] [nvarchar](260) NOT NULL,
	[Total Size in MB] [decimal](15, 2) NULL,
	[Available Space In MB] [decimal](15, 2) NULL,
	[File Growth in MB] [int] NULL,
	[Filegroup Name] [sysname] NULL,
	[Logical Volume Name] [nvarchar](256) NULL,
	[Volume Mount Point] [nvarchar](256) NULL,
	[Vl Total Size (MB)] [decimal](18, 2) NULL,
	[Vl Available Size (MB)] [decimal](18, 2) NULL,
	[Vl Space Free %] [decimal](22, 2) NULL
);

EXECUTE master.sys.sp_MSforeachdb '
USE [?]; 

INSERT INTO #tb_db_files_space
SELECT
	DB_NAME() [Database name],
	CASE 
		WHEN (select sum(size*8/1024) from sys.database_files) > 1000000 THEN ''VLDB''
		WHEN (select sum(size*8/1024) from sys.database_files) BETWEEN 100000	AND 1000000 THEN ''LDB''
		WHEN (select sum(size*8/1024) from sys.database_files) < 100000 THEN ''SDB''
	END AS [DB Category],
	f.name AS [File Name] , 
	f.physical_name AS [Physical Name],
	CAST((f.size/128.0) AS DECIMAL(15,2)) AS [Total Size in MB],
	CAST(f.size/128.0 - CAST(FILEPROPERTY(f.name, ''SpaceUsed'') AS int)/128.0 AS DECIMAL(15,2)) AS [Available Space In MB], 
	growth * 8/1024 as [File Growth in MB],
	fg.name AS [Filegroup Name],
	vs.logical_volume_name as [Logical Volume Name],
	vs.volume_mount_point as [Volume Mount Point],
	CONVERT(DECIMAL(18,2),vs.total_bytes/1048576.0) AS [Vl Total Size (MB)],
	CONVERT(DECIMAL(18,2),vs.available_bytes/1048576.0) AS [Vl Available Size (MB)],
	CAST(CAST(vs.available_bytes AS FLOAT)/ CAST(vs.total_bytes AS FLOAT) AS DECIMAL(18,2)) * 100 AS [Vl Space Free %] 
FROM sys.database_files AS f WITH (NOLOCK) 
LEFT OUTER JOIN sys.data_spaces AS fg WITH (NOLOCK) ON f.data_space_id = fg.data_space_id 
CROSS APPLY sys.dm_os_volume_stats(DB_ID(), f.[file_id]) AS vs 
order by 1,2
OPTION (RECOMPILE);
'

select [Database name], 
		SUM([Total Size in MB]) as [Total Size in MB], 
		SUM([Available Space In MB]) as [Available Space In MB], 
		[Filegroup Name],
		[Volume Mount Point],
		SUM([Vl Total Size (MB)]) as [Vl Total Size (MB)],
		SUM([Vl Available Size (MB)]) as [Vl Available Size (MB)],
		[Vl Space Free %] 
from #tb_db_files_space
--where [Database name] = 'P11PRD'
group by [Database name],
		 [Filegroup Name],
		 [Volume Mount Point],
		 [Vl Space Free %]
order by 1,3;


select * from #tb_db_files_space
order by 1,3;

>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
drop table #tb_db_files_space;