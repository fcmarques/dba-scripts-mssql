IF  NOT EXISTS (SELECT * FROM msdb..sysschedules WHERE name = N'RCHLO_DBA_DatabaseBackup - FULL')
EXEC msdb.dbo.sp_add_schedule 
	@schedule_name=N'RCHLO_DBA_DatabaseBackup - FULL', 
	@enabled=1, 
	@freq_type=4, 
	@freq_interval=1, 
	@freq_subday_type=1, 
	@freq_subday_interval=0, 
	@freq_relative_interval=0, 
	@freq_recurrence_factor=0, 
	@active_start_time=10000, 
	@active_end_time=235959
GO

IF  NOT EXISTS (SELECT * FROM msdb..sysschedules WHERE name = N'RCHLO_DBA_DatabaseBackup - LOG')
EXEC msdb.dbo.sp_add_schedule 
	@schedule_name=N'RCHLO_DBA_DatabaseBackup - LOG', 
	@enabled=1, 
	@freq_type=4, 
	@freq_interval=1, 
	@freq_subday_type=8, 
	@freq_subday_interval=1, 
	@freq_relative_interval=0, 
	@freq_recurrence_factor=0, 
	@active_start_time=0, 
	@active_end_time=235959;
GO

IF  NOT EXISTS (SELECT * FROM msdb..sysschedules WHERE name = N'RCHLO_DBA_DatabaseBackup - DIFF')
EXEC msdb.dbo.sp_add_schedule 
	@schedule_name=N'RCHLO_DBA_DatabaseBackup - DIFF', 
	@enabled=1, 
	@freq_type=4, 
	@freq_interval=6, 
	@freq_subday_type=8, 
	@freq_subday_interval=1, 
	@freq_relative_interval=0, 
	@freq_recurrence_factor=0, 
	@active_start_time=0, 
	@active_end_time=235959;
GO

IF  NOT EXISTS (SELECT * FROM msdb..sysschedules WHERE name = N'RCHLO_DBA_Cleanup')
EXEC msdb.dbo.sp_add_schedule 
	@schedule_name=N'RCHLO_DBA_Cleanup', 
	@enabled=1, 
	@freq_type=8, 
	@freq_interval=1, 
	@freq_subday_type=1, 
	@freq_subday_interval=0, 
	@freq_relative_interval=0, 
	@freq_recurrence_factor=1, 
	@active_start_time=0, 
	@active_end_time=235959;
GO

IF  NOT EXISTS (SELECT * FROM msdb..sysschedules WHERE name = N'RCHLO_DBA_DatabaseIntegrityCheck')
EXEC msdb.dbo.sp_add_schedule 
	@schedule_name=N'RCHLO_DBA_DatabaseIntegrityCheck', 
	@enabled=1, 
	@freq_type=8, 
	@freq_interval=64, 
	@freq_subday_type=1, 
	@freq_subday_interval=0, 
	@freq_relative_interval=0, 
	@freq_recurrence_factor=1, 
	@active_start_time=0, 
	@active_end_time=235959;
GO

IF  NOT EXISTS (SELECT * FROM msdb..sysschedules WHERE name = N'RCHLO_DBA_IndexOptimize')
EXEC msdb.dbo.sp_add_schedule 
	@schedule_name=N'RCHLO_DBA_IndexOptimize', 
	@enabled=1, 
	@freq_type=8, 
	@freq_interval=1, 
	@freq_subday_type=1, 
	@freq_subday_interval=0, 
	@freq_relative_interval=0, 
	@freq_recurrence_factor=1, 
	@active_start_time=0, 
	@active_end_time=235959;
GO

EXEC msdb.dbo.sp_attach_schedule 
	@job_name=N'RCHLO_DBA_CommandLog Cleanup',
	@schedule_name=N'RCHLO_DBA_Cleanup';
GO

EXEC msdb.dbo.sp_attach_schedule 
	@job_name=N'RCHLO_DBA_DatabaseBackup - SYSTEM_DATABASES - FULL',
	@schedule_name=N'RCHLO_DBA_DatabaseBackup - FULL';
GO

EXEC msdb.dbo.sp_attach_schedule 
	@job_name=N'RCHLO_DBA_DatabaseBackup - USER_DATABASES - DIFF',
	@schedule_name=N'RCHLO_DBA_DatabaseBackup - DIFF';
GO

EXEC msdb.dbo.sp_attach_schedule 
	@job_name=N'RCHLO_DBA_DatabaseBackup - USER_DATABASES - FULL',
	@schedule_name=N'RCHLO_DBA_DatabaseBackup - FULL';
GO

EXEC msdb.dbo.sp_attach_schedule 
	@job_name=N'RCHLO_DBA_DatabaseBackup - USER_DATABASES - LOG',
	@schedule_name=N'RCHLO_DBA_DatabaseBackup - LOG';
GO

EXEC msdb.dbo.sp_attach_schedule 
	@job_name=N'RCHLO_DBA_DatabaseIntegrityCheck - SYSTEM_DATABASES',
	@schedule_name=N'RCHLO_DBA_DatabaseIntegrityCheck';
GO

EXEC msdb.dbo.sp_attach_schedule 
	@job_name=N'RCHLO_DBA_DatabaseIntegrityCheck - USER_DATABASES',
	@schedule_name=N'RCHLO_DBA_DatabaseIntegrityCheck';
GO

EXEC msdb.dbo.sp_attach_schedule 
	@job_name=N'RCHLO_DBA_IndexOptimize - USER_DATABASES',
	@schedule_name=N'RCHLO_DBA_IndexOptimize';
GO

EXEC msdb.dbo.sp_attach_schedule 
	@job_name=N'RCHLO_DBA_Output File Cleanup',
	@schedule_name=N'RCHLO_DBA_Cleanup';
GO

EXEC msdb.dbo.sp_attach_schedule 
	@job_name=N'RCHLO_DBA_sp_delete_backuphistory',
	@schedule_name=N'RCHLO_DBA_Cleanup';
GO

EXEC msdb.dbo.sp_attach_schedule 
	@job_name=N'RCHLO_DBA_sp_purge_jobhistory',
	@schedule_name=N'RCHLO_DBA_Cleanup';
GO

