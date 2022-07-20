sELECT m.name                         AS MemberName,
       g.name                         AS GroupName
FROM   sysmembers x LEFT JOIN sysusers m  ON m.uid = x.memberuid
       LEFT JOIN sysusers g ON x.groupuid = g.uid
ORDER  BY CASE
            WHEN LEFT(g.name, 3) = 'db_' THEN 0
            ELSE
              CASE
                WHEN g.name = 'public' THEN 1
                ELSE 2
              END
          END,
          g.name
          =============


select b.name, permissao = case 
			when (a.action = 26) then 'REFERENCES'
when (a.action = 178) then 'CREATE FUNCTION'
when (a.action = 193) then 'SELECT'
when (a.action = 195) then 'INSERT'
when (a.action = 196) then 'DELETE'
when (a.action = 197) then 'UPDATE'
when (a.action = 198) then 'CREATE TABLE'
when (a.action = 203) then 'CREATE DATABASE'
when (a.action = 207) then 'CREATE VIEW'
when (a.action = 222) then 'CREATE PROCEDURE'
when (a.action = 224) then 'EXECUTE'
when (a.action = 228) then 'BACKUP DATABASE'
when (a.action = 233) then 'CREATE DEFAULT'
when (a.action = 235) then 'BACKUP LOG'
when (a.action = 236) then 'CREATE RULE'
else 'Nulo'
end
from dbo.sysprotects as a join sysusers as b on a.uid=b.uid
group by name, a.action


select object_name(id),* from syspermissions
select * from sysobjects where id = 29295214
select * from sysprotects