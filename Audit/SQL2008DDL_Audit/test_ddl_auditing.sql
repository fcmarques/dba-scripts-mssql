--
-- SQL 2008 DDL Auditing Solution
--
-- Stand up test for all database level auditing and server auditing
--
-- Sean Elliott
-- sean_p_elliott@yahoo.co.uk
--
-- July 2010
--

select * from dbadata..ServerAudit

exec sp_MSForEachDb 'if ''?'' != ''tempdb'' begin use ?;print ''?'';select * from DatabaseAudit end'


exec sp_MSForEachDB 'use [?]; print ''?''; create table aa_test_ddl_audit (col1 int)'
exec sp_MSForEachDB 'use [?]; print ''?''; drop table aa_test_ddl_audit'


