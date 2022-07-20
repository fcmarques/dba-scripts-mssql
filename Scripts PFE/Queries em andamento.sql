select 
 es.session_id
, object_name (es.session_id, qp.objectid) [Proc Name]
, er.request_id
, er.start_time
, er.status
, er.wait_resource
, er.wait_type
, er.last_wait_type
, er.command
, er.blocking_session_id
, er.sql_handle
, st.text
, substring (st.text, (er.statement_start_offset/2)+1, 
        ((case er.statement_end_offset
          when -1 then datalength (st.text)
         else er.statement_end_offset
         end - er.statement_start_offset)/2) + 1) as 'Comando'
             , er.plan_handle
, er.cpu_time
, er.reads
, er.logical_reads
, er.writes
, er.granted_query_memory
, qp.query_plan
, er.statement_start_offset
, er.statement_end_offset
, er.query_hash
, er.query_plan_hash
from sys.dm_exec_sessions es join sys.dm_exec_requests er on es.session_id = er.session_id
cross apply sys.dm_exec_sql_text (er.sql_handle) st
cross apply sys.dm_exec_query_plan (er.plan_handle) qp
where es.is_user_process = 1
--and er.blocking_session_id <> 0 for blocked proccesses