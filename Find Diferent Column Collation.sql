SELECT t.name           AS TableName, 
       c.name           ColumnName, 
       ty.name          AS TypeName, 
       c.max_length     AS TypeLength, 
       c.collation_name AS CollationName,
       'ALTER TABLE ' + T.name + ' ALTER COLUMN ' + C.name + ' ' + TY.name + '(' + CAST(C.max_length AS VARCHAR) + ') COLLATE Latin1_General_CI_AS' AS ChangeScript
FROM   sys.all_columns c 
       JOIN sys.tables t 
         ON t.object_id = c.object_id 
       JOIN sys.types ty 
         ON ty.system_type_id = c.system_type_id 
WHERE  c.collation_name IS NOT NULL 
       AND c.collation_name <> 'Latin1_General_CI_AS' 
ORDER  BY t.name 

/*
Validação do processo

CREATE table xxxxxx(id int primary key, ds varchar(100), dt datetime)

ALTER TABLE xxxxxx ALTER COLUMN ds
varchar(100) COLLATE Latin1_General_CI_AI

ALTER TABLE xxxxxx ALTER COLUMN DS char(30) COLLATE Latin1_General_CI_AS

insert into xxxxxx
values(1,'teste', GETDATE());

insert into xxxxxx
values(2,'testé', GETDATE());

insert into xxxxxx
values(3,'testê', GETDATE());

select * from xxxxxx
where ds = 'teste'
*/