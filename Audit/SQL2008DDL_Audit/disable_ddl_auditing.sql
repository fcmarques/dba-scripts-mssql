--
-- SQL 2008 DDL Auditing Solution
--
-- Disable all SQL 2008 DDL audit triggers
--
-- Sean Elliott
-- sean_p_elliott@yahoo.co.uk
--
-- July 2010
--

-- Disable all SQL 2008 DDL audit triggers
exec sp_MSForEachDB
'
  use [?];
  if ''?'' != ''tempdb''
  begin
    print ''disable ? DatabaseAuditTrigger'';
    disable trigger DatabaseAuditTrigger on database;
  end
'
go

disable trigger ServerAuditTrigger on all server
go

