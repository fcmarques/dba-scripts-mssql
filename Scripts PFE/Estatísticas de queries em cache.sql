-- estatísticas de execução das queries com planos em cache, CPU
select creation_time
, last_execution_time
, execution_count
, plan_generation_num
, total_worker_time
, last_worker_time
, max_worker_time
, min_worker_time
, substring (st.text, (qs.statement_start_offset/2)+1, 
        ((case qs.statement_end_offset
          when -1 then datalength (st.text)
         else qs.statement_end_offset
         end - qs.statement_start_offset)/2) + 1) 'Comando'
, qp.query_plan
from sys.dm_exec_query_stats qs 
cross apply sys.dm_exec_sql_text(qs.sql_handle) st
cross apply sys.dm_exec_query_plan (qs.plan_handle) qp
--where qs.sql_handle = 
 