-- https://www.mssqltips.com/sqlservertip/2827/troubleshooting-sql-server-resourcesemaphore-waittype-memory-issues/
SELECT * FROM sys.sysprocesses
where lastwaittype = 'RESOURCE_SEMAPHORE'
ORDER BY lastwaittype;

SELECT * FROM sys.dm_exec_query_resource_semaphores;

SELECT * FROM sys.dm_exec_query_memory_grants
order by requested_memory_kb desc

select top 10 * from sys.dm_exec_query_memory_grants

SELECT * FROM sys.dm_exec_sql_text(sql_handle)

SELECT * FROM sys.dm_exec_sql_plan(plan_handle)