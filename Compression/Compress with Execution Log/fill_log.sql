<<<<<<< HEAD
SELECT 
	  name AS ObjectName, 
	  OBJECT_SCHEMA_NAME(object_id) AS SchemaName,
	  OBJECT_NAME(object_id) as TableName,
	  'INDEX' as ObjectType,
      'ALTER INDEX ' + QUOTENAME(name)
      + ' ON '
      + QUOTENAME(OBJECT_SCHEMA_NAME(object_id))
      + '.'
      + QUOTENAME(OBJECT_NAME(object_id))
      + ' REBUILD PARTITION = ALL WITH (FILLFACTOR = 90, DATA_COMPRESSION = PAGE);' AS Command,
	  '' AS StartTime,
	  '' AS EndTime
	  into dbdba.dbo.log_compress_indexes
FROM sys.indexes
WHERE OBJECTPROPERTY(object_id, 'IsMSShipped') = 0
AND OBJECTPROPERTY(object_id, 'IsTable') = 1
ORDER BY CASE type_desc
      WHEN 'CLUSTERED' THEN 1
      ELSE 2
END

SELECT
	  name AS ObjectName, 
	  OBJECT_SCHEMA_NAME(id) AS SchemaName,
	  OBJECT_NAME(id) as TableName,
	  'TABLE' as ObjectType,      'ALTER TABLE ' + name
      + ' REBUILD WITH (DATA_COMPRESSION = PAGE);' AS Command,
	  '' AS StartTime,
	  '' AS EndTime
	  into dbdba.dbo.log_compress_tables
FROM sysobjects
WHERE xtype = 'U'


SELECT
      st.name,
      sp.data_compression,
      sp.data_compression_desc
FROM sys.partitions sp
INNER JOIN sys.tables st
      ON st.object_id = sp.object_id
=======
SELECT 
	  name AS ObjectName, 
	  OBJECT_SCHEMA_NAME(object_id) AS SchemaName,
	  OBJECT_NAME(object_id) as TableName,
	  'INDEX' as ObjectType,
      'ALTER INDEX ' + QUOTENAME(name)
      + ' ON '
      + QUOTENAME(OBJECT_SCHEMA_NAME(object_id))
      + '.'
      + QUOTENAME(OBJECT_NAME(object_id))
      + ' REBUILD PARTITION = ALL WITH (FILLFACTOR = 90, DATA_COMPRESSION = PAGE);' AS Command,
	  '' AS StartTime,
	  '' AS EndTime
	  into dbdba.dbo.log_compress_indexes
FROM sys.indexes
WHERE OBJECTPROPERTY(object_id, 'IsMSShipped') = 0
AND OBJECTPROPERTY(object_id, 'IsTable') = 1
ORDER BY CASE type_desc
      WHEN 'CLUSTERED' THEN 1
      ELSE 2
END

SELECT
	  name AS ObjectName, 
	  OBJECT_SCHEMA_NAME(id) AS SchemaName,
	  OBJECT_NAME(id) as TableName,
	  'TABLE' as ObjectType,      'ALTER TABLE ' + name
      + ' REBUILD WITH (DATA_COMPRESSION = PAGE);' AS Command,
	  '' AS StartTime,
	  '' AS EndTime
	  into dbdba.dbo.log_compress_tables
FROM sysobjects
WHERE xtype = 'U'


SELECT
      st.name,
      sp.data_compression,
      sp.data_compression_desc
FROM sys.partitions sp
INNER JOIN sys.tables st
      ON st.object_id = sp.object_id
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
WHERE data_compression = 0