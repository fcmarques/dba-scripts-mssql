/*

SQL Server Maintenance Solution - SQL Server 2005, SQL Server 2008, SQL Server 2008 R2, and SQL Server 2012

Backup: http://ola.hallengren.com/sql-server-backup.html
Integrity Check: http://ola.hallengren.com/sql-server-integrity-check.html
Index and Statistics Maintenance: http://ola.hallengren.com/sql-server-index-and-statistics-maintenance.html

The solution is free: http://ola.hallengren.com/license.html

You can contact me by e-mail at ola@hallengren.com.

Last updated 20 May, 2012.

Ola Hallengren
http://ola.hallengren.com

*/

USE [master] -- Specify the database in which the objects will be created.

SET NOCOUNT ON

DECLARE @CreateJobs nvarchar(max)
DECLARE @BackupDirectory nvarchar(max)
DECLARE @OutputFileDirectory nvarchar(max)
DECLARE @LogToTable nvarchar(max)
DECLARE @Version numeric(18,10)
DECLARE @Error int

SET @CreateJobs          = 'Y'          -- Specify whether jobs should be created.
SET @BackupDirectory     = N'C:\Backup' -- Specify the backup root directory.
SET @OutputFileDirectory = NULL         -- Specify the output file directory. If no directory is specified, then the SQL Server error log directory is used.
SET @LogToTable          = 'Y'          -- Log commands to a table.

SET @Error = 0

SET @Version = CAST(LEFT(CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max)),CHARINDEX('.',CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max))) - 1) + '.' + REPLACE(RIGHT(CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max)), LEN(CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max))) - CHARINDEX('.',CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max)))),'.','') AS numeric(18,10))

IF IS_SRVROLEMEMBER('sysadmin') = 0
BEGIN
  RAISERROR('You need to be a member of the SysAdmin server role to install the solution.',16,1)
  SET @Error = @@ERROR
END

IF (SELECT [compatibility_level] FROM sys.databases WHERE database_id = DB_ID()) < 80
BEGIN
  RAISERROR('The database that you are creating the objects in has to be in compatibility level 80, 90, 100, or 110.',16,1)
  SET @Error = @@ERROR
END

IF OBJECT_ID('tempdb..#Config') IS NOT NULL DROP TABLE #Config

CREATE TABLE #Config ([Name] nvarchar(max),
                      [Value] nvarchar(max))

DECLARE @ErrorLog TABLE (LogDate datetime,
                         ProcessInfo nvarchar(max),
                         ErrorText nvarchar(max))

IF @CreateJobs = 'Y' AND @OutputFileDirectory IS NULL
BEGIN
  INSERT INTO @ErrorLog (LogDate, ProcessInfo, ErrorText)
  EXECUTE [master].dbo.sp_readerrorlog 0

  IF @@ERROR <> 0
  BEGIN
    RAISERROR('Error reading from the error log.',16,1)
    SET @Error = @@ERROR
  END

  SELECT @OutputFileDirectory = SUBSTRING(ErrorText,38,LEN(ErrorText) - 37 - CHARINDEX('\',REVERSE(ErrorText)))
  FROM @ErrorLog
  WHERE ErrorText LIKE 'Logging SQL Server messages in file%'

  IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
  BEGIN
    RAISERROR('The log directory could not be found.',16,1)
    SET @Error = @@ERROR
  END
END

INSERT INTO #Config ([Name], [Value])
VALUES('CreateJobs', @CreateJobs)

INSERT INTO #Config ([Name], [Value])
VALUES('BackupDirectory', @BackupDirectory)

INSERT INTO #Config ([Name], [Value])
VALUES('OutputFileDirectory', @OutputFileDirectory)

INSERT INTO #Config ([Name], [Value])
VALUES('LogToTable', @LogToTable)

INSERT INTO #Config ([Name], [Value])
VALUES('DatabaseName', DB_NAME(DB_ID()))

INSERT INTO #Config ([Name], [Value])
VALUES('Error', CAST(@Error AS nvarchar))

IF OBJECT_ID('[dbo].[DatabaseBackup]') IS NOT NULL DROP PROCEDURE [dbo].[DatabaseBackup]
IF OBJECT_ID('[dbo].[DatabaseIntegrityCheck]') IS NOT NULL DROP PROCEDURE [dbo].[DatabaseIntegrityCheck]
IF OBJECT_ID('[dbo].[IndexOptimize]') IS NOT NULL DROP PROCEDURE [dbo].[IndexOptimize]
IF OBJECT_ID('[dbo].[CommandExecute]') IS NOT NULL DROP PROCEDURE [dbo].[CommandExecute]
IF OBJECT_ID('[dbo].[DatabaseSelect]') IS NOT NULL DROP FUNCTION [dbo].[DatabaseSelect]

IF OBJECT_ID('[dbo].[CommandLog]') IS NULL AND OBJECT_ID('[dbo].[PK_CommandLog]') IS NULL
BEGIN
CREATE TABLE [dbo].[CommandLog](
[ID] int IDENTITY(1,1) NOT NULL CONSTRAINT [PK_CommandLog] PRIMARY KEY CLUSTERED,
[DatabaseName] sysname NULL,
[SchemaName] sysname NULL,
[ObjectName] sysname NULL,
[ObjectType] char(2) NULL,
[IndexName] sysname NULL,
[IndexType] tinyint NULL,
[StatisticsName] sysname NULL,
[PartitionNumber] int NULL,
[ExtendedInfo] xml NULL,
[Command] nvarchar(max) NOT NULL,
[CommandType] nvarchar(60) NOT NULL,
[StartTime] datetime NOT NULL,
[EndTime] datetime NULL,
[ErrorNumber] int NULL,
[ErrorMessage] nvarchar(max) NULL
)
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[DatabaseSelect] (@DatabaseList nvarchar(max))

RETURNS @Database TABLE (DatabaseName nvarchar(max) NOT NULL)

AS

BEGIN

  ----------------------------------------------------------------------------------------------------
  --// Source: http://ola.hallengren.com                                                          //--
  ----------------------------------------------------------------------------------------------------

  DECLARE @DatabaseItem nvarchar(max)
  DECLARE @Position int

  DECLARE @CurrentID int
  DECLARE @CurrentDatabaseName nvarchar(max)
  DECLARE @CurrentDatabaseStatus bit

  DECLARE @Database01 TABLE (DatabaseName nvarchar(max))

  DECLARE @Database02 TABLE (ID int IDENTITY PRIMARY KEY,
                             DatabaseName nvarchar(max),
                             DatabaseStatus bit,
                             Completed bit)

  DECLARE @Database03 TABLE (DatabaseName nvarchar(max),
                             DatabaseStatus bit)

  DECLARE @Sysdatabases TABLE (DatabaseName nvarchar(max))

  ----------------------------------------------------------------------------------------------------
  --// Split input string into elements                                                           //--
  ----------------------------------------------------------------------------------------------------

  WHILE CHARINDEX(', ',@DatabaseList) > 0 SET @DatabaseList = REPLACE(@DatabaseList,', ',',')
  WHILE CHARINDEX(' ,',@DatabaseList) > 0 SET @DatabaseList = REPLACE(@DatabaseList,' ,',',')
  WHILE CHARINDEX(',,',@DatabaseList) > 0 SET @DatabaseList = REPLACE(@DatabaseList,',,',',')

  IF RIGHT(@DatabaseList,1) = ',' SET @DatabaseList = LEFT(@DatabaseList,LEN(@DatabaseList) - 1)
  IF LEFT(@DatabaseList,1) = ','  SET @DatabaseList = RIGHT(@DatabaseList,LEN(@DatabaseList) - 1)

  SET @DatabaseList = LTRIM(RTRIM(@DatabaseList))

  WHILE LEN(@DatabaseList) > 0
  BEGIN
    SET @Position = CHARINDEX(',', @DatabaseList)
    IF @Position = 0
    BEGIN
      SET @DatabaseItem = @DatabaseList
      SET @DatabaseList = ''
    END
    ELSE
    BEGIN
      SET @DatabaseItem = LEFT(@DatabaseList, @Position - 1)
      SET @DatabaseList = RIGHT(@DatabaseList, LEN(@DatabaseList) - @Position)
    END
    IF @DatabaseItem <> '-' INSERT INTO @Database01 (DatabaseName) VALUES(@DatabaseItem)
  END

  ----------------------------------------------------------------------------------------------------
  --// Handle database exclusions                                                                 //--
  ----------------------------------------------------------------------------------------------------

  INSERT INTO @Database02 (DatabaseName, DatabaseStatus, Completed)
  SELECT DISTINCT DatabaseName = CASE WHEN DatabaseName LIKE '-%' THEN RIGHT(DatabaseName,LEN(DatabaseName) - 1) ELSE DatabaseName END,
                  DatabaseStatus = CASE WHEN DatabaseName LIKE '-%' THEN 0 ELSE 1 END,
                  0 AS Completed
  FROM @Database01

  ----------------------------------------------------------------------------------------------------
  --// Resolve elements                                                                           //--
  ----------------------------------------------------------------------------------------------------

  WHILE EXISTS (SELECT * FROM @Database02 WHERE Completed = 0)
  BEGIN

    SELECT TOP 1 @CurrentID = ID,
                 @CurrentDatabaseName = DatabaseName,
                 @CurrentDatabaseStatus = DatabaseStatus
    FROM @Database02
    WHERE Completed = 0
    ORDER BY ID ASC

    IF @CurrentDatabaseName = 'SYSTEM_DATABASES'
    BEGIN
      INSERT INTO @Database03 (DatabaseName, DatabaseStatus)
      SELECT [name], @CurrentDatabaseStatus
      FROM sys.databases
      WHERE [name] IN('master','model','msdb','tempdb')
    END
    ELSE IF @CurrentDatabaseName = 'USER_DATABASES'
    BEGIN
      INSERT INTO @Database03 (DatabaseName, DatabaseStatus)
      SELECT [name], @CurrentDatabaseStatus
      FROM sys.databases
      WHERE [name] NOT IN('master','model','msdb','tempdb')
    END
    ELSE IF @CurrentDatabaseName = 'ALL_DATABASES'
    BEGIN
      INSERT INTO @Database03 (DatabaseName, DatabaseStatus)
      SELECT [name], @CurrentDatabaseStatus
      FROM sys.databases
    END
    ELSE IF CHARINDEX('%',@CurrentDatabaseName) > 0
    BEGIN
      INSERT INTO @Database03 (DatabaseName, DatabaseStatus)
      SELECT [name], @CurrentDatabaseStatus
      FROM sys.databases
      WHERE [name] LIKE REPLACE(CASE WHEN LEFT(@CurrentDatabaseName,1) = '[' AND RIGHT(@CurrentDatabaseName,1) = ']' THEN PARSENAME(@CurrentDatabaseName,1) ELSE @CurrentDatabaseName END,'_','[_]')
    END
    ELSE
    BEGIN
      INSERT INTO @Database03 (DatabaseName, DatabaseStatus)
      SELECT [name], @CurrentDatabaseStatus
      FROM sys.databases
      WHERE [name] = CASE WHEN LEFT(@CurrentDatabaseName,1) = '[' AND RIGHT(@CurrentDatabaseName,1) = ']' THEN PARSENAME(@CurrentDatabaseName,1) ELSE @CurrentDatabaseName END
    END

    UPDATE @Database02
    SET Completed = 1
    WHERE ID = @CurrentID

    SET @CurrentID = NULL
    SET @CurrentDatabaseName = NULL
    SET @CurrentDatabaseStatus = NULL

  END

  ----------------------------------------------------------------------------------------------------
  --// Handle tempdb and database snapshots                                                       //--
  ----------------------------------------------------------------------------------------------------

  INSERT INTO @Sysdatabases (DatabaseName)
  SELECT [name]
  FROM sys.databases
  WHERE [name] <> 'tempdb'
  AND source_database_id IS NULL

  ----------------------------------------------------------------------------------------------------
  --// Return results                                                                             //--
  ----------------------------------------------------------------------------------------------------

  INSERT INTO @Database (DatabaseName)
  SELECT DatabaseName
  FROM @Sysdatabases
  INTERSECT
  SELECT DatabaseName
  FROM @Database03
  WHERE DatabaseStatus = 1
  EXCEPT
  SELECT DatabaseName
  FROM @Database03
  WHERE DatabaseStatus = 0

  RETURN

  ----------------------------------------------------------------------------------------------------

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CommandExecute]

@Command nvarchar(max),
@CommandType nvarchar(max),
@Mode int,
@Comment nvarchar(max) = NULL,
@DatabaseName nvarchar(max) = NULL,
@SchemaName nvarchar(max) = NULL,
@ObjectName nvarchar(max) = NULL,
@ObjectType nvarchar(max) = NULL,
@IndexName nvarchar(max) = NULL,
@IndexType int = NULL,
@StatisticsName nvarchar(max) = NULL,
@PartitionNumber int = NULL,
@ExtendedInfo xml = NULL,
@LogToTable nvarchar(max),
@Execute nvarchar(max)

AS

BEGIN

  ----------------------------------------------------------------------------------------------------
  --// Source: http://ola.hallengren.com                                                          //--
  ----------------------------------------------------------------------------------------------------

  SET NOCOUNT ON

  SET LOCK_TIMEOUT 3600000

  DECLARE @StartMessage nvarchar(max)
  DECLARE @EndMessage nvarchar(max)
  DECLARE @ErrorMessage nvarchar(max)
  DECLARE @ErrorMessageOriginal nvarchar(max)

  DECLARE @StartTime datetime
  DECLARE @EndTime datetime

  DECLARE @StartTimeSec datetime
  DECLARE @EndTimeSec datetime

  DECLARE @ID int

  DECLARE @Error int
  DECLARE @ReturnCode int

  SET @Error = 0
  SET @ReturnCode = 0

  ----------------------------------------------------------------------------------------------------
  --// Check core requirements                                                                    //--
  ----------------------------------------------------------------------------------------------------

  IF SERVERPROPERTY('EngineEdition') = 5
  BEGIN
    SET @ErrorMessage = 'SQL Azure is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @Error <> 0
  BEGIN
    SET @ReturnCode = @Error
    GOTO ReturnCode
  END

  IF @LogToTable = 'Y' AND NOT EXISTS (SELECT * FROM sys.objects objects INNER JOIN sys.schemas schemas ON objects.[schema_id] = schemas.[schema_id] WHERE objects.[type] = 'U' AND schemas.[name] = 'dbo' AND objects.[name] = 'CommandLog')
  BEGIN
    SET @ErrorMessage = 'The table CommandLog is missing. Download http://ola.hallengren.com/scripts/CommandLog.sql.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @Error <> 0
  BEGIN
    SET @ReturnCode = @Error
    GOTO ReturnCode
  END

  ----------------------------------------------------------------------------------------------------
  --// Check input parameters                                                                     //--
  ----------------------------------------------------------------------------------------------------

  IF @Command IS NULL OR @Command = ''
  BEGIN
    SET @ErrorMessage = 'The value for parameter @Command is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @CommandType IS NULL OR @CommandType = '' OR LEN(@CommandType) > 60
  BEGIN
    SET @ErrorMessage = 'The value for parameter @CommandType is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @Mode NOT IN(1,2) OR @Mode IS NULL
  BEGIN
    SET @ErrorMessage = 'The value for parameter @Mode is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @LogToTable NOT IN('Y','N') OR @LogToTable IS NULL
  BEGIN
    SET @ErrorMessage = 'The value for parameter @LogToTable is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @Execute NOT IN('Y','N') OR @Execute IS NULL
  BEGIN
    SET @ErrorMessage = 'The value for parameter @Execute is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @Error <> 0
  BEGIN
    SET @ReturnCode = @Error
    GOTO ReturnCode
  END

  ----------------------------------------------------------------------------------------------------
  --// Log initial information                                                                    //--
  ----------------------------------------------------------------------------------------------------

  SET @StartTime = GETDATE()
  SET @StartTimeSec = CONVERT(datetime,CONVERT(nvarchar,@StartTime,120),120)

  SET @StartMessage = 'DateTime: ' + CONVERT(nvarchar,@StartTimeSec,120) + CHAR(13) + CHAR(10)
  SET @StartMessage = @StartMessage + 'Command: ' + @Command
  IF @Comment IS NOT NULL SET @StartMessage = @StartMessage + CHAR(13) + CHAR(10) + 'Comment: ' + @Comment
  SET @StartMessage = REPLACE(@StartMessage,'%','%%')
  RAISERROR(@StartMessage,10,1) WITH NOWAIT

  IF @LogToTable = 'Y'
  BEGIN
    INSERT INTO dbo.CommandLog (DatabaseName, SchemaName, ObjectName, ObjectType, IndexName, IndexType, StatisticsName, PartitionNumber, ExtendedInfo, CommandType, Command, StartTime)
    VALUES (@DatabaseName, @SchemaName, @ObjectName, @ObjectType, @IndexName, @IndexType, @StatisticsName, @PartitionNumber, @ExtendedInfo, @CommandType, @Command, @StartTime)
  END

  SET @ID = SCOPE_IDENTITY()

  ----------------------------------------------------------------------------------------------------
  --// Execute command                                                                            //--
  ----------------------------------------------------------------------------------------------------

  IF @Mode = 1 AND @Execute = 'Y'
  BEGIN
    EXECUTE(@Command)
    SET @Error = @@ERROR
    SET @ReturnCode = @Error
  END

  IF @Mode = 2 AND @Execute = 'Y'
  BEGIN
    BEGIN TRY
      EXECUTE(@Command)
    END TRY
    BEGIN CATCH
      SET @Error = ERROR_NUMBER()
      SET @ReturnCode = @Error
      SET @ErrorMessageOriginal = ERROR_MESSAGE()
      SET @ErrorMessage = 'Msg ' + CAST(@Error AS nvarchar) + ', ' + ISNULL(@ErrorMessageOriginal,'')
      RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    END CATCH
  END

  ----------------------------------------------------------------------------------------------------
  --// Log completing information                                                                 //--
  ----------------------------------------------------------------------------------------------------

  SET @EndTime = GETDATE()
  SET @EndTimeSec = CONVERT(datetime,CONVERT(varchar,@EndTime,120),120)

  SET @EndMessage = 'Outcome: ' + CASE WHEN @Execute = 'N' THEN 'Not Executed' WHEN @Error = 0 THEN 'Succeeded' ELSE 'Failed' END + CHAR(13) + CHAR(10)
  SET @EndMessage = @EndMessage + 'Duration: ' + CASE WHEN DATEDIFF(ss,@StartTimeSec, @EndTimeSec)/(24*3600) > 0 THEN CAST(DATEDIFF(ss,@StartTimeSec, @EndTimeSec)/(24*3600) AS nvarchar) + '.' ELSE '' END + CONVERT(nvarchar,@EndTimeSec - @StartTimeSec,108) + CHAR(13) + CHAR(10)
  SET @EndMessage = @EndMessage + 'DateTime: ' + CONVERT(nvarchar,@EndTimeSec,120) + CHAR(13) + CHAR(10) + ' '
  SET @EndMessage = REPLACE(@EndMessage,'%','%%')
  RAISERROR(@EndMessage,10,1) WITH NOWAIT

  IF @LogToTable = 'Y'
  BEGIN
    UPDATE dbo.CommandLog
    SET EndTime = @EndTime,
        ErrorNumber = CASE WHEN @Execute = 'N' THEN NULL ELSE @Error END,
        ErrorMessage = @ErrorMessageOriginal
    WHERE ID = @ID
  END

  ReturnCode:
  IF @ReturnCode <> 0
  BEGIN
    RETURN @ReturnCode
  END

  ----------------------------------------------------------------------------------------------------

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DatabaseBackup]

@Databases nvarchar(max),
@Directory nvarchar(max) = NULL,
@BackupType nvarchar(max),
@Verify nvarchar(max) = 'N',
@CleanupTime int = NULL,
@Compress nvarchar(max) = NULL,
@CopyOnly nvarchar(max) = 'N',
@ChangeBackupType nvarchar(max) = 'N',
@BackupSoftware nvarchar(max) = NULL,
@CheckSum nvarchar(max) = 'N',
@BlockSize int = NULL,
@BufferCount int = NULL,
@MaxTransferSize int = NULL,
@NumberOfFiles int = 1,
@CompressionLevel int = NULL,
@Description nvarchar(max) = NULL,
@Threads int = NULL,
@Throttle int = NULL,
@Encrypt nvarchar(max) = 'N',
@EncryptionType nvarchar(max) = NULL,
@EncryptionKey nvarchar(max) = NULL,
@LogToTable nvarchar(max) = 'N',
@Execute nvarchar(max) = 'Y'

AS

BEGIN

  ----------------------------------------------------------------------------------------------------
  --// Source: http://ola.hallengren.com                                                          //--
  ----------------------------------------------------------------------------------------------------

  SET NOCOUNT ON

  DECLARE @StartMessage nvarchar(max)
  DECLARE @EndMessage nvarchar(max)
  DECLARE @DatabaseMessage nvarchar(max)
  DECLARE @ErrorMessage nvarchar(max)

  DECLARE @Version numeric(18,10)

  DECLARE @Cluster nvarchar(max)

  DECLARE @DefaultDirectory nvarchar(4000)
  DECLARE @CheckDirectory nvarchar(4000)

  DECLARE @CurrentID int
  DECLARE @CurrentDatabaseID int
  DECLARE @CurrentDatabaseName nvarchar(max)
  DECLARE @CurrentBackupType nvarchar(max)
  DECLARE @CurrentFileExtension nvarchar(max)
  DECLARE @CurrentFileNumber int
  DECLARE @CurrentDifferentialLSN numeric(25,0)
  DECLARE @CurrentLogLSN numeric(25,0)
  DECLARE @CurrentLatestBackup datetime
  DECLARE @CurrentDatabaseNameFS nvarchar(max)
  DECLARE @CurrentDirectory nvarchar(max)
  DECLARE @CurrentFilePath nvarchar(max)
  DECLARE @CurrentDate datetime
  DECLARE @CurrentCleanupDate datetime
  DECLARE @CurrentIsDatabaseAccessible bit
  DECLARE @CurrentAvailabilityGroup nvarchar(max)
  DECLARE @CurrentRole nvarchar(max)
  DECLARE @CurrentIsPreferredBackupReplica bit

  DECLARE @CurrentCommand01 nvarchar(max)
  DECLARE @CurrentCommand02 nvarchar(max)
  DECLARE @CurrentCommand03 nvarchar(max)
  DECLARE @CurrentCommand04 nvarchar(max)

  DECLARE @CurrentCommandOutput01 int
  DECLARE @CurrentCommandOutput02 int
  DECLARE @CurrentCommandOutput03 int
  DECLARE @CurrentCommandOutput04 int

  DECLARE @CurrentCommandType01 nvarchar(max)
  DECLARE @CurrentCommandType02 nvarchar(max)
  DECLARE @CurrentCommandType03 nvarchar(max)
  DECLARE @CurrentCommandType04 nvarchar(max)

  DECLARE @DirectoryInfo TABLE (FileExists bit,
                                FileIsADirectory bit,
                                ParentDirectoryExists bit)

  DECLARE @tmpDatabases TABLE (ID int IDENTITY PRIMARY KEY,
                               DatabaseName nvarchar(max),
                               Completed bit)

  DECLARE @CurrentFiles TABLE (CurrentFilePath nvarchar(max))

  DECLARE @Error int
  DECLARE @ReturnCode int

  SET @Error = 0
  SET @ReturnCode = 0

  SET @Version = CAST(LEFT(CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max)),CHARINDEX('.',CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max))) - 1) + '.' + REPLACE(RIGHT(CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max)), LEN(CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max))) - CHARINDEX('.',CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max)))),'.','') AS numeric(18,10))

  IF @Version >= 11
  BEGIN
    SELECT @Cluster = cluster_name
    FROM sys.dm_hadr_cluster
  END

  ----------------------------------------------------------------------------------------------------
  --// Log initial information                                                                    //--
  ----------------------------------------------------------------------------------------------------

  SET @StartMessage = 'DateTime: ' + CONVERT(nvarchar,GETDATE(),120) + CHAR(13) + CHAR(10)
  SET @StartMessage = @StartMessage + 'Server: ' + CAST(SERVERPROPERTY('ServerName') AS nvarchar) + CHAR(13) + CHAR(10)
  SET @StartMessage = @StartMessage + 'Version: ' + CAST(SERVERPROPERTY('ProductVersion') AS nvarchar) + CHAR(13) + CHAR(10)
  SET @StartMessage = @StartMessage + 'Edition: ' + CAST(SERVERPROPERTY('Edition') AS nvarchar) + CHAR(13) + CHAR(10)
  SET @StartMessage = @StartMessage + 'Procedure: ' + QUOTENAME(DB_NAME(DB_ID())) + '.' + (SELECT QUOTENAME(schemas.name) FROM sys.schemas schemas INNER JOIN sys.objects objects ON schemas.[schema_id] = objects.[schema_id] WHERE [object_id] = @@PROCID) + '.' + QUOTENAME(OBJECT_NAME(@@PROCID)) + CHAR(13) + CHAR(10)
  SET @StartMessage = @StartMessage + 'Parameters: @Databases = ' + ISNULL('''' + REPLACE(@Databases,'''','''''') + '''','NULL')
  SET @StartMessage = @StartMessage + ', @Directory = ' + ISNULL('''' + REPLACE(@Directory,'''','''''') + '''','NULL')
  SET @StartMessage = @StartMessage + ', @BackupType = ' + ISNULL('''' + REPLACE(@BackupType,'''','''''') + '''','NULL')
  SET @StartMessage = @StartMessage + ', @Verify = ' + ISNULL('''' + REPLACE(@Verify,'''','''''') + '''','NULL')
  SET @StartMessage = @StartMessage + ', @CleanupTime = ' + ISNULL(CAST(@CleanupTime AS nvarchar),'NULL')
  SET @StartMessage = @StartMessage + ', @Compress = ' + ISNULL('''' + REPLACE(@Compress,'''','''''') + '''','NULL')
  SET @StartMessage = @StartMessage + ', @CopyOnly = ' + ISNULL('''' + REPLACE(@CopyOnly,'''','''''') + '''','NULL')
  SET @StartMessage = @StartMessage + ', @ChangeBackupType = ' + ISNULL('''' + REPLACE(@ChangeBackupType,'''','''''') + '''','NULL')
  SET @StartMessage = @StartMessage + ', @BackupSoftware = ' + ISNULL('''' + REPLACE(@BackupSoftware,'''','''''') + '''','NULL')
  SET @StartMessage = @StartMessage + ', @CheckSum = ' + ISNULL('''' + REPLACE(@CheckSum,'''','''''') + '''','NULL')
  SET @StartMessage = @StartMessage + ', @BlockSize = ' + ISNULL(CAST(@BlockSize AS nvarchar),'NULL')
  SET @StartMessage = @StartMessage + ', @BufferCount = ' + ISNULL(CAST(@BufferCount AS nvarchar),'NULL')
  SET @StartMessage = @StartMessage + ', @MaxTransferSize = ' + ISNULL(CAST(@MaxTransferSize AS nvarchar),'NULL')
  SET @StartMessage = @StartMessage + ', @NumberOfFiles = ' + ISNULL(CAST(@NumberOfFiles AS nvarchar),'NULL')
  SET @StartMessage = @StartMessage + ', @CompressionLevel = ' + ISNULL(CAST(@CompressionLevel AS nvarchar),'NULL')
  SET @StartMessage = @StartMessage + ', @Description = ' + ISNULL('''' + REPLACE(@Description,'''','''''') + '''','NULL')
  SET @StartMessage = @StartMessage + ', @Threads = ' + ISNULL(CAST(@Threads AS nvarchar),'NULL')
  SET @StartMessage = @StartMessage + ', @Throttle = ' + ISNULL(CAST(@Throttle AS nvarchar),'NULL')
  SET @StartMessage = @StartMessage + ', @Encrypt = ' + ISNULL('''' + REPLACE(@Encrypt,'''','''''') + '''','NULL')
  SET @StartMessage = @StartMessage + ', @EncryptionType = ' + ISNULL('''' + REPLACE(@EncryptionType,'''','''''') + '''','NULL')
  SET @StartMessage = @StartMessage + ', @EncryptionKey = ' + ISNULL('''' + REPLACE(@EncryptionKey,'''','''''') + '''','NULL')
  SET @StartMessage = @StartMessage + ', @LogToTable = ' + ISNULL('''' + REPLACE(@LogToTable,'''','''''') + '''','NULL')
  SET @StartMessage = @StartMessage + ', @Execute = ' + ISNULL('''' + REPLACE(@Execute,'''','''''') + '''','NULL') + CHAR(13) + CHAR(10)
  SET @StartMessage = @StartMessage + 'Source: http://ola.hallengren.com' + CHAR(13) + CHAR(10)
  SET @StartMessage = REPLACE(@StartMessage,'%','%%') + ' '
  RAISERROR(@StartMessage,10,1) WITH NOWAIT

  ----------------------------------------------------------------------------------------------------
  --// Check core requirements                                                                    //--
  ----------------------------------------------------------------------------------------------------

  IF SERVERPROPERTY('EngineEdition') = 5
  BEGIN
    SET @ErrorMessage = 'SQL Azure is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @Error <> 0
  BEGIN
    SET @ReturnCode = @Error
    GOTO Logging
  END

  IF NOT EXISTS (SELECT * FROM sys.objects objects INNER JOIN sys.schemas schemas ON objects.[schema_id] = schemas.[schema_id] WHERE objects.[type] = 'P' AND schemas.[name] = 'dbo' AND objects.[name] = 'CommandExecute')
  BEGIN
    SET @ErrorMessage = 'The stored procedure CommandExecute is missing. Download http://ola.hallengren.com/scripts/CommandExecute.sql.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF EXISTS (SELECT * FROM sys.objects objects INNER JOIN sys.schemas schemas ON objects.[schema_id] = schemas.[schema_id] WHERE objects.[type] = 'P' AND schemas.[name] = 'dbo' AND objects.[name] = 'CommandExecute' AND OBJECT_DEFINITION(objects.[object_id]) NOT LIKE '%@LogToTable%')
  BEGIN
    SET @ErrorMessage = 'The stored procedure CommandExecute needs to be updated. Download http://ola.hallengren.com/scripts/CommandExecute.sql.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF NOT EXISTS (SELECT * FROM sys.objects objects INNER JOIN sys.schemas schemas ON objects.[schema_id] = schemas.[schema_id] WHERE objects.[type] = 'TF' AND schemas.[name] = 'dbo' AND objects.[name] = 'DatabaseSelect')
  BEGIN
    SET @ErrorMessage = 'The function DatabaseSelect is missing. Download http://ola.hallengren.com/scripts/DatabaseSelect.sql.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @LogToTable = 'Y' AND NOT EXISTS (SELECT * FROM sys.objects objects INNER JOIN sys.schemas schemas ON objects.[schema_id] = schemas.[schema_id] WHERE objects.[type] = 'U' AND schemas.[name] = 'dbo' AND objects.[name] = 'CommandLog')
  BEGIN
    SET @ErrorMessage = 'The table CommandLog is missing. Download http://ola.hallengren.com/scripts/CommandLog.sql.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @Error <> 0
  BEGIN
    SET @ReturnCode = @Error
    GOTO Logging
  END

  ----------------------------------------------------------------------------------------------------
  --// Select databases                                                                           //--
  ----------------------------------------------------------------------------------------------------

  IF @Databases IS NULL OR @Databases = ''
  BEGIN
    SET @ErrorMessage = 'The value for parameter @Databases is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  INSERT INTO @tmpDatabases (DatabaseName, Completed)
  SELECT DatabaseName AS DatabaseName,
         0 AS Completed
  FROM dbo.DatabaseSelect (@Databases)
  ORDER BY DatabaseName ASC

  IF @@ERROR <> 0
  BEGIN
    SET @ErrorMessage = 'Error selecting databases.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  SET @ErrorMessage = ''
  SELECT @ErrorMessage = @ErrorMessage + QUOTENAME(DatabaseName) + ', '
  FROM @tmpDatabases
  WHERE REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(DatabaseName,'\',''),'/',''),':',''),'*',''),'?',''),'"',''),'<',''),'>',''),'|',''),' ','') = ''
  ORDER BY DatabaseName ASC
  IF @@ROWCOUNT > 0
  BEGIN
    SET @ErrorMessage = 'The names of the following databases are not supported; ' + LEFT(@ErrorMessage,LEN(@ErrorMessage)-1) + '.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  SET @ErrorMessage = '';
  WITH tmpDatabasesCTE
  AS
  (
  SELECT name AS DatabaseName,
         UPPER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(name,'\',''),'/',''),':',''),'*',''),'?',''),'"',''),'<',''),'>',''),'|',''),' ','')) AS DatabaseNameFS
  FROM sys.databases
  )
  SELECT @ErrorMessage = @ErrorMessage + QUOTENAME(DatabaseName) + ', '
  FROM tmpDatabasesCTE
  WHERE DatabaseNameFS IN(SELECT DatabaseNameFS FROM tmpDatabasesCTE GROUP BY DatabaseNameFS HAVING COUNT(*) > 1)
  AND DatabaseNameFS IN(SELECT UPPER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(DatabaseName COLLATE DATABASE_DEFAULT,'\',''),'/',''),':',''),'*',''),'?',''),'"',''),'<',''),'>',''),'|',''),' ','')) FROM @tmpDatabases)
  AND DatabaseNameFS <> ''
  ORDER BY DatabaseNameFS ASC, DatabaseName ASC
  IF @@ROWCOUNT > 0
  BEGIN
    SET @ErrorMessage = 'The names of the following databases are not unique in the file system; ' + LEFT(@ErrorMessage,LEN(@ErrorMessage)-1) + '.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  ----------------------------------------------------------------------------------------------------
  --// Get default backup directory                                                               //--
  ----------------------------------------------------------------------------------------------------

  IF @Directory IS NULL
  BEGIN
    EXECUTE [master].dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer', N'BackupDirectory', @DefaultDirectory OUTPUT
    SET @Directory = @DefaultDirectory
  END

  ----------------------------------------------------------------------------------------------------
  --// Get default compression                                                                    //--
  ----------------------------------------------------------------------------------------------------

  IF @Compress IS NULL
  BEGIN
    SELECT @Compress = CASE
    WHEN @BackupSoftware IS NULL AND EXISTS(SELECT * FROM sys.configurations WHERE name = 'backup compression default' AND value_in_use = 1) THEN 'Y'
    WHEN @BackupSoftware IS NULL AND NOT EXISTS(SELECT * FROM sys.configurations WHERE name = 'backup compression default' AND value_in_use = 1) THEN 'N'
    WHEN @BackupSoftware IS NOT NULL AND (@CompressionLevel IS NULL OR @CompressionLevel > 0)  THEN 'Y'
    WHEN @BackupSoftware IS NOT NULL AND @CompressionLevel = 0  THEN 'N'
    END
  END

  ----------------------------------------------------------------------------------------------------
  --// Check directory                                                                            //--
  ----------------------------------------------------------------------------------------------------

  IF NOT (@Directory LIKE '_:' OR @Directory LIKE '_:\%' OR @Directory LIKE '\\%\%') OR @Directory IS NULL OR LEFT(@Directory,1) = ' ' OR RIGHT(@Directory,1) = ' '
  BEGIN
    SET @ErrorMessage = 'The value for parameter @Directory is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  SET @CheckDirectory = @Directory

  INSERT INTO @DirectoryInfo (FileExists, FileIsADirectory, ParentDirectoryExists)
  EXECUTE [master].dbo.xp_fileexist @CheckDirectory

  IF NOT EXISTS (SELECT * FROM @DirectoryInfo WHERE FileExists = 0 AND FileIsADirectory = 1 AND ParentDirectoryExists = 1)
  BEGIN
    SET @ErrorMessage = 'The directory does not exist.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  ----------------------------------------------------------------------------------------------------
  --// Check input parameters                                                                     //--
  ----------------------------------------------------------------------------------------------------

  IF @BackupType NOT IN ('FULL','DIFF','LOG') OR @BackupType IS NULL
  BEGIN
    SET @ErrorMessage = 'The value for parameter @BackupType is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @Verify NOT IN ('Y','N') OR @Verify IS NULL OR (@BackupSoftware = 'SQLSAFE' AND @Encrypt = 'Y' AND @Verify = 'Y')
  BEGIN
    SET @ErrorMessage = 'The value for parameter @Verify is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @CleanupTime < 0
  BEGIN
    SET @ErrorMessage = 'The value for parameter @CleanupTime is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @Compress NOT IN ('Y','N') OR @Compress IS NULL OR (@Compress = 'Y' AND @BackupSoftware IS NULL AND NOT ((@Version >= 10 AND @Version < 10.5 AND SERVERPROPERTY('EngineEdition') = 3) OR (@Version >= 10.5 AND (SERVERPROPERTY('EngineEdition') = 3 OR SERVERPROPERTY('EditionID') = -1534726760)))) OR (@Compress = 'N' AND @BackupSoftware IS NOT NULL AND (@CompressionLevel IS NULL OR @CompressionLevel >= 1)) OR (@Compress = 'Y' AND @BackupSoftware IS NOT NULL AND @CompressionLevel = 0)
  BEGIN
    SET @ErrorMessage = 'The value for parameter @Compress is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @CopyOnly NOT IN ('Y','N') OR @CopyOnly IS NULL
  BEGIN
    SET @ErrorMessage = 'The value for parameter @CopyOnly is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @ChangeBackupType NOT IN ('Y','N') OR @ChangeBackupType IS NULL
  BEGIN
    SET @ErrorMessage = 'The value for parameter @ChangeBackupType is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @BackupSoftware NOT IN ('LITESPEED','SQLBACKUP','HYPERBAC','SQLSAFE')
  BEGIN
    SET @ErrorMessage = 'The value for parameter @BackupSoftware is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @BackupSoftware = 'LITESPEED' AND NOT EXISTS (SELECT * FROM [master].sys.objects WHERE [type] = 'X' AND [name] = 'xp_backup_database')
  BEGIN
    SET @ErrorMessage = 'LiteSpeed is not installed. Download http://www.quest.com/litespeed-for-sql-server/.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @BackupSoftware = 'SQLBACKUP' AND NOT EXISTS (SELECT * FROM [master].sys.objects WHERE [type] = 'X' AND [name] = 'sqlbackup')
  BEGIN
    SET @ErrorMessage = 'SQLBackup is not installed. Download http://www.red-gate.com/products/dba/sql-backup/.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @BackupSoftware = 'SQLSAFE' AND NOT EXISTS (SELECT * FROM [master].sys.objects WHERE [type] = 'X' AND [name] = 'xp_ss_backup')
  BEGIN
    SET @ErrorMessage = 'SQLsafe is not installed. Download http://www.idera.com/Products/SQL-Server/SQL-safe-backup/.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @CheckSum NOT IN ('Y','N') OR @CheckSum IS NULL
  BEGIN
    SET @ErrorMessage = 'The value for parameter @CheckSum is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @BlockSize NOT IN (512,1024,2048,4096,8192,16384,32768,65536) OR (@BlockSize IS NOT NULL AND @BackupSoftware = 'SQLBACKUP') OR (@BlockSize IS NOT NULL AND @BackupSoftware = 'SQLSAFE')
  BEGIN
    SET @ErrorMessage = 'The value for parameter @BlockSize is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @BufferCount <= 0 OR @BufferCount > 2147483647 OR (@BufferCount IS NOT NULL AND @BackupSoftware = 'SQLBACKUP') OR (@BufferCount IS NOT NULL AND @BackupSoftware = 'SQLSAFE')
  BEGIN
    SET @ErrorMessage = 'The value for parameter @BufferCount is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @MaxTransferSize < 65536 OR @MaxTransferSize > 4194304 OR @MaxTransferSize % 65536 > 0 OR (@MaxTransferSize IS NOT NULL AND @BackupSoftware = 'SQLBACKUP') OR (@MaxTransferSize IS NOT NULL AND @BackupSoftware = 'SQLSAFE')
  BEGIN
    SET @ErrorMessage = 'The value for parameter @MaxTransferSize is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @NumberOfFiles < 1 OR @NumberOfFiles > 64 OR (@NumberOfFiles > 32 AND @BackupSoftware = 'SQLBACKUP') OR @NumberOfFiles IS NULL
  BEGIN
    SET @ErrorMessage = 'The value for parameter @NumberOfFiles is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF (@BackupSoftware IS NULL AND @CompressionLevel IS NOT NULL) OR (@BackupSoftware = 'HYPERBAC' AND @CompressionLevel IS NOT NULL) OR (@BackupSoftware = 'LITESPEED' AND (@CompressionLevel < 0 OR @CompressionLevel > 10)) OR (@BackupSoftware = 'SQLBACKUP' AND (@CompressionLevel < 0 OR @CompressionLevel > 4)) OR (@BackupSoftware = 'SQLSAFE' AND (@CompressionLevel < 1 OR @CompressionLevel > 4))
  BEGIN
    SET @ErrorMessage = 'The value for parameter @CompressionLevel is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF LEN(@Description) > 255 OR (@BackupSoftware = 'LITESPEED' AND LEN(@Description) > 128)
  BEGIN
    SET @ErrorMessage = 'The value for parameter @Description is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @Threads IS NOT NULL AND (@BackupSoftware NOT IN('LITESPEED','SQLBACKUP','SQLSAFE') OR @BackupSoftware IS NULL) OR @Threads < 2 OR @Threads > 32
  BEGIN
    SET @ErrorMessage = 'The value for parameter @Threads is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @Throttle IS NOT NULL AND (@BackupSoftware NOT IN('LITESPEED') OR @BackupSoftware IS NULL) OR @Throttle < 1 OR @Throttle > 100
  BEGIN
    SET @ErrorMessage = 'The value for parameter @Throttle is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @Encrypt NOT IN('Y','N') OR @Encrypt IS NULL OR (@Encrypt = 'Y' AND @BackupSoftware IS NULL)
  BEGIN
    SET @ErrorMessage = 'The value for parameter @Encrypt is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF (@EncryptionType IS NOT NULL AND @BackupSoftware IS NULL) OR (@EncryptionType IS NOT NULL AND @BackupSoftware = 'HYPERBAC') OR (@EncryptionType IS NOT NULL AND @Encrypt = 'N') OR ((@EncryptionType NOT IN('RC2-40','RC2-56','RC2-112','RC2-128','3DES-168','RC4-128','AES-128','AES-192','AES-256') OR @EncryptionType IS NULL) AND @Encrypt = 'Y' AND @BackupSoftware = 'LITESPEED') OR ((@EncryptionType NOT IN('AES-128','AES-256') OR @EncryptionType IS NULL) AND @Encrypt = 'Y' AND @BackupSoftware = 'SQLBACKUP') OR ((@EncryptionType NOT IN('AES-128','AES-256') OR @EncryptionType IS NULL) AND @Encrypt = 'Y' AND @BackupSoftware = 'SQLSAFE')
  BEGIN
    SET @ErrorMessage = 'The value for parameter @EncryptionType is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF (@EncryptionKey IS NOT NULL AND @BackupSoftware IS NULL) OR (@EncryptionKey IS NOT NULL AND @BackupSoftware = 'HYPERBAC') OR (@EncryptionKey IS NOT NULL AND @Encrypt = 'N') OR (@EncryptionKey IS NULL AND @Encrypt = 'Y' AND @BackupSoftware IN('LITESPEED','SQLBACKUP','SQLSAFE'))
  BEGIN
    SET @ErrorMessage = 'The value for parameter @EncryptionKey is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @LogToTable NOT IN('Y','N') OR @LogToTable IS NULL
  BEGIN
    SET @ErrorMessage = 'The value for parameter @LogToTable is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @Execute NOT IN('Y','N') OR @Execute IS NULL
  BEGIN
    SET @ErrorMessage = 'The value for parameter @Execute is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @Error <> 0
  BEGIN
    SET @ErrorMessage = 'The documentation is available at http://ola.hallengren.com/sql-server-backup.html.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @ReturnCode = @Error
    GOTO Logging
  END

  ----------------------------------------------------------------------------------------------------
  --// Execute backup commands                                                                    //--
  ----------------------------------------------------------------------------------------------------

  WHILE EXISTS (SELECT * FROM @tmpDatabases WHERE Completed = 0)
  BEGIN

    SELECT TOP 1 @CurrentID = ID,
                 @CurrentDatabaseName = DatabaseName
    FROM @tmpDatabases
    WHERE Completed = 0
    ORDER BY ID ASC

    SET @CurrentDatabaseID = DB_ID(@CurrentDatabaseName)

    IF EXISTS (SELECT * FROM sys.database_recovery_status WHERE database_id = @CurrentDatabaseID AND database_guid IS NOT NULL)
    BEGIN
      SET @CurrentIsDatabaseAccessible = 1
    END
    ELSE
    BEGIN
      SET @CurrentIsDatabaseAccessible = 0
    END

    SELECT @CurrentDifferentialLSN = differential_base_lsn
    FROM sys.master_files
    WHERE database_id = @CurrentDatabaseID
    AND [type] = 0
    AND [file_id] = 1

    -- Workaround for a bug in SQL Server 2005
    IF @Version >= 9 AND @Version < 10
    AND (SELECT differential_base_lsn FROM sys.master_files WHERE database_id = @CurrentDatabaseID AND [type] = 0 AND [file_id] = 1) = (SELECT differential_base_lsn FROM sys.master_files WHERE database_id = DB_ID('model') AND [type] = 0 AND [file_id] = 1)
    AND (SELECT differential_base_guid FROM sys.master_files WHERE database_id = @CurrentDatabaseID AND [type] = 0 AND [file_id] = 1) = (SELECT differential_base_guid FROM sys.master_files WHERE database_id = DB_ID('model') AND [type] = 0 AND [file_id] = 1)
    AND (SELECT differential_base_time FROM sys.master_files WHERE database_id = @CurrentDatabaseID AND [type] = 0 AND [file_id] = 1) IS NULL
    BEGIN
      SET @CurrentDifferentialLSN = NULL
    END

    -- If a VSS snapshot has been taken since the last full backup, a differential backup cannot be performed
    IF EXISTS (SELECT * FROM msdb.dbo.backupset WHERE database_name = @CurrentDatabaseName AND [type] = 'D' AND is_snapshot = 1 AND checkpoint_lsn = @CurrentDifferentialLSN)
    BEGIN
      SET @CurrentDifferentialLSN = NULL
    END

    SELECT @CurrentLogLSN = last_log_backup_lsn
    FROM sys.database_recovery_status
    WHERE database_id = @CurrentDatabaseID

    SET @CurrentBackupType = @BackupType

    IF @ChangeBackupType = 'Y'
    BEGIN
      IF @CurrentBackupType = 'LOG' AND DATABASEPROPERTYEX(@CurrentDatabaseName,'Recovery') <> 'SIMPLE' AND @CurrentLogLSN IS NULL AND @CurrentDatabaseName <> 'master'
      BEGIN
        SET @CurrentBackupType = 'DIFF'
      END
      IF @CurrentBackupType = 'DIFF' AND @CurrentDifferentialLSN IS NULL AND @CurrentDatabaseName <> 'master'
      BEGIN
        SET @CurrentBackupType = 'FULL'
      END
    END

    IF @CurrentBackupType = 'LOG'
    BEGIN
      SELECT @CurrentLatestBackup = MAX(backup_finish_date)
      FROM msdb.dbo.backupset
      WHERE [type] IN('D','I')
      AND is_copy_only = 0
      AND is_snapshot = 0
      AND is_damaged = 0
      AND database_name = @CurrentDatabaseName
    END

    IF @Version >= 11 AND @Cluster IS NOT NULL
    BEGIN
      SELECT @CurrentAvailabilityGroup = availability_groups.name,
             @CurrentRole = dm_hadr_availability_replica_states.role_desc
      FROM sys.databases databases
      INNER JOIN sys.availability_databases_cluster availability_databases_cluster ON databases.group_database_id = availability_databases_cluster.group_database_id
      INNER JOIN sys.availability_groups availability_groups ON availability_databases_cluster.group_id = availability_groups.group_id
      INNER JOIN sys.dm_hadr_availability_replica_states dm_hadr_availability_replica_states ON availability_groups.group_id = dm_hadr_availability_replica_states.group_id AND databases.replica_id = dm_hadr_availability_replica_states.replica_id
      WHERE databases.name = @CurrentDatabaseName
    END

    IF @Version >= 11 AND @Cluster IS NOT NULL AND @CurrentAvailabilityGroup IS NOT NULL
    BEGIN
      SELECT @CurrentIsPreferredBackupReplica = sys.fn_hadr_backup_is_preferred_replica(@CurrentDatabaseName)
    END

    -- Set database message
    SET @DatabaseMessage = 'DateTime: ' + CONVERT(nvarchar,GETDATE(),120) + CHAR(13) + CHAR(10)
    SET @DatabaseMessage = @DatabaseMessage + 'Database: ' + QUOTENAME(@CurrentDatabaseName) + CHAR(13) + CHAR(10)
    SET @DatabaseMessage = @DatabaseMessage + 'Status: ' + CAST(DATABASEPROPERTYEX(@CurrentDatabaseName,'Status') AS nvarchar) + CHAR(13) + CHAR(10)
    SET @DatabaseMessage = @DatabaseMessage + 'Standby: ' + CASE WHEN DATABASEPROPERTYEX(@CurrentDatabaseName,'IsInStandBy') = 1 THEN 'Yes' ELSE 'No' END + CHAR(13) + CHAR(10)
    SET @DatabaseMessage = @DatabaseMessage + 'Updateability: ' + CAST(DATABASEPROPERTYEX(@CurrentDatabaseName,'Updateability') AS nvarchar) + CHAR(13) + CHAR(10)
    SET @DatabaseMessage = @DatabaseMessage + 'User access: ' + CAST(DATABASEPROPERTYEX(@CurrentDatabaseName,'UserAccess') AS nvarchar) + CHAR(13) + CHAR(10)
    SET @DatabaseMessage = @DatabaseMessage + 'Is accessible: ' + CASE WHEN @CurrentIsDatabaseAccessible = 1 THEN 'Yes' ELSE 'No' END + CHAR(13) + CHAR(10)
    SET @DatabaseMessage = @DatabaseMessage + 'Recovery model: ' + CAST(DATABASEPROPERTYEX(@CurrentDatabaseName,'Recovery') AS nvarchar) + CHAR(13) + CHAR(10)
    IF @CurrentAvailabilityGroup IS NOT NULL SET @DatabaseMessage = @DatabaseMessage + 'Availability Group: ' + @CurrentAvailabilityGroup + CHAR(13) + CHAR(10)
    IF @CurrentAvailabilityGroup IS NOT NULL SET @DatabaseMessage = @DatabaseMessage + 'Availability Group role: ' + @CurrentRole + CHAR(13) + CHAR(10)
    IF @CurrentAvailabilityGroup IS NOT NULL SET @DatabaseMessage = @DatabaseMessage + 'Is preferred backup replica: ' + CASE WHEN @CurrentIsPreferredBackupReplica = 1 THEN 'Yes' WHEN @CurrentIsPreferredBackupReplica = 0 THEN 'No' ELSE 'N/A' END + CHAR(13) + CHAR(10)
    SET @DatabaseMessage = @DatabaseMessage + 'Differential base LSN: ' + ISNULL(CAST(@CurrentDifferentialLSN AS nvarchar),'N/A') + CHAR(13) + CHAR(10)
    SET @DatabaseMessage = @DatabaseMessage + 'Last log backup LSN: ' + ISNULL(CAST(@CurrentLogLSN AS nvarchar),'N/A') + CHAR(13) + CHAR(10)
    SET @DatabaseMessage = REPLACE(@DatabaseMessage,'%','%%') + ' '
    RAISERROR(@DatabaseMessage,10,1) WITH NOWAIT

    IF DATABASEPROPERTYEX(@CurrentDatabaseName,'Status') = 'ONLINE'
    AND NOT (DATABASEPROPERTYEX(@CurrentDatabaseName,'UserAccess') = 'SINGLE_USER' AND @CurrentIsDatabaseAccessible = 0)
    AND DATABASEPROPERTYEX(@CurrentDatabaseName,'IsInStandBy') = 0
    AND NOT (@CurrentBackupType = 'LOG' AND (DATABASEPROPERTYEX(@CurrentDatabaseName,'Recovery') = 'SIMPLE' OR @CurrentLogLSN IS NULL))
    AND NOT (@CurrentBackupType = 'DIFF' AND @CurrentDifferentialLSN IS NULL)
    AND NOT (@CurrentBackupType IN('DIFF','LOG') AND @CurrentDatabaseName = 'master')
    AND NOT (@CurrentAvailabilityGroup IS NOT NULL AND @CurrentBackupType = 'FULL' AND @CopyOnly = 'N' AND (@CurrentRole <> 'PRIMARY' OR @CurrentRole IS NULL))
    AND NOT (@CurrentAvailabilityGroup IS NOT NULL AND @CurrentBackupType = 'FULL' AND @CopyOnly = 'Y' AND (@CurrentIsPreferredBackupReplica <> 1 OR @CurrentIsPreferredBackupReplica IS NULL))
    AND NOT (@CurrentAvailabilityGroup IS NOT NULL AND @CurrentBackupType = 'DIFF' AND (@CurrentRole <> 'PRIMARY' OR @CurrentRole IS NULL))
    AND NOT (@CurrentAvailabilityGroup IS NOT NULL AND @CurrentBackupType = 'LOG' AND @CopyOnly = 'N' AND (@CurrentIsPreferredBackupReplica <> 1 OR @CurrentIsPreferredBackupReplica IS NULL))
    AND NOT (@CurrentAvailabilityGroup IS NOT NULL AND @CurrentBackupType = 'LOG' AND @CopyOnly = 'Y' AND (@CurrentRole <> 'PRIMARY' OR @CurrentRole IS NULL))
    BEGIN

      -- Set variables
      SET @CurrentDate = GETDATE()

      IF @CleanupTime IS NULL OR (@CurrentBackupType = 'LOG' AND @CurrentLatestBackup IS NULL)
      BEGIN
        SET @CurrentCleanupDate = NULL
      END
      ELSE
      IF @CurrentBackupType = 'LOG'
      BEGIN
        SET @CurrentCleanupDate = (SELECT MIN([Date]) FROM(SELECT DATEADD(hh,-(@CleanupTime),@CurrentDate) AS [Date] UNION SELECT @CurrentLatestBackup AS [Date]) Dates)
      END
      ELSE
      BEGIN
        SET @CurrentCleanupDate = DATEADD(hh,-(@CleanupTime),@CurrentDate)
      END

      SET @CurrentDatabaseNameFS = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@CurrentDatabaseName,'\',''),'/',''),':',''),'*',''),'?',''),'"',''),'<',''),'>',''),'|',''),' ','')

      SELECT @CurrentFileExtension = CASE
      WHEN @BackupSoftware IS NULL AND @CurrentBackupType = 'FULL' THEN 'bak'
      WHEN @BackupSoftware IS NULL AND @CurrentBackupType = 'DIFF' THEN 'bak'
      WHEN @BackupSoftware IS NULL AND @CurrentBackupType = 'LOG' THEN 'trn'
      WHEN @BackupSoftware = 'LITESPEED' AND @CurrentBackupType = 'FULL' THEN 'bak'
      WHEN @BackupSoftware = 'LITESPEED' AND @CurrentBackupType = 'DIFF' THEN 'bak'
      WHEN @BackupSoftware = 'LITESPEED' AND @CurrentBackupType = 'LOG' THEN 'trn'
      WHEN @BackupSoftware = 'SQLBACKUP' AND @CurrentBackupType = 'FULL' THEN 'sqb'
      WHEN @BackupSoftware = 'SQLBACKUP' AND @CurrentBackupType = 'DIFF' THEN 'sqb'
      WHEN @BackupSoftware = 'SQLBACKUP' AND @CurrentBackupType = 'LOG' THEN 'sqb'
      WHEN @BackupSoftware = 'HYPERBAC' AND @CurrentBackupType = 'FULL' AND @Encrypt = 'N' THEN 'hbc'
      WHEN @BackupSoftware = 'HYPERBAC' AND @CurrentBackupType = 'DIFF' AND @Encrypt = 'N' THEN 'hbc'
      WHEN @BackupSoftware = 'HYPERBAC' AND @CurrentBackupType = 'LOG' AND @Encrypt = 'N' THEN 'hbc'
      WHEN @BackupSoftware = 'HYPERBAC' AND @CurrentBackupType = 'FULL' AND @Encrypt = 'Y' THEN 'hbe'
      WHEN @BackupSoftware = 'HYPERBAC' AND @CurrentBackupType = 'DIFF' AND @Encrypt = 'Y' THEN 'hbe'
      WHEN @BackupSoftware = 'HYPERBAC' AND @CurrentBackupType = 'LOG' AND @Encrypt = 'Y' THEN 'hbe'
      WHEN @BackupSoftware = 'SQLSAFE' AND @CurrentBackupType = 'FULL' THEN 'safe'
      WHEN @BackupSoftware = 'SQLSAFE' AND @CurrentBackupType = 'DIFF' THEN 'safe'
      WHEN @BackupSoftware = 'SQLSAFE' AND @CurrentBackupType = 'LOG' THEN 'safe'
      END

      SET @CurrentDirectory = @Directory + CASE WHEN RIGHT(@Directory,1) = '\' THEN '' ELSE '\' END + CASE WHEN @CurrentAvailabilityGroup IS NOT NULL THEN @Cluster + '$' + @CurrentAvailabilityGroup ELSE REPLACE(CAST(SERVERPROPERTY('servername') AS nvarchar),'\','$') END + '\' + @CurrentDatabaseNameFS + '\' + UPPER(@CurrentBackupType) + CASE WHEN @CopyOnly = 'Y' THEN '_COPY_ONLY' ELSE '' END

      SET @CurrentFileNumber = 0

      WHILE @CurrentFileNumber < @NumberOfFiles
      BEGIN
        SET @CurrentFileNumber = @CurrentFileNumber + 1

        SET @CurrentFilePath = @CurrentDirectory + '\' + CASE WHEN @CurrentAvailabilityGroup IS NOT NULL THEN @Cluster + '$' + @CurrentAvailabilityGroup ELSE REPLACE(CAST(SERVERPROPERTY('servername') AS nvarchar),'\','$') END + '_' + @CurrentDatabaseNameFS + '_' + UPPER(@CurrentBackupType) + CASE WHEN @CopyOnly = 'Y' THEN '_COPY_ONLY' ELSE '' END + '_' + REPLACE(REPLACE(REPLACE((CONVERT(nvarchar,@CurrentDate,120)),'-',''),' ','_'),':','') + CASE WHEN @NumberOfFiles > 1 AND @NumberOfFiles <= 9 THEN '_' + CAST(@CurrentFileNumber AS nvarchar) WHEN @NumberOfFiles >= 10 THEN '_' + RIGHT('0' + CAST(@CurrentFileNumber AS nvarchar),2) ELSE '' END + '.' + @CurrentFileExtension

        IF LEN(@CurrentFilePath) > 259
        BEGIN
          SET @CurrentFilePath = @CurrentDirectory + '\' + CASE WHEN @CurrentAvailabilityGroup IS NOT NULL THEN @Cluster + '$' + @CurrentAvailabilityGroup ELSE REPLACE(CAST(SERVERPROPERTY('servername') AS nvarchar),'\','$') END + '_' + LEFT(@CurrentDatabaseNameFS,CASE WHEN (LEN(@CurrentDatabaseNameFS) + 259 - LEN(@CurrentFilePath) - 3) < 20 THEN 20 ELSE (LEN(@CurrentDatabaseNameFS) + 259 - LEN(@CurrentFilePath) - 3) END) + '...' + '_' + UPPER(@CurrentBackupType) + CASE WHEN @CopyOnly = 'Y' THEN '_COPY_ONLY' ELSE '' END + '_' + REPLACE(REPLACE(REPLACE((CONVERT(nvarchar,@CurrentDate,120)),'-',''),' ','_'),':','') + CASE WHEN @NumberOfFiles > 1 AND @NumberOfFiles <= 9 THEN '_' + CAST(@CurrentFileNumber AS nvarchar) WHEN @NumberOfFiles >= 10 THEN '_' + RIGHT('0' + CAST(@CurrentFileNumber AS nvarchar),2) ELSE '' END + '.' + @CurrentFileExtension
        END

        INSERT INTO @CurrentFiles (CurrentFilePath)
        SELECT @CurrentFilePath
      END

      -- Create directory
      SET @CurrentCommandType01 = 'xp_create_subdir'
      SET @CurrentCommand01 = 'DECLARE @ReturnCode int EXECUTE @ReturnCode = [master].dbo.xp_create_subdir N''' + REPLACE(@CurrentDirectory,'''','''''') + ''' IF @ReturnCode <> 0 RAISERROR(''Error creating directory.'', 16, 1)'
      EXECUTE @CurrentCommandOutput01 = [dbo].[CommandExecute] @Command = @CurrentCommand01, @CommandType = @CurrentCommandType01, @Mode = 1, @DatabaseName = @CurrentDatabaseName, @LogToTable = @LogToTable, @Execute = @Execute
      SET @Error = @@ERROR
      IF @Error <> 0 SET @CurrentCommandOutput01 = @Error
      IF @CurrentCommandOutput01 <> 0 SET @ReturnCode = @CurrentCommandOutput01

      -- Perform a backup
      IF @CurrentCommandOutput01 = 0
      BEGIN
        IF @BackupSoftware IS NULL
        BEGIN
          SELECT @CurrentCommandType02 = CASE
          WHEN @CurrentBackupType IN('DIFF','FULL') THEN 'BACKUP_DATABASE'
          WHEN @CurrentBackupType = 'LOG' THEN 'BACKUP_LOG'
          END

          SELECT @CurrentCommand02 = CASE
          WHEN @CurrentBackupType IN('DIFF','FULL') THEN 'BACKUP DATABASE ' + QUOTENAME(@CurrentDatabaseName) + ' TO'
          WHEN @CurrentBackupType = 'LOG' THEN 'BACKUP LOG ' + QUOTENAME(@CurrentDatabaseName) + ' TO'
          END

          SELECT @CurrentCommand02 = @CurrentCommand02 + ' DISK = N''' + REPLACE(CurrentFilePath,'''','''''') + '''' + CASE WHEN ROW_NUMBER() OVER (ORDER BY CurrentFilePath ASC) <> @NumberOfFiles THEN ',' ELSE '' END
          FROM @CurrentFiles
          ORDER BY CurrentFilePath ASC

          SET @CurrentCommand02 = @CurrentCommand02 + ' WITH '
          IF @CheckSum = 'Y' SET @CurrentCommand02 = @CurrentCommand02 + 'CHECKSUM'
          IF @CheckSum = 'N' SET @CurrentCommand02 = @CurrentCommand02 + 'NO_CHECKSUM'
          IF @Compress = 'Y' SET @CurrentCommand02 = @CurrentCommand02 + ', COMPRESSION'
          IF @Compress = 'N' AND @Version >= 10 SET @CurrentCommand02 = @CurrentCommand02 + ', NO_COMPRESSION'
          IF @CurrentBackupType = 'DIFF' SET @CurrentCommand02 = @CurrentCommand02 + ', DIFFERENTIAL'
          IF @CopyOnly = 'Y' SET @CurrentCommand02 = @CurrentCommand02 + ', COPY_ONLY'
          IF @BlockSize IS NOT NULL SET @CurrentCommand02 = @CurrentCommand02 + ', BLOCKSIZE = ' + CAST(@BlockSize AS nvarchar)
          IF @BufferCount IS NOT NULL SET @CurrentCommand02 = @CurrentCommand02 + ', BUFFERCOUNT = ' + CAST(@BufferCount AS nvarchar)
          IF @MaxTransferSize IS NOT NULL SET @CurrentCommand02 = @CurrentCommand02 + ', MAXTRANSFERSIZE = ' + CAST(@MaxTransferSize AS nvarchar)
          IF @Description IS NOT NULL SET @CurrentCommand02 = @CurrentCommand02 + ', DESCRIPTION = N''' + REPLACE(@Description,'''','''''') + ''''
        END

        IF @BackupSoftware = 'LITESPEED'
        BEGIN
          SELECT @CurrentCommandType02 = CASE
          WHEN @CurrentBackupType IN('DIFF','FULL') THEN 'xp_backup_database'
          WHEN @CurrentBackupType = 'LOG' THEN 'xp_backup_log'
          END

          SELECT @CurrentCommand02 = CASE
          WHEN @CurrentBackupType IN('DIFF','FULL') THEN 'DECLARE @ReturnCode int EXECUTE @ReturnCode = [master].dbo.xp_backup_database @database = N''' + REPLACE(@CurrentDatabaseName,'''','''''') + ''''
          WHEN @CurrentBackupType = 'LOG' THEN 'DECLARE @ReturnCode int EXECUTE @ReturnCode = [master].dbo.xp_backup_log @database = N''' + REPLACE(@CurrentDatabaseName,'''','''''') + ''''
          END

          SELECT @CurrentCommand02 = @CurrentCommand02 + ', @filename = N''' + REPLACE(CurrentFilePath,'''','''''') + ''''
          FROM @CurrentFiles
          ORDER BY CurrentFilePath ASC

          SET @CurrentCommand02 = @CurrentCommand02 + ', @with = '''
          IF @CheckSum = 'Y' SET @CurrentCommand02 = @CurrentCommand02 + 'CHECKSUM'
          IF @CheckSum = 'N' SET @CurrentCommand02 = @CurrentCommand02 + 'NO_CHECKSUM'
          IF @CurrentBackupType = 'DIFF' SET @CurrentCommand02 = @CurrentCommand02 + ', DIFFERENTIAL'
          IF @CopyOnly = 'Y' SET @CurrentCommand02 = @CurrentCommand02 + ', COPY_ONLY'
          IF @BlockSize IS NOT NULL SET @CurrentCommand02 = @CurrentCommand02 + ', BLOCKSIZE = ' + CAST(@BlockSize AS nvarchar)
          SET @CurrentCommand02 = @CurrentCommand02 + ''''
          IF @CompressionLevel IS NOT NULL SET @CurrentCommand02 = @CurrentCommand02 + ', @compressionlevel = ' + CAST(@CompressionLevel AS nvarchar)
          IF @BufferCount IS NOT NULL SET @CurrentCommand02 = @CurrentCommand02 + ', @buffercount = ' + CAST(@BufferCount AS nvarchar)
          IF @MaxTransferSize IS NOT NULL SET @CurrentCommand02 = @CurrentCommand02 + ', @maxtransfersize = ' + CAST(@MaxTransferSize AS nvarchar)
          IF @Threads IS NOT NULL SET @CurrentCommand02 = @CurrentCommand02 + ', @threads = ' + CAST(@Threads AS nvarchar)
          IF @Throttle IS NOT NULL SET @CurrentCommand02 = @CurrentCommand02 + ', @throttle = ' + CAST(@Throttle AS nvarchar)
          IF @Description IS NOT NULL SET @CurrentCommand02 = @CurrentCommand02 + ', @desc = N''' + REPLACE(@Description,'''','''''') + ''''

          IF @EncryptionType IS NOT NULL SET @CurrentCommand02 = @CurrentCommand02 + ', @cryptlevel = ' + CASE
          WHEN @EncryptionType = 'RC2-40' THEN '0'
          WHEN @EncryptionType = 'RC2-56' THEN '1'
          WHEN @EncryptionType = 'RC2-112' THEN '2'
          WHEN @EncryptionType = 'RC2-128' THEN '3'
          WHEN @EncryptionType = '3DES-168' THEN '4'
          WHEN @EncryptionType = 'RC4-128' THEN '5'
          WHEN @EncryptionType = 'AES-128' THEN '6'
          WHEN @EncryptionType = 'AES-192' THEN '7'
          WHEN @EncryptionType = 'AES-256' THEN '8'
          END

          IF @EncryptionKey IS NOT NULL SET @CurrentCommand02 = @CurrentCommand02 + ', @encryptionkey = N''' + REPLACE(@EncryptionKey,'''','''''') + ''''
          SET @CurrentCommand02 = @CurrentCommand02 + ' IF @ReturnCode <> 0 RAISERROR(''Error performing LiteSpeed backup.'', 16, 1)'
        END

        IF @BackupSoftware = 'SQLBACKUP'
        BEGIN
          SET @CurrentCommandType02 = 'sqlbackup'

          SELECT @CurrentCommand02 = CASE
          WHEN @CurrentBackupType IN('DIFF','FULL') THEN 'BACKUP DATABASE ' + QUOTENAME(@CurrentDatabaseName) + ' TO'
          WHEN @CurrentBackupType = 'LOG' THEN 'BACKUP LOG ' + QUOTENAME(@CurrentDatabaseName) + ' TO'
          END

          SELECT @CurrentCommand02 = @CurrentCommand02 + ' DISK = N''' + REPLACE(CurrentFilePath,'''','''''') + '''' + CASE WHEN ROW_NUMBER() OVER (ORDER BY CurrentFilePath ASC) <> @NumberOfFiles THEN ',' ELSE '' END
          FROM @CurrentFiles
          ORDER BY CurrentFilePath ASC

          SET @CurrentCommand02 = @CurrentCommand02 + ' WITH '
          IF @CheckSum = 'Y' SET @CurrentCommand02 = @CurrentCommand02 + 'CHECKSUM'
          IF @CheckSum = 'N' SET @CurrentCommand02 = @CurrentCommand02 + 'NO_CHECKSUM'
          IF @CurrentBackupType = 'DIFF' SET @CurrentCommand02 = @CurrentCommand02 + ', DIFFERENTIAL'
          IF @CopyOnly = 'Y' SET @CurrentCommand02 = @CurrentCommand02 + ', COPY_ONLY'
          IF @CompressionLevel IS NOT NULL SET @CurrentCommand02 = @CurrentCommand02 + ', COMPRESSION = ' + CAST(@CompressionLevel AS nvarchar)
          IF @Threads IS NOT NULL SET @CurrentCommand02 = @CurrentCommand02 + ', THREADCOUNT = ' + CAST(@Threads AS nvarchar)
          IF @Description IS NOT NULL SET @CurrentCommand02 = @CurrentCommand02 + ', DESCRIPTION = N''' + REPLACE(@Description,'''','''''') + ''''

          IF @EncryptionType IS NOT NULL SET @CurrentCommand02 = @CurrentCommand02 + ', KEYSIZE = ' + CASE
          WHEN @EncryptionType = 'AES-128' THEN '128'
          WHEN @EncryptionType = 'AES-256' THEN '256'
          END

          IF @EncryptionKey IS NOT NULL SET @CurrentCommand02 = @CurrentCommand02 + ', PASSWORD = N''' + REPLACE(@EncryptionKey,'''','''''') + ''''
          SET @CurrentCommand02 = 'DECLARE @ReturnCode int EXECUTE @ReturnCode = [master].dbo.sqlbackup N''-SQL "' + REPLACE(@CurrentCommand02,'''','''''') + '"''' + ' IF @ReturnCode <> 0 RAISERROR(''Error performing SQLBackup backup.'', 16, 1)'
        END

        IF @BackupSoftware = 'HYPERBAC'
        BEGIN
          SET @CurrentCommandType02 = 'BACKUP_DATABASE'

          SELECT @CurrentCommand02 = CASE
          WHEN @CurrentBackupType IN('DIFF','FULL') THEN 'BACKUP DATABASE ' + QUOTENAME(@CurrentDatabaseName) + ' TO'
          WHEN @CurrentBackupType = 'LOG' THEN 'BACKUP LOG ' + QUOTENAME(@CurrentDatabaseName) + ' TO'
          END

          SELECT @CurrentCommand02 = @CurrentCommand02 + ' DISK = N''' + REPLACE(CurrentFilePath,'''','''''') + '''' + CASE WHEN ROW_NUMBER() OVER (ORDER BY CurrentFilePath ASC) <> @NumberOfFiles THEN ',' ELSE '' END
          FROM @CurrentFiles
          ORDER BY CurrentFilePath ASC

          SET @CurrentCommand02 = @CurrentCommand02 + ' WITH '
          IF @CheckSum = 'Y' SET @CurrentCommand02 = @CurrentCommand02 + 'CHECKSUM'
          IF @CheckSum = 'N' SET @CurrentCommand02 = @CurrentCommand02 + 'NO_CHECKSUM'
          IF @CurrentBackupType = 'DIFF' SET @CurrentCommand02 = @CurrentCommand02 + ', DIFFERENTIAL'
          IF @CopyOnly = 'Y' SET @CurrentCommand02 = @CurrentCommand02 + ', COPY_ONLY'
          IF @BlockSize IS NOT NULL SET @CurrentCommand02 = @CurrentCommand02 + ', BLOCKSIZE = ' + CAST(@BlockSize AS nvarchar)
          IF @BufferCount IS NOT NULL SET @CurrentCommand02 = @CurrentCommand02 + ', BUFFERCOUNT = ' + CAST(@BufferCount AS nvarchar)
          IF @MaxTransferSize IS NOT NULL SET @CurrentCommand02 = @CurrentCommand02 + ', MAXTRANSFERSIZE = ' + CAST(@MaxTransferSize AS nvarchar)
          IF @Description IS NOT NULL SET @CurrentCommand02 = @CurrentCommand02 + ', DESCRIPTION = N''' + REPLACE(@Description,'''','''''') + ''''
        END

        IF @BackupSoftware = 'SQLSAFE'
        BEGIN
          SET @CurrentCommandType02 = 'xp_ss_backup'

          SET @CurrentCommand02 = 'DECLARE @ReturnCode int EXECUTE @ReturnCode = [master].dbo.xp_ss_backup @database = N''' + REPLACE(@CurrentDatabaseName,'''','''''') + ''''

          SELECT @CurrentCommand02 = @CurrentCommand02 + ', ' + CASE WHEN ROW_NUMBER() OVER (ORDER BY CurrentFilePath ASC) = 1 THEN '@filename' ELSE '@backupfile' END + ' = N''' + REPLACE(CurrentFilePath,'''','''''') + ''''
          FROM @CurrentFiles
          ORDER BY CurrentFilePath ASC

          SET @CurrentCommand02 = @CurrentCommand02 + ', @backuptype = ' + CASE WHEN @CurrentBackupType = 'FULL' THEN '''Full''' WHEN @CurrentBackupType = 'DIFF' THEN '''Differential''' WHEN @CurrentBackupType = 'LOG' THEN '''Log''' END
          SET @CurrentCommand02 = @CurrentCommand02 + ', @checksum = ' + CASE WHEN @CheckSum = 'Y' THEN '1' WHEN @CheckSum = 'N' THEN '0' END
          SET @CurrentCommand02 = @CurrentCommand02 + ', @copyonly = ' + CASE WHEN @CopyOnly = 'Y' THEN '1' WHEN @CopyOnly = 'N' THEN '0' END
          IF @CompressionLevel IS NOT NULL SET @CurrentCommand02 = @CurrentCommand02 + ', @compressionlevel = ' + CAST(@CompressionLevel AS nvarchar)
          IF @Threads IS NOT NULL SET @CurrentCommand02 = @CurrentCommand02 + ', @threads = ' + CAST(@Threads AS nvarchar)
          IF @Description IS NOT NULL SET @CurrentCommand02 = @CurrentCommand02 + ', @desc = N''' + REPLACE(@Description,'''','''''') + ''''

          IF @EncryptionType IS NOT NULL SET @CurrentCommand02 = @CurrentCommand02 + ', @encryptiontype = N''' + CASE
          WHEN @EncryptionType = 'AES-128' THEN 'AES128'
          WHEN @EncryptionType = 'AES-256' THEN 'AES256'
          END + ''''

          IF @EncryptionKey IS NOT NULL SET @CurrentCommand02 = @CurrentCommand02 + ', @encryptedbackuppassword = N''' + REPLACE(@EncryptionKey,'''','''''') + ''''
          SET @CurrentCommand02 = @CurrentCommand02 + ' IF @ReturnCode <> 0 RAISERROR(''Error performing SQLsafe backup.'', 16, 1)'
        END

        EXECUTE @CurrentCommandOutput02 = [dbo].[CommandExecute] @Command = @CurrentCommand02, @CommandType = @CurrentCommandType02, @Mode = 1, @DatabaseName = @CurrentDatabaseName, @LogToTable = @LogToTable, @Execute = @Execute
        SET @Error = @@ERROR
        IF @Error <> 0 SET @CurrentCommandOutput02 = @Error
        IF @CurrentCommandOutput02 <> 0 SET @ReturnCode = @CurrentCommandOutput02
      END

      -- Verify the backup
      IF @CurrentCommandOutput02 = 0 AND @Verify = 'Y'
      BEGIN
        IF @BackupSoftware IS NULL
        BEGIN
          SET @CurrentCommandType03 = 'RESTORE_VERIFYONLY'

          SET @CurrentCommand03 = 'RESTORE VERIFYONLY FROM'

          SELECT @CurrentCommand03 = @CurrentCommand03 + ' DISK = N''' + REPLACE(CurrentFilePath,'''','''''') + '''' + CASE WHEN ROW_NUMBER() OVER (ORDER BY CurrentFilePath ASC) <> @NumberOfFiles THEN ',' ELSE '' END
          FROM @CurrentFiles
          ORDER BY CurrentFilePath ASC

          SET @CurrentCommand03 = @CurrentCommand03 + ' WITH '
          IF @CheckSum = 'Y' SET @CurrentCommand03 = @CurrentCommand03 + 'CHECKSUM'
          IF @CheckSum = 'N' SET @CurrentCommand03 = @CurrentCommand03 + 'NO_CHECKSUM'
        END

        IF @BackupSoftware = 'LITESPEED'
        BEGIN
          SET @CurrentCommandType03 = 'xp_restore_verifyonly'

          SET @CurrentCommand03 = 'DECLARE @ReturnCode int EXECUTE @ReturnCode = [master].dbo.xp_restore_verifyonly'

          SELECT @CurrentCommand03 = @CurrentCommand03 + ' @filename = N''' + REPLACE(CurrentFilePath,'''','''''') + '''' + CASE WHEN ROW_NUMBER() OVER (ORDER BY CurrentFilePath ASC) <> @NumberOfFiles THEN ',' ELSE '' END
          FROM @CurrentFiles
          ORDER BY CurrentFilePath ASC

          SET @CurrentCommand03 = @CurrentCommand03 + ', @with = '''
          IF @CheckSum = 'Y' SET @CurrentCommand03 = @CurrentCommand03 + 'CHECKSUM'
          IF @CheckSum = 'N' SET @CurrentCommand03 = @CurrentCommand03 + 'NO_CHECKSUM'
          SET @CurrentCommand03 = @CurrentCommand03 + ''''
          IF @EncryptionKey IS NOT NULL SET @CurrentCommand03 = @CurrentCommand03 + ', @encryptionkey = N''' + REPLACE(@EncryptionKey,'''','''''') + ''''

          SET @CurrentCommand03 = @CurrentCommand03 + ' IF @ReturnCode <> 0 RAISERROR(''Error verifying LiteSpeed backup.'', 16, 1)'
        END

        IF @BackupSoftware = 'SQLBACKUP'
        BEGIN
          SET @CurrentCommandType03 = 'sqlbackup'

          SET @CurrentCommand03 = 'RESTORE VERIFYONLY FROM'

          SELECT @CurrentCommand03 = @CurrentCommand03 + ' DISK = N''' + REPLACE(CurrentFilePath,'''','''''') + '''' + CASE WHEN ROW_NUMBER() OVER (ORDER BY CurrentFilePath ASC) <> @NumberOfFiles THEN ',' ELSE '' END
          FROM @CurrentFiles
          ORDER BY CurrentFilePath ASC

          SET @CurrentCommand03 = @CurrentCommand03 + ' WITH '
          IF @CheckSum = 'Y' SET @CurrentCommand03 = @CurrentCommand03 + 'CHECKSUM'
          IF @CheckSum = 'N' SET @CurrentCommand03 = @CurrentCommand03 + 'NO_CHECKSUM'
          IF @EncryptionKey IS NOT NULL SET @CurrentCommand03 = @CurrentCommand03 + ', PASSWORD = N''' + REPLACE(@EncryptionKey,'''','''''') + ''''

          SET @CurrentCommand03 = 'DECLARE @ReturnCode int EXECUTE @ReturnCode = [master].dbo.sqlbackup N''-SQL "' + REPLACE(@CurrentCommand03,'''','''''') + '"''' + ' IF @ReturnCode <> 0 RAISERROR(''Error verifying SQLBackup backup.'', 16, 1)'
        END

        IF @BackupSoftware = 'HYPERBAC'
        BEGIN
          SET @CurrentCommandType03 = 'RESTORE_VERIFYONLY'

          SET @CurrentCommand03 = 'RESTORE VERIFYONLY FROM'

          SELECT @CurrentCommand03 = @CurrentCommand03 + ' DISK = N''' + REPLACE(CurrentFilePath,'''','''''') + '''' + CASE WHEN ROW_NUMBER() OVER (ORDER BY CurrentFilePath ASC) <> @NumberOfFiles THEN ',' ELSE '' END
          FROM @CurrentFiles
          ORDER BY CurrentFilePath ASC

          SET @CurrentCommand03 = @CurrentCommand03 + ' WITH '
          IF @CheckSum = 'Y' SET @CurrentCommand03 = @CurrentCommand03 + 'CHECKSUM'
          IF @CheckSum = 'N' SET @CurrentCommand03 = @CurrentCommand03 + 'NO_CHECKSUM'
        END

        IF @BackupSoftware = 'SQLSAFE'
        BEGIN
          SET @CurrentCommandType03 = 'xp_ss_verify'

          SET @CurrentCommand03 = 'DECLARE @ReturnCode int EXECUTE @ReturnCode = [master].dbo.xp_ss_verify @database = N''' + REPLACE(@CurrentDatabaseName,'''','''''') + ''''

          SELECT @CurrentCommand03 = @CurrentCommand03 + ', ' + CASE WHEN ROW_NUMBER() OVER (ORDER BY CurrentFilePath ASC) = 1 THEN '@filename' ELSE '@backupfile' END + ' = N''' + REPLACE(CurrentFilePath,'''','''''') + ''''
          FROM @CurrentFiles
          ORDER BY CurrentFilePath ASC

          SET @CurrentCommand03 = @CurrentCommand03 + ' IF @ReturnCode <> 0 RAISERROR(''Error verifying SQLsafe backup.'', 16, 1)'
        END

        EXECUTE @CurrentCommandOutput03 = [dbo].[CommandExecute] @Command = @CurrentCommand03, @CommandType = @CurrentCommandType03, @Mode = 1, @DatabaseName = @CurrentDatabaseName, @LogToTable = @LogToTable, @Execute = @Execute
        SET @Error = @@ERROR
        IF @Error <> 0 SET @CurrentCommandOutput03 = @Error
        IF @CurrentCommandOutput03 <> 0 SET @ReturnCode = @CurrentCommandOutput03
      END

      -- Delete old backup files
      IF (@CurrentCommandOutput02 = 0 AND @Verify = 'N' AND @CurrentCleanupDate IS NOT NULL)
      OR (@CurrentCommandOutput02 = 0 AND @Verify = 'Y' AND @CurrentCommandOutput03 = 0 AND @CurrentCleanupDate IS NOT NULL)
      BEGIN
        IF @BackupSoftware IS NULL
        BEGIN
          SET @CurrentCommandType04 = 'xp_delete_file'

          SET @CurrentCommand04 = 'DECLARE @ReturnCode int EXECUTE @ReturnCode = [master].dbo.xp_delete_file 0, N''' + REPLACE(@CurrentDirectory,'''','''''') + ''', ''' + @CurrentFileExtension + ''', ''' + CONVERT(nvarchar(19),@CurrentCleanupDate,126) + ''' IF @ReturnCode <> 0 RAISERROR(''Error deleting files.'', 16, 1)'
        END

        IF @BackupSoftware = 'LITESPEED'
        BEGIN
          SET @CurrentCommandType04 = 'xp_slssqlmaint'

          SET @CurrentCommand04 = 'DECLARE @ReturnCode int EXECUTE @ReturnCode = [master].dbo.xp_slssqlmaint N''-MAINTDEL -DELFOLDER "' + REPLACE(@CurrentDirectory,'''','''''') + '" -DELEXTENSION "' + @CurrentFileExtension + '" -DELUNIT "' + CAST(DATEDIFF(mi,@CurrentCleanupDate,GETDATE()) + 1 AS nvarchar) + '" -DELUNITTYPE "minutes" -DELUSEAGE'' IF @ReturnCode <> 0 RAISERROR(''Error deleting LiteSpeed backup files.'', 16, 1)'
        END

        IF @BackupSoftware = 'SQLBACKUP'
        BEGIN
          SET @CurrentCommandType04 = 'sqbutility'

          SET @CurrentCommand04 = 'DECLARE @ReturnCode int EXECUTE @ReturnCode = [master].dbo.sqbutility 1032, N''' + REPLACE(@CurrentDatabaseName,'''','''''') + ''', N''' + REPLACE(@CurrentDirectory,'''','''''') + ''', ''' + CASE WHEN @CurrentBackupType = 'FULL' THEN 'D' WHEN @CurrentBackupType = 'DIFF' THEN 'I' WHEN @CurrentBackupType = 'LOG' THEN 'L' END + ''', ''' + CAST(DATEDIFF(hh,@CurrentCleanupDate,GETDATE()) + 1 AS nvarchar) + 'h'', ' + ISNULL('''' + REPLACE(@EncryptionKey,'''','''''') + '''','NULL') + ' IF @ReturnCode <> 0 RAISERROR(''Error deleting SQLBackup backup files.'', 16, 1)'
        END

        IF @BackupSoftware = 'HYPERBAC'
        BEGIN
          SET @CurrentCommandType04 = 'xp_delete_file'

          SET @CurrentCommand04 = 'DECLARE @ReturnCode int EXECUTE @ReturnCode = [master].dbo.xp_delete_file 0, N''' + REPLACE(@CurrentDirectory,'''','''''') + ''', ''' + @CurrentFileExtension + ''', ''' + CONVERT(nvarchar(19),@CurrentCleanupDate,126) + ''' IF @ReturnCode <> 0 RAISERROR(''Error deleting files.'', 16, 1)'
        END

        IF @BackupSoftware = 'SQLSAFE'
        BEGIN
          SET @CurrentCommandType04 = 'xp_ss_delete'

          SET @CurrentCommand04 = 'DECLARE @ReturnCode int EXECUTE @ReturnCode = [master].dbo.xp_ss_delete @filename = N''' + REPLACE(@CurrentDirectory,'''','''''') + '\*.' + @CurrentFileExtension + ''', @age = ''' + CAST(DATEDIFF(mi,@CurrentCleanupDate,GETDATE()) + 1 AS nvarchar) + 'Minutes'' IF @ReturnCode <> 0 RAISERROR(''Error deleting SQLsafe backup files.'', 16, 1)'
        END

        EXECUTE @CurrentCommandOutput04 = [dbo].[CommandExecute] @Command = @CurrentCommand04, @CommandType = @CurrentCommandType04, @Mode = 1, @DatabaseName = @CurrentDatabaseName, @LogToTable = @LogToTable, @Execute = @Execute
        SET @Error = @@ERROR
        IF @Error <> 0 SET @CurrentCommandOutput04 = @Error
        IF @CurrentCommandOutput04 <> 0 SET @ReturnCode = @CurrentCommandOutput04
      END

    END

    -- Update that the database is completed
    UPDATE @tmpDatabases
    SET Completed = 1
    WHERE ID = @CurrentID

    -- Clear variables
    SET @CurrentID = NULL
    SET @CurrentDatabaseID = NULL
    SET @CurrentDatabaseName = NULL
    SET @CurrentBackupType = NULL
    SET @CurrentFileExtension = NULL
    SET @CurrentFileNumber = NULL
    SET @CurrentDifferentialLSN = NULL
    SET @CurrentLogLSN = NULL
    SET @CurrentLatestBackup = NULL
    SET @CurrentDatabaseNameFS = NULL
    SET @CurrentDirectory = NULL
    SET @CurrentFilePath = NULL
    SET @CurrentDate = NULL
    SET @CurrentCleanupDate = NULL
    SET @CurrentIsDatabaseAccessible = NULL
    SET @CurrentAvailabilityGroup = NULL
    SET @CurrentRole = NULL
    SET @CurrentIsPreferredBackupReplica = NULL

    SET @CurrentCommand01 = NULL
    SET @CurrentCommand02 = NULL
    SET @CurrentCommand03 = NULL
    SET @CurrentCommand04 = NULL

    SET @CurrentCommandOutput01 = NULL
    SET @CurrentCommandOutput02 = NULL
    SET @CurrentCommandOutput03 = NULL
    SET @CurrentCommandOutput04 = NULL

    SET @CurrentCommandType01 = NULL
    SET @CurrentCommandType02 = NULL
    SET @CurrentCommandType03 = NULL
    SET @CurrentCommandType04 = NULL

    DELETE FROM @CurrentFiles

  END

  ----------------------------------------------------------------------------------------------------
  --// Log completing information                                                                 //--
  ----------------------------------------------------------------------------------------------------

  Logging:
  SET @EndMessage = 'DateTime: ' + CONVERT(nvarchar,GETDATE(),120)
  SET @EndMessage = REPLACE(@EndMessage,'%','%%')
  RAISERROR(@EndMessage,10,1) WITH NOWAIT

  IF @ReturnCode <> 0
  BEGIN
    RETURN @ReturnCode
  END

  ----------------------------------------------------------------------------------------------------

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DatabaseIntegrityCheck]

@Databases nvarchar(max),
@PhysicalOnly nvarchar(max) = 'N',
@NoIndex nvarchar(max) = 'N',
@ExtendedLogicalChecks nvarchar(max) = 'N',
@TabLock nvarchar(max) = 'N',
@LogToTable nvarchar(max) = 'N',
@Execute nvarchar(max) = 'Y'

AS

BEGIN

  ----------------------------------------------------------------------------------------------------
  --// Source: http://ola.hallengren.com                                                          //--
  ----------------------------------------------------------------------------------------------------

  SET NOCOUNT ON

  DECLARE @StartMessage nvarchar(max)
  DECLARE @EndMessage nvarchar(max)
  DECLARE @DatabaseMessage nvarchar(max)
  DECLARE @ErrorMessage nvarchar(max)

  DECLARE @Version numeric(18,10)

  DECLARE @Cluster nvarchar(max)

  DECLARE @CurrentID int
  DECLARE @CurrentDatabaseID int
  DECLARE @CurrentDatabaseName nvarchar(max)
  DECLARE @CurrentIsDatabaseAccessible bit
  DECLARE @CurrentAvailabilityGroup nvarchar(max)
  DECLARE @CurrentRole nvarchar(max)

  DECLARE @CurrentCommand01 nvarchar(max)

  DECLARE @CurrentCommandOutput01 int

  DECLARE @CurrentCommandType01 nvarchar(max)

  DECLARE @tmpDatabases TABLE (ID int IDENTITY PRIMARY KEY,
                               DatabaseName nvarchar(max),
                               Completed bit)

  DECLARE @Error int
  DECLARE @ReturnCode int

  SET @Error = 0
  SET @ReturnCode = 0

  SET @Version = CAST(LEFT(CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max)),CHARINDEX('.',CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max))) - 1) + '.' + REPLACE(RIGHT(CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max)), LEN(CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max))) - CHARINDEX('.',CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max)))),'.','') AS numeric(18,10))

  IF @Version >= 11
  BEGIN
    SELECT @Cluster = cluster_name
    FROM sys.dm_hadr_cluster
  END

  ----------------------------------------------------------------------------------------------------
  --// Log initial information                                                                    //--
  ----------------------------------------------------------------------------------------------------

  SET @StartMessage = 'DateTime: ' + CONVERT(nvarchar,GETDATE(),120) + CHAR(13) + CHAR(10)
  SET @StartMessage = @StartMessage + 'Server: ' + CAST(SERVERPROPERTY('ServerName') AS nvarchar) + CHAR(13) + CHAR(10)
  SET @StartMessage = @StartMessage + 'Version: ' + CAST(SERVERPROPERTY('ProductVersion') AS nvarchar) + CHAR(13) + CHAR(10)
  SET @StartMessage = @StartMessage + 'Edition: ' + CAST(SERVERPROPERTY('Edition') AS nvarchar) + CHAR(13) + CHAR(10)
  SET @StartMessage = @StartMessage + 'Procedure: ' + QUOTENAME(DB_NAME(DB_ID())) + '.' + (SELECT QUOTENAME(schemas.name) FROM sys.schemas schemas INNER JOIN sys.objects objects ON schemas.[schema_id] = objects.[schema_id] WHERE [object_id] = @@PROCID) + '.' + QUOTENAME(OBJECT_NAME(@@PROCID)) + CHAR(13) + CHAR(10)
  SET @StartMessage = @StartMessage + 'Parameters: @Databases = ' + ISNULL('''' + REPLACE(@Databases,'''','''''') + '''','NULL')
  SET @StartMessage = @StartMessage + ', @PhysicalOnly = ' + ISNULL('''' + REPLACE(@PhysicalOnly,'''','''''') + '''','NULL')
  SET @StartMessage = @StartMessage + ', @NoIndex = ' + ISNULL('''' + REPLACE(@NoIndex,'''','''''') + '''','NULL')
  SET @StartMessage = @StartMessage + ', @ExtendedLogicalChecks = ' + ISNULL('''' + REPLACE(@ExtendedLogicalChecks,'''','''''') + '''','NULL')
  SET @StartMessage = @StartMessage + ', @TabLock = ' + ISNULL('''' + REPLACE(@TabLock,'''','''''') + '''','NULL')
  SET @StartMessage = @StartMessage + ', @LogToTable = ' + ISNULL('''' + REPLACE(@LogToTable,'''','''''') + '''','NULL')
  SET @StartMessage = @StartMessage + ', @Execute = ' + ISNULL('''' + REPLACE(@Execute,'''','''''') + '''','NULL') + CHAR(13) + CHAR(10)
  SET @StartMessage = @StartMessage + 'Source: http://ola.hallengren.com' + CHAR(13) + CHAR(10)
  SET @StartMessage = REPLACE(@StartMessage,'%','%%') + ' '
  RAISERROR(@StartMessage,10,1) WITH NOWAIT

  ----------------------------------------------------------------------------------------------------
  --// Check core requirements                                                                    //--
  ----------------------------------------------------------------------------------------------------

  IF SERVERPROPERTY('EngineEdition') = 5
  BEGIN
    SET @ErrorMessage = 'SQL Azure is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @Error <> 0
  BEGIN
    SET @ReturnCode = @Error
    GOTO Logging
  END

  IF NOT EXISTS (SELECT * FROM sys.objects objects INNER JOIN sys.schemas schemas ON objects.[schema_id] = schemas.[schema_id] WHERE objects.[type] = 'P' AND schemas.[name] = 'dbo' AND objects.[name] = 'CommandExecute')
  BEGIN
    SET @ErrorMessage = 'The stored procedure CommandExecute is missing. Download http://ola.hallengren.com/scripts/CommandExecute.sql.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF EXISTS (SELECT * FROM sys.objects objects INNER JOIN sys.schemas schemas ON objects.[schema_id] = schemas.[schema_id] WHERE objects.[type] = 'P' AND schemas.[name] = 'dbo' AND objects.[name] = 'CommandExecute' AND OBJECT_DEFINITION(objects.[object_id]) NOT LIKE '%@LogToTable%')
  BEGIN
    SET @ErrorMessage = 'The stored procedure CommandExecute needs to be updated. Download http://ola.hallengren.com/scripts/CommandExecute.sql.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF NOT EXISTS (SELECT * FROM sys.objects objects INNER JOIN sys.schemas schemas ON objects.[schema_id] = schemas.[schema_id] WHERE objects.[type] = 'TF' AND schemas.[name] = 'dbo' AND objects.[name] = 'DatabaseSelect')
  BEGIN
    SET @ErrorMessage = 'The function DatabaseSelect is missing. Download http://ola.hallengren.com/scripts/DatabaseSelect.sql.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @LogToTable = 'Y' AND NOT EXISTS (SELECT * FROM sys.objects objects INNER JOIN sys.schemas schemas ON objects.[schema_id] = schemas.[schema_id] WHERE objects.[type] = 'U' AND schemas.[name] = 'dbo' AND objects.[name] = 'CommandLog')
  BEGIN
    SET @ErrorMessage = 'The table CommandLog is missing. Download http://ola.hallengren.com/scripts/CommandLog.sql.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @Error <> 0
  BEGIN
    SET @ReturnCode = @Error
    GOTO Logging
  END

  ----------------------------------------------------------------------------------------------------
  --// Select databases                                                                           //--
  ----------------------------------------------------------------------------------------------------

  IF @Databases IS NULL OR @Databases = ''
  BEGIN
    SET @ErrorMessage = 'The value for parameter @Databases is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  INSERT INTO @tmpDatabases (DatabaseName, Completed)
  SELECT DatabaseName AS DatabaseName,
         0 AS Completed
  FROM dbo.DatabaseSelect (@Databases)
  ORDER BY DatabaseName ASC

  IF @@ERROR <> 0
  BEGIN
    SET @ErrorMessage = 'Error selecting databases.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  ----------------------------------------------------------------------------------------------------
  --// Check input parameters                                                                     //--
  ----------------------------------------------------------------------------------------------------

  IF @PhysicalOnly NOT IN ('Y','N') OR @PhysicalOnly IS NULL
  BEGIN
    SET @ErrorMessage = 'The value for parameter @PhysicalOnly is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @NoIndex NOT IN ('Y','N') OR @NoIndex IS NULL
  BEGIN
    SET @ErrorMessage = 'The value for parameter @NoIndex is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @ExtendedLogicalChecks NOT IN ('Y','N') OR @ExtendedLogicalChecks IS NULL OR (@ExtendedLogicalChecks = 'Y' AND NOT @Version >= 10)
  BEGIN
    SET @ErrorMessage = 'The value for parameter @ExtendedLogicalChecks is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @PhysicalOnly = 'Y' AND @ExtendedLogicalChecks = 'Y'
  BEGIN
    SET @ErrorMessage = 'Extended Logical Checks and Physical Only cannot be used together.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @TabLock NOT IN ('Y','N') OR @TabLock IS NULL
  BEGIN
    SET @ErrorMessage = 'The value for parameter @TabLock is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @LogToTable NOT IN('Y','N') OR @LogToTable IS NULL
  BEGIN
    SET @ErrorMessage = 'The value for parameter @LogToTable is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @Execute NOT IN('Y','N') OR @Execute IS NULL
  BEGIN
    SET @ErrorMessage = 'The value for parameter @Execute is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @Error <> 0
  BEGIN
    SET @ErrorMessage = 'The documentation is available at http://ola.hallengren.com/sql-server-integrity-check.html.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @ReturnCode = @Error
    GOTO Logging
  END

  ----------------------------------------------------------------------------------------------------
  --// Execute commands                                                                           //--
  ----------------------------------------------------------------------------------------------------

  WHILE EXISTS (SELECT * FROM @tmpDatabases WHERE Completed = 0)
  BEGIN

    SELECT TOP 1 @CurrentID = ID,
                 @CurrentDatabaseName = DatabaseName
    FROM @tmpDatabases
    WHERE Completed = 0
    ORDER BY ID ASC

    SET @CurrentDatabaseID = DB_ID(@CurrentDatabaseName)

    IF EXISTS (SELECT * FROM sys.database_recovery_status WHERE database_id = @CurrentDatabaseID AND database_guid IS NOT NULL)
    BEGIN
      SET @CurrentIsDatabaseAccessible = 1
    END
    ELSE
    BEGIN
      SET @CurrentIsDatabaseAccessible = 0
    END

    IF @Version >= 11 AND @Cluster IS NOT NULL
    BEGIN
      SELECT @CurrentAvailabilityGroup = availability_groups.name,
             @CurrentRole = dm_hadr_availability_replica_states.role_desc
      FROM sys.databases databases
      INNER JOIN sys.availability_databases_cluster availability_databases_cluster ON databases.group_database_id = availability_databases_cluster.group_database_id
      INNER JOIN sys.availability_groups availability_groups ON availability_databases_cluster.group_id = availability_groups.group_id
      INNER JOIN sys.dm_hadr_availability_replica_states dm_hadr_availability_replica_states ON availability_groups.group_id = dm_hadr_availability_replica_states.group_id AND databases.replica_id = dm_hadr_availability_replica_states.replica_id
      WHERE databases.name = @CurrentDatabaseName
    END

    -- Set database message
    SET @DatabaseMessage = 'DateTime: ' + CONVERT(nvarchar,GETDATE(),120) + CHAR(13) + CHAR(10)
    SET @DatabaseMessage = @DatabaseMessage + 'Database: ' + QUOTENAME(@CurrentDatabaseName) + CHAR(13) + CHAR(10)
    SET @DatabaseMessage = @DatabaseMessage + 'Status: ' + CAST(DATABASEPROPERTYEX(@CurrentDatabaseName,'Status') AS nvarchar) + CHAR(13) + CHAR(10)
    SET @DatabaseMessage = @DatabaseMessage + 'Standby: ' + CASE WHEN DATABASEPROPERTYEX(@CurrentDatabaseName,'IsInStandBy') = 1 THEN 'Yes' ELSE 'No' END + CHAR(13) + CHAR(10)
    SET @DatabaseMessage = @DatabaseMessage + 'Updateability: ' + CAST(DATABASEPROPERTYEX(@CurrentDatabaseName,'Updateability') AS nvarchar) + CHAR(13) + CHAR(10)
    SET @DatabaseMessage = @DatabaseMessage + 'User access: ' + CAST(DATABASEPROPERTYEX(@CurrentDatabaseName,'UserAccess') AS nvarchar) + CHAR(13) + CHAR(10)
    SET @DatabaseMessage = @DatabaseMessage + 'Is accessible: ' + CASE WHEN @CurrentIsDatabaseAccessible = 1 THEN 'Yes' ELSE 'No' END + CHAR(13) + CHAR(10)
    SET @DatabaseMessage = @DatabaseMessage + 'Recovery model: ' + CAST(DATABASEPROPERTYEX(@CurrentDatabaseName,'Recovery') AS nvarchar) + CHAR(13) + CHAR(10)
    IF @CurrentAvailabilityGroup IS NOT NULL SET @DatabaseMessage = @DatabaseMessage + 'Availability Group: ' + @CurrentAvailabilityGroup + CHAR(13) + CHAR(10)
    IF @CurrentAvailabilityGroup IS NOT NULL SET @DatabaseMessage = @DatabaseMessage + 'Availability Group role: ' + @CurrentRole + CHAR(13) + CHAR(10)
    SET @DatabaseMessage = REPLACE(@DatabaseMessage,'%','%%') + ' '
    RAISERROR(@DatabaseMessage,10,1) WITH NOWAIT

    IF DATABASEPROPERTYEX(@CurrentDatabaseName,'Status') = 'ONLINE'
    AND NOT (DATABASEPROPERTYEX(@CurrentDatabaseName,'UserAccess') = 'SINGLE_USER' AND @CurrentIsDatabaseAccessible = 0)
    BEGIN
      SET @CurrentCommandType01 = 'DBCC_CHECKDB'

      SET @CurrentCommand01 = 'DBCC CHECKDB (' + QUOTENAME(@CurrentDatabaseName)
      IF @NoIndex = 'Y' SET @CurrentCommand01 = @CurrentCommand01 + ', NOINDEX'
      SET @CurrentCommand01 = @CurrentCommand01 + ') WITH NO_INFOMSGS, ALL_ERRORMSGS'
      IF @PhysicalOnly = 'N' SET @CurrentCommand01 = @CurrentCommand01 + ', DATA_PURITY'
      IF @PhysicalOnly = 'Y' SET @CurrentCommand01 = @CurrentCommand01 + ', PHYSICAL_ONLY'
      IF @ExtendedLogicalChecks = 'Y' SET @CurrentCommand01 = @CurrentCommand01 + ', EXTENDED_LOGICAL_CHECKS'
      IF @TabLock = 'Y' SET @CurrentCommand01 = @CurrentCommand01 + ', TABLOCK'

      EXECUTE @CurrentCommandOutput01 = [dbo].[CommandExecute] @Command = @CurrentCommand01, @CommandType = @CurrentCommandType01, @Mode = 1, @DatabaseName = @CurrentDatabaseName, @LogToTable = @LogToTable, @Execute = @Execute
      SET @Error = @@ERROR
      IF @Error <> 0 SET @CurrentCommandOutput01 = @Error
      IF @CurrentCommandOutput01 <> 0 SET @ReturnCode = @CurrentCommandOutput01
    END

    -- Update that the database is completed
    UPDATE @tmpDatabases
    SET Completed = 1
    WHERE ID = @CurrentID

    -- Clear variables
    SET @CurrentID = NULL
    SET @CurrentDatabaseID = NULL
    SET @CurrentDatabaseName = NULL
    SET @CurrentIsDatabaseAccessible = NULL
    SET @CurrentAvailabilityGroup = NULL
    SET @CurrentRole = NULL

    SET @CurrentCommand01 = NULL

    SET @CurrentCommandOutput01 = NULL

    SET @CurrentCommandType01 = NULL

  END

  ----------------------------------------------------------------------------------------------------
  --// Log completing information                                                                 //--
  ----------------------------------------------------------------------------------------------------

  Logging:
  SET @EndMessage = 'DateTime: ' + CONVERT(nvarchar,GETDATE(),120)
  SET @EndMessage = REPLACE(@EndMessage,'%','%%')
  RAISERROR(@EndMessage,10,1) WITH NOWAIT

  IF @ReturnCode <> 0
  BEGIN
    RETURN @ReturnCode
  END

  ----------------------------------------------------------------------------------------------------

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[IndexOptimize]

@Databases nvarchar(max),
@FragmentationLow nvarchar(max) = NULL,
@FragmentationMedium nvarchar(max) = 'INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
@FragmentationHigh nvarchar(max) = 'INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
@FragmentationLevel1 int = 5,
@FragmentationLevel2 int = 30,
@PageCountLevel int = 1000,
@SortInTempdb nvarchar(max) = 'N',
@MaxDOP int = NULL,
@FillFactor int = NULL,
@PadIndex nvarchar(max) = NULL,
@LOBCompaction nvarchar(max) = 'Y',
@UpdateStatistics nvarchar(max) = NULL,
@OnlyModifiedStatistics nvarchar(max) = 'N',
@StatisticsSample int = NULL,
@StatisticsResample nvarchar(max) = 'N',
@PartitionLevel nvarchar(max) = 'N',
@TimeLimit int = NULL,
@Indexes nvarchar(max) = NULL,
@Delay int = NULL,
@LogToTable nvarchar(max) = 'N',
@Execute nvarchar(max) = 'Y'

AS

BEGIN

  ----------------------------------------------------------------------------------------------------
  --// Source: http://ola.hallengren.com                                                          //--
  ----------------------------------------------------------------------------------------------------

  SET NOCOUNT ON

  SET ARITHABORT ON

  SET LOCK_TIMEOUT 3600000

  DECLARE @StartMessage nvarchar(max)
  DECLARE @EndMessage nvarchar(max)
  DECLARE @DatabaseMessage nvarchar(max)
  DECLARE @ErrorMessage nvarchar(max)

  DECLARE @Version numeric(18,10)

  DECLARE @Cluster nvarchar(max)

  DECLARE @StartTime datetime

  DECLARE @CurrentIndexList nvarchar(max)
  DECLARE @CurrentIndexItem nvarchar(max)
  DECLARE @CurrentIndexPosition int

  DECLARE @CurrentID int
  DECLARE @CurrentDatabaseID int
  DECLARE @CurrentDatabaseName nvarchar(max)
  DECLARE @CurrentIsDatabaseAccessible bit
  DECLARE @CurrentAvailabilityGroup nvarchar(max)
  DECLARE @CurrentRole nvarchar(max)

  DECLARE @CurrentCommand01 nvarchar(max)
  DECLARE @CurrentCommand02 nvarchar(max)
  DECLARE @CurrentCommand03 nvarchar(max)
  DECLARE @CurrentCommand04 nvarchar(max)
  DECLARE @CurrentCommand05 nvarchar(max)
  DECLARE @CurrentCommand06 nvarchar(max)
  DECLARE @CurrentCommand07 nvarchar(max)
  DECLARE @CurrentCommand08 nvarchar(max)
  DECLARE @CurrentCommand09 nvarchar(max)
  DECLARE @CurrentCommand10 nvarchar(max)
  DECLARE @CurrentCommand11 nvarchar(max)
  DECLARE @CurrentCommand12 nvarchar(max)

  DECLARE @CurrentCommandOutput11 int
  DECLARE @CurrentCommandOutput12 int

  DECLARE @CurrentCommandType11 nvarchar(max)
  DECLARE @CurrentCommandType12 nvarchar(max)

  DECLARE @CurrentIxID int
  DECLARE @CurrentSchemaID int
  DECLARE @CurrentSchemaName nvarchar(max)
  DECLARE @CurrentObjectID int
  DECLARE @CurrentObjectName nvarchar(max)
  DECLARE @CurrentObjectType nvarchar(max)
  DECLARE @CurrentIndexID int
  DECLARE @CurrentIndexName nvarchar(max)
  DECLARE @CurrentIndexType int
  DECLARE @CurrentStatisticsID int
  DECLARE @CurrentStatisticsName nvarchar(max)
  DECLARE @CurrentPartitionID bigint
  DECLARE @CurrentPartitionNumber int
  DECLARE @CurrentPartitionCount int
  DECLARE @CurrentIsPartition bit
  DECLARE @CurrentIndexExists bit
  DECLARE @CurrentStatisticsExists bit
  DECLARE @CurrentIsImageText bit
  DECLARE @CurrentIsNewLOB bit
  DECLARE @CurrentIsFileStream bit
  DECLARE @CurrentAllowPageLocks bit
  DECLARE @CurrentNoRecompute bit
  DECLARE @CurrentStatisticsModified bit
  DECLARE @CurrentOnReadOnlyFileGroup bit
  DECLARE @CurrentFragmentationLevel float
  DECLARE @CurrentPageCount bigint
  DECLARE @CurrentFragmentationGroup nvarchar(max)
  DECLARE @CurrentAction nvarchar(max)
  DECLARE @CurrentMaxDOP int
  DECLARE @CurrentUpdateStatistics nvarchar(max)
  DECLARE @CurrentComment nvarchar(max)
  DECLARE @CurrentExtendedInfo xml
  DECLARE @CurrentDelay datetime

  DECLARE @tmpDatabases TABLE (ID int IDENTITY PRIMARY KEY,
                               DatabaseName nvarchar(max),
                               Completed bit)

  DECLARE @tmpIndexesStatistics TABLE (IxID int IDENTITY,
                                       SchemaID int,
                                       SchemaName nvarchar(max),
                                       ObjectID int,
                                       ObjectName nvarchar(max),
                                       ObjectType nvarchar(max),
                                       IndexID int,
                                       IndexName nvarchar(max),
                                       IndexType int,
                                       StatisticsID int,
                                       StatisticsName nvarchar(max),
                                       PartitionID bigint,
                                       PartitionNumber int,
                                       PartitionCount int,
                                       Selected bit,
                                       Completed bit,
                                       PRIMARY KEY(Selected, Completed, IxID))

  DECLARE @SelectedIndexes TABLE (DatabaseName nvarchar(max),
                                  SchemaName nvarchar(max),
                                  ObjectName nvarchar(max),
                                  IndexName nvarchar(max),
                                  Selected bit)

  DECLARE @Actions TABLE ([Action] nvarchar(max))

  INSERT INTO @Actions([Action]) VALUES('INDEX_REBUILD_ONLINE')
  INSERT INTO @Actions([Action]) VALUES('INDEX_REBUILD_OFFLINE')
  INSERT INTO @Actions([Action]) VALUES('INDEX_REORGANIZE')

  DECLARE @ActionsPreferred TABLE (FragmentationGroup nvarchar(max),
                                   [Priority] int,
                                   [Action] nvarchar(max))

  DECLARE @CurrentActionsAllowed TABLE ([Action] nvarchar(max))

  DECLARE @Error int
  DECLARE @ReturnCode int

  SET @Error = 0
  SET @ReturnCode = 0

  SET @Version = CAST(LEFT(CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max)),CHARINDEX('.',CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max))) - 1) + '.' + REPLACE(RIGHT(CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max)), LEN(CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max))) - CHARINDEX('.',CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max)))),'.','') AS numeric(18,10))

  IF @Version >= 11
  BEGIN
    SELECT @Cluster = cluster_name
    FROM sys.dm_hadr_cluster
  END

  ----------------------------------------------------------------------------------------------------
  --// Log initial information                                                                    //--
  ----------------------------------------------------------------------------------------------------

  SET @StartTime = CONVERT(datetime,CONVERT(nvarchar,GETDATE(),120),120)

  SET @StartMessage = 'DateTime: ' + CONVERT(nvarchar,@StartTime,120) + CHAR(13) + CHAR(10)
  SET @StartMessage = @StartMessage + 'Server: ' + CAST(SERVERPROPERTY('ServerName') AS nvarchar) + CHAR(13) + CHAR(10)
  SET @StartMessage = @StartMessage + 'Version: ' + CAST(SERVERPROPERTY('ProductVersion') AS nvarchar) + CHAR(13) + CHAR(10)
  SET @StartMessage = @StartMessage + 'Edition: ' + CAST(SERVERPROPERTY('Edition') AS nvarchar) + CHAR(13) + CHAR(10)
  SET @StartMessage = @StartMessage + 'Procedure: ' + QUOTENAME(DB_NAME(DB_ID())) + '.' + (SELECT QUOTENAME(schemas.name) FROM sys.schemas schemas INNER JOIN sys.objects objects ON schemas.[schema_id] = objects.[schema_id] WHERE [object_id] = @@PROCID) + '.' + QUOTENAME(OBJECT_NAME(@@PROCID)) + CHAR(13) + CHAR(10)
  SET @StartMessage = @StartMessage + 'Parameters: @Databases = ' + ISNULL('''' + REPLACE(@Databases,'''','''''') + '''','NULL')
  SET @StartMessage = @StartMessage + ', @FragmentationLow = ' + ISNULL('''' + REPLACE(@FragmentationLow,'''','''''') + '''','NULL')
  SET @StartMessage = @StartMessage + ', @FragmentationMedium = ' + ISNULL('''' + REPLACE(@FragmentationMedium,'''','''''') + '''','NULL')
  SET @StartMessage = @StartMessage + ', @FragmentationHigh = ' + ISNULL('''' + REPLACE(@FragmentationHigh,'''','''''') + '''','NULL')
  SET @StartMessage = @StartMessage + ', @FragmentationLevel1 = ' + ISNULL(CAST(@FragmentationLevel1 AS nvarchar),'NULL')
  SET @StartMessage = @StartMessage + ', @FragmentationLevel2 = ' + ISNULL(CAST(@FragmentationLevel2 AS nvarchar),'NULL')
  SET @StartMessage = @StartMessage + ', @PageCountLevel = ' + ISNULL(CAST(@PageCountLevel AS nvarchar),'NULL')
  SET @StartMessage = @StartMessage + ', @SortInTempdb = ' + ISNULL('''' + REPLACE(@SortInTempdb,'''','''''') + '''','NULL')
  SET @StartMessage = @StartMessage + ', @MaxDOP = ' + ISNULL(CAST(@MaxDOP AS nvarchar),'NULL')
  SET @StartMessage = @StartMessage + ', @FillFactor = ' + ISNULL(CAST(@FillFactor AS nvarchar),'NULL')
  SET @StartMessage = @StartMessage + ', @PadIndex = ' + ISNULL('''' + REPLACE(@PadIndex,'''','''''') + '''','NULL')
  SET @StartMessage = @StartMessage + ', @LOBCompaction = ' + ISNULL('''' + REPLACE(@LOBCompaction,'''','''''') + '''','NULL')
  SET @StartMessage = @StartMessage + ', @UpdateStatistics = ' + ISNULL('''' + REPLACE(@UpdateStatistics,'''','''''') + '''','NULL')
  SET @StartMessage = @StartMessage + ', @OnlyModifiedStatistics = ' + ISNULL('''' + REPLACE(@OnlyModifiedStatistics,'''','''''') + '''','NULL')
  SET @StartMessage = @StartMessage + ', @StatisticsSample = ' + ISNULL(CAST(@StatisticsSample AS nvarchar),'NULL')
  SET @StartMessage = @StartMessage + ', @StatisticsResample = ' + ISNULL('''' + REPLACE(@StatisticsResample,'''','''''') + '''','NULL')
  SET @StartMessage = @StartMessage + ', @PartitionLevel = ' + ISNULL('''' + REPLACE(@PartitionLevel,'''','''''') + '''','NULL')
  SET @StartMessage = @StartMessage + ', @TimeLimit = ' + ISNULL(CAST(@TimeLimit AS nvarchar),'NULL')
  SET @StartMessage = @StartMessage + ', @Indexes = ' + ISNULL('''' + REPLACE(@Indexes,'''','''''') + '''','NULL')
  SET @StartMessage = @StartMessage + ', @Delay = ' + ISNULL(CAST(@Delay AS nvarchar),'NULL')
  SET @StartMessage = @StartMessage + ', @LogToTable = ' + ISNULL('''' + REPLACE(@LogToTable,'''','''''') + '''','NULL')
  SET @StartMessage = @StartMessage + ', @Execute = ' + ISNULL('''' + REPLACE(@Execute,'''','''''') + '''','NULL') + CHAR(13) + CHAR(10)
  SET @StartMessage = @StartMessage + 'Source: http://ola.hallengren.com' + CHAR(13) + CHAR(10)
  SET @StartMessage = REPLACE(@StartMessage,'%','%%') + ' '
  RAISERROR(@StartMessage,10,1) WITH NOWAIT

  ----------------------------------------------------------------------------------------------------
  --// Check core requirements                                                                    //--
  ----------------------------------------------------------------------------------------------------

  IF SERVERPROPERTY('EngineEdition') = 5
  BEGIN
    SET @ErrorMessage = 'SQL Azure is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @Error <> 0
  BEGIN
    SET @ReturnCode = @Error
    GOTO Logging
  END

  IF NOT EXISTS (SELECT * FROM sys.objects objects INNER JOIN sys.schemas schemas ON objects.[schema_id] = schemas.[schema_id] WHERE objects.[type] = 'P' AND schemas.[name] = 'dbo' AND objects.[name] = 'CommandExecute')
  BEGIN
    SET @ErrorMessage = 'The stored procedure CommandExecute is missing. Download http://ola.hallengren.com/scripts/CommandExecute.sql.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF EXISTS (SELECT * FROM sys.objects objects INNER JOIN sys.schemas schemas ON objects.[schema_id] = schemas.[schema_id] WHERE objects.[type] = 'P' AND schemas.[name] = 'dbo' AND objects.[name] = 'CommandExecute' AND OBJECT_DEFINITION(objects.[object_id]) NOT LIKE '%@LogToTable%')
  BEGIN
    SET @ErrorMessage = 'The stored procedure CommandExecute needs to be updated. Download http://ola.hallengren.com/scripts/CommandExecute.sql.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF NOT EXISTS (SELECT * FROM sys.objects objects INNER JOIN sys.schemas schemas ON objects.[schema_id] = schemas.[schema_id] WHERE objects.[type] = 'TF' AND schemas.[name] = 'dbo' AND objects.[name] = 'DatabaseSelect')
  BEGIN
    SET @ErrorMessage = 'The function DatabaseSelect is missing. Download http://ola.hallengren.com/scripts/DatabaseSelect.sql.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @LogToTable = 'Y' AND NOT EXISTS (SELECT * FROM sys.objects objects INNER JOIN sys.schemas schemas ON objects.[schema_id] = schemas.[schema_id] WHERE objects.[type] = 'U' AND schemas.[name] = 'dbo' AND objects.[name] = 'CommandLog')
  BEGIN
    SET @ErrorMessage = 'The table CommandLog is missing. Download http://ola.hallengren.com/scripts/CommandLog.sql.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @Error <> 0
  BEGIN
    SET @ReturnCode = @Error
    GOTO Logging
  END

  ----------------------------------------------------------------------------------------------------
  --// Select databases                                                                           //--
  ----------------------------------------------------------------------------------------------------

  IF @Databases IS NULL OR @Databases = ''
  BEGIN
    SET @ErrorMessage = 'The value for parameter @Databases is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  INSERT INTO @tmpDatabases (DatabaseName, Completed)
  SELECT DatabaseName AS DatabaseName,
         0 AS Completed
  FROM dbo.DatabaseSelect (@Databases)
  ORDER BY DatabaseName ASC

  IF @@ERROR <> 0
  BEGIN
    SET @ErrorMessage = 'Error selecting databases.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  ----------------------------------------------------------------------------------------------------
  --// Select indexes                                                                             //--
  ----------------------------------------------------------------------------------------------------

  SET @CurrentIndexList = @Indexes

  WHILE CHARINDEX(', ',@CurrentIndexList) > 0 SET @CurrentIndexList = REPLACE(@CurrentIndexList,', ',',')
  WHILE CHARINDEX(' ,',@CurrentIndexList) > 0 SET @CurrentIndexList = REPLACE(@CurrentIndexList,' ,',',')
  WHILE CHARINDEX(',,',@CurrentIndexList) > 0 SET @CurrentIndexList = REPLACE(@CurrentIndexList,',,',',')

  IF RIGHT(@CurrentIndexList,1) = ',' SET @CurrentIndexList = LEFT(@CurrentIndexList,LEN(@CurrentIndexList) - 1)
  IF LEFT(@CurrentIndexList,1) = ',' SET @CurrentIndexList = RIGHT(@CurrentIndexList,LEN(@CurrentIndexList) - 1)

  SET @CurrentIndexList = LTRIM(RTRIM(@CurrentIndexList))

  WHILE LEN(@CurrentIndexList) > 0
  BEGIN
    SET @CurrentIndexPosition = CHARINDEX(',', @CurrentIndexList)
    IF @CurrentIndexPosition = 0
    BEGIN
      SET @CurrentIndexItem = @CurrentIndexList
      SET @CurrentIndexList = ''
    END
    ELSE
    BEGIN
      SET @CurrentIndexItem = LEFT(@CurrentIndexList, @CurrentIndexPosition - 1)
      SET @CurrentIndexList = RIGHT(@CurrentIndexList, LEN(@CurrentIndexList) - @CurrentIndexPosition)
    END;

    WITH IndexItem01 (IndexItem, Selected) AS (
    SELECT CASE WHEN @CurrentIndexItem LIKE '-%' THEN RIGHT(@CurrentIndexItem,LEN(@CurrentIndexItem) - 1) ELSE @CurrentIndexItem END AS IndexItem,
           CASE WHEN @CurrentIndexItem LIKE '-%' THEN 0 ELSE 1 END AS Selected),
    IndexItem02 (IndexItem, Selected) AS (
    SELECT CASE WHEN IndexItem = 'ALL_INDEXES' THEN '%.%.%.%' ELSE IndexItem END AS IndexItem,
           Selected
    FROM IndexItem01)
    INSERT INTO @SelectedIndexes (DatabaseName, SchemaName, ObjectName, IndexName, Selected)
    SELECT DatabaseName = CASE WHEN PARSENAME(IndexItem,4) IS NULL THEN PARSENAME(IndexItem,3) ELSE PARSENAME(IndexItem,4) END,
           SchemaName = CASE WHEN PARSENAME(IndexItem,4) IS NULL THEN PARSENAME(IndexItem,2) ELSE PARSENAME(IndexItem,3) END,
           ObjectName = CASE WHEN PARSENAME(IndexItem,4) IS NULL THEN PARSENAME(IndexItem,1) ELSE PARSENAME(IndexItem,2) END,
           IndexName = CASE WHEN PARSENAME(IndexItem,4) IS NULL THEN '%' ELSE PARSENAME(IndexItem,1) END,
           Selected
    FROM IndexItem02
  END

  IF EXISTS(SELECT * FROM @SelectedIndexes WHERE DatabaseName IS NULL OR SchemaName IS NULL OR ObjectName IS NULL OR IndexName IS NULL) OR (@Indexes IS NOT NULL AND NOT EXISTS(SELECT * FROM @SelectedIndexes))
  BEGIN
    SET @ErrorMessage = 'Error selecting indexes.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END;

  ----------------------------------------------------------------------------------------------------
  --// Select actions                                                                             //--
  ----------------------------------------------------------------------------------------------------

  WITH FragmentationLow AS
  (
  SELECT CASE WHEN CHARINDEX(',', @FragmentationLow) = 0 THEN @FragmentationLow ELSE SUBSTRING(@FragmentationLow, 1, CHARINDEX(',', @FragmentationLow) - 1) END AS [Action],
         CASE WHEN CHARINDEX(',', @FragmentationLow) = 0 THEN '' ELSE SUBSTRING(@FragmentationLow, CHARINDEX(',', @FragmentationLow) + 1, LEN(@FragmentationLow)) END AS String,
         1 AS [Priority],
         CASE WHEN CHARINDEX(',', @FragmentationLow) = 0 THEN 0 ELSE 1 END [Continue]
  WHERE @FragmentationLow IS NOT NULL
  UNION ALL
  SELECT CASE WHEN CHARINDEX(',', String) = 0 THEN String ELSE SUBSTRING(String, 1, CHARINDEX(',', String) - 1) END AS [Action],
         CASE WHEN CHARINDEX(',', String) = 0 THEN '' ELSE SUBSTRING(String, CHARINDEX(',', String) + 1, LEN(String)) END AS String,
         [Priority] + 1  AS [Priority],
         CASE WHEN CHARINDEX(',', String) = 0 THEN 0 ELSE 1 END [Continue]
  FROM FragmentationLow
  WHERE [Continue] = 1
  ),
  FragmentationMedium AS
  (
  SELECT CASE WHEN CHARINDEX(',', @FragmentationMedium) = 0 THEN @FragmentationMedium ELSE SUBSTRING(@FragmentationMedium, 1, CHARINDEX(',', @FragmentationMedium) - 1) END AS [Action],
         CASE WHEN CHARINDEX(',', @FragmentationMedium) = 0 THEN '' ELSE SUBSTRING(@FragmentationMedium, CHARINDEX(',', @FragmentationMedium) + 1, LEN(@FragmentationMedium)) END AS String,
         1 AS [Priority],
         CASE WHEN CHARINDEX(',', @FragmentationMedium) = 0 THEN 0 ELSE 1 END [Continue]
  WHERE @FragmentationMedium IS NOT NULL
  UNION ALL
  SELECT CASE WHEN CHARINDEX(',', String) = 0 THEN String ELSE SUBSTRING(String, 1, CHARINDEX(',', String) - 1) END AS [Action],
         CASE WHEN CHARINDEX(',', String) = 0 THEN '' ELSE SUBSTRING(String, CHARINDEX(',', String) + 1, LEN(String)) END AS String,
         [Priority] + 1  AS [Priority],
         CASE WHEN CHARINDEX(',', String) = 0 THEN 0 ELSE 1 END [Continue]
  FROM FragmentationMedium
  WHERE [Continue] = 1
  ),
  FragmentationHigh AS
  (
  SELECT CASE WHEN CHARINDEX(',', @FragmentationHigh) = 0 THEN @FragmentationHigh ELSE SUBSTRING(@FragmentationHigh, 1, CHARINDEX(',', @FragmentationHigh) - 1) END AS [Action],
         CASE WHEN CHARINDEX(',', @FragmentationHigh) = 0 THEN '' ELSE SUBSTRING(@FragmentationHigh, CHARINDEX(',', @FragmentationHigh) + 1, LEN(@FragmentationHigh)) END AS String,
         1 AS [Priority],
         CASE WHEN CHARINDEX(',', @FragmentationHigh) = 0 THEN 0 ELSE 1 END [Continue]
  WHERE @FragmentationHigh IS NOT NULL
  UNION ALL
  SELECT CASE WHEN CHARINDEX(',', String) = 0 THEN String ELSE SUBSTRING(String, 1, CHARINDEX(',', String) - 1) END AS [Action],
         CASE WHEN CHARINDEX(',', String) = 0 THEN '' ELSE SUBSTRING(String, CHARINDEX(',', String) + 1, LEN(String)) END AS String,
         [Priority] + 1  AS [Priority],
         CASE WHEN CHARINDEX(',', String) = 0 THEN 0 ELSE 1 END [Continue]
  FROM FragmentationHigh
  WHERE [Continue] = 1
  )
  INSERT INTO @ActionsPreferred(FragmentationGroup, [Priority], [Action])
  SELECT 'Low' AS FragmentationGroup, [Priority], [Action]
  FROM FragmentationLow
  UNION
  SELECT 'Medium' AS FragmentationGroup, [Priority], [Action]
  FROM FragmentationMedium
  UNION
  SELECT 'High' AS FragmentationGroup, [Priority], [Action]
  FROM FragmentationHigh

  ----------------------------------------------------------------------------------------------------
  --// Check input parameters                                                                     //--
  ----------------------------------------------------------------------------------------------------

  IF EXISTS (SELECT [Action] FROM @ActionsPreferred WHERE FragmentationGroup = 'Low' AND [Action] NOT IN(SELECT * FROM @Actions))
  OR EXISTS(SELECT * FROM @ActionsPreferred WHERE FragmentationGroup = 'Low' GROUP BY [Action] HAVING COUNT(*) > 1)
  BEGIN
    SET @ErrorMessage = 'The value for parameter @FragmentationLow is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF EXISTS (SELECT [Action] FROM @ActionsPreferred WHERE FragmentationGroup = 'Medium' AND [Action] NOT IN(SELECT * FROM @Actions))
  OR EXISTS(SELECT * FROM @ActionsPreferred WHERE FragmentationGroup = 'Medium' GROUP BY [Action] HAVING COUNT(*) > 1)
  BEGIN
    SET @ErrorMessage = 'The value for parameter @FragmentationMedium is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF EXISTS (SELECT [Action] FROM @ActionsPreferred WHERE FragmentationGroup = 'High' AND [Action] NOT IN(SELECT * FROM @Actions))
  OR EXISTS(SELECT * FROM @ActionsPreferred WHERE FragmentationGroup = 'High' GROUP BY [Action] HAVING COUNT(*) > 1)
  BEGIN
    SET @ErrorMessage = 'The value for parameter @FragmentationHigh is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @FragmentationLevel1 <= 0 OR @FragmentationLevel1 >= 100 OR @FragmentationLevel1 >= @FragmentationLevel2 OR @FragmentationLevel1 IS NULL
  BEGIN
    SET @ErrorMessage = 'The value for parameter @FragmentationLevel1 is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @FragmentationLevel2 <= 0 OR @FragmentationLevel2 >= 100 OR @FragmentationLevel2 <= @FragmentationLevel1 OR @FragmentationLevel2 IS NULL
  BEGIN
    SET @ErrorMessage = 'The value for parameter @FragmentationLevel2 is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @PageCountLevel < 0 OR @PageCountLevel IS NULL
  BEGIN
    SET @ErrorMessage = 'The value for parameter @PageCountLevel is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @SortInTempdb NOT IN('Y','N') OR @SortInTempdb IS NULL
  BEGIN
    SET @ErrorMessage = 'The value for parameter @SortInTempdb is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @MaxDOP < 0 OR @MaxDOP > 64 OR @MaxDOP > (SELECT cpu_count FROM sys.dm_os_sys_info) OR (@MaxDOP > 1 AND SERVERPROPERTY('EngineEdition') <> 3)
  BEGIN
    SET @ErrorMessage = 'The value for parameter @MaxDOP is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @MaxDOP > 1 AND SERVERPROPERTY('EngineEdition') <> 3
  BEGIN
    SET @ErrorMessage = 'Parallel index operations are only supported in Enterprise, Developer and Datacenter Edition.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @FillFactor <= 0 OR @FillFactor > 100
  BEGIN
    SET @ErrorMessage = 'The value for parameter @FillFactor is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @PadIndex NOT IN('Y','N')
  BEGIN
    SET @ErrorMessage = 'The value for parameter @PadIndex is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @LOBCompaction NOT IN('Y','N') OR @LOBCompaction IS NULL
  BEGIN
    SET @ErrorMessage = 'The value for parameter @LOBCompaction is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @UpdateStatistics NOT IN('ALL','COLUMNS','INDEX')
  BEGIN
    SET @ErrorMessage = 'The value for parameter @UpdateStatistics is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @OnlyModifiedStatistics NOT IN('Y','N') OR @OnlyModifiedStatistics IS NULL
  BEGIN
    SET @ErrorMessage = 'The value for parameter @OnlyModifiedStatistics is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @StatisticsSample <= 0 OR @StatisticsSample  > 100
  BEGIN
    SET @ErrorMessage = 'The value for parameter @StatisticsSample is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @StatisticsResample NOT IN('Y','N') OR @StatisticsResample IS NULL OR (@StatisticsResample = 'Y' AND @StatisticsSample IS NOT NULL)
  BEGIN
    SET @ErrorMessage = 'The value for parameter @StatisticsResample is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @PartitionLevel NOT IN('Y','N') OR @PartitionLevel IS NULL OR (@PartitionLevel = 'Y' AND SERVERPROPERTY('EngineEdition') <> 3)
  BEGIN
    SET @ErrorMessage = 'The value for parameter @PartitionLevel is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @PartitionLevel = 'Y' AND SERVERPROPERTY('EngineEdition') <> 3
  BEGIN
    SET @ErrorMessage = 'Table partitioning is only supported in Enterprise, Developer and Datacenter Edition.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @TimeLimit < 0
  BEGIN
    SET @ErrorMessage = 'The value for parameter @TimeLimit is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @Delay < 0
  BEGIN
    SET @ErrorMessage = 'The value for parameter @Delay is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @LogToTable NOT IN('Y','N') OR @LogToTable IS NULL
  BEGIN
    SET @ErrorMessage = 'The value for parameter @LogToTable is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @Execute NOT IN('Y','N') OR @Execute IS NULL
  BEGIN
    SET @ErrorMessage = 'The value for parameter @Execute is not supported.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @Error = @@ERROR
  END

  IF @Error <> 0
  BEGIN
    SET @ErrorMessage = 'The documentation is available at http://ola.hallengren.com/sql-server-index-and-statistics-maintenance.html.' + CHAR(13) + CHAR(10) + ' '
    RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
    SET @ReturnCode = @Error
    GOTO Logging
  END

  ----------------------------------------------------------------------------------------------------
  --// Execute commands                                                                           //--
  ----------------------------------------------------------------------------------------------------

  WHILE EXISTS (SELECT * FROM @tmpDatabases WHERE Completed = 0)
  BEGIN

    SELECT TOP 1 @CurrentID = ID,
                 @CurrentDatabaseName = DatabaseName
    FROM @tmpDatabases
    WHERE Completed = 0
    ORDER BY ID ASC

    SET @CurrentDatabaseID = DB_ID(@CurrentDatabaseName)

    IF EXISTS (SELECT * FROM sys.database_recovery_status WHERE database_id = @CurrentDatabaseID AND database_guid IS NOT NULL)
    BEGIN
      SET @CurrentIsDatabaseAccessible = 1
    END
    ELSE
    BEGIN
      SET @CurrentIsDatabaseAccessible = 0
    END

    IF @Version >= 11 AND @Cluster IS NOT NULL
    BEGIN
      SELECT @CurrentAvailabilityGroup = availability_groups.name,
             @CurrentRole = dm_hadr_availability_replica_states.role_desc
      FROM sys.databases databases
      INNER JOIN sys.availability_databases_cluster availability_databases_cluster ON databases.group_database_id = availability_databases_cluster.group_database_id
      INNER JOIN sys.availability_groups availability_groups ON availability_databases_cluster.group_id = availability_groups.group_id
      INNER JOIN sys.dm_hadr_availability_replica_states dm_hadr_availability_replica_states ON availability_groups.group_id = dm_hadr_availability_replica_states.group_id AND databases.replica_id = dm_hadr_availability_replica_states.replica_id
      WHERE databases.name = @CurrentDatabaseName
    END

    -- Set database message
    SET @DatabaseMessage = 'DateTime: ' + CONVERT(nvarchar,GETDATE(),120) + CHAR(13) + CHAR(10)
    SET @DatabaseMessage = @DatabaseMessage + 'Database: ' + QUOTENAME(@CurrentDatabaseName) + CHAR(13) + CHAR(10)
    SET @DatabaseMessage = @DatabaseMessage + 'Status: ' + CAST(DATABASEPROPERTYEX(@CurrentDatabaseName,'Status') AS nvarchar) + CHAR(13) + CHAR(10)
    SET @DatabaseMessage = @DatabaseMessage + 'Standby: ' + CASE WHEN DATABASEPROPERTYEX(@CurrentDatabaseName,'IsInStandBy') = 1 THEN 'Yes' ELSE 'No' END + CHAR(13) + CHAR(10)
    SET @DatabaseMessage = @DatabaseMessage + 'Updateability: ' + CAST(DATABASEPROPERTYEX(@CurrentDatabaseName,'Updateability') AS nvarchar) + CHAR(13) + CHAR(10)
    SET @DatabaseMessage = @DatabaseMessage + 'User access: ' + CAST(DATABASEPROPERTYEX(@CurrentDatabaseName,'UserAccess') AS nvarchar) + CHAR(13) + CHAR(10)
    SET @DatabaseMessage = @DatabaseMessage + 'Is accessible: ' + CASE WHEN @CurrentIsDatabaseAccessible = 1 THEN 'Yes' ELSE 'No' END + CHAR(13) + CHAR(10)
    SET @DatabaseMessage = @DatabaseMessage + 'Recovery model: ' + CAST(DATABASEPROPERTYEX(@CurrentDatabaseName,'Recovery') AS nvarchar) + CHAR(13) + CHAR(10)
    IF @CurrentAvailabilityGroup IS NOT NULL SET @DatabaseMessage = @DatabaseMessage + 'Availability Group: ' + @CurrentAvailabilityGroup + CHAR(13) + CHAR(10)
    IF @CurrentAvailabilityGroup IS NOT NULL SET @DatabaseMessage = @DatabaseMessage + 'Availability Group role: ' + @CurrentRole + CHAR(13) + CHAR(10)
    SET @DatabaseMessage = REPLACE(@DatabaseMessage,'%','%%') + ' '
    RAISERROR(@DatabaseMessage,10,1) WITH NOWAIT

    IF DATABASEPROPERTYEX(@CurrentDatabaseName,'Status') = 'ONLINE'
    AND NOT (DATABASEPROPERTYEX(@CurrentDatabaseName,'UserAccess') = 'SINGLE_USER' AND @CurrentIsDatabaseAccessible = 0)
    AND DATABASEPROPERTYEX(@CurrentDatabaseName,'Updateability') = 'READ_WRITE'
    BEGIN

      -- Select indexes in the current database
      IF (EXISTS(SELECT * FROM @ActionsPreferred) OR @UpdateStatistics IS NOT NULL) AND (GETDATE() < DATEADD(ss,@TimeLimit,@StartTime) OR @TimeLimit IS NULL)
      BEGIN
        SET @CurrentCommand01 = 'SELECT SchemaID, SchemaName, ObjectID, ObjectName, ObjectType, IndexID, IndexName, IndexType, StatisticsID, StatisticsName, PartitionID, PartitionNumber, PartitionCount, Selected, Completed FROM ('

        IF EXISTS(SELECT * FROM @ActionsPreferred) OR @UpdateStatistics IN('ALL','INDEX')
        BEGIN
          SET @CurrentCommand01 = @CurrentCommand01 + 'SELECT schemas.[schema_id] AS SchemaID, schemas.[name] AS SchemaName, objects.[object_id] AS ObjectID, objects.[name] AS ObjectName, RTRIM(objects.[type]) AS ObjectType, indexes.index_id AS IndexID, indexes.[name] AS IndexName, indexes.[type] AS IndexType, stats.stats_id AS StatisticsID, stats.name AS StatisticsName'
          IF @PartitionLevel = 'Y' SET @CurrentCommand01 = @CurrentCommand01 + ', partitions.partition_id AS PartitionID, partitions.partition_number AS PartitionNumber, IndexPartitions.partition_count AS PartitionCount'
          IF @PartitionLevel = 'N' SET @CurrentCommand01 = @CurrentCommand01 + ', NULL AS PartitionID, NULL AS PartitionNumber, NULL AS PartitionCount'
          SET @CurrentCommand01 = @CurrentCommand01 + ', 0 AS Selected, 0 AS Completed FROM ' + QUOTENAME(@CurrentDatabaseName) + '.sys.indexes indexes INNER JOIN ' + QUOTENAME(@CurrentDatabaseName) + '.sys.objects objects ON indexes.[object_id] = objects.[object_id] INNER JOIN ' + QUOTENAME(@CurrentDatabaseName) + '.sys.schemas schemas ON objects.[schema_id] = schemas.[schema_id] LEFT OUTER JOIN ' + QUOTENAME(@CurrentDatabaseName) + '.sys.stats stats ON indexes.[object_id] = stats.[object_id] AND indexes.[index_id] = stats.[stats_id]'
          IF @PartitionLevel = 'Y' SET @CurrentCommand01 = @CurrentCommand01 + ' LEFT OUTER JOIN ' + QUOTENAME(@CurrentDatabaseName) + '.sys.partitions partitions ON indexes.[object_id] = partitions.[object_id] AND indexes.index_id = partitions.index_id LEFT OUTER JOIN (SELECT partitions.[object_id], partitions.index_id, COUNT(*) AS partition_count FROM ' + QUOTENAME(@CurrentDatabaseName) + '.sys.partitions partitions GROUP BY partitions.[object_id], partitions.index_id) IndexPartitions ON partitions.[object_id] = IndexPartitions.[object_id] AND partitions.[index_id] = IndexPartitions.[index_id]'
          IF @PartitionLevel = 'Y' SET @CurrentCommand01 = @CurrentCommand01 + ' LEFT OUTER JOIN ' + QUOTENAME(@CurrentDatabaseName) + '.sys.dm_db_partition_stats dm_db_partition_stats ON indexes.[object_id] = dm_db_partition_stats.[object_id] AND indexes.[index_id] = dm_db_partition_stats.[index_id] AND partitions.partition_id = dm_db_partition_stats.partition_id'
          IF @PartitionLevel = 'N' SET @CurrentCommand01 = @CurrentCommand01 + ' LEFT OUTER JOIN (SELECT dm_db_partition_stats.[object_id], dm_db_partition_stats.[index_id], SUM(dm_db_partition_stats.in_row_data_page_count) AS in_row_data_page_count FROM ' + QUOTENAME(@CurrentDatabaseName) + '.sys.dm_db_partition_stats dm_db_partition_stats GROUP BY dm_db_partition_stats.[object_id], dm_db_partition_stats.[index_id]) dm_db_partition_stats ON indexes.[object_id] = dm_db_partition_stats.[object_id] AND indexes.[index_id] = dm_db_partition_stats.[index_id]'
          SET @CurrentCommand01 = @CurrentCommand01 + ' WHERE objects.[type] IN(''U'',''V'') AND objects.is_ms_shipped = 0 AND indexes.[type] IN(1,2,3,4) AND indexes.is_disabled = 0 AND indexes.is_hypothetical = 0'
          IF (@UpdateStatistics NOT IN('ALL','INDEX') OR @UpdateStatistics IS NULL) AND @PageCountLevel > 0 SET @CurrentCommand01 = @CurrentCommand01 + ' AND (dm_db_partition_stats.in_row_data_page_count >= @ParamPageCountLevel OR dm_db_partition_stats.in_row_data_page_count IS NULL)'
          IF NOT EXISTS(SELECT * FROM @ActionsPreferred) SET @CurrentCommand01 = @CurrentCommand01 + ' AND stats.stats_id IS NOT NULL'
        END

        IF (EXISTS(SELECT * FROM @ActionsPreferred) AND @UpdateStatistics = 'COLUMNS') OR @UpdateStatistics = 'ALL' SET @CurrentCommand01 = @CurrentCommand01 + ' UNION '

        IF @UpdateStatistics IN('ALL','COLUMNS') SET @CurrentCommand01 = @CurrentCommand01 + 'SELECT schemas.[schema_id] AS SchemaID, schemas.[name] AS SchemaName, objects.[object_id] AS ObjectID, objects.[name] AS ObjectName, RTRIM(objects.[type]) AS ObjectType, NULL AS IndexID, NULL AS IndexName, NULL AS IndexType, stats.stats_id AS StatisticsID, stats.name AS StatisticsName, NULL AS PartitionID, NULL AS PartitionNumber, NULL AS PartitionCount, 0 AS Selected, 0 AS Completed FROM ' + QUOTENAME(@CurrentDatabaseName) + '.sys.stats stats INNER JOIN ' + QUOTENAME(@CurrentDatabaseName) + '.sys.objects objects ON stats.[object_id] = objects.[object_id] INNER JOIN ' + QUOTENAME(@CurrentDatabaseName) + '.sys.schemas schemas ON objects.[schema_id] = schemas.[schema_id] WHERE objects.[type] IN(''U'',''V'') AND objects.is_ms_shipped = 0 AND NOT EXISTS(SELECT * FROM ' + QUOTENAME(@CurrentDatabaseName) + '.sys.indexes indexes WHERE indexes.[object_id] = stats.[object_id] AND indexes.index_id = stats.stats_id)'

        SET @CurrentCommand01 = @CurrentCommand01 + ') IndexesStatistics ORDER BY SchemaName ASC, ObjectName ASC'
        IF (EXISTS(SELECT * FROM @ActionsPreferred) AND @UpdateStatistics = 'COLUMNS') OR @UpdateStatistics = 'ALL' SET @CurrentCommand01 = @CurrentCommand01 + ', CASE WHEN IndexType IS NULL THEN 1 ELSE 0 END ASC'
        IF EXISTS(SELECT * FROM @ActionsPreferred) OR @UpdateStatistics IN('ALL','INDEX') SET @CurrentCommand01 = @CurrentCommand01 + ', IndexType ASC, IndexName ASC'
        IF @UpdateStatistics IN('ALL','COLUMNS') SET @CurrentCommand01 = @CurrentCommand01 + ', StatisticsName ASC'
        IF @PartitionLevel = 'Y' SET @CurrentCommand01 = @CurrentCommand01 + ', PartitionNumber ASC'

        INSERT INTO @tmpIndexesStatistics (SchemaID, SchemaName, ObjectID, ObjectName, ObjectType, IndexID, IndexName, IndexType, StatisticsID, StatisticsName, PartitionID, PartitionNumber, PartitionCount, Selected, Completed)
        EXECUTE sp_executesql @statement = @CurrentCommand01, @params = N'@ParamPageCountLevel int', @ParamPageCountLevel = @PageCountLevel
        SET @Error = @@ERROR
        IF @Error <> 0 SET @ReturnCode = @Error
        IF @Error = 1222
        BEGIN
          SET @ErrorMessage = 'The system tables are locked in the database ' + QUOTENAME(@CurrentDatabaseName) + '.' + CHAR(13) + CHAR(10) + ' '
          SET @ErrorMessage = REPLACE(@ErrorMessage,'%','%%')
          RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
        END
      END

      IF @Indexes IS NULL
      BEGIN
        UPDATE tmpIndexesStatistics
        SET tmpIndexesStatistics.Selected = 1
        FROM @tmpIndexesStatistics tmpIndexesStatistics
      END
      ELSE
      BEGIN
        UPDATE tmpIndexesStatistics
        SET tmpIndexesStatistics.Selected = SelectedIndexes.Selected
        FROM @tmpIndexesStatistics tmpIndexesStatistics
        INNER JOIN @SelectedIndexes SelectedIndexes
        ON @CurrentDatabaseName LIKE REPLACE(SelectedIndexes.DatabaseName,'_','[_]') AND tmpIndexesStatistics.SchemaName LIKE REPLACE(SelectedIndexes.SchemaName,'_','[_]') AND tmpIndexesStatistics.ObjectName LIKE REPLACE(SelectedIndexes.ObjectName,'_','[_]') AND COALESCE(tmpIndexesStatistics.IndexName,tmpIndexesStatistics.StatisticsName) LIKE REPLACE(SelectedIndexes.IndexName,'_','[_]')
        WHERE SelectedIndexes.Selected = 1

        UPDATE tmpIndexesStatistics
        SET tmpIndexesStatistics.Selected = SelectedIndexes.Selected
        FROM @tmpIndexesStatistics tmpIndexesStatistics
        INNER JOIN @SelectedIndexes SelectedIndexes
        ON @CurrentDatabaseName LIKE REPLACE(SelectedIndexes.DatabaseName,'_','[_]') AND tmpIndexesStatistics.SchemaName LIKE REPLACE(SelectedIndexes.SchemaName,'_','[_]') AND tmpIndexesStatistics.ObjectName LIKE REPLACE(SelectedIndexes.ObjectName,'_','[_]') AND COALESCE(tmpIndexesStatistics.IndexName,tmpIndexesStatistics.StatisticsName) LIKE REPLACE(SelectedIndexes.IndexName,'_','[_]')
        WHERE SelectedIndexes.Selected = 0
      END

      WHILE EXISTS (SELECT * FROM @tmpIndexesStatistics WHERE Selected = 1 AND Completed = 0 AND (GETDATE() < DATEADD(ss,@TimeLimit,@StartTime) OR @TimeLimit IS NULL))
      BEGIN

        SELECT TOP 1 @CurrentIxID = IxID,
                     @CurrentSchemaID = SchemaID,
                     @CurrentSchemaName = SchemaName,
                     @CurrentObjectID = ObjectID,
                     @CurrentObjectName = ObjectName,
                     @CurrentObjectType = ObjectType,
                     @CurrentIndexID = IndexID,
                     @CurrentIndexName = IndexName,
                     @CurrentIndexType = IndexType,
                     @CurrentStatisticsID = StatisticsID,
                     @CurrentStatisticsName = StatisticsName,
                     @CurrentPartitionID = PartitionID,
                     @CurrentPartitionNumber = PartitionNumber,
                     @CurrentPartitionCount = PartitionCount
        FROM @tmpIndexesStatistics
        WHERE Selected = 1
        AND Completed = 0
        ORDER BY IxID ASC

        -- Is the index a partition?
        IF @CurrentPartitionNumber IS NULL OR @CurrentPartitionCount = 1 BEGIN SET @CurrentIsPartition = 0 END ELSE BEGIN SET @CurrentIsPartition = 1 END

        -- Does the index exist?
        IF @CurrentIndexID IS NOT NULL AND EXISTS(SELECT * FROM @ActionsPreferred)
        BEGIN
          IF @CurrentIsPartition = 0 SET @CurrentCommand02 = 'IF EXISTS(SELECT * FROM ' + QUOTENAME(@CurrentDatabaseName) + '.sys.indexes indexes INNER JOIN ' + QUOTENAME(@CurrentDatabaseName) + '.sys.objects objects ON indexes.[object_id] = objects.[object_id] INNER JOIN ' + QUOTENAME(@CurrentDatabaseName) + '.sys.schemas schemas ON objects.[schema_id] = schemas.[schema_id] WHERE objects.[type] IN(''U'',''V'') AND objects.is_ms_shipped = 0 AND indexes.[type] IN(1,2,3,4) AND indexes.is_disabled = 0 AND indexes.is_hypothetical = 0 AND schemas.[schema_id] = @ParamSchemaID AND schemas.[name] = @ParamSchemaName AND objects.[object_id] = @ParamObjectID AND objects.[name] = @ParamObjectName AND objects.[type] = @ParamObjectType AND indexes.index_id = @ParamIndexID AND indexes.[name] = @ParamIndexName AND indexes.[type] = @ParamIndexType) BEGIN SET @ParamIndexExists = 1 END'
          IF @CurrentIsPartition = 1 SET @CurrentCommand02 = 'IF EXISTS(SELECT * FROM ' + QUOTENAME(@CurrentDatabaseName) + '.sys.indexes indexes INNER JOIN ' + QUOTENAME(@CurrentDatabaseName) + '.sys.objects objects ON indexes.[object_id] = objects.[object_id] INNER JOIN ' + QUOTENAME(@CurrentDatabaseName) + '.sys.schemas schemas ON objects.[schema_id] = schemas.[schema_id] INNER JOIN ' + QUOTENAME(@CurrentDatabaseName) + '.sys.partitions partitions ON indexes.[object_id] = partitions.[object_id] AND indexes.index_id = partitions.index_id WHERE objects.[type] IN(''U'',''V'') AND objects.is_ms_shipped = 0 AND indexes.[type] IN(1,2,3,4) AND indexes.is_disabled = 0 AND indexes.is_hypothetical = 0 AND schemas.[schema_id] = @ParamSchemaID AND schemas.[name] = @ParamSchemaName AND objects.[object_id] = @ParamObjectID AND objects.[name] = @ParamObjectName AND objects.[type] = @ParamObjectType AND indexes.index_id = @ParamIndexID AND indexes.[name] = @ParamIndexName AND indexes.[type] = @ParamIndexType AND partitions.partition_id = @ParamPartitionID AND partitions.partition_number = @ParamPartitionNumber) BEGIN SET @ParamIndexExists = 1 END'

          EXECUTE sp_executesql @statement = @CurrentCommand02, @params = N'@ParamSchemaID int, @ParamSchemaName sysname, @ParamObjectID int, @ParamObjectName sysname, @ParamObjectType sysname, @ParamIndexID int, @ParamIndexName sysname, @ParamIndexType int, @ParamPartitionID bigint, @ParamPartitionNumber int, @ParamIndexExists bit OUTPUT', @ParamSchemaID = @CurrentSchemaID, @ParamSchemaName = @CurrentSchemaName, @ParamObjectID = @CurrentObjectID, @ParamObjectName = @CurrentObjectName, @ParamObjectType = @CurrentObjectType, @ParamIndexID = @CurrentIndexID, @ParamIndexName = @CurrentIndexName, @ParamIndexType = @CurrentIndexType, @ParamPartitionID = @CurrentPartitionID, @ParamPartitionNumber = @CurrentPartitionNumber, @ParamIndexExists = @CurrentIndexExists OUTPUT
          SET @Error = @@ERROR
          IF @Error = 0 AND @CurrentIndexExists IS NULL SET @CurrentIndexExists = 0
          IF @Error <> 0
          BEGIN
            SET @ReturnCode = @Error
            GOTO NoAction
          END
          IF @CurrentIndexExists = 0 GOTO NoAction
        END

        -- Does the statistics exist?
        IF @CurrentStatisticsID IS NOT NULL AND @UpdateStatistics IS NOT NULL
        BEGIN
          SET @CurrentCommand03 = 'IF EXISTS(SELECT * FROM ' + QUOTENAME(@CurrentDatabaseName) + '.sys.stats stats INNER JOIN ' + QUOTENAME(@CurrentDatabaseName) + '.sys.objects objects ON stats.[object_id] = objects.[object_id] INNER JOIN ' + QUOTENAME(@CurrentDatabaseName) + '.sys.schemas schemas ON objects.[schema_id] = schemas.[schema_id] WHERE objects.[type] IN(''U'',''V'') AND objects.is_ms_shipped = 0 AND schemas.[schema_id] = @ParamSchemaID AND schemas.[name] = @ParamSchemaName AND objects.[object_id] = @ParamObjectID AND objects.[name] = @ParamObjectName AND objects.[type] = @ParamObjectType AND stats.stats_id = @ParamStatisticsID AND stats.[name] = @ParamStatisticsName) BEGIN SET @ParamStatisticsExists = 1 END'

          EXECUTE sp_executesql @statement = @CurrentCommand03, @params = N'@ParamSchemaID int, @ParamSchemaName sysname, @ParamObjectID int, @ParamObjectName sysname, @ParamObjectType sysname, @ParamStatisticsID int, @ParamStatisticsName sysname, @ParamStatisticsExists bit OUTPUT', @ParamSchemaID = @CurrentSchemaID, @ParamSchemaName = @CurrentSchemaName, @ParamObjectID = @CurrentObjectID, @ParamObjectName = @CurrentObjectName, @ParamObjectType = @CurrentObjectType, @ParamStatisticsID = @CurrentStatisticsID, @ParamStatisticsName = @CurrentStatisticsName, @ParamStatisticsExists = @CurrentStatisticsExists OUTPUT
          SET @Error = @@ERROR
          IF @Error = 0 AND @CurrentStatisticsExists IS NULL SET @CurrentStatisticsExists = 0
          IF @Error <> 0
          BEGIN
            SET @ReturnCode = @Error
            GOTO NoAction
          END
          IF @CurrentStatisticsExists = 0 GOTO NoAction
        END

        -- Is one of the columns in the index an image, text or ntext data type?
        IF @CurrentIndexID IS NOT NULL AND @CurrentIndexType = 1 AND EXISTS(SELECT * FROM @ActionsPreferred)
        BEGIN
          SET @CurrentCommand04 = 'IF EXISTS(SELECT * FROM ' + QUOTENAME(@CurrentDatabaseName) + '.sys.columns columns INNER JOIN ' + QUOTENAME(@CurrentDatabaseName) + '.sys.types types ON columns.system_type_id = types.user_type_id WHERE columns.[object_id] = @ParamObjectID AND types.name IN(''image'',''text'',''ntext'')) BEGIN SET @ParamIsImageText = 1 END'

          EXECUTE sp_executesql @statement = @CurrentCommand04, @params = N'@ParamObjectID int, @ParamIndexID int, @ParamIsImageText bit OUTPUT', @ParamObjectID = @CurrentObjectID, @ParamIndexID = @CurrentIndexID, @ParamIsImageText = @CurrentIsImageText OUTPUT
          SET @Error = @@ERROR
          IF @Error = 0 AND @CurrentIsImageText IS NULL SET @CurrentIsImageText = 0
          IF @Error <> 0
          BEGIN
            SET @ReturnCode = @Error
            GOTO NoAction
          END
        END

        -- Is one of the columns in the index an xml, varchar(max), nvarchar(max), varbinary(max) or large CLR data type?
        IF @CurrentIndexID IS NOT NULL AND @CurrentIndexType IN(1,2) AND EXISTS(SELECT * FROM @ActionsPreferred)
        BEGIN
          IF @CurrentIndexType = 1 SET @CurrentCommand05 = 'IF EXISTS(SELECT * FROM ' + QUOTENAME(@CurrentDatabaseName) + '.sys.columns columns INNER JOIN ' + QUOTENAME(@CurrentDatabaseName) + '.sys.types types ON columns.system_type_id = types.user_type_id OR (columns.user_type_id = types.user_type_id AND types.is_assembly_type = 1) WHERE columns.[object_id] = @ParamObjectID AND (types.name IN(''xml'') OR (types.name IN(''varchar'',''nvarchar'',''varbinary'') AND columns.max_length = -1) OR (types.is_assembly_type = 1 AND columns.max_length = -1))) BEGIN SET @ParamIsNewLOB = 1 END'
          IF @CurrentIndexType = 2 SET @CurrentCommand05 = 'IF EXISTS(SELECT * FROM ' + QUOTENAME(@CurrentDatabaseName) + '.sys.index_columns index_columns INNER JOIN ' + QUOTENAME(@CurrentDatabaseName) + '.sys.columns columns ON index_columns.[object_id] = columns.[object_id] AND index_columns.column_id = columns.column_id INNER JOIN ' + QUOTENAME(@CurrentDatabaseName) + '.sys.types types ON columns.system_type_id = types.user_type_id OR (columns.user_type_id = types.user_type_id AND types.is_assembly_type = 1) WHERE index_columns.[object_id] = @ParamObjectID AND index_columns.index_id = @ParamIndexID AND (types.[name] IN(''xml'') OR (types.[name] IN(''varchar'',''nvarchar'',''varbinary'') AND columns.max_length = -1) OR (types.is_assembly_type = 1 AND columns.max_length = -1))) BEGIN SET @ParamIsNewLOB = 1 END'

          EXECUTE sp_executesql @statement = @CurrentCommand05, @params = N'@ParamObjectID int, @ParamIndexID int, @ParamIsNewLOB bit OUTPUT', @ParamObjectID = @CurrentObjectID, @ParamIndexID = @CurrentIndexID, @ParamIsNewLOB = @CurrentIsNewLOB OUTPUT
          SET @Error = @@ERROR
          IF @Error = 0 AND @CurrentIsNewLOB IS NULL SET @CurrentIsNewLOB = 0
          IF @Error <> 0
          BEGIN
            SET @ReturnCode = @Error
            GOTO NoAction
          END
        END

        -- Is one of the columns in the index a file stream column?
        IF @CurrentIndexID IS NOT NULL AND @CurrentIndexType = 1 AND EXISTS(SELECT * FROM @ActionsPreferred)
        BEGIN
          SET @CurrentCommand06 = 'IF EXISTS(SELECT * FROM ' + QUOTENAME(@CurrentDatabaseName) + '.sys.columns columns WHERE columns.[object_id] = @ParamObjectID  AND columns.is_filestream = 1) BEGIN SET @ParamIsFileStream = 1 END'

          EXECUTE sp_executesql @statement = @CurrentCommand06, @params = N'@ParamObjectID int, @ParamIndexID int, @ParamIsFileStream bit OUTPUT', @ParamObjectID = @CurrentObjectID, @ParamIndexID = @CurrentIndexID, @ParamIsFileStream = @CurrentIsFileStream OUTPUT
          SET @Error = @@ERROR
          IF @Error = 0 AND @CurrentIsFileStream IS NULL SET @CurrentIsFileStream = 0
          IF @Error <> 0
          BEGIN
            SET @ReturnCode = @Error
            GOTO NoAction
          END
        END

        -- Is Allow_Page_Locks set to On?
        IF @CurrentIndexID IS NOT NULL AND EXISTS(SELECT * FROM @ActionsPreferred)
        BEGIN
          SET @CurrentCommand07 = 'IF EXISTS(SELECT * FROM ' + QUOTENAME(@CurrentDatabaseName) + '.sys.indexes indexes WHERE indexes.[object_id] = @ParamObjectID AND indexes.[index_id] = @ParamIndexID AND indexes.[allow_page_locks] = 1) BEGIN SET @ParamAllowPageLocks = 1 END'

          EXECUTE sp_executesql @statement = @CurrentCommand07, @params = N'@ParamObjectID int, @ParamIndexID int, @ParamAllowPageLocks bit OUTPUT', @ParamObjectID = @CurrentObjectID, @ParamIndexID = @CurrentIndexID, @ParamAllowPageLocks = @CurrentAllowPageLocks OUTPUT
          SET @Error = @@ERROR
          IF @Error = 0 AND @CurrentAllowPageLocks IS NULL SET @CurrentAllowPageLocks = 0
          IF @Error <> 0
          BEGIN
            SET @ReturnCode = @Error
            GOTO NoAction
          END
        END

        -- Is No_Recompute set to On?
        IF @CurrentStatisticsID IS NOT NULL AND @UpdateStatistics IS NOT NULL
        BEGIN
          SET @CurrentCommand08 = 'IF EXISTS(SELECT * FROM ' + QUOTENAME(@CurrentDatabaseName) + '.sys.stats stats WHERE stats.[object_id] = @ParamObjectID AND stats.[stats_id] = @ParamStatisticsID AND stats.[no_recompute] = 1) BEGIN SET @ParamNoRecompute = 1 END'

          EXECUTE sp_executesql @statement = @CurrentCommand08, @params = N'@ParamObjectID int, @ParamStatisticsID int, @ParamNoRecompute bit OUTPUT', @ParamObjectID = @CurrentObjectID, @ParamStatisticsID = @CurrentStatisticsID, @ParamNoRecompute = @CurrentNoRecompute OUTPUT
          SET @Error = @@ERROR
          IF @Error = 0 AND @CurrentNoRecompute IS NULL SET @CurrentNoRecompute = 0
          IF @Error <> 0
          BEGIN
            SET @ReturnCode = @Error
            GOTO NoAction
          END
        END

        -- Has the data in the statistics been modified since the statistics was last updated?
        IF @CurrentStatisticsID IS NOT NULL AND @UpdateStatistics IS NOT NULL AND @OnlyModifiedStatistics = 'Y'
        BEGIN
          SET @CurrentCommand09 = 'IF EXISTS(SELECT * FROM ' + QUOTENAME(@CurrentDatabaseName) + '.sys.sysindexes sysindexes WHERE sysindexes.[id] = @ParamObjectID AND sysindexes.[indid] = @ParamStatisticsID AND sysindexes.[rowmodctr] <> 0) BEGIN SET @ParamStatisticsModified = 1 END'

          EXECUTE sp_executesql @statement = @CurrentCommand09, @params = N'@ParamObjectID int, @ParamStatisticsID int, @ParamStatisticsModified bit OUTPUT', @ParamObjectID = @CurrentObjectID, @ParamStatisticsID = @CurrentStatisticsID, @ParamStatisticsModified = @CurrentStatisticsModified OUTPUT
          SET @Error = @@ERROR
          IF @Error = 0 AND @CurrentStatisticsModified IS NULL SET @CurrentStatisticsModified = 0
          IF @Error <> 0
          BEGIN
            SET @ReturnCode = @Error
            GOTO NoAction
          END
        END

        -- Is the index on a read-only filegroup?
        IF @CurrentIndexID IS NOT NULL AND EXISTS(SELECT * FROM @ActionsPreferred)
        BEGIN
          SET @CurrentCommand10 = 'IF EXISTS(SELECT * FROM (SELECT filegroups.data_space_id FROM ' + QUOTENAME(@CurrentDatabaseName) + '.sys.indexes indexes INNER JOIN ' + QUOTENAME(@CurrentDatabaseName) + '.sys.destination_data_spaces destination_data_spaces ON indexes.data_space_id = destination_data_spaces.partition_scheme_id INNER JOIN ' + QUOTENAME(@CurrentDatabaseName) + '.sys.filegroups filegroups ON destination_data_spaces.data_space_id = filegroups.data_space_id WHERE filegroups.is_read_only = 1 AND indexes.[object_id] = @ParamObjectID AND indexes.[index_id] = @ParamIndexID'
          IF @CurrentIsPartition = 1 SET @CurrentCommand10 = @CurrentCommand10 + ' AND destination_data_spaces.destination_id = @ParamPartitionNumber'
          SET @CurrentCommand10 = @CurrentCommand10 + ' UNION SELECT filegroups.data_space_id FROM ' + QUOTENAME(@CurrentDatabaseName) + '.sys.indexes indexes INNER JOIN ' + QUOTENAME(@CurrentDatabaseName) + '.sys.filegroups filegroups ON indexes.data_space_id = filegroups.data_space_id WHERE filegroups.is_read_only = 1 AND indexes.[object_id] = @ParamObjectID AND indexes.[index_id] = @ParamIndexID'
          IF @CurrentIndexType = 1 SET @CurrentCommand10 = @CurrentCommand10 + ' UNION SELECT filegroups.data_space_id FROM ' + QUOTENAME(@CurrentDatabaseName) + '.sys.tables tables INNER JOIN ' + QUOTENAME(@CurrentDatabaseName) + '.sys.filegroups filegroups ON tables.lob_data_space_id = filegroups.data_space_id WHERE filegroups.is_read_only = 1 AND tables.[object_id] = @ParamObjectID'
          SET @CurrentCommand10 = @CurrentCommand10 + ') ReadOnlyFileGroups) BEGIN SET @ParamOnReadOnlyFileGroup = 1 END'

          EXECUTE sp_executesql @statement = @CurrentCommand10, @params = N'@ParamObjectID int, @ParamIndexID int, @ParamPartitionNumber int, @ParamOnReadOnlyFileGroup bit OUTPUT', @ParamObjectID = @CurrentObjectID, @ParamIndexID = @CurrentIndexID, @ParamPartitionNumber = @CurrentPartitionNumber, @ParamOnReadOnlyFileGroup = @CurrentOnReadOnlyFileGroup OUTPUT
          SET @Error = @@ERROR
          IF @Error = 0 AND @CurrentOnReadOnlyFileGroup IS NULL SET @CurrentOnReadOnlyFileGroup = 0
          IF @Error <> 0
          BEGIN
            SET @ReturnCode = @Error
            GOTO NoAction
          END
        END

        -- Is the index fragmented?
        IF @CurrentIndexID IS NOT NULL
        AND EXISTS(SELECT * FROM @ActionsPreferred)
        AND (EXISTS(SELECT [Priority], [Action], COUNT(*) FROM @ActionsPreferred GROUP BY [Priority], [Action] HAVING COUNT(*) <> 3) OR @PageCountLevel > 0)
        BEGIN
          SELECT @CurrentFragmentationLevel = MAX(avg_fragmentation_in_percent),
                 @CurrentPageCount = SUM(page_count)
          FROM sys.dm_db_index_physical_stats(@CurrentDatabaseID, @CurrentObjectID, @CurrentIndexID, @CurrentPartitionNumber, 'LIMITED')
          WHERE alloc_unit_type_desc = 'IN_ROW_DATA'
          AND index_level = 0
          SET @Error = @@ERROR
          IF @Error = 1222
          BEGIN
            SET @ErrorMessage = 'The dynamic management view sys.dm_db_index_physical_stats is locked on the index ' + QUOTENAME(@CurrentSchemaName) + '.' + QUOTENAME(@CurrentObjectName) + '.' + QUOTENAME(@CurrentIndexName) + '.' + CHAR(13) + CHAR(10) + ' '
            SET @ErrorMessage = REPLACE(@ErrorMessage,'%','%%')
            RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
            END
          IF @Error <> 0
          BEGIN
            SET @ReturnCode = @Error
            GOTO NoAction
          END
        END

        -- Select fragmentation group
        IF @CurrentIndexID IS NOT NULL AND EXISTS(SELECT * FROM @ActionsPreferred)
        BEGIN
          SET @CurrentFragmentationGroup = CASE
          WHEN @CurrentFragmentationLevel >= @FragmentationLevel2 THEN 'High'
          WHEN @CurrentFragmentationLevel >= @FragmentationLevel1 AND @CurrentFragmentationLevel < @FragmentationLevel2 THEN 'Medium'
          WHEN @CurrentFragmentationLevel < @FragmentationLevel1 THEN 'Low'
          END
        END

        -- Which actions are allowed?
        IF @CurrentIndexID IS NOT NULL AND EXISTS(SELECT * FROM @ActionsPreferred)
        BEGIN
          IF @CurrentOnReadOnlyFileGroup = 0 AND @CurrentAllowPageLocks = 1
          BEGIN
            INSERT INTO @CurrentActionsAllowed ([Action])
            VALUES ('INDEX_REORGANIZE')
          END
          IF @CurrentOnReadOnlyFileGroup = 0
          BEGIN
            INSERT INTO @CurrentActionsAllowed ([Action])
            VALUES ('INDEX_REBUILD_OFFLINE')
          END
          IF @CurrentOnReadOnlyFileGroup = 0
          AND @CurrentIsPartition = 0
          AND ((@CurrentIndexType = 1 AND @CurrentIsImageText = 0 AND @CurrentIsNewLOB = 0)
          OR (@CurrentIndexType = 2 AND @CurrentIsNewLOB = 0)
          OR (@CurrentIndexType = 1 AND @CurrentIsImageText = 0 AND @CurrentIsFileStream = 0 AND @Version >= 11)
          OR (@CurrentIndexType = 2 AND @Version >= 11))
          AND SERVERPROPERTY('EngineEdition') = 3
          BEGIN
            INSERT INTO @CurrentActionsAllowed ([Action])
            VALUES ('INDEX_REBUILD_ONLINE')
          END
        END

        -- Decide action
        IF @CurrentIndexID IS NOT NULL
        AND EXISTS(SELECT * FROM @ActionsPreferred)
        AND (@CurrentPageCount >= @PageCountLevel OR @PageCountLevel = 0)
        BEGIN
          IF EXISTS(SELECT [Priority], [Action], COUNT(*) FROM @ActionsPreferred GROUP BY [Priority], [Action] HAVING COUNT(*) <> 3)
          BEGIN
            SELECT @CurrentAction = [Action]
            FROM @ActionsPreferred
            WHERE FragmentationGroup = @CurrentFragmentationGroup
            AND [Priority] = (SELECT MIN([Priority])
                              FROM @ActionsPreferred
                              WHERE FragmentationGroup = @CurrentFragmentationGroup
                              AND [Action] IN (SELECT [Action] FROM @CurrentActionsAllowed))
          END
          ELSE
          BEGIN
            SELECT @CurrentAction = [Action]
            FROM @ActionsPreferred
            WHERE [Priority] = (SELECT MIN([Priority])
                                FROM @ActionsPreferred
                                WHERE [Action] IN (SELECT [Action] FROM @CurrentActionsAllowed))
          END
        END

        -- Workaround for a bug in SQL Server 2005, SQL Server 2008 and SQL Server 2008 R2, http://support.microsoft.com/kb/2292737
        IF @CurrentIndexID IS NOT NULL
        BEGIN
          SET @CurrentMaxDOP = @MaxDOP
          IF @Version < 11 AND @CurrentAction = 'INDEX_REBUILD_ONLINE' AND @CurrentAllowPageLocks = 0
          BEGIN
            SET @CurrentMaxDOP = 1
          END
        END

        -- Update statistics?
        IF @CurrentStatisticsID IS NOT NULL
        AND (@UpdateStatistics = 'ALL' OR (@UpdateStatistics = 'INDEX' AND @CurrentIndexID IS NOT NULL) OR (@UpdateStatistics = 'COLUMNS' AND @CurrentIndexID IS NULL))
        AND (@CurrentStatisticsModified = 1 OR @OnlyModifiedStatistics = 'N')
        AND ((@CurrentIsPartition = 0 AND (@CurrentAction NOT IN('INDEX_REBUILD_ONLINE','INDEX_REBUILD_OFFLINE') OR @CurrentAction IS NULL)) OR (@CurrentIsPartition = 1 AND @CurrentPartitionNumber = @CurrentPartitionCount))
        BEGIN
          SET @CurrentUpdateStatistics = 'Y'
        END
        ELSE
        BEGIN
          SET @CurrentUpdateStatistics = 'N'
        END

        -- Create comment
        IF @CurrentIndexID IS NOT NULL
        BEGIN
          SET @CurrentComment = 'ObjectType: ' + CASE WHEN @CurrentObjectType = 'U' THEN 'Table' WHEN @CurrentObjectType = 'V' THEN 'View' ELSE 'N/A' END + ', '
          SET @CurrentComment = @CurrentComment + 'IndexType: ' + CASE WHEN @CurrentIndexType = 1 THEN 'Clustered' WHEN @CurrentIndexType = 2 THEN 'NonClustered' WHEN @CurrentIndexType = 3 THEN 'XML' WHEN @CurrentIndexType = 4 THEN 'Spatial' ELSE 'N/A' END + ', '
          SET @CurrentComment = @CurrentComment + 'ImageText: ' + CASE WHEN @CurrentIsImageText = 1 THEN 'Yes' WHEN @CurrentIsImageText = 0 THEN 'No' ELSE 'N/A' END + ', '
          SET @CurrentComment = @CurrentComment + 'NewLOB: ' + CASE WHEN @CurrentIsNewLOB = 1 THEN 'Yes' WHEN @CurrentIsNewLOB = 0 THEN 'No' ELSE 'N/A' END + ', '
          SET @CurrentComment = @CurrentComment + 'FileStream: ' + CASE WHEN @CurrentIsFileStream = 1 THEN 'Yes' WHEN @CurrentIsFileStream = 0 THEN 'No' ELSE 'N/A' END + ', '
          SET @CurrentComment = @CurrentComment + 'AllowPageLocks: ' + CASE WHEN @CurrentAllowPageLocks = 1 THEN 'Yes' WHEN @CurrentAllowPageLocks = 0 THEN 'No' ELSE 'N/A' END + ', '
          SET @CurrentComment = @CurrentComment + 'PageCount: ' + ISNULL(CAST(@CurrentPageCount AS nvarchar),'N/A') + ', '
          SET @CurrentComment = @CurrentComment + 'Fragmentation: ' + ISNULL(CAST(@CurrentFragmentationLevel AS nvarchar),'N/A')
        END

        IF @CurrentIndexID IS NOT NULL AND (@CurrentPageCount IS NOT NULL OR @CurrentFragmentationLevel IS NOT NULL)
        BEGIN
        SET @CurrentExtendedInfo = (SELECT *
                                    FROM (SELECT CAST(@CurrentPageCount AS nvarchar) AS [PageCount],
                                                 CAST(@CurrentFragmentationLevel AS nvarchar) AS Fragmentation
                                    ) ExtendedInfo FOR XML AUTO, ELEMENTS)
        END

        IF @CurrentIndexID IS NOT NULL AND @CurrentAction IS NOT NULL AND (GETDATE() < DATEADD(ss,@TimeLimit,@StartTime) OR @TimeLimit IS NULL)
        BEGIN
          SET @CurrentCommandType11 = 'ALTER_INDEX'

          SET @CurrentCommand11 = 'ALTER INDEX ' + QUOTENAME(@CurrentIndexName) + ' ON ' + QUOTENAME(@CurrentDatabaseName) + '.' + QUOTENAME(@CurrentSchemaName) + '.' + QUOTENAME(@CurrentObjectName)

          IF @CurrentAction IN('INDEX_REBUILD_ONLINE','INDEX_REBUILD_OFFLINE')
          BEGIN
            SET @CurrentCommand11 = @CurrentCommand11 + ' REBUILD'
            IF @CurrentIsPartition = 1 SET @CurrentCommand11 = @CurrentCommand11 + ' PARTITION = ' + CAST(@CurrentPartitionNumber AS nvarchar)
            SET @CurrentCommand11 = @CurrentCommand11 + ' WITH ('
            IF @SortInTempdb = 'Y' SET @CurrentCommand11 = @CurrentCommand11 + 'SORT_IN_TEMPDB = ON'
            IF @SortInTempdb = 'N' SET @CurrentCommand11 = @CurrentCommand11 + 'SORT_IN_TEMPDB = OFF'
            IF @CurrentAction = 'INDEX_REBUILD_ONLINE' AND @CurrentIsPartition = 0 SET @CurrentCommand11 = @CurrentCommand11 + ', ONLINE = ON'
            IF @CurrentAction = 'INDEX_REBUILD_OFFLINE' AND @CurrentIsPartition = 0 SET @CurrentCommand11 = @CurrentCommand11 + ', ONLINE = OFF'
            IF @CurrentMaxDOP IS NOT NULL SET @CurrentCommand11 = @CurrentCommand11 + ', MAXDOP = ' + CAST(@CurrentMaxDOP AS nvarchar)
            IF @FillFactor IS NOT NULL AND @CurrentIsPartition = 0 SET @CurrentCommand11 = @CurrentCommand11 + ', FILLFACTOR = ' + CAST(@FillFactor AS nvarchar)
            IF @PadIndex = 'Y' AND @CurrentIsPartition = 0 SET @CurrentCommand11 = @CurrentCommand11 + ', PAD_INDEX = ON'
            IF @PadIndex = 'N' AND @CurrentIsPartition = 0 SET @CurrentCommand11 = @CurrentCommand11 + ', PAD_INDEX = OFF'
            SET @CurrentCommand11 = @CurrentCommand11 + ')'
          END

          IF @CurrentAction IN('INDEX_REORGANIZE')
          BEGIN
            SET @CurrentCommand11 = @CurrentCommand11 + ' REORGANIZE'
            IF @CurrentIsPartition = 1 SET @CurrentCommand11 = @CurrentCommand11 + ' PARTITION = ' + CAST(@CurrentPartitionNumber AS nvarchar)
            SET @CurrentCommand11 = @CurrentCommand11 + ' WITH ('
            IF @LOBCompaction = 'Y' SET @CurrentCommand11 = @CurrentCommand11 + 'LOB_COMPACTION = ON'
            IF @LOBCompaction = 'N' SET @CurrentCommand11 = @CurrentCommand11 + 'LOB_COMPACTION = OFF'
            SET @CurrentCommand11 = @CurrentCommand11 + ')'
          END

          EXECUTE @CurrentCommandOutput11 = [dbo].[CommandExecute] @Command = @CurrentCommand11, @CommandType = @CurrentCommandType11, @Mode = 2, @Comment = @CurrentComment, @DatabaseName = @CurrentDatabaseName, @SchemaName = @CurrentSchemaName, @ObjectName = @CurrentObjectName, @ObjectType = @CurrentObjectType, @IndexName = @CurrentIndexName, @IndexType = @CurrentIndexType, @PartitionNumber = @CurrentPartitionNumber, @ExtendedInfo = @CurrentExtendedInfo, @LogToTable = @LogToTable, @Execute = @Execute
          SET @Error = @@ERROR
          IF @Error <> 0 SET @CurrentCommandOutput11 = @Error
          IF @CurrentCommandOutput11 <> 0 SET @ReturnCode = @CurrentCommandOutput11

          IF @Delay > 0
          BEGIN
            SET @CurrentDelay = DATEADD(ss,@Delay,'1900-01-01')
            WAITFOR DELAY @CurrentDelay
          END
        END

        IF @CurrentStatisticsID IS NOT NULL AND @CurrentUpdateStatistics = 'Y' AND (GETDATE() < DATEADD(ss,@TimeLimit,@StartTime) OR @TimeLimit IS NULL)
        BEGIN
          SET @CurrentCommandType12 = 'UPDATE_STATISTICS'

          SET @CurrentCommand12 = 'UPDATE STATISTICS ' + QUOTENAME(@CurrentDatabaseName) + '.' + QUOTENAME(@CurrentSchemaName) + '.' + QUOTENAME(@CurrentObjectName) + ' ' + QUOTENAME(@CurrentStatisticsName)
          IF @StatisticsSample IS NOT NULL OR @StatisticsResample = 'Y' OR @CurrentNoRecompute = 1 SET @CurrentCommand12 = @CurrentCommand12 + ' WITH'
          IF @StatisticsSample = 100 SET @CurrentCommand12 = @CurrentCommand12 + ' FULLSCAN'
          IF @StatisticsSample IS NOT NULL AND @StatisticsSample <> 100 SET @CurrentCommand12 = @CurrentCommand12 + ' SAMPLE ' + CAST(@StatisticsSample AS nvarchar) + ' PERCENT'
          IF @StatisticsResample = 'Y' SET @CurrentCommand12 = @CurrentCommand12 + ' RESAMPLE'
          IF (@StatisticsSample IS NOT NULL OR @StatisticsResample = 'Y') AND @CurrentNoRecompute = 1 SET @CurrentCommand12 = @CurrentCommand12 + ','
          IF @CurrentNoRecompute = 1 SET @CurrentCommand12 = @CurrentCommand12 + ' NORECOMPUTE'

          EXECUTE @CurrentCommandOutput12 = [dbo].[CommandExecute] @Command = @CurrentCommand12, @CommandType = @CurrentCommandType12, @Mode = 2, @DatabaseName = @CurrentDatabaseName, @SchemaName = @CurrentSchemaName, @ObjectName = @CurrentObjectName, @ObjectType = @CurrentObjectType, @IndexName = @CurrentIndexName, @IndexType = @CurrentIndexType, @StatisticsName = @CurrentStatisticsName, @LogToTable = @LogToTable, @Execute = @Execute
          SET @Error = @@ERROR
          IF @Error <> 0 SET @CurrentCommandOutput12 = @Error
          IF @CurrentCommandOutput12 <> 0 SET @ReturnCode = @CurrentCommandOutput12
        END

        NoAction:

        -- Update that the index is completed
        UPDATE @tmpIndexesStatistics
        SET Completed = 1
        WHERE Selected = 1
        AND Completed = 0
        AND IxID = @CurrentIxID

        -- Clear variables
        SET @CurrentCommand02 = NULL
        SET @CurrentCommand03 = NULL
        SET @CurrentCommand04 = NULL
        SET @CurrentCommand05 = NULL
        SET @CurrentCommand06 = NULL
        SET @CurrentCommand07 = NULL
        SET @CurrentCommand08 = NULL
        SET @CurrentCommand09 = NULL
        SET @CurrentCommand10 = NULL
        SET @CurrentCommand11 = NULL
        SET @CurrentCommand12 = NULL

        SET @CurrentCommandOutput11 = NULL
        SET @CurrentCommandOutput12 = NULL

        SET @CurrentCommandType11 = NULL
        SET @CurrentCommandType12 = NULL

        SET @CurrentIxID = NULL
        SET @CurrentSchemaID = NULL
        SET @CurrentSchemaName = NULL
        SET @CurrentObjectID = NULL
        SET @CurrentObjectName = NULL
        SET @CurrentObjectType = NULL
        SET @CurrentIndexID = NULL
        SET @CurrentIndexName = NULL
        SET @CurrentIndexType = NULL
        SET @CurrentStatisticsID = NULL
        SET @CurrentStatisticsName = NULL
        SET @CurrentPartitionID = NULL
        SET @CurrentPartitionNumber = NULL
        SET @CurrentPartitionCount = NULL
        SET @CurrentIsPartition = NULL
        SET @CurrentIndexExists = NULL
        SET @CurrentStatisticsExists = NULL
        SET @CurrentIsImageText = NULL
        SET @CurrentIsNewLOB = NULL
        SET @CurrentIsFileStream = NULL
        SET @CurrentAllowPageLocks = NULL
        SET @CurrentNoRecompute = NULL
        SET @CurrentStatisticsModified = NULL
        SET @CurrentOnReadOnlyFileGroup = NULL
        SET @CurrentFragmentationLevel = NULL
        SET @CurrentPageCount = NULL
        SET @CurrentFragmentationGroup = NULL
        SET @CurrentAction = NULL
        SET @CurrentMaxDOP = NULL
        SET @CurrentUpdateStatistics = NULL
        SET @CurrentComment = NULL
        SET @CurrentExtendedInfo = NULL

        DELETE FROM @CurrentActionsAllowed

      END

    END

    -- Update that the database is completed
    UPDATE @tmpDatabases
    SET Completed = 1
    WHERE ID = @CurrentID

    -- Clear variables
    SET @CurrentID = NULL
    SET @CurrentDatabaseID = NULL
    SET @CurrentDatabaseName = NULL
    SET @CurrentIsDatabaseAccessible = NULL
    SET @CurrentAvailabilityGroup = NULL
    SET @CurrentRole = NULL

    SET @CurrentCommand01 = NULL

    DELETE FROM @tmpIndexesStatistics

  END

  ----------------------------------------------------------------------------------------------------
  --// Log completing information                                                                 //--
  ----------------------------------------------------------------------------------------------------

  Logging:
  SET @EndMessage = 'DateTime: ' + CONVERT(nvarchar,GETDATE(),120)
  SET @EndMessage = REPLACE(@EndMessage,'%','%%')
  RAISERROR(@EndMessage,10,1) WITH NOWAIT

  IF @ReturnCode <> 0
  BEGIN
    RETURN @ReturnCode
  END

  ----------------------------------------------------------------------------------------------------

END
GO

IF (SELECT CAST([Value] AS int) FROM #Config WHERE Name = 'Error') = 0
AND (SELECT [Value] FROM #Config WHERE Name = 'CreateJobs') = 'Y'
AND SERVERPROPERTY('EngineEdition') <> 4
BEGIN

  DECLARE @BackupDirectory nvarchar(max)
  DECLARE @OutputFileDirectory nvarchar(max)
  DECLARE @LogToTable nvarchar(max)
  DECLARE @DatabaseName nvarchar(max)

  DECLARE @Version numeric(18,10)

  DECLARE @TokenServer nvarchar(max)
  DECLARE @TokenJobID nvarchar(max)
  DECLARE @TokenStepID nvarchar(max)
  DECLARE @TokenDate nvarchar(max)
  DECLARE @TokenTime nvarchar(max)

  DECLARE @JobDescription nvarchar(max)
  DECLARE @JobCategory nvarchar(max)
  DECLARE @JobOwner nvarchar(max)

  DECLARE @JobName01 nvarchar(max)
  DECLARE @JobName02 nvarchar(max)
  DECLARE @JobName03 nvarchar(max)
  DECLARE @JobName04 nvarchar(max)
  DECLARE @JobName05 nvarchar(max)
  DECLARE @JobName06 nvarchar(max)
  DECLARE @JobName07 nvarchar(max)
  DECLARE @JobName08 nvarchar(max)
  DECLARE @JobName09 nvarchar(max)
  DECLARE @JobName10 nvarchar(max)
  DECLARE @JobName11 nvarchar(max)

  DECLARE @JobCommand01 nvarchar(max)
  DECLARE @JobCommand02 nvarchar(max)
  DECLARE @JobCommand03 nvarchar(max)
  DECLARE @JobCommand04 nvarchar(max)
  DECLARE @JobCommand05 nvarchar(max)
  DECLARE @JobCommand06 nvarchar(max)
  DECLARE @JobCommand07 nvarchar(max)
  DECLARE @JobCommand08 nvarchar(max)
  DECLARE @JobCommand09 nvarchar(max)
  DECLARE @JobCommand10 nvarchar(max)
  DECLARE @JobCommand11 nvarchar(max)

  DECLARE @OutputFile01 nvarchar(max)
  DECLARE @OutputFile02 nvarchar(max)
  DECLARE @OutputFile03 nvarchar(max)
  DECLARE @OutputFile04 nvarchar(max)
  DECLARE @OutputFile05 nvarchar(max)
  DECLARE @OutputFile06 nvarchar(max)
  DECLARE @OutputFile07 nvarchar(max)
  DECLARE @OutputFile08 nvarchar(max)
  DECLARE @OutputFile09 nvarchar(max)
  DECLARE @OutputFile10 nvarchar(max)
  DECLARE @OutputFile11 nvarchar(max)

  SET @Version = CAST(LEFT(CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max)),CHARINDEX('.',CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max))) - 1) + '.' + REPLACE(RIGHT(CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max)), LEN(CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max))) - CHARINDEX('.',CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max)))),'.','') AS numeric(18,10))

  IF @Version >= 9.002047
  BEGIN
    SET @TokenServer = '$' + '(ESCAPE_SQUOTE(SRVR))'
    SET @TokenJobID = '$' + '(ESCAPE_SQUOTE(JOBID))'
    SET @TokenStepID = '$' + '(ESCAPE_SQUOTE(STEPID))'
    SET @TokenDate = '$' + '(ESCAPE_SQUOTE(STRTDT))'
    SET @TokenTime = '$' + '(ESCAPE_SQUOTE(STRTTM))'
  END
  ELSE
  BEGIN
    SET @TokenServer = '$' + '(SRVR)'
    SET @TokenJobID = '$' + '(JOBID)'
    SET @TokenStepID = '$' + '(STEPID)'
    SET @TokenDate = '$' + '(STRTDT)'
    SET @TokenTime = '$' + '(STRTTM)'
  END

  SELECT @BackupDirectory = Value
  FROM #Config
  WHERE [Name] = 'BackupDirectory'

  SELECT @OutputFileDirectory = Value
  FROM #Config
  WHERE [Name] = 'OutputFileDirectory'

  SELECT @LogToTable = Value
  FROM #Config
  WHERE [Name] = 'LogToTable'

  SELECT @DatabaseName = Value
  FROM #Config
  WHERE [Name] = 'DatabaseName'

  SET @JobDescription = 'Source: http://ola.hallengren.com'
  SET @JobCategory = 'Database Maintenance'
  SET @JobOwner = SUSER_SNAME(0x01)

  SET @JobName01 = 'DatabaseBackup - SYSTEM_DATABASES - FULL'
  SET @JobCommand01 = 'sqlcmd -E -S ' + @TokenServer + ' -d ' + @DatabaseName + ' -Q "EXECUTE [dbo].[DatabaseBackup] @Databases = ''SYSTEM_DATABASES'', @Directory = ' + ISNULL('N''' + REPLACE(@BackupDirectory,'''','''''') + '''','NULL') + ', @BackupType = ''FULL'', @Verify = ''Y'', @CleanupTime = 24, @CheckSum = ''Y''' + CASE WHEN @LogToTable = 'Y' THEN ', @LogToTable = ''Y''' ELSE '' END + '" -b'
  SET @OutputFile01 = @OutputFileDirectory + CASE WHEN RIGHT(@OutputFileDirectory,1) = '\' THEN '' ELSE '\' END + 'DatabaseBackup_' + @TokenJobID + '_' + @TokenStepID + '_' + @TokenDate + '_' + @TokenTime + '.txt'
  IF LEN(@OutputFile01) > 200 SET @OutputFile01 = @OutputFileDirectory + CASE WHEN RIGHT(@OutputFileDirectory,1) = '\' THEN '' ELSE '\' END + @TokenJobID + '_' + @TokenStepID + '_' + @TokenDate + '_' + @TokenTime + '.txt'
  IF LEN(@OutputFile01) > 200 SET @OutputFile01 = NULL

  SET @JobName02 = 'DatabaseBackup - USER_DATABASES - DIFF'
  SET @JobCommand02 = 'sqlcmd -E -S ' + @TokenServer + ' -d ' + @DatabaseName + ' -Q "EXECUTE [dbo].[DatabaseBackup] @Databases = ''USER_DATABASES'', @Directory = ' + ISNULL('N''' + REPLACE(@BackupDirectory,'''','''''') + '''','NULL') + ', @BackupType = ''DIFF'', @Verify = ''Y'', @CleanupTime = 24, @CheckSum = ''Y''' + CASE WHEN @LogToTable = 'Y' THEN ', @LogToTable = ''Y''' ELSE '' END + '" -b'
  SET @OutputFile02 = @OutputFileDirectory + CASE WHEN RIGHT(@OutputFileDirectory,1) = '\' THEN '' ELSE '\' END + 'DatabaseBackup_' + @TokenJobID + '_' + @TokenStepID + '_' + @TokenDate + '_' + @TokenTime + '.txt'
  IF LEN(@OutputFile02) > 200 SET @OutputFile02 = @OutputFileDirectory + CASE WHEN RIGHT(@OutputFileDirectory,1) = '\' THEN '' ELSE '\' END + @TokenJobID + '_' + @TokenStepID + '_' + @TokenDate + '_' + @TokenTime + '.txt'
  IF LEN(@OutputFile02) > 200 SET @OutputFile02 = NULL

  SET @JobName03 = 'DatabaseBackup - USER_DATABASES - FULL'
  SET @JobCommand03 = 'sqlcmd -E -S ' + @TokenServer + ' -d ' + @DatabaseName + ' -Q "EXECUTE [dbo].[DatabaseBackup] @Databases = ''USER_DATABASES'', @Directory = ' + ISNULL('N''' + REPLACE(@BackupDirectory,'''','''''') + '''','NULL') + ', @BackupType = ''FULL'', @Verify = ''Y'', @CleanupTime = 24, @CheckSum = ''Y''' + CASE WHEN @LogToTable = 'Y' THEN ', @LogToTable = ''Y''' ELSE '' END + '" -b'
  SET @OutputFile03 = @OutputFileDirectory + CASE WHEN RIGHT(@OutputFileDirectory,1) = '\' THEN '' ELSE '\' END + 'DatabaseBackup_' + @TokenJobID + '_' + @TokenStepID + '_' + @TokenDate + '_' + @TokenTime + '.txt'
  IF LEN(@OutputFile03) > 200 SET @OutputFile03 = @OutputFileDirectory + CASE WHEN RIGHT(@OutputFileDirectory,1) = '\' THEN '' ELSE '\' END + @TokenJobID + '_' + @TokenStepID + '_' + @TokenDate + '_' + @TokenTime + '.txt'
  IF LEN(@OutputFile03) > 200 SET @OutputFile03 = NULL

  SET @JobName04 = 'DatabaseBackup - USER_DATABASES - LOG'
  SET @JobCommand04 = 'sqlcmd -E -S ' + @TokenServer + ' -d ' + @DatabaseName + ' -Q "EXECUTE [dbo].[DatabaseBackup] @Databases = ''USER_DATABASES'', @Directory = ' + ISNULL('N''' + REPLACE(@BackupDirectory,'''','''''') + '''','NULL') + ', @BackupType = ''LOG'', @Verify = ''Y'', @CleanupTime = 24, @CheckSum = ''Y''' + CASE WHEN @LogToTable = 'Y' THEN ', @LogToTable = ''Y''' ELSE '' END + '" -b'
  SET @OutputFile04 = @OutputFileDirectory + CASE WHEN RIGHT(@OutputFileDirectory,1) = '\' THEN '' ELSE '\' END + 'DatabaseBackup_' + @TokenJobID + '_' + @TokenStepID + '_' + @TokenDate + '_' + @TokenTime + '.txt'
  IF LEN(@OutputFile04) > 200 SET @OutputFile04 = @OutputFileDirectory + CASE WHEN RIGHT(@OutputFileDirectory,1) = '\' THEN '' ELSE '\' END + @TokenJobID + '_' + @TokenStepID + '_' + @TokenDate + '_' + @TokenTime + '.txt'
  IF LEN(@OutputFile04) > 200 SET @OutputFile04 = NULL

  SET @JobName05 = 'DatabaseIntegrityCheck - SYSTEM_DATABASES'
  SET @JobCommand05 = 'sqlcmd -E -S ' + @TokenServer + ' -d ' + @DatabaseName + ' -Q "EXECUTE [dbo].[DatabaseIntegrityCheck] @Databases = ''SYSTEM_DATABASES''' + CASE WHEN @LogToTable = 'Y' THEN ', @LogToTable = ''Y''' ELSE '' END + '" -b'
  SET @OutputFile05 = @OutputFileDirectory + CASE WHEN RIGHT(@OutputFileDirectory,1) = '\' THEN '' ELSE '\' END + 'DatabaseIntegrityCheck_' + @TokenJobID + '_' + @TokenStepID + '_' + @TokenDate + '_' + @TokenTime + '.txt'
  IF LEN(@OutputFile05) > 200 SET @OutputFile05 = @OutputFileDirectory + CASE WHEN RIGHT(@OutputFileDirectory,1) = '\' THEN '' ELSE '\' END + @TokenJobID + '_' + @TokenStepID + '_' + @TokenDate + '_' + @TokenTime + '.txt'
  IF LEN(@OutputFile05) > 200 SET @OutputFile05 = NULL

  SET @JobName06 = 'DatabaseIntegrityCheck - USER_DATABASES'
  SET @JobCommand06 = 'sqlcmd -E -S ' + @TokenServer + ' -d ' + @DatabaseName + ' -Q "EXECUTE [dbo].[DatabaseIntegrityCheck] @Databases = ''USER_DATABASES''' + CASE WHEN @LogToTable = 'Y' THEN ', @LogToTable = ''Y''' ELSE '' END + '" -b'
  SET @OutputFile06 = @OutputFileDirectory + CASE WHEN RIGHT(@OutputFileDirectory,1) = '\' THEN '' ELSE '\' END + 'DatabaseIntegrityCheck_' + @TokenJobID + '_' + @TokenStepID + '_' + @TokenDate + '_' + @TokenTime + '.txt'
  IF LEN(@OutputFile06) > 200 SET @OutputFile06 = @OutputFileDirectory + CASE WHEN RIGHT(@OutputFileDirectory,1) = '\' THEN '' ELSE '\' END + @TokenJobID + '_' + @TokenStepID + '_' + @TokenDate + '_' + @TokenTime + '.txt'
  IF LEN(@OutputFile06) > 200 SET @OutputFile06 = NULL

  SET @JobName07 = 'IndexOptimize - USER_DATABASES'
  SET @JobCommand07 = 'sqlcmd -E -S ' + @TokenServer + ' -d ' + @DatabaseName + ' -Q "EXECUTE [dbo].[IndexOptimize] @Databases = ''USER_DATABASES''' + CASE WHEN @LogToTable = 'Y' THEN ', @LogToTable = ''Y''' ELSE '' END + '" -b'
  SET @OutputFile07 = @OutputFileDirectory + CASE WHEN RIGHT(@OutputFileDirectory,1) = '\' THEN '' ELSE '\' END + 'IndexOptimize_' + @TokenJobID + '_' + @TokenStepID + '_' + @TokenDate + '_' + @TokenTime + '.txt'
  IF LEN(@OutputFile07) > 200 SET @OutputFile07 = @OutputFileDirectory + CASE WHEN RIGHT(@OutputFileDirectory,1) = '\' THEN '' ELSE '\' END + @TokenJobID + '_' + @TokenStepID + '_' + @TokenDate + '_' + @TokenTime + '.txt'
  IF LEN(@OutputFile07) > 200 SET @OutputFile07 = NULL

  SET @JobName08 = 'sp_delete_backuphistory'
  SET @JobCommand08 = 'sqlcmd -E -S ' + @TokenServer + ' -d ' + 'msdb' + ' -Q "DECLARE @CleanupDate datetime SET @CleanupDate = DATEADD(dd,-30,GETDATE()) EXECUTE dbo.sp_delete_backuphistory @oldest_date = @CleanupDate" -b'
  SET @OutputFile08 = @OutputFileDirectory + CASE WHEN RIGHT(@OutputFileDirectory,1) = '\' THEN '' ELSE '\' END + 'sp_delete_backuphistory_' + @TokenJobID + '_' + @TokenStepID + '_' + @TokenDate + '_' + @TokenTime + '.txt'
  IF LEN(@OutputFile08) > 200 SET @OutputFile08 = @OutputFileDirectory + CASE WHEN RIGHT(@OutputFileDirectory,1) = '\' THEN '' ELSE '\' END + @TokenJobID + '_' + @TokenStepID + '_' + @TokenDate + '_' + @TokenTime + '.txt'
  IF LEN(@OutputFile08) > 200 SET @OutputFile08 = NULL

  SET @JobName09 = 'sp_purge_jobhistory'
  SET @JobCommand09 = 'sqlcmd -E -S ' + @TokenServer + ' -d ' + 'msdb' + ' -Q "DECLARE @CleanupDate datetime SET @CleanupDate = DATEADD(dd,-30,GETDATE()) EXECUTE dbo.sp_purge_jobhistory @oldest_date = @CleanupDate" -b'
  SET @OutputFile09 = @OutputFileDirectory + CASE WHEN RIGHT(@OutputFileDirectory,1) = '\' THEN '' ELSE '\' END + 'sp_purge_jobhistory_' + @TokenJobID + '_' + @TokenStepID + '_' + @TokenDate + '_' + @TokenTime + '.txt'
  IF LEN(@OutputFile09) > 200 SET @OutputFile09 = @OutputFileDirectory + CASE WHEN RIGHT(@OutputFileDirectory,1) = '\' THEN '' ELSE '\' END + @TokenJobID + '_' + @TokenStepID + '_' + @TokenDate + '_' + @TokenTime + '.txt'
  IF LEN(@OutputFile09) > 200 SET @OutputFile09 = NULL

  SET @JobName10 = 'Output File Cleanup'
  SET @JobCommand10 = 'cmd /q /c "For /F "tokens=1 delims=" %v In (''ForFiles /P "' + @OutputFileDirectory + '" /m *_*_*_*.txt /d -30 2^>^&1'') do if EXIST "' + @OutputFileDirectory + '"\%v echo del "' + @OutputFileDirectory + '"\%v& del "' + @OutputFileDirectory + '"\%v"'
  SET @OutputFile10 = @OutputFileDirectory + CASE WHEN RIGHT(@OutputFileDirectory,1) = '\' THEN '' ELSE '\' END + 'OutputFileCleanup_' + @TokenJobID + '_' + @TokenStepID + '_' + @TokenDate + '_' + @TokenTime + '.txt'
  IF LEN(@OutputFile10) > 200 SET @OutputFile10 = @OutputFileDirectory + CASE WHEN RIGHT(@OutputFileDirectory,1) = '\' THEN '' ELSE '\' END + @TokenJobID + '_' + @TokenStepID + '_' + @TokenDate + '_' + @TokenTime + '.txt'
  IF LEN(@OutputFile10) > 200 SET @OutputFile10 = NULL

  SET @JobName11 = 'CommandLog Cleanup'
  SET @JobCommand11 = 'sqlcmd -E -S ' + @TokenServer + ' -d ' + @DatabaseName + ' -Q "DELETE FROM [dbo].[CommandLog] WHERE DATEDIFF(dd,StartTime,GETDATE()) > 30" -b'
  SET @OutputFile11 = @OutputFileDirectory + CASE WHEN RIGHT(@OutputFileDirectory,1) = '\' THEN '' ELSE '\' END + 'CommandLogCleanup_' + @TokenJobID + '_' + @TokenStepID + '_' + @TokenDate + '_' + @TokenTime + '.txt'
  IF LEN(@OutputFile11) > 200 SET @OutputFile11 = @OutputFileDirectory + CASE WHEN RIGHT(@OutputFileDirectory,1) = '\' THEN '' ELSE '\' END + @TokenJobID + '_' + @TokenStepID + '_' + @TokenDate + '_' + @TokenTime + '.txt'
  IF LEN(@OutputFile11) > 200 SET @OutputFile11 = NULL

  IF NOT EXISTS (SELECT * FROM msdb.dbo.sysjobs WHERE [name] = @JobName01)
  BEGIN
    EXECUTE msdb.dbo.sp_add_job @job_name = @JobName01, @description = @JobDescription, @category_name = @JobCategory, @owner_login_name = @JobOwner
    EXECUTE msdb.dbo.sp_add_jobstep @job_name = @JobName01, @step_name = @JobName01, @subsystem = 'CMDEXEC', @command = @JobCommand01, @output_file_name = @OutputFile01
    EXECUTE msdb.dbo.sp_add_jobserver @job_name = @JobName01
  END

  IF NOT EXISTS (SELECT * FROM msdb.dbo.sysjobs WHERE [name] = @JobName02)
  BEGIN
    EXECUTE msdb.dbo.sp_add_job @job_name = @JobName02, @description = @JobDescription, @category_name = @JobCategory, @owner_login_name = @JobOwner
    EXECUTE msdb.dbo.sp_add_jobstep @job_name = @JobName02, @step_name = @JobName02, @subsystem = 'CMDEXEC', @command = @JobCommand02, @output_file_name = @OutputFile02
    EXECUTE msdb.dbo.sp_add_jobserver @job_name = @JobName02
  END

  IF NOT EXISTS (SELECT * FROM msdb.dbo.sysjobs WHERE [name] = @JobName03)
  BEGIN
    EXECUTE msdb.dbo.sp_add_job @job_name = @JobName03, @description = @JobDescription, @category_name = @JobCategory, @owner_login_name = @JobOwner
    EXECUTE msdb.dbo.sp_add_jobstep @job_name = @JobName03, @step_name = @JobName03, @subsystem = 'CMDEXEC', @command = @JobCommand03, @output_file_name = @OutputFile03
    EXECUTE msdb.dbo.sp_add_jobserver @job_name = @JobName03
  END

  IF NOT EXISTS (SELECT * FROM msdb.dbo.sysjobs WHERE [name] = @JobName04)
  BEGIN
    EXECUTE msdb.dbo.sp_add_job @job_name = @JobName04, @description = @JobDescription, @category_name = @JobCategory, @owner_login_name = @JobOwner
    EXECUTE msdb.dbo.sp_add_jobstep @job_name = @JobName04, @step_name = @JobName04, @subsystem = 'CMDEXEC', @command = @JobCommand04, @output_file_name = @OutputFile04
    EXECUTE msdb.dbo.sp_add_jobserver @job_name = @JobName04
  END

  IF NOT EXISTS (SELECT * FROM msdb.dbo.sysjobs WHERE [name] = @JobName05)
  BEGIN
    EXECUTE msdb.dbo.sp_add_job @job_name = @JobName05, @description = @JobDescription, @category_name = @JobCategory, @owner_login_name = @JobOwner
    EXECUTE msdb.dbo.sp_add_jobstep @job_name = @JobName05, @step_name = @JobName05, @subsystem = 'CMDEXEC', @command = @JobCommand05, @output_file_name = @OutputFile05
    EXECUTE msdb.dbo.sp_add_jobserver @job_name = @JobName05
  END

  IF NOT EXISTS (SELECT * FROM msdb.dbo.sysjobs WHERE [name] = @JobName06)
  BEGIN
    EXECUTE msdb.dbo.sp_add_job @job_name = @JobName06, @description = @JobDescription, @category_name = @JobCategory, @owner_login_name = @JobOwner
    EXECUTE msdb.dbo.sp_add_jobstep @job_name = @JobName06, @step_name = @JobName06, @subsystem = 'CMDEXEC', @command = @JobCommand06, @output_file_name = @OutputFile06
    EXECUTE msdb.dbo.sp_add_jobserver @job_name = @JobName06
  END

  IF NOT EXISTS (SELECT * FROM msdb.dbo.sysjobs WHERE [name] = @JobName07)
  BEGIN
    EXECUTE msdb.dbo.sp_add_job @job_name = @JobName07, @description = @JobDescription, @category_name = @JobCategory, @owner_login_name = @JobOwner
    EXECUTE msdb.dbo.sp_add_jobstep @job_name = @JobName07, @step_name = @JobName07, @subsystem = 'CMDEXEC', @command = @JobCommand07, @output_file_name = @OutputFile07
    EXECUTE msdb.dbo.sp_add_jobserver @job_name = @JobName07
  END

  IF NOT EXISTS (SELECT * FROM msdb.dbo.sysjobs WHERE [name] = @JobName08)
  BEGIN
    EXECUTE msdb.dbo.sp_add_job @job_name = @JobName08, @description = @JobDescription, @category_name = @JobCategory, @owner_login_name = @JobOwner
    EXECUTE msdb.dbo.sp_add_jobstep @job_name = @JobName08, @step_name = @JobName08, @subsystem = 'CMDEXEC', @command = @JobCommand08, @output_file_name = @OutputFile08
    EXECUTE msdb.dbo.sp_add_jobserver @job_name = @JobName08
  END

  IF NOT EXISTS (SELECT * FROM msdb.dbo.sysjobs WHERE [name] = @JobName09)
  BEGIN
    EXECUTE msdb.dbo.sp_add_job @job_name = @JobName09, @description = @JobDescription, @category_name = @JobCategory, @owner_login_name = @JobOwner
    EXECUTE msdb.dbo.sp_add_jobstep @job_name = @JobName09, @step_name = @JobName09, @subsystem = 'CMDEXEC', @command = @JobCommand09, @output_file_name = @OutputFile09
    EXECUTE msdb.dbo.sp_add_jobserver @job_name = @JobName09
  END

  IF NOT EXISTS (SELECT * FROM msdb.dbo.sysjobs WHERE [name] = @JobName10)
  BEGIN
    EXECUTE msdb.dbo.sp_add_job @job_name = @JobName10, @description = @JobDescription, @category_name = @JobCategory, @owner_login_name = @JobOwner
    EXECUTE msdb.dbo.sp_add_jobstep @job_name = @JobName10, @step_name = @JobName10, @subsystem = 'CMDEXEC', @command = @JobCommand10, @output_file_name = @OutputFile10
    EXECUTE msdb.dbo.sp_add_jobserver @job_name = @JobName10
  END

  IF NOT EXISTS (SELECT * FROM msdb.dbo.sysjobs WHERE [name] = @JobName11)
  BEGIN
    EXECUTE msdb.dbo.sp_add_job @job_name = @JobName11, @description = @JobDescription, @category_name = @JobCategory, @owner_login_name = @JobOwner
    EXECUTE msdb.dbo.sp_add_jobstep @job_name = @JobName11, @step_name = @JobName11, @subsystem = 'CMDEXEC', @command = @JobCommand11, @output_file_name = @OutputFile11
    EXECUTE msdb.dbo.sp_add_jobserver @job_name = @JobName11
  END

END
GO