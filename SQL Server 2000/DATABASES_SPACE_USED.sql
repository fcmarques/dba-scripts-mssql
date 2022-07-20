DECLARE 
	@dbName varchar(40)

DECLARE Databases_Cursor CURSOR FOR
select name from sysdatabases

CREATE TABLE #DBfiles (
	[fileid] [smallint] NOT NULL ,
	[groupid] [smallint] NOT NULL ,
	[size] [int] NOT NULL ,
	[maxsize] [int] NOT NULL ,
	[growth] [int] NOT NULL ,
	[status] [int] NOT NULL ,
	[perf] [int] NOT NULL ,
	[name] [nchar] (128) NOT NULL ,
	[filename] [nchar] (260) NOT NULL 
)

OPEN Databases_Cursor
FETCH NEXT FROM Databases_Cursor
into @dbName
WHILE @@FETCH_STATUS = 0
BEGIN

   print @dbName
   exec ('select * INTO #DBfiles from ' +@dbName+'.dbo.sysfiles')
   FETCH NEXT FROM Databases_Cursor
   into @dbName
END
CLOSE Databases_Cursor
DEALLOCATE Databases_Cursor

--select name from sysdatabases

DROP TABLE #DBfiles
GO
