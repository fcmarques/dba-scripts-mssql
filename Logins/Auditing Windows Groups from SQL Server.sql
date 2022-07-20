--SQL Server 2005, 2008, 2008R2, 2014, 2016 and 2017
DECLARE @LoginName sysname 
DECLARE @sql NVARCHAR (2000) 

BEGIN 
   DECLARE cur_Loginfetch CURSOR FOR 
    
   SELECT [name] FROM master.sys.server_principals WHERE TYPE = 'G' 
    
   OPEN cur_Loginfetch 
    
   FETCH NEXT FROM cur_Loginfetch INTO @LoginName 
   WHILE @@FETCH_STATUS = 0 
       BEGIN 
           EXEC xp_logininfo @LoginName , 'members' 
           FETCH NEXT FROM cur_Loginfetch INTO @LoginName 
       END 
   CLOSE cur_Loginfetch 
   DEALLOCATE cur_Loginfetch 
   RETURN 
END 