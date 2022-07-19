--
-- SQL 2005 DDL Auditing Solution
--
-- Install SQL 2005 Server and Database auditing for whole SQL instance.
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
--    Step 1 Create Audit RESTORE/ATTACH DATABASE job
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

if exists (select job_id from msdb.dbo.sysjobs_view where name = N'Audit RESTORE/ATTACH DATABASE')
begin
  print 'Delete job Audit RESTORE/ATTACH DATABASE'
  exec msdb.dbo.sp_delete_job @job_name=N'Audit RESTORE/ATTACH DATABASE', @delete_unused_schedule=1
end
else begin
  print 'Skip delete job Audit RESTORE/ATTACH DATABASE'
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
-- set @JobLogDir = 'I:\Program Files\MSSQL10.' + @InstName + '\Backup\Reports\'
-- set @JobLogDir = 'I:\Program Files\MSSQL\MSSQL10.' + @InstName + '\MSSQL\Backup\Reports\'
-- SQL 2005 specific
set @JobLogDir = 'I:\Program Files\mssql\maintenance\reports\'
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
/****** Object:  Step [Create Audit RESTORE/ATTACH DATABASE]    Script Date: 06/01/2010 17:19:58 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Create Audit RESTORE/ATTACH DATABASE', 
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
-- SQL 2005 DDL Auditing Solution
--
-- Create job to audit DATABASE RESTORE and CREATE DATABASE FOR ATTACH
--
-- Sean Elliott
-- sean_p_elliott@yahoo.co.uk
--
-- July 2010
--
-- DO NOT EDIT THIS JOB DIRECTLY - edit script install_on_all_db_2005.sql
--

use [msdb]
go

IF NOT EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N''Audit RESTORE/ATTACH DATABASE'')
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
  EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N''Audit RESTORE/ATTACH DATABASE'', 
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
  /****** Object:  Step [Audit RESTORE/ATTACH DATABASE commands]    Script Date: 05/26/2010 15:11:10 ******/
  EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N''Audit RESTORE/ATTACH DATABASE commands'', 
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
-- SQL 2005 DDL Auditing Solution
--
-- Install Audit RESTORE/ATTACH DATABASE job which detects database attaches and restores
-- and copies the details from sys.databases and msdb.restorehistory to dbadata.dbo.ServerAudit
--
-- Sean Elliott
-- sean_p_elliott@yahoo.co.uk
--
-- July 2010
--
-- DO NOT EDIT THIS JOB DIRECTLY - edit script install_on_all_db_2005.sql
--

--
-- SQL 2005 specific
--
-- Audit CREATE DATABASE FOR ATTACH
--

-- If database exists but there is no audit trail for it having been
-- created or restored it must have been attached ie audit it as having been attached
-- It is not possible to audit CREATE DATABASE FOR ATTACH via DDL trigger - not fired for that event
-- SQL 2008 audits ATTACH as CREATE_DATABASE event so generated here as CREATE_DATABASE
insert  dbadata.dbo.ServerAudit
(
  AuditDate, LoginName, EventType,
  ServerName, DatabaseName, SchemaName, 
  ObjectName, TSQLCommand, XMLEventData
)
select  sdb.create_date AuditDate,
        suser_sname(sdb.owner_sid) LoginName,
        ''''CREATE_DATABASE'''' EventType,
        @@servername ServerName, 
        sdb.name DatabaseName,
        null SchemaName,
        null ObjectName, 
        (
          select  TOP 1 ''''CREATE DATABASE '''' + sdb.name + '''' FOR ATTACH '''' + smf.name + '''' = "'''' + smf.physical_name + ''''"''''
          from    master.sys.master_files smf 
          where   sdb.database_id = smf.database_id
          and     smf.type_desc = ''''ROWS''''
          order by file_id asc
        ) +
        (
          select  TOP 1 '''', '''' + smf.name + '''' = "'''' + smf.physical_name + ''''"''''
          from    master.sys.master_files smf 
          where   sdb.database_id = smf.database_id
          and     smf.type_desc = ''''LOG''''
          order by file_id asc
        ) TSQLCommand,
        ''''CREATE_DATABASE FOR ATTACH - Generated by SQL Agent job Audit RESTORE/ATTACH DATABASE'''' XMLEventData
from    master.sys.databases sdb
where not exists
(
  select  1
  from    dbadata.dbo.ServerAudit sva
  where   sva.EventType in (''''CREATE_DATABASE'''')
  and     sva.DatabaseName = sdb.name
  and     sdb.create_date <= sva.AuditDate
)

-- Any attaches just audited?
if @@rowcount > 0
begin
  -- Make sure that DDL auditing is installed/fixed for databases just restored
  exec msdb.dbo.sp_start_job ''''Setup DDL Audit''''
end
 
--
-- Audit RESTORE DATABASE
--
insert  dbadata.dbo.ServerAudit
(
  AuditDate, LoginName, EventType,
  ServerName, DatabaseName, SchemaName, 
  ObjectName, TSQLCommand, XMLEventData
)
select  rsh.restore_date AuditDate,
        rsh.user_name LoginName,
        ''''RESTORE_DATABASE'''' EventType,
        @@servername ServerName,
        rsh.destination_database_name DatabaseName,
        null SchemaName,
        null ObjectName,
        ''''RESTORE DATABASE '''' + rsh.destination_database_name + 
          '''', backup_set_id = '''' + convert(varchar, rsh.backup_set_id) +
          '''', restore_type = '''' + rsh.restore_type + 
          '''', replace = '''' + convert(varchar, rsh.replace) + 
          '''', recovery = '''' + convert(varchar, rsh.recovery),
          ''''RESTORE_DATABASE - Generated by SQL Agent job Audit RESTORE/ATTACH DATABASE'''' XMLEventData
          from  msdb.dbo.restorehistory rsh
          where rsh.restore_date > isnull((select max(AuditDate) from dbadata.dbo.ServerAudit where EventType = ''''RESTORE_DATABASE''''), ''''1900-Jan-01'''')

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
		  @active_end_time=235959/*, 
		  @schedule_uid=N''6edeb9cd-a368-41a0-80cd-83e01e6b926f''*/
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
-- Install SQL 2008 Server and Database auditing for whole SQL instance.
--
-- Server level is held in dbadata and database level is in all databases.
--
-- Sean Elliott
-- June 2010
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
--for ddl_events
-- SQL 2005 specific
-- A specific list is required for SQL 2005 auditing purposes and can only be at server level
-- For SQL 2008 server level auditing can include database level events
for 
  alter_authorization_server,
  create_database,
  alter_database,
  drop_database,
  create_endpoint,
  drop_endpoint,
  create_login,
  alter_login,
  drop_login,
  grant_server,
  deny_server,
  revoke_server
as 
begin
  --
  -- SQL 2005 DDL Auditing Solution
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
  
  -- This does not work in SQL 2005 because CREATE DATABASE FOR ATTACH does not fire this trigger
  -- In SQL 2005 attached databases are audited similarly to RESTORE DATABASE via job Audit RESTORE/ATTACH DATABASE
  -- Has a database just been attached? It may not have DDL auditing in it so add now if required via job
/*
  if @EventType = ''CREATE_DATABASE'' and @TSQLCommand like ''%create%database%for%attach%''
  begin
    exec msdb.dbo.sp_start_job N''Setup DDL Audit''
  end
*/
  -- SQL 2005 specific
  -- Run the install/fix when a database is created so that it is set to trustworthy
  -- and owner SID is corrected etc
  if @EventType = ''CREATE_DATABASE''
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
-- SQL 2005 specific
--
-- Need trustworthy databases for EXECUTE AS across databases.
-- This is used by trigger DatabaseAudit_i triggered by DatabaseAuditTrigger
--
exec sp_MSForEachDb
''
  declare @sql varchar(500)

  if ''''?'''' not in (''''tempdb'''', ''''model'''')
  begin
    select @sql = ''''alter database [?] set trustworthy on''''
    from   sys.databases
    where  name = ''''?''''
    and    is_trustworthy_on = 0

    if @@rowcount = 1
    begin
      print @sql
      exec(@sql)
    end 
    else print ''''Database [?] is already trustworthy''''
  end
  else print ''''Database [?] CANNOT be trustworthy''''
''


--
-- SQL 2005 specific
--
-- Make sure that the database owner SID is OK otherwise it is not possible to 
-- use EXECUTE AS across databases. Owner SID has been known to be wrong.
-- Set the DB owner to the standard SQL service account or sa.
--
exec sp_MSForEachDb
''
  use [?]

  declare @dbo sysname
  declare @sql varchar(256)

  -- Get the current dbo for [?] database
  select  @dbo = suser_sname(sdb.owner_sid)
  from    sys.databases sdb where sdb.name = ''''?''''

  print ''''Current dbo for [?] is '''' + @dbo

  -- Has dbo NOT already been switched/set to sa?
  if @dbo != ''''sa''''
  begin
    print ''''alter authorization on database::[?] to [sa]''''
    alter authorization on database::[?] to [sa]

    -- Need this account to still exist as a user
    set @sql = ''''create user ['''' + @dbo + ''''] for login ['''' + @dbo + '''']''''
    print @sql
    exec(@sql)

    set @sql = ''''grant connect on database::[?] to ['''' + @dbo + '''']''''
    print @sql
    exec(@sql)

    -- Put it back as a db_owner as before alter authorization
    print ''''exec sp_addrolemember db_owner, '''' + @dbo
    exec sp_addrolemember ''''db_owner'''', @dbo
  end
  else begin
    print ''''Skip alter authorization on database::[?] to [sa]''''
  end
''


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

    -- Avoid problem with access to dbadata.dbo.ServerAudit via exec
    exec(''''
		    create trigger [dbo].[DatabaseAudit_i] on [dbo].[DatabaseAudit]
		    for insert
		    as
		    begin
		      set nocount on

		      declare @is_trustworthy_on bit

		      select @is_trustworthy_on = is_trustworthy_on from sys.databases where name = db_name()

		      if @is_trustworthy_on = 1
		      begin
          insert  dbadata.dbo.ServerAudit
          (
          AuditDate, LoginName, EventType, ServerName, DatabaseName, SchemaName, ObjectName, TSQLCommand, XMLEventData
          )
          select AuditDate, LoginName, EventType, @@ServerName, db_name(), SchemaName, ObjectName, TSQLCommand, XMLEventData
          from    inserted ins
		      end
		      else begin
          print ''''''''[Information] - Trigger [?].[DatabaseAudit].[DatabaseAudit_i] skipped insert into dbadata.dbo.ServerAudit because database ['''''''' + db_name() + ''''''''] is not trustworthy''''''''
		      end
		    end
    '''')
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
  -- SQL 2005 DDL Auditing Solution
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
		@active_end_time=235959/*, 
		@schedule_uid=N'2036f7c0-009c-46ed-8e90-533351df29cd'*/
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
