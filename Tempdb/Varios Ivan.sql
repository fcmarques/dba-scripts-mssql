===========================================================================================
===========================================================================================
Retorna o uso de TEMPDB tanto de dados quanto de LOG
===========================================================================================
===========================================================================================
;WITH task_space_usage AS (
    -- SUM alloc/delloc pages
    SELECT session_id,
           request_id,
           SUM(internal_objects_alloc_page_count) AS alloc_pages,
           SUM(internal_objects_dealloc_page_count) AS dealloc_pages
    FROM sys.dm_db_task_space_usage WITH (NOLOCK)
    WHERE session_id <> @@SPID
    GROUP BY session_id, request_id
)
SELECT TSU.session_id,
       TSU.alloc_pages * 1.0 / 128 AS [internal object MB space],
       TSU.dealloc_pages * 1.0 / 128 AS [internal object dealloc MB space],
       EST.text,
       -- Extract statement from sql text
       ISNULL(
           NULLIF(
               SUBSTRING(
                 EST.text, 
                 ERQ.statement_start_offset / 2, 
                 CASE WHEN ERQ.statement_end_offset < ERQ.statement_start_offset 
                  THEN 0 
                 ELSE( ERQ.statement_end_offset - ERQ.statement_start_offset ) / 2 END
               ), ''
           ), EST.text
       ) AS [statement text],
       EQP.query_plan
FROM task_space_usage AS TSU
INNER JOIN sys.dm_exec_requests ERQ WITH (NOLOCK)
    ON  TSU.session_id = ERQ.session_id
    AND TSU.request_id = ERQ.request_id
OUTER APPLY sys.dm_exec_sql_text(ERQ.sql_handle) AS EST
OUTER APPLY sys.dm_exec_query_plan(ERQ.plan_handle) AS EQP
WHERE EST.text IS NOT NULL OR EQP.query_plan IS NOT NULL
ORDER BY 3 DESC;




SELECT tdt.database_transaction_log_bytes_reserved,tst.session_id,
       t.[text], [statement] = COALESCE(NULLIF(
         SUBSTRING(
           t.[text],
           r.statement_start_offset / 2,
           CASE WHEN r.statement_end_offset < r.statement_start_offset
             THEN 0
             ELSE( r.statement_end_offset - r.statement_start_offset ) / 2 END
         ), ''
       ), t.[text])
     FROM sys.dm_tran_database_transactions AS tdt
     INNER JOIN sys.dm_tran_session_transactions AS tst
     ON tdt.transaction_id = tst.transaction_id
         LEFT OUTER JOIN sys.dm_exec_requests AS r
         ON tst.session_id = r.session_id
         OUTER APPLY sys.dm_exec_sql_text(r.plan_handle) AS t
     WHERE tdt.database_id = 2;





                ;WITH s AS
(
    SELECT 
        s.session_id,
        [pages] = SUM(s.user_objects_alloc_page_count 
          + s.internal_objects_alloc_page_count) 
    FROM sys.dm_db_session_space_usage AS s
    GROUP BY s.session_id
    HAVING SUM(s.user_objects_alloc_page_count 
      + s.internal_objects_alloc_page_count) > 0
)
SELECT s.session_id, s.[pages], t.[text], 
  [statement] = COALESCE(NULLIF(
    SUBSTRING(
        t.[text], 
        r.statement_start_offset / 2, 
        CASE WHEN r.statement_end_offset < r.statement_start_offset 
        THEN 0 
        ELSE( r.statement_end_offset - r.statement_start_offset ) / 2 END
      ), ''
    ), t.[text])
FROM s
LEFT OUTER JOIN 
sys.dm_exec_requests AS r
ON s.session_id = r.session_id
OUTER APPLY sys.dm_exec_sql_text(r.plan_handle) AS t
ORDER BY s.[pages] DESC;





SELECT tst.[session_id],
s.[login_name] AS [Login Name],
DB_NAME (tdt.database_id) AS [Database],
tdt.[database_transaction_begin_time] AS [Begin Time],
tdt.[database_transaction_log_record_count] AS [Log Records],
tdt.[database_transaction_log_bytes_used] AS [Log Bytes Used],
tdt.[database_transaction_log_bytes_reserved] AS [Log Bytes Rsvd],
SUBSTRING(st.text, (r.statement_start_offset/2)+1,
((CASE r.statement_end_offset
WHEN -1 THEN DATALENGTH(st.text)
ELSE r.statement_end_offset
END - r.statement_start_offset)/2) + 1) AS statement_text,
st.[text] AS [Last T-SQL Text],
qp.[query_plan] AS [Last Plan]
FROM sys.dm_tran_database_transactions tdt
JOIN sys.dm_tran_session_transactions tst
ON tst.[transaction_id] = tdt.[transaction_id]
JOIN sys.[dm_exec_sessions] s
ON s.[session_id] = tst.[session_id]
JOIN sys.dm_exec_connections c
ON c.[session_id] = tst.[session_id]
LEFT OUTER JOIN sys.dm_exec_requests r
ON r.[session_id] = tst.[session_id]
CROSS APPLY sys.dm_exec_sql_text (c.[most_recent_sql_handle]) AS st
OUTER APPLY sys.dm_exec_query_plan (r.[plan_handle]) AS qp
where DB_NAME (tdt.database_id) = 'tempdb'ORDER BY [Log Bytes Used] DESC;

		 
Ivan Milleo Carrenho
ivan.carrenho@v8consulting.com.br
mobile: 55 11 9 9498 8135
Phone: 55 11 2384 1083
www.v8consulting.com.br



