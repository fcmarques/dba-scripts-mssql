<<<<<<< HEAD
IF OBJECT_ID ( 'pr_send_checklist', 'P' ) IS NOT NULL   
    DROP procedure pr_send_checklist;  
GO  

CREATE procedure [dbo].[pr_send_checklist] 
@Email varchar(300)          
--pr_send_checklist @Email = 'fabio.marques@riachuelo.com.br;Eduardo.Monte@riachuelo.com.br;demarchi@riachuelo.com.br'
AS          
SET NOCOUNT ON          
--Errorlog          
create table #xp_readerrorlog           
(           
LogDate datetime           
,ProcessInfo nvarchar(128)           
,Text nvarchar(4000)           
)           
          
          
-- insert into #xp_readerrorlog           
-- exec xp_readerrorlog           
insert into #xp_readerrorlog           
EXEC master.dbo.xp_readerrorlog 0, 1, N'fail', null, NULL, NULL, N'desc'          
insert into #xp_readerrorlog           
EXEC master.dbo.xp_readerrorlog 0, 1, N'error', null, NULL, NULL, N'desc'          
insert into #xp_readerrorlog           
EXEC master.dbo.xp_readerrorlog 0, 1, N'severity', null, NULL, NULL, N'desc'          
insert into #xp_readerrorlog           
EXEC master.dbo.xp_readerrorlog 0, 1, N'I/O', null, NULL, NULL, N'desc'          
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
SELECT @profiler = name FROM msdb..sysmail_profile where name = 'DBA'          
SELECT @ServerT = 'CheckList Diario (' +@@SERVERNAME+')'          
          
          
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

     
<H4>Status dos Jobs</H>           
<table>           
' +           
'           
          
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
  
     
<H4>Jobs com falha em Step</H>           
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
  
<H4>Status dos Backups - Full</H>           
          
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
inner join master..sysdatabases sys on sys.name = bs.database_name          
inner join (select database_name          
, max(bs.backup_finish_date) as last_backup          
from          
msdb.dbo.backupset bs          
inner join msdb.dbo.backupmediafamily bmf on bmf.media_set_id = bs.media_set_id          
inner join master..sysdatabases sys on sys.name = bs.database_name          
where type = 'D'         
and (bmf.Physical_device_name not like '%Replica%' )  
AND  bmf.Physical_device_name not like '%HISTORICO.BAK%'   
group by database_name ) TEMP          
on TEMP.last_backup = bs.backup_finish_date          
and TEMP.database_name = bs.database_name          
where type = 'D'          
order by 3 asc     
FOR XML PATH('tr'), TYPE           
) AS NVARCHAR(MAX) ) +           
N'</table>          
           
           
<H4>Status dos Backups - Log</H>           
          
<table>           
' +
'           
          
<tr>           
<th>Database</th><th>Data</th><th>Device</th>          
' + ISNULL(CAST ( ( SELECT td = rtrim(ltrim(bs.Database_name)), '',           
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
inner join master..sysdatabases sys on sys.name = bs.database_name       
where type = 'L'       
group by database_name ) TEMP          
on TEMP.last_backup = bs.backup_finish_date          
and TEMP.database_name = bs.database_name          
where type = 'L'          
order by bs.backup_finish_date desc          
FOR XML PATH('tr'), TYPE           
) AS NVARCHAR(MAX) ), 'NADA') +           
N'</table>          
<H4>Errorlog</H>           
          
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

<H4>Espaço em Disco</H>           
          
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
          
        
'          
          
DROP TABLE #drives
DROP TABLE #xp_readerrorlog

EXEC msdb.dbo.sp_send_dbmail           
@recipients= @Email,
@body=@MyQuery ,           
@subject = @ServerT,           
@profile_name =@profiler,           
@body_format = 'HTML';

=======
IF OBJECT_ID ( 'pr_send_checklist', 'P' ) IS NOT NULL   
    DROP procedure pr_send_checklist;  
GO  

CREATE procedure [dbo].[pr_send_checklist] 
@Email varchar(300)          
--pr_send_checklist @Email = 'fabio.marques@riachuelo.com.br;Eduardo.Monte@riachuelo.com.br;demarchi@riachuelo.com.br'
AS          
SET NOCOUNT ON          
--Errorlog          
create table #xp_readerrorlog           
(           
LogDate datetime           
,ProcessInfo nvarchar(128)           
,Text nvarchar(4000)           
)           
          
          
-- insert into #xp_readerrorlog           
-- exec xp_readerrorlog           
insert into #xp_readerrorlog           
EXEC master.dbo.xp_readerrorlog 0, 1, N'fail', null, NULL, NULL, N'desc'          
insert into #xp_readerrorlog           
EXEC master.dbo.xp_readerrorlog 0, 1, N'error', null, NULL, NULL, N'desc'          
insert into #xp_readerrorlog           
EXEC master.dbo.xp_readerrorlog 0, 1, N'severity', null, NULL, NULL, N'desc'          
insert into #xp_readerrorlog           
EXEC master.dbo.xp_readerrorlog 0, 1, N'I/O', null, NULL, NULL, N'desc'          
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
SELECT @profiler = name FROM msdb..sysmail_profile where name = 'DBA'          
SELECT @ServerT = 'CheckList Diario (' +@@SERVERNAME+')'          
          
          
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

     
<H4>Status dos Jobs</H>           
<table>           
' +           
'           
          
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
  
     
<H4>Jobs com falha em Step</H>           
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
  
<H4>Status dos Backups - Full</H>           
          
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
inner join master..sysdatabases sys on sys.name = bs.database_name          
inner join (select database_name          
, max(bs.backup_finish_date) as last_backup          
from          
msdb.dbo.backupset bs          
inner join msdb.dbo.backupmediafamily bmf on bmf.media_set_id = bs.media_set_id          
inner join master..sysdatabases sys on sys.name = bs.database_name          
where type = 'D'         
and (bmf.Physical_device_name not like '%Replica%' )  
AND  bmf.Physical_device_name not like '%HISTORICO.BAK%'   
group by database_name ) TEMP          
on TEMP.last_backup = bs.backup_finish_date          
and TEMP.database_name = bs.database_name          
where type = 'D'          
order by 3 asc     
FOR XML PATH('tr'), TYPE           
) AS NVARCHAR(MAX) ) +           
N'</table>          
           
           
<H4>Status dos Backups - Log</H>           
          
<table>           
' +
'           
          
<tr>           
<th>Database</th><th>Data</th><th>Device</th>          
' + ISNULL(CAST ( ( SELECT td = rtrim(ltrim(bs.Database_name)), '',           
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
inner join master..sysdatabases sys on sys.name = bs.database_name       
where type = 'L'       
group by database_name ) TEMP          
on TEMP.last_backup = bs.backup_finish_date          
and TEMP.database_name = bs.database_name          
where type = 'L'          
order by bs.backup_finish_date desc          
FOR XML PATH('tr'), TYPE           
) AS NVARCHAR(MAX) ), 'NADA') +           
N'</table>          
<H4>Errorlog</H>           
          
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

<H4>Espaço em Disco</H>           
          
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
          
        
'          
          
DROP TABLE #drives
DROP TABLE #xp_readerrorlog

EXEC msdb.dbo.sp_send_dbmail           
@recipients= @Email,
@body=@MyQuery ,           
@subject = @ServerT,           
@profile_name =@profiler,           
@body_format = 'HTML';

>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
GO