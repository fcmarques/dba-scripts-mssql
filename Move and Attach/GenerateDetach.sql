-- Build the sp_detach_db command (ONLINE, non-system databases only): 
SELECT DISTINCT'exec sp_detach_db ''' + DB_NAME(dbid) + ''';' 
FROM master.dbo.sysaltfiles 
WHERE SUBSTRING(filename,1,1) IN ('E','F') 
AND DATABASEPROPERTYEX( DB_NAME(dbid) , 'Status' ) = 'ONLINE' 
AND DB_NAME(dbid) NOT IN ('master','tempdb','msdb','model') 
GO