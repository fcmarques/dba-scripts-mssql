select * from sys.dm_os_waiting_tasks
where session_id <> @@SPID and session_id > 50
order by wait_duration_ms desc


select * from sys.dm_os_waiting_tasks
where session_id = 3289
order by wait_duration_ms desc

select * from sys.dm_exec_requests where session_id = 785


select * from sys.dm_exec_sessions where session_id = 785

select * from sys.dm_tran_session_transactions where session_id = 785
select * from sys.dm_tran_active_transactions where transaction_id = 89051459


dbcc inputbuffer(3202)

select cast(query_plan as xml) from sys.dm_exec_text_query_plan(0x060005006C35660540612F7C380000000000000000000000, 408, -1)



WITH Waits AS
(SELECT wait_type, wait_time_ms / 1000. AS wait_time_s,
100. * wait_time_ms / SUM(wait_time_ms) OVER() AS pct,
ROW_NUMBER() OVER(ORDER BY wait_time_ms DESC) AS rn
FROM sys.dm_os_wait_stats
WHERE wait_type NOT IN ('CLR_SEMAPHORE','LAZYWRITER_SLEEP','RESOURCE_QUEUE','SLEEP_TASK'
,'SLEEP_SYSTEMTASK','SQLTRACE_BUFFER_FLUSH','WAITFOR', 'LOGMGR_QUEUE','CHECKPOINT_QUEUE'
,'REQUEST_FOR_DEADLOCK_SEARCH','XE_TIMER_EVENT','BROKER_TO_FLUSH','BROKER_TASK_STOP','CLR_MANUAL_EVENT'
,'CLR_AUTO_EVENT','DISPATCHER_QUEUE_SEMAPHORE', 'FT_IFTS_SCHEDULER_IDLE_WAIT'
,'XE_DISPATCHER_WAIT', 'XE_DISPATCHER_JOIN', 'SQLTRACE_INCREMENTAL_FLUSH_SLEEP'))
SELECT W1.wait_type,
CAST(W1.wait_time_s AS DECIMAL(12, 2)) AS wait_time_s,
CAST(W1.pct AS DECIMAL(12, 2)) AS pct,
CAST(SUM(W2.pct) AS DECIMAL(12, 2)) AS running_pct
FROM Waits AS W1
INNER JOIN Waits AS W2
ON W2.rn <= W1.rn
GROUP BY W1.rn, W1.wait_type, W1.wait_time_s, W1.pct
HAVING SUM(W2.pct) - W1.pct < 99 OPTION (RECOMPILE); -- percentage threshold
GO


sp_configure 'cost threshold for parallelism', 300
reconfigure

select
CURRENT_TIMESTAMP as SnapShotTime,
db.name as DatabaseName,
mf.physical_name as FilePath,
mf.name as LogicalName,
vfs.*
from sys.dm_io_virtual_file_stats (NULL,NULL)
as vfs
join sys.master_files
as mf on vfs.database_id = mf.database_id and vfs.file_id = mf.file_id
join sys.databases
as db on vfs.database_id = db.database_id
order by num_of_reads


DBCC SQLPERF("sys.dm_os_wait_stats",CLEAR);
Go
