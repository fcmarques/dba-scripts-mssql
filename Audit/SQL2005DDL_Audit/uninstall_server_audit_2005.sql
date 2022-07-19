--
-- Uninstall SQL 2005 server and database DDL auditing from whole server.
-- This will delete all the database level audit tables but not the server level.
--
-- ** Server level audit table must be explicitly deleted manually if required **
--
-- Sean Elliott
-- June 2010
--

-- Drop the jobs
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

-- Drop the server level trigger
if  exists (select * from master.sys.server_triggers where parent_class_desc = 'SERVER' and name = N'ServerAuditTrigger')
begin
  print 'Disable and drop trigger ServerAuditTrigger on all server';
  disable trigger ServerAuditTrigger on all server;
  drop trigger ServerAuditTrigger on all server;
end
else begin
  print 'Skip disable and drop trigger ServerAuditTrigger on all server';
end
go

-- Drop the database level triggers for all databases
exec sp_MSForEachDB
'
  use [?];
  if  exists (select * from sys.triggers where parent_class_desc = ''DATABASE'' AND name = N''DatabaseAuditTrigger'')
  begin
    print ''[?] - disable and drop trigger DatabaseAuditTrigger on database'';
    disable trigger DatabaseAuditTrigger on database;
    drop trigger DatabaseAuditTrigger on database;
  end
  else begin
    print ''[?] - Skip disable and drop trigger DatabaseAuditTrigger on database'';
  end
  if exists (select * from sys.objects where object_id = object_id(''[dbo].[DatabaseAudit]'') and type in (''U''))
  begin
    print ''[?] - drop table [?].[dbo].[DatabaseAudit]'';
    drop table [?].[dbo].[DatabaseAudit];
  end
  else begin
    print ''[?] - Skip drop table [?].[dbo].[DatabaseAudit]'';
  end
'
go

-- Drop the login used to write to the audit trails
if exists (select * from sys.server_principals where name = N'server_audit')
begin
  print 'drop login [server_audit]'
  drop login [server_audit]
end
else begin
  print 'Skip drop login [server_audit]'
end

-- Drop all the database users used to write to the DB level audit trail   
exec sp_MSForEachDB
'
  use [?];
  if exists (select * from sys.database_principals where name = N''server_audit'')
  begin
    print ''[?] - drop user [server_audit]'';
    drop user [server_audit];
  end
  else begin
    print ''[?] - Skip drop user [server_audit]'';
  end
'
go

-- No need for trustworthy datdabases now
exec sp_MSForEachDb
'
 	if ''?'' not in (''tempdb'', ''model'')
	 begin
	   print ''alter database [?] set trustworthy off'';
	   exec(''alter database [?] set trustworthy off'')
	end
	else
   print ''Skip alter database [?] set trustworthy off'';
'
go
