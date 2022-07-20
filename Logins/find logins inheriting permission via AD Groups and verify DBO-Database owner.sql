set nocount on
go
Create table #TmpTableSec1 (database_name varchar(100), Owner varchar(100))
Create table #TmpTableSec2 (database_name varchar(100), principal varchar(50), DBO_Owner_Login varchar(100))
Create table #TmpResult (database_name varchar(100), principal varchar(50), DBO_Owner_Login varchar(100))
DECLARE DBCURSOR CURSOR FOR
select name 
from sys.databases where state=0 and name not in ('tempdb','model','master','msdb')
Declare @name varchar(50)
Declare @cmd  varchar(200)
Declare @dbowner varchar(100)
OPEN DBCURSOR
FETCH NEXT FROM DBCURSOR INTO @name
WHILE @@FETCH_STATUS = 0
BEGIN
      --print 'Database --> ['+@name+']'
      set @cmd = 'select name,  suser_sname(owner_sid) from master.sys.databases where name = '''+@name+''''
      --select @cmd
      insert #TmpTableSec1 exec (@cmd)
      --select @dbowner = (select suser_sname(owner_sid) from master.sys.databases where name = @name)
      set @cmd = 'use '+ @name +'
      select db_name(), name, suser_sname(sid)
      from sys.database_principals where name = ''dbo'''
      --select ''@DBO'' = (select suser_sname(sid) from sys.database_principals where name = ''dbo'') '
      INSERT #TmpTableSec2 exec (@cmd) 
FETCH NEXT FROM DBCURSOR INTO @name
END
CLOSE DBCURSOR
DEALLOCATE DBCURSOR
--select * from #TmpTableSec1
--select * from #TmpTableSec2
insert into #TmpResult
select a.database_name, a.Owner, b.DBO_Owner_Login from #TmpTableSec1 a
join #TmpTableSec2 b
on a.database_name = b.database_name
--select * from #TmpResult

Create table #GroupMemberTable (account_name varchar(200), type varchar(50), privilege varchar(100), login_name varchar(200), group_name varchar(500))

DECLARE DBCURSOR2 CURSOR FOR
select distinct(DBO_Owner_Login)
from #TmpResult where DBO_Owner_Login like '%\%' and DBO_Owner_Login <> 'NT AUTHORITY\SYSTEM'
Declare @DBO varchar (200)
Declare @DBNAME varchar (200)
OPEN DBCURSOR2
FETCH NEXT FROM DBCURSOR2 INTO @DBO
WHILE @@FETCH_STATUS = 0
BEGIN
      set @cmd = 'EXEC xp_logininfo '''+@DBO+ ''', ''all'' '
      insert into #GroupMemberTable EXEC (@cmd)
      --update #GroupMemberTable set database_name = @DBNAME where id=@@IDENTITY 
      --print @cmd
FETCH NEXT FROM DBCURSOR2 INTO @DBO
END
CLOSE DBCURSOR2
DEALLOCATE DBCURSOR2
--select * from #TmpResult
--select * from #GroupMemberTable where group_name <> 'NULL' --and privilege = 'admin'

Create table #Tmp_DB_ownerRoleResults (database_name varchar(100), DBOwnerRole_Member_UserName varchar(200), User_type varchar(100))
DECLARE DBCURSOR3 CURSOR FOR
select database_name
from #TmpResult where DBO_Owner_Login <> 'NT AUTHORITY\SYSTEM'
Declare @database_name3 varchar (200)
Declare @cmd3  varchar(500)
OPEN DBCURSOR3
FETCH NEXT FROM DBCURSOR3 INTO @database_name3
WHILE @@FETCH_STATUS = 0
BEGIN
      set @cmd3 = 'use '+ @database_name3 +'
      select db_name(), user_name(member_principal_id), type_desc from sys.database_role_members a
      inner join sys.database_principals b
      on a.member_principal_id = b.principal_id where a.role_principal_id=16384'
      --print @cmd3
      --exec (@cmd3)
      insert into #Tmp_DB_ownerRoleResults exec (@cmd3)
FETCH NEXT FROM DBCURSOR3 INTO @database_name3
END
CLOSE DBCURSOR3
DEALLOCATE DBCURSOR3

print '###########################################################'
print '###### Database Owner and DBO Owner Logging Mapping #######'
print '###########################################################'
select * from #TmpResult


print '###########################################################################'
print '###### AD Group Member Logins which have DBO Access in the database #######'
print '###########################################################################'
create table #TmpTableSec3 (database_name varchar(100), Database_Owner varchar(200), DBO_Owner_Login varchar(200), type varchar (100), privilege varchar(100), group_name varchar(500))
insert into #TmpTableSec3
select a.database_name, a.principal, a.DBO_Owner_Login, b.type, b.privilege, b.group_name
from #TmpResult a
left join #GroupMemberTable b
on a.DBO_Owner_Login = b.login_name
where b.group_name is not null --and b.privilege = 'admin'
order by a.database_name
select database_name, DBO_Owner_Login, privilege, group_name  from #TmpTableSec3 
where privilege = 'admin' order by database_name asc

print '####################################################################################'
print '###### Members of DB_OWNER ROLE For Each Database (Excluding DBO Owner Login)#######'
print '####################################################################################'
Create table #TmpTableSec4 (database_name varchar(100), DBOwnerRole_Member_UserName varchar(200), User_type varchar(100))
insert into #TmpTableSec4
select a.database_name as [Database_Name], b.DBOwnerRole_Member_UserName, b.User_type 
from #TmpResult a
inner join #Tmp_DB_ownerRoleResults b
on a.database_name = b.database_name
where b.DBOwnerRole_Member_UserName <> 'dbo'

Create table #TmpTableSec5 (database_name varchar(100), DBOwnerRole_Member_UserName varchar(200), User_type varchar(100))
insert into #TmpTableSec5
select a.name as [Database_Name], b.DBOwnerRole_Member_UserName, b.User_type 
from sys.databases a
left outer join #TmpTableSec4 b
on a.name = b.database_name

select * from #TmpTableSec5
where DBOwnerRole_Member_UserName is not null
order by database_name

print''
print '#########################################################################################################################'
print '###### Final Result: Users who are not part of DB_OWNER Role nor having explicit login access but have DBO rights #######'
print '#########################################################################################################################'
print ''
create table #TmpFinalResult (group_name varchar(500), database_name varchar(100), DBO_Owner_Login varchar(200), Database_Owner varchar(200), privilege varchar(100))
insert into #TmpFinalResult
select distinct (a.group_name), a.database_name, a.DBO_Owner_Login, a.Database_Owner, a.privilege
from #TmpTableSec3 a
where a.database_name in (select database_name from #TmpResult where principal <> DBO_Owner_Login)
and a.group_name not in (select name from sys.syslogins where sysadmin = 1 and isntgroup = 1)
and a.DBO_Owner_Login not in (select name from sys.syslogins where sysadmin = 1 and isntuser = 1)
and a.DBO_Owner_Login not in (select DBO_Owner_Login from #TmpTableSec3 where privilege = 'admin')
--and a.group_name not in ('Any Domain Groups to be filtered goes here e.g. [DOMAIN\All Users]')
order by a.database_name asc
select a.database_name, a.DBO_Owner_Login, a.Database_Owner, a.group_name, a.privilege from #TmpFinalResult a
order by a.database_name asc

drop table #TmpTableSec1
drop table #TmpTableSec2
drop table #TmpTableSec3
drop table #TmpTableSec4
drop table #TmpTableSec5
drop table #TmpResult
drop table #GroupMemberTable
drop table #Tmp_DB_ownerRoleResults
drop table #TmpFinalResult
go
set nocount off
go