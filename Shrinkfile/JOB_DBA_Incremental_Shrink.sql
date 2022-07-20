USE [msdb]
GO

/****** Object:  Job [RCHLO_DBA_Incremental_Shrink]    Script Date: 06/13/2019 10:40:19 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Database Maintenance]    Script Date: 06/13/2019 10:40:19 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'RCHLO_DBA_Incremental_Shrink', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'RIACHUELO\3406555', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Incremental_Shrink]    Script Date: 06/13/2019 10:40:20 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Incremental_Shrink', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'declare @file_id_max int
declare @file_name varchar(100)

SELECT @file_id_max = MAX(file_id) from sys.database_files where type_desc = ''ROWS''

select @file_name = name from sys.database_files
where type_desc = ''ROWS''
and name not in (''R3PDATA17'',''R3PDATA37'')--,''R3PDATA1'',''R3PDATA42'',''R3PDATA92'',''R3PDATA150'',''R3PDATA137'',''R3PDATA102'',''R3PDATA90'',''R3PDATA108'',''R3PDATA97'',''R3PDATA38'',''R3PDATA31'',''R3PDATA69''
and file_id = ABS(Checksum(NewID()) % @file_id_max + 1)
Print ''Shrinking file - '' + @file_name
EXEC sp_Incremental_Shrink_DB_File @DBFileName=@file_name, @ShrinkIncrementMB=10000;', 
		@database_name=N'R3P', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Shrink', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=63, 
		@freq_subday_type=4, 
		@freq_subday_interval=10, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20180410, 
		@active_end_date=99991231, 
		@active_start_time=60000, 
		@active_end_time=25959, 
		@schedule_uid=N'02413dd1-69cb-424f-b993-39f758b40273'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


