<<<<<<< HEAD
USE [msdb];
GO

DECLARE @ReturnCode INT;
SELECT @ReturnCode = 0;

-- NOTE: You must replace <database name> with the name of the 
-- mirrored database on which you want to alert and uncomment the 
-- DECLARE statement

DECLARE @dbName NVARCHAR(128);
SELECT @dbName = N'<database name>';

-- NOTE: This script assumes that you are creating the alert on
-- the mirror or principal server instance. If you want to offload
-- processing to another instance, you must change the @namespace 
-- variable as follows: Enter the name of the instance from which 
-- the WMI events will originate. For example, if the instance is 
-- the default instance, use 'MSSQLSERVER'. If the instance is 
-- SVR1\INSTANCE, use 'INSTANCE'
DECLARE @instanceName NVARCHAR(128);
IF (SERVERPROPERTY('InstanceName') IS NOT null)
BEGIN
   SELECT @instanceName = CONVERT(NVARCHAR(128), 
      SERVERPROPERTY('InstanceName'));
END;
ELSE
BEGIN
   SELECT @instanceName = N'MSSQLSERVER';
END;

-- Create an alert on database mirroring state change events
-- Alert: Alert [DB Mirroring: State Changes]
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE 
   name=N'Database Mirroring' AND category_class=2)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'ALERT', 
   @type=N'NONE', @name=N'Database Mirroring';
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO Quit_Alert;

END;

DECLARE @namespace NVARCHAR(200);
DECLARE @wquery NVARCHAR(200);
DECLARE @alertName NVARCHAR(200);

-- ***************
-- Create a set of alerts based on performance warnings
-- ***************

-- Create [DBM Perf: Unsent Log Threshold (<dbname>]
SELECT @alertName = N'DBM Perf: Unsent Log Threshold ('
      + @dbName + ')';
EXEC msdb.dbo.sp_add_alert 
   @name=@alertName, 
   @category_name=N'Database Mirroring',
   @database_name = @dbName,
   @message_id=32042, 
   @severity=0, 
   @delay_between_responses=1800, 
   @include_event_description_in=0,
   @enabled=0;

-- Create [DBM Perf: Oldest Unsent Transaction Threshold (<dbname>]
SELECT @alertName = N'DBM Perf: Oldest Unsent Transaction Threshold ('
      + @dbName + ')';
EXEC msdb.dbo.sp_add_alert 
   @name=@alertName, 
   @category_name=N'Database Mirroring',
   @database_name = @dbName,
   @message_id=32040, 
   @severity=0, 
   @delay_between_responses=1800, 
   @include_event_description_in=0,
   @enabled=0;

-- Create [DBM Perf: Unrestored Log Threshold (<dbname>]
SELECT @alertName = N'DBM Perf: Unrestored Log Threshold ('
      + @dbName + ')';
EXEC msdb.dbo.sp_add_alert 
   @name=@alertName, 
   @category_name=N'Database Mirroring',
   @database_name = @dbName,
   @message_id=32043, 
   @severity=0, 
   @delay_between_responses=1800, 
   @include_event_description_in=0,
   @enabled=0;

-- Create [DBM Perf: Mirror Commit Overhead Threshold (<dbname>]
SELECT @alertName = N'DBM Perf: Mirror Commit Overhead Threshold ('
   + @dbName + ')';
EXEC msdb.dbo.sp_add_alert 
   @name=@alertName, 
   @category_name=N'Database Mirroring',
   @database_name = @dbName,
   @message_id=32044, 
   @severity=0, 
   @delay_between_responses=1800, 
   @include_event_description_in=0,
   @enabled=0;

-- ***************
-- Create a set of alerts based on mirroring states
-- ***************

-- Create [DBM State: Synchronized Principal with Witness (<dbname>)]
SELECT @namespace = N'\\.\root\Microsoft\SqlServer\ServerEvents\' 
   + @instanceName;
SELECT @wquery = N'SELECT * from DATABASE_MIRRORING_STATE_CHANGE 
   WHERE State = 1 AND DatabaseName = ''' + @dbName + '''';
SELECT @alertName = N'DBM State: Synchronized Principal with Witness ('
   + @dbName + ')';
EXEC msdb.dbo.sp_add_alert 
   @name=@alertName, 
   @message_id=0, 
   @severity=0, 
   @enabled=0, 
   @delay_between_responses=0, 
   @include_event_description_in=0, 
   @category_name=N'Database Mirroring', 
   @wmi_namespace=@namespace, 
   @wmi_query=@wquery;

-- Create [DBM State: Synchronized Principal without Witness (<dbname>)]
SELECT @namespace = N'\\.\root\Microsoft\SqlServer\ServerEvents\' 
   + @instanceName;
SELECT @wquery = N'SELECT * from DATABASE_MIRRORING_STATE_CHANGE 
   WHERE State = 2 AND DatabaseName = ''' + @dbName + '''';
SELECT @alertName = N'DBM State: Synchronized Principal without Witness ('
   + @dbName + ')';
EXEC msdb.dbo.sp_add_alert 
   @name=@alertName, 
   @message_id=0, 
   @severity=0, 
   @enabled=0, 
   @delay_between_responses=0, 
   @include_event_description_in=0, 
   @category_name=N'Database Mirroring', 
   @wmi_namespace=@namespace, 
   @wmi_query=@wquery;

-- Create [DBM State: Synchronized Mirror with Witness (<dbname>)]
SELECT @namespace = N'\\.\root\Microsoft\SqlServer\ServerEvents\' 
   + @instanceName;
SELECT @wquery = N'SELECT * from DATABASE_MIRRORING_STATE_CHANGE 
   WHERE State = 3 AND DatabaseName = ''' + @dbName + '''';
SELECT @alertName = N'DBM State: Synchronized Mirror with Witness ('
   + @dbName + ')';
EXEC msdb.dbo.sp_add_alert 
   @name=@alertName, 
   @message_id=0, 
   @severity=0, 
   @enabled=0, 
   @delay_between_responses=0, 
   @include_event_description_in=0, 
   @category_name=N'Database Mirroring', 
   @wmi_namespace=@namespace, 
   @wmi_query=@wquery;;

-- Create [DBM State: Synchronized Mirror without Witness (<dbname>)]
SELECT @namespace = N'\\.\root\Microsoft\SqlServer\ServerEvents\' 
   + @instanceName
SELECT @wquery = N'SELECT * from DATABASE_MIRRORING_STATE_CHANGE 
   WHERE State = 4 AND DatabaseName = ''' + @dbName + ''''
SELECT @alertName = N'DBM State: Synchronized Mirror without Witness ('
   + @dbName + ')'
EXEC msdb.dbo.sp_add_alert 
   @name=@alertName, 
   @message_id=0, 
   @severity=0, 
   @enabled=0, 
   @delay_between_responses=0, 
   @include_event_description_in=0, 
   @category_name=N'Database Mirroring', 
   @wmi_namespace=@namespace, 
   @wmi_query=@wquery;

-- Create [DBM State: Principal Connection Lost (<dbname>)]
SELECT @namespace = N'\\.\root\Microsoft\SqlServer\ServerEvents\' 
   + @instanceName;
SELECT @wquery = N'SELECT * from DATABASE_MIRRORING_STATE_CHANGE 
   WHERE State = 5 AND DatabaseName = ''' + @dbName + '''';
SELECT @alertName = N'DBM State: Principal Connection Lost ('
   + @dbName + ')';
EXEC msdb.dbo.sp_add_alert 
   @name=@alertName, 
   @message_id=0, 
   @severity=0, 
   @enabled=0, 
   @delay_between_responses=0, 
   @include_event_description_in=0, 
   @category_name=N'Database Mirroring', 
   @wmi_namespace=@namespace, 
   @wmi_query=@wquery;

-- Create [DBM State: Mirror Connection Lost (<dbname>)]
SELECT @namespace = N'\\.\root\Microsoft\SqlServer\ServerEvents\' 
   + @instanceName;
SELECT @wquery = N'SELECT * from DATABASE_MIRRORING_STATE_CHANGE 
   WHERE State = 6 AND DatabaseName = ''' + @dbName + '''';
SELECT @alertName = N'DBM State: Mirror Connection Lost ('
   + @dbName + ')';
EXEC msdb.dbo.sp_add_alert 
   @name=@alertName, 
   @message_id=0, 
   @severity=0, 
   @enabled=0, 
   @delay_between_responses=0, 
   @include_event_description_in=0, 
   @category_name=N'Database Mirroring', 
   @wmi_namespace=@namespace, 
   @wmi_query=@wquery;

-- Create [DBM State: Manual Failover (<dbname>)]
SELECT @namespace = N'\\.\root\Microsoft\SqlServer\ServerEvents\' 
   + @instanceName;
SELECT @wquery = N'SELECT * from DATABASE_MIRRORING_STATE_CHANGE 
   WHERE State = 7 AND DatabaseName = ''' + @dbName + '''';
SELECT @alertName = N'DBM State: Manual Failover ('
   + @dbName + ')';
EXEC msdb.dbo.sp_add_alert 
   @name=@alertName, 
   @message_id=0, 
   @severity=0, 
   @enabled=0, 
   @delay_between_responses=0, 
   @include_event_description_in=0, 
   @category_name=N'Database Mirroring', 
   @wmi_namespace=@namespace, 
   @wmi_query=@wquery;

-- Create [DBM State: Automatic Failover (<dbname>)]
SELECT @namespace = N'\\.\root\Microsoft\SqlServer\ServerEvents\' 
   + @instanceName;
SELECT @wquery = N'SELECT * from DATABASE_MIRRORING_STATE_CHANGE 
   WHERE State = 8 AND DatabaseName = ''' + @dbName + '''';
SELECT @alertName = N'DBM State: Automatic Failover ('
   + @dbName + ')';
EXEC msdb.dbo.sp_add_alert 
   @name=@alertName, 
   @message_id=0, 
   @severity=0, 
   @enabled=0, 
   @delay_between_responses=0, 
   @include_event_description_in=0, 
   @category_name=N'Database Mirroring', 
   @wmi_namespace=@namespace, 
   @wmi_query=@wquery;

-- Create [DBM State: Mirroring Suspended (<dbname>)]
SELECT @namespace = N'\\.\root\Microsoft\SqlServer\ServerEvents\' 
   + @instanceName;
SELECT @wquery = N'SELECT * from DATABASE_MIRRORING_STATE_CHANGE 
   WHERE State = 9 AND DatabaseName = ''' + @dbName + '''';
SELECT @alertName = N'DBM State: Mirroring Suspended ('
   + @dbName + ')';
EXEC msdb.dbo.sp_add_alert 
   @name=@alertName, 
   @message_id=0, 
   @severity=0, 
   @enabled=0, 
   @delay_between_responses=0, 
   @include_event_description_in=0, 
   @category_name=N'Database Mirroring', 
   @wmi_namespace=@namespace, 
   @wmi_query=@wquery;

-- Create [DBM State: No Quorum (<dbname>)]
SELECT @namespace = N'\\.\root\Microsoft\SqlServer\ServerEvents\' 
   + @instanceName;
SELECT @wquery = N'SELECT * from DATABASE_MIRRORING_STATE_CHANGE 
   WHERE State = 10 AND DatabaseName = ''' + @dbName + '''';
SELECT @alertName = N'DBM State: No Quorum ('
   + @dbName + ')';
EXEC msdb.dbo.sp_add_alert 
   @name=@alertName, 
   @message_id=0, 
   @severity=0, 
   @enabled=0, 
   @delay_between_responses=0, 
   @include_event_description_in=0, 
   @category_name=N'Database Mirroring', 
   @wmi_namespace=@namespace, 
   @wmi_query=@wquery;

-- Create [DBM State: Synchronizing Mirror (<dbname>)]
SELECT @namespace = N'\\.\root\Microsoft\SqlServer\ServerEvents\' 
   + @instanceName;
SELECT @wquery = N'SELECT * from DATABASE_MIRRORING_STATE_CHANGE 
   WHERE State = 11 AND DatabaseName = ''' + @dbName + '''';
SELECT @alertName = N'DBM State: Synchronizing Mirror ('
   + @dbName + ')';
EXEC msdb.dbo.sp_add_alert 
   @name=@alertName, 
   @message_id=0, 
   @severity=0, 
   @enabled=0, 
   @delay_between_responses=0, 
   @include_event_description_in=0, 
   @category_name=N'Database Mirroring', 
   @wmi_namespace=@namespace, 
   @wmi_query=@wquery;

-- Create [DBM State: Principal Running Exposed (<dbname>)]
SELECT @namespace = N'\\.\root\Microsoft\SqlServer\ServerEvents\' 
   + @instanceName;
SELECT @wquery = N'SELECT * from DATABASE_MIRRORING_STATE_CHANGE 
   WHERE State = 12 AND DatabaseName = ''' + @dbName + '''';
SELECT @alertName = N'DBM State: Principal Running Exposed ('
   + @dbName + ')';
EXEC msdb.dbo.sp_add_alert 
   @name=@alertName, 
   @message_id=0, 
   @severity=0, 
   @enabled=0, 
   @delay_between_responses=0, 
   @include_event_description_in=0, 
   @category_name=N'Database Mirroring', 
   @wmi_namespace=@namespace, 
   @wmi_query=@wquery;

-- Create [DBM State: Synchronizing Principal (<dbname>)]
SELECT @namespace = N'\\.\root\Microsoft\SqlServer\ServerEvents\' 
   + @instanceName;
SELECT @wquery = N'SELECT * from DATABASE_MIRRORING_STATE_CHANGE 
   WHERE State = 13 AND DatabaseName = ''' + @dbName + '''';
SELECT @alertName = N'DBM State: Synchronizing Principal ('
   + @dbName + ')';
EXEC msdb.dbo.sp_add_alert 
   @name=@alertName, 
   @message_id=0, 
   @severity=0, 
   @enabled=0, 
   @delay_between_responses=0, 
   @include_event_description_in=0, 
   @category_name=N'Database Mirroring', 
   @wmi_namespace=@namespace, 
   @wmi_query=@wquery;

=======
USE [msdb];
GO

DECLARE @ReturnCode INT;
SELECT @ReturnCode = 0;

-- NOTE: You must replace <database name> with the name of the 
-- mirrored database on which you want to alert and uncomment the 
-- DECLARE statement

DECLARE @dbName NVARCHAR(128);
SELECT @dbName = N'<database name>';

-- NOTE: This script assumes that you are creating the alert on
-- the mirror or principal server instance. If you want to offload
-- processing to another instance, you must change the @namespace 
-- variable as follows: Enter the name of the instance from which 
-- the WMI events will originate. For example, if the instance is 
-- the default instance, use 'MSSQLSERVER'. If the instance is 
-- SVR1\INSTANCE, use 'INSTANCE'
DECLARE @instanceName NVARCHAR(128);
IF (SERVERPROPERTY('InstanceName') IS NOT null)
BEGIN
   SELECT @instanceName = CONVERT(NVARCHAR(128), 
      SERVERPROPERTY('InstanceName'));
END;
ELSE
BEGIN
   SELECT @instanceName = N'MSSQLSERVER';
END;

-- Create an alert on database mirroring state change events
-- Alert: Alert [DB Mirroring: State Changes]
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE 
   name=N'Database Mirroring' AND category_class=2)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'ALERT', 
   @type=N'NONE', @name=N'Database Mirroring';
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO Quit_Alert;

END;

DECLARE @namespace NVARCHAR(200);
DECLARE @wquery NVARCHAR(200);
DECLARE @alertName NVARCHAR(200);

-- ***************
-- Create a set of alerts based on performance warnings
-- ***************

-- Create [DBM Perf: Unsent Log Threshold (<dbname>]
SELECT @alertName = N'DBM Perf: Unsent Log Threshold ('
      + @dbName + ')';
EXEC msdb.dbo.sp_add_alert 
   @name=@alertName, 
   @category_name=N'Database Mirroring',
   @database_name = @dbName,
   @message_id=32042, 
   @severity=0, 
   @delay_between_responses=1800, 
   @include_event_description_in=0,
   @enabled=0;

-- Create [DBM Perf: Oldest Unsent Transaction Threshold (<dbname>]
SELECT @alertName = N'DBM Perf: Oldest Unsent Transaction Threshold ('
      + @dbName + ')';
EXEC msdb.dbo.sp_add_alert 
   @name=@alertName, 
   @category_name=N'Database Mirroring',
   @database_name = @dbName,
   @message_id=32040, 
   @severity=0, 
   @delay_between_responses=1800, 
   @include_event_description_in=0,
   @enabled=0;

-- Create [DBM Perf: Unrestored Log Threshold (<dbname>]
SELECT @alertName = N'DBM Perf: Unrestored Log Threshold ('
      + @dbName + ')';
EXEC msdb.dbo.sp_add_alert 
   @name=@alertName, 
   @category_name=N'Database Mirroring',
   @database_name = @dbName,
   @message_id=32043, 
   @severity=0, 
   @delay_between_responses=1800, 
   @include_event_description_in=0,
   @enabled=0;

-- Create [DBM Perf: Mirror Commit Overhead Threshold (<dbname>]
SELECT @alertName = N'DBM Perf: Mirror Commit Overhead Threshold ('
   + @dbName + ')';
EXEC msdb.dbo.sp_add_alert 
   @name=@alertName, 
   @category_name=N'Database Mirroring',
   @database_name = @dbName,
   @message_id=32044, 
   @severity=0, 
   @delay_between_responses=1800, 
   @include_event_description_in=0,
   @enabled=0;

-- ***************
-- Create a set of alerts based on mirroring states
-- ***************

-- Create [DBM State: Synchronized Principal with Witness (<dbname>)]
SELECT @namespace = N'\\.\root\Microsoft\SqlServer\ServerEvents\' 
   + @instanceName;
SELECT @wquery = N'SELECT * from DATABASE_MIRRORING_STATE_CHANGE 
   WHERE State = 1 AND DatabaseName = ''' + @dbName + '''';
SELECT @alertName = N'DBM State: Synchronized Principal with Witness ('
   + @dbName + ')';
EXEC msdb.dbo.sp_add_alert 
   @name=@alertName, 
   @message_id=0, 
   @severity=0, 
   @enabled=0, 
   @delay_between_responses=0, 
   @include_event_description_in=0, 
   @category_name=N'Database Mirroring', 
   @wmi_namespace=@namespace, 
   @wmi_query=@wquery;

-- Create [DBM State: Synchronized Principal without Witness (<dbname>)]
SELECT @namespace = N'\\.\root\Microsoft\SqlServer\ServerEvents\' 
   + @instanceName;
SELECT @wquery = N'SELECT * from DATABASE_MIRRORING_STATE_CHANGE 
   WHERE State = 2 AND DatabaseName = ''' + @dbName + '''';
SELECT @alertName = N'DBM State: Synchronized Principal without Witness ('
   + @dbName + ')';
EXEC msdb.dbo.sp_add_alert 
   @name=@alertName, 
   @message_id=0, 
   @severity=0, 
   @enabled=0, 
   @delay_between_responses=0, 
   @include_event_description_in=0, 
   @category_name=N'Database Mirroring', 
   @wmi_namespace=@namespace, 
   @wmi_query=@wquery;

-- Create [DBM State: Synchronized Mirror with Witness (<dbname>)]
SELECT @namespace = N'\\.\root\Microsoft\SqlServer\ServerEvents\' 
   + @instanceName;
SELECT @wquery = N'SELECT * from DATABASE_MIRRORING_STATE_CHANGE 
   WHERE State = 3 AND DatabaseName = ''' + @dbName + '''';
SELECT @alertName = N'DBM State: Synchronized Mirror with Witness ('
   + @dbName + ')';
EXEC msdb.dbo.sp_add_alert 
   @name=@alertName, 
   @message_id=0, 
   @severity=0, 
   @enabled=0, 
   @delay_between_responses=0, 
   @include_event_description_in=0, 
   @category_name=N'Database Mirroring', 
   @wmi_namespace=@namespace, 
   @wmi_query=@wquery;;

-- Create [DBM State: Synchronized Mirror without Witness (<dbname>)]
SELECT @namespace = N'\\.\root\Microsoft\SqlServer\ServerEvents\' 
   + @instanceName
SELECT @wquery = N'SELECT * from DATABASE_MIRRORING_STATE_CHANGE 
   WHERE State = 4 AND DatabaseName = ''' + @dbName + ''''
SELECT @alertName = N'DBM State: Synchronized Mirror without Witness ('
   + @dbName + ')'
EXEC msdb.dbo.sp_add_alert 
   @name=@alertName, 
   @message_id=0, 
   @severity=0, 
   @enabled=0, 
   @delay_between_responses=0, 
   @include_event_description_in=0, 
   @category_name=N'Database Mirroring', 
   @wmi_namespace=@namespace, 
   @wmi_query=@wquery;

-- Create [DBM State: Principal Connection Lost (<dbname>)]
SELECT @namespace = N'\\.\root\Microsoft\SqlServer\ServerEvents\' 
   + @instanceName;
SELECT @wquery = N'SELECT * from DATABASE_MIRRORING_STATE_CHANGE 
   WHERE State = 5 AND DatabaseName = ''' + @dbName + '''';
SELECT @alertName = N'DBM State: Principal Connection Lost ('
   + @dbName + ')';
EXEC msdb.dbo.sp_add_alert 
   @name=@alertName, 
   @message_id=0, 
   @severity=0, 
   @enabled=0, 
   @delay_between_responses=0, 
   @include_event_description_in=0, 
   @category_name=N'Database Mirroring', 
   @wmi_namespace=@namespace, 
   @wmi_query=@wquery;

-- Create [DBM State: Mirror Connection Lost (<dbname>)]
SELECT @namespace = N'\\.\root\Microsoft\SqlServer\ServerEvents\' 
   + @instanceName;
SELECT @wquery = N'SELECT * from DATABASE_MIRRORING_STATE_CHANGE 
   WHERE State = 6 AND DatabaseName = ''' + @dbName + '''';
SELECT @alertName = N'DBM State: Mirror Connection Lost ('
   + @dbName + ')';
EXEC msdb.dbo.sp_add_alert 
   @name=@alertName, 
   @message_id=0, 
   @severity=0, 
   @enabled=0, 
   @delay_between_responses=0, 
   @include_event_description_in=0, 
   @category_name=N'Database Mirroring', 
   @wmi_namespace=@namespace, 
   @wmi_query=@wquery;

-- Create [DBM State: Manual Failover (<dbname>)]
SELECT @namespace = N'\\.\root\Microsoft\SqlServer\ServerEvents\' 
   + @instanceName;
SELECT @wquery = N'SELECT * from DATABASE_MIRRORING_STATE_CHANGE 
   WHERE State = 7 AND DatabaseName = ''' + @dbName + '''';
SELECT @alertName = N'DBM State: Manual Failover ('
   + @dbName + ')';
EXEC msdb.dbo.sp_add_alert 
   @name=@alertName, 
   @message_id=0, 
   @severity=0, 
   @enabled=0, 
   @delay_between_responses=0, 
   @include_event_description_in=0, 
   @category_name=N'Database Mirroring', 
   @wmi_namespace=@namespace, 
   @wmi_query=@wquery;

-- Create [DBM State: Automatic Failover (<dbname>)]
SELECT @namespace = N'\\.\root\Microsoft\SqlServer\ServerEvents\' 
   + @instanceName;
SELECT @wquery = N'SELECT * from DATABASE_MIRRORING_STATE_CHANGE 
   WHERE State = 8 AND DatabaseName = ''' + @dbName + '''';
SELECT @alertName = N'DBM State: Automatic Failover ('
   + @dbName + ')';
EXEC msdb.dbo.sp_add_alert 
   @name=@alertName, 
   @message_id=0, 
   @severity=0, 
   @enabled=0, 
   @delay_between_responses=0, 
   @include_event_description_in=0, 
   @category_name=N'Database Mirroring', 
   @wmi_namespace=@namespace, 
   @wmi_query=@wquery;

-- Create [DBM State: Mirroring Suspended (<dbname>)]
SELECT @namespace = N'\\.\root\Microsoft\SqlServer\ServerEvents\' 
   + @instanceName;
SELECT @wquery = N'SELECT * from DATABASE_MIRRORING_STATE_CHANGE 
   WHERE State = 9 AND DatabaseName = ''' + @dbName + '''';
SELECT @alertName = N'DBM State: Mirroring Suspended ('
   + @dbName + ')';
EXEC msdb.dbo.sp_add_alert 
   @name=@alertName, 
   @message_id=0, 
   @severity=0, 
   @enabled=0, 
   @delay_between_responses=0, 
   @include_event_description_in=0, 
   @category_name=N'Database Mirroring', 
   @wmi_namespace=@namespace, 
   @wmi_query=@wquery;

-- Create [DBM State: No Quorum (<dbname>)]
SELECT @namespace = N'\\.\root\Microsoft\SqlServer\ServerEvents\' 
   + @instanceName;
SELECT @wquery = N'SELECT * from DATABASE_MIRRORING_STATE_CHANGE 
   WHERE State = 10 AND DatabaseName = ''' + @dbName + '''';
SELECT @alertName = N'DBM State: No Quorum ('
   + @dbName + ')';
EXEC msdb.dbo.sp_add_alert 
   @name=@alertName, 
   @message_id=0, 
   @severity=0, 
   @enabled=0, 
   @delay_between_responses=0, 
   @include_event_description_in=0, 
   @category_name=N'Database Mirroring', 
   @wmi_namespace=@namespace, 
   @wmi_query=@wquery;

-- Create [DBM State: Synchronizing Mirror (<dbname>)]
SELECT @namespace = N'\\.\root\Microsoft\SqlServer\ServerEvents\' 
   + @instanceName;
SELECT @wquery = N'SELECT * from DATABASE_MIRRORING_STATE_CHANGE 
   WHERE State = 11 AND DatabaseName = ''' + @dbName + '''';
SELECT @alertName = N'DBM State: Synchronizing Mirror ('
   + @dbName + ')';
EXEC msdb.dbo.sp_add_alert 
   @name=@alertName, 
   @message_id=0, 
   @severity=0, 
   @enabled=0, 
   @delay_between_responses=0, 
   @include_event_description_in=0, 
   @category_name=N'Database Mirroring', 
   @wmi_namespace=@namespace, 
   @wmi_query=@wquery;

-- Create [DBM State: Principal Running Exposed (<dbname>)]
SELECT @namespace = N'\\.\root\Microsoft\SqlServer\ServerEvents\' 
   + @instanceName;
SELECT @wquery = N'SELECT * from DATABASE_MIRRORING_STATE_CHANGE 
   WHERE State = 12 AND DatabaseName = ''' + @dbName + '''';
SELECT @alertName = N'DBM State: Principal Running Exposed ('
   + @dbName + ')';
EXEC msdb.dbo.sp_add_alert 
   @name=@alertName, 
   @message_id=0, 
   @severity=0, 
   @enabled=0, 
   @delay_between_responses=0, 
   @include_event_description_in=0, 
   @category_name=N'Database Mirroring', 
   @wmi_namespace=@namespace, 
   @wmi_query=@wquery;

-- Create [DBM State: Synchronizing Principal (<dbname>)]
SELECT @namespace = N'\\.\root\Microsoft\SqlServer\ServerEvents\' 
   + @instanceName;
SELECT @wquery = N'SELECT * from DATABASE_MIRRORING_STATE_CHANGE 
   WHERE State = 13 AND DatabaseName = ''' + @dbName + '''';
SELECT @alertName = N'DBM State: Synchronizing Principal ('
   + @dbName + ')';
EXEC msdb.dbo.sp_add_alert 
   @name=@alertName, 
   @message_id=0, 
   @severity=0, 
   @enabled=0, 
   @delay_between_responses=0, 
   @include_event_description_in=0, 
   @category_name=N'Database Mirroring', 
   @wmi_namespace=@namespace, 
   @wmi_query=@wquery;

>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
Quit_Alert: