DECLARE @DBuser_sql VARCHAR(4000)
IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE name = '##DBuser_table')
DROP TABLE ##DBuser_table
CREATE TABLE ##DBuser_table (DBName VARCHAR(200), UserName VARCHAR(250), LoginType VARCHAR(500), AssociatedRole VARCHAR(200))
SET @DBuser_sql='select ''?'' AS DBName, a.name, CASE WHEN a.isntgroup =1 AND a.isntuser=0 THEN ''Windows Group''
    WHEN a.isntgroup =0 AND a.isntuser=1 THEN ''Windows Login''
    WHEN a.issqlrole=1 THEN ''Database Role''
    ELSE ''SQL Login'' END AS ''Login Type'',USER_NAME(b.groupuid) AS ''AssociatedRole''
from ?.dbo.sysusers a LEFT OUTER JOIN ?.dbo.sysmembers b ON a.uid=b.memberuid where a.altuid<>1 and a.uid not in (1,2) AND ''?'' NOT IN (''master'',''msdb'',''model'',''tempdb'') ORDER BY Name'
INSERT INTO ##DBuser_table
EXEC sp_MSforeachdb @command1=@dbuser_sql
SELECT * FROM ##DBuser_table ORDER BY DBName