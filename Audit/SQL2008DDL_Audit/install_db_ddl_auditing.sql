--
-- SQL 2008 DDL Auditing Solution
--
-- Re enable jobs to re-install a DB DDL following use of uninstall_db_ddl_auditing.sql
--
-- Sean Elliott
-- sean_p_elliott@yahoo.co.uk
--
-- September 2010
--

EXEC msdb.dbo.sp_update_job @job_name=N'Audit RESTORE DATABASE', 
		@enabled=1
GO

EXEC msdb.dbo.sp_update_job @job_name=N'Setup DDL Audit', 
		@enabled=1
GO

-- Reinstall DDL auditing where missing
exec msdb.dbo.sp_start_job 'Setup DDL Audit'
