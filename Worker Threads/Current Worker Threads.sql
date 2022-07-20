SELECT 
	SUM(current_workers_count) as [Current worker thread] 
FROM sys.dm_os_schedulers