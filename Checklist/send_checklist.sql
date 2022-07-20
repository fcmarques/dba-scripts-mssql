<<<<<<< HEAD
------------------------------------------------------------
-- Object        : send_checklist
-- Object Type   : Stored Procedure
-- Produced By   : DBACorp  
-- URL           : www.dbacorp.com.br
-- Author        : Fabio Marques
-- Date          : 06-Apr-2015  	
-- Purpose       : Enviar email de checklist	
-- Called by     : Job "[GeraDBA] Send Checklist"
-- Parameters    : @Email = Email do destinatario do checklist
-- Example       : send_checklist @Email = 'fabio.marques@dbacorp.com.br'
-- Modifications : v 1.0 06-Apr-2015 - Versão inicial
------------------------------------------------------------
/*
	Pré requitos:
	
	sp_configure 'show advanced options', 1;
	GO
	RECONFIGURE;
	GO
	sp_configure 'Ole Automation Procedures', 1;
	GO
	RECONFIGURE;
	GO
	
*/


USE [GeraDBA]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[send_checklist]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[send_checklist]
GO

CREATE PROCEDURE [dbo].[send_checklist]           
@Email varchar(300)          
--send_checklist @Email = 'fabio.marques@dbacorp.com.br'          
AS          
SET NOCOUNT ON

DECLARE @Ambiente varchar(50)
          
SET @Ambiente =  CASE 
			WHEN @@SERVERNAME = 'GERA-APP-10'		THEN ' SERVIDOR: Demo '
            WHEN @@SERVERNAME = 'GERA-APP-04'		THEN ' SERVIDOR: Dualtec HML '
			WHEN @@SERVERNAME = 'GERA-APP-06'		THEN ' SERVIDOR: Embelleze '
			WHEN @@SERVERNAME = 'VMPW8KBD02'		THEN ' SERVIDOR: EPM '
			WHEN @@SERVERNAME = 'WIN-H3GIBOJCR4R'	THEN ' SERVIDOR: Gera Institucional '
			WHEN @@SERVERNAME = 'JQPHPWK8BI01'		THEN ' SERVIDOR: Jequiti Cubos '
			WHEN @@SERVERNAME = 'JQVMHWK8QA01'		THEN ' SERVIDOR: Jequiti HML '
			WHEN @@SERVERNAME = 'JQPSPWK8SQ02'		THEN ' SERVIDOR: Jequiti Mirror '
			WHEN @@SERVERNAME = 'JQPSPWK8SQ01'		THEN ' SERVIDOR: Jequiti PRD '
			WHEN @@SERVERNAME = 'GERA-APP-14'		THEN ' SERVIDOR: Koleta Chile '
			WHEN @@SERVERNAME = 'GERA-APP-11'		THEN ' SERVIDOR: Koketa Peru '
			WHEN @@SERVERNAME = 'MAVMPWK8SQ01'		THEN ' SERVIDOR: Marisa PRD '
			WHEN @@SERVERNAME = 'GERA-APP-08'		THEN ' SERVIDOR: Marisa Cubos '
			WHEN @@SERVERNAME = 'GERA-APP-03'		THEN ' SERVIDOR: Marisa HEAD '
			WHEN @@SERVERNAME = 'MAVMPWK8LS01'		THEN ' SERVIDOR: Marisa DR '
			WHEN @@SERVERNAME = 'WCS-NATURAARSQL'	THEN ' SERVIDOR: Natura Argentina PRD '
			WHEN @@SERVERNAME = 'NAPSHWK8QA01'		THEN ' SERVIDOR: Natura Argentina HML '
			WHEN @@SERVERNAME = 'GERA-APP-13'		THEN ' SERVIDOR: Natura Bolivia '
			WHEN @@SERVERNAME = 'GERASQLCLU'		THEN ' SERVIDOR: Natura Chile PRD '
			WHEN @@SERVERNAME = 'GERADB05'			THEN ' SERVIDOR: Natura Chile HML '
			WHEN @@SERVERNAME = 'CLUSSQLSNATU'		THEN ' SERVIDOR: Natura Colombia PRD '
			WHEN @@SERVERNAME = 'GERADB03'			THEN ' SERVIDOR: Natura Colombia HML '
			WHEN @@SERVERNAME = 'WCS-NATURASQL'		THEN ' SERVIDOR: Natura Mexico PRD '
			WHEN @@SERVERNAME = 'NMPSPWK8HML'		THEN ' SERVIDOR: Natura Mexico HML '
			WHEN @@SERVERNAME = 'WCS-NATURAPESQL'	THEN ' SERVIDOR: Natura Peru PRD '
			WHEN @@SERVERNAME = 'NPPSHWK8QA01'		THEN ' SERVIDOR: Natura Peru HML '
			WHEN @@SERVERNAME = 'GERA-APP-12'		THEN ' SERVIDOR: Unika Kallan '
	   END
	   
--fragmentation

DECLARE @name VARCHAR(50) -- database name  
DECLARE @cmd VARCHAR(max) -- command  

If OBJECT_ID('tempdb..#fragmentation') IS NOT NULL 
drop table #fragmentation 

create table #fragmentation 
(DatabaseName varchar(100),ObjectName varchar(100), indexName varchar(100),avg_fragmentation_percent numeric(5,2)) 

DECLARE db_cursor CURSOR FOR  
SELECT name 
FROM MASTER.sys.databases 
WHERE name NOT IN ('master','model','msdb','tempdb') 
AND state = 0 

OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @name   

WHILE @@FETCH_STATUS = 0   
BEGIN   
       SET @cmd = 'insert into #fragmentation (DatabaseName, ObjectName, indexName, avg_fragmentation_percent) 
	   SELECT DB_NAME(ps.database_id) AS [Database Name], OBJECT_NAME(ps.OBJECT_ID,DB_ID(''' + @name + ''')) AS [Object Name], 
isnull(i.name, ''-'') AS [Index Name], ps.avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID(''' + @name + '''),NULL, NULL, NULL , NULL) AS ps
INNER JOIN ' + @name + '.sys.indexes AS i WITH (NOLOCK) ON ps.[object_id] = i.[object_id] AND ps.index_id = i.index_id
WHERE ps.database_id = DB_ID(''' + @name +''')
AND ps.page_count > 2500
AND ps.avg_fragmentation_in_percent > 30
ORDER BY ps.avg_fragmentation_in_percent DESC OPTION (RECOMPILE);'
       exec(@cmd)

       FETCH NEXT FROM db_cursor INTO @name   
END   

CLOSE db_cursor   
DEALLOCATE db_cursor
    
--Errorlog      
If OBJECT_ID('tempdb..#xp_readerrorlog') IS NOT NULL 
drop table #xp_readerrorlog     
create table #xp_readerrorlog           
(           
LogDate datetime           
,ProcessInfo nvarchar(128)           
,Text nvarchar(4000)           
)           
          
          
-- insert into #xp_readerrorlog           
-- exec xp_readerrorlog           
insert into #xp_readerrorlog           
EXEC master.dbo.xp_readerrorlog 0, 1, 'fail', null, NULL, NULL, N'desc'          
insert into #xp_readerrorlog           
EXEC master.dbo.xp_readerrorlog 0, 1, 'error', null, NULL, NULL, N'desc'          
insert into #xp_readerrorlog           
EXEC master.dbo.xp_readerrorlog 0, 1, 'severity', null, NULL, NULL, N'desc'          
insert into #xp_readerrorlog           
EXEC master.dbo.xp_readerrorlog 0, 1, 'I/O', null, NULL, NULL, N'desc'          
if not exists(SELECT 1          
from #xp_readerrorlog           
where LogDate >= getdate()-2           
and (lower([Text]) like '%fail%' or lower([Text]) like '%error%' or lower([Text]) like '%severity%')          
and [Text] not like '%5000%'           
and [Text] not like '%severity%'           
and [Text] not like '%BackupDiskFile::%' )          
insert into #xp_readerrorlog          
select getdate(),0,'Nenhuma Falha'          
          
------          
          
DECLARE @hr int           
DECLARE @fso int           
DECLARE @drive char(1)           
DECLARE @odrive int           
DECLARE @TotalSize varchar(20)           
DECLARE @MB bigint ; SET @MB = 1048576           
          
If OBJECT_ID('tempdb..#drives') IS NOT NULL 
drop table #drives

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
          
declare @previousdate datetime           
declare @year varchar(4)           
declare @month varchar(2)           
declare @monthpre varchar(2)           
declare @day varchar(2)           
declare @daypre varchar(2)           
declare @finaldate int           
          
-- lambança para converter em int           
set @previousdate = dateadd(dd, -3, getdate()) -- Ultimos 3 days           
set @year = datepart(yyyy, @previousdate)           
select @monthpre = convert(varchar(2), datepart(mm, @previousdate))           
select @month = right(convert(varchar, (@monthpre + 1000000000)),2)           
select @daypre = convert(varchar(2), datepart(dd, @previousdate))           
select @day = right(convert(varchar, (@daypre + 1000000000)),2)           
set @finaldate = cast(@year + @month + @day as int)          
          
DECLARE @profiler VARCHAR(100)           
DECLARE @ServerT VARCHAR(100)           
SET @profiler = 'GeraDBA'          
SET @ServerT = 'CheckList Diario (' +@Ambiente+')'          
          
          
DECLARE @MyQuery VARCHAR(MAX)           
SET @MyQuery =          
'<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN">           
<html>           
<head>           
<style type=''text/css''>           
<!--           
<!--           
table {           
border: 1px solid #cfcfcf;           
}         
          
th {           
font: 700 13px "Trebuchet MS", Arial, Helvetica, sans-serif;           
text-transform: uppercase;           
color: #fff;           
background-color: #069;           
text-align: left;           
padding: 0 10px;           
}          
          
td {           
font: 11px Tahoma, Geneva, sans-serif;           
color: #505050;           
background-color: #EEE9E9;           
padding: 4px;           
}           
          
          
          
-->           
          
</style>           
          
<title>Generated table</title>           
</head>           
<body>    
    
<body> 
'
+
'     
<H4>Status dos Jobs</H>           
'
+
ISNULL(
'
<table>           
<tr>           
<th>Nome do Job</th><th>Data</th><th>Status</th>          
' + CAST ( ( SELECT distinct td = rtrim(ltrim(j.Name)), '',           
td = rtrim(ltrim(max(CONVERT(DATETIME, RTRIM(run_date)) + ((run_time/10000 * 3600) + ((run_time%10000)/100*60) + (run_time%10000)%100 /*run_time_elapsed_seconds*/) / (23.999999*3600 /* seconds in a day*/)))), '',           
td = case h.run_status          
when 0 then 'Failed'          
when 1 then 'Successful'          
when 3 then 'Cancelled'          
when 4 then 'In Progress'          
end , ''          
from msdb..sysJobHistory h    
inner join  msdb..sysJobs j on h.job_id = j.job_id     
inner join (select job_id, max(instance_id) as instance_id    
                from msdb..sysjobhistory    
                group by job_id) q2    
on h.instance_id = q2.instance_id    
where j.job_id = h.job_id    
--and h.step_id = 1          
and h.run_date > @finaldate          
--and h.run_date =           
--(select max(hi.run_date) from msdb..sysJobHistory hi where h.job_id = hi.job_id)          
GROUP BY           
j.Name ,          
case h.run_status           
when 0 then 'Failed'           
when 1 then 'Successful'           
when 3 then 'Cancelled'           
when 4 then 'In Progress'           
end          
ORDER BY 1,3 desc        
          
FOR XML PATH('tr'), TYPE           
) AS NVARCHAR(MAX) ) +           
N'</table>           
', '<P>=================NADA=================</P>')
+
'  
    
<H4>Steps de Jobs com falha</H>           
'
+
ISNULL(
'
<table>           
' +  
'         
<tr>          
<th>Nome do Job</th><th>Step</th><th>Erro</th>
        
' 
+ isnull(CAST ( (
SELECT   td = j.[name],
	'',  
         td = s.step_name,   
    '',  
         td = h.message,  
    ''         
FROM     msdb.dbo.sysjobhistory h   
         INNER JOIN msdb.dbo.sysjobs j   
           ON h.job_id = j.job_id   
         INNER JOIN msdb.dbo.sysjobsteps s   
           ON j.job_id = s.job_id  
           AND h.step_id = s.step_id  
WHERE    h.run_status = 0 -- Failure   
         AND h.run_date > @FinalDate   
         AND h.sql_severity < 15 
FOR XML PATH('tr'), TYPE 
) AS NVARCHAR(MAX) ), cast((SELECT td = '', '', td = '', '', td = '', '' FOR XML PATH('tr'), TYPE) AS NVARCHAR(MAX))) +           
N'</table>           
', '<P>=================NADA=================</P>')
+
'  
<H4>Status dos Backups - Full</H>           
'
+
ISNULL(
'
<table>           
' +           
'           
          
<tr>           
<th>Database</th><th>Data</th><th>Device</th>          
' + CAST ( (   
  
 SELECT td = rtrim(ltrim(bs.Database_name)), '',           
td = rtrim(ltrim(bs.Backup_finish_date )), '',           
td = rtrim(ltrim(bmf.Physical_device_name )), ''           
from          
msdb.dbo.backupset bs          
inner join msdb.dbo.backupmediafamily bmf on bmf.media_set_id = bs.media_set_id          
inner join master.sys.databases sys on sys.name = bs.database_name          
inner join (select database_name          
, max(bs.backup_finish_date) as last_backup          
from          
msdb.dbo.backupset bs          
inner join msdb.dbo.backupmediafamily bmf on bmf.media_set_id = bs.media_set_id          
inner join master.sys.databases sys on sys.name = bs.database_name          
where type = 'D'         
group by database_name ) TEMP          
on TEMP.last_backup = bs.backup_finish_date          
and TEMP.database_name = bs.database_name          
where type = 'D'          
order by 3 asc     
FOR XML PATH('tr'), TYPE           
) AS NVARCHAR(MAX) ) +           
N'</table>          
', '<P>=================NADA=================</P>')
+
'           
<H4>Status dos Backups - Log</H>           
'
+
ISNULL(
'
<table>           
' +           
'           
          
<tr>           
<th>Database</th><th>Data</th><th>Device</th>          
' + CAST ( ( SELECT td = rtrim(ltrim(bs.Database_name)), '',           
td = rtrim(ltrim(bs.Backup_finish_date )), '',           
td = rtrim(ltrim(bmf.Physical_device_name )), ''           
from          
msdb.dbo.backupset bs          
inner join msdb.dbo.backupmediafamily bmf on bmf.media_set_id = bs.media_set_id          
inner join master.sys.databases sys on sys.name = bs.database_name and sys.recovery_model <> '3'         
inner join (select database_name          
, max(bs.backup_finish_date) as last_backup          
from          
msdb.dbo.backupset bs          
inner join msdb.dbo.backupmediafamily bmf on bmf.media_set_id = bs.media_set_id          
inner join master.sys.databases sys on sys.name = bs.database_name       
where type = 'L'       
group by database_name ) TEMP          
on TEMP.last_backup = bs.backup_finish_date          
and TEMP.database_name = bs.database_name          
where type = 'L'          
order by bs.backup_finish_date desc          
FOR XML PATH('tr'), TYPE           
) AS NVARCHAR(MAX) ) +           
N'</table>
', '<P>=================NADA=================</P>')
+
'          
<H4>Espaço em Disco</H>           
'
+
ISNULL(
'
<table>           
' +           
'           
          
<tr>           
<th>Drive</th><th>Livre(MB)</th><th>Total(MB)</th><th>Livre(%)</th>          
' + CAST ( ( SELECT td = rtrim(ltrim(drive)), '',           
td = rtrim(ltrim(FreeSpace)), '',           
td = rtrim(ltrim(TotalSize)), '',           
td = CAST((FreeSpace/(TotalSize*1.0))*100.0 as int), ''           
FROM #drives           
where CAST((FreeSpace/(TotalSize*1.0))*100.0 as int) <= 99           
ORDER BY drive          
FOR XML PATH('tr'), TYPE           
) AS NVARCHAR(MAX) ) +           
N'</table>          
', '<P>=================NADA=================</P>')
+
'          
<H4>Fragmentação</H>           
'
+
ISNULL(
'
<table>           
' +           
'           
          
<tr>           
<th>Database Name</th><th>Object Name</th><th>Index Name</th><th>Fragmentation(%)</th>          
' + CAST ( ( SELECT td = DatabaseName, '', td = ObjectName, '', 
td = indexName, '', td = avg_fragmentation_percent, ''
FROM #fragmentation
ORDER BY avg_fragmentation_percent DESC --OPTION (RECOMPILE)         
FOR XML PATH('tr'), TYPE           
) AS NVARCHAR(MAX) ) +           
N'</table>          
', '<P>=================NADA=================</P>')
+
'          
<H4>Errorlog</H>           
'
+
ISNULL(
'
<table>           
' +           
'           
          
<tr>           
<th>Data</th><th>Detalhes</th>          
' +           
CAST ( ( SELECT td = rtrim(ltrim(isnull([LogDate],''))), '',           
td = rtrim(ltrim(left(isnull([Text],''),120))), ''           
from #xp_readerrorlog           
where LogDate >= getdate()-2           
and (lower([Text]) like '%fail%' or lower([Text]) like '%error%' or lower([Text]) like '%severity%' or ProcessInfo = '0')          
and [Text] not like '%5000%'           
and [Text] not like '%severity%'           
and [Text] not like '%BackupDiskFile::%'           
ORDER BY LogDate DESC          
FOR XML PATH('tr'), TYPE           
) AS NVARCHAR(MAX) ) +           
N'</table>          
', '<P>=================NADA=================</P>')          
          
;           
DROP TABLE #drives           
DROP TABLE #xp_readerrorlog           
DROP TABLE #fragmentation           
SELECT @MyQuery

EXEC msdb.dbo.sp_send_dbmail           

@recipients= @Email,        
@body=@MyQuery ,           
@subject = @ServerT,           
@profile_name = @profiler,           
@body_format = 'HTML'  
=======
------------------------------------------------------------
-- Object        : send_checklist
-- Object Type   : Stored Procedure
-- Produced By   : DBACorp  
-- URL           : www.dbacorp.com.br
-- Author        : Fabio Marques
-- Date          : 06-Apr-2015  	
-- Purpose       : Enviar email de checklist	
-- Called by     : Job "[GeraDBA] Send Checklist"
-- Parameters    : @Email = Email do destinatario do checklist
-- Example       : send_checklist @Email = 'fabio.marques@dbacorp.com.br'
-- Modifications : v 1.0 06-Apr-2015 - Versão inicial
------------------------------------------------------------
/*
	Pré requitos:
	
	sp_configure 'show advanced options', 1;
	GO
	RECONFIGURE;
	GO
	sp_configure 'Ole Automation Procedures', 1;
	GO
	RECONFIGURE;
	GO
	
*/


USE [GeraDBA]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[send_checklist]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[send_checklist]
GO

CREATE PROCEDURE [dbo].[send_checklist]           
@Email varchar(300)          
--send_checklist @Email = 'fabio.marques@dbacorp.com.br'          
AS          
SET NOCOUNT ON

DECLARE @Ambiente varchar(50)
          
SET @Ambiente =  CASE 
			WHEN @@SERVERNAME = 'GERA-APP-10'		THEN ' SERVIDOR: Demo '
            WHEN @@SERVERNAME = 'GERA-APP-04'		THEN ' SERVIDOR: Dualtec HML '
			WHEN @@SERVERNAME = 'GERA-APP-06'		THEN ' SERVIDOR: Embelleze '
			WHEN @@SERVERNAME = 'VMPW8KBD02'		THEN ' SERVIDOR: EPM '
			WHEN @@SERVERNAME = 'WIN-H3GIBOJCR4R'	THEN ' SERVIDOR: Gera Institucional '
			WHEN @@SERVERNAME = 'JQPHPWK8BI01'		THEN ' SERVIDOR: Jequiti Cubos '
			WHEN @@SERVERNAME = 'JQVMHWK8QA01'		THEN ' SERVIDOR: Jequiti HML '
			WHEN @@SERVERNAME = 'JQPSPWK8SQ02'		THEN ' SERVIDOR: Jequiti Mirror '
			WHEN @@SERVERNAME = 'JQPSPWK8SQ01'		THEN ' SERVIDOR: Jequiti PRD '
			WHEN @@SERVERNAME = 'GERA-APP-14'		THEN ' SERVIDOR: Koleta Chile '
			WHEN @@SERVERNAME = 'GERA-APP-11'		THEN ' SERVIDOR: Koketa Peru '
			WHEN @@SERVERNAME = 'MAVMPWK8SQ01'		THEN ' SERVIDOR: Marisa PRD '
			WHEN @@SERVERNAME = 'GERA-APP-08'		THEN ' SERVIDOR: Marisa Cubos '
			WHEN @@SERVERNAME = 'GERA-APP-03'		THEN ' SERVIDOR: Marisa HEAD '
			WHEN @@SERVERNAME = 'MAVMPWK8LS01'		THEN ' SERVIDOR: Marisa DR '
			WHEN @@SERVERNAME = 'WCS-NATURAARSQL'	THEN ' SERVIDOR: Natura Argentina PRD '
			WHEN @@SERVERNAME = 'NAPSHWK8QA01'		THEN ' SERVIDOR: Natura Argentina HML '
			WHEN @@SERVERNAME = 'GERA-APP-13'		THEN ' SERVIDOR: Natura Bolivia '
			WHEN @@SERVERNAME = 'GERASQLCLU'		THEN ' SERVIDOR: Natura Chile PRD '
			WHEN @@SERVERNAME = 'GERADB05'			THEN ' SERVIDOR: Natura Chile HML '
			WHEN @@SERVERNAME = 'CLUSSQLSNATU'		THEN ' SERVIDOR: Natura Colombia PRD '
			WHEN @@SERVERNAME = 'GERADB03'			THEN ' SERVIDOR: Natura Colombia HML '
			WHEN @@SERVERNAME = 'WCS-NATURASQL'		THEN ' SERVIDOR: Natura Mexico PRD '
			WHEN @@SERVERNAME = 'NMPSPWK8HML'		THEN ' SERVIDOR: Natura Mexico HML '
			WHEN @@SERVERNAME = 'WCS-NATURAPESQL'	THEN ' SERVIDOR: Natura Peru PRD '
			WHEN @@SERVERNAME = 'NPPSHWK8QA01'		THEN ' SERVIDOR: Natura Peru HML '
			WHEN @@SERVERNAME = 'GERA-APP-12'		THEN ' SERVIDOR: Unika Kallan '
	   END
	   
--fragmentation

DECLARE @name VARCHAR(50) -- database name  
DECLARE @cmd VARCHAR(max) -- command  

If OBJECT_ID('tempdb..#fragmentation') IS NOT NULL 
drop table #fragmentation 

create table #fragmentation 
(DatabaseName varchar(100),ObjectName varchar(100), indexName varchar(100),avg_fragmentation_percent numeric(5,2)) 

DECLARE db_cursor CURSOR FOR  
SELECT name 
FROM MASTER.sys.databases 
WHERE name NOT IN ('master','model','msdb','tempdb') 
AND state = 0 

OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @name   

WHILE @@FETCH_STATUS = 0   
BEGIN   
       SET @cmd = 'insert into #fragmentation (DatabaseName, ObjectName, indexName, avg_fragmentation_percent) 
	   SELECT DB_NAME(ps.database_id) AS [Database Name], OBJECT_NAME(ps.OBJECT_ID,DB_ID(''' + @name + ''')) AS [Object Name], 
isnull(i.name, ''-'') AS [Index Name], ps.avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID(''' + @name + '''),NULL, NULL, NULL , NULL) AS ps
INNER JOIN ' + @name + '.sys.indexes AS i WITH (NOLOCK) ON ps.[object_id] = i.[object_id] AND ps.index_id = i.index_id
WHERE ps.database_id = DB_ID(''' + @name +''')
AND ps.page_count > 2500
AND ps.avg_fragmentation_in_percent > 30
ORDER BY ps.avg_fragmentation_in_percent DESC OPTION (RECOMPILE);'
       exec(@cmd)

       FETCH NEXT FROM db_cursor INTO @name   
END   

CLOSE db_cursor   
DEALLOCATE db_cursor
    
--Errorlog      
If OBJECT_ID('tempdb..#xp_readerrorlog') IS NOT NULL 
drop table #xp_readerrorlog     
create table #xp_readerrorlog           
(           
LogDate datetime           
,ProcessInfo nvarchar(128)           
,Text nvarchar(4000)           
)           
          
          
-- insert into #xp_readerrorlog           
-- exec xp_readerrorlog           
insert into #xp_readerrorlog           
EXEC master.dbo.xp_readerrorlog 0, 1, 'fail', null, NULL, NULL, N'desc'          
insert into #xp_readerrorlog           
EXEC master.dbo.xp_readerrorlog 0, 1, 'error', null, NULL, NULL, N'desc'          
insert into #xp_readerrorlog           
EXEC master.dbo.xp_readerrorlog 0, 1, 'severity', null, NULL, NULL, N'desc'          
insert into #xp_readerrorlog           
EXEC master.dbo.xp_readerrorlog 0, 1, 'I/O', null, NULL, NULL, N'desc'          
if not exists(SELECT 1          
from #xp_readerrorlog           
where LogDate >= getdate()-2           
and (lower([Text]) like '%fail%' or lower([Text]) like '%error%' or lower([Text]) like '%severity%')          
and [Text] not like '%5000%'           
and [Text] not like '%severity%'           
and [Text] not like '%BackupDiskFile::%' )          
insert into #xp_readerrorlog          
select getdate(),0,'Nenhuma Falha'          
          
------          
          
DECLARE @hr int           
DECLARE @fso int           
DECLARE @drive char(1)           
DECLARE @odrive int           
DECLARE @TotalSize varchar(20)           
DECLARE @MB bigint ; SET @MB = 1048576           
          
If OBJECT_ID('tempdb..#drives') IS NOT NULL 
drop table #drives

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
          
declare @previousdate datetime           
declare @year varchar(4)           
declare @month varchar(2)           
declare @monthpre varchar(2)           
declare @day varchar(2)           
declare @daypre varchar(2)           
declare @finaldate int           
          
-- lambança para converter em int           
set @previousdate = dateadd(dd, -3, getdate()) -- Ultimos 3 days           
set @year = datepart(yyyy, @previousdate)           
select @monthpre = convert(varchar(2), datepart(mm, @previousdate))           
select @month = right(convert(varchar, (@monthpre + 1000000000)),2)           
select @daypre = convert(varchar(2), datepart(dd, @previousdate))           
select @day = right(convert(varchar, (@daypre + 1000000000)),2)           
set @finaldate = cast(@year + @month + @day as int)          
          
DECLARE @profiler VARCHAR(100)           
DECLARE @ServerT VARCHAR(100)           
SET @profiler = 'GeraDBA'          
SET @ServerT = 'CheckList Diario (' +@Ambiente+')'          
          
          
DECLARE @MyQuery VARCHAR(MAX)           
SET @MyQuery =          
'<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN">           
<html>           
<head>           
<style type=''text/css''>           
<!--           
<!--           
table {           
border: 1px solid #cfcfcf;           
}         
          
th {           
font: 700 13px "Trebuchet MS", Arial, Helvetica, sans-serif;           
text-transform: uppercase;           
color: #fff;           
background-color: #069;           
text-align: left;           
padding: 0 10px;           
}          
          
td {           
font: 11px Tahoma, Geneva, sans-serif;           
color: #505050;           
background-color: #EEE9E9;           
padding: 4px;           
}           
          
          
          
-->           
          
</style>           
          
<title>Generated table</title>           
</head>           
<body>    
    
<body> 
'
+
'     
<H4>Status dos Jobs</H>           
'
+
ISNULL(
'
<table>           
<tr>           
<th>Nome do Job</th><th>Data</th><th>Status</th>          
' + CAST ( ( SELECT distinct td = rtrim(ltrim(j.Name)), '',           
td = rtrim(ltrim(max(CONVERT(DATETIME, RTRIM(run_date)) + ((run_time/10000 * 3600) + ((run_time%10000)/100*60) + (run_time%10000)%100 /*run_time_elapsed_seconds*/) / (23.999999*3600 /* seconds in a day*/)))), '',           
td = case h.run_status          
when 0 then 'Failed'          
when 1 then 'Successful'          
when 3 then 'Cancelled'          
when 4 then 'In Progress'          
end , ''          
from msdb..sysJobHistory h    
inner join  msdb..sysJobs j on h.job_id = j.job_id     
inner join (select job_id, max(instance_id) as instance_id    
                from msdb..sysjobhistory    
                group by job_id) q2    
on h.instance_id = q2.instance_id    
where j.job_id = h.job_id    
--and h.step_id = 1          
and h.run_date > @finaldate          
--and h.run_date =           
--(select max(hi.run_date) from msdb..sysJobHistory hi where h.job_id = hi.job_id)          
GROUP BY           
j.Name ,          
case h.run_status           
when 0 then 'Failed'           
when 1 then 'Successful'           
when 3 then 'Cancelled'           
when 4 then 'In Progress'           
end          
ORDER BY 1,3 desc        
          
FOR XML PATH('tr'), TYPE           
) AS NVARCHAR(MAX) ) +           
N'</table>           
', '<P>=================NADA=================</P>')
+
'  
    
<H4>Steps de Jobs com falha</H>           
'
+
ISNULL(
'
<table>           
' +  
'         
<tr>          
<th>Nome do Job</th><th>Step</th><th>Erro</th>
        
' 
+ isnull(CAST ( (
SELECT   td = j.[name],
	'',  
         td = s.step_name,   
    '',  
         td = h.message,  
    ''         
FROM     msdb.dbo.sysjobhistory h   
         INNER JOIN msdb.dbo.sysjobs j   
           ON h.job_id = j.job_id   
         INNER JOIN msdb.dbo.sysjobsteps s   
           ON j.job_id = s.job_id  
           AND h.step_id = s.step_id  
WHERE    h.run_status = 0 -- Failure   
         AND h.run_date > @FinalDate   
         AND h.sql_severity < 15 
FOR XML PATH('tr'), TYPE 
) AS NVARCHAR(MAX) ), cast((SELECT td = '', '', td = '', '', td = '', '' FOR XML PATH('tr'), TYPE) AS NVARCHAR(MAX))) +           
N'</table>           
', '<P>=================NADA=================</P>')
+
'  
<H4>Status dos Backups - Full</H>           
'
+
ISNULL(
'
<table>           
' +           
'           
          
<tr>           
<th>Database</th><th>Data</th><th>Device</th>          
' + CAST ( (   
  
 SELECT td = rtrim(ltrim(bs.Database_name)), '',           
td = rtrim(ltrim(bs.Backup_finish_date )), '',           
td = rtrim(ltrim(bmf.Physical_device_name )), ''           
from          
msdb.dbo.backupset bs          
inner join msdb.dbo.backupmediafamily bmf on bmf.media_set_id = bs.media_set_id          
inner join master.sys.databases sys on sys.name = bs.database_name          
inner join (select database_name          
, max(bs.backup_finish_date) as last_backup          
from          
msdb.dbo.backupset bs          
inner join msdb.dbo.backupmediafamily bmf on bmf.media_set_id = bs.media_set_id          
inner join master.sys.databases sys on sys.name = bs.database_name          
where type = 'D'         
group by database_name ) TEMP          
on TEMP.last_backup = bs.backup_finish_date          
and TEMP.database_name = bs.database_name          
where type = 'D'          
order by 3 asc     
FOR XML PATH('tr'), TYPE           
) AS NVARCHAR(MAX) ) +           
N'</table>          
', '<P>=================NADA=================</P>')
+
'           
<H4>Status dos Backups - Log</H>           
'
+
ISNULL(
'
<table>           
' +           
'           
          
<tr>           
<th>Database</th><th>Data</th><th>Device</th>          
' + CAST ( ( SELECT td = rtrim(ltrim(bs.Database_name)), '',           
td = rtrim(ltrim(bs.Backup_finish_date )), '',           
td = rtrim(ltrim(bmf.Physical_device_name )), ''           
from          
msdb.dbo.backupset bs          
inner join msdb.dbo.backupmediafamily bmf on bmf.media_set_id = bs.media_set_id          
inner join master.sys.databases sys on sys.name = bs.database_name and sys.recovery_model <> '3'         
inner join (select database_name          
, max(bs.backup_finish_date) as last_backup          
from          
msdb.dbo.backupset bs          
inner join msdb.dbo.backupmediafamily bmf on bmf.media_set_id = bs.media_set_id          
inner join master.sys.databases sys on sys.name = bs.database_name       
where type = 'L'       
group by database_name ) TEMP          
on TEMP.last_backup = bs.backup_finish_date          
and TEMP.database_name = bs.database_name          
where type = 'L'          
order by bs.backup_finish_date desc          
FOR XML PATH('tr'), TYPE           
) AS NVARCHAR(MAX) ) +           
N'</table>
', '<P>=================NADA=================</P>')
+
'          
<H4>Espaço em Disco</H>           
'
+
ISNULL(
'
<table>           
' +           
'           
          
<tr>           
<th>Drive</th><th>Livre(MB)</th><th>Total(MB)</th><th>Livre(%)</th>          
' + CAST ( ( SELECT td = rtrim(ltrim(drive)), '',           
td = rtrim(ltrim(FreeSpace)), '',           
td = rtrim(ltrim(TotalSize)), '',           
td = CAST((FreeSpace/(TotalSize*1.0))*100.0 as int), ''           
FROM #drives           
where CAST((FreeSpace/(TotalSize*1.0))*100.0 as int) <= 99           
ORDER BY drive          
FOR XML PATH('tr'), TYPE           
) AS NVARCHAR(MAX) ) +           
N'</table>          
', '<P>=================NADA=================</P>')
+
'          
<H4>Fragmentação</H>           
'
+
ISNULL(
'
<table>           
' +           
'           
          
<tr>           
<th>Database Name</th><th>Object Name</th><th>Index Name</th><th>Fragmentation(%)</th>          
' + CAST ( ( SELECT td = DatabaseName, '', td = ObjectName, '', 
td = indexName, '', td = avg_fragmentation_percent, ''
FROM #fragmentation
ORDER BY avg_fragmentation_percent DESC --OPTION (RECOMPILE)         
FOR XML PATH('tr'), TYPE           
) AS NVARCHAR(MAX) ) +           
N'</table>          
', '<P>=================NADA=================</P>')
+
'          
<H4>Errorlog</H>           
'
+
ISNULL(
'
<table>           
' +           
'           
          
<tr>           
<th>Data</th><th>Detalhes</th>          
' +           
CAST ( ( SELECT td = rtrim(ltrim(isnull([LogDate],''))), '',           
td = rtrim(ltrim(left(isnull([Text],''),120))), ''           
from #xp_readerrorlog           
where LogDate >= getdate()-2           
and (lower([Text]) like '%fail%' or lower([Text]) like '%error%' or lower([Text]) like '%severity%' or ProcessInfo = '0')          
and [Text] not like '%5000%'           
and [Text] not like '%severity%'           
and [Text] not like '%BackupDiskFile::%'           
ORDER BY LogDate DESC          
FOR XML PATH('tr'), TYPE           
) AS NVARCHAR(MAX) ) +           
N'</table>          
', '<P>=================NADA=================</P>')          
          
;           
DROP TABLE #drives           
DROP TABLE #xp_readerrorlog           
DROP TABLE #fragmentation           
SELECT @MyQuery

EXEC msdb.dbo.sp_send_dbmail           

@recipients= @Email,        
@body=@MyQuery ,           
@subject = @ServerT,           
@profile_name = @profiler,           
@body_format = 'HTML'  
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
