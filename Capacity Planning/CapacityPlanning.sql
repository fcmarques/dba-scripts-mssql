<<<<<<< HEAD
USE [msdb]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************************************************
Purpose        : Populate [tbl_CapacityPlanning] table in msdb database to keep Database &
files details for Capacity Planning and growth trends.
Author        : Deepak Kumar
Dependencies: None, SP is compatible for SQL Server 2005 onwards..                    
*******************************************************************************************/
CREATE PROC [dbo].[dba_CapacityPlanning]
AS
BEGIN
SET NOCOUNT ON
IF  NOT EXISTS (SELECT * FROM MSDB.sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[tbl_CapacityPlanning]') AND type in (N'U'))
BEGIN
CREATE TABLE [msdb].[dbo].[tbl_CapacityPlanning](
    [ExecuteTime] [datetime] NULL,
    [SQLBuild] [nvarchar](57) NULL,
    [SQLName] [nvarchar](128) NULL,
    [DBName] [sysname]  NULL,
    [LogicalFileName] [sysname]  NULL,
    [DBCreationDate] [datetime]  NULL,
    [DBRecoveryModel] [nvarchar](60) NULL,
    [DBCompatibilityLevel] [tinyint] NULL,
    [DBCollation] [sysname] NULL,
    [FileType] [nvarchar](60) NULL,
    [FileName] [nvarchar](260)  NULL,
    [Growth] [float] NULL,
    [GrowthType] [varchar](30) NULL,
    [FileID] [int]  NULL,
    [IsPrimaryFile] [bit] NULL,
    [MaxSize(MB)] [float] NULL,
    [Size(MB)] [float] NULL,
    [UsedSpace(MB)] [float] NULL,
    [AvailableSpace(MB)] [float] NULL,
    [FileStatus] [nvarchar](60) NULL,
    [IsOffline] [bit] NULL,
    [IsReadOnly] [bit] NOT NULL,
    [IsReadOnlyMedia] [bit]  NULL,
    [IsSparse] [bit]  NULL
) ON [PRIMARY]
END 
CREATE table #tmpspc (Fileid int, FileGroup int, TotalExtents int, 
UsedExtents int, Name sysname, FileName nchar(520)) 
DECLARE @DatabaseName varchar(500)
DECLARE curDB cursor for 
SELECT ltrim(rtrim(name))  from master.sys.databases where state_desc='ONLINE' 
AND user_access_desc='MULTI_USER'
open curDB
fetch curDB into @DatabaseName
while @@fetch_status = 0
begin
insert into #tmpspc exec ('USE [' + @DatabaseName + ']  DBCC SHOWFILESTATS')    
fetch curDB into @DatabaseName
end
close curDB
deallocate curDB 
 
create table #tmplogspc (DatabaseName sysname, LogSize float, SpaceUsedPerc float, Status bit)
insert #tmplogspc EXEC ('dbcc sqlperf(logspace)') 
 
insert into [msdb].[dbo].[tbl_CapacityPlanning] SELECT getdate() AS [ExecuteTime],
left(@@version,57) AS [SQLBuild], @@servername AS [SQLName],
sd.name AS [DBName],
s.name AS [LogicalFileName],
sd.create_date AS [DBCreationDate], sd.recovery_model_desc AS [DBRecoveryModel], 
sd.compatibility_level AS [DBCompatibilityLevel], sd.collation_name AS [DBCollation],
s.type_desc AS [FileType],
s.physical_name AS [FileName],
CAST(CASE s.is_percent_growth WHEN 1 THEN s.growth ELSE (s.growth*8)/1024 END AS float) AS [Growth],
CAST(CASE WHEN s.is_percent_growth=1  THEN '%' Else 'MB' END AS VARCHAR) AS [GrowthType],
s.file_id AS [FileID],
CAST(CASE s.file_id WHEN 1 THEN 1 ELSE 0 END AS bit) AS [IsPrimaryFile],
CASE when s.max_size=-1 then -1 else (s.max_size * CONVERT(float,8))/1024 END AS [MaxSize(MB)],
(s.size * CONVERT(float,8))/1024 AS [Size(MB)],
(CAST(tspc.UsedExtents*convert(float,64) AS float))/1024 AS [UsedSpace(MB)],
((tspc.TotalExtents - tspc.UsedExtents)*convert(float,64))/1024 AS [AvailableSpace(MB)],
s.state_desc AS [FileStatus],
CAST(case s.state when 6 then 1 else 0 end AS bit) AS [IsOffline],
s.is_read_only AS [IsReadOnly],
s.is_media_read_only AS [IsReadOnlyMedia],
s.is_sparse AS [IsSparse]
FROM master.sys.master_files AS s 
INNER JOIN master.sys.databases sd ON sd.database_id=s.database_id
INNER JOIN #tmpspc tspc ON ltrim(rtrim(tspc.FileName)) = ltrim(rtrim(s.physical_name))
UNION ALL
SELECT getdate() AS [ExecuteTime],left(@@version,57) AS [SQLBuild], @@servername AS [SQLName],
sd.name AS [DBName],
s.name AS [LogicalName],
sd.create_date AS [DBCreationDate], sd.recovery_model_desc AS [DBRecoveryModel], 
sd.compatibility_level AS [DBCompatibilityLevel], sd.collation_name AS [DBCollation],
s.type_desc AS [FileType],
s.physical_name AS [FileName],
CAST(CASE s.is_percent_growth WHEN 1 THEN s.growth ELSE (s.growth*8)/1024 END AS float) AS [Growth],
CAST(CASE WHEN s.is_percent_growth=1  THEN '%' Else 'MB' END AS VARCHAR) AS [GrowthType],
s.file_id AS [FileID],
'0' as [IsPrimaryFile],
CASE when s.max_size=-1 then -1 else (s.max_size * CONVERT(float,8))/1024 END AS [MaxSize(MB)],
(s.size * CONVERT(float,8))/1024 AS [Size(MB)],
(tspclog.LogSize * tspclog.SpaceUsedPerc * 10.24)/1024 AS [UsedSpace(MB)],
((s.size * CONVERT(float,8))/1024 - (tspclog.LogSize * tspclog.SpaceUsedPerc * 10.24)/1024) 
AS [AvailableSpace(MB)],
s.state_desc AS [FileStatus],
CAST(case s.state when 6 then 1 else 0 end AS bit) AS [IsOffline],
s.is_read_only AS [IsReadOnly],
s.is_media_read_only AS [IsReadOnlyMedia],
s.is_sparse AS [IsSparse]
FROM master.sys.master_files AS s
INNER JOIN master.sys.databases sd ON sd.database_id=s.database_id
INNER JOIN #tmplogspc tspclog ON 
tspclog.DatabaseName = sd.name
WHERE (s.type = 1 ) ORDER BY sd.name, FileID ASC 
 
-- DROP THE TEMP TABLES
DROP TABLE #tmpspc
DROP TABLE #tmplogspc
END 
 
GO

-- exec dba_CapacityPlanning
=======
USE [msdb]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************************************************
Purpose        : Populate [tbl_CapacityPlanning] table in msdb database to keep Database &
files details for Capacity Planning and growth trends.
Author        : Deepak Kumar
Dependencies: None, SP is compatible for SQL Server 2005 onwards..                    
*******************************************************************************************/
CREATE PROC [dbo].[dba_CapacityPlanning]
AS
BEGIN
SET NOCOUNT ON
IF  NOT EXISTS (SELECT * FROM MSDB.sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[tbl_CapacityPlanning]') AND type in (N'U'))
BEGIN
CREATE TABLE [msdb].[dbo].[tbl_CapacityPlanning](
    [ExecuteTime] [datetime] NULL,
    [SQLBuild] [nvarchar](57) NULL,
    [SQLName] [nvarchar](128) NULL,
    [DBName] [sysname]  NULL,
    [LogicalFileName] [sysname]  NULL,
    [DBCreationDate] [datetime]  NULL,
    [DBRecoveryModel] [nvarchar](60) NULL,
    [DBCompatibilityLevel] [tinyint] NULL,
    [DBCollation] [sysname] NULL,
    [FileType] [nvarchar](60) NULL,
    [FileName] [nvarchar](260)  NULL,
    [Growth] [float] NULL,
    [GrowthType] [varchar](30) NULL,
    [FileID] [int]  NULL,
    [IsPrimaryFile] [bit] NULL,
    [MaxSize(MB)] [float] NULL,
    [Size(MB)] [float] NULL,
    [UsedSpace(MB)] [float] NULL,
    [AvailableSpace(MB)] [float] NULL,
    [FileStatus] [nvarchar](60) NULL,
    [IsOffline] [bit] NULL,
    [IsReadOnly] [bit] NOT NULL,
    [IsReadOnlyMedia] [bit]  NULL,
    [IsSparse] [bit]  NULL
) ON [PRIMARY]
END 
CREATE table #tmpspc (Fileid int, FileGroup int, TotalExtents int, 
UsedExtents int, Name sysname, FileName nchar(520)) 
DECLARE @DatabaseName varchar(500)
DECLARE curDB cursor for 
SELECT ltrim(rtrim(name))  from master.sys.databases where state_desc='ONLINE' 
AND user_access_desc='MULTI_USER'
open curDB
fetch curDB into @DatabaseName
while @@fetch_status = 0
begin
insert into #tmpspc exec ('USE [' + @DatabaseName + ']  DBCC SHOWFILESTATS')    
fetch curDB into @DatabaseName
end
close curDB
deallocate curDB 
 
create table #tmplogspc (DatabaseName sysname, LogSize float, SpaceUsedPerc float, Status bit)
insert #tmplogspc EXEC ('dbcc sqlperf(logspace)') 
 
insert into [msdb].[dbo].[tbl_CapacityPlanning] SELECT getdate() AS [ExecuteTime],
left(@@version,57) AS [SQLBuild], @@servername AS [SQLName],
sd.name AS [DBName],
s.name AS [LogicalFileName],
sd.create_date AS [DBCreationDate], sd.recovery_model_desc AS [DBRecoveryModel], 
sd.compatibility_level AS [DBCompatibilityLevel], sd.collation_name AS [DBCollation],
s.type_desc AS [FileType],
s.physical_name AS [FileName],
CAST(CASE s.is_percent_growth WHEN 1 THEN s.growth ELSE (s.growth*8)/1024 END AS float) AS [Growth],
CAST(CASE WHEN s.is_percent_growth=1  THEN '%' Else 'MB' END AS VARCHAR) AS [GrowthType],
s.file_id AS [FileID],
CAST(CASE s.file_id WHEN 1 THEN 1 ELSE 0 END AS bit) AS [IsPrimaryFile],
CASE when s.max_size=-1 then -1 else (s.max_size * CONVERT(float,8))/1024 END AS [MaxSize(MB)],
(s.size * CONVERT(float,8))/1024 AS [Size(MB)],
(CAST(tspc.UsedExtents*convert(float,64) AS float))/1024 AS [UsedSpace(MB)],
((tspc.TotalExtents - tspc.UsedExtents)*convert(float,64))/1024 AS [AvailableSpace(MB)],
s.state_desc AS [FileStatus],
CAST(case s.state when 6 then 1 else 0 end AS bit) AS [IsOffline],
s.is_read_only AS [IsReadOnly],
s.is_media_read_only AS [IsReadOnlyMedia],
s.is_sparse AS [IsSparse]
FROM master.sys.master_files AS s 
INNER JOIN master.sys.databases sd ON sd.database_id=s.database_id
INNER JOIN #tmpspc tspc ON ltrim(rtrim(tspc.FileName)) = ltrim(rtrim(s.physical_name))
UNION ALL
SELECT getdate() AS [ExecuteTime],left(@@version,57) AS [SQLBuild], @@servername AS [SQLName],
sd.name AS [DBName],
s.name AS [LogicalName],
sd.create_date AS [DBCreationDate], sd.recovery_model_desc AS [DBRecoveryModel], 
sd.compatibility_level AS [DBCompatibilityLevel], sd.collation_name AS [DBCollation],
s.type_desc AS [FileType],
s.physical_name AS [FileName],
CAST(CASE s.is_percent_growth WHEN 1 THEN s.growth ELSE (s.growth*8)/1024 END AS float) AS [Growth],
CAST(CASE WHEN s.is_percent_growth=1  THEN '%' Else 'MB' END AS VARCHAR) AS [GrowthType],
s.file_id AS [FileID],
'0' as [IsPrimaryFile],
CASE when s.max_size=-1 then -1 else (s.max_size * CONVERT(float,8))/1024 END AS [MaxSize(MB)],
(s.size * CONVERT(float,8))/1024 AS [Size(MB)],
(tspclog.LogSize * tspclog.SpaceUsedPerc * 10.24)/1024 AS [UsedSpace(MB)],
((s.size * CONVERT(float,8))/1024 - (tspclog.LogSize * tspclog.SpaceUsedPerc * 10.24)/1024) 
AS [AvailableSpace(MB)],
s.state_desc AS [FileStatus],
CAST(case s.state when 6 then 1 else 0 end AS bit) AS [IsOffline],
s.is_read_only AS [IsReadOnly],
s.is_media_read_only AS [IsReadOnlyMedia],
s.is_sparse AS [IsSparse]
FROM master.sys.master_files AS s
INNER JOIN master.sys.databases sd ON sd.database_id=s.database_id
INNER JOIN #tmplogspc tspclog ON 
tspclog.DatabaseName = sd.name
WHERE (s.type = 1 ) ORDER BY sd.name, FileID ASC 
 
-- DROP THE TEMP TABLES
DROP TABLE #tmpspc
DROP TABLE #tmplogspc
END 
 
GO

-- exec dba_CapacityPlanning
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
-- select * from msdb..tbl_CapacityPlanning 