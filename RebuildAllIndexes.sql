/*
CREATE TABLE [dbo].[RebuildAllIndexesLog](
	[id] [int] primary key IDENTITY(1,1) NOT NULL,
	[dbname] [varchar](100) NULL,
	[tbname] [varchar](100) NULL,
	[dateini] [datetime] NULL,
	[dateend] [datetime] NULL)
*/

DECLARE @Database VARCHAR(255)   
DECLARE @Table VARCHAR(255)  
DECLARE @cmd NVARCHAR(500)  
DECLARE @fillfactor INT 

SET @fillfactor = 90 

DECLARE DatabaseCursor CURSOR FOR  
SELECT name FROM MASTER.dbo.sysdatabases   
--WHERE name NOT IN ('master','msdb','tempdb','model','distribution')   
--WHERE name IN ('vivsposlj01')   
WHERE name IN ('Gesplan')   
ORDER BY 1  

OPEN DatabaseCursor  

FETCH NEXT FROM DatabaseCursor INTO @Database  
WHILE @@FETCH_STATUS = 0  
BEGIN  

   SET @cmd = 'DECLARE TableCursor CURSOR FOR SELECT ''['' + table_catalog + ''].['' + table_schema + ''].['' + 
  table_name + '']'' as tableName FROM ' + @Database + '.INFORMATION_SCHEMA.TABLES 
  WHERE table_type = ''BASE TABLE'''   

   -- create table cursor  
   EXEC (@cmd)  
   OPEN TableCursor   

   FETCH NEXT FROM TableCursor INTO @Table   
   WHILE @@FETCH_STATUS = 0   
   BEGIN   

	   SET @cmd = 'INSERT INTO DBDBA.DBO.RebuildAllIndexesLog(dbname,tbname,dateini) values('''+@Database+''','''+@Table+''',getdate())'
	   EXEC (@cmd)

       IF (@@MICROSOFTVERSION / POWER(2, 24) >= 9)
       BEGIN
           -- SQL 2005 or higher command
		   
           SET @cmd = 'ALTER INDEX ALL ON ' + @Table + ' REBUILD WITH (FILLFACTOR = ' + CONVERT(VARCHAR(3),@fillfactor) + ')' 
           EXEC (@cmd)
           
       END
       ELSE
       BEGIN
          -- SQL 2000 command 
          DBCC DBREINDEX(@Table,' ',@fillfactor)  
       END

	   SET @cmd = 'UPDATE DBDBA.DBO.RebuildAllIndexesLog set dateend = getdate() where dbname='''+@Database+''' and tbname='''+@Table+''''
       EXEC (@cmd)

       FETCH NEXT FROM TableCursor INTO @Table   
   END   

   CLOSE TableCursor   
   DEALLOCATE TableCursor  

   FETCH NEXT FROM DatabaseCursor INTO @Database  
END  
CLOSE DatabaseCursor   
DEALLOCATE DatabaseCursor