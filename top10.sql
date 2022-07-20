SELECT TOP (10)
		db_name(st.dbid),
		execution_count, total_worker_time, max_worker_time, 
		total_elapsed_time, max_elapsed_time, 
		total_logical_reads, max_logical_reads, 
		SUBSTRING(st.text, (qs.statement_start_offset/2)+1, 
					((CASE qs.statement_end_offset
						WHEN -1 THEN DATALENGTH(st.text)
					 ELSE qs.statement_end_offset
					 END - qs.statement_start_offset)/2) + 1) AS statement_text, 
		qp.query_plan
	FROM sys.dm_exec_query_stats qs
		CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
		CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
	ORDER BY max_elapsed_time DESC