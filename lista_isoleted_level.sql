USE [master] 
go

declare  @databases varchar (200)
		,@sql varchar(200)
		,@banco varchar (100)
		,@hostname varchar (30)
		,@instance varchar (30)

set @hostname = convert (varchar(10),SERVERPROPERTY  ('MachineName'))
set @instance = convert (varchar(10),SERVERPROPERTY  ('InstanceName'))
	
create table #tmp (banco varchar (100))

create table #tmp2 (hostname varchar (30),
					instance varchar(30),
					banco varchar (100),
					tabela varchar (150),
					fill_factor int, 
					Allow_page_lock varchar (5),
					Allow_row_lock varchar(5))

BEGIN

insert into #tmp (banco) 
	select name from sys.databases where name not in ('distribution','master','model','msdb','tempdb')

DECLARE c1 CURSOR FOR  
	select banco from #tmp
		OPEN c1;  
		FETCH NEXT FROM c1 INTO @banco; 
		WHILE @@FETCH_STATUS = 0  
		BEGIN  
			set @sql='use '+@banco
			exec (@sql)
			insert into #tmp2 (tabela,fill_factor,Allow_row_lock,Allow_page_lock)
			 select b.name, fill_factor, allow_row_locks,allow_page_locks  
				from sys.indexes as a inner join sysobjects as b on(a.object_id = b.id)
				where allow_row_locks = 0 or allow_page_locks = 0
				update #tmp2 set banco=@banco, hostname=@hostname, instance=@instance where banco is null
		FETCH NEXT FROM c1 INTO @banco;  
		END;  

CLOSE c1;  
DEALLOCATE c1;
select * from #tmp2
drop table #tmp
drop table #tmp2
END

