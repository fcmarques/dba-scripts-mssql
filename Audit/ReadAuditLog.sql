WITH auditlog
AS (
	SELECT DATEADD(hour, - 3, event_time) AS event_time
		,sequence_number
		,a.action_id
		,a.class_type
		,b.securable_class_desc
		,a.server_principal_name
		,b.class_type_desc AS object_type
		,c.name AS command_type
		,a.database_name
		,a.object_name
		,a.statement
	FROM fn_get_audit_file(N'Z:\Audits\AuditTableSelect_*.sqlaudit', NULL, NULL) AS a
	INNER JOIN sys.dm_audit_class_type_map AS b ON (a.class_type COLLATE database_default = b.class_type COLLATE database_default)
	INNER JOIN sys.dm_audit_actions c ON (
			c.action_id COLLATE database_default = a.action_id COLLATE database_default
			AND c.class_desc COLLATE database_default = b.securable_class_desc COLLATE database_default
			)
	WHERE NOT EXISTS (
			SELECT *
			FROM sys.dm_audit_actions d
			WHERE d.action_id COLLATE database_default = a.action_id COLLATE database_default
				AND d.class_desc COLLATE database_default = b.class_type_desc COLLATE database_default
			)
	
	UNION
	
	-- Case where the sys.dm_audit_actions reports class_type_desc, or  
	-- metadata object type.  
	SELECT DATEADD(hour, - 3, event_time) AS event_time
		,sequence_number
		,a.action_id
		,a.class_type
		,b.securable_class_desc
		,a.server_principal_name
		,b.class_type_desc AS object_type
		,c.name AS command_type
		,a.database_name
		,a.object_name
		,a.statement
	FROM fn_get_audit_file(N'Z:\Audits\AuditTableSelect_*.sqlaudit', NULL, NULL) AS a
	INNER JOIN sys.dm_audit_class_type_map AS b ON (a.class_type COLLATE database_default = b.class_type COLLATE database_default)
	INNER JOIN sys.dm_audit_actions c ON (
			c.action_id COLLATE database_default = a.action_id COLLATE database_default
			AND c.class_desc COLLATE database_default = b.class_type_desc COLLATE database_default
			)
	)
SELECT *
FROM auditlog
WHERE object_type IN (
		'STORED PROCEDURE'
		,'FUNCTION SCALAR SQL'
		)
	AND event_time > Getdate() - 5
ORDER BY event_time DESC
