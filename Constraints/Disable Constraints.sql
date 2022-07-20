<<<<<<< HEAD
-- Disable all table constraints
ALTER TABLE YourTableName NOCHECK CONSTRAINT ALL
-- Enable all table constraints
ALTER TABLE YourTableName CHECK CONSTRAINT ALL

-- ----------

-- Disable single constraint
ALTER TABLE YourTableName NOCHECK CONSTRAINT YourConstraint
-- Enable single constraint
ALTER TABLE YourTableName CHECK CONSTRAINT YourConstraint

-- ----------

-- Disable all constraints for database
EXEC sp_msforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT all"
-- Enable all constraints for database
EXEC sp_msforeachtable "ALTER TABLE ? WITH CHECK CHECK CONSTRAINT all"


-- Disable all constraints referencing a table
DECLARE @sql NVARCHAR(MAX) = N'';

;WITH x AS 
(
  SELECT DISTINCT obj = 
      QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.' 
    + QUOTENAME(OBJECT_NAME(parent_object_id)) 
  FROM sys.foreign_keys
  where OBJECT_NAME(referenced_object_id) = 'tb_evento'
)
SELECT @sql += N'ALTER TABLE ' + obj + ' NOCHECK CONSTRAINT ALL;
' FROM x;

EXEC sp_executesql @sql;


-- Enable all constraints referencing a table with validation
DECLARE @sql NVARCHAR(MAX) = N'';

;WITH x AS 
(
  SELECT DISTINCT obj = 
      QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.' 
    + QUOTENAME(OBJECT_NAME(parent_object_id)) 
  FROM sys.foreign_keys
  where OBJECT_NAME(referenced_object_id) = 'tb_evento'
)
SELECT @sql += N'ALTER TABLE ' + obj + ' WITH CHECK CHECK CONSTRAINT ALL;
' FROM x;

EXEC sp_executesql @sql;


-- Enable all constraints referencing a table without validation
DECLARE @sql NVARCHAR(MAX) = N'';

;WITH x AS 
(
  SELECT DISTINCT obj = 
      QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.' 
    + QUOTENAME(OBJECT_NAME(parent_object_id)) 
  FROM sys.foreign_keys
  where OBJECT_NAME(referenced_object_id) = 'tb_evento'
)
SELECT @sql += N'ALTER TABLE ' + obj + ' CHECK CONSTRAINT ALL;
' FROM x;

=======
-- Disable all table constraints
ALTER TABLE YourTableName NOCHECK CONSTRAINT ALL
-- Enable all table constraints
ALTER TABLE YourTableName CHECK CONSTRAINT ALL

-- ----------

-- Disable single constraint
ALTER TABLE YourTableName NOCHECK CONSTRAINT YourConstraint
-- Enable single constraint
ALTER TABLE YourTableName CHECK CONSTRAINT YourConstraint

-- ----------

-- Disable all constraints for database
EXEC sp_msforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT all"
-- Enable all constraints for database
EXEC sp_msforeachtable "ALTER TABLE ? WITH CHECK CHECK CONSTRAINT all"


-- Disable all constraints referencing a table
DECLARE @sql NVARCHAR(MAX) = N'';

;WITH x AS 
(
  SELECT DISTINCT obj = 
      QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.' 
    + QUOTENAME(OBJECT_NAME(parent_object_id)) 
  FROM sys.foreign_keys
  where OBJECT_NAME(referenced_object_id) = 'tb_evento'
)
SELECT @sql += N'ALTER TABLE ' + obj + ' NOCHECK CONSTRAINT ALL;
' FROM x;

EXEC sp_executesql @sql;


-- Enable all constraints referencing a table with validation
DECLARE @sql NVARCHAR(MAX) = N'';

;WITH x AS 
(
  SELECT DISTINCT obj = 
      QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.' 
    + QUOTENAME(OBJECT_NAME(parent_object_id)) 
  FROM sys.foreign_keys
  where OBJECT_NAME(referenced_object_id) = 'tb_evento'
)
SELECT @sql += N'ALTER TABLE ' + obj + ' WITH CHECK CHECK CONSTRAINT ALL;
' FROM x;

EXEC sp_executesql @sql;


-- Enable all constraints referencing a table without validation
DECLARE @sql NVARCHAR(MAX) = N'';

;WITH x AS 
(
  SELECT DISTINCT obj = 
      QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.' 
    + QUOTENAME(OBJECT_NAME(parent_object_id)) 
  FROM sys.foreign_keys
  where OBJECT_NAME(referenced_object_id) = 'tb_evento'
)
SELECT @sql += N'ALTER TABLE ' + obj + ' CHECK CONSTRAINT ALL;
' FROM x;

>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
EXEC sp_executesql @sql;