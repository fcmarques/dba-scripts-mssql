declare @DbName varchar(50), @DbId int
set rowcount 0
select dbid, name into #databases from sysdatabases
set rowcount 1
select @DbId = dbid, @DbName = name from #databases
while @@rowcount <> 0
begin

    set rowcount 0
    select * from #databases where dbid = @DbId
    delete #databases where dbid = @DbId

	print @DbName
	select @DbName = name from #databases

    set rowcount 1
    select @DbId = dbid from #databases

end
set rowcount 0
--drop table #databases


--select * from sysdatabases