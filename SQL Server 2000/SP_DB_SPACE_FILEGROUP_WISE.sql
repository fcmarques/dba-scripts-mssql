/*Version 1.0
Created by Chetan Jain
*/


CREATE PROCEDURE SP_DB_SPACE_FILEGROUP_WISE(@database varchar(100)=null, @threshold integer=null)
as 
set nocount on 
if (select object_id('tempdb..#FinalResults') ) is not null
	drop table #FinalResults
create table #FinalResults(
ServerName sysname Default(@@servername),
FileType varchar(4) NOT NULL, 
[Name] sysname NOT NULL, 
Filegroup1 varchar(100) not null,
Total numeric(9,2) NOT NULL, 
Used numeric(9,2) NOT NULL, 
[Free] numeric(9,2) NOT NULL, 
PctFreeSpc numeric(9,2) , 
dbname sysname NULL ,
RunDate Datetime Default(Getdate()) ) 


create table #DataFiles( 
Fileid int NOT NULL, 
[FileGroup] varchar(100) NOT NULL, 
TotalExtents int NOT NULL, 
UsedExtents int NOT NULL, 
[Name] sysname NOT NULL, 
[FileName] varchar(300) NOT NULL

) 
create table #LogFiles(
dbname sysname NOT NULL, 
LogSize numeric(15,7) NOT NULL, 
LogUsed numeric(9,5) NOT NULL, 
Status int NOT NULL

) 
BEGIN 
declare @StrSql varchar(500) 
declare @dbname varchar(128) 

/* Get data file(s) size */ 
if @database is not null
begin
	declare DataFileCur cursor local fast_forward 
	for 
	select name 
	from master..sysdatabases where name = @database
end
else
begin 
	declare DataFileCur cursor local fast_forward 
	for 
	select name 
	from master..sysdatabases 
	
end
open DataFileCur 
fetch next from DataFileCur into @dbname 
while @@fetch_status=0 
begin 
set @StrSql = 'use ' + @dbname + ' DBCC showfilestats' 
insert #DataFiles 
exec(@StrSql) 
set @strsql = 'use ' + @dbname + ' update #DataFiles set #datafiles.Filegroup = sysfilegroups.groupname from #datafiles , sysfilegroups where #datafiles.Filegroup = cast(sysfilegroups.groupid as varchar(100))'
exec(@strSql)

insert #FinalResults(FileType,[Name],Filegroup1,Total,Used,[Free],PctFreeSpc,dbname) 
select 'Data', 
left(right([FileName],charindex('\',reverse([FileName]))-1),  charindex('.',right([FileName],  charindex('\',reverse([FileName]))-1))-1), 
Filegroup,
CAST(((TotalExtents*64)/1024.00) as numeric(9,2)), 
CAST(((UsedExtents*64)/1024.00) as numeric(9,2)), 
(CAST(((TotalExtents*64)/1024.00) as numeric(9,2)) -CAST(((UsedExtents*64)/1024.00) as numeric(9,2))) , 
convert(decimal(15,2),100.0 * round( totalextents*64.0/1024.0 - usedextents*64.0/1024.0 ,0) /(totalextents*64.0/1024.0)) ,
@dbname 
from #DataFiles
delete #DataFiles 
fetch next from DataFileCur into @dbname 
end 
close DataFileCur 
deallocate DataFileCur 

/* Get log file(s) size */ 
insert #LogFiles exec('dbcc sqlperf(logspace)') 


declare @LogSql Varchar(8000)
declare @dbname1 varchar(128) ,@dbid1 int

if @database is not null
begin
declare LogFileCur cursor local fast_forward 
for 
select name,dbid
from master..sysdatabases where name = @database
end
else
begin
declare LogFileCur cursor local fast_forward 
for 
select name,dbid
from master..sysdatabases
end
open LogFileCur 
fetch next from LogFileCur into @dbname1,@dbid1
while @@fetch_status=0 
begin 
SET @LogSql ='USE '+ @dbname1 + CHAR(13) + ' insert #FinalResults(FileType,[Name],Filegroup1,Total,Used,[Free],PctFreeSpc,dbname) select ''Log'',s.[name],''Transaction Log'',s.Size/128. as LogSize , 
FILEPROPERTY(s.name,''spaceused'')/8.00 /16.00 As LogUsedSpace,(s.Size/128. - FILEPROPERTY(s.name,''spaceused'')/8.00 /16.00) , 
convert(decimal(15,2),100.0 * (s.Size/128. - FILEPROPERTY(s.name,''spaceused'')/8.00 /16.00) / (s.Size/128. ) ),'''+ @dbname1 +''' 
from #LogFiles l , master.dbo.sysaltfiles f ,' + @dbname1+'.dbo.sysfiles s 
where f.dbid='+ convert(Varchar(2), @dbid1) + 'and (s.status & 0x40) <> 0 and s.fileid=f.fileid and l.dbname ='''+ @dbname1+''''
Exec(@LogSql)
fetch next from LogFileCur into @dbname1 ,@dbid1
end

if exists
(select ServerName,dbname,Filegroup1 --,sum(total) as Total ,sum(used) As Used,sum(free) as free , (sum(total)-sum(used))/sum(total)*100 as FreePct
from #FinalResults 
group by ServerName,dbname,Filegroup1
having (sum(total)-sum(used))/sum(total)*100 <= isnull(@threshold,10)
--order by ServerName,dbname,Filegroup1 
)

select --ltrim(rtrim(ServerName)),
'Free Space Below '+ cast(isnull(@threshold,10) as varchar(10) ) + ' percent for DB ' + ltrim(rtrim(isnull(dbname,'') )) + '-Filegroup:' + ltrim(rtrim(Filegroup1)) + ',PctFree:' + cast (  convert( decimal(5,2),  (sum(total)-sum(used)) / sum(total)*100 ) 
as varchar(100)  )--,sum(total) as Total ,sum(used) As Used,sum(free) as free , (sum(total)-sum(used))/sum(total)*100 as FreePct
from #FinalResults 
group by ServerName,dbname,Filegroup1
having (sum(total)-sum(used))/sum(total)*100 <= isnull(@threshold,10)
order by ServerName,dbname,Filegroup1

drop table #DataFiles 
drop table #LogFiles 
drop table #FinalResults
return 
end 