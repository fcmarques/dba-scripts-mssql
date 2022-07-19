--
-- SQL 2005 DDL Auditing Solution
--
-- Enable all SQL 2005 DDL audit triggers
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
    print ''enable ? DatabaseAuditTrigger, DatabaseAudit_i'';
    enable trigger DatabaseAuditTrigger on database;
    enable trigger dbo.DatabaseAudit_i on DatabaseAudit;
  end
'
go

enable trigger ServerAuditTrigger on all server
go

