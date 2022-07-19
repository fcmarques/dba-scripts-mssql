--
-- SQL 2008 DDL Auditing Solution
--
-- Check existence of triggers and list enabled/disabled state for all SQL 2008 DDL audit triggers
--
-- Sean Elliott
-- sean_p_elliott@yahoo.co.uk
--
-- July 2010
--

if exists (select * from master.sys.server_triggers where parent_class_desc = 'SERVER' and name = N'ServerAuditTrigger')
  print 'ServerAuditTrigger does exist'
else
  print '*** ServerAuditTrigger does not exist ***'

exec sp_MSForEachDB
'
  use [?];
  if ''?'' != ''tempdb''
  begin
    if exists (select * from sys.triggers where parent_class_desc = ''DATABASE'' and name = N''DatabaseAuditTrigger'')
      print ''? DatabaseAuditTrigger does exist''
    else
      print ''*** ? DatabaseAuditTrigger does NOT exist ***''
  end
'
go


select name, is_disabled from sys.server_triggers where name = 'ServerAuditTrigger'
go

exec sp_MSForEachDB
'
  use [?];
  if ''?'' != ''tempdb''
  begin
    select ''?'' [Database], name, is_disabled
    from sys.triggers
    where name in (''DatabaseAuditTrigger'', ''DatabaseAudit_i'')
  end
'
go
