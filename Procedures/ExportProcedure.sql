USE [msdb]
GO
 
/****** Object:  Job [ExportProcedure]    Script Date: 11/23/2012 15:21:11 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Database Maintenance]    Script Date: 11/23/2012 15:21:11 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
 
END
 
DECLARE @jobId BINARY(16)
DECLARE @LoggedInUser NVARCHAR(100)
SELECT @LoggedInUser = SUSER_NAME()
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'ExportProcedure', 
        @enabled=1, 
        @notify_level_eventlog=0, 
        @notify_level_email=0, 
        @notify_level_netsend=0, 
        @notify_level_page=0, 
        @delete_level=0, 
        @description=N'This job backups all database stored procedures and function to physical drive.', 
        @category_name=N'Database Maintenance', 
        @owner_login_name=@LoggedInUser, @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [ExportProcedureScript]    Script Date: 11/23/2012 15:21:11 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'ExportProcedureScript', 
        @step_id=1, 
        @cmdexec_success_code=0, 
        @on_success_action=1, 
        @on_success_step_id=0, 
        @on_fail_action=2, 
        @on_fail_step_id=0, 
        @retry_attempts=0, 
        @retry_interval=0, 
        @os_run_priority=0, @subsystem=N'TSQL', 
        @command=N'USE msdb
GO
IF OBJECT_ID(''USP_BackupAllStoredProcedures'') IS NOT NULL
DROP PROC USP_BackupAllStoredProcedures
GO
 
/*==========================================================================================    
Name:  Export all stored procedures for all user databases to particular location    
Author:  Aadhar Joshi    
Parameters:   
@ExportDataPath specifies location to where backup of sp needs to store.  eg. ''C:\Backup\StoredProcedure\''   
Returns:      
Description: It creates main folder in @ExportDataPath which contains current 
   date and time, in that folder it creates different folders for each databases and   
creates stored procedure related to database.   
==========================================================================================*/    
    
CREATE PROCEDURE [dbo].[USP_BackupAllStoredProcedures]
    (
      @ExportDataPath NVARCHAR(1000) = NULL    
    )
AS 
    BEGIN    
        SET QUOTED_IDENTIFIER OFF  
        SET NOCOUNT ON  
        BEGIN TRY  
            DECLARE @ExportPath AS NVARCHAR(1000)  
            SET @ExportPath = @ExportDataPath  
            IF ( ISNULL(@ExportPath, '''') = '''' ) 
                BEGIN  
                    SET @ExportPath = ''C:\Backup\StoredProcedure\''  
                END  
            SET @ExportPath += ( SELECT CONVERT(VARCHAR(100), GETDATE(), 102)
                                        + ''_''
                                        + REPLACE(CONVERT(VARCHAR(100), GETDATE(), 108),
                                                  '':'', ''.'')
                               ) + ''\''  
            -- variables for first while loop  
            DECLARE @DatabaseName AS NVARCHAR(1000)  
            -- variables for second while loop  
            DECLARE @ExportFilePath NVARCHAR(1000)        
            DECLARE @ServerName NVARCHAR(100)        
            SELECT  @ServerName = CONVERT(SYSNAME, SERVERPROPERTY(N''servername''))     
            DECLARE @GetProcedureNames NVARCHAR(MAX)  
            IF OBJECT_ID(''tempdb..#Databases'') IS NOT NULL 
                DROP TABLE #Databases   
            SELECT  name ,
                    ROW_NUMBER() OVER ( ORDER BY name ) AS RowNum
            INTO    #Databases
            FROM    sys.databases
            WHERE   database_id > 4  
            DECLARE @DatabaseCurrentPosition INT = 1  
            WHILE @DatabaseCurrentPosition <= ( SELECT  COUNT(1)
                                                FROM    #Databases
                                              ) 
                BEGIN  
                    SELECT  @DatabaseName = NAME
                    FROM    #Databases
                    WHERE   RowNum = @DatabaseCurrentPosition  
                    SET @ExportFilePath = @ExportPath + @DatabaseName       
                    EXECUTE master.dbo.xp_create_subdir @ExportFilePath   
                    IF OBJECT_ID(''tempdb..#Procedures'') IS NOT NULL 
                        DROP TABLE #Procedures   
                    CREATE TABLE #Procedures
                        (
                          RoutineName NVARCHAR(MAX) ,
                          RowNum INT ,
                          ObjectID INT
                        )  
                    SET @GetProcedureNames = N''INSERT INTO #Procedures 
                         SELECT QUOTENAME(s.[name]) + ''''.'''' + QUOTENAME(o.[name]) AS RoutineName  
                     ,ROW_NUMBER() OVER ( ORDER BY s.[name],o.[name]) AS RowNum,sm.object_id as ObjectID FROM ''
                        + @DatabaseName + ''.sys.objects AS o  INNER JOIN ''
                        + @DatabaseName
                        + ''.sys.schemas AS s ON s.[schema_id] = o.[schema_id] INNER JOIN ''
                        + @DatabaseName
                        + ''.sys.sql_modules sm ON o.[object_id]=sm.[object_id]            
                        WHERE type IN (''''p'''',''''v'''',''''fn'''') AND o.is_ms_shipped = 0 ''        
                    EXEC(@GetProcedureNames)
                    IF ( ( SELECT   COUNT(1)
                           FROM     #Procedures
                         ) > 1 ) 
                        BEGIN
                            DECLARE @ProcedureCurrentPosition INT = 1  
                            WHILE @ProcedureCurrentPosition <= ( SELECT
                                                              COUNT(1)
                                                              FROM
                                                              #Procedures
                                                              ) 
                                BEGIN  
                                    DECLARE @ProcedureContent NVARCHAR(MAX)     
                                    DECLARE @ProcedureName NVARCHAR(MAX)   
                                    DECLARE @ObjectID INT
                                    
                                    Select  @ProcedureName = RoutineName ,
                                            @ObjectID = ObjectID
                                    FROM    #Procedures
                                    WHERE   RowNum = @ProcedureCurrentPosition 
                                    SET @ExportFilePath = @ExportPath
                                        + @DatabaseName + ''\'' + @ProcedureName
                                        + ''.sql''  
                                    DECLARE @Que NVARCHAR(MAX)= ''Select Definition from ''
                                        + @dataBaseName
                                        + ''.sys.sql_modules sm where sm.[object_id]=''
                                        + CAST (@objectID AS NVARCHAR)
                          
                                    DECLARE @sql NVARCHAR(4000)        
                                    SELECT  @sql = ''bcp "'' + @Que
                                            + ''" queryout '' + @ExportFilePath
                                            + '' -c -t -T -S'' + ''''
                                            + @ServerName + ''''  
                                    EXEC xp_cmdshell @sql   
                                    SET @ProcedureCurrentPosition = @ProcedureCurrentPosition
                                        + 1  
                                END    
                        END      
                    SET @DatabaseCurrentPosition = @DatabaseCurrentPosition
                        + 1  
                END     
        END TRY        
        BEGIN CATCH        
   -- Raise an error with the details of the exception   
            DECLARE @ErrMsg NVARCHAR(4000) ,
                @ErrSeverity INT        
            SELECT  @ErrMsg = ERROR_MESSAGE() ,
                    @ErrSeverity = ERROR_SEVERITY()        
            RAISERROR(@ErrMsg, @ErrSeverity,1)        
            RETURN        
        END CATCH ;    
    END
GO
 
EXEC USP_BackupAllStoredProcedures
     
        
', 
        @database_name=N'msdb', 
        @flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'ExportProcedures', 
        @enabled=1, 
        @freq_type=4, 
        @freq_interval=1, 
        @freq_subday_type=1, 
        @freq_subday_interval=0, 
        @freq_relative_interval=0, 
        @freq_recurrence_factor=0, 
        @active_start_date=20121123, 
        @active_end_date=99991231, 
        @active_start_time=80000, 
        @active_end_time=235959, 
        @schedule_uid=N'637344da-963e-4b7e-9829-9fbdd90fc738'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
 
GO
 