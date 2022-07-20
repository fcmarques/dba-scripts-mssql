DECLARE @Obj_sql VARCHAR(4000)
IF EXISTS (SELECT 1 from tempdb..sysobjects where name = '##Obj_table')
DROP TABLE ##Obj_table
CREATE TABLE ##Obj_table(DBName VARCHAR(200), UserName VARCHAR(250), ObjectName VARCHAR(500), Permission VARCHAR(200))
SET @Obj_sql='select ''?'',a.name,c.name,case b.actadd when 1 then ''SELECT''
when 2 then ''UPDATE''
when 3 then ''SELECT,UPDATE''
when 4 then ''REFERENCES''
when 5 then ''SELECT, REFERENCES''
when 6 then ''UPDATE,REFERENCES''
when 7 then ''SELECT,UPDATE,REFERENCES''
when 8 then ''INSERT''
when 9 then ''SELECT,INSERT''
when 10 then ''UPDATE,INSERT''
when 11 then ''SELECT,UPDATE,INSERT''
when 12 then ''REFERENCES,INSERT''
when 13 then ''SELECT,REFERENCES,INSERT''
when 14 then ''UPDATE,REFERENCES,INSERT''
when 15 then ''SELECT,UPDATE,REFERENCES,INSERT''
when 16 then ''DELETE''
when 17 then ''SELECT,DELETE''
when 18 then ''UPDATE,DELETE''
when 19 then ''SELECT,UPDATE,DELETE''
when 20 then ''REFERENCES,DELETE''
when 21 then ''SELECT,REFERENCES,DELETE''
when 22 then ''UPDATE,REFERENCES,DELETE''
when 23 then ''SELECT,UPDATE,REFERENCES,DELETE''
when 24 then ''INSERT,DELETE''
when 25 then ''SELECT,INSERT,DELETE''
when 26 then ''UPDATE,INSERT,DELETE''
when 27 then ''SELECT,UPDATE,INSERT,DELETE''
when 28 then ''REFERENCES,INSERT,DELETE''
when 29 then ''SELECT,REFERENCES,INSERT,DELETE''
when 30 then ''REFERENCES,INSERT,DELETE''
when 31 then ''SELECT,UPDATE,REFERENCES,INSERT,DELETE''
when 32 then ''EXECUTE'' else NULL end
from ?.dbo.sysusers a, ?.dbo.syspermissions b,?.dbo.sysobjects c
where a.uid = b.grantee and b.[id] = c.[id] and b.grantee <> 0 and ''?'' NOT IN (''master'',''msdb'',''model'',''tempdb'') order by a.name'
INSERT INTO ##Obj_table
EXEC sp_MSforeachdb @command1=@Obj_sql
SELECT * FROM ##Obj_table ORDER BY DBName