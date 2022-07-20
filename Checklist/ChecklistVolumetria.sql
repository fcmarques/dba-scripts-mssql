<<<<<<< HEAD
---------  CPU and Memory and Disk ---------
SELECT cpu_count / 2 AS [Logical CPU Count], 
physical_memory_in_bytes/1048576 AS [Physical Memory (MB)],
(SELECT value FROM sys.configurations WHERE name = 'max server memory (MB)') as [Max Server Memory (MB)],
(SELECT SUM(CONVERT(decimal(10), size/128.0/1024)) FROM sys.master_files) AS [Total Size in (GB)]
FROM sys.dm_os_sys_info WITH (NOLOCK) OPTION (RECOMPILE);

---------  CPU Comnsumo  ---------
DECLARE @ts_now bigint = (SELECT cpu_ticks/(cpu_ticks/ms_ticks) FROM sys.dm_os_sys_info WITH (NOLOCK)); 

SELECT TOP(288) SQLProcessUtilization AS [SQL Server Process CPU Utilization],
               DATEADD(ms, -10 * (@ts_now - [timestamp]), GETDATE()) AS [Event Time] 
FROM ( 
	  SELECT record.value('(./Record/@id)[1]', 'int') AS record_id, 
			record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') 
			AS [SystemIdle], 
			record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 
			'int') 
			AS [SQLProcessUtilization], [timestamp] 
	  FROM ( 
			SELECT [timestamp], CONVERT(xml, record) AS [record] 
			FROM sys.dm_os_ring_buffers WITH (NOLOCK)
			WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR' 
			AND record LIKE N'%<SystemHealth>%') AS x 
	  ) AS y 
ORDER BY record_id DESC OPTION (RECOMPILE);

---------  Volumetria por database  ---------
SELECT DB_NAME([database_id]) AS [Database Name], 
       SUM(CONVERT(decimal(10,2), size/128.0/1024)) AS [Total Size in GB]
FROM sys.master_files WITH (NOLOCK)
WHERE [database_id] > 4 
AND [database_id] <> 32767
OR [database_id] = 2
group by DB_NAME([database_id])
ORDER BY DB_NAME([database_id]) OPTION (RECOMPILE);

---------  Volumetria Total ---------
SELECT SUM(CONVERT(decimal(10), size/128.0/1024)) AS [Total Size in GB]
FROM sys.master_files WITH (NOLOCK)
WHERE [database_id] > 4 
AND [database_id] <> 32767
=======
---------  CPU and Memory and Disk ---------
SELECT cpu_count / 2 AS [Logical CPU Count], 
physical_memory_in_bytes/1048576 AS [Physical Memory (MB)],
(SELECT value FROM sys.configurations WHERE name = 'max server memory (MB)') as [Max Server Memory (MB)],
(SELECT SUM(CONVERT(decimal(10), size/128.0/1024)) FROM sys.master_files) AS [Total Size in (GB)]
FROM sys.dm_os_sys_info WITH (NOLOCK) OPTION (RECOMPILE);

---------  CPU Comnsumo  ---------
DECLARE @ts_now bigint = (SELECT cpu_ticks/(cpu_ticks/ms_ticks) FROM sys.dm_os_sys_info WITH (NOLOCK)); 

SELECT TOP(288) SQLProcessUtilization AS [SQL Server Process CPU Utilization],
               DATEADD(ms, -10 * (@ts_now - [timestamp]), GETDATE()) AS [Event Time] 
FROM ( 
	  SELECT record.value('(./Record/@id)[1]', 'int') AS record_id, 
			record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') 
			AS [SystemIdle], 
			record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 
			'int') 
			AS [SQLProcessUtilization], [timestamp] 
	  FROM ( 
			SELECT [timestamp], CONVERT(xml, record) AS [record] 
			FROM sys.dm_os_ring_buffers WITH (NOLOCK)
			WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR' 
			AND record LIKE N'%<SystemHealth>%') AS x 
	  ) AS y 
ORDER BY record_id DESC OPTION (RECOMPILE);

---------  Volumetria por database  ---------
SELECT DB_NAME([database_id]) AS [Database Name], 
       SUM(CONVERT(decimal(10,2), size/128.0/1024)) AS [Total Size in GB]
FROM sys.master_files WITH (NOLOCK)
WHERE [database_id] > 4 
AND [database_id] <> 32767
OR [database_id] = 2
group by DB_NAME([database_id])
ORDER BY DB_NAME([database_id]) OPTION (RECOMPILE);

---------  Volumetria Total ---------
SELECT SUM(CONVERT(decimal(10), size/128.0/1024)) AS [Total Size in GB]
FROM sys.master_files WITH (NOLOCK)
WHERE [database_id] > 4 
AND [database_id] <> 32767
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
OR [database_id] = 2