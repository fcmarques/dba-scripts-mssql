-- ListOwnersForAllObjects.sql
-- SQL Server 2000 and later.
SELECT
   NAME               AS Object,
   USER_NAME(uid)     AS Owner,
   CASE (xtype)
      WHEN 'AF' THEN 'Aggregate function (CLR)'
      WHEN 'C'  THEN 'CHECK constraint' 
      WHEN 'D'  THEN 'DEFAULT (constraint or stand-alone)'
      WHEN 'F'  THEN 'FOREIGN KEY constraint'
      WHEN 'PK' THEN 'PRIMARY KEY constraint'
      WHEN 'P'  THEN 'SQL stored procedure'
      WHEN 'PC' THEN 'Assembly (CLR) stored procedure'
      WHEN 'FN' THEN 'SQL scalar function'
      WHEN 'FS' THEN 'Assembly (CLR) scalar function'
      WHEN 'FT' THEN 'Assembly (CLR) table-valued function'
      WHEN 'R'  THEN 'Rule (old-style, stand-alone)'
      WHEN 'RF' THEN 'Replication-filter-procedure'
      WHEN 'S'  THEN 'System base table'
      WHEN 'SN' THEN 'Synonym'
      WHEN 'SQ' THEN 'Service queue'
      WHEN 'TA' THEN 'Assembly (CLR) DML trigger'
      WHEN 'TR' THEN 'SQL DML trigger '
      WHEN 'IF' THEN 'SQL inline table-valued function'
      WHEN 'TF' THEN 'SQL table-valued-function'
      WHEN 'U'  THEN 'Table (user-defined)'
      WHEN 'UQ' THEN 'UNIQUE constraint'
      WHEN 'V'  THEN 'View'
      WHEN 'X'  THEN 'Extended stored procedure'
      WHEN 'IT' THEN 'Internal table'
   END            AS 'Object Type'
  FROM sysobjects
 WHERE USER_NAME(uid) NOT IN ('sys', 'INFORMATION_SCHEMA')
 ORDER BY 'Object Type', Owner, Object