SELECT TOP 100 total_worker_time/execution_count AS [Avg CPU Time],
    SUBSTRING(st.text, (qs.statement_start_offset/2)+1, 
        ((CASE qs.statement_end_offset
          WHEN -1 THEN DATALENGTH(st.text)
         ELSE qs.statement_end_offset
         END - qs.statement_start_offset)/2) + 1) AS statement_text
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
where st.text like 'select%' 
ORDER BY total_worker_time/execution_count DESC;


select * from sys.dm_exec_query_stats
====================================================
SET SHOWPLAN_XML OFF 
SELECT top 100
    GETDATE() AS "Collection Date",
    qs.execution_count AS "Execution Count",
    SUBSTRING(qt.text,qs.statement_start_offset/2 +1, 
                 (CASE WHEN qs.statement_end_offset = -1 
                       THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2 
                       ELSE qs.statement_end_offset END -
                            qs.statement_start_offset
                 )/2
             ) AS "Query Text", 
     DB_NAME(qt.dbid) AS "DB Name",
     qs.total_worker_time AS "Total CPU Time",
     qs.total_worker_time/qs.execution_count AS "Avg CPU Time (ms)",     
     qs.total_physical_reads AS "Total Physical Reads",
     qs.total_physical_reads/qs.execution_count AS "Avg Physical Reads",
     qs.total_logical_reads AS "Total Logical Reads",
     qs.total_logical_reads/qs.execution_count AS "Avg Logical Reads",
     qs.total_logical_writes AS "Total Logical Writes",
     qs.total_logical_writes/qs.execution_count AS "Avg Logical Writes",
     qs.total_elapsed_time AS "Total Duration",
     (qs.total_elapsed_time/qs.execution_count)/1000 AS "Avg Duration (s)",
     qp.query_plan AS "Plan"
FROM sys.dm_exec_query_stats AS qs 
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt 
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp
WHERE qt.text like 'select%'
and  qs.execution_count > 50 OR
     qs.total_worker_time/qs.execution_count > 100 OR
     qs.total_physical_reads/qs.execution_count > 1000 OR
     qs.total_logical_reads/qs.execution_count > 1000 OR
     qs.total_logical_writes/qs.execution_count > 1000 OR
     qs.total_elapsed_time/qs.execution_count > 1000
ORDER BY 
     qs.execution_count DESC,
     qs.total_elapsed_time/qs.execution_count DESC,
     qs.total_worker_time/qs.execution_count DESC,
     qs.total_physical_reads/qs.execution_count DESC,
     qs.total_logical_reads/qs.execution_count DESC,
     qs.total_logical_writes/qs.execution_count DESC
     

SELECT [CODIGO_LOJA] 
FROM [item_pagamento] WITH(nolock,readuncommitted)
  WHERE [CODIGO_LOJA]=@1 
        AND [DATA_MOVIMENTO]=@2 
        AND [CODIGO_PDV]=@3 
        AND [CUPOM]=@4 
        AND [SEQUENCIA]=@5
