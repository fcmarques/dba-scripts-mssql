IF  NOT EXISTS (SELECT * FROM msdb..sysschedules WHERE name = N'DBACorp_MS_DatabaseBackup - FULL')
EXEC msdb.dbo.sp_add_schedule 
	@schedule_name=N'DBACorp_MS_DatabaseBackup - FULL', 
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

IF  NOT EXISTS (SELECT * FROM msdb..sysschedules WHERE name = N'DBACorp_MS_DatabaseBackup - LOG')
EXEC msdb.dbo.sp_add_schedule 
	@schedule_name=N'DBACorp_MS_DatabaseBackup - LOG', 
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

IF  NOT EXISTS (SELECT * FROM msdb..sysschedules WHERE name = N'DBACorp_MS_DatabaseBackup - DIFF')
EXEC msdb.dbo.sp_add_schedule 
	@schedule_name=N'DBACorp_MS_DatabaseBackup - DIFF', 
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

IF  NOT EXISTS (SELECT * FROM msdb..sysschedules WHERE name = N'DBACorp_MS_Cleanup')
EXEC msdb.dbo.sp_add_schedule 
	@schedule_name=N'DBACorp_MS_Cleanup', 
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

IF  NOT EXISTS (SELECT * FROM msdb..sysschedules WHERE name = N'DBACorp_MS_DatabaseIntegrityCheck')
EXEC msdb.dbo.sp_add_schedule 
	@schedule_name=N'DBACorp_MS_DatabaseIntegrityCheck', 
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

IF  NOT EXISTS (SELECT * FROM msdb..sysschedules WHERE name = N'DBACorp_MS_IndexOptimize')
EXEC msdb.dbo.sp_add_schedule 
	@schedule_name=N'DBACorp_MS_IndexOptimize', 
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
	@job_name=N'DBACorp_MS_CommandLog Cleanup',
	@schedule_name=N'DBACorp_MS_Cleanup';
GO

EXEC msdb.dbo.sp_attach_schedule 
	@job_name=N'DBACorp_MS_DatabaseBackup - SYSTEM_DATABASES - FULL',
	@schedule_name=N'DBACorp_MS_DatabaseBackup - FULL';
GO

EXEC msdb.dbo.sp_attach_schedule 
	@job_name=N'DBACorp_MS_DatabaseBackup - USER_DATABASES - DIFF',
	@schedule_name=N'DBACorp_MS_DatabaseBackup - DIFF';
GO

EXEC msdb.dbo.sp_attach_schedule 
	@job_name=N'DBACorp_MS_DatabaseBackup - USER_DATABASES - FULL',
	@schedule_name=N'DBACorp_MS_DatabaseBackup - FULL';
GO

EXEC msdb.dbo.sp_attach_schedule 
	@job_name=N'DBACorp_MS_DatabaseBackup - USER_DATABASES - LOG',
	@schedule_name=N'DBACorp_MS_DatabaseBackup - LOG';
GO

EXEC msdb.dbo.sp_attach_schedule 
	@job_name=N'DBACorp_MS_DatabaseIntegrityCheck - SYSTEM_DATABASES',
	@schedule_name=N'DBACorp_MS_DatabaseIntegrityCheck';
GO

EXEC msdb.dbo.sp_attach_schedule 
	@job_name=N'DBACorp_MS_DatabaseIntegrityCheck - USER_DATABASES',
	@schedule_name=N'DBACorp_MS_DatabaseIntegrityCheck';
GO

EXEC msdb.dbo.sp_attach_schedule 
	@job_name=N'DBACorp_MS_IndexOptimize - USER_DATABASES',
	@schedule_name=N'DBACorp_MS_IndexOptimize';
GO

EXEC msdb.dbo.sp_attach_schedule 
	@job_name=N'DBACorp_MS_Output File Cleanup',
	@schedule_name=N'DBACorp_MS_Cleanup';
GO

EXEC msdb.dbo.sp_attach_schedule 
	@job_name=N'DBACorp_MS_sp_delete_backuphistory',
	@schedule_name=N'DBACorp_MS_Cleanup';
GO

EXEC msdb.dbo.sp_attach_schedule 
	@job_name=N'DBACorp_MS_sp_purge_jobhistory',
	@schedule_name=N'DBACorp_MS_Cleanup';
GO

