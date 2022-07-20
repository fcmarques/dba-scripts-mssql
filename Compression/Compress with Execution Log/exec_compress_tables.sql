<<<<<<< HEAD
/*
SELECT TOP (1000) [ObjectName]
      ,[SchemaName]
      ,[TableName]
      ,[ObjectType]
      ,[Command]
      ,[StartTime]
      ,[EndTime]
  FROM [DBDBA].[dbo].[log_compress_tables]

UPDATE [DBDBA].[dbo].[log_compress_tables] 
   SET [StartTime] = NULL;

UPDATE [DBDBA].[dbo].[log_compress_tables] 
   SET [EndTime] = NULL;

*/

-- tempo total de execução: 92:44:00 

SET NOCOUNT ON
GO

DECLARE @ObjectName VARCHAR(255), @SchemaNamee VARCHAR(255), @TableName VARCHAR(255), @Command NVARCHAR(2000)
 
DECLARE cursor1 CURSOR FOR
select [ObjectName]
      ,[SchemaName]
      ,[TableName]
      ,[Command]
  FROM [DBDBA].[dbo].[log_compress_tables]
 WHERE [EndTime] IS NULL
 
OPEN cursor1
 
FETCH NEXT FROM cursor1 INTO @ObjectName, @SchemaNamee , @TableName, @Command
 
WHILE @@FETCH_STATUS = 0
BEGIN
 
UPDATE [DBDBA].[dbo].[log_compress_tables] 
   SET [StartTime] = GETDATE()
 WHERE [ObjectName] = @ObjectName AND 
	   [SchemaName] = @SchemaNamee AND 
	   [TableName] = @TableName;
 
EXECUTE sp_executesql @Command;

UPDATE [DBDBA].[dbo].[log_compress_tables] 
   SET [EndTime] = GETDATE()
 WHERE [ObjectName] = @ObjectName AND
       [SchemaName] = @SchemaNamee AND
       [TableName] = @TableName;


FETCH NEXT FROM cursor1 INTO @ObjectName, @SchemaNamee , @TableName, @Command
END
 
CLOSE cursor1
 
DEALLOCATE cursor1

=======
/*
SELECT TOP (1000) [ObjectName]
      ,[SchemaName]
      ,[TableName]
      ,[ObjectType]
      ,[Command]
      ,[StartTime]
      ,[EndTime]
  FROM [DBDBA].[dbo].[log_compress_tables]

UPDATE [DBDBA].[dbo].[log_compress_tables] 
   SET [StartTime] = NULL;

UPDATE [DBDBA].[dbo].[log_compress_tables] 
   SET [EndTime] = NULL;

*/

-- tempo total de execução: 92:44:00 

SET NOCOUNT ON
GO

DECLARE @ObjectName VARCHAR(255), @SchemaNamee VARCHAR(255), @TableName VARCHAR(255), @Command NVARCHAR(2000)
 
DECLARE cursor1 CURSOR FOR
select [ObjectName]
      ,[SchemaName]
      ,[TableName]
      ,[Command]
  FROM [DBDBA].[dbo].[log_compress_tables]
 WHERE [EndTime] IS NULL
 
OPEN cursor1
 
FETCH NEXT FROM cursor1 INTO @ObjectName, @SchemaNamee , @TableName, @Command
 
WHILE @@FETCH_STATUS = 0
BEGIN
 
UPDATE [DBDBA].[dbo].[log_compress_tables] 
   SET [StartTime] = GETDATE()
 WHERE [ObjectName] = @ObjectName AND 
	   [SchemaName] = @SchemaNamee AND 
	   [TableName] = @TableName;
 
EXECUTE sp_executesql @Command;

UPDATE [DBDBA].[dbo].[log_compress_tables] 
   SET [EndTime] = GETDATE()
 WHERE [ObjectName] = @ObjectName AND
       [SchemaName] = @SchemaNamee AND
       [TableName] = @TableName;


FETCH NEXT FROM cursor1 INTO @ObjectName, @SchemaNamee , @TableName, @Command
END
 
CLOSE cursor1
 
DEALLOCATE cursor1

>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
