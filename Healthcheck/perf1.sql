declare @ts_now bigint,
@start_time varchar(20),
@Server_Name varchar(100),
@Server_ver varchar(500),
@SQLSer_OSInfo varchar(500),
@SQL_inst_date varchar(100),
@MachineName varchar(100),
@ServerName varchar(100),
@SrvName_prop varchar(100),
@Srv_Machine varchar(100),
@InstName varchar(100),
@IsCluster varchar(10),
@CompNetbios varchar(200),
@SqlEdition varchar(100),
@SqlProductLevel varchar(10),
@SqlProdVer varchar(20),
@SqlProid varchar(10),
@Sql_Ins_collation varchar(100),
@IsfullText varchar(10),
@IsInterSec varchar(10),
@LogicalCPUCount varchar(10),
@PhyCPUCount varchar(10),
@PhyRAM_MB varchar(10),
@Proc_Value varchar(200),
@Proc_date Varchar(500),
@Sp_config_Name varchar(500),
@Sp_config_value varchar(10),
@Sp_config_inusevalue varchar(10),
@Sp_config_des varchar(1000),
@db_det_name varchar(400),
@db_det_fileid varchar(200),
@db_det_filename varchar(200),
@db_det_phyfilename varchar(4000),
@db_det_filedesc varchar(100),
@db_det_statedesc varchar(200),
@db_det_filesizeMB varchar(20),
@avg_io_stall_ms real,
@row_cnt int,
@Db_name varchar(500),
@Db_cpu_time_ms bigint,
@db_cpu_per real,
@dbcache_Dbname varchar(500),
@dbcache_dbcachesizeMB real,
@cpuwait_signal_cpu_waits real,
@cpuwait_resource_wait real,
@logindet_LoginName varchar(500),
@logindet_session_count bigint,
@avg_task_count varchar(200),
@avg_runnable_task_count varchar(200),
@avg_diskpendingio_count varchar(200),
@flagname varchar(20),
@flagstatus varchar(20),
@flagglobal varchar(20),
@flagsesion varchar(20),
@topqbycpu_query varchar(4000),
@topqbycpu_time varchar(200),
@topqbycpu_dbid varchar(200) ,
@topqbycpu_dbname varchar(200) ,
@topqbycpu_totaltime varchar(200),
@topqbycpu_execution_count varchar(200),
@topspbycpu_plan_handle varchar(2000),


--Missing Indexes by Script
@msgindx_idxgroup_handle varchar(200),
@msgindx_idx_handle varchar(200),
@msgindx_improvement_measures varchar(200),
@msgindx_createidxstat varchar(5000),
@msgindx_grphandle varchar(200),
@msgindx_uniqcompiles varchar(200),
@msgindx_userseeks varchar(200),
@msgindx_usescans varchar(200),
@msgindx_lastuserseek varchar(200),
@msgindx_lastuserscan varchar(200),
@msgindx_avgtotalusercost varchar(200),
@msgindx_avguserimpact varchar(200),
@msgindx_systemseek varchar(200),
@msgindx_systemscan varchar(200),
@msgindx_lastsysseek varchar(200),
@msgindx_avgtotalsyscost varchar(200),
@msgindx_avgsysimpact varchar(200),
@msgindx_databaseid varchar(200),
@msgindx_objid varchar(200),

--MSDB Suspect pages
@mscorrupt_dbid varchar(10),
@mscorrupt_fileid varchar(20),
@mscorrupt_pageid varchar(500),
@mscorrupt_eventtype varchar(2000),
@mscorrupt_errorcount varchar(5000),
@mscorrupt_lastupdate varchar(2000),

-- Listing 26 Detecting blocking (a more accurate and complete version)
@blocking_lcktype varchar(200),
@blocking_dbname varchar(500),
@blocking_blockerobj varchar(500),
@blocking_lckreque varchar(200),
@blocking_waitersid varchar(10),
@blocking_waitime varchar(10),
@blocking_waitbatch varchar(20),
@blocking_waiterstmt varchar(1000),
@blocking_blockersid varchar(200),
@blocking_blocker_stmt varchar(1000),

-- Listing 27 Looking at locks that are causing problems
@lockquery_restype varchar(100),
@lockquery_resdbid varchar(10),
@lockquery_resentryid varchar(100),
@lockquery_reqmode varchar(100),
@lockquery_reqsessid varchar(10),
@lockquery_blocksid varchar(10),

-- Database Growth Query
@endDate datetime,
@months smallint,
@DBG_Dbname varchar(200),
@DBG_YearMon varchar(50),
@DBG_MinSizeMB varchar(200),
@DBG_MaxSizeMB varchar(200),
@DBG_AVGSizeMB varchar(200),
@DBG_GrowthMB varchar(200),

--script for IO Result for file in min
@fileio_dbname varchar(200),
@fileio_filename varchar(4000),
@fileio_filetype varchar(200),
@fileio_filesizegb varchar(200),
@fileio_mbread varchar(200),
@fileio_mbwrite varchar(200),
@fileio_noofread varchar(200),
@fileio_noofwrite varchar(200),
@fileio_miniowritestall varchar(200),
@fileio_minioreadstall varchar(200),
--waittype details
@waitType_WaitTypeName varchar(500),
@WaitType_waittime_s decimal(12,2),
@WaitType_resource_s decimal(12,2),
@WaitType_Signal_s decimal(12,2),
@WaitType_counts bigint,
@WaitType_WaitingPct real,
@WaitType_RunningPct real,
--script to look for open transaction actual activity
@otran_spid varchar(10),
@otran_lasworkertime varchar(200),
@otran_lastphysicalread varchar(200),
@otran_totalphysicalread varchar(200),
@otran_totallogicalwrites varchar(200),
@otran_lastlogicalreads varchar(200),
@otran_currentwait varchar(200),
@otran_lastwaittype varchar(1000),
@otran_watiresource varchar(1000),
@otran_waittime varchar(100),
@otran_opentrancount varchar(100),
@otran_rowcount varchar(10),
@otran_granterqmem varchar(20),
@otran_sqltect varchar(4000)



		print'<HTML><head><Title>SQL Server Instance Detail Report.</Title>'+
			'<style type="text/css">'+
				'table {
				border-collapse:collapse;
				background:#FAEBD7 repeat-x;
				border-left:1px solid #686868;
				border-right:1px solid #686868;
				font:0.8em/145% Trebuchet MS,helvetica,arial,verdana;
				color: #333;
				}'+

'td, th {
		padding:5px;
}'+

'caption {
		padding: 0 0 .5em 0;
		text-align: left;
		font-size: 1.4em;
		font-weight: bold;
		text-transform: uppercase;
		color: #333;
		background: transparent;
}'+

'table a {
		color:#950000;
		text-decoration:none;
}'+

'table a:link {}'+

'table a:visited {
		font-weight:normal;
		color:#666;
		text-decoration: line-through;
}'+

'table a:hover {
		border-bottom: 1px dashed #bbb;
}'+


'thead th, tfoot th, tfoot td {
		background:#FAEBD7 url(http://www.roscripts.com/images/teaser.gif) repeat-x;
		color:#fff
}'+

'tfoot td {
		text-align:right
}'+

'tbody th, tbody td {
		border-bottom: dotted 1px #333;
}'+

'tbody th {
		white-space: nowrap;
}'+

'tbody th a {
		color:#333;
}'+

'.odd {}'+

'tbody tr:hover {
		background:#FAEBD7
}'+


'</style></head>'

/*
SQL Server Startup Time		
			
*/


print N'<h1><u><center>SQL Server Performance Health Check Report</center></u></h1>'

print N'<h2><center>SQL SERVER INSTANCE DETAILS</center></h2>'
print N'<h3>SQL Server Up Time</h3>'
print N'<table cellspacing="1" cellpadding="1" border="1">'+

N'<tr><th><strong>SQL Server was Restarted on</strong></th>'+'</tr>'

declare cur_uptime_sql cursor for
select CONVERT(VARCHAR(20), create_date, 100) 
  from sys.databases where database_id=2
open cur_uptime_sql
fetch from cur_uptime_sql into 
@start_time
while @@fetch_status>=0
begin 
print '<tr><td>'+@start_time+'</td>'+'</tr>'
fetch from cur_uptime_sql into 
@start_time
end
close cur_uptime_sql
deallocate cur_uptime_sql
print'</table><br/>'


/*
Get selected server properties (SQL Server 2005)
-- This gives you a lot of useful information about your instance of SQL Server

*/

print N'<H3>SQL Server Instance properties</H3>'
print N'<table cellspacing="1" cellpadding="1" border="1">'+


N'<tr><th><strong>Machine Name</strong></th>'+
N'<th><strong>Server Name</strong></th>'+
N'<th><strong>Instance Name</strong></th>'+
N'<th><strong>Is Clustered</strong></th>'+
N'<th><strong>Computer Netbios Name</strong></th>'+
N'<th><strong>SQL Edition</strong></th>'+
N'<th><strong>SQL Product Patch Level</strong></th>'+
N'<th><strong>SQL Product Product Version</strong></th>'+
N'<th><strong>SQL Process ID</strong></th>'+
N'<th><strong>SQL Instance Collation</strong></th>'+
N'<th><strong>SQL FullText Installed</strong></th>'+
N'<th><strong>SQL IsIntegratedSecurityOnly</strong></th></tr>'

declare cur_sql_sqlpropties cursor for 
SELECT 
cast(SERVERPROPERTY('MachineName') as varchar(200)) AS [MachineName], 
cast(SERVERPROPERTY('ServerName') as varchar(200)) AS [ServerName],  
cast(SERVERPROPERTY('InstanceName') as varchar(200)) AS [Instance],
cast(SERVERPROPERTY('IsClustered') as varchar(200)) AS [IsClustered], 
CAST(SERVERPROPERTY('ComputerNamePhysicalNetBIOS') as varchar(200)) AS [ComputerNamePhysicalNetBIOS], 
cast(SERVERPROPERTY('Edition') as varchar(200)) AS [Edition],
cast(SERVERPROPERTY('ProductLevel') as varchar(200)) AS [ProductLevel], 
cast(SERVERPROPERTY('ProductVersion') as varchar(200)) AS [ProductVersion],
cast(SERVERPROPERTY('ProcessID') as varchar(200)) AS [ProcessID],
cast(SERVERPROPERTY('Collation') as varchar(200)) AS [Collation],
cast(SERVERPROPERTY('IsFullTextInstalled') as varchar(200)) AS [IsFullTextInstalled], 
cast(SERVERPROPERTY('IsIntegratedSecurityOnly') as varchar(200)) AS [IsIntegratedSecurityOnly]

open cur_sql_sqlpropties
fetch next from cur_sql_sqlpropties into 
@Srv_Machine,
@SrvName_prop,
@InstName,
@IsCluster,
@CompNetbios,
@SqlEdition,
@SqlProductLevel,
@SqlProdVer,
@SqlProid,
@Sql_Ins_collation,
@IsfullText,
@IsInterSec
while @@fetch_status>=0
begin 

if(@InstName IS NULL)
begin
set @InstName = 'Default'
end
print '<tr><td>'+@Srv_Machine+'</td><td>'+@SrvName_prop+'</td><td>'+@InstName+'</td><td>'+@IsCluster+'</td><td>'+@CompNetbios+'</td><td>'+@SqlEdition+'</td><td>'+@SqlProductLevel+'</td><td>'+@SqlProdVer+'</td><td>'+@SqlProid+'</td><td>'+@Sql_Ins_collation
+'</td><td>'+@IsfullText+'</td><td>'+@IsInterSec+'</td>'+'</tr>'
--print 'I am in the cursor'
fetch next from cur_sql_sqlpropties into 
@Srv_Machine,
@SrvName_prop,
@InstName,
@IsCluster,
@CompNetbios,
@SqlEdition,
@SqlProductLevel,
@SqlProdVer,
@SqlProid,
@Sql_Ins_collation,
@IsfullText,
@IsInterSec
end
close cur_sql_sqlpropties
deallocate cur_sql_sqlpropties
print'</table><br/>'

/*

CPU Hardware Information for SQL Server 2005 
 
 */
print N'<H3>SQL Server Server CPU Information</H3>'
print N'<table cellspacing="1" cellpadding="1" border="1">'+
N'<tr><th><strong>Logical CPU Count</strong></th>'+
N'<th><strong>Physical CPU Count</strong></th>'+
N'<th><strong>CPU Last 30 Min.</strong></th></tr>'
declare @cpu as varchar(15)

		SELECT @LogicalCPUCount=cast(cpu_count as varchar(10)),
			@PhyCPUCount=cast (cpu_count/hyperthread_ratio as varchar(10))
			 
		FROM sys.dm_os_sys_info WITH (NOLOCK) OPTION (RECOMPILE)
set nocount on
SET QUOTED_IDENTIFIER ON
 select top 30 (100 - SystemIdle) as cpu_utlization into  #cpu 
  from (    select   record.value('(./Record/@id)[1]', 'int') as record_id,    
  record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int')    
  as SystemIdle,    record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]',    'int') 
  as SQLProcessUtilization,    timestamp   from (    select timestamp, convert(xml, record) as record    
  from sys.dm_os_ring_buffers    where ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'   
  and record like '%<SystemHealth>%') as x    ) as y order by record_id desc
  select @cpu= cast(SUM(cpu_utlization)/30 as varchar (15)) from  #cpu 
  drop table #cpu	
 
print '<tr><td>'+@LogicalCPUCount+'</td><td>'+@PhyCPUCount+'</td><td>'+@cpu+'</td>'+'</tr>'
print'</table><br/>'
print '<br>'
/* Memory information*/


print N'<H3>SQL Server Memory information and usage:-</H3>'
print N'<table cellspacing="1" cellpadding="1" border="1">'+
N'<tr><th><strong>Total RAM MB</strong></th>'+
'<th><strong>Available RAM MB</strong></th>'+
'<th><strong>Max Server Memory MB</strong></th>'+
'<th><strong>Current SQL Usage MB</strong></th>'+
N'<th><strong>Page Life Expectancy Sec</strong></th></tr>'


declare @page_size int, @Instancename varchar(50);
declare @Total_physical_memory_GB as varchar(50);
declare @Available_physical_memory_MB as varchar(50);
declare @Buffer_Pool_Usage as varchar(50);
declare @Max_Server_Mermory as varchar(50);
declare @ple as int;
declare @SQLcmd varchar(8000); set @SQLcmd = '<Total Physical Memory Query>';
declare @Mem table ([Total_physical_memory_GB] varchar(50));

-- Get the SQL server version
declare @version varchar(4);
select @version = SUBSTRING(@@VERSION, CHARINDEX('2',@@VERSION),4);

if @version = '2005'
begin
	select @SQLcmd = replace(@SQLcmd,'<Total Physical Memory Query>','SELECT cast(CEILING((physical_memory_in_bytes/1048576.0))as varchar (50)) FROM sys.dm_os_sys_info;');
	insert into @Mem exec (@SQLcmd);
	select @Total_physical_memory_GB = [Total_physical_memory_GB] from @Mem;
--	SELECT @Total_physical_memory_GB = cast(CEILING((physical_memory_in_bytes/1048576.0)/1024)as varchar (50)) FROM sys.dm_os_sys_info;
	SELECT @Buffer_Pool_Usage =cast(CEILING(cntr_value/1024) as varchar(50)) FROM sys.dm_os_performance_counters WHERE counter_name = 'Total Server Memory (KB)';
	select @ple = cntr_value from sys.dm_os_performance_counters where object_name like '%Manager%' and counter_name = 'Page life expectancy';
	SELECT @Max_Server_Mermory = cast([value_in_use]as varchar(50)) FROM [master].[sys].[configurations]WHERE NAME IN ('Max server memory (MB)');
end 
else
	if (@version >= '2008')
	begin
		SET NOCOUNT ON;
		SELECT @Total_physical_memory_GB = cast((([total_physical_memory_kb] / 1024)) as varchar(50))FROM [master].[sys].[dm_os_sys_memory];
		SELECT @Available_physical_memory_MB = cast((([available_physical_memory_kb] / 1024)) as varchar(50))FROM [master].[sys].[dm_os_sys_memory];
		SELECT @Buffer_Pool_Usage =cast(CEILING(cntr_value/1024) as varchar(50)) FROM sys.dm_os_performance_counters WHERE counter_name = 'Total Server Memory (KB)';
		SELECT @Max_Server_Mermory = cast([value_in_use]as varchar(50)) FROM [master].[sys].[configurations]WHERE NAME IN ('Max server memory (MB)');
		select @ple = cntr_value from sys.dm_os_performance_counters where object_name like '%Manager%' and counter_name = 'Page life expectancy';
	end

print '<tr><td>'+@Total_physical_memory_GB+
	  '</td><td>'+@Available_physical_memory_MB+
	  '</td><td>'+@Max_Server_Mermory+
	  '</td><td>'+@Buffer_Pool_Usage+
	  '</td><td>'+cast(@ple as varchar(10))+'</td>'+'</tr>'+'</table>'

/* Deadlock information
*/
print N'<H3>SQL Server Deadlock information</H3>'
print N'<table cellspacing="1" cellpadding="1" border="1">'+
N'<tr><th><strong>Deadlock</strong></th>'+
N'<th><strong>Count</strong></th></tr>'

declare @deadlock varchar(4);
declare @count as int;
 select @count=cntr_value from sys.dm_os_performance_counters where object_name like '%Locks%' and counter_name = 'Number of Deadlocks/sec' and instance_name = '_Total';
 if @count>0 set @deadlock='Yes'
 else set @deadlock='No'
print '<tr><td>'+@deadlock+'</td><td>'+cast(@count as varchar(4))+'</td>'+'</tr>'
print'</table><br/>'
print '<br>'
print '<table style="width: 100%">
	<tr>
		<td><strong><span class="auto-style1">SQL Server Deadlock 
		Detail:-</span><br class="auto-style1"></strong>-- Get the deadlock count for a instance <br>-- This provides all the deadlocks that have 
		happened on the server since the last restart..</td>
	</tr>
</table>'


/*SQL Server Login Count and Session Detail.
*/

print N'<H3>SQL Server Login and session count detail</H3>'
print N'<table cellspacing="1" cellpadding="1" border="1">'+
N'<tr><th><strong>SQL Login Name</strong></th>'+
N'<th><strong>SQL Session Counts</strong></th></tr>'

declare cur_session_countinfo cursor for 
SELECT login_name, COUNT(session_id) AS [session_count] 
FROM sys.dm_exec_sessions WITH (NOLOCK)
GROUP BY login_name
ORDER BY COUNT(session_id) DESC OPTION (RECOMPILE);

open cur_session_countinfo
fetch from cur_session_countinfo into 
@logindet_LoginName,
@logindet_session_count
while @@FETCH_STATUS>=0
 begin
print '<tr><td>'+cast(@logindet_LoginName as varchar(500))+'</td><td>'+cast(@logindet_session_count as varchar(500))+'</td>'+'</tr>'
fetch from cur_session_countinfo into 
@logindet_LoginName,
@logindet_session_count
end
close cur_session_countinfo
deallocate cur_session_countinfo
print'</table><br/>'
print '<table style="width: 100%">
	<tr>
		<td><strong><span class="auto-style1">SQL Server Login and Session 
		Detail:-</span><br class="auto-style1"></strong>-- Get logins that are 
		connected and how many sessions they have <br>-- This can help 
		characterize your workload and determine whether you are seeing a normal 
		level of activity.</td>
	</tr>
</table>'



 /*
 --Detecting blocking (a more accurate and complete version)
 */

 
 print N'<H3>SQL Server Detected Blocking on Instance:-</H3>'
print N'<table cellspacing="1" cellpadding="1" border="1">'+
N'<tr><th><strong>Lock Type</strong></th>'+
'<th><strong>Database Name</strong></th>'+
'<th><strong>Blocked Object</strong></th>'+
'<th><strong>Lock Requested</strong></th>'+
'<th><strong>Waiter Spid</strong></th>'+
'<th><strong>Wait Time(in Microsecond)</strong></th>'+
'<th><strong>Waiter Batch</strong></th>'+
'<th><strong>Waiter Statement</strong></th>'+
'<th><strong>Blocker Sid</strong></th>'+
N'<th><strong>Blocker Statement</strong></th></tr>'



declare cur_sqlblcoking_detail_cur cursor for 
SELECT t1.resource_type AS 'lock type',db_name(resource_database_id) AS 'database',
t1.resource_associated_entity_id AS 'blk object',t1.request_mode AS 'lock req', --- lock requested
t1.request_session_id AS 'waiter sid', t2.wait_duration_ms AS 'wait time',
(SELECT [text] FROM sys.dm_exec_requests AS r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle)
WHERE r.session_id = t1.request_session_id) AS 'waiter_batch',
(SELECT substring(qt.text,r.statement_start_offset/2,
(CASE WHEN r.statement_end_offset = -1
THEN LEN(CONVERT(nvarchar(max), qt.text)) * 2
ELSE r.statement_end_offset END - r.statement_start_offset)/2)
FROM sys.dm_exec_requests AS r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS qt
WHERE r.session_id = t1.request_session_id) AS 'waiter_stmt',
t2.blocking_session_id AS 'blocker sid',
(SELECT [text] FROM sys.sysprocesses AS p
CROSS APPLY sys.dm_exec_sql_text(p.sql_handle)
WHERE p.spid = t2.blocking_session_id) AS 'blocker_stmt'
FROM sys.dm_tran_locks AS t1
INNER JOIN sys.dm_os_waiting_tasks AS t2
ON t1.lock_owner_address = t2.resource_address;


open cur_sqlblcoking_detail_cur
fetch from cur_sqlblcoking_detail_cur into 
@blocking_lcktype ,
@blocking_dbname ,
@blocking_blockerobj ,
@blocking_lckreque ,
@blocking_waitersid ,
@blocking_waitime ,
@blocking_waitbatch ,
@blocking_waiterstmt ,
@blocking_blockersid ,
@blocking_blocker_stmt



while @@FETCH_STATUS>=0
 begin
print '<tr><td>'+cast(@blocking_lcktype as varchar(100))+
	  '</td><td>'+cast(@blocking_dbname as varchar(40))+
	  '</td><td>'+cast(@blocking_blockerobj as varchar(100))+
	  '</td><td>'+cast(@blocking_lckreque as varchar(100))+
	  '</td><td>'+cast(@blocking_waitersid as varchar(10))+
	  '</td><td>'+cast(@blocking_waitime as varchar(100))+
	  '</td><td>'+ISNULL(cast(@blocking_waitbatch as varchar(200)),0)+
	  '</td><td>'+ISNULL(cast(@blocking_waiterstmt as varchar(1000)),0)+
	  '</td><td>'+cast(@blocking_blockersid as varchar(40))+
	  '</td><td>'+ISNULL(cast(@blocking_blocker_stmt as varchar(1000)),0)+'</td>'+'</tr>'
	  
fetch from cur_sqlblcoking_detail_cur into 
@blocking_lcktype ,
@blocking_dbname ,
@blocking_blockerobj ,
@blocking_lckreque ,
@blocking_waitersid ,
@blocking_waitime ,
@blocking_waitbatch ,
@blocking_waiterstmt ,
@blocking_blockersid ,
@blocking_blocker_stmt
end

close cur_sqlblcoking_detail_cur
deallocate cur_sqlblcoking_detail_cur

print'</table><br/>'

print '<table style="width: 100%">
	<tr>
		<td><strong><span class="auto-style1">Application process blocking 
		Detail:-</span><br class="auto-style1"></strong>-- Get the blocking chain details and will provide 
		all the lead blcoker spid and spid which are getting blocked by this session <br>-- This can help 
		to find out application processes which are causing performance issues due to blocking.
		</td>
	</tr>
</table>'
/* Wait Stats details */

print N'<H3>SQL Server Instance Wait Type Information</H3>'
print N'<table cellspacing="1" cellpadding="1" border="1">'+
N'<tr><th><strong>WAIT Type Names</strong></th>'+
'<th><strong>WAIT Time in (S)</strong></th>'+
'<th><strong>Resource Time in (S)</strong></th>'+
'<th><strong>Signal Time (S)</strong></th>'+
'<th><strong>Wait Counts</strong></th>'+
'<th><strong>WAIT Perc(%)</strong></th>'+
N'<th><strong>Running in (%)</strong></th></tr>'

declare cur_inst_waitinfo cursor for 
WITH Waits AS
(SELECT 
wait_type,
wait_time_ms / 1000 AS waits,
(wait_time_ms-signal_wait_time_ms)/1000 as Resoruce_Wait_Time_S,
signal_wait_time_ms /1000.0 as signals_wait_time_s,
waiting_tasks_count as WaitCount,
100. * wait_time_ms / SUM(wait_time_ms) OVER() AS Percentage,
ROW_NUMBER() OVER(ORDER BY wait_time_ms DESC) AS RowNumber
FROM sys.dm_os_wait_stats
WHERE wait_type NOT IN ('CLR_SEMAPHORE','LAZYWRITER_SLEEP','RESOURCE_QUEUE','SLEEP_TASK'
,'SLEEP_SYSTEMTASK','SQLTRACE_BUFFER_FLUSH','WAITFOR', 'LOGMGR_QUEUE','CHECKPOINT_QUEUE'
,'REQUEST_FOR_DEADLOCK_SEARCH','XE_TIMER_EVENT','BROKER_TO_FLUSH','BROKER_TASK_STOP','CLR_MANUAL_EVENT'
,'CLR_AUTO_EVENT','DISPATCHER_QUEUE_SEMAPHORE', 'FT_IFTS_SCHEDULER_IDLE_WAIT'
,'XE_DISPATCHER_WAIT', 'XE_DISPATCHER_JOIN', 'SQLTRACE_INCREMENTAL_FLUSH_SLEEP'))
SELECT 
W1.wait_type as WaitType, 
CAST(W1.waits AS DECIMAL(12, 2)) AS wait_S,
CAST(W1.Resoruce_Wait_Time_S as decimal(12,2)) as Resource_S,
CAST(W1.signals_wait_time_s as decimal(12,2)) as Signal_S,
CAST(W1.WaitCount as varchar(20)) as WaitCounts,
CAST(W1.Percentage AS DECIMAL(12, 2)) AS Percentage_wait,
CAST(SUM(W2.Percentage) AS DECIMAL(12, 2)) AS running_Percentage
FROM Waits AS W1
INNER JOIN Waits AS W2
ON W2.RowNumber <= W1.RowNumber
GROUP BY 
W1.RowNumber,
W1.wait_type, 
W1.waits, 
W1.Percentage,
W1.Resoruce_Wait_Time_S,
W1.signals_wait_time_s,
W1.WaitCount
HAVING SUM(W2.Percentage) - W1.Percentage < 99;

open cur_inst_waitinfo
fetch cur_inst_waitinfo into 
	    @waitType_WaitTypeName,
		@WaitType_waittime_s,
		@WaitType_resource_s,
		@WaitType_Signal_s,
		@WaitType_counts,
		@WaitType_WaitingPct,
		@WaitType_RunningPct

while @@FETCH_STATUS>=0
 begin
print '<tr><td>'+cast(@waitType_WaitTypeName as varchar(500))+
	 '</td><td>'+cast(@WaitType_waittime_s as varchar(500))+
	 '</td><td>'+cast(@WaitType_resource_s as varchar(500))+
	 '</td><td>'+cast(@WaitType_Signal_s as varchar(500))+
	 '</td><td>'+cast(@WaitType_counts as varchar(500))+
	 '</td><td>'+cast(@WaitType_WaitingPct as varchar(500))+
	 '</td><td>'+cast(@WaitType_RunningPct as varchar(500))+'</td>'+'</tr>'
fetch cur_inst_waitinfo into 
	    @waitType_WaitTypeName,
		@WaitType_waittime_s,
		@WaitType_resource_s,
		@WaitType_Signal_s,
		@WaitType_counts,
		@WaitType_WaitingPct,
		@WaitType_RunningPct
end

close cur_inst_waitinfo
deallocate cur_inst_waitinfo

print'</table><br/>'
print '<table style="width: 100%">
	<tr>
		<td><strong><span class="auto-style1">SQL Server Instance Wait Type 
		Information:-</span><br class="auto-style1"></strong>-- Common 
		Significant Wait types with BOL explanations<br></td>
	</tr>
</table>
<br/>'


/*
Script for getting Top 20 SP ordered bu total worker time to find out most expensive sp by total worker time
indication could be CPU pressure.
The following example returns information about the top five queries ranked by average CPU time. This example aggregates the queries according to their query hash so that logically equivalent queries are grouped by their cumulative resource consumption. 

*/


print N'<H3>SQL Server Top 10 expensive queries - By High CPU:-</H3>'
print N'<table cellspacing="1" cellpadding="1" border="1">'+
N'<tr><th><strong>Query Name/Text</strong></th>'+
'<th><strong>Execution_Count</strong></th>'+
'<th><strong>Avg CPU time in Microsecond</strong></th>'+
'<th><strong>Total time</strong></th>'+
'<th><strong>DB_id</strong></th>'+
'<th><strong>DB_Name</strong></th></tr>'

declare cur_topspcpu_info cursor for 
SELECT TOP 10
   SUBSTRING(qt.text,qs.statement_start_offset/2, 
  (case when qs.statement_end_offset = -1 
  then len(convert(nvarchar(max), qt.text)) * 2 
  else qs.statement_end_offset end -qs.statement_start_offset)/2) 
  as query_text,qs.total_worker_time/qs.execution_count as [Avg CPU Time],
  qt.dbid, dbname=db_name(qt.dbid), qs.total_worker_time, qs.execution_count,
  plan_handle   
  FROM sys.dm_exec_query_stats qs
  cross apply sys.dm_exec_sql_text(qs.sql_handle) as qt
  ORDER BY 
  [Avg CPU Time] DESC;

open cur_topspcpu_info
fetch from cur_topspcpu_info into 
		@topqbycpu_query,
		@topqbycpu_time ,
		@topqbycpu_dbid ,
		@topqbycpu_dbname ,
		@topqbycpu_totaltime,
		@topqbycpu_execution_count,
		@topspbycpu_plan_handle 
		

while @@FETCH_STATUS>=0
 begin
print '<tr><td>'+cast(@topqbycpu_query as varchar(1000))+
	 '</td><td>'+cast(@topqbycpu_execution_count as varchar(20))+
	 '</td><td>'+cast(@topqbycpu_time as varchar(200))+
	 '</td><td>'+cast(@topqbycpu_totaltime as varchar(20))+
	 '</td><td>'+cast( @topqbycpu_dbid as varchar(200))+
	 '</td><td>'+ISNULL(cast(@topqbycpu_dbname as varchar(20)),0)+'</td>'+'</tr>'
	
fetch from cur_topspcpu_info into 
		@topqbycpu_query,
		@topqbycpu_time ,
		@topqbycpu_dbid ,
		@topqbycpu_dbname ,
		@topqbycpu_totaltime,
		@topqbycpu_execution_count,
		@topspbycpu_plan_handle 

end
close cur_topspcpu_info
deallocate cur_topspcpu_info
 print'</table><br/>'
 print N'<table style="width: 100%">
	<tr>
		<td><strong>SQL Server Top 10 CPU Consuming queries:-</strong><br>
		--Above table shows the top 10 queries taken CPU, please focus on Avg_Cpu_time which tells me how much time query has taken on CPU. If CPU time is high, please check the index and stats. 
		-- This data is cumulative since last SQL Server restart or cache flush</td>
	</tr>
</table>'

/* top 10 by duration */

  declare @topbydur_query varchar(4000),
		@topbydur_execution_count varchar(200),
		@topbydur_avg_elapsed_time varchar(200),
		@topbydur_avg_cpu_time varchar(200),
		@topbydur_avg_physical_reads varchar(200),
		@topspbydur_avg_logical_reads varchar(200) 

print N'<H3>SQL Server Top 10 queries - By Duration:-</H3>'
print N'<table cellspacing="1" cellpadding="1" border="1">'+
N'<tr><th><strong>Query Name/Text</strong></th>'+
'<th><strong>Execution Count</strong></th>'+
'<th><strong>Avg_duration_MS</strong></th>'+
'<th><strong>Avg_CPU_time</strong></th>'+
'<th><strong>avg_physical_reads</strong></th>'+
'<th><strong>avg_physical_reads</strong></th></tr>'

declare cur_topspcpu_info cursor for 
select top 10 s2.text, 
   s1.execution_count, 
  (s1.total_elapsed_time/s1.execution_count )/1000 as avg_elapsed_time, 
  (s1.total_worker_time/s1.execution_count )/1000 as avg_cpu_time, 
  (s1.total_physical_reads/s1.execution_count ) as avg_physical_reads,
  (s1.total_Logical_reads/s1.execution_count ) as avg_logical_reads 
  from sys.dm_exec_query_stats s1 
  cross apply 
  sys.dm_exec_sql_text(sql_handle) s2 
  order by avg_elapsed_time desc;

open cur_topspcpu_info
fetch from cur_topspcpu_info into 
		@topbydur_query,
		@topbydur_execution_count,
		@topbydur_avg_elapsed_time ,
		@topbydur_avg_cpu_time ,
		@topbydur_avg_physical_reads,
		@topspbydur_avg_logical_reads 
		

while @@FETCH_STATUS>=0
 begin
print '<tr><td>'+cast(@topbydur_query as varchar(1000))+
	 '</td><td>'+cast(@topbydur_execution_count as varchar(200))+
	 '</td><td>'+cast(@topbydur_avg_elapsed_time as varchar(200))+
	 '</td><td>'+cast(@topbydur_avg_cpu_time as varchar(20))+
	 '</td><td>'+cast(@topbydur_avg_physical_reads as varchar(20))+
	 '</td><td>'+cast(@topspbydur_avg_logical_reads as varchar(20))+'</td>'+'</tr>'
	
fetch from cur_topspcpu_info into 
		@topbydur_query,
		@topbydur_execution_count,
		@topbydur_avg_elapsed_time ,
		@topbydur_avg_cpu_time ,
		@topbydur_avg_physical_reads,
		@topspbydur_avg_logical_reads 

end
close cur_topspcpu_info
deallocate cur_topspcpu_info
 print'</table><br/>'
 print N'<table style="width: 100%">
	<tr>
		<td><strong>SQL Server Top 10 long running queries:-</strong><br>
		--Above table shows the top 10 long running queries by duratione, you need to check the excution count and avg elapsed time to find out which are query frequently executing for long duration
		-- This data is cumulative since last SQL Server restart or cache flush</td>
	</tr>
</table>'

/*top 10 IO consuming queries*/


  declare @topbydIO_query varchar(4000),
		@topbydIO_execution_count varchar(200),
		@topbydIO_avg_IO varchar(200)

print N'<H3>SQL Server Top Expensive queries - By IO:-</H3>'
print N'<table cellspacing="1" cellpadding="1" border="1">'+
N'<tr><th><strong>Query Name/Text</strong></th>'+
'<th><strong>Execution Count</strong></th>'+
'<th><strong>Avg_IOS</strong></th></tr>'

declare cur_topIO_info cursor for 
 SELECT TOP 10  
  SUBSTRING(qt.text,qs.statement_start_offset/2, 
  (case when qs.statement_end_offset = -1 
  then len(convert(nvarchar(max), qt.text)) * 2 
  else qs.statement_end_offset end -qs.statement_start_offset)/2) 
  as query_text,
  qs.execution_count,
   (qs.total_logical_reads + qs.total_logical_writes) /qs.execution_count as 
  [Avg IO]
   FROM sys.dm_exec_query_stats qs
  cross apply sys.dm_exec_sql_text(qs.sql_handle) as qt
  ORDER BY 
  [Avg IO] DESC
  ;

open cur_topIO_info
fetch from cur_topIO_info into 
		@topbydIO_query,
		@topbydIO_execution_count,
		@topbydIO_avg_IO 

while @@FETCH_STATUS>=0
 begin
print '<tr><td>'+cast(@topbydIO_query as varchar(1000))+
	 '</td><td>'+cast(@topbydIO_execution_count as varchar(200))+
	 '</td><td>'+cast(@topbydIO_avg_IO as varchar(20))+'</td>'+'</tr>'
	
fetch from cur_topIO_info into 
		@topbydIO_query,
		@topbydIO_execution_count,
		@topbydIO_avg_IO 

end
close cur_topIO_info
deallocate cur_topIO_info
 print'</table><br/>'
 print N'<table style="width: 100%">
	<tr>
		<td><strong>SQL Server Top 10 long IO queries:-</strong><br>
		--Above table shows the top 10 long IO queries by duratione
		-- This data is cumulative since last SQL Server restart or cache flush</td>
	</tr>
</table>'
/* index fragmentation details.*/

 declare @dbname varchar(4000),
		@table_name varchar(200),
		@index_name varchar(200),
		@index_id varchar(200),
		@index_type varchar(200),
		@avg_frg_pct varchar(200),
		@frag_count varchar(200),
		@page_count varchar(200)

print N'<H3>SQL Server Index fragmentation details by database:-</H3>'
print N'<table cellspacing="1" cellpadding="1" border="1">'+
N'<tr><th><strong>DB Name/Text</strong></th>'+
'<th><strong>Table Name</strong></th>'+
'<th><strong>Index Name</strong></th>'+
'<th><strong>Index ID</strong></th>'+
'<th><strong>Index_type</strong></th>'+
'<th><strong>Avg_Fragmentation</strong></th>'+
'<th><strong>Fragmentation Count</strong></th>'+
'<th><strong>Page Count</strong></th></tr>'

declare cur_Index_info cursor for 
SELECT DB_NAME(database_id) AS [Database Name], OBJECT_NAME(ps.OBJECT_ID) AS [Object Name], 
i.name AS [Index Name], ps.index_id, index_type_desc,
avg_fragmentation_in_percent, fragment_count, page_count
FROM sys.dm_db_index_physical_stats(DB_ID(),NULL, NULL, NULL ,N'LIMITED') AS ps 
INNER JOIN sys.indexes AS i WITH (NOLOCK)
ON ps.[object_id] = i.[object_id] 
AND ps.index_id = i.index_id
WHERE database_id = DB_ID()
AND page_count > 1500 and avg_fragmentation_in_percent>20
ORDER BY avg_fragmentation_in_percent DESC OPTION (RECOMPILE);

open cur_Index_info
fetch from cur_Index_info into 
		@dbname,
		@table_name,
		@index_name,
		@index_id,
		@index_type,
		@avg_frg_pct,
		@frag_count,
		@page_count

while @@FETCH_STATUS>=0
 begin
print '<tr><td>'+cast(@dbname as varchar(1000))+
	 '</td><td>'+cast(@table_name as varchar(200))+
	 '</td><td>'+cast(@index_name as varchar(200))+
	 '</td><td>'+cast(@index_id as varchar(200))+
	 '</td><td>'+cast(@index_type as varchar(200))+
	 '</td><td>'+cast(@avg_frg_pct as varchar(200))+
	 '</td><td>'+cast(@frag_count as varchar(200))+
	 '</td><td>'+cast(@page_count as varchar(20))+'</td>'+'</tr>'
	
fetch from cur_Index_info into 
		@dbname,
		@table_name,
		@index_name,
		@index_id,
		@index_type,
		@avg_frg_pct,
		@frag_count,
		@page_count

end
close cur_Index_info
deallocate cur_Index_info
 print'</table><br/>'
 print N'<table style="width: 100%">
	<tr>
		<td><strong>SQL Server Index fragmentation details:-</strong><br>
		--Above table shows Index fragmentation details. We have filter this data of page count >1500 and fragmentation is more then 20%</td>
	</tr>
</table>'


 /*
   Looking at Index Advantage to find missing indexes
-- Missing Indexes by Index Advantage (make sure to also look at last user seek time)
 */
 
 print N'<H3>SQL Server Missing Indexes:-</H3>'
print N'<table cellspacing="1" cellpadding="1" border="1">'+
N'<th><strong>Index Improvments Measures</strong></th>'+
'<th><strong>Index Create Statement</strong></th>'+
'<th><strong>Index Avg User Impact</strong></th>'+
'<th><strong>Index User Seeks</strong></th>'+
'<th><strong>Index  User Scans</strong></th>'+
'<th><strong>Index Last User Seek</strong></th>'+
'<th><strong>Index Last User Scan</strong></th>'+
'<th><strong>Index Avg Total User Cost</strong></th>'+
'<th><strong>Index System Seek</strong></th>'+
'<th><strong>Index System Scan</strong></th>'+
'<th><strong>Index Last Sytem Seek</strong></th>'+
'<th><strong>Index Avg total System Cost</strong></th>'+
'<th><strong>Index Avg System Impact</strong></th>'+
'<th><strong>Database ID</strong></th>'+
N'<th><strong>Object ID</strong></th></tr>'

declare cu_msgdet cursor for 
SELECT  
 CONVERT (decimal (28,1), migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans)) AS improvement_measure
 ,'CREATE INDEX missing_index_' + CONVERT (varchar, mig.index_group_handle) + '_' + CONVERT (varchar, mid.index_handle) 
  + ' ON ' + mid.statement 
  + ' (' + ISNULL (mid.equality_columns,'') 
    + CASE WHEN mid.equality_columns IS NOT NULL AND mid.inequality_columns IS NOT NULL THEN ',' ELSE '' END + ISNULL (mid.inequality_columns, '')
  + ')' 
  + ISNULL (' INCLUDE (' + mid.included_columns + ')', '') AS create_index_statement, 
  migs.avg_user_impact,
  migs.user_seeks,
  migs.user_scans,
  migs.last_user_seek,
  ISNULL(migs.last_user_scan,0) as last_user_scan,
  migs.avg_total_user_cost,
  migs.system_seeks,
  migs.system_scans,
  ISNULL(migs.last_system_seek,0) as last_system_seek,
  migs.avg_total_system_cost,
  migs.avg_system_impact,
   mid.database_id, mid.[object_id]
FROM sys.dm_db_missing_index_groups mig
INNER JOIN sys.dm_db_missing_index_group_stats migs ON migs.group_handle = mig.index_group_handle
INNER JOIN sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
WHERE CONVERT (decimal (28,1), migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans)) > 10
ORDER BY migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans) DESC

open cu_msgdet
fetch from cu_msgdet into 
		@msgindx_improvement_measures,
		@msgindx_createidxstat,
		@msgindx_avguserimpact ,
		@msgindx_userseeks,
		@msgindx_usescans ,
		@msgindx_lastuserseek ,
		@msgindx_lastuserscan ,
		@msgindx_avgtotalusercost,
		@msgindx_systemseek ,
		@msgindx_systemscan ,
		@msgindx_lastsysseek ,
		@msgindx_avgtotalsyscost ,
		@msgindx_avgsysimpact ,
		@msgindx_databaseid ,
		@msgindx_objid



while @@FETCH_STATUS>=0
 begin
print '</td><td>'+cast(@msgindx_improvement_measures as varchar(100))+
	  '</td><td>'+cast(@msgindx_createidxstat as varchar(5000))+
	  '</td><td>'+cast(@msgindx_avguserimpact as varchar(40))+
	  '</td><td>'+cast(@msgindx_userseeks as varchar(40))+
	  '</td><td>'+cast(@msgindx_usescans as varchar(40))+
	   '</td><td>'+cast(@msgindx_lastuserseek as varchar(40))+
		'</td><td>'+cast(@msgindx_lastuserscan as varchar(40))+
		'</td><td>'+cast(@msgindx_avgtotalusercost as varchar(40))+
		'</td><td>'+cast(@msgindx_systemseek as varchar(40))+
		'</td><td>'+cast(@msgindx_systemscan as varchar(40))+
		'</td><td>'+cast(@msgindx_lastsysseek as varchar(40))+
		'</td><td>'+cast(@msgindx_avgtotalsyscost as varchar(40))+
		'</td><td>'+cast(@msgindx_avgsysimpact as varchar(40))+
	  '</td><td>'+cast(@msgindx_databaseid as varchar(40))+
	  '</td><td>'+cast(@msgindx_objid as varchar(40))+'</td>'+'</tr>'
fetch from cu_msgdet into 
		@msgindx_improvement_measures,
		@msgindx_createidxstat,
		@msgindx_avguserimpact ,
		@msgindx_userseeks,
		@msgindx_usescans ,
		@msgindx_lastuserseek ,
		@msgindx_lastuserscan ,
		@msgindx_avgtotalusercost,
		@msgindx_systemseek ,
		@msgindx_systemscan ,
		@msgindx_lastsysseek ,
		@msgindx_avgtotalsyscost ,
		@msgindx_avgsysimpact ,
		@msgindx_databaseid ,
		@msgindx_objid

end

close cu_msgdet
deallocate cu_msgdet
 print'</table><br/>'



 print'<br>
<table style="width: 100%">
	<tr>
		<td><strong><span class="auto-style1">SQL Server Missing Indexes by 
		Index Advantage:-</span><br class="auto-style1"></strong>--Above table 
		will give you a list of indexes that the query optimizer would have 
		liked to have had, based on the workload.We can see if there are any 
		tables that jump out with multiple missing indexes.<br>--You may also 
		want to look at the last_user_seek column to see when was the last time 
		the optimizer wanted an index. If it is several hours or days ago, it 
		may have been from an ad-hoc query of maintenance job rather than your 
		normal workload.</td>
	</tr>
</table>
<br/>'

/* list of unused indexes
*/
  declare @utable_name varchar(200),
		@uindex_name varchar(200)
		
print N'<H3>List of Unused Indexes:-</H3>'
print N'<table cellspacing="1" cellpadding="1" border="1">'+
N'<th><strong>Table Name</strong></th>'+
'<th><strong>Index Name</strong></th></tr>'

declare cur_unIndex_info cursor for 
select object_name(i.object_id) as ObjectName, i.name as [Unused Index]
from sys.indexes i
left join sys.dm_db_index_usage_stats s on s.object_id = i.object_id
      and i.index_id = s.index_id
      and s.database_id = db_id()
where objectproperty(i.object_id, 'IsIndexable') = 1
AND objectproperty(i.object_id, 'IsIndexed') = 1
and s.index_id is null -- and dm_db_index_usage_stats has no reference to this index
or (s.user_updates > 0 and s.user_seeks = 0 and s.user_scans = 0 and s.user_lookups = 0) -- index is being updated, but not used by seeks/scans/lookups
order by object_name(i.object_id) asc;

open cur_unIndex_info
fetch from cur_unIndex_info into 
		@utable_name,
		@uindex_name
		

while @@FETCH_STATUS>=0
 begin
print '<tr><td>'+cast(@utable_name as varchar(1000))+
	 '</td><td>'+cast(@uindex_name as varchar(200))+
	 '</tr>'
	
fetch from cur_unIndex_info into 
		@utable_name,
		@uindex_name
end
close cur_unIndex_info
deallocate cur_unIndex_info
 print'</table><br/>'
 print N'<table style="width: 100%">
	<tr>
		<td><strong>List of unused indexes in database-</strong><br>
		--Above table shows the list of unused indexes which are not getting used at all.</td>
	</tr>
</table>'


/*
Analyse the database size growth using backup history.
*/


 
 print N'<H3>SQL Server Database Growth in Last Six Month:-</H3>'
print N'<table cellspacing="1" cellpadding="1" border="1">'+
N'<tr><th><strong>Database Name</strong></th>'+
'<th><strong>Year-Month</strong></th>'+
'<th><strong>MinSize in MB</strong></th>'+
'<th><strong>MaxSize in MB</strong></th>'+
'<th><strong>Average Size in MB</strong></th>'+
N'<th><strong>Growth in MB</strong></th></tr>'


set nocount on


SET @endDate = GetDate();  -- Include in the statistic all backups from today
SET @months = 6;           -- back to the last 6 months.
WITH HIST AS
   (SELECT BS.database_name AS DatabaseName
          ,YEAR(BS.backup_start_date) * 100
           + MONTH(BS.backup_start_date) AS YearMonth
          ,CONVERT(numeric(10, 1), MIN(BF.file_size / 1048576.0)) AS MinSizeMB
          ,CONVERT(numeric(10, 1), MAX(BF.file_size / 1048576.0)) AS MaxSizeMB
          ,CONVERT(numeric(10, 1), AVG(BF.file_size / 1048576.0)) AS AvgSizeMB
    FROM msdb.dbo.backupset as BS
         INNER JOIN
         msdb.dbo.backupfile AS BF
             ON BS.backup_set_id = BF.backup_set_id
    WHERE NOT BS.database_name IN
              ('master', 'msdb', 'model', 'tempdb')
          AND BF.file_type = 'D'
          AND BS.backup_start_date BETWEEN DATEADD(mm, - @months, @endDate) AND @endDate
    GROUP BY BS.database_name
            ,YEAR(BS.backup_start_date)
            ,MONTH(BS.backup_start_date))
SELECT MAIN.DatabaseName
      ,MAIN.YearMonth
      ,MAIN.MinSizeMB
      ,MAIN.MaxSizeMB
      ,MAIN.AvgSizeMB
      ,MAIN.AvgSizeMB 
       - (SELECT TOP 1 SUB.AvgSizeMB
          FROM HIST AS SUB
          WHERE SUB.DatabaseName = MAIN.DatabaseName
                AND SUB.YearMonth < MAIN.YearMonth
          ORDER BY SUB.YearMonth DESC) AS GrowthMB into #DBgrwothdata
FROM HIST AS MAIN
ORDER BY MAIN.DatabaseName
        ,MAIN.YearMonth 

--select * from #DBgrwothdata

declare cur_dbgrowth_info cursor for 
select
DatabaseName,
YearMonth,
MinSizeMB,
MaxSizeMB,
AvgSizeMB,
GrowthMB from #DBgrwothdata

open cur_dbgrowth_info

fetch from cur_dbgrowth_info into
@DBG_Dbname ,
@DBG_YearMon ,
@DBG_MinSizeMB ,
@DBG_MaxSizeMB ,
@DBG_AVGSizeMB ,
@DBG_GrowthMB 

while @@FETCH_STATUS>=0
 begin
print '<tr><td>'+cast(@DBG_Dbname as varchar(100))+
	  '</td><td>'+cast(@DBG_YearMon as varchar(40))+
	  '</td><td>'+cast(@DBG_MinSizeMB as varchar(100))+
	  '</td><td>'+cast(@DBG_MaxSizeMB as varchar(100))+
	  '</td><td>'+cast(@DBG_AVGSizeMB as varchar(10))+
	  '</td><td>'+IsNull(cast(@DBG_GrowthMB as varchar(100)),'')+'</td>'+'</tr>'
fetch from cur_dbgrowth_info into
@DBG_Dbname ,
@DBG_YearMon ,
@DBG_MinSizeMB ,
@DBG_MaxSizeMB ,
@DBG_AVGSizeMB ,
@DBG_GrowthMB 
end
close cur_dbgrowth_info
deallocate cur_dbgrowth_info
set nocount on
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'#DBgrwothdata') AND type in (N'U'))
DROP TABLE #DBgrwothdata
print'</table><br/>'
print'
<br>
<table style="width: 100%">
	<tr>
		<td><span class="auto-style1"><strong>SQL Server Database Growth 
		Matrix:-</strong></span><br class="auto-style1">--Above table shows you 
		your user database growth based on the backup of the database.<br>--This information is very handy when you planing for 
		capacity management.</td>
	</tr>
</table>

<br/>'




print '</HTML>'




