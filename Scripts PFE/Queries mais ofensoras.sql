SELECT    DB_NAME(dest.dbid) AS [Database name],
		OBJECT_NAME(dest.objectid, dest.dbid) AS [Stored procedure name],
		[Execution Count],
		[Avg CPU time (ms)],
		[Avg Elapsed time (ms)],
		[Creation time],
		[Last Execution time],
		[Total CPU time (ms)],
		[Total Elapsed time (ms)],
		[Total Physical Reads],
		[Plan Count],
		getdate() AS [Recorded date],
		plan_handle,
		dest.text AS 'Text'
		,QP.query_plan
FROM   (
	SELECT  TOP 1000 plan_handle,
			COUNT(DISTINCT plan_handle) AS [Plan Count],
			MAX(execution_count) AS [Execution Count],
			SUM(total_worker_time/execution_count)/1000 AS [Avg CPU time (ms)],
			SUM(total_elapsed_time/execution_count)/1000 AS [Avg Elapsed time (ms)],
			MAX(creation_time) AS [Creation time],
			MAX(last_execution_time) AS [Last Execution time],
			SUM(total_worker_time/1000) AS [Total CPU time (ms)],
			SUM(total_elapsed_time/1000) AS [Total Elapsed time (ms)],
			SUM(total_logical_reads) AS [Total Physical Reads]
	FROM   sys.dm_exec_query_stats
	GROUP  BY plan_handle
	ORDER  BY SUM(total_worker_time/execution_count)/1000 DESC
	) deqs
	CROSS APPLY sys.dm_exec_sql_text (deqs.plan_handle) AS dest
	CROSS APPLY sys.dm_exec_query_plan (plan_handle) AS QP
