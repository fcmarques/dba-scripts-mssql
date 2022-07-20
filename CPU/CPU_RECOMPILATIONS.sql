<<<<<<< HEAD
-- One of the most frequent contributors to high CPU consumption is stored procedure recompilation. Here is a DMV that displays the list of the top 25 recompilations:

SELECT TOP 25 SQL_TEXT.TEXT, SQL_HANDLE, 
PLAN_GENERATION_NUM, EXECUTION_COUNT, DBID, 
OBJECTID FROM SYS.DM_EXEC_QUERY_STATS A
CROSS APPLY SYS.DM_EXEC_SQL_TEXT(SQL_HANDLE) 
AS SQL_TEXT WHERE PLAN_GENERATION_NUM >1
=======
-- One of the most frequent contributors to high CPU consumption is stored procedure recompilation. Here is a DMV that displays the list of the top 25 recompilations:

SELECT TOP 25 SQL_TEXT.TEXT, SQL_HANDLE, 
PLAN_GENERATION_NUM, EXECUTION_COUNT, DBID, 
OBJECTID FROM SYS.DM_EXEC_QUERY_STATS A
CROSS APPLY SYS.DM_EXEC_SQL_TEXT(SQL_HANDLE) 
AS SQL_TEXT WHERE PLAN_GENERATION_NUM >1
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
ORDER BY PLAN_GENERATION_NUM DESC