--Arquivos x filegroups
select a.groupid,b.data_space_id,a.name,a.filename, b.name, b.data_space_id
from sys.sysfiles as a join sys.filegroups as b on a.groupid=b.data_space_id


--gera script para efetuar o shrink
select 'DBCC SHRINKFILE (N'''+name+''', EMPTYFILE)' from sys.sysfiles where groupid not in (1,51,52)

--gera lista das tabelas x filegroups 
select t.name as table_name, p.rows, fg.name as filegroup_name, fg.is_default
from sys.partitions p join sys.tables t on p.object_id = t.object_id
    join sys.allocation_units au on au.container_id = p.partition_id join sys.filegroups fg on au.data_space_id = fg.data_space_id        
where p.index_id < 2
    and t.name <> 'sysdiagrams'        
	and  fg.name like 'fg%'
order by t.name

--alter
alter database <> remove file

--shrink
DBCC SHRINKFILE (N'file', EMPTYFILE)
