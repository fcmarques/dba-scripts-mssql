/*Find query plan by query hash*/
select 
  SUBSTRING(qt.text, (qs.statement_start_offset/2)+1, ((CASE qs.statement_end_offset WHEN -1 THEN DATALENGTH(qt.text)ELSE qs.statement_end_offset END - qs.statement_start_offset)/2)+1) as CommandText
, qs.query_hash
, qs.last_worker_time
, qs.last_logical_reads
, qs.execution_count
, qp.query_plan
, qs.plan_handle
from sys.dm_exec_query_stats qs
cross apply sys.dm_exec_sql_text(qs.sql_handle) qt
join sys.dm_exec_cached_plans cp on cp.plan_handle = qs.plan_handle 
cross apply sys.dm_exec_query_plan(cp.plan_handle) qp
where 
qs.query_hash = 0x43DD1343BB3CDCBE