<<<<<<< HEAD
USE [BaselineDB]
GO

EXEC sp_CollectConfigData @help = 1
EXEC sp_CollectDatabaseInfo @help = 1
EXEC sp_CollectFileInfo @help = 1
EXEC sp_CollectIOVFStats @help = 1
EXEC sp_CollectPerfmonData @help = 1
EXEC sp_CollectTempDBUsage @help = 1
EXEC sp_CollectWaitStats @help = 1

-------------------------------------

EXEC sp_CollectConfigData
@Retention = 90,
@BypassNonActiveSrvConfError = 1,
@help = 0,
@LogInfo = 1

SELECT * FROM [dbo].[configuration_data]

UPDATE [dbo].[configuration_data] 
SET [capture_date] = DATEADD(day, -91, [capture_date])
WHERE [configuration_id] = 101

UPDATE [dbo].[configuration_data] 
SET [value] = 499, [value_in_use] = 499
WHERE [configuration_id] = 1544

DELETE FROM [dbo].[configuration_data] WHERE [configuration_id] = 102

-------------------------------------

EXEC sp_CollectDatabaseInfo
@Retention = 90,
@help = 0,
@LogInfo = 1

SELECT * FROM [dbo].[database_info]

select * from sys.databases

UPDATE [dbo].[database_info] 
SET [capture_date] = DATEADD(day, -91, [capture_date])
WHERE [database_id] = 1

UPDATE [dbo].[database_info] 
SET [compatibility_level] = 10
WHERE [database_id] = 4

DELETE FROM [dbo].[database_info] 
WHERE [database_name] = 'BaselineDB'

-------------------------------------

EXEC sp_CollectFileInfo
@DestTable = NULL,
@DestSchema = NULL,
@TSMode = 0,
@EmptyTSTable = 0,
@Retention = 90,
@help = 0,
@LogInfo = 1

SELECT * FROM [dbo].[file_info]

SELECT * FROM [dbo].[ts_file_info]

UPDATE [dbo].[file_info] 
SET [capture_date] = DATEADD(day, -91, [capture_date])
WHERE [database_name] = 'master'

-------------------------------------

EXEC sp_CollectIOVFStats
@DestTable = NULL,
@DestSchema  = NULL,
@TSMode = 0,
@EmptyTSTable = 0,
@CollectingInterval  = 1,
@SampleInterval = 10,
@Retention = 90,
@help = 0,
@LogInfo = 1

SELECT * FROM [dbo].[iovf_stats]

UPDATE [dbo].[iovf_stats] 
SET [capture_date] = DATEADD(day, -91, [capture_date])
WHERE [database_name] = 'master'

SELECT * FROM [dbo].[ts_iovf_stats]

-------------------------------------

EXEC sp_CollectPerfmonData
@DestTable = NULL,
@DestSchema = NULL,
@TSMode = 0,
@EmptyTSTable = 0,
@CollectingInterval = 1,
@SampleInterval = 20,
@MeasuringInterval = 3,
@Retention = 90,
@help = 0,
@LogInfo = 1

SELECT * FROM [dbo].[perfmon_data]

select * from sys.dm_os_performance_counters 
WHERE [counter_name] IN ( SELECT [counter_name] FROM [dbo].[filter_performance_counters] 
							WHERE [is_included] = 1 )

UPDATE [dbo].[perfmon_data] 
SET [capture_date] = DATEADD(day, -91, [capture_date])

-------------------------------------

EXEC sp_CollectTempDBUsage
@DestTable = NULL,
@DestSchema = NULL,
@TSMode = 0,
@EmptyTSTable = 0,
@Retention = 90,
@CollectingInterval = 1,
@SampleInterval = 30,
@help = 0,
@LogInfo = 1

SELECT * FROM [dbo].[tempdb_usage]

UPDATE [dbo].[tempdb_usage] 
SET [capture_date] = DATEADD(day, -91, [capture_date])

-------------------------------------

EXEC sp_CollectWaitStats
@DestTable = NULL,
@DestSchema = NULL,
@ResetWaitStats = 1,
@MeasuringInterval = 1,
@TSMode = 1,
@EmptyTSTable = 0,
@Retention = 90,
@help = 0,
@LogInfo = 1

SELECT * FROM [dbo].[wait_stats]

UPDATE [dbo].[wait_stats] 
SET [capture_date] = DATEADD(day, -91, [capture_date])
=======
USE [BaselineDB]
GO

EXEC sp_CollectConfigData @help = 1
EXEC sp_CollectDatabaseInfo @help = 1
EXEC sp_CollectFileInfo @help = 1
EXEC sp_CollectIOVFStats @help = 1
EXEC sp_CollectPerfmonData @help = 1
EXEC sp_CollectTempDBUsage @help = 1
EXEC sp_CollectWaitStats @help = 1

-------------------------------------

EXEC sp_CollectConfigData
@Retention = 90,
@BypassNonActiveSrvConfError = 1,
@help = 0,
@LogInfo = 1

SELECT * FROM [dbo].[configuration_data]

UPDATE [dbo].[configuration_data] 
SET [capture_date] = DATEADD(day, -91, [capture_date])
WHERE [configuration_id] = 101

UPDATE [dbo].[configuration_data] 
SET [value] = 499, [value_in_use] = 499
WHERE [configuration_id] = 1544

DELETE FROM [dbo].[configuration_data] WHERE [configuration_id] = 102

-------------------------------------

EXEC sp_CollectDatabaseInfo
@Retention = 90,
@help = 0,
@LogInfo = 1

SELECT * FROM [dbo].[database_info]

select * from sys.databases

UPDATE [dbo].[database_info] 
SET [capture_date] = DATEADD(day, -91, [capture_date])
WHERE [database_id] = 1

UPDATE [dbo].[database_info] 
SET [compatibility_level] = 10
WHERE [database_id] = 4

DELETE FROM [dbo].[database_info] 
WHERE [database_name] = 'BaselineDB'

-------------------------------------

EXEC sp_CollectFileInfo
@DestTable = NULL,
@DestSchema = NULL,
@TSMode = 0,
@EmptyTSTable = 0,
@Retention = 90,
@help = 0,
@LogInfo = 1

SELECT * FROM [dbo].[file_info]

SELECT * FROM [dbo].[ts_file_info]

UPDATE [dbo].[file_info] 
SET [capture_date] = DATEADD(day, -91, [capture_date])
WHERE [database_name] = 'master'

-------------------------------------

EXEC sp_CollectIOVFStats
@DestTable = NULL,
@DestSchema  = NULL,
@TSMode = 0,
@EmptyTSTable = 0,
@CollectingInterval  = 1,
@SampleInterval = 10,
@Retention = 90,
@help = 0,
@LogInfo = 1

SELECT * FROM [dbo].[iovf_stats]

UPDATE [dbo].[iovf_stats] 
SET [capture_date] = DATEADD(day, -91, [capture_date])
WHERE [database_name] = 'master'

SELECT * FROM [dbo].[ts_iovf_stats]

-------------------------------------

EXEC sp_CollectPerfmonData
@DestTable = NULL,
@DestSchema = NULL,
@TSMode = 0,
@EmptyTSTable = 0,
@CollectingInterval = 1,
@SampleInterval = 20,
@MeasuringInterval = 3,
@Retention = 90,
@help = 0,
@LogInfo = 1

SELECT * FROM [dbo].[perfmon_data]

select * from sys.dm_os_performance_counters 
WHERE [counter_name] IN ( SELECT [counter_name] FROM [dbo].[filter_performance_counters] 
							WHERE [is_included] = 1 )

UPDATE [dbo].[perfmon_data] 
SET [capture_date] = DATEADD(day, -91, [capture_date])

-------------------------------------

EXEC sp_CollectTempDBUsage
@DestTable = NULL,
@DestSchema = NULL,
@TSMode = 0,
@EmptyTSTable = 0,
@Retention = 90,
@CollectingInterval = 1,
@SampleInterval = 30,
@help = 0,
@LogInfo = 1

SELECT * FROM [dbo].[tempdb_usage]

UPDATE [dbo].[tempdb_usage] 
SET [capture_date] = DATEADD(day, -91, [capture_date])

-------------------------------------

EXEC sp_CollectWaitStats
@DestTable = NULL,
@DestSchema = NULL,
@ResetWaitStats = 1,
@MeasuringInterval = 1,
@TSMode = 1,
@EmptyTSTable = 0,
@Retention = 90,
@help = 0,
@LogInfo = 1

SELECT * FROM [dbo].[wait_stats]

UPDATE [dbo].[wait_stats] 
SET [capture_date] = DATEADD(day, -91, [capture_date])
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
