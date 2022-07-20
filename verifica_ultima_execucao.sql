use midway
go


SELECT object_name(m.object_id) AS Nome_Procedure,
MAX(qs.last_execution_time) AS Ultima_Execucao
FROM sys.sql_modules m
LEFT JOIN (sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text (qs.sql_handle) st)
ON m.object_id = st.objectid
AND st.dbid = db_id()
where m.object_id = 125243501
GROUP BY object_name(m.object_id);


select  *
--object_id('pr_alterar_evento'),*
from sys.objects
where type ='P' 
