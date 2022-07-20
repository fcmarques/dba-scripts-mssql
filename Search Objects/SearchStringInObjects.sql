/*
	-- Search for a string in all objects in all databases
*/

IF OBJECT_ID('tempdb.dbo.#ObjectsFinded', 'U') IS NOT NULL
  DROP TABLE #ObjectsFinded;
  
CREATE TABLE #ObjectsFinded(
	[Server Name] nvarchar(100),
	[Database] nvarchar(100),
	[Schema] nvarchar(100),
	[Object Name] nvarchar(100),
	[Object Type] nvarchar(100),
	[Creation Date] nvarchar(100),
	[Modification Date] nvarchar(100),
	[Code Fragment] nvarchar(100)
	)

DECLARE @SQL VARCHAR(3000)

SET @SQL = 
'
USE ?

INSERT INTO #ObjectsFinded
SELECT DISTINCT 
	@@SERVERNAME as ''Server Name'',
	DB_NAME() as ''Database'',
	SCHEMA_NAME(so.schema_id) as ''Schema'',
	so.name as ''Object Name'', 
	so.type_desc AS ''Object Type'',
	so.create_date as ''Creation Date'',
	so.modify_date as ''Modification Date'',
	substring(sc.text, 0, 100) as ''Code Fragment''
--so.*,sc.*
FROM syscomments sc
INNER JOIN sys.objects so
	ON sc.id = so.object_id
WHERE 
	sc.TEXT LIKE ''%xp_decrypt%'' or
	sc.TEXT LIKE ''%xp_encrypt%'' 
'
EXEC sp_MSforeachdb @SQL
GO

SELECT * FROM #ObjectsFinded
GO

