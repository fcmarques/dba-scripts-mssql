SELECT CATALOG.Path
	,CATALOG.NAME
	,Users.UserName
	,CATALOG.Type
	,Roles.RoleName
FROM CATALOG
INNER JOIN Policies ON CATALOG.PolicyID = Policies.PolicyID
INNER JOIN PolicyUserRole ON PolicyUserRole.PolicyID = Policies.PolicyID
INNER JOIN Roles ON PolicyUserRole.RoleID = Roles.RoleID
INNER JOIN Users ON PolicyUserRole.UserID = Users.UserID
ORDER BY CATALOG.Path