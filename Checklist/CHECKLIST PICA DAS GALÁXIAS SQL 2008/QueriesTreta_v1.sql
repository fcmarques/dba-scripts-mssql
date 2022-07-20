<<<<<<< HEAD
/*
 _____                 _             _____        _        
|  _  |               (_)           |_   _|      | |       
| | | |_   _  ___ _ __ _  ___  ___    | |_ __ ___| |_ __ _ 
| | | | | | |/ _ \ '__| |/ _ \/ __|   | | '__/ _ \ __/ _` |
\ \/' / |_| |  __/ |  | |  __/\__ \   | | | |  __/ || (_| |
 \_/\_\\__,_|\___|_|  |_|\___||___/   \_/_|  \___|\__\__,_|                                                   
				v1 - Stefano Gioia <stgioia@gmail.com>		 
				                                                                          
*/


sp_configure
-- maxdop recomendado
select 
    case 
        when cpu_count / hyperthread_ratio > 8 then 8
        else cpu_count / hyperthread_ratio
    end as optimal_maxdop_setting
from sys.dm_os_sys_info;    

sys.dm_os_sys_info 
sys.dm_os_nodes
                                                                    
-- Waits do Servidor
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
SELECT database_name, max (CONVERT (varchar (18), backup_finish_date, 120))
	FROM msdb..backupset
	GROUP BY database_name
	ORDER BY 1
	
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
	, cast(pln.query_plan as xml) as query_plan, GETDATE () 'data_hora'
into #DIGDIN 
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


-- Permissoes
xp_cmdshell 'whoami /priv'

-- Memoria troubleshooting
http://fabriciolima.net/blog/2010/12/25/casos-do-dia-a-dia-diminuindo-um-problema-de-memoria-no-sql-server/

=======
/*
 _____                 _             _____        _        
|  _  |               (_)           |_   _|      | |       
| | | |_   _  ___ _ __ _  ___  ___    | |_ __ ___| |_ __ _ 
| | | | | | |/ _ \ '__| |/ _ \/ __|   | | '__/ _ \ __/ _` |
\ \/' / |_| |  __/ |  | |  __/\__ \   | | | |  __/ || (_| |
 \_/\_\\__,_|\___|_|  |_|\___||___/   \_/_|  \___|\__\__,_|                                                   
				v1 - Stefano Gioia <stgioia@gmail.com>		 
				                                                                          
*/


sp_configure
-- maxdop recomendado
select 
    case 
        when cpu_count / hyperthread_ratio > 8 then 8
        else cpu_count / hyperthread_ratio
    end as optimal_maxdop_setting
from sys.dm_os_sys_info;    

sys.dm_os_sys_info 
sys.dm_os_nodes
                                                                    
-- Waits do Servidor
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
SELECT database_name, max (CONVERT (varchar (18), backup_finish_date, 120))
	FROM msdb..backupset
	GROUP BY database_name
	ORDER BY 1
	
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
	, cast(pln.query_plan as xml) as query_plan, GETDATE () 'data_hora'
into #DIGDIN 
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


-- Permissoes
xp_cmdshell 'whoami /priv'

-- Memoria troubleshooting
http://fabriciolima.net/blog/2010/12/25/casos-do-dia-a-dia-diminuindo-um-problema-de-memoria-no-sql-server/

>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
