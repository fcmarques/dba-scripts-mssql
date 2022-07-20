<<<<<<< HEAD
CHECKPOINT; 
GO
SELECT text, cp.plan_handle, cp.objtype, cp.usecounts, 
DB_NAME(st.dbid) AS [DatabaseName],
'DBCC FREEPROCCACHE (' + CONVERT(VARCHAR(1000), cp.plan_handle, 1) + ');' AS FREEPROCCACHE
FROM sys.dm_exec_cached_plans AS cp CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS st 
WHERE text
LIKE N'%ORDER BY CHAM.ID_CHAM_CD_CHAMADO %' OPTION (RECOMPILE); 

DBCC FREEPROCCACHE (0x06000700F615EC1740C1893B0A0000000000000000000000);
GO  
CHECKPOINT; 
GO
=======
CHECKPOINT; 
GO
SELECT text, cp.plan_handle, cp.objtype, cp.usecounts, 
DB_NAME(st.dbid) AS [DatabaseName],
'DBCC FREEPROCCACHE (' + CONVERT(VARCHAR(1000), cp.plan_handle, 1) + ');' AS FREEPROCCACHE
FROM sys.dm_exec_cached_plans AS cp CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS st 
WHERE text
LIKE N'%ORDER BY CHAM.ID_CHAM_CD_CHAMADO %' OPTION (RECOMPILE); 

DBCC FREEPROCCACHE (0x06000700F615EC1740C1893B0A0000000000000000000000);
GO  
CHECKPOINT; 
GO
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
