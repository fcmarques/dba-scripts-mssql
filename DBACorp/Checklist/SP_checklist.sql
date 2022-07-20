<<<<<<< HEAD
/*
sp_configure 'show advanced options', 1;
GO
sp_configure 'Ole Automation Procedures', 1;
GO
EXEC sp_configure 'xp_cmdshell', 1
GO
RECONFIGURE;
GO
*/

USE [master]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SP_checklist]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SP_checklist]
GO

/****** Object:  StoredProcedure [dbo].[SP_checklist]    Script Date: 18/12/2013 14:17:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[SP_checklist]        
as        
set nocount on          
  
print'                '  
print'                '  
print'======================================'  
print'SERVIDOR - ' +@@servername  
print'======================================'  
  
  
CREATE TABLE [dbo].#tbCOUNT(          
 [CPUBusyPct] [numeric](31, 15) NULL,          
 [Total Memory_GB] [numeric](32, 12) NULL,          
 [SQLServer Memory_GB] [numeric](29, 9) NULL          
) ON [PRIMARY]          
          
DECLARE          
  @CPU_BUSY int          
  , @IO_BUSY int          
  , @IDLE int          
DECLARE @PG_SIZE INT          
  , @INSTANCENAME VARCHAR(50)          
  , @count int           
set @count =0           
          
  SELECT          
  @CPU_BUSY = @@CPU_BUSY          
  , @IDLE = @@IDLE          
SELECT @pg_size = low from master..spt_values where number = 1 and type = 'E'          
          
WHILE @count < 20            
          
 BEGIN          
          
  SELECT          
    @IO_BUSY = @@IO_BUSY          
    WAITFOR DELAY '00:00:00:500'          
  INSERT INTO #tbCOUNT (CPUBusyPct,[Total Memory_GB],[SQLServer Memory_GB])            
  SELECT          
    CONVERT(CHAR,((@@CPU_BUSY - @CPU_BUSY)/((@@IDLE - @IDLE + @@CPU_BUSY - @CPU_BUSY) * 1.00) *100),10) AS CPUBusyPct          
  ,(SELECT physical_memory_in_bytes/1073741824.0 as [Total Memory_GB]          
   FROM sys.dm_os_sys_info)[Total Memory_GB]          
  ,(SELECT (cntr_value/1048576.0) as [SQLServer Memory_GB]           
   FROM sys.dm_os_performance_counters           
  WHERE counter_name = 'Target Server Memory (KB)') [SQLServer Memory_GB]          
          
 SET @count = @count+1          
 END          
        
print '                      '        
print '                      '        
print '=================================================================================='        
print 'COUNTERS'        
print '=================================================================================='        
print '                      '        
        
select  left(avg([CPUBusyPct]),18) as [CPUBusyPct],         
  left(avg([Total Memory_GB]),18)as [Total Memory_GB],         
  left(avg([SQLServer Memory_GB]),18)as [SQLServer Memory_GB]        
from #tbCOUNT        
        
Drop table #tbCOUNT        
        
        
--VERIFICAR ESPACO EM DISCO          
--SELECT 'VERIFICAR ESPACO EM DISCO'          
/*BEGIN          
          
create table #disk_details          
(          
 drive nvarchar(10)          
 ,[MB Free] numeric          
)          
          
 insert into #disk_details (drive, [MB Free])          
  exec master.dbo.xp_fixeddrives          
          
          
END*/          
        
set nocount on           
DECLARE @counter SMALLINT          
DECLARE @dbname VARCHAR(100)          
DECLARE @db_bkpdate varchar(100)          
DECLARE @status varchar(20)          
-- DECLARE @svr_name varchar(100)          
DECLARE @media_set_id varchar(20)          
DECLARE @filepath VARCHAR(1000)          
Declare @filestatus int          
DECLARE @fileavailable varchar(20)          
DECLARE @BACKUPSIZE float          
          
SELECT @counter=MAX(dbid) FROM master..sysdatabases          
-- CREATE TABLE #backup_details (ServerName varchar(100),DatabaseName varchar(100),BkpDate varchar(20) NULL,BackupSize_in_MB varchar(20),Status varchar(20),FilePath varchar(1000),FileAvailable varchar(20))          
CREATE TABLE #backup_details (DatabaseName varchar(100),BkpDate varchar(20) NULL,BackupSize_in_MB varchar(16),Status varchar(20),FilePath varchar(1000),FileAvailable varchar(20))          
-- select @svr_name = CAST(SERVERPROPERTY('ServerName')AS sysname)          
WHILE @counter > 0          
BEGIN          
/* Need to re-initialize all variables*/          
Select @dbName = null , @db_bkpdate = null ,          
@media_set_id = Null , @backupsize = Null ,          
@filepath = Null , @filestatus = Null ,           
@fileavailable = Null , @status = Null , @backupsize = Null          
          
select @dbname = name from master..sysdatabases where dbid = @counter          
select @db_bkpdate = max(backup_start_date) from msdb..backupset where database_name = @dbname and type='D'          
select @media_set_id = media_set_id from msdb..backupset where backup_start_date = ( select max(backup_start_date) from msdb..backupset where database_name = @dbname and type='D')          
select @backupsize = backup_size from msdb..backupset where backup_start_date = ( select max(backup_start_date) from msdb..backupset where database_name = @dbname and type='D')          
select @filepath = physical_device_name from msdb..backupmediafamily where media_set_id = @media_set_id          
EXEC master..xp_fileexist @filepath , @filestatus out          
if @filestatus = 1          
set @fileavailable = 'Available'          
else          
set @fileavailable = 'NOT Available'          
if (datediff(day,@db_bkpdate,getdate()) > 7)          
set @status = 'Warning'          
else          
set @status = 'Healthy'          
set @backupsize = (@backupsize/1024)/1024          
insert into #backup_details select @dbname,@db_bkpdate,@backupsize,@status,@filepath,@fileavailable          
-- insert into #backup_details select @svr_name,@dbname,@db_bkpdate,@backupsize,@status,@filepath,@fileavailable          
update #backup_details          
set status = 'Warning' where bkpdate IS NULL          
set @counter = @counter - 1          
END          
        
print '                      '        
print '=================================================================================='        
print 'BACKUP DETAILS'        
print '=================================================================================='        
print '                      '        
        
select CONVERT(CHAR,left(DatabaseName,32),20) as DatabaseName
,CONVERT(CHAR,databasepropertyex(DatabaseName,'STATUS'),10) as DatabaseStatus 
,CONVERT(CHAR,BkpDate,12) as BkpDate  
,CONVERT(CHAR,BackupSize_in_MB,20)as BackupSize_in_MB , CONVERT(CHAR,left(Status,10),10) as Status   
,CONVERT(CHAR,left(FilePath,30),30) as FilePath
,left(FileAvailable,13)        
 from #backup_details where databasename not in ('tempdb','northwind','pubs') order by BkpDate desc          
drop table #backup_details          
        
print '                      '        
print '=================================================================================='        
print 'JOB DETAILS'        
print '=================================================================================='        
print '                      '        
        
SELECT           
      left(j.name,30) as [Nome do Job],          
      CONVERT(CHAR(10), CAST(STR(h.run_date,8, 0) AS dateTIME), 105) as [Data da Execução],          
      STUFF(STUFF(RIGHT('000000' + CAST ( h.run_time AS VARCHAR(6 ) ) ,6),5,0,':'),3,0,':') as [Hora Execução],          
      h.run_duration [Tempo (ss)],          
      case h.run_status when 0 then 'Falha'          
            when 2 then 'Retry'          
            when 3 then 'Cancelado pelo usuário'          
            when 4 then 'Em execução'          
      end as [Status]          
 ,h.run_date        
FROM           
      msdb.dbo.sysjobhistory h           
      inner join msdb.dbo.sysjobs j ON j.job_id = h.job_id          
WHERE h.run_status<>1 and h.step_id=0          
and convert(int,h.run_date) >= convert(int,convert(nvarchar(8),getdate()-1,112))          
ORDER BY           
      j.name,           
      h.run_date,           
      h.run_time          
  
print '                      '        
print '=================================================================================='        
print 'MAINTENANCE PLAN DETAILS'        
print '=================================================================================='        
print '                      '        
        
SELECT   
   convert(char(30),left(isnull(J.name,''),30)) as Job_name  
 , convert(char(20),convert(nvarchar(20),isnull(L.start_time,''))) as date_exec  
 , convert(char(20),left(isnull(D.line1,''),30)) as step  
 , convert(char(215),left(isnull(replace(replace(D.[error_message],'"',''),'''',''),''),205)) as error_message  
INTO #maintenance_plans  
FROM  msdb.dbo.sysmaintplan_subplans S  
 , msdb.dbo.sysmaintplan_log L  
 , msdb.dbo.sysmaintplan_logdetail D  
 , msdb.dbo.sysjobs J  
WHERE S.subplan_id = L.subplan_id  
 and D.task_detail_id = L.task_detail_id  
 and S.job_id = J.job_id  
 and L.succeeded <> 1  
 and L.start_time > (getdate()-3)          
 and D.succeeded <> 1   
ORDER BY           
      J.name,  
   S.subplan_name,  
   L.start_time  
  
select distinct * from #maintenance_plans  
--SPACEDISK          
          
DECLARE @hr int             
DECLARE @fso int             
DECLARE @drive char(1)             
DECLARE @odrive int             
DECLARE @TotalSize varchar(20)             
DECLARE @MB bigint ; SET @MB = 1048576             
            
CREATE TABLE #drives (drive char(1) PRIMARY KEY,             
                      FreeSpace int NULL,             
                      TotalSize int NULL)             
            
INSERT #drives(drive,FreeSpace)             
EXEC master.dbo.xp_fixeddrives             
            
EXEC @hr=sp_OACreate 'Scripting.FileSystemObject',@fso OUT             
IF @hr <> 0 EXEC sp_OAGetErrorInfo @fso             
            
DECLARE dcur CURSOR LOCAL FAST_FORWARD             
FOR SELECT drive from #drives             
ORDER by drive             
            
OPEN dcur             
            
FETCH NEXT FROM dcur INTO @drive             
            
WHILE @@FETCH_STATUS=0             
BEGIN             
            
        EXEC @hr = sp_OAMethod @fso,'GetDrive', @odrive OUT, @drive             
        IF @hr <> 0 EXEC sp_OAGetErrorInfo @fso             
        EXEC @hr = sp_OAGetProperty @odrive,'TotalSize', @TotalSize OUT             
        IF @hr <> 0 EXEC sp_OAGetErrorInfo @odrive             
        UPDATE #drives             
        SET TotalSize=@TotalSize/@MB             
        WHERE drive=@drive             
        FETCH NEXT FROM dcur INTO @drive             
            
END             
            
CLOSE dcur             
DEALLOCATE dcur             
            
EXEC @hr=sp_OADestroy @fso             
IF @hr <> 0 EXEC sp_OAGetErrorInfo @fso             
            
if exists( select 1 FROM #drives             
   where CAST((FreeSpace/(TotalSize*1.0))*100.0 as int) <= 99            
   and drive not in ('M','Q') )              
begin          
        
print '                      '        
print '=================================================================================='        
print 'DISK DETAILS'        
print '=================================================================================='        
print '                      '          
             
SELECT Drive,             
       FreeSpace as 'Livre(MB)',             
       TotalSize as 'Total(MB)',             
       CAST((FreeSpace/(TotalSize*1.0))*100.0 as int) as 'Livre(%)'             
FROM #drives             
where CAST((FreeSpace/(TotalSize*1.0))*100.0 as int) <= 99            
and drive not in ('M','Q')            
ORDER BY drive             
          
end            
            
        
--LOGS DO SQL SERVER       
--SELECT 'LOGS DO SQL SERVER'       
BEGIN       
       
       create table #xp_readerrorlog (LogDate datetime, ProcessInfo nvarchar(128 ), Text nvarchar( max))

       --SE FOR SEGUNDA COLETA DE SEXTA, SÁBADO E DOMINGO
       declare @Time_Start datetime

       IF ( DATEPART(weekday , GETDATE ()) = 2)
       BEGIN
             set @time_start=( getdate()-3 )
       END
       ELSE
       BEGIN
             set @time_start=( getdate()-1 )
       END

       insert into #xp_readerrorlog (LogDate , ProcessInfo, Text)
             exec xp_readerrorlog 0, 1, '', '', @Time_Start
       insert into #xp_readerrorlog (LogDate , ProcessInfo, Text)
             exec xp_readerrorlog 1, 1, '', '', @Time_Start ;
       insert into #xp_readerrorlog (LogDate , ProcessInfo, Text)
             exec xp_readerrorlog 2, 1, '', '', @Time_Start ;
       insert into #xp_readerrorlog (LogDate , ProcessInfo, Text)
             exec xp_readerrorlog 3, 1, '', '', @Time_Start ;

       SELECT q1. Text, q1 .Ocorrencias INTO #xp_readerrorlog_2
       FROM
       (
             SELECT Text ,
                     Count(*) Ocorrencias
             FROM   #xp_readerrorlog
             WHERE  Text LIKE '%Login failed%'
                     AND LogDate >= @time_start
             GROUP  BY Text
             UNION ALL
             SELECT Text ,
               Count(*) Ocorrencias
             FROM   #xp_readerrorlog
             WHERE  Text NOT LIKE '%Login failed%'
                     AND Text NOT LIKE '%Error: 18456%'
                     AND Text NOT LIKE '%backed up%'
                     AND Text NOT LIKE '%found 0 errors and repaired 0 errors%'
                     AND Text NOT LIKE '%Login succeeded%'
                     AND Text NOT LIKE '%finished without errors%'
                     AND Text NOT LIKE '%Logging SQL Server messages in file%'
                     AND Text NOT LIKE '%This instance of SQL Server has been using a process ID%'
                     AND Text NOT LIKE '%The error log has been reinitialized%'
                     AND Text NOT LIKE '%Starting up database%'
                     AND Text NOT LIKE '%(c) 2005 Microsoft Corporation.%'
                     AND Text NOT LIKE '%All rights reserved.%'
                     AND Text NOT LIKE '%Authentication mode is MIXED.%'
                     AND Text NOT LIKE '%The database ''model4IDR'' is marked RESTORING%'
                     AND Text NOT LIKE '%Database was restored: Database: model4IDR%'
                     AND Text NOT LIKE '%The database ''master4IDR'' is marked RESTORING%'
                     AND Text NOT LIKE '%Database was restored: Database: master4IDR%'
                     AND Text NOT LIKE '%Microsoft SQL Server 20%'
                     AND Text NOT LIKE '%Server process ID%'
                     AND Text NOT LIKE '%(part of plan cache)%'
					 AND Text NOT LIKE '%Setting database option%'
					 AND Text NOT LIKE '%Attempting to cycle error log%'
					 AND Text NOT LIKE '%Changing the status to%'
                     AND LogDate >= @time_start
             GROUP  BY Text
       )q1
       ORDER BY q1.Ocorrencias desc

END       

print '                      '        
print '=================================================================================='        
print 'ERRORLOG'        
print '=================================================================================='        
print '                      '          
       
SELECT convert (char( 265),LEFT(Isnull ([Text], ''), 265))       AS [Text],
       convert(char (10),LEFT( Isnull([Ocorrencias] , '' ), 10)) AS [Ocorrencias]
FROM   #xp_readerrorlog_2       
       
drop table #xp_readerrorlog
drop table #xp_readerrorlog_2

print '                      '        
print '=================================================================================='        
print 'EVENT VIEWER - APPLICATION'        
print '=================================================================================='        
print '                      '        
        
declare @dateevent varchar(10)          
declare @query varchar(500)          
declare @querySSystem varchar(500)          
select @dateevent= CONVERT(VARCHAR(10), DATEADD(day,-2,GETDATE()), 101)          
         
create table #tb(event varchar(5000))          
set @query = 'C:\Windows\system32\cscript eventquery.vbs /l Application /fi "Datetime gt '+convert(varchar,@dateevent)+',12:00:00AM"'          
insert into #tb          
exec xp_cmdshell @query-- /fi "Type eq warning" /fi "Type eq warning"'           
          
select  top 20          
        left(isnull(event,''),82) as Event           
     from #tb where  (event like '% AM %'  or  event like '% PM %')          
       and  (event like '%Error%' or event like '%Warning%')  
       
print ''        
print '                      '        
print '=================================================================================='        
print 'EVENT VIEWER - SYSTEM'        
print '=================================================================================='        
print '                      '        
        
create table #tb_System(event varchar(5000))          
set @querySSystem = 'C:\Windows\system32\cscript eventquery.vbs /l System /fi "Datetime gt '+convert(varchar,@dateevent)+',12:00:00AM"'          
insert into #tb_System          
exec xp_cmdshell @querySSystem-- /fi "Type eq warning" /fi "Type eq warning"'           
         
 select  top 20         
       left(isnull(event,'NULL'),82) as Event        
    from #tb_System where  (event like '% AM %'  or  event like '% PM %')          
           and  (event like '%Error%' or event like '%Warning%')          
        
print '                      '        
DROP TABLE #tb      
DROP TABLE #drives             
DROP TABLE #tb_System   
  
print ''        
print '                      '        
print '=================================================================================='        
print 'MEMORY DUMP INFO'        
print '=================================================================================='        
print '                      '        

SELECT left([filename],100), creation_time, size_in_bytes/1048576.0 AS [Size (MB)]
FROM sys.dm_server_memory_dumps WITH (NOLOCK) 
ORDER BY creation_time DESC OPTION (RECOMPILE);
          
GO

=======
/*
sp_configure 'show advanced options', 1;
GO
sp_configure 'Ole Automation Procedures', 1;
GO
EXEC sp_configure 'xp_cmdshell', 1
GO
RECONFIGURE;
GO
*/

USE [master]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SP_checklist]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SP_checklist]
GO

/****** Object:  StoredProcedure [dbo].[SP_checklist]    Script Date: 18/12/2013 14:17:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[SP_checklist]        
as        
set nocount on          
  
print'                '  
print'                '  
print'======================================'  
print'SERVIDOR - ' +@@servername  
print'======================================'  
  
  
CREATE TABLE [dbo].#tbCOUNT(          
 [CPUBusyPct] [numeric](31, 15) NULL,          
 [Total Memory_GB] [numeric](32, 12) NULL,          
 [SQLServer Memory_GB] [numeric](29, 9) NULL          
) ON [PRIMARY]          
          
DECLARE          
  @CPU_BUSY int          
  , @IO_BUSY int          
  , @IDLE int          
DECLARE @PG_SIZE INT          
  , @INSTANCENAME VARCHAR(50)          
  , @count int           
set @count =0           
          
  SELECT          
  @CPU_BUSY = @@CPU_BUSY          
  , @IDLE = @@IDLE          
SELECT @pg_size = low from master..spt_values where number = 1 and type = 'E'          
          
WHILE @count < 20            
          
 BEGIN          
          
  SELECT          
    @IO_BUSY = @@IO_BUSY          
    WAITFOR DELAY '00:00:00:500'          
  INSERT INTO #tbCOUNT (CPUBusyPct,[Total Memory_GB],[SQLServer Memory_GB])            
  SELECT          
    CONVERT(CHAR,((@@CPU_BUSY - @CPU_BUSY)/((@@IDLE - @IDLE + @@CPU_BUSY - @CPU_BUSY) * 1.00) *100),10) AS CPUBusyPct          
  ,(SELECT physical_memory_in_bytes/1073741824.0 as [Total Memory_GB]          
   FROM sys.dm_os_sys_info)[Total Memory_GB]          
  ,(SELECT (cntr_value/1048576.0) as [SQLServer Memory_GB]           
   FROM sys.dm_os_performance_counters           
  WHERE counter_name = 'Target Server Memory (KB)') [SQLServer Memory_GB]          
          
 SET @count = @count+1          
 END          
        
print '                      '        
print '                      '        
print '=================================================================================='        
print 'COUNTERS'        
print '=================================================================================='        
print '                      '        
        
select  left(avg([CPUBusyPct]),18) as [CPUBusyPct],         
  left(avg([Total Memory_GB]),18)as [Total Memory_GB],         
  left(avg([SQLServer Memory_GB]),18)as [SQLServer Memory_GB]        
from #tbCOUNT        
        
Drop table #tbCOUNT        
        
        
--VERIFICAR ESPACO EM DISCO          
--SELECT 'VERIFICAR ESPACO EM DISCO'          
/*BEGIN          
          
create table #disk_details          
(          
 drive nvarchar(10)          
 ,[MB Free] numeric          
)          
          
 insert into #disk_details (drive, [MB Free])          
  exec master.dbo.xp_fixeddrives          
          
          
END*/          
        
set nocount on           
DECLARE @counter SMALLINT          
DECLARE @dbname VARCHAR(100)          
DECLARE @db_bkpdate varchar(100)          
DECLARE @status varchar(20)          
-- DECLARE @svr_name varchar(100)          
DECLARE @media_set_id varchar(20)          
DECLARE @filepath VARCHAR(1000)          
Declare @filestatus int          
DECLARE @fileavailable varchar(20)          
DECLARE @BACKUPSIZE float          
          
SELECT @counter=MAX(dbid) FROM master..sysdatabases          
-- CREATE TABLE #backup_details (ServerName varchar(100),DatabaseName varchar(100),BkpDate varchar(20) NULL,BackupSize_in_MB varchar(20),Status varchar(20),FilePath varchar(1000),FileAvailable varchar(20))          
CREATE TABLE #backup_details (DatabaseName varchar(100),BkpDate varchar(20) NULL,BackupSize_in_MB varchar(16),Status varchar(20),FilePath varchar(1000),FileAvailable varchar(20))          
-- select @svr_name = CAST(SERVERPROPERTY('ServerName')AS sysname)          
WHILE @counter > 0          
BEGIN          
/* Need to re-initialize all variables*/          
Select @dbName = null , @db_bkpdate = null ,          
@media_set_id = Null , @backupsize = Null ,          
@filepath = Null , @filestatus = Null ,           
@fileavailable = Null , @status = Null , @backupsize = Null          
          
select @dbname = name from master..sysdatabases where dbid = @counter          
select @db_bkpdate = max(backup_start_date) from msdb..backupset where database_name = @dbname and type='D'          
select @media_set_id = media_set_id from msdb..backupset where backup_start_date = ( select max(backup_start_date) from msdb..backupset where database_name = @dbname and type='D')          
select @backupsize = backup_size from msdb..backupset where backup_start_date = ( select max(backup_start_date) from msdb..backupset where database_name = @dbname and type='D')          
select @filepath = physical_device_name from msdb..backupmediafamily where media_set_id = @media_set_id          
EXEC master..xp_fileexist @filepath , @filestatus out          
if @filestatus = 1          
set @fileavailable = 'Available'          
else          
set @fileavailable = 'NOT Available'          
if (datediff(day,@db_bkpdate,getdate()) > 7)          
set @status = 'Warning'          
else          
set @status = 'Healthy'          
set @backupsize = (@backupsize/1024)/1024          
insert into #backup_details select @dbname,@db_bkpdate,@backupsize,@status,@filepath,@fileavailable          
-- insert into #backup_details select @svr_name,@dbname,@db_bkpdate,@backupsize,@status,@filepath,@fileavailable          
update #backup_details          
set status = 'Warning' where bkpdate IS NULL          
set @counter = @counter - 1          
END          
        
print '                      '        
print '=================================================================================='        
print 'BACKUP DETAILS'        
print '=================================================================================='        
print '                      '        
        
select CONVERT(CHAR,left(DatabaseName,32),20) as DatabaseName
,CONVERT(CHAR,databasepropertyex(DatabaseName,'STATUS'),10) as DatabaseStatus 
,CONVERT(CHAR,BkpDate,12) as BkpDate  
,CONVERT(CHAR,BackupSize_in_MB,20)as BackupSize_in_MB , CONVERT(CHAR,left(Status,10),10) as Status   
,CONVERT(CHAR,left(FilePath,30),30) as FilePath
,left(FileAvailable,13)        
 from #backup_details where databasename not in ('tempdb','northwind','pubs') order by BkpDate desc          
drop table #backup_details          
        
print '                      '        
print '=================================================================================='        
print 'JOB DETAILS'        
print '=================================================================================='        
print '                      '        
        
SELECT           
      left(j.name,30) as [Nome do Job],          
      CONVERT(CHAR(10), CAST(STR(h.run_date,8, 0) AS dateTIME), 105) as [Data da Execução],          
      STUFF(STUFF(RIGHT('000000' + CAST ( h.run_time AS VARCHAR(6 ) ) ,6),5,0,':'),3,0,':') as [Hora Execução],          
      h.run_duration [Tempo (ss)],          
      case h.run_status when 0 then 'Falha'          
            when 2 then 'Retry'          
            when 3 then 'Cancelado pelo usuário'          
            when 4 then 'Em execução'          
      end as [Status]          
 ,h.run_date        
FROM           
      msdb.dbo.sysjobhistory h           
      inner join msdb.dbo.sysjobs j ON j.job_id = h.job_id          
WHERE h.run_status<>1 and h.step_id=0          
and convert(int,h.run_date) >= convert(int,convert(nvarchar(8),getdate()-1,112))          
ORDER BY           
      j.name,           
      h.run_date,           
      h.run_time          
  
print '                      '        
print '=================================================================================='        
print 'MAINTENANCE PLAN DETAILS'        
print '=================================================================================='        
print '                      '        
        
SELECT   
   convert(char(30),left(isnull(J.name,''),30)) as Job_name  
 , convert(char(20),convert(nvarchar(20),isnull(L.start_time,''))) as date_exec  
 , convert(char(20),left(isnull(D.line1,''),30)) as step  
 , convert(char(215),left(isnull(replace(replace(D.[error_message],'"',''),'''',''),''),205)) as error_message  
INTO #maintenance_plans  
FROM  msdb.dbo.sysmaintplan_subplans S  
 , msdb.dbo.sysmaintplan_log L  
 , msdb.dbo.sysmaintplan_logdetail D  
 , msdb.dbo.sysjobs J  
WHERE S.subplan_id = L.subplan_id  
 and D.task_detail_id = L.task_detail_id  
 and S.job_id = J.job_id  
 and L.succeeded <> 1  
 and L.start_time > (getdate()-3)          
 and D.succeeded <> 1   
ORDER BY           
      J.name,  
   S.subplan_name,  
   L.start_time  
  
select distinct * from #maintenance_plans  
--SPACEDISK          
          
DECLARE @hr int             
DECLARE @fso int             
DECLARE @drive char(1)             
DECLARE @odrive int             
DECLARE @TotalSize varchar(20)             
DECLARE @MB bigint ; SET @MB = 1048576             
            
CREATE TABLE #drives (drive char(1) PRIMARY KEY,             
                      FreeSpace int NULL,             
                      TotalSize int NULL)             
            
INSERT #drives(drive,FreeSpace)             
EXEC master.dbo.xp_fixeddrives             
            
EXEC @hr=sp_OACreate 'Scripting.FileSystemObject',@fso OUT             
IF @hr <> 0 EXEC sp_OAGetErrorInfo @fso             
            
DECLARE dcur CURSOR LOCAL FAST_FORWARD             
FOR SELECT drive from #drives             
ORDER by drive             
            
OPEN dcur             
            
FETCH NEXT FROM dcur INTO @drive             
            
WHILE @@FETCH_STATUS=0             
BEGIN             
            
        EXEC @hr = sp_OAMethod @fso,'GetDrive', @odrive OUT, @drive             
        IF @hr <> 0 EXEC sp_OAGetErrorInfo @fso             
        EXEC @hr = sp_OAGetProperty @odrive,'TotalSize', @TotalSize OUT             
        IF @hr <> 0 EXEC sp_OAGetErrorInfo @odrive             
        UPDATE #drives             
        SET TotalSize=@TotalSize/@MB             
        WHERE drive=@drive             
        FETCH NEXT FROM dcur INTO @drive             
            
END             
            
CLOSE dcur             
DEALLOCATE dcur             
            
EXEC @hr=sp_OADestroy @fso             
IF @hr <> 0 EXEC sp_OAGetErrorInfo @fso             
            
if exists( select 1 FROM #drives             
   where CAST((FreeSpace/(TotalSize*1.0))*100.0 as int) <= 99            
   and drive not in ('M','Q') )              
begin          
        
print '                      '        
print '=================================================================================='        
print 'DISK DETAILS'        
print '=================================================================================='        
print '                      '          
             
SELECT Drive,             
       FreeSpace as 'Livre(MB)',             
       TotalSize as 'Total(MB)',             
       CAST((FreeSpace/(TotalSize*1.0))*100.0 as int) as 'Livre(%)'             
FROM #drives             
where CAST((FreeSpace/(TotalSize*1.0))*100.0 as int) <= 99            
and drive not in ('M','Q')            
ORDER BY drive             
          
end            
            
        
--LOGS DO SQL SERVER       
--SELECT 'LOGS DO SQL SERVER'       
BEGIN       
       
       create table #xp_readerrorlog (LogDate datetime, ProcessInfo nvarchar(128 ), Text nvarchar( max))

       --SE FOR SEGUNDA COLETA DE SEXTA, SÁBADO E DOMINGO
       declare @Time_Start datetime

       IF ( DATEPART(weekday , GETDATE ()) = 2)
       BEGIN
             set @time_start=( getdate()-3 )
       END
       ELSE
       BEGIN
             set @time_start=( getdate()-1 )
       END

       insert into #xp_readerrorlog (LogDate , ProcessInfo, Text)
             exec xp_readerrorlog 0, 1, '', '', @Time_Start
       insert into #xp_readerrorlog (LogDate , ProcessInfo, Text)
             exec xp_readerrorlog 1, 1, '', '', @Time_Start ;
       insert into #xp_readerrorlog (LogDate , ProcessInfo, Text)
             exec xp_readerrorlog 2, 1, '', '', @Time_Start ;
       insert into #xp_readerrorlog (LogDate , ProcessInfo, Text)
             exec xp_readerrorlog 3, 1, '', '', @Time_Start ;

       SELECT q1. Text, q1 .Ocorrencias INTO #xp_readerrorlog_2
       FROM
       (
             SELECT Text ,
                     Count(*) Ocorrencias
             FROM   #xp_readerrorlog
             WHERE  Text LIKE '%Login failed%'
                     AND LogDate >= @time_start
             GROUP  BY Text
             UNION ALL
             SELECT Text ,
               Count(*) Ocorrencias
             FROM   #xp_readerrorlog
             WHERE  Text NOT LIKE '%Login failed%'
                     AND Text NOT LIKE '%Error: 18456%'
                     AND Text NOT LIKE '%backed up%'
                     AND Text NOT LIKE '%found 0 errors and repaired 0 errors%'
                     AND Text NOT LIKE '%Login succeeded%'
                     AND Text NOT LIKE '%finished without errors%'
                     AND Text NOT LIKE '%Logging SQL Server messages in file%'
                     AND Text NOT LIKE '%This instance of SQL Server has been using a process ID%'
                     AND Text NOT LIKE '%The error log has been reinitialized%'
                     AND Text NOT LIKE '%Starting up database%'
                     AND Text NOT LIKE '%(c) 2005 Microsoft Corporation.%'
                     AND Text NOT LIKE '%All rights reserved.%'
                     AND Text NOT LIKE '%Authentication mode is MIXED.%'
                     AND Text NOT LIKE '%The database ''model4IDR'' is marked RESTORING%'
                     AND Text NOT LIKE '%Database was restored: Database: model4IDR%'
                     AND Text NOT LIKE '%The database ''master4IDR'' is marked RESTORING%'
                     AND Text NOT LIKE '%Database was restored: Database: master4IDR%'
                     AND Text NOT LIKE '%Microsoft SQL Server 20%'
                     AND Text NOT LIKE '%Server process ID%'
                     AND Text NOT LIKE '%(part of plan cache)%'
					 AND Text NOT LIKE '%Setting database option%'
					 AND Text NOT LIKE '%Attempting to cycle error log%'
					 AND Text NOT LIKE '%Changing the status to%'
                     AND LogDate >= @time_start
             GROUP  BY Text
       )q1
       ORDER BY q1.Ocorrencias desc

END       

print '                      '        
print '=================================================================================='        
print 'ERRORLOG'        
print '=================================================================================='        
print '                      '          
       
SELECT convert (char( 265),LEFT(Isnull ([Text], ''), 265))       AS [Text],
       convert(char (10),LEFT( Isnull([Ocorrencias] , '' ), 10)) AS [Ocorrencias]
FROM   #xp_readerrorlog_2       
       
drop table #xp_readerrorlog
drop table #xp_readerrorlog_2

print '                      '        
print '=================================================================================='        
print 'EVENT VIEWER - APPLICATION'        
print '=================================================================================='        
print '                      '        
        
declare @dateevent varchar(10)          
declare @query varchar(500)          
declare @querySSystem varchar(500)          
select @dateevent= CONVERT(VARCHAR(10), DATEADD(day,-2,GETDATE()), 101)          
         
create table #tb(event varchar(5000))          
set @query = 'C:\Windows\system32\cscript eventquery.vbs /l Application /fi "Datetime gt '+convert(varchar,@dateevent)+',12:00:00AM"'          
insert into #tb          
exec xp_cmdshell @query-- /fi "Type eq warning" /fi "Type eq warning"'           
          
select  top 20          
        left(isnull(event,''),82) as Event           
     from #tb where  (event like '% AM %'  or  event like '% PM %')          
       and  (event like '%Error%' or event like '%Warning%')  
       
print ''        
print '                      '        
print '=================================================================================='        
print 'EVENT VIEWER - SYSTEM'        
print '=================================================================================='        
print '                      '        
        
create table #tb_System(event varchar(5000))          
set @querySSystem = 'C:\Windows\system32\cscript eventquery.vbs /l System /fi "Datetime gt '+convert(varchar,@dateevent)+',12:00:00AM"'          
insert into #tb_System          
exec xp_cmdshell @querySSystem-- /fi "Type eq warning" /fi "Type eq warning"'           
         
 select  top 20         
       left(isnull(event,'NULL'),82) as Event        
    from #tb_System where  (event like '% AM %'  or  event like '% PM %')          
           and  (event like '%Error%' or event like '%Warning%')          
        
print '                      '        
DROP TABLE #tb      
DROP TABLE #drives             
DROP TABLE #tb_System   
  
print ''        
print '                      '        
print '=================================================================================='        
print 'MEMORY DUMP INFO'        
print '=================================================================================='        
print '                      '        

SELECT left([filename],100), creation_time, size_in_bytes/1048576.0 AS [Size (MB)]
FROM sys.dm_server_memory_dumps WITH (NOLOCK) 
ORDER BY creation_time DESC OPTION (RECOMPILE);
          
GO

>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
