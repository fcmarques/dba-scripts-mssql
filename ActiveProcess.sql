
SELECT 'Active Processes'                        AS [Type], 
       spid ,
       blocked ,
       loginame ,
       hostname ,
       sys.status ,
       cmd ,
       sys . program_name,
       lastwaittype ,
       cpu ,
       physical_io ,
       h1 .text                                 AS command, 
       Datediff(second , last_batch , Getdate ()) AS Seconds ,
       sys. login_time ,
       open_tran ,
       query_plan
FROM   sys .dm_exec_requests er
       INNER JOIN sys. sysprocesses sys
               ON sys .spid = er. session_id
       INNER JOIN sys. dm_exec_sessions es
               ON er. session_id = es . session_id
       CROSS apply sys. Dm_exec_sql_text( er .sql_handle ) AS h1
       CROSS apply sys. Dm_exec_query_plan( er .plan_handle )
WHERE  spid <> @@SPID