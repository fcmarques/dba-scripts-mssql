USE daniel
GO

SELECT
s.*,
dp1.*
FROM sys.schemas AS s INNER JOIN sys.database_principals AS dp1 ON dp1.principal_id = s.principal_id
where dp1.type_desc = 'DATABASE_ROLE'

select * from sys.schemas

select * from sys.extended_properties
select * from sys.database_permissions
SELECT * FROM SYS.database_principals

SELECT * FROM SYS.objects WHERE OBJECT_ID = '2105058535'

USE daniel
GO
select a.name,a.type_desc, c.name,b.permission_name
from sys.database_principals as a inner join sys.database_permissions as b on a.principal_id = b.grantee_principal_id
inner join sys.objects as c on c.object_id = b.major_id
where a.type_desc = 'DATABASE_ROLE'

sp_helptext 'sp_helptext'

