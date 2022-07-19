--
-- SQL 2008 DDL Auditing Solution
--
-- Enable all SQL 2008 DDL audit triggers
--
-- Sean Elliott
-- sean_p_elliott@yahoo.co.uk
--
-- July 2010
--

-- Enable all SQL 2008 DDL audit triggers
exec sp_MSForEachDB
'
  use [?];
  if ''?'' != ''tempdb''
  begin
    print ''enable ? DatabaseAuditTrigger'';
    enable trigger DatabaseAuditTrigger on database;
  end
'
go

enable trigger ServerAuditTrigger on all server
go

