<<<<<<< HEAD
DECLARE @name VARCHAR(50) -- database name   
DECLARE @path VARCHAR(256) -- path for backup files   
DECLARE @fileName VARCHAR(256) -- filename for backup   
DECLARE @fileDate VARCHAR(20) -- used for file name  

SET @path = 'C:\Backup\'   

SELECT @fileDate = CONVERT(VARCHAR(20),GETDATE(),112)  
   + '_'  
   + REPLACE(CONVERT(VARCHAR(20),GETDATE(),108),':','') 

DECLARE db_cursor CURSOR FOR   
SELECT name  
FROM master.dbo.sysdatabases  
WHERE name NOT IN ('master','model','msdb','tempdb')  
   AND DATABASEPROPERTYEX(name, 'Recovery') IN ('FULL','BULK_LOGGED') 

OPEN db_cursor    
FETCH NEXT FROM db_cursor INTO @name    

WHILE @@FETCH_STATUS = 0    
BEGIN    
       SET @fileName = @path + @name + '_' + @fileDate + '.TRN'   
       BACKUP LOG @name TO DISK = @fileName   

       FETCH NEXT FROM db_cursor INTO @name    
END    

CLOSE db_cursor    
=======
DECLARE @name VARCHAR(50) -- database name   
DECLARE @path VARCHAR(256) -- path for backup files   
DECLARE @fileName VARCHAR(256) -- filename for backup   
DECLARE @fileDate VARCHAR(20) -- used for file name  

SET @path = 'C:\Backup\'   

SELECT @fileDate = CONVERT(VARCHAR(20),GETDATE(),112)  
   + '_'  
   + REPLACE(CONVERT(VARCHAR(20),GETDATE(),108),':','') 

DECLARE db_cursor CURSOR FOR   
SELECT name  
FROM master.dbo.sysdatabases  
WHERE name NOT IN ('master','model','msdb','tempdb')  
   AND DATABASEPROPERTYEX(name, 'Recovery') IN ('FULL','BULK_LOGGED') 

OPEN db_cursor    
FETCH NEXT FROM db_cursor INTO @name    

WHILE @@FETCH_STATUS = 0    
BEGIN    
       SET @fileName = @path + @name + '_' + @fileDate + '.TRN'   
       BACKUP LOG @name TO DISK = @fileName   

       FETCH NEXT FROM db_cursor INTO @name    
END    

CLOSE db_cursor    
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
DEALLOCATE db_cursor 