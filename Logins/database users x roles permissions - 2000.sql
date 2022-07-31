
SELECT db_name() AS 'DB Name',
	su.NAME as 'User', 
	CASE 
		WHEN su.isntgroup = 1 AND su.isntuser = 0	THEN 'Windows Group' 
		WHEN su.isntgroup = 0 AND su.isntuser = 1 THEN 'Windows Login'
		WHEN su.issqlrole = 1 THEN 'Database Role'
		ELSE 'SQL Login'
    END AS 'Login Type',
	USER_NAME(sm.groupuid) AS 'Associated Role',
	CASE sp.protecttype
		WHEN 204 THEN 'GRANT w/ GRANT'
		WHEN 205 THEN 'GRANT'
		WHEN 206 THEN 'DENY' 
	END AS 'Permission',
    CASE sp.action
		WHEN 26 THEN 'REFERENCES'
		WHEN 193 THEN 'SELECT'
		WHEN 195 THEN 'INSERT'
		WHEN 196 THEN 'DELETE'
		WHEN 197 THEN 'UPDATE'
		WHEN 224 THEN 'EXECUTE' 
	END AS 'Action',
	  so.name AS 'Object',
	CASE (so.xtype)
		WHEN 'AF' THEN 'Aggregate function (CLR)'
		WHEN 'C'  THEN 'CHECK constraint' 
		WHEN 'D'  THEN 'DEFAULT (constraint or stand-alone)'
		WHEN 'F'  THEN 'FOREIGN KEY constraint'
		WHEN 'PK' THEN 'PRIMARY KEY constraint'
		WHEN 'P'  THEN 'SQL stored procedure'
		WHEN 'PC' THEN 'Assembly (CLR) stored procedure'
		WHEN 'FN' THEN 'SQL scalar function'
		WHEN 'FS' THEN 'Assembly (CLR) scalar function'
		WHEN 'FT' THEN 'Assembly (CLR) table-valued function'
		WHEN 'R'  THEN 'Rule (old-style, stand-alone)'
		WHEN 'RF' THEN 'Replication-filter-procedure'
		WHEN 'S'  THEN 'System base table'
		WHEN 'SN' THEN 'Synonym'
		WHEN 'SQ' THEN 'Service queue'
		WHEN 'TA' THEN 'Assembly (CLR) DML trigger'
		WHEN 'TR' THEN 'SQL DML trigger '
		WHEN 'IF' THEN 'SQL inline table-valued function'
		WHEN 'TF' THEN 'SQL table-valued-function'
		WHEN 'U'  THEN 'Table (user-defined)'
		WHEN 'UQ' THEN 'UNIQUE constraint'
		WHEN 'V'  THEN 'View'
		WHEN 'X'  THEN 'Extended stored procedure'
		WHEN 'IT' THEN 'Internal table'
	END AS 'Object Type'
FROM dbo.sysusers su
LEFT JOIN dbo.sysmembers sm
	ON su.uid = sm.memberuid
LEFT JOIN sysprotects sp
	on sp.uid = sm.groupuid
INNER JOIN sysobjects so
    ON sp.id = so.id
WHERE su.altuid <> 1
	AND su.uid NOT IN (1,2)
	AND '?' NOT IN ('master','msdb','model','tempdb')
	--AND su.name = 'username@seuemail.com.br'
ORDER BY su.NAME
