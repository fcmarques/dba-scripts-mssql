<<<<<<< HEAD
create table #temptable 
	(
	 dbname				nvarchar(128)
	,fileid				int
	,name				varchar(128)
	,filename			varchar(1024)
	,usage				varchar(30)
	,size				numeric(10,3)
    ,usedspace			numeric(10,3)
	,freespace			numeric(10,3)
	,growth			varchar(128)
	,maxsize			varchar(128)
	,perf				varchar(30)
	)


declare @databasename varchar(128)
declare @dbid	varchar(5)
declare @sql varchar(max)

declare dbname cursor for SELECT name, database_id FROM master.sys.databases where state_desc = 'ONLINE'
open dbname
	
	fetch next from dbname
	into @databasename,@dbid
	
	while @@fetch_status = 0
	begin

		select @sql  = 	' use  '+ quotename(@databasename) + '
			      		  insert into #temptable
					      select 
							  '''+@databasename+''' dbname, 
							  fileid, 
							  rtrim(name), 
							  rtrim(filename), 
							  case wheN (64 & status) = 64 then ''log'' else ''data'' end, 
							  round((size * 8192.0)/(1024.0 * 1024.0),2), 
							  convert(numeric(10,2), fileproperty(name,''spaceused'')/128.00), 
							  round(( size/128.0 - cast(fileproperty(name, ''spaceused'') as int)/128.0),2), 
							  case when status & 0x100000 = 0 then convert(varchar,ceiling((growth * 8192)/(1024.0*1024.0)))+'' mb''
							  else convert (varchar, growth)+'' %'' end, 
							  case maxsize when -1 then  ''unlimited'' else convert(varchar(20),
							  ceiling( ((maxsize * 8192.0)/(1024.0 * 1024.0))) ) end , 
							  perf [espaço reservado mb]
   		                 from ' + quotename(@databasename, N'[') + N'.dbo.sysfiles'
 		exec (@sql)
 
 	fetch next from dbname
	into @databasename,@dbid
end

select
	dbname [nome banco],
	name [nome lógico],
	filename [nome físico],
	usage [tipo],
	size [tamanho mb],
	usedspace [espaço usado mb],
	freespace [espaço livre mb],
	growth [crescimento (mb ou %)],
	maxsize [tamanho limite mb]
from
	#temptable	
	
drop table #temptable
close dbname
deallocate dbname

/*
select 
	left(filename,3) [nome físico],
	usage [tipo],
	count(*)
from
	#temptable	
where dbname not in ('master','model','msdb','tempdb')
group by left(filename,3), usage
=======
create table #temptable 
	(
	 dbname				nvarchar(128)
	,fileid				int
	,name				varchar(128)
	,filename			varchar(1024)
	,usage				varchar(30)
	,size				numeric(10,3)
    ,usedspace			numeric(10,3)
	,freespace			numeric(10,3)
	,growth			varchar(128)
	,maxsize			varchar(128)
	,perf				varchar(30)
	)


declare @databasename varchar(128)
declare @dbid	varchar(5)
declare @sql varchar(max)

declare dbname cursor for SELECT name, database_id FROM master.sys.databases where state_desc = 'ONLINE'
open dbname
	
	fetch next from dbname
	into @databasename,@dbid
	
	while @@fetch_status = 0
	begin

		select @sql  = 	' use  '+ quotename(@databasename) + '
			      		  insert into #temptable
					      select 
							  '''+@databasename+''' dbname, 
							  fileid, 
							  rtrim(name), 
							  rtrim(filename), 
							  case wheN (64 & status) = 64 then ''log'' else ''data'' end, 
							  round((size * 8192.0)/(1024.0 * 1024.0),2), 
							  convert(numeric(10,2), fileproperty(name,''spaceused'')/128.00), 
							  round(( size/128.0 - cast(fileproperty(name, ''spaceused'') as int)/128.0),2), 
							  case when status & 0x100000 = 0 then convert(varchar,ceiling((growth * 8192)/(1024.0*1024.0)))+'' mb''
							  else convert (varchar, growth)+'' %'' end, 
							  case maxsize when -1 then  ''unlimited'' else convert(varchar(20),
							  ceiling( ((maxsize * 8192.0)/(1024.0 * 1024.0))) ) end , 
							  perf [espaço reservado mb]
   		                 from ' + quotename(@databasename, N'[') + N'.dbo.sysfiles'
 		exec (@sql)
 
 	fetch next from dbname
	into @databasename,@dbid
end

select
	dbname [nome banco],
	name [nome lógico],
	filename [nome físico],
	usage [tipo],
	size [tamanho mb],
	usedspace [espaço usado mb],
	freespace [espaço livre mb],
	growth [crescimento (mb ou %)],
	maxsize [tamanho limite mb]
from
	#temptable	
	
drop table #temptable
close dbname
deallocate dbname

/*
select 
	left(filename,3) [nome físico],
	usage [tipo],
	count(*)
from
	#temptable	
where dbname not in ('master','model','msdb','tempdb')
group by left(filename,3), usage
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
*/