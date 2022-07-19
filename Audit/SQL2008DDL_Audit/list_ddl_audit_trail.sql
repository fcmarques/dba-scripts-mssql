--
-- SQL 2008 DDL Auditing Solution
--
-- Some TSQL snippets to list audit information
--
-- Sean Elliott
-- sean_p_elliott@yahoo.co.uk
--
-- July 2010
--

-- All server events
select * from dbadata..ServerAudit

-- All current database events
select * from DatabaseAudit

-- All database events
exec sp_MSForEachDb 'if ''?'' != ''tempdb'' begin use ?;print ''?'';select * from DatabaseAudit end'

