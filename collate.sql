
--1
select distinct 'ALTER TABLE ' + t.name + ' NOCHECK CONSTRAINT ALL' + CHAR(13) + CHAR(10) + 'GO' 
from (sys.columns c inner join sys.types ty on c.system_type_id = ty.system_type_id) inner join 
                (sys.objects t inner join sys.schemas s on t.schema_id = s.schema_id) on c.object_id = t.object_id 
where t.type='U' and c.collation_name is not null and ty.name <> 'sysname' and c.collation_name <> 'SQL_Latin1_General_CP850_CI_AI' 

--2
select 'alter table [' + s.name + '].[' + t.name + '] alter column [' + c.name + '] ' + 
                ty.name + case when ty.name not in ('text', 'sysname') then '(' + case when c.max_length > 0 then 
                case when ty.name not in ('nchar', 'nvarchar') then convert(varchar, c.max_length) else convert(varchar, c.max_length/2) end else 'max' end + 
                ')' else '' end + ' collate SQL_Latin1_General_CP850_CI_AI ' + 
                case when c.is_nullable = 0 then 'NOT ' else '' end + 'NULL' + CHAR(13) + CHAR(10) + 'GO'
from (sys.columns c inner join sys.types ty on c.system_type_id = ty.system_type_id) inner join 
                (sys.objects t inner join sys.schemas s on t.schema_id = s.schema_id) on c.object_id = t.object_id 
where t.type='U' and c.collation_name is not null and ty.name <> 'sysname' and c.collation_name <> 'SQL_Latin1_General_CP850_CI_AI' 
order by s.name, t.name, c.column_id

--3
select distinct 'ALTER TABLE ' + t.name + ' CHECK CONSTRAINT ALL' + CHAR(13) + CHAR(10) + 'GO' 
from (sys.columns c inner join sys.types ty on c.system_type_id = ty.system_type_id) inner join 
                (sys.objects t inner join sys.schemas s on t.schema_id = s.schema_id) on c.object_id = t.object_id 
where t.type='U' and c.collation_name is not null and ty.name <> 'sysname' and c.collation_name <> 'SQL_Latin1_General_CP850_CI_AI' 

--Opção mais complexa (gerar script de criação antes)
--DROP CONTRAINT
select 'ALTER TABLE ' + ctu.table_name + ' DROP CONSTRAINT ' + ctu.constraint_name + CHAR(13) + CHAR(10) + 'GO'
 from information_schema.constraint_table_usage ctu 
 where objectproperty(object_id(ctu.constraint_name), 'isforeignkey') = 1

