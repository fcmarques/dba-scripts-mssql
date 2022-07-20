DECLARE @nome VARCHAR(50) 
DECLARE @path VARCHAR(256)  
DECLARE @nomeArq VARCHAR(256)  
DECLARE @DataArq VARCHAR(20)  

SET @path = 'c:\DBACORPteste\backup\' 

SELECT @DataArq = CONVERT(VARCHAR(20),GETDATE(),112)+REPLACE(CONVERT(VARCHAR(20),GETDATE(),114),':','')

DECLARE db_cursor CURSOR FOR 
SELECT name
     FROM master.dbo.sysdatabases
     WHERE dbid > 4
			and databasepropertyex(name,'STATUS') = 'ONLINE' 

OPEN db_cursor  
FETCH NEXT FROM db_cursor INTO @nome  

WHILE @@FETCH_STATUS = 0  
BEGIN  
       SET @nomeArq = @path + @nome + '_' + @DataArq + '.trn' 
       BACKUP LOG @nome TO DISK = @nomeArq 
       FETCH NEXT FROM db_cursor INTO @nome  
END  

CLOSE db_cursor  
DEALLOCATE db_cursor

