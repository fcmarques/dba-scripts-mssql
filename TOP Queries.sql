-- Top Cached SPs By Execution Count (SQL 2008 R2) (Query 43) (SP Execution Counts)
SELECT TOP(25) DB_NAME(qs.database_id) AS Databasename, OBJECT_NAME(qs.object_id,qs.database_id) AS [SP Name], qs.execution_count,
ISNULL(qs.execution_count/DATEDIFF(Minute, qs.cached_time, GETDATE()), 0) AS [Calls/Minute],
qs.total_worker_time/qs.execution_count AS [AvgWorkerTime], qs.total_worker_time AS [TotalWorkerTime],  
qs.total_elapsed_time, qs.total_elapsed_time/qs.execution_count AS [avg_elapsed_time],
qs.cached_time
FROM sys.dm_exec_procedure_stats AS qs WITH (NOLOCK)
ORDER BY qs.execution_count DESC OPTION (RECOMPILE);
------


-- Top Cached SPs By Avg Elapsed Time (SQL 2008 R2)  (Query 44) (SP Avg Elapsed Time) 
SELECT TOP(25) DB_NAME(qs.database_id) AS Databasename, OBJECT_NAME(qs.object_id,qs.database_id) AS [SP Name], qs.total_elapsed_time/qs.execution_count AS [avg_elapsed_time], 
qs.total_elapsed_time, qs.execution_count, ISNULL(qs.execution_count/DATEDIFF(Minute, qs.cached_time, 
GETDATE()), 0) AS [Calls/Minute], qs.total_worker_time/qs.execution_count AS [AvgWorkerTime], 
qs.total_worker_time AS [TotalWorkerTime], qs.cached_time
FROM sys.dm_exec_procedure_stats AS qs WITH (NOLOCK)
ORDER BY avg_elapsed_time DESC OPTION (RECOMPILE);
------

-- Top Cached SPs By Avg Elapsed Time (SQL 2008 R2)  (Query 44) (SP Total Elapsed Time) 
SELECT TOP(25) DB_NAME(qs.database_id) AS Databasename, OBJECT_NAME(qs.object_id,qs.database_id) AS [SP Name], qs.total_elapsed_time/qs.execution_count AS [avg_elapsed_time], 
qs.total_elapsed_time, qs.execution_count, ISNULL(qs.execution_count/DATEDIFF(Minute, qs.cached_time, 
GETDATE()), 0) AS [Calls/Minute], qs.total_worker_time/qs.execution_count AS [AvgWorkerTime], 
qs.total_worker_time AS [TotalWorkerTime], qs.cached_time
FROM sys.dm_exec_procedure_stats AS qs WITH (NOLOCK)
ORDER BY total_elapsed_time DESC OPTION (RECOMPILE);
------

-- Top Cached SPs By Total Worker time (SQL 2008 R2). Worker time relates to CPU cost  (Query 46) (SP Worker Time)
SELECT TOP(25) DB_NAME(qs.database_id) AS Databasename, OBJECT_NAME(qs.object_id,qs.database_id) AS [SP Name], qs.total_worker_time AS [TotalWorkerTime], 
qs.total_worker_time/qs.execution_count AS [AvgWorkerTime], qs.execution_count, 
ISNULL(qs.execution_count/DATEDIFF(Minute, qs.cached_time, GETDATE()), 0) AS [Calls/Minute],
qs.total_elapsed_time, qs.total_elapsed_time/qs.execution_count 
AS [avg_elapsed_time], qs.cached_time
FROM sys.dm_exec_procedure_stats AS qs WITH (NOLOCK)
ORDER BY qs.total_worker_time DESC OPTION (RECOMPILE);

-- This helps you find the most expensive cached stored procedures from a CPU perspective
-- You should look at this if you see signs of CPU pressure


-- Top Cached SPs By Total Logical Reads (SQL 2008 R2). Logical reads relate to memory pressure  (Query 47) (SP Logical Reads)
SELECT TOP(25) DB_NAME(qs.database_id) AS Databasename, OBJECT_NAME(qs.object_id,qs.database_id) AS [SP Name], qs.total_logical_reads AS [TotalLogicalReads], 
qs.total_logical_reads/qs.execution_count AS [AvgLogicalReads],qs.execution_count, 
ISNULL(qs.execution_count/DATEDIFF(Minute, qs.cached_time, GETDATE()), 0) AS [Calls/Minute], 
qs.total_elapsed_time, qs.total_elapsed_time/qs.execution_count 
AS [avg_elapsed_time], qs.cached_time
FROM sys.dm_exec_procedure_stats AS qs WITH (NOLOCK)
ORDER BY qs.total_logical_reads DESC OPTION (RECOMPILE);
------

-- This helps you find the most expensive cached stored procedures from a memory perspective
-- You should look at this if you see signs of memory pressure


-- Top Cached SPs By Total Physical Reads (SQL 2008 R2). Physical reads relate to disk I/O pressure  (Query 48) (SP Physical Reads)
SELECT TOP(25) DB_NAME(qs.database_id) AS Databasename, OBJECT_NAME(qs.object_id,qs.database_id) AS [SP Name],qs.total_physical_reads AS [TotalPhysicalReads], 
qs.total_physical_reads/qs.execution_count AS [AvgPhysicalReads], qs.execution_count, 
qs.total_logical_reads,qs.total_elapsed_time, qs.total_elapsed_time/qs.execution_count 
AS [avg_elapsed_time], qs.cached_time 
FROM sys.dm_exec_procedure_stats AS qs WITH (NOLOCK)
WHERE qs.total_physical_reads > 0
ORDER BY qs.total_physical_reads DESC, qs.total_logical_reads DESC OPTION (RECOMPILE);
------
