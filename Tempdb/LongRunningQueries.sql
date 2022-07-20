SELECT HOST_NAME AS [System Name]
	,program_name AS [Application Name]
	,DB_NAME(er.database_id) AS [DATABASE Name]
	,USER_NAME(USER_ID) AS [USER Name]
	,connection_id AS [CONNECTION ID]
	,er.session_id AS [CURRENT SESSION ID]
	,blocking_session_id AS [Blocking SESSION ID]
	,start_time AS [Request START TIME]
	,er.STATUS AS [Status]
	,command AS [Command Type]
	,(
		SELECT TEXT
		FROM sys.dm_exec_sql_text(sql_handle)
		) AS [Query TEXT]
	,wait_type AS [Waiting Type]
	,wait_time AS [Waiting Duration]
	,wait_resource AS [Waiting FOR Resource]
	,er.transaction_id AS [TRANSACTION ID]
	,percent_complete AS [PERCENT Completed]
	,estimated_completion_time AS [Estimated COMPLETION TIME (in mili sec)]
	,er.cpu_time AS [CPU TIME used (in mili sec)]
	,(memory_usage * 8) AS [Memory USAGE (in KB)]
	,er.total_elapsed_time AS [Elapsed TIME (in mili sec)]
FROM sys.dm_exec_requests er
INNER JOIN sys.dm_exec_sessions ON er.session_id = sys.dm_exec_sessions.session_id
WHERE DB_NAME(er.database_id) = 'tempdb'
