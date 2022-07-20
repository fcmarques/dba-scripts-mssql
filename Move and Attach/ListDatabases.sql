-- List all databases attached to the drives regardless of the database status:  

SELECT DISTINCT DB_NAME(dbid) 
FROM master.dbo.sysaltfiles 
WHERE SUBSTRING(filename,1,1) IN ('E','F') 
GO 

-- List all ONLINE databases: 
SELECT DISTINCT DB_NAME(dbid) 
FROM master.dbo.sysaltfiles 
WHERE SUBSTRING(filename,1,1) IN ('E','F') 
AND DATABASEPROPERTYEX( DB_NAME(dbid) , 'Status' ) = 'ONLINE' 
GO 

-- Alert if there is any system database on the specific drives: 
IF EXISTS (SELECT 1 
FROM master.dbo.sysaltfiles 
WHERE SUBSTRING(filename,1,1) IN ('E','F') 
AND DATABASEPROPERTYEX( DB_NAME(dbid) , 'Status' ) = 'ONLINE' 
AND DB_NAME(dbid) IN ('master','tempdb','msdb','model')  
) 
BEGIN 
  SELECT DISTINCT DB_NAME(dbid) AS 'There are system databases on these drives:' 
  FROM master.dbo.sysaltfiles 
  WHERE SUBSTRING(filename,1,1) IN ('E','F') 
  AND DATABASEPROPERTYEX( DB_NAME(dbid) , 'Status' ) = 'ONLINE' 
  AND DB_NAME(dbid) IN ('master','tempdb','msdb','model') 
END 
GO 

-- List all ONLINE databases attached to the drives, except for system databases: 
SELECT DISTINCT DB_NAME(dbid) 
FROM master.dbo.sysaltfiles 
WHERE SUBSTRING(filename,1,1) IN ('E','F') 
AND DATABASEPROPERTYEX( DB_NAME(dbid) , 'Status' ) = 'ONLINE' 
AND DB_NAME(dbid) NOT IN ('master','tempdb','msdb','model') 
GO 