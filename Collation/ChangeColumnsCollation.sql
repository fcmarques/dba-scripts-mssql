<<<<<<< HEAD
SELECT Object_name(c.object_id) AS tablename, 
       c.NAME                   AS columnname, 
       c.collation_name, 
       t.NAME                   'Data type', 
       CASE 
         WHEN t.NAME = 'nvarchar' THEN c.max_length / 2 
         ELSE c.max_length 
       END, 
       'ALTER TABLE ' + Object_name(c.object_id) 
       + ' ALTER COLUMN ' + QUOTENAME (c.NAME) + ' nvarchar(' + CASE WHEN t.NAME = 'nvarchar' THEN Cast(c.max_length / 2 AS VARCHAR) ELSE Cast(c.max_length AS VARCHAR) END
       + ') COLLATE DATABASE_DEFAULT;' 
FROM   sys.columns c 
       INNER JOIN sys.types t 
               ON c.user_type_id = t.user_type_id 
WHERE  c.collation_name IS NOT NULL 
       AND c.collation_name = 'SQL_Latin1_General_CP1_CI_AI'
   --    AND c.column_id not in (
			--select c.column_id from sys.columns c
			--join sys.sysdepends sd
			--	on c.object_id = sd.depid and c.column_id = sd.depnumber       
   --    )
ORDER  BY Object_name(c.object_id), 
=======
SELECT Object_name(c.object_id) AS tablename, 
       c.NAME                   AS columnname, 
       c.collation_name, 
       t.NAME                   'Data type', 
       CASE 
         WHEN t.NAME = 'nvarchar' THEN c.max_length / 2 
         ELSE c.max_length 
       END, 
       'ALTER TABLE ' + Object_name(c.object_id) 
       + ' ALTER COLUMN ' + QUOTENAME (c.NAME) + ' nvarchar(' + CASE WHEN t.NAME = 'nvarchar' THEN Cast(c.max_length / 2 AS VARCHAR) ELSE Cast(c.max_length AS VARCHAR) END
       + ') COLLATE DATABASE_DEFAULT;' 
FROM   sys.columns c 
       INNER JOIN sys.types t 
               ON c.user_type_id = t.user_type_id 
WHERE  c.collation_name IS NOT NULL 
       AND c.collation_name = 'SQL_Latin1_General_CP1_CI_AI'
   --    AND c.column_id not in (
			--select c.column_id from sys.columns c
			--join sys.sysdepends sd
			--	on c.object_id = sd.depid and c.column_id = sd.depnumber       
   --    )
ORDER  BY Object_name(c.object_id), 
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
          c.column_id 