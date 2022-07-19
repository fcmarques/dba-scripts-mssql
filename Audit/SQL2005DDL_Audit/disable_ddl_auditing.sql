--
-- SQL 2005 DDL Auditing Solution
--
-- Disable all SQL 2005 DDL audit triggers
--
-- Sean Elliott
-- sean_p_elliott@yahoo.co.uk
--
-- July 2010
--

exec sp_MSForEachDB
'
  use [?];
  if ''?'' != ''tempdb''
  begin
    print ''disable ? DatabaseAuditTrigger, DatabaseAudit_i'';
    disable trigger DatabaseAuditTrigger on database;
    disable trigger dbo.DatabaseAudit_i on DatabaseAudit;
  end
'
go

disable trigger ServerAuditTrigger on all server
go

