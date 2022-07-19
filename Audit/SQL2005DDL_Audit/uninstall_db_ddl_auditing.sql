--
-- SQL 2005 DDL Auditing Solution
--
-- Uninstall DDL auditing for one database and stop it re-installing
--
-- Sean Elliott
-- sean_p_elliott@yahoo.co.uk
--
-- September 2010
--

USE db_to_be_uninstalled
GO
|
EXEC msdb.dbo.sp_update_job @job_name=N'Audit RESTORE/ATTACH DATABASE', @enabled=0
GO

EXEC msdb.dbo.sp_update_job @job_name=N'Setup DDL Audit', @enabled=0
GO

IF  EXISTS (SELECT * FROM sys.triggers WHERE parent_class_desc = 'DATABASE' AND name = N'DatabaseAuditTrigger')
DROP TRIGGER [DatabaseAuditTrigger] ON DATABASE
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DatabaseAudit]') AND type in (N'U'))
DROP TABLE [dbo].[DatabaseAudit]
GO

IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N'server_audit')
DROP USER [server_audit]
GO

--
-- Re enable and install via install_db_ddl_auditing.sql
--
