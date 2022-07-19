--
-- SQL 2008 DDL Auditing Solution
--
-- Install SQL 2008 Server and Database auditing for whole SQL instance.
--
-- Server level is held in dbadata and database level is in all databases.
--
-- Sean Elliott
-- sean_p_elliott@yahoo.co.uk
--
-- July 2010
--
--
-- Installation overview:
--
-- Create server_audit server login
-- Delete job Setup DDL Audit
-- Create job Setup DDL Audit
--    Step 1 Create Audit RESTORE DATABASE job
--    Step 2 Incremental install/fix
-- Start job Setup DDL Audit
--

USE [msdb]
GO

--
-- Create server audit login and give access to dbadata..ServerAudit
--
if not exists (select * from sys.server_principals where name = N'server_audit')
begin 
  print 'Create server_audit server login'
  create login [server_audit] with password=N'Password123', default_database=[master], check_expiration=off, check_policy=off
end
else begin
  print 'Skip create server_audit server login'
end
go

if exists (select job_id from msdb.dbo.sysjobs_view where name = N'Setup DDL Audit')
begin
  print 'Delete job Setup DDL Audit'
  exec msdb.dbo.sp_delete_job @job_name=N'Setup DDL Audit', @delete_unused_schedule=1
end
else begin
  print 'Skip delete job Setup DDL Audit'
end
go

if exists (select job_id from msdb.dbo.sysjobs_view where name = N'Audit RESTORE DATABASE')
begin
  print 'Delete job Audit RESTORE DATABASE'
  exec msdb.dbo.sp_delete_job @job_name=N'Audit RESTORE DATABASE', @delete_unused_schedule=1
end
else begin
  print 'Skip delete job Audit RESTORE DATABASE'
end
go

USE [msdb]
GO

print 'Create job Setup DDL Audit'

/****** Object:  Job [Setup DDL Audit]    Script Date: 06/01/2010 17:19:57 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [DBA Tasks]    Script Date: 06/01/2010 17:19:57 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'DBA Tasks' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'DBA Tasks'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

-- Include instance in paths
declare @InstName   sysname
declare @JobLogPath varchar(500)
declare @JobLogDir varchar(500)
declare @IsDir bit

set @InstName = Coalesce(Cast(ServerProperty('InstanceName') as sysname), 'MSSQLSERVER')
set @JobLogDir = 'I:\Program Files\MSSQL10.' + @InstName + '\Backup\Reports\'
set @JobLogDir = 'I:\Program Files\MSSQL\MSSQL10.' + @InstName + '\MSSQL\Backup\Reports\'
set @JobLogPath = @JobLogDir + 'Setup DDL Audit.txt'

-- Does the log folder exist?
create table #FileExists (IsFile bit, IsDir bit, HasParentDir bit)
insert #FileExists exec master.dbo.xp_fileexist @JobLogDir
select @IsDir = isDir from #FileExists
drop table #FileExists

if @IsDir = 0
begin
	print 'Must be a non standard installation because job log path does not exist:'
	print @JobLogDir
	print 'Edit the local copy of this script so that @JobLogDir is set to correct path!'
	print 'Rerun OK with correct path'
	goto QuitWithRollback
end


DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Setup DDL Audit', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'DBA Tasks', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Create Audit RESTORE DATABASE]    Script Date: 06/01/2010 17:19:58 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Create Audit RESTORE DATABASE', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--
-- SQL 2008 DDL Auditing Solution
--
-- Create job to audit RESTORE DATABASE commands.
--
-- Sean Elliott
-- sean_p_elliott@yahoo.co.uk
--
-- July 2010
--
-- DO NOT EDIT THIS JOB DIRECTLY - edit script install_on_all_db.sql
--

use [msdb]
go

IF NOT EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N''Audit RESTORE DATABASE'')
BEGIN
  BEGIN TRANSACTION
  DECLARE @ReturnCode INT
  SELECT @ReturnCode = 0

  IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N''DDL Audit'' AND category_class=1)
  BEGIN
  EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N''JOB'', @type=N''LOCAL'', @name=N''DDL Audit''
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

  END

  DECLARE @jobId BINARY(16)
  EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N''Audit RESTORE DATABASE'', 
		  @enabled=1, 
		  @notify_level_eventlog=0, 
		  @notify_level_email=0, 
		  @notify_level_netsend=0, 
		  @notify_level_page=0, 
		  @delete_level=0, 
		  @description=N''Copies new RESTORE DATABASE auditing from msdb.dbo.restorehistory to dbadata.dbo.ServerAudit every minute'', 
		  @category_name=N''DDL Audit'', 
		  @owner_login_name=N''sa'', @job_id = @jobId OUTPUT
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
  /****** Object:  Step [Audit RESTORE DATABASE commands]    Script Date: 05/26/2010 15:11:10 ******/
  EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N''Audit RESTORE DATABASE commands'', 
		  @step_id=1, 
		  @cmdexec_success_code=0, 
		  @on_success_action=1, 
		  @on_success_step_id=0, 
		  @on_fail_action=2, 
		  @on_fail_step_id=0, 
		  @retry_attempts=0, 
		  @retry_interval=0, 
		  @os_run_priority=0, @subsystem=N''TSQL'', 
		  @command=N''--
-- SQL 2008 DDL Auditing Solution
--
-- Install Audit RESTORE DATABASE job which detects database restores and copies the details from
-- msdb to dbadata.dbo.ServerAudit
--
-- Sean Elliott
-- sean_p_elliott@yahoo.co.uk
--
-- July 2010
--
-- DO NOT EDIT THIS JOB DIRECTLY - edit script install_on_all_db.sql
--

insert  dbadata.dbo.ServerAudit
  (
    AuditDate, LoginName, EventType,
    ServerName, DatabaseName, SchemaName, 
    ObjectName, TSQLCommand, XMLEventData
  )
  select  restore_date AuditDate,
          user_name LoginName,
          ''''RESTORE_DATABASE'''' EventType,
          @@servername ServerName,
          destination_database_name DatabaseName,
          null SchemaName,
          null ObjectName,
          ''''RESTORE DATABASE '''' + destination_database_name + 
            '''', backup_set_id = '''' + convert(varchar, backup_set_id) +
            '''', restore_type = '''' + restore_type + 
            '''', replace = '''' + convert(varchar, replace) + 
            '''', recovery = '''' + convert(varchar, recovery),
            ''''Generated by SQL Agent job Audit RESTORE DATABASE'''' XMLEventData
            from  msdb.dbo.restorehistory
            where restore_date > isnull((select max(AuditDate) from dbadata.dbo.ServerAudit where EventType = ''''RESTORE_DATABASE''''), ''''1900-Jan-01'''')

  -- Any restores just audited?
  if @@rowcount > 0
  begin
    -- Make sure that DDL auditing is installed/fixed for databases just restored
    exec msdb.dbo.sp_start_job ''''Setup DDL Audit''''
  end
            
  '', 
		  @database_name=N''master'', 
		  @flags=4
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
  EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
  EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N''Every 1 minute'', 
		  @enabled=1, 
		  @freq_type=4, 
		  @freq_interval=1, 
		  @freq_subday_type=4, 
		  @freq_subday_interval=1, 
		  @freq_relative_interval=0, 
		  @freq_recurrence_factor=0, 
		  @active_start_date=20100521, 
		  @active_end_date=99991231, 
		  @active_start_time=0, 
		  @active_end_time=235959, 
		  @schedule_uid=N''6edeb9cd-a368-41a0-80cd-83e01e6b926f''
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
  EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N''(local)''
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
  COMMIT TRANSACTION
  GOTO EndSave
  QuitWithRollback:
      IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
  EndSave:
END
GO


', 
		@database_name=N'msdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Incremental install/fix]    Script Date: 06/01/2010 17:19:58 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Incremental install/fix', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--
-- SQL 2008 DDL Auditing Solution
--
-- Install SQL 2008 Server and Database auditing for whole SQL instance.
--
-- Server level is held in dbadata and database level is in all databases.
--
-- Sean Elliott
-- sean_p_elliott@yahoo.co.uk
--
-- July 2010
--
--
-- DO NOT EDIT THIS JOB DIRECTLY - edit script install_on_all_db.sql
--
--
-- Installation overview:
--
-- Create ServerAudit table in dbadata
-- Create dbadata server_audit user and grant access to dbadata..ServerAudit 
-- Create server audit trigger in dbadata
-- Create DatabaseAudit table in all databases except:
--  i  Already exists
--  ii tempdb
-- Create server audit users in all databases and grant insert access to DatabaseAudit table except:
--  i  Already exists (including dbadata)
--  ii tempdb
-- Grant server_audit permission to run jobs Audit RESTORE DATABASE and Setup DDL Audit
-- Create database audit trigger in dbadata only
-- Clone database audit trigger to all databases except:
--  i  Already exists
--  ii tempdb
-- Fix any broken user SID. (This happens when a database is restored from a different server.)
-- Clear down model.dbo.DatabaseAudit so that new databases start with an empty table
--

--
-- Create server audit table in dbadata
--

set nocount on
go

use dbadata
go

if not exists (select * from sys.objects where object_id = object_id(N''[dbo].[ServerAudit]'') and type in (N''U''))
begin
  create table [dbo].[ServerAudit](
	  [AuditDate] [datetime] not null,
	  [LoginName] [sysname] not null,
	  [EventType] [sysname] not null,
	  [ServerName] [sysname] not null,
	  [DatabaseName] [sysname] null,
	  [SchemaName] [sysname] null,
	  [ObjectName] [sysname] null,
	  [TSQLCommand] [varchar](max) null,
	  [XMLEventData] [xml] not null
  ) on [primary]

  create clustered index [ServerAudit_IX_AuditDate] ON [dbo].[ServerAudit] 
  (
	  [AuditDate] desc
  ) on [primary]
  
  create nonclustered index [ServerAudit_IX_EventType] ON [dbo].[ServerAudit]
  (
    [EventType]
  ) on [primary]
end
else begin
  print ''Skip create ServerAudit table for [dbadata]''
end
go

if not exists (select * from sys.database_principals where name = N''server_audit'')
begin
  create user [server_audit] for login [server_audit]
  grant connect on database::[dbadata] to [server_audit];
  grant insert, select on [dbo].[ServerAudit] to [server_audit]
end
else begin
  print ''Skip create server_audit user for [dbadata]''
end
go

-- Flag table - cannot use variables because "create trigger" must be only command in batch
create table #disable_master_db_audit (disable_trigger bit not null)
go

--
-- Create server audit trigger in dbadata
-- "create trigger" must be only command in batch so always have to drop and create
-- The "create trigger" cannot be within if statement
--
if exists (select * from master.sys.server_triggers where parent_class_desc = ''SERVER'' and name = N''ServerAuditTrigger'')
begin
  -- Set a # table flag - cannot use variables because "create trigger" must be only command in batch
  insert #disable_master_db_audit select 1;
  
  -- Does master database have a DatabaseAuditTrigger?
  if exists (select * from master.sys.triggers where parent_class_desc = ''DATABASE'' and name = N''DatabaseAuditTrigger'')
  begin
     use master;
     
    -- Disable the master DB DatabaseAuditTrigger so that does not audit the drop and create
    -- of ServerAuditTrigger every time - only initial create
    -- It does not get audited by ServerAuditTrigger either
    disable trigger DatabaseAuditTrigger on database
    
    use dbadata
  end  
  
  print ''Disable and drop ServerAuditTrigger - has to be recreated every time'';
  disable trigger ServerAuditTrigger on all server
  drop trigger ServerAuditTrigger on all server
end
else begin
  insert #disable_master_db_audit select 0;
  print ''Skip disable and drop ServerAuditTrigger''
end
go

print ''Create ServerAuditTrigger - has to be recreated every time''

-- Needed for XML data type
-- These options are create time only for stored procedures (and so triggers)
-- These should also be default connection options so no need to revert
set ansi_nulls on
set quoted_identifier on
go

create trigger ServerAuditTrigger
on all server
-- Audit server level and database level into dbadata.dbo.ServerAudit
-- The database level is also audited into <database>.dbo.DatabaseAudit
with execute as ''server_audit''
for ddl_events
as 
begin
  --
  -- SQL 2008 DDL Auditing Solution
  --
  -- Server level DDL audit
  --
  -- Sean Elliott
  -- sean_p_elliott@yahoo.co.uk
  --
  -- July 2010
  --
  
  set nocount on 
  
  -- Needed for xml data type
  set ansi_padding on
  set ansi_warnings on
  set arithabort on
  set concat_null_yields_null on
  set numeric_roundabort off
   
  declare @EventData xml,
          @EventType sysname,
          @TSQLCommand varchar(max)
    
  set @EventData = EventData()
  
   -- debug
--  select @EventData

  set @EventType = @EventData.value(''data(/EVENT_INSTANCE/EventType)[1]'', ''sysname'')
  set @TSQLCommand = @EventData.value(''data(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]'', ''varchar(max)'')
  
  -- Has a database just been attached? It may not have DDL auditing in it so add now if required via job
  if @EventType = ''CREATE_DATABASE'' and @TSQLCommand like ''%create%database%for%attach%''
  begin
    exec msdb.dbo.sp_start_job N''Setup DDL Audit''
  end
    
  insert dbadata.dbo.ServerAudit
  (
    AuditDate, LoginName, EventType, ServerName, DatabaseName, SchemaName, ObjectName, TSQLCommand, XMLEventData
  )
  select 
    getdate(),
    @EventData.value(''data(/EVENT_INSTANCE/LoginName)[1]'', ''sysname''),
    @EventType,
    @EventData.value(''data(/EVENT_INSTANCE/ServerName)[1]'', ''sysname''),
    @EventData.value(''data(/EVENT_INSTANCE/DatabaseName)[1]'', ''sysname''),
    coalesce
    ( @EventData.value(''data(/EVENT_INSTANCE/SchemaName)[1]'', ''sysname''),
      @EventData.value(''data(/EVENT_INSTANCE/DefaultSchema)[1]'', ''sysname'')
    ), 
    @EventData.value(''data(/EVENT_INSTANCE/ObjectName)[1]'', ''sysname''), 
    @TSQLCommand,
    @EventData
end
go

--
-- Everything past here will now be audited at the server level (only)
--
enable trigger ServerAuditTrigger on all server
go


-- Did we just disable the master DB auditing?
-- Cannot use variables because of "create trigger" restrictions
if exists (select disable_trigger from #disable_master_db_audit where disable_trigger = 1)
begin
  use master;
  enable trigger DatabaseAuditTrigger on database;
  use dbadata;
end
go

drop table #disable_master_db_audit
go


--
-- Create the DatabaseAudit table in all applicable databases where it does not already exist
--
exec sp_MSForEachDB
''
  use [?];
  
  if not exists (select * from sys.objects where object_id = object_id(''''[dbo].[DatabaseAudit]'''') and type in (''''U''''))
  and ''''?'''' not in (''''tempdb'''')
  begin
    print ''''Create for DatabaseAudit table for [?]''''
    create table [?].[dbo].[DatabaseAudit](
	      [AuditDate] [datetime] not null,
	      [LoginName] [sysname] not null,
	      [EventType] [sysname] not null,
	      [SchemaName] [sysname] null,
	      [ObjectName] [sysname] null,
	      [TSQLCommand] [varchar](max) null,
	      [XMLEventData] [xml] not null
      ) ON [PRIMARY]
    create clustered index DatabaseAudit_IX_AuditDate on [DatabaseAudit](AuditDate DESC)
  end
  else begin
    print ''''Skip create DatabaseAudit table for [?]''''
  end
''

--
-- Give server_audit login/user ability to write to the DatabaseAudit table in all databases
--
exec sp_MSForEachDB
''
  use [?];
  
  if not exists (select * from sys.database_principals where name = N''''server_audit'''')
  and ''''?'''' not in (''''tempdb'''')
  begin
     print ''''Create user [server_audit] for database ?''''
     create user [server_audit] for login [server_audit] with default_schema=[dbo];
     grant connect on database::[?] to [server_audit];
     grant insert on [?].[dbo].[DatabaseAudit] to [server_audit];
  end
  else begin
     print ''''Skip create user [server_audit] for database ?''''
  end
''

--
-- Setup dbadata user permissions if required
-- User already exists because created above with dbadata.dbo.ServerAudit so permission
-- not created with the others above. Check whether permssion already exists before granting
--
if not exists
( select tab.name, ppl.name
  from sys.database_permissions prm
  join sys.tables tab
  on prm.major_id = tab.object_id
  join sys.database_principals ppl
  on ppl.principal_id = prm.grantee_principal_id
  where class = 1
  and tab.name = ''DatabaseAudit''
  and ppl.name = ''server_audit''
)
begin
  print ''grant insert on [dbadata].[dbo].[DatabaseAudit] to [server_audit]''
  grant insert on [dbadata].[dbo].[DatabaseAudit] to [server_audit];
end
else begin
  print ''Skip grant insert on [dbadata].[dbo].[DatabaseAudit] to [server_audit]''
end
go

--
-- Allow server_audit to run job "Setup DDL Audit" expediently
--
use [msdb]
go

if not exists
(
  select mpl.name
  from sys.database_principals rol
  join sys.database_role_members mrs
  on mrs.role_principal_id = rol.principal_id
  join sys.database_principals mpl
  on mpl.principal_id = mrs.member_principal_id
  where rol.name = ''SQLAgentOperatorRole''
  and mpl.type = ''S''
  and mpl.name = ''server_audit''
)
begin
  print ''Add server_audit to role SQLAgentOperatorRole''
  exec sp_addrolemember N''SQLAgentOperatorRole'', N''server_audit''
end
else begin
  print ''Skip add server_audit to role SQLAgentOperatorRole''
end
go

--
-- Create the (functional) template DatabaseAuditTrigger in dbadata
-- This is cloned to all other applicable databases next
-- "create trigger" must be only command in batch so always have to drop and create
-- The "create trigger" cannot be within if statement
--
use dbadata
go

-- Flag table - cannot use variables because "create trigger" must be only command in batch
create table #disable_server_audit (disable_trigger bit not null)
go

if exists (select * from sys.triggers where parent_class_desc = ''DATABASE'' and name = N''DatabaseAuditTrigger'')
begin
  -- Set a # table flag - cannot use variables because "create trigger" must be only command in batch
  insert #disable_server_audit select 1;
  disable trigger ServerAuditTrigger on all server
  
  print ''Disable and drop dbadata DatabaseAuditTrigger - has to be recreated every time'';
  disable trigger DatabaseAuditTrigger on database
  drop trigger DatabaseAuditTrigger on database
end
else begin
  -- Set a # table flag - cannot use variables because "create trigger" must be only command in batch
  insert #disable_server_audit select 0;
end
go

-- Needed for XML data type
-- These options are create time only for stored procedures (and so triggers)
-- These should also be default connection options so no need to revert
set ansi_nulls on
set quoted_identifier on
go

print ''Create dbadata DatabaseAuditTrigger - has to be recreated every time''
go

create trigger DatabaseAuditTrigger
on database
with execute as ''server_audit''
for ddl_database_level_events
as 
begin
  --
  -- SQL 2008 DDL Auditing Solution
  --
  -- Database level DDL audit
  --
  -- Sean Elliott
  -- sean_p_elliott@yahoo.co.uk
  --
  -- July 2010
  --
  
  set nocount on 

  -- Needed for XML datatype
  set ansi_padding on
  set ansi_warnings on
  set arithabort on
  set concat_null_yields_null on
  set numeric_roundabort off
  
  declare @EventData xml
    
  set @EventData = eventdata()
  
  -- debug
--  select @EventData
  
  insert dbo.DatabaseAudit (AuditDate, LoginName, EventType, SchemaName, ObjectName, TSQLCommand, XMLEventData)
  select 
    getdate(),
    @EventData.value(''data(/EVENT_INSTANCE/LoginName)[1]'', ''sysname''),
    @EventData.value(''data(/EVENT_INSTANCE/EventType)[1]'', ''sysname''),
    isnull
    ( @EventData.value(''data(/EVENT_INSTANCE/SchemaName)[1]'', ''sysname''), 
      @EventData.value(''data(/EVENT_INSTANCE/DefaultSchema)[1]'', ''sysname'')
    ),
    @EventData.value(''data(/EVENT_INSTANCE/ObjectName)[1]'', ''sysname''),
    @EventData.value(''data(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]'', ''varchar(max)''),
    @EventData
  
end   
go

enable trigger DatabaseAuditTrigger on database
go

-- Did we just disable the server auditing?
-- Cannot use variables because of "create trigger" restrictions
if exists (select disable_trigger from #disable_server_audit where disable_trigger = 1)
begin
  enable trigger ServerAuditTrigger on all server
end
go

drop table #disable_server_audit
go

--
-- Install the database trigger in all applicable databases by cloning from dbadata
--
exec sp_MSForEachDB
''
  use [?];
  
  if not exists (select * from sys.triggers where parent_class_desc = ''''DATABASE'''' and name = N''''DatabaseAuditTrigger'''')
     and ''''?'''' not in (''''tempdb'''')
  begin
    declare @sql nvarchar(max)
  
    select  @sql = sqm.definition
    from    dbadata.sys.triggers trg
    join    dbadata.sys.sql_modules sqm
    on      trg.object_id = sqm.object_id
    where   trg.name = ''''DatabaseAuditTrigger''''

    print ''''Create DatabaseAuditTrigger for [?]''''
    
    -- Needed for XML data type - something implicitly unsets them - these are needed
    set ansi_nulls on
    set quoted_identifier on

    print @sql
    exec(@sql)
  end
  else begin
    print ''''Skip create DatabaseAuditTrigger for [?]''''
  end
''

--
-- Fix any broken user SID. This happens when a database is restored from a different server.
-- The SID for the database user would not match that for the server login
--
exec sp_MSForEachDB
''
  use [?];
  
  if ''''?'''' != ''''tempdb''''
  and not exists
  (
    select  1
    from    master.sys.syslogins lgi
    join    sys.sysusers usr
    -- Fix OFF collation problem
--    on      lgi.name = usr.name
    on      lgi.name COLLATE DATABASE_DEFAULT = usr.name COLLATE DATABASE_DEFAULT
    where   lgi.name = ''''server_audit''''
    and     lgi.sid = usr.sid
  )
  begin
    print ''''Fix server_audit user sid for [?]''''
    alter user server_audit with login = server_audit
  end
  else begin
    print ''''Skip fix server_audit user sid for [?]''''
  end
''

-- Clear down model.dbo.DatabaseAudit so that new databases start with an empty table
-- We don''t care (much) about auditing model anyway
set nocount off

print ''Clear down model.dbo.DatabaseAudit so that new databases start with an empty table''
delete model.dbo.DatabaseAudit
go
', 
		@database_name=N'master', 
		@output_file_name=@JobLogPath, 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20100521, 
		@active_end_date=99991231, 
		@active_start_time=24500, 
		@active_end_time=235959, 
		@schedule_uid=N'2036f7c0-009c-46ed-8e90-533351df29cd'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

-- Run the job to install other objects
exec msdb.dbo.sp_start_job 'Setup DDL Audit'
go
