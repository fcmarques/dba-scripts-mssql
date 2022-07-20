
SELECT DTL.resource_type,  
   CASE   
       WHEN DTL.resource_type IN ('DATABASE', 'FILE', 'METADATA') THEN DTL.resource_type  
       WHEN DTL.resource_type = 'OBJECT' THEN OBJECT_NAME(DTL.resource_associated_entity_id, SP.[dbid])  
       WHEN DTL.resource_type IN ('KEY', 'PAGE', 'RID') THEN   
           (  
           SELECT OBJECT_NAME([object_id])  
           FROM sys.partitions  
           WHERE sys.partitions.hobt_id =   
             DTL.resource_associated_entity_id  
           )  
       ELSE 'Unidentified'  
   END AS requested_object_name, DTL.request_mode, DTL.request_status,  
   DEST.TEXT, SP.spid, SP.blocked, SP.status, SP.loginame 
FROM sys.dm_tran_locks DTL  
   INNER JOIN sys.sysprocesses SP  
       ON DTL.request_session_id = SP.spid   
   --INNER JOIN sys.[dm_exec_requests] AS SDER ON SP.[spid] = [SDER].[session_id] 
   CROSS APPLY sys.dm_exec_sql_text(SP.sql_handle) AS DEST  
WHERE SP.dbid = DB_ID()  
   AND DTL.[resource_type] <> 'DATABASE' 
  -- and DTL.request_mode='WAIT'
ORDER BY DTL.[request_session_id];


select count (spid),spid,blocked,cmd
from sys.sysprocesses 
where blocked != 0
group by blocked, cmd, spid

select count (spid),blocked,cmd
from sys.sysprocesses 
where blocked != 0
group by blocked, cmd
order by 1 desc

sp_configure
dbcc inputbuffer (440)

select * from sys.sysprocesses where spid = 459
kill 1112

select * from sys.tables

select * from ##tbl

reconfigure

sp_who