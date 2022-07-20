SELECT DB_NAME(st.dbid) AS databasename,
       OBJECT_SCHEMA_NAME(st.objectid,st.dbid) AS schemaname,
       OBJECT_NAME(st.objectid,st.dbid) AS objectname,
       qs.*, 
       st.text AS querytext,
       Substring(st.text, 
	             ( qs.statement_start_offset / 2 ) + 1, 
				 ( ( CASE qs.statement_end_offset 
                        WHEN -1 THEN Datalength(st.text)
                        ELSE qs.statement_end_offset
                     END - qs.statement_start_offset ) / 2 ) + 1) AS statementtext,
       qp.query_plan, 
       Getdate() AS dateadded
FROM   sys.dm_exec_query_stats AS qs 
       CROSS apply sys.Dm_exec_sql_text(qs.sql_handle) AS st 
       CROSS apply sys.Dm_exec_query_plan (qs.plan_handle) qp 
WHERE  Object_name(st.objectid,st.dbid) = 'pr_cadastro_fila_consulta';