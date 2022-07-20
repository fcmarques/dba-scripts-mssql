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
	USER_NAME(so.uid) as ''Schema'',
	so.name as ''Object Name'', 
	CASE (so.xtype)
		WHEN ''AF'' THEN ''Aggregate function (CLR)''
		WHEN ''C''  THEN ''CHECK constraint'' 
		WHEN ''D''  THEN ''DEFAULT (constraint or stand-alone)''
		WHEN ''F''  THEN ''FOREIGN KEY constraint''
		WHEN ''PK'' THEN ''PRIMARY KEY constraint''
		WHEN ''P''  THEN ''SQL Stored Procedure''
		WHEN ''PC'' THEN ''Assembly (CLR) stored procedure''
		WHEN ''FN'' THEN ''SQL scalar function''
		WHEN ''FS'' THEN ''Assembly (CLR) scalar function''
		WHEN ''FT'' THEN ''Assembly (CLR) table-valued function''
		WHEN ''R''  THEN ''Rule (old-style, stand-alone)''
		WHEN ''RF'' THEN ''Replication-filter-procedure''
		WHEN ''S''  THEN ''System base table''
		WHEN ''SN'' THEN ''Synonym''
		WHEN ''SQ'' THEN ''Service queue''
		WHEN ''TA'' THEN ''Assembly (CLR) DML trigger''
		WHEN ''TR'' THEN ''SQL DML trigger ''
		WHEN ''IF'' THEN ''SQL inline table-valued function''
		WHEN ''TF'' THEN ''SQL table-valued-function''
		WHEN ''U''  THEN ''Table (user-defined)''
		WHEN ''UQ'' THEN ''UNIQUE constraint''
		WHEN ''V''  THEN ''View''
		WHEN ''X''  THEN ''Extended stored procedure''
		WHEN ''IT'' THEN ''Internal table''
	END AS ''Object Type'',
	so.crdate as ''Creation Date'',
	substring(sc.text, 0, 100) as ''Code Fragment''
--so.*,sc.*
FROM syscomments sc
INNER JOIN sysobjects so
	ON sc.id = so.id
WHERE 
	sc.TEXT LIKE ''%PADM01%'' or
	sc.TEXT LIKE ''%Usrdes%'' or
	sc.TEXT LIKE ''%Usrdev%'' or
	sc.TEXT LIKE ''%userGEDNetwork%'' or
	sc.TEXT LIKE ''%pwdUserGEDNetwork%'' or
	sc.TEXT LIKE ''%usrfolha%'' or
	sc.TEXT LIKE ''%usrcorp%'' or
	sc.TEXT LIKE ''%usrcorp%'' or
	sc.TEXT LIKE ''%direcao%'' or
	sc.TEXT LIKE ''%Zeus%'' or
	sc.TEXT LIKE ''%WEBUSR01%''
'
EXEC sp_MSforeachdb @SQL
GO

SELECT * FROM #ObjectsFinded
GO

