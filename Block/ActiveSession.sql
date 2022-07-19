<<<<<<< HEAD
select erq.session_id, erq.blocking_session_id, erq.status, erq.wait_type, erq.start_time, est.text, erq.reads/128 Leitura_Fisica, erq.logical_reads/128 Leitura_Logica, erq.writes/128 Escritas,
SUBSTRING(est.text,erq.statement_start_offset/2 +1,   
                 (CASE WHEN erq.statement_end_offset = -1   
                       THEN LEN(CONVERT(nvarchar(max), est.text)) * 2   
                       ELSE erq.statement_end_offset end -  
                            erq.statement_start_offset  
                 )/2  
             ) AS query_text,   
ess.host_name, ess.login_name, ess.program_name, eqp.query_plan
from sys.dm_exec_requests erq
inner join sys.dm_exec_sessions ess on erq.session_id = ess.session_id
cross apply sys.dm_exec_sql_text(erq.sql_handle) est
cross apply sys.dm_exec_query_plan(erq.plan_handle) eqp
where erq.group_id != 1
and erq.session_id != @@SPID
=======
select erq.session_id, erq.blocking_session_id, erq.status, erq.wait_type, erq.start_time, est.text, erq.reads/128 Leitura_Fisica, erq.logical_reads/128 Leitura_Logica, erq.writes/128 Escritas,
SUBSTRING(est.text,erq.statement_start_offset/2 +1,   
                 (CASE WHEN erq.statement_end_offset = -1   
                       THEN LEN(CONVERT(nvarchar(max), est.text)) * 2   
                       ELSE erq.statement_end_offset end -  
                            erq.statement_start_offset  
                 )/2  
             ) AS query_text,   
ess.host_name, ess.login_name, ess.program_name, eqp.query_plan
from sys.dm_exec_requests erq
inner join sys.dm_exec_sessions ess on erq.session_id = ess.session_id
cross apply sys.dm_exec_sql_text(erq.sql_handle) est
cross apply sys.dm_exec_query_plan(erq.plan_handle) eqp
where erq.group_id != 1
and erq.session_id != @@SPID
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
