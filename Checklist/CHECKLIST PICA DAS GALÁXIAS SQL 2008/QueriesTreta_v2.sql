/*
	░░░░░▄▄▄▄▀▀▀▀▀▀▀▀▄▄▄▄▄▄░░░░░░░
	░░░░░█░░░░▒▒▒▒▒▒▒▒▒▒▒▒░░▀▀▄░░░░
	░░░░█░░░▒▒▒▒▒▒░░░░░░░░▒▒▒░░█░░░
	░░░█░░░░░░▄██▀▄▄░░░░░▄▄▄░░░░█░░
	░▄▀▒▄▄▄▒░█▀▀▀▀▄▄█░░░██▄▄█░░░░█░
	█░▒█▒▄░▀▄▄▄▀░░░░░░░░█░░░▒▒▒▒▒░█
	█░▒█░█▀▄▄░░░░░█▀░░░░▀▄░░▄▀▀▀▄▒█
	░█░▀▄░█▄░█▀▄▄░▀░▀▀░▄▄▀░░░░█░░█░
	░░█░░░▀▄▀█▄▄░█▀▀▀▄▄▄▄▀▀█▀██░█░░
	░░░█░░░░██░░▀█▄▄▄█▄▄█▄████░█░░░
	░░░░█░░░░▀▀▄░█░░░█░█▀██████░█░░
	░░░░░▀▄░░░░░▀▀▄▄▄█▄█▄█▄█▄▀░░█░░
	░░░░░░░▀▄▄░▒▒▒▒░░░░░░░░░░▒░░░█░
	░░░░░░░░░░▀▀▄▄░▒▒▒▒▒▒▒▒▒▒░░░░█░
	░░░░░░░░░░░░░░▀▄▄▄▄▄▄▄▄▄▄▄▄▄█░░		                                                                          
*/


-- Criação da tabela aonde ficará o log
CREATE TABLE [dbo].[ChangeLog](
[LogId] [int] IDENTITY(1,1) NOT NULL,
[DatabaseName] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EventType] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ObjectName] [varchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ObjectType] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SqlCommand] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EventDate] [datetime] NOT NULL CONSTRAINT [DF_EventsLog_EventDate] DEFAULT (getdate()),
[LoginName] [varchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

go
-- Criação da trigger

CREATE trigger backup_objects
on database
for create_procedure, alter_procedure, drop_procedure,
create_table, alter_table, drop_table,
create_function, alter_function, drop_function
as

set nocount on		

declare @data xml
DECLARE @client_ip VARCHAR(15)
set @data = EVENTDATA()

SELECT @client_ip = client_net_address
FROM sys.dm_exec_connections
WHERE session_id =@data.value('(/EVENT_INSTANCE/SPID)[1]', 'varchar(256)')

-- NÃO SE ESQUEÇA DE ALTERAR ESTE INSERT COLOCANDO O BANCO CORRETO.
insert into YOURDATABASE.dbo.changelog(databasename,	  eventtype,
objectname, objecttype, sqlcommand, loginname)
values(
@data.value('(/EVENT_INSTANCE/DatabaseName)[1]', 'varchar(256)'),
@data.value('(/EVENT_INSTANCE/EventType)[1]', 'varchar(50)'),
@data.value('(/EVENT_INSTANCE/SchemaName)[1]', 'varchar(256)') +'.'+
@data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'varchar(256)'),
@data.value('(/EVENT_INSTANCE/ObjectType)[1]', 'varchar(25)'),
@data.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'varchar(max)'),
@data.value('(/EVENT_INSTANCE/LoginName)[1]', 'varchar(256)')+'('+@client_ip+')'
)

sp_configure
-- maxdop recomendado
select 
    case 
        when cpu_count / hyperthread_ratio > 8 then 8
        else cpu_count / hyperthread_ratio
    end as optimal_maxdop_setting
from sys.dm_os_sys_info;    

-- sys.dm_os_sys_info 
--- sys.dm_os_nodes
         
                                                                    
 WITH Waits AS
    (SELECT
        wait_type,
        wait_time_ms / 1000.0 AS WaitS,
        (wait_time_ms - signal_wait_time_ms) / 1000.0 AS ResourceS,
        signal_wait_time_ms / 1000.0 AS SignalS,
        waiting_tasks_count AS WaitCount,
        100.0 * wait_time_ms / SUM (wait_time_ms) OVER() AS Percentage,
        ROW_NUMBER() OVER(ORDER BY wait_time_ms DESC) AS RowNum
    FROM sys.dm_os_wait_stats
    WHERE wait_type NOT IN (
        'CLR_SEMAPHORE', 'LAZYWRITER_SLEEP', 'RESOURCE_QUEUE', 'SLEEP_TASK',
        'SLEEP_SYSTEMTASK', 'SQLTRACE_BUFFER_FLUSH', 'WAITFOR', 'LOGMGR_QUEUE',
        'CHECKPOINT_QUEUE', 'REQUEST_FOR_DEADLOCK_SEARCH', 'XE_TIMER_EVENT', 'BROKER_TO_FLUSH',
        'BROKER_TASK_STOP', 'CLR_MANUAL_EVENT', 'CLR_AUTO_EVENT', 'DISPATCHER_QUEUE_SEMAPHORE',
        'FT_IFTS_SCHEDULER_IDLE_WAIT', 'XE_DISPATCHER_WAIT', 'XE_DISPATCHER_JOIN', 'BROKER_EVENTHANDLER',
        'TRACEWRITE', 'FT_IFTSHC_MUTEX', 'SQLTRACE_INCREMENTAL_FLUSH_SLEEP')
    
     AND wait_type not like 'PREEMPTIVE%')
SELECT
     W1.wait_type AS WaitType,
     CAST (W1.WaitS AS DECIMAL(14, 2)) AS Wait_S,
     CAST (W1.ResourceS AS DECIMAL(14, 2)) AS Resource_S,
     CAST (W1.SignalS AS DECIMAL(14, 2)) AS Signal_S,
     W1.WaitCount AS WaitCount,
     CAST (W1.Percentage AS DECIMAL(4, 2)) AS Percentage
FROM Waits AS W1
INNER JOIN Waits AS W2
     ON W2.RowNum <= W1.RowNum
GROUP BY W1.RowNum, W1.wait_type, W1.WaitS, W1.ResourceS, W1.SignalS, W1.WaitCount, W1.Percentage
HAVING SUM (W2.Percentage) - W1.Percentage < 95; -- percentage threshold
GO

-- Contador de Buffer Cache Hit Ratio (quanto mais próximo de 100%, melhor. Indica possível falta de RAM)
SELECT (a.cntr_value * 1.0 / b.cntr_value) * 100.0 as BufferCacheHitRatio
    FROM sys.dm_os_performance_counters  a
    JOIN  (SELECT cntr_value,OBJECT_NAME
        FROM sys.dm_os_performance_counters  
        WHERE counter_name = 'Buffer cache hit ratio base'
            AND OBJECT_NAME = 'SQLServer:Buffer Manager') b ON  a.OBJECT_NAME = b.OBJECT_NAME
    WHERE a.counter_name = 'Buffer cache hit ratio'
    AND a.OBJECT_NAME = 'SQLServer:Buffer Manager'
    
-- Contador de Page Life Expectancy (Idealmente acima de 300 segundos, pode indicar pressão de memória,
-- queries ruins ou flush do cache recentemente)
SELECT *
    FROM sys.dm_os_performance_counters  
    WHERE counter_name = 'Page life expectancy'
    AND OBJECT_NAME = 'SQLServer:Buffer Manager'
    
-- TOP50 CPU (TOTAL)
SELECT 
      total_cpu_time, 
      total_execution_count,
      number_of_statements,
      s2.text
FROM 
      (SELECT TOP 50 
            SUM(qs.total_worker_time) AS total_cpu_time, 
            SUM(qs.execution_count) AS total_execution_count,
            COUNT(*) AS  number_of_statements, 
            qs.sql_handle --,
      FROM 
            sys.dm_exec_query_stats AS qs
      GROUP BY qs.sql_handle
      ORDER BY SUM(qs.total_worker_time) DESC) AS stats
      CROSS APPLY sys.dm_exec_sql_text(stats.sql_handle) AS s2 

-- TOP50 CPU (AVG)
SELECT TOP 100
total_worker_time/execution_count AS [Avg CPU Time],
(SELECT SUBSTRING(text,statement_start_offset/2,(CASE WHEN statement_end_offset = -1 then LEN(CONVERT(nvarchar(max), text)) * 2 ELSE statement_end_offset end -statement_start_offset)/2) FROM sys.dm_exec_sql_text(sql_handle)) AS query_text, *
FROM sys.dm_exec_query_stats 
ORDER BY [Avg CPU Time] DESC

-- TOP20 Recompilations
SELECT TOP 20
      sql_text.text,
      sql_handle,
      plan_generation_num,
      execution_count,
      dbid,
      objectid 
from sys.dm_exec_query_stats a
      cross apply sys.dm_exec_sql_text(sql_handle) as sql_text
where plan_generation_num > 1
order by plan_generation_num desc

-- TOP50 WORKER TIME
SELECT 
    highest_cpu_queries.plan_handle, 
    highest_cpu_queries.total_worker_time,
    q.dbid,
    q.objectid,
    q.number,
    q.encrypted,
    q.[text]
from 
    (select top 50 
        qs.plan_handle, 
        qs.total_worker_time
    from 
        sys.dm_exec_query_stats qs
    order by qs.total_worker_time desc) as highest_cpu_queries
    cross apply sys.dm_exec_sql_text(plan_handle) as q
order by highest_cpu_queries.total_worker_time desc

-- TOP50 WORKER TIME
SELECT 
    highest_cpu_queries.plan_handle, 
    highest_cpu_queries.total_worker_time,
    q.dbid,
    q.objectid,
    q.number,
    q.encrypted,
    q.[text]
from 
    (select top 50 
        qs.plan_handle, 
        qs.total_worker_time
    from 
        sys.dm_exec_query_stats qs
    order by qs.total_worker_time desc) as highest_cpu_queries
    cross apply sys.dm_exec_sql_text(plan_handle) as q
order by highest_cpu_queries.total_worker_time desc

-- SUSPEITOS: SORT, HASH MATCH
select *
from 
      sys.dm_exec_cached_plans
      cross apply sys.dm_exec_query_plan(plan_handle)
where 
      cast(query_plan as nvarchar(max)) like '%Sort%'
      or cast(query_plan as nvarchar(max)) like '%Hash Match%'

-- TOP 10 I/O (AVG)
	select top 10 (total_logical_reads/execution_count) as avg_logical_reads,
							 (total_logical_writes/execution_count) as avg_logical_writes,
				  (total_physical_reads/execution_count) as avg_physical_reads,
				  Execution_count, statement_start_offset, p.query_plan, q.text
	from sys.dm_exec_query_stats
			cross apply sys.dm_exec_query_plan(plan_handle) p
			cross apply sys.dm_exec_sql_text(plan_handle) as q
	order by (total_logical_reads + total_logical_writes)/execution_count Desc

-- TOP 10 I/O (TOTAL)
select top 10
    (total_logical_reads/execution_count) as avg_logical_reads,
    (total_logical_writes/execution_count) as avg_logical_writes,
    (total_physical_reads/execution_count) as avg_phys_reads,
     Execution_count, 
    statement_start_offset as stmt_start_offset, 
    sql_handle, 
    plan_handle
from sys.dm_exec_query_stats  
order by  (total_logical_reads + total_logical_writes) Desc

-- sp_configure
sp_configure 'show advanced options', 1
go	
reconfigure
go
sp_configure

-- Backups FULL em dia? 
SELECT database_name, max (CONVERT (varchar (20), backup_finish_date, 120)) 'LastBackup'
	FROM msdb..backupset
	WHERE CONVERT (varchar (20), backup_finish_date, 120) < dateadd (day, -2, getdate ())
	GROUP BY database_name
	
--Memória OK? Indo pra onde?
SELECT TOP(10) [type] AS [Memory Clerk Type], SUM(single_pages_kb) AS [SPA Mem, Kb] 
FROM sys.dm_os_memory_clerks 
GROUP BY [type]  
ORDER BY SUM(single_pages_kb) DESC OPTION (RECOMPILE);

DBCC MEMORYSTATUS

SELECT 
	objtype AS 'Cached Object Type',
	COUNT(*) AS 'Number of Plans',
	SUM(CAST(size_in_bytes AS BIGINT))/1024/1024 AS 'Plan Cache Size (MB)',
	AVG(usecounts) AS 'Avg Use Count'
FROM sys.dm_exec_cached_plans
GROUP BY objtype
ORDER BY 'Plan Cache Size (MB)' DESC

SELECT  TOP 6
 LEFT([name], 20) as [name],
 LEFT([type], 20) as [type],
 [single_pages_kb] + [multi_pages_kb] AS cache_kb,
 [entries_count]
FROM sys.dm_os_memory_cache_counters
order by single_pages_kb + multi_pages_kb DESC

SELECT  SUM(multi_pages_kb + virtual_memory_committed_kb 
            + shared_memory_committed_kb  
            + awe_allocated_kb) AS [Used by BPool, Kb]
FROM sys.dm_os_memory_clerks
WHERE type = 'MEMORYCLERK_SQLBUFFERPOOL';

-- TOP 10 RECOMPILE
SELECT TOP 10 plan_generation_num, execution_count,
    (SELECT SUBSTRING(text, statement_start_offset/2 + 1,
      (CASE WHEN statement_end_offset = -1
            THEN LEN(CONVERT(nvarchar(max),text)) * 2
            ELSE statement_end_offset
       END - statement_start_offset)/2)
     FROM sys.dm_exec_sql_text(sql_handle)) AS query_text
FROM sys.dm_exec_query_stats
WHERE plan_generation_num >1
ORDER BY plan_generation_num DESC;

-- I/O STALL
select db_name(mf.database_id) as database_name, mf.physical_name, 
left(mf.physical_name, 1) as drive_letter, 
vfs.num_of_writes, vfs.num_of_bytes_written, vfs.io_stall_write_ms, 
mf.type_desc, vfs.num_of_reads, vfs.num_of_bytes_read, vfs.io_stall_read_ms,
vfs.io_stall, vfs.size_on_disk_bytes
from sys.master_files mf
join sys.dm_io_virtual_file_stats(NULL, NULL) vfs
on mf.database_id=vfs.database_id and mf.file_id=vfs.file_id
order by vfs.num_of_bytes_written desc

--	2005 - QUERY MASTER - MASTER
select
	ses.session_id,
	db_name(req.database_id) as database_name,
	wt.wait_duration_ms,
	wt.wait_type,
	wt.blocking_session_id,
	wt.resource_description,
	ses.host_name,
	ses.host_process_id,
	ses.login_name,
	ses.status,
	ses.last_request_start_time,
	case ses.transaction_isolation_level
	when 0 then 'Unspecified'
	when 1 then 'ReadUncomitted'
	when 2 then 'ReadCommitted'
	when 3 then 'Repeatable'
	when 4 then 'Serializable'
	when 5 then 'Snapshot'
	end as transaction_isolation_level,
	substring(qry.text, (req.statement_start_offset/2),
		(case req.statement_end_offset/2 when 0 then datalength(qry.text)
		else req.statement_end_offset/2 end) - (req.statement_start_offset/2)) as query_text
from
	sys.dm_exec_sessions as ses
	inner join
	sys.dm_exec_requests as req
		on ses.session_id = req.session_id
	left join
	sys.dm_os_waiting_tasks as wt
		on ses.session_id = wt.session_id
	cross apply
	sys.dm_exec_sql_text(req.sql_handle) as qry
	cross apply
	sys.dm_exec_text_query_plan(req.plan_handle, req.statement_start_offset, req.statement_end_offset) as pln
where
	ses.is_user_process = 1
	and (ses.session_id > @@spid
	or ses.session_id < @@spid)
order by wait_duration_ms desc
while 1 = 1
begin
insert into #DIGDIN
select
	ses.session_id,
	db_name(req.database_id) as database_name,
	wt.wait_duration_ms,
	wt.wait_type,
	wt.blocking_session_id,
	wt.resource_description,
	ses.host_name,
	ses.host_process_id,
	ses.login_name,
	ses.status,
	ses.last_request_start_time,
	case ses.transaction_isolation_level
	when 0 then 'Unspecified'
	when 1 then 'ReadUncomitted'
	when 2 then 'ReadCommitted'
	when 3 then 'Repeatable'
	when 4 then 'Serializable'
	when 5 then 'Snapshot'
	end as transaction_isolation_level,
	substring(qry.text, (req.statement_start_offset/2),
		(case req.statement_end_offset/2 when 0 then datalength(qry.text)
		else req.statement_end_offset/2 end) - (req.statement_start_offset/2)) as query_text
	, cast(pln.query_plan as xml) as query_plan, GETDATE () 'data_hora'
from
	sys.dm_exec_sessions as ses
	inner join
	sys.dm_exec_requests as req
		on ses.session_id = req.session_id
	left join
	sys.dm_os_waiting_tasks as wt
		on ses.session_id = wt.session_id
	cross apply
	sys.dm_exec_sql_text(req.sql_handle) as qry
	cross apply
	sys.dm_exec_text_query_plan(req.plan_handle, req.statement_start_offset, req.statement_end_offset) as pln
where
	ses.is_user_process = 1
	and (ses.session_id > @@spid
	or ses.session_id < @@spid)
order by wait_duration_ms desc
waitfor delay '00:00:15'
end

select *
	from #DIGDIN
--	2005 - QUERY MASTER - Disco (PAGEIOLATCH_*, WRITELOG, LOGBUFFER)
set nocount on
select * into #tmp from sys.dm_io_virtual_file_stats(NULL, NULL)
waitfor delay '00:00:01.000'
select
	db_name(vfs.database_id) as database_name,
	mf.physical_name,
	mf.type_desc,
	pio.io_type,
	pio.io_pending_ms_ticks,
	case pio.io_pending
	when 0 then 'SQL Server'
	when 1 then 'Windows / IO Subsystem'
	else 'Unknown'
	end as io_pending,

	vfs.io_stall_read_ms / vfs.num_of_reads as avg_read_wait_ms,
	(vfs.io_stall_read_ms - tmp.io_stall_read_ms) /
		isnull(nullif((vfs.num_of_reads - tmp.num_of_reads), 0), 1) as last_sec_read_wait_ms,
	vfs.num_of_reads - tmp.num_of_reads as last_sec_reads,

	vfs.io_stall_write_ms / vfs.num_of_writes as avg_write_wait_ms,
	(vfs.io_stall_write_ms - tmp.io_stall_write_ms) /
		isnull(nullif((vfs.num_of_writes - tmp.num_of_writes), 0), 1) as last_sec_write_wait_ms,
	vfs.num_of_writes - tmp.num_of_writes as last_sec_writes
from
	sys.dm_io_pending_io_requests as pio
	inner join
	sys.dm_io_virtual_file_stats(NULL, NULL) as vfs
		on pio.io_handle = vfs.file_handle
	inner join
	sys.master_files as mf
		on vfs.database_id = mf.database_id
			and vfs.file_id = mf.file_id
	inner join
	#tmp as tmp
		on vfs.database_id = tmp.database_id
			and vfs.file_id = tmp.file_id
drop table #tmp

--	2005 - QUERY MASTER - CPU(SOS_SCHEDULER_YIELD)
select  
    case grouping(parent_node_id)
    when 1 then 'TOTAL'
    else cast(parent_node_id as varchar(5))
    end as numa_node_id,
    case grouping(scheduler_id)
    when 1 then 'TOTAL'
    else cast(scheduler_id as varchar(5))
    end as scheduler_id,
    sum(current_tasks_count) as current_tasks_count,
    sum(runnable_tasks_count) as runnable_tasks_count
from  
    sys.dm_os_schedulers 
where  
    scheduler_id < 255
group by
	parent_node_id,
    scheduler_id
with rollup
order by
    case grouping(parent_node_id)
    when 1 then 1
    else 2
    end,
	case grouping(scheduler_id)
	when 1 then 1
	else 2
	end,
    replicate('0', 3-len(cast(parent_node_id as varchar(5)))) +
		cast(parent_node_id as varchar(5)),
    replicate('0', 3-len(cast(scheduler_id as varchar(5)))) +
		cast(scheduler_id as varchar(5))

--	2005 - QUERY MASTER - Rede (NETWORK_IO)
select
	con.session_id,
	db_name(req.database_id) as database_name,
	ses.host_name,
	ses.host_process_id,
	ses.login_name,
	ses.last_request_start_time,
	con.connect_time,
	con.net_transport,
	con.protocol_type,
	con.num_reads,
	con.last_read,
	con.num_writes,
	con.last_write,
	con.net_packet_size,
	con.client_net_address,
	con.local_net_address,
	con.local_tcp_port,
	qry.text as most_recent_sql_batch
from
	sys.dm_os_waiting_tasks as wt
	inner join
	sys.dm_exec_connections as con
		on wt.session_id = con.session_id
	inner join
	sys.dm_exec_sessions as ses
		on wt.session_id = ses.session_id
	inner join
	sys.dm_exec_requests as req
		on wt.session_id = req.session_id
	cross apply
	sys.dm_exec_sql_text(con.most_recent_sql_handle) as qry
where
	ses.is_user_process = 1
	and (ses.session_id > @@spid
	or ses.session_id < @@spid)
	and wt.wait_type = 'NETWORK_IO'

--	2005 - QUERY MASTER - Trace (SQLTRACE_*)
select
	id,
	case status
	when 0 then 'Stopped'
	when 1 then 'Running'
	else 'Unknown'
	end as status,
	path,
	case is_rowset
	when 0 then 'File Trace'
	when 1 then 'Profiler Trace'
	else 'Unknown'
	end as type,
	reader_spid,
	start_time,
	last_event_time,
	event_count,
	cast(event_count as decimal(38,3)) /
		datediff(ss, start_time, getdate()) as avg_events_per_second
from
	sys.traces
where
	is_default = 0

-- Tempo estimado para finalizar backup
SELECT command, 
	'EstimatedEndTime' = Dateadd(ms,estimated_completion_time,Getdate()),
	'EstimatedSecondsToEnd' = estimated_completion_time / 1000,
	'EstimatedMinutesToEnd' = estimated_completion_time / 1000 / 60,
	'BackupStartTime' = start_time,
	'PercentComplete' = percent_complete
FROM sys.dm_exec_requests
WHERE session_id = 741    

-- Dono da conta SQL Server
DECLARE @serviceaccount varchar(100)
EXECUTE master.dbo.xp_instance_regread
N'HKEY_LOCAL_MACHINE',
N'SYSTEM\CurrentControlSet\Services\MSSQLSERVER',
N'ObjectName',
@ServiceAccount OUTPUT, N'no_output'
SELECT @Serviceaccount

-- Nó físico
Select ServerProperty('ComputerNamePhysicalNetBIOS')

-- Ler pacote SSIS
SELECT [name] AS SSISPackageName , CONVERT(XML, CONVERT(VARBINARY(MAX), packagedata))  FROM msdb.dbo.sysdtspackages90  
	where name = 'PACOTE'

-- Missing Indexes
 SELECT
   migs.avg_total_user_cost * (migs.avg_user_impact / 100.0) * (migs.user_seeks + migs.user_scans) AS improvement_measure,
   'CREATE INDEX [missing_index_' + CONVERT (varchar, mig.index_group_handle) + '_' + CONVERT (varchar, mid.index_handle)
   + '_' + LEFT (PARSENAME(mid.statement, 1), 32) + ']'
   + ' ON ' + mid.statement
   + ' (' + ISNULL (mid.equality_columns,'')
     + CASE WHEN mid.equality_columns IS NOT NULL AND mid.inequality_columns IS NOT NULL THEN ',' ELSE '' END
     + ISNULL (mid.inequality_columns, '')
   + ')'
   + ISNULL (' INCLUDE (' + mid.included_columns + ')', '') AS create_index_statement,
   migs.*, mid.database_id, mid.[object_id]
 FROM sys.dm_db_missing_index_groups mig
 INNER JOIN sys.dm_db_missing_index_group_stats migs ON migs.group_handle = mig.index_group_handle
 INNER JOIN sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
 WHERE migs.avg_total_user_cost * (migs.avg_user_impact / 100.0) * (migs.user_seeks + migs.user_scans) > 10
 ORDER BY migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans) DESC

-- Do not run this TSQL until SQL Server has been running for at least 3 hours
SET NOCOUNT ON

SELECT objtype AS [Cache Store Type],
        COUNT_BIG(*) AS [Total Num Of Plans],
        SUM(CAST(size_in_bytes as decimal(14,2))) / 1048576 AS [Total Size In MB],
        AVG(usecounts) AS [All Plans - Ave Use Count],
        SUM(CAST((CASE WHEN usecounts = 1 THEN size_in_bytes ELSE 0 END) as decimal(14,2)))/ 1048576 AS [Size in MB of plans with a Use count = 1],
        SUM(CASE WHEN usecounts = 1 THEN 1 ELSE 0 END) AS [Number of of plans with a Use count = 1]
        FROM sys.dm_exec_cached_plans
        GROUP BY objtype
        ORDER BY [Size in MB of plans with a Use count = 1] DESC

DECLARE @AdHocSizeInMB decimal (14,2), @TotalSizeInMB decimal (14,2)

SELECT @AdHocSizeInMB = SUM(CAST((CASE WHEN usecounts = 1 AND LOWER(objtype) = 'adhoc' THEN size_in_bytes ELSE 0 END) as decimal(14,2))) / 1048576,
        @TotalSizeInMB = SUM (CAST (size_in_bytes as decimal (14,2))) / 1048576
        FROM sys.dm_exec_cached_plans 

SELECT @AdHocSizeInMB as [Current memory occupied by adhoc plans only used once (MB)],
         @TotalSizeInMB as [Total cache plan size (MB)],
         CAST((@AdHocSizeInMB / @TotalSizeInMB) * 100 as decimal(14,2)) as [% of total cache plan occupied by adhoc plans only used once]
IF  @AdHocSizeInMB > 200 or ((@AdHocSizeInMB / @TotalSizeInMB) * 100) > 25  -- 200MB or > 25%
        SELECT 'Switch on Optimize for ad hoc workloads as it will make a significant difference' as [Recommendation]
ELSE
        SELECT 'Setting Optimize for ad hoc workloads will make little difference' as [Recommendation]
GO

SELECT COUNT(*) as quantidade
FROM   sys.dm_tran_locks AS tl 
       INNER JOIN sys.dm_os_waiting_tasks AS wt 
         ON tl.lock_owner_address = wt.resource_address 
WHERE  wt.wait_duration_ms / 1000 > 180

--Já a próxima ira listar todos os bloqueios no momento:
SELECT tl.request_session_id, 
       wt.blocking_session_id, 
       Db_name(tl.resource_database_id) AS databasename, 
       tl.resource_type, 
       tl.request_mode, 
       tl.resource_associated_entity_id,
       tl.request_lifetime,
       wt.wait_duration_ms/1000 as duration,
       wt.wait_type
FROM   sys.dm_tran_locks AS tl 
       INNER JOIN sys.dm_os_waiting_tasks AS wt 
         ON tl.lock_owner_address = wt.resource_address; 
GO

-- TOP20 QUERIES PARALELISMO
WITH cQueryStats
AS (
SELECT qs.plan_handle
,MAX(qs.execution_count) as execution_count
,SUM(qs.total_worker_time) as total_worker_time
,SUM(qs.total_logical_reads) as total_logical_reads
,SUM(qs.total_elapsed_time) as total_elapsed_time
FROM sys.dm_exec_query_stats qs
GROUP BY qs.plan_handle
)
SELECT TOP 20
OBJECT_NAME(p.objectid, p.dbid) as [object_name] ,qs.execution_count
,qs.total_worker_time
,qs.total_logical_reads
,qs.total_elapsed_time
,p.query_plan
,q.text
,cp.plan_handle
FROM cQueryStats qs
INNER JOIN sys.dm_exec_cached_plans cp ON qs.plan_handle = cp.plan_handle
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) p
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) as q
WHERE cp.cacheobjtype = 'Compiled Plan'
AND p.query_plan.value('declare namespace p="http://schemas.microsoft.com/sqlserver/2004/07/showplan";max(//p:RelOp/@Parallel)', 'float') > 0
ORDER BY qs.total_worker_time/qs.execution_count DESC


SELECT TOP 10 
[Qt de Exec] = qs.execution_count
,[Query] = SUBSTRING (qt.text,qs.statement_start_offset/2, 
         (CASE WHEN qs.statement_end_offset = -1 
            THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2 
          ELSE qs.statement_end_offset END - qs.statement_start_offset)/2) 
--,[Parent Query] = qt.text
--,DatabaseName = DB_NAME(qt.dbid)
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt
ORDER BY qs.execution_count DESC;


-- Permissoes
xp_cmdshell 'whoami /priv'

-- Memoria troubleshooting
http://fabriciolima.net/blog/2010/12/25/casos-do-dia-a-dia-diminuindo-um-problema-de-memoria-no-sql-server/


-- Duplicata exata (SQL 2005)	
with indexcols as
(
select TableID = IX.[object_id],
index_id ,
name,
( select case keyno when 0 then NULL else colid end as [data()]
from sys.sysindexkeys as IXKeys1
where IXKeys1.id = IX.[object_id]
and IXKeys1.indid = IX.index_id
order by keyno, colid
for xml path('')
) as cols,
( select case keyno when 0 then colid else NULL end as [data()]
from sys.sysindexkeys as IXKeys2
where IXKeys2.id = IX.[object_id]
and IXKeys2.indid = IX.index_id
order by colid
for xml path('')
) as inc
from sys.indexes as IX
)
select
'ServerChecked' = @@Serv	ername,
'DataBaseChecked' = DB_Name(),
'DateChecked_UTC' = GETUTCDATE(),
'TableName' = object_schema_name(IndexSet1.TableID)
+ '.' + object_name(IndexSet1.TableID),
'IndexName' = IndexSet1.name,
'ExactDuplicateIndexName' = IndexSet2.name,
'SpaceUsed_MB_ByDuplicate' = (SIx.Reserved)/128.0, --*8 to KB, / 1024 to MB = nett / 128.
'RowsIn_Duplicate' = SIx.[rows],
'DuplicateIndex_Usage' = (DupIXUsage.user_seeks + DupIXUsage.user_scans + DupIXUsage.user_lookups),
'DuplicateIndex_Updates' = (DupIXUsage.user_updates)
from indexcols as IndexSet1
join indexcols as IndexSet2
on IndexSet1.TableID = IndexSet2.TableID
and IndexSet1.index_id < IndexSet2.index_id
and IndexSet1.cols = IndexSet2.cols
and IndexSet1.inc = IndexSet2.inc
left join sys.sysindexes SIx
on IndexSet2.name = SIx.name
and IndexSet2.TableID = SIx.[id]
left join sys.dm_db_index_usage_stats DupIXUsage
on IndexSet2.TableID = DupIXUsage.[object_id]
and IndexSet2.index_id = DupIXUsage.index_id
and DupIXUsage.Database_id = db_id() --current database
Order by
TableName, IndexName, ExactDuplicateIndexName 

--Identifying Queries Most Often Blocked 
SELECT TOP 20 
 [Average Time Blocked] = (total_elapsed_time - total_worker_time) / qs.execution_count
,[Total Time Blocked] = total_elapsed_time - total_worker_time 
,[Execution count] = qs.execution_count
,[Individual Query] = SUBSTRING (qt.text,qs.statement_start_offset/2, 
         (CASE WHEN qs.statement_end_offset = -1 
            THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2 
          ELSE qs.statement_end_offset END - qs.statement_start_offset)/2) 
,[Parent Query] = qt.text
,DatabaseName = DB_NAME(qt.dbid)
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt
ORDER BY [Average Time Blocked] DESC;


-- Verificação do logshipping (rodar no standby)

select     convert(nvarchar(4),his.session_id),
                convert(nvarchar(256),his.database_name),
                convert(char(1),session_status),
                convert(nvarchar(20),his.log_time),
                convert(nvarchar(4000),message)
                from msdb.dbo.log_shipping_monitor_history_detail his
                inner join (select database_name, max(log_time) as log_time
                            from msdb..log_shipping_monitor_history_detail
                                group by database_name) q2
                on his.log_time = q2.log_time    and his.database_name = q2.database_name
                where message like 'The restore %'
                and his.database_name is not null
                and his.database_name <> 'db_principal_teste'
                order by his.log_time desc
                
           
-- VERIFICAÇÃO DE TODOS JOBS

SET NOCOUNT ON
--Checking for SQL Server verion
IF CONVERT(tinyint,(SUBSTRING(CONVERT(CHAR(1),SERVERPROPERTY('productversion')),1,1))) <> 8
BEGIN
---This is for SQL 2k5 and SQL2k8 servers
SET NOCOUNT ON
SELECT Convert(varchar(20),SERVERPROPERTY('ServerName')) AS ServerName,
j.name AS job_name,
CASE j.enabled WHEN 1 THEN 'Enabled' Else 'Disabled' END AS job_status,
CASE jh.run_status WHEN 0 THEN 'Error Failed'
				WHEN 1 THEN 'Succeeded'
				WHEN 2 THEN 'Retry'
				WHEN 3 THEN 'Cancelled'
				WHEN 4 THEN 'In Progress' ELSE
				'Status Unknown' END AS 'last_run_status',
ja.run_requested_date as last_run_date,
CONVERT(VARCHAR(10),CONVERT(DATETIME,RTRIM(19000101))+(jh.run_duration * 9 + jh.run_duration % 10000 * 6 + jh.run_duration % 100 * 10) / 216e4,108) AS run_duration,
ja.next_scheduled_run_date,
CONVERT(VARCHAR(500),jh.message) AS step_description
FROM
(msdb.dbo.sysjobactivity ja LEFT JOIN msdb.dbo.sysjobhistory jh ON ja.job_history_id = jh.instance_id)
join msdb.dbo.sysjobs_view j on ja.job_id = j.job_id
WHERE ja.session_id=(SELECT MAX(session_id)  from msdb.dbo.sysjobactivity) ORDER BY job_name,job_status
END
ELSE
BEGIN
--This is for SQL2k servers
SET NOCOUNT ON
DECLARE @SQL VARCHAR(5000)
--Getting information from sp_help_job to a temp table
SET @SQL='SELECT job_id,name AS job_name,CASE enabled WHEN 1 THEN ''Enabled'' ELSE ''Disabled'' END AS job_status,
CASE last_run_outcome WHEN 0 THEN ''Error Failed''
				WHEN 1 THEN ''Succeeded''
				WHEN 2 THEN ''Retry''
				WHEN 3 THEN ''Cancelled''
				WHEN 4 THEN ''In Progress'' ELSE
				''Status Unknown'' END AS  last_run_status,
CASE RTRIM(last_run_date) WHEN 0 THEN 19000101 ELSE last_run_date END last_run_date,
CASE RTRIM(last_run_time) WHEN 0 THEN 235959 ELSE last_run_time END last_run_time, 
CASE RTRIM(next_run_date) WHEN 0 THEN 19000101 ELSE next_run_date END next_run_date, 
CASE RTRIM(next_run_time) WHEN 0 THEN 235959 ELSE next_run_time END next_run_time,
last_run_date AS lrd, last_run_time AS lrt
INTO ##jobdetails
FROM OPENROWSET(''sqloledb'', ''server=(local);trusted_connection=yes'', ''set fmtonly off exec msdb.dbo.sp_help_job'')'
exec (@SQL)
--Merging run date & time format, adding run duration and adding step description
select Convert(varchar(20),SERVERPROPERTY('ServerName')) AS ServerName,jd.job_name,jd.job_status,jd.last_run_status,
CONVERT(DATETIME,RTRIM(jd.last_run_date)) +(jd.last_run_time * 9 + jd.last_run_time % 10000 * 6 + jd.last_run_time % 100 * 10) / 216e4 AS last_run_date,
CONVERT(VARCHAR(10),CONVERT(DATETIME,RTRIM(19000101))+(jh.run_duration * 9 + jh.run_duration % 10000 * 6 + jh.run_duration % 100 * 10) / 216e4,108) AS run_duration,
CONVERT(DATETIME,RTRIM(jd.next_run_date)) +(jd.next_run_time * 9 + jd.next_run_time % 10000 * 6 + jd.next_run_time % 100 * 10) / 216e4 AS next_scheduled_run_date,
CONVERT(VARCHAR(500),jh.message) AS step_description
from (##jobdetails jd  LEFT JOIN  msdb.dbo.sysjobhistory jh ON jd.job_id=jh.job_id AND jd.lrd=jh.run_date AND jd.lrt=jh.run_time) where step_id=0 or step_id is null
order by jd.job_name,jd.job_status
--dropping the temp table
drop table ###jobdetails
END

-- LATCHES

-- http://sqlskills.com/BLOGS/PAUL/Default.aspx#p3

WITH [Latches] AS
    (SELECT
        [latch_class],
        [wait_time_ms] / 1000.0 AS [WaitS],
        [waiting_requests_count] AS [WaitCount],
        100.0 * [wait_time_ms] / SUM ([wait_time_ms]) OVER() AS [Percentage],
        ROW_NUMBER() OVER(ORDER BY [wait_time_ms] DESC) AS [RowNum]
    FROM sys.dm_os_latch_stats
    WHERE [latch_class] NOT IN (
        N'BUFFER')
    AND [wait_time_ms] > 0
    )
SELECT
    [W1].[latch_class] AS [LatchClass],
    CAST ([W1].[WaitS] AS DECIMAL(14, 2)) AS [Wait_S],
    [W1].[WaitCount] AS [WaitCount],
    CAST ([W1].[Percentage] AS DECIMAL(14, 2)) AS [Percentage],
    CAST (([W1].[WaitS] / [W1].[WaitCount]) AS DECIMAL (14, 4)) AS [AvgWait_S]
FROM [Latches] AS [W1]
INNER JOIN [Latches] AS [W2]
    ON [W2].[RowNum] <= [W1].[RowNum]
WHERE [W1].[WaitCount] > 0
GROUP BY [W1].[RowNum], [W1].[latch_class], [W1].[WaitS], [W1].[WaitCount], [W1].[Percentage]
HAVING SUM ([W2].[Percentage]) - [W1].[Percentage] < 95; -- percentage threshold
GO 




-- extended event: query que funciona no SQL2005 RTM

    SELECT CAST (
        REPLACE (
            REPLACE (
                XEventData.XEvent.value ('(data/value)[1]', 'varchar(max)'),
                '<victim-list>', '<deadlock><victim-list>'),
            '<process-list>', '</victim-list><process-list>')
        AS XML) AS DeadlockGraph
    FROM (SELECT CAST (target_data AS XML) AS TargetData
        FROM sys.dm_xe_session_targets st
        JOIN sys.dm_xe_sessions s ON s.address = st.event_session_address
        WHERE [name] = 'system_health') AS Data
    CROSS APPLY TargetData.nodes ('//RingBufferTarget/event') AS XEventData (XEvent)
        WHERE XEventData.XEvent.value('@name', 'varchar(4000)') = 'xml_deadlock_report';


-- PESQUISA JOB SQL AGENT SEARCH

--2008

USE [msdb]
GO
SELECT	j.job_id,
	s.srvname,
	j.name,
	js.step_id,
	js.command,
	j.enabled 
FROM	dbo.sysjobs j
JOIN	dbo.sysjobsteps js
	ON	js.job_id = j.job_id 
JOIN	master.dbo.sysservers s
	ON	s.srvid = j.originating_server_id
WHERE	js.command LIKE N'%@belmetal.com.br%'
GO

--2000

USE [msdb]	
GO
SELECT	j.job_id,
	j.originating_server,
	j.name,
	js.step_id,
	js.command,
	j.enabled 
FROM	dbo.sysjobs j
JOIN	dbo.sysjobsteps js
	ON	js.job_id = j.job_id 
WHERE	js.command LIKE N'%KEYWORD_SEARCH%'
GO


-- sp_whoisactive comandos p/ filtrar

select *
	from LOG_WhoIsActive
	where wait_info is not null
	and login_name <> 'mcassab\mcspadmin'
	order by 1 desc


/*

DECLARE @Comando varchar (4000),
		@Banco	 varchar (0100),
		@Caminho varchar (0500)
		
SELECT @Caminho = 'D:\Backup\MSSQL\PlanoPadrao\'
		
DECLARE cBancos CURSOR FOR    
	SELECT name FROM sys.databases
	WHERE name in ('sgi_belcorpbr', 'sgi_belcorpbr_olap', 'sgi_aretta', 'sgi_aretta_olap', 'sgi_b1',
					'sgi_daterra', 'sgi_daterra_olap', 'sgi_estrutura_geo_2', 'sgi_estrutura_geo_3', 
					'sgi_estrutura_geo_4', 'sgi_gera_db', 'sgi_gera_eai_b2_sap', 'sgi_gera_olap',
					'sgi_transferencia_dados', 'sgi_jnjco', 'sgi_jnjco_olap', 'sgi_gera',
					'sgi_hml_jnjco', 'sgi_hml_jnjco_olap', 'master', 'msdb')
					
	OPEN cBancos     
	FETCH NEXT FROM cBancos INTO @Banco    

	WHILE @@FETCH_STATUS = 0     
	BEGIN     
		SELECT @Comando = 'D:\CLSoftware\util\MSSQLCompressedBackup\msbp.exe backup "db(database=' +  @Banco + 
		';instancename=GERASQL;clusternetworkname=GERA-CLSQL;backuptype=full)" "gzip(level=4)" "local(path=' + @Caminho + @Banco + 
		'.bak.gz)"' 
		EXEC xp_cmdshell @Comando
		--PRINT @Comando
		FETCH NEXT FROM cBancos INTO @Banco    
	END
CLOSE cBancos     
DEALLOCATE cBancos 

*/
-- volumetria
SELECT right (convert (varchar (6), b.backup_finish_date, 112), 2) + '/' + left (convert (varchar (6), b.backup_finish_date, 112), 4), replace (convert (decimal (9, 2), avg (b.backup_size/1048576)), '.', ',')
FROM  msdb.dbo.backupset b
WHERE  type in ('D')
and b.database_name = 'sgi_natura_chile'
group by right (convert (varchar (6), b.backup_finish_date, 112), 2) + '/' + left (convert (varchar (6), b.backup_finish_date, 112), 4)
ORDER BY 1 asc






DECLARE @endDate datetime, @months smallint;
SET @endDate = GetDate();  -- Include in the statistic all backups from today
SET @months = 6;           -- back to the last 6 months.

;WITH HIST AS
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
          ORDER BY SUB.YearMonth DESC) AS GrowthMB
FROM HIST AS MAIN
ORDER BY MAIN.DatabaseName
        ,MAIN.YearMonth

-- AUDITORIA

-- SERVER-LEVEL PERMISSIONS

SELECT SP1.[name] AS 'Login', 'Role: ' + SP2.[name] COLLATE DATABASE_DEFAULT AS 'ServerPermission' 
FROM sys.server_principals SP1
  JOIN sys.server_role_members SRM
    ON SP1.principal_id = SRM.member_principal_id
  JOIN sys.server_principals SP2
    ON SRM.role_principal_id = SP2.principal_id
UNION ALL
SELECT SP.[name] AS 'Login' , SPerm.state_desc + ' ' + SPerm.permission_name COLLATE DATABASE_DEFAULT AS 'ServerPermission'  FROM sys.server_principals SP 
  JOIN sys.server_permissions SPerm 
    ON SP.principal_id = SPerm.grantee_principal_id 
ORDER BY [Login], [ServerPermission]; 

-- DATABASE-LEVEL PERMISSIONS

declare @database nvarchar(128)   
declare @user varchar(20)   
declare @dbo char(1)   
declare @access char(1)   
declare @security char(1)   
declare @ddl char(1)   
declare @datareader char(1)   
declare @datawriter char(1)   
declare @denyread char(1)   
declare @denywrite char(1)  
declare @dbname varchar(200) 
declare @mSql1 varchar(8000)

CREATE TABLE #DBROLES

( DBName sysname not null,
UserName sysname not null,
db_owner varchar(3) not null,
db_accessadmin varchar(3) not null,
db_securityadmin varchar(3) not null,
db_ddladmin varchar(3) not null,
db_datareader varchar(3) not null,
db_datawriter varchar(3) not null,
db_denydatareader varchar(3) not null,
db_denydatawriter varchar(3) not null,
Cur_Date datetime not null default getdate()
)

DECLARE DBName_Cursor CURSOR FOR
select name
from master.dbo.sysdatabases
where name not in ('mssecurity','tempdb')
Order by name
OPEN DBName_Cursor
FETCH NEXT FROM DBName_Cursor INTO @dbname
WHILE @@FETCH_STATUS = 0
BEGIN

Set @mSQL1 = ' Insert into #DBROLES ( DBName, UserName, db_owner, db_accessadmin,
db_securityadmin, db_ddladmin, db_datareader, db_datawriter,
db_denydatareader, db_denydatawriter )
SELECT '+''''+@dbName +''''+ ' as DBName ,UserName, '+char(13)+ '
Max(CASE RoleName WHEN ''db_owner'' THEN ''Yes'' ELSE ''No'' END) AS db_owner,
Max(CASE RoleName WHEN ''db_accessadmin '' THEN ''Yes'' ELSE ''No'' END) AS db_accessadmin ,
Max(CASE RoleName WHEN ''db_securityadmin'' THEN ''Yes'' ELSE ''No'' END) AS db_securityadmin,
Max(CASE RoleName WHEN ''db_ddladmin'' THEN ''Yes'' ELSE ''No'' END) AS db_ddladmin,
Max(CASE RoleName WHEN ''db_datareader'' THEN ''Yes'' ELSE ''No'' END) AS db_datareader,
Max(CASE RoleName WHEN ''db_datawriter'' THEN ''Yes'' ELSE ''No'' END) AS db_datawriter,
Max(CASE RoleName WHEN ''db_denydatareader'' THEN ''Yes'' ELSE ''No'' END) AS db_denydatareader,
Max(CASE RoleName WHEN ''db_denydatawriter'' THEN ''Yes'' ELSE ''No'' END) AS db_denydatawriter
from (
select b.name as USERName, c.name as RoleName
from ' + @dbName+'.dbo.sysmembers a '+char(13)+
' join '+ @dbName+'.dbo.sysusers b '+char(13)+
' on a.memberuid = b.uid join '+@dbName +'.dbo.sysusers c
on a.groupuid = c.uid )s
Group by USERName
order by UserName'

Execute (@mSql1)
FETCH NEXT FROM DBName_Cursor INTO @dbname
END

CLOSE DBName_Cursor
DEALLOCATE DBName_Cursor

Select * from #DBRoles
where ((@database is null) OR (DBName LIKE '%'+@database+'%')) AND
((@user is null) OR (UserName LIKE '%'+@user+'%')) AND
((@dbo is null) OR (db_owner = 'Yes')) AND
((@access is null) OR (db_accessadmin = 'Yes')) AND
((@security is null) OR (db_securityadmin = 'Yes')) AND
((@ddl is null) OR (db_ddladmin = 'Yes')) AND
((@datareader is null) OR (db_datareader = 'Yes')) AND
((@datawriter is null) OR (db_datawriter = 'Yes')) AND
((@denyread is null) OR (db_denydatareader = 'Yes')) AND
((@denywrite is null) OR (db_denydatawriter = 'Yes'))

DROP TABLE #DBROLES

-- Queries BANCO vs CPU

WITH DB_CPU_Stats
AS
(SELECT DatabaseID, DB_Name(DatabaseID) AS [DatabaseName], SUM(total_worker_time) AS [CPU_Time_Ms]
 FROM sys.dm_exec_query_stats AS qs
 CROSS APPLY (SELECT CONVERT(int, value) AS [DatabaseID] 
              FROM sys.dm_exec_plan_attributes(qs.plan_handle)
              WHERE attribute = N'dbid') AS F_DB
 GROUP BY DatabaseID)
SELECT ROW_NUMBER() OVER(ORDER BY [CPU_Time_Ms] DESC) AS [row_num],
       DatabaseName, [CPU_Time_Ms], 
       CAST([CPU_Time_Ms] * 1.0 / SUM([CPU_Time_Ms]) OVER() * 100.0 AS DECIMAL(5, 2)) AS [CPUPercent]
FROM DB_CPU_Stats
WHERE DatabaseID > 4 -- system databases
AND DatabaseID <> 32767 -- ResourceDB
ORDER BY row_num OPTION (RECOMPILE);


--- 



create table #xp_readerrorlog (LogDate datetime, ProcessInfo nvarchar(128), Text nvarchar(max))

insert into #xp_readerrorlog (LogDate, ProcessInfo, Text) exec xp_readerrorlog
insert into #xp_readerrorlog (LogDate, ProcessInfo, Text) exec xp_readerrorlog 1

select count(*) from #xp_readerrorlog

select Text + ' - Tentativas:' + convert(nvarchar(10),count(*)), count(*)
from #xp_readerrorlog
where Text like '%Login failed%'
group by Text
order by 2 desc

select  Text, count(*) from #xp_readerrorlog
where Text  NOT LIKE '%Login failed%'
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
					 AND LogDate >= (GETDATE()-15)
group by Text
order by 2 desc





SELECT UseCounts, Cacheobjtype, Objtype, TEXT, query_plan
FROM sys.dm_exec_cached_plans 
CROSS APPLY sys.dm_exec_sql_text(plan_handle)
CROSS APPLY sys.dm_exec_query_plan(plan_handle)
WHERE text LIKE '%%'






DECLARE @Inicio int,
		@Fim	int,
		@cmd	varchar (1000)
				
SELECT @Inicio = 300000

SELECT @Fim = 100000

WHILE (@Inicio >= @Fim)
BEGIN
    SELECT @cmd = 'DBCC SHRINKFILE (N''gerasgi_jequiti_Data'' , ' + convert (varchar, @Inicio) + ')'
    SELECT @Inicio
    EXEC (@cmd)
    SET @Inicio = @Inicio - 1000
END
GO






SELECT
[database_name] AS "Database",
RIGHT(CONVERT(CHAR(10),backup_start_date,103),7) AS 'Month',
replace (convert (decimal (10, 2), AVG([backup_size]/1024/1024)), '.', ',') AS "Backup Size MB"
FROM msdb.dbo.backupset
WHERE [database_name] = N'sgi_natura_argentina_olap'
AND [type] = 'D'
GROUP BY [database_name], RIGHT(CONVERT(CHAR(10),backup_start_date,103),7)

SELECT DISTINCT
    SUBSTRING(volume_mount_point, 1, 1) AS Drive
    ,total_bytes/1024/1024 AS Total_MB
    ,available_bytes/1024/1024 AS Available_MB
FROM
    sys.master_files AS f
CROSS APPLY
    sys.dm_os_volume_stats(f.database_id, f.file_id);
    




;WITH connectivity_ring_buffer as 
(SELECT
record.value('(Record/@id)[1]', 'int') as id,
record.value('(Record/@type)[1]', 'varchar(50)') as type,
record.value('(Record/ConnectivityTraceRecord/RecordType)[1]', 'varchar(50)') as RecordType,
record.value('(Record/ConnectivityTraceRecord/RecordSource)[1]', 'varchar(50)') as RecordSource,
record.value('(Record/ConnectivityTraceRecord/Spid)[1]', 'int') as Spid,
record.value('(Record/ConnectivityTraceRecord/SniConnectionId)[1]', 'uniqueidentifier') as SniConnectionId,
record.value('(Record/ConnectivityTraceRecord/SniProvider)[1]', 'int') as SniProvider,
record.value('(Record/ConnectivityTraceRecord/OSError)[1]', 'int') as OSError,
record.value('(Record/ConnectivityTraceRecord/SniConsumerError)[1]', 'int') as SniConsumerError,
record.value('(Record/ConnectivityTraceRecord/State)[1]', 'int') as State,
record.value('(Record/ConnectivityTraceRecord/RemoteHost)[1]', 'varchar(50)') as RemoteHost,
record.value('(Record/ConnectivityTraceRecord/RemotePort)[1]', 'varchar(50)') as RemotePort,
record.value('(Record/ConnectivityTraceRecord/LocalHost)[1]', 'varchar(50)') as LocalHost,
record.value('(Record/ConnectivityTraceRecord/LocalPort)[1]', 'varchar(50)') as LocalPort,
record.value('(Record/ConnectivityTraceRecord/RecordTime)[1]', 'datetime') as RecordTime,
record.value('(Record/ConnectivityTraceRecord/LoginTimers/TotalLoginTimeInMilliseconds)[1]', 'bigint') as TotalLoginTimeInMilliseconds,
record.value('(Record/ConnectivityTraceRecord/LoginTimers/LoginTaskEnqueuedInMilliseconds)[1]', 'bigint') as LoginTaskEnqueuedInMilliseconds,
record.value('(Record/ConnectivityTraceRecord/LoginTimers/NetworkWritesInMilliseconds)[1]', 'bigint') as NetworkWritesInMilliseconds,
record.value('(Record/ConnectivityTraceRecord/LoginTimers/NetworkReadsInMilliseconds)[1]', 'bigint') as NetworkReadsInMilliseconds,
record.value('(Record/ConnectivityTraceRecord/LoginTimers/SslProcessingInMilliseconds)[1]', 'bigint') as SslProcessingInMilliseconds,
record.value('(Record/ConnectivityTraceRecord/LoginTimers/SspiProcessingInMilliseconds)[1]', 'bigint') as SspiProcessingInMilliseconds,
record.value('(Record/ConnectivityTraceRecord/LoginTimers/LoginTriggerAndResourceGovernorProcessingInMilliseconds)[1]', 'bigint') as LoginTriggerAndResourceGovernorProcessingInMilliseconds,
record.value('(Record/ConnectivityTraceRecord/TdsBuffersInformation/TdsInputBufferError)[1]', 'int') as TdsInputBufferError,
record.value('(Record/ConnectivityTraceRecord/TdsBuffersInformation/TdsOutputBufferError)[1]', 'int') as TdsOutputBufferError,
record.value('(Record/ConnectivityTraceRecord/TdsBuffersInformation/TdsInputBufferBytes)[1]', 'int') as TdsInputBufferBytes,
record.value('(Record/ConnectivityTraceRecord/TdsDisconnectFlags/PhysicalConnectionIsKilled)[1]', 'int') as PhysicalConnectionIsKilled,
record.value('(Record/ConnectivityTraceRecord/TdsDisconnectFlags/DisconnectDueToReadError)[1]', 'int') as DisconnectDueToReadError,
record.value('(Record/ConnectivityTraceRecord/TdsDisconnectFlags/NetworkErrorFoundInInputStream)[1]', 'int') as NetworkErrorFoundInInputStream,
record.value('(Record/ConnectivityTraceRecord/TdsDisconnectFlags/ErrorFoundBeforeLogin)[1]', 'int') as ErrorFoundBeforeLogin,
record.value('(Record/ConnectivityTraceRecord/TdsDisconnectFlags/SessionIsKilled)[1]', 'int') as SessionIsKilled,
record.value('(Record/ConnectivityTraceRecord/TdsDisconnectFlags/NormalDisconnect)[1]', 'int') as NormalDisconnect
--record.value('(Record/ConnectivityTraceRecord/TdsDisconnectFlags/NormalLogout)[1]', 'int') as NormalLogout
FROM
( SELECT CAST(record as xml) as record
FROM sys.dm_os_ring_buffers
WHERE ring_buffer_type = 'RING_BUFFER_CONNECTIVITY') as tab
)
SELECT c.RecordTime,m.[text],* 
FROM connectivity_ring_buffer c 
    LEFT JOIN sys.messages m ON c.SniConsumerError = m.message_id AND m.language_id = 1033 
ORDER BY c.RecordTime DESC    
















--	2005 - QUERY MASTER - MASTER
select
	ses.session_id,
	datediff(second, ses.last_request_start_time, getdate()),
		substring(qry.text, (req.statement_start_offset/2),
		(case req.statement_end_offset/2 when 0 then datalength(qry.text)
		else req.statement_end_offset/2 end) - (req.statement_start_offset/2)) as query_text,
	req.cpu_time,
	db_name(req.database_id) as database_name,
	wt.wait_duration_ms,
	wt.wait_type,
	wt.blocking_session_id,
	wt.resource_description,
	ses.host_name,
	ses.host_process_id,
	ses.login_name,
	ses.status,
	ses.last_request_start_time,
	case ses.transaction_isolation_level
	when 0 then 'Unspecified'
	when 1 then 'ReadUncomitted'
	when 2 then 'ReadCommitted'
	when 3 then 'Repeatable'
	when 4 then 'Serializable'
	when 5 then 'Snapshot'
	end as transaction_isolation_leve
from
	sys.dm_exec_sessions as ses
	inner join
	sys.dm_exec_requests as req
		on ses.session_id = req.session_id
	left join
	sys.dm_os_waiting_tasks as wt
		on ses.session_id = wt.session_id
	cross apply
	sys.dm_exec_sql_text(req.sql_handle) as qry
	cross apply
	sys.dm_exec_text_query_plan(req.plan_handle, req.statement_start_offset, req.statement_end_offset) as pln
where
	ses.is_user_process = 1
	and (ses.session_id > @@spid
	or ses.session_id < @@spid)
order by req.cpu_time desc


/*
exec sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL'  
exec sp_MSforeachtable 'ALTER TABLE ? DISABLE TRIGGER ALL'  
exec sp_MSforeachtable 'DELETE FROM ?'  
exec sp_MSforeachtable 'ALTER TABLE ? CHECK CONSTRAINT ALL'  
exec sp_MSforeachtable 'ALTER TABLE ? ENABLE TRIGGER ALL' 
exec sp_MSforeachtable 'IF NOT EXISTS (SELECT *
    FROM SYS.IDENTITY_COLUMNS
    JOIN SYS.TABLES ON SYS.IDENTITY_COLUMNS.Object_ID = SYS.TABLES.Object_ID
    WHERE SYS.TABLES.Object_ID = OBJECT_ID(''?'') AND SYS.IDENTITY_COLUMNS.Last_Value IS NULL)
    AND OBJECTPROPERTY(OBJECT_ID(''?''), ''TableHasIdentity'') = 1
    DBCC CHECKIDENT (''?'', RESEED, 0) WITH NO_INFOMSGS'
 
LIMPA TABELA

*/





SELECT TOP 20
    qs.sql_handle,
    qs.execution_count,
    qs.total_worker_time AS Total_CPU,
    total_CPU_inSeconds = --Converted from microseconds
    qs.total_worker_time/1000000,
    average_CPU_inSeconds = --Converted from microseconds
    (qs.total_worker_time/1000000) / qs.execution_count,
    qs.total_elapsed_time,
    total_elapsed_time_inSeconds = --Converted from microseconds
    qs.total_elapsed_time/1000000,
    st.text,
    qp.query_plan
FROM
    sys.dm_exec_query_stats AS qs
        CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
        CROSS apply sys.dm_exec_query_plan (qs.plan_handle) AS qp
		WHERE text LIKE '%TB_SOLICITACAO_FATURAMENTO_PEDID%'
		And qs.execution_count > 5
ORDER BY qs.total_worker_time desc

 
--------------------------------------------------------------------------
select *, QT_RUN_TICKS / 10000000 / 60 'MINUTOS'
	from TB_SCH_JOB_HISTORY
	where cd_job = 8
	and convert (varchar (20), datepart (hour, DT_JOB_RUN), 120) = 0
-------------------------------------------------------------------------- 
DECLARE @Mensagem varchar (8000)

CREATE TABLE #LOG_WhoIsActive ( [dd hh:mm:ss.mss] varchar(8000) NULL,[session_id] smallint NOT NULL,[sql_text] xml NULL,[login_name] nvarchar(128) NOT NULL,[wait_info] nvarchar(4000) NULL,[CPU] varchar(30) NULL,[tempdb_allocations] varchar(30) NULL,[tempdb_current] varchar(30) NULL,[blocking_session_id] smallint NULL,[blocked_session_count] varchar(30) NULL,[reads] varchar(30) NULL,[writes] varchar(30) NULL,[physical_reads] varchar(30) NULL,[used_memory] varchar(30) NULL,[status] varchar(30) NOT NULL,[open_tran_count] varchar(30) NULL,[percent_complete] varchar(30) NULL,[host_name] nvarchar(128) NULL,[database_name] nvarchar(128) NULL,[program_name] nvarchar(128) NULL,[start_time] datetime NOT NULL,[login_time] datetime NULL,[request_id] int NULL,[collection_time] datetime NOT NULL)

EXEC dbo.sp_WhoIsActive @find_block_leaders = 1, @DESTINATION_TABLE = '#LOG_WhoIsActive' 

SELECT *
       FROM #LOG_WhoIsActive
       WHERE blocked_session_count > 0
       AND blocking_session_id IS NULL
         ORDER BY blocked_session_count DESC

SELECT *
       FROM #LOG_WhoIsActive
       WHERE wait_info LIKE '%LCK%'
		   
DROP TABLE #LOG_WhoIsActive

------------------------------------------------------------------------------------------------------------------------

SELECT TOP 10 SUBSTRING(qt.TEXT, (qs.statement_start_offset/2)+1,
((CASE qs.statement_end_offset
WHEN -1 THEN DATALENGTH(qt.TEXT)
ELSE qs.statement_end_offset
END - qs.statement_start_offset)/2)+1),
qs.execution_count,
qs.total_logical_reads, qs.last_logical_reads,
qs.total_logical_writes, qs.last_logical_writes,
qs.total_worker_time,
qs.last_worker_time,
qs.total_elapsed_time/1000000 total_elapsed_time_in_S,
qs.last_elapsed_time/1000000 last_elapsed_time_in_S,
qs.last_execution_time,
(qs.total_elapsed_time/1000000)/qs.execution_count,
qp.query_plan
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
WHERE (qs.total_elapsed_time/1000000)/qs.execution_count >=1
AND qs.execution_count > 100
--ORDER BY qs.total_worker_time DESC -- CPU time
ORDER BY qs.total_logical_reads DESC -- logical reads
--ORDER BY qs.total_logical_writes DESC -- logical writes
------------------------------------------------------------------------------------------------------------------------
-- alocação allocation CLR

select single_pages_kb + multi_pages_kb + virtual_memory_committed_kb from sys.dm_os_memory_clerks where type = 'MEMORYCLERK_SQLCLR'
------------------------------------------------------------------------------------------------------------------------
SELECT
	CAST(total_elapsed_time / 1000000.0 AS DECIMAL(28, 2)) AS [Total Duration (s)]
	, CAST(total_worker_time * 100.0 / total_elapsed_time AS DECIMAL(28, 2)) AS [% CPU]
	, CAST((total_elapsed_time - total_worker_time)* 100.0 /
	total_elapsed_time AS DECIMAL(28, 2)) AS [% Waiting]
	, execution_count
	, CAST(total_elapsed_time / 1000000.0 / execution_count AS DECIMAL(28, 2)) AS [Average Duration (s)]
	, SUBSTRING (qt.text,(qs.statement_start_offset/2) + 1,
	 ((CASE WHEN qs.statement_end_offset = -1
	 THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2
	 ELSE qs.statement_end_offset
	 END - qs.statement_start_offset)/2) + 1) AS [Individual Query]
	, SUBSTRING(qt.text,1,100) AS [Parent Query]
	, DB_NAME(qt.dbid) AS DatabaseName

FROM sys.dm_exec_query_stats qs
	CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt
	WHERE total_elapsed_time > 0
	ORDER BY total_elapsed_time DESC
------------------------------------------------------------------------------------------------------------------------
SELECT CAST(total_elapsed_time / 1000000.0 AS DECIMAL(28, 2)) AS [Total Duration (s)]
	, CAST(total_worker_time * 100.0 / total_elapsed_time AS DECIMAL(28, 2)) AS [% CPU]
	, CAST((total_elapsed_time - total_worker_time)* 100.0 /
	total_elapsed_time AS DECIMAL(28, 2)) AS [% Waiting]
	, execution_count
	, qs.total_logical_reads
	, qs.total_logical_writes
	, CAST(total_elapsed_time / 1000000.0 / execution_count AS DECIMAL(28, 2)) AS [Average Duration (s)]
	, SUBSTRING (qt.text,(qs.statement_start_offset/2) + 1,
	 ((CASE WHEN qs.statement_end_offset = -1
	 THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2
	 ELSE qs.statement_end_offset
	 END - qs.statement_start_offset)/2) + 1) AS [Individual Query]
INTO BaselineQueries_06012014
FROM sys.dm_exec_query_stats qs
	CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt
	WHERE total_elapsed_time > 0
	AND SUBSTRING (qt.text,(qs.statement_start_offset/2) + 1,
	 ((CASE WHEN qs.statement_end_offset = -1
	 THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2
	 ELSE qs.statement_end_offset
	 END - qs.statement_start_offset)/2) + 1) LIKE '%sgi_marisa%'
                                                         
 WITH Waits AS
    (SELECT
        wait_type,
        wait_time_ms / 1000.0 AS WaitS,
        (wait_time_ms - signal_wait_time_ms) / 1000.0 AS ResourceS,
        signal_wait_time_ms / 1000.0 AS SignalS,
        waiting_tasks_count AS WaitCount,
        100.0 * wait_time_ms / SUM (wait_time_ms) OVER() AS Percentage,
        ROW_NUMBER() OVER(ORDER BY wait_time_ms DESC) AS RowNum
    FROM sys.dm_os_wait_stats
    WHERE wait_type NOT IN (
        'CLR_SEMAPHORE', 'LAZYWRITER_SLEEP', 'RESOURCE_QUEUE', 'SLEEP_TASK',
        'SLEEP_SYSTEMTASK', 'SQLTRACE_BUFFER_FLUSH', 'WAITFOR', 'LOGMGR_QUEUE',
        'CHECKPOINT_QUEUE', 'REQUEST_FOR_DEADLOCK_SEARCH', 'XE_TIMER_EVENT', 'BROKER_TO_FLUSH',
        'BROKER_TASK_STOP', 'CLR_MANUAL_EVENT', 'CLR_AUTO_EVENT', 'DISPATCHER_QUEUE_SEMAPHORE',
        'FT_IFTS_SCHEDULER_IDLE_WAIT', 'XE_DISPATCHER_WAIT', 'XE_DISPATCHER_JOIN', 'BROKER_EVENTHANDLER',
        'TRACEWRITE', 'FT_IFTSHC_MUTEX', 'SQLTRACE_INCREMENTAL_FLUSH_SLEEP', 'ONDEMAND_TASK_QUEUE')
     AND wait_type not like 'PREEMPTIVE%')
SELECT
     W1.wait_type AS WaitType,
     CAST (W1.WaitS AS DECIMAL(14, 2)) AS Wait_S,
     CAST (W1.ResourceS AS DECIMAL(14, 2)) AS Resource_S,
     CAST (W1.SignalS AS DECIMAL(14, 2)) AS Signal_S,
     W1.WaitCount AS WaitCount,
     CAST (W1.Percentage AS DECIMAL(4, 2)) AS Percentage
INTO BaselineWaits_06012014
FROM Waits AS W1
INNER JOIN Waits AS W2
     ON W2.RowNum <= W1.RowNum
GROUP BY W1.RowNum, W1.wait_type, W1.WaitS, W1.ResourceS, W1.SignalS, W1.WaitCount, W1.Percentage
HAVING SUM (W2.Percentage) - W1.Percentage < 95; -- percentage threshold
GO

