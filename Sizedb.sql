use master
go
	
create table #sizedb (SERVIDOR varchar (30),
					  BANCO varchar (100),
					  TAMANHO int,
					  DATA DATEtime)
insert into #sizedb	
	select  convert (varchar(10),SERVERPROPERTY  ('MachineName')) host,
		    db_name(dbid) banco,	
        str(convert(dec(15),sum(size))* 8192/ 1048576,10),
        GETDATE() data
from sysaltfiles 
	where dbid not in (select dbid from sysdatabases where name in ('master','tempdb','model','msdb'))
	and	db_name(dbid) is not null
	group by dbid 

select * from #sizedb
