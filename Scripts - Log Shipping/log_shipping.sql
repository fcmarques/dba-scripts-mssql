/*====================================================================
LOG SHIPPING FROM SCRATCH

This set of stored Procedures is all you need to setup a good log shipping 
framework in your organization Two of them will be put into scheduled 
SQL SERVER AGENT JOBS to run and backup, copy and apply logs at a schedule 
you determine.

Feel Free to Contact me with any questions....
Adam Jorgensen
07/17/2005
adamJ@Diamond.com
====================================================================*/

/*-----------------------------------------------------------
This procedure  Initializes the backups  needed for log shipping and copies them to your target Server
USAGE:  EXEC SOURCE>MASTER.dbo.Sp_logship_init <'dbname'>,'\\networkShare\BackupInit.bak',  ' \\target\networkshare\'
-- @DBNAME - <'dbname'>
-- @CURRENTBACKUPFILE - '\\networkShare\BackupInit.bak'
-- @LOGTARGETSHARE - ' \\target\networkshare\' 
--------------------------------------------------------------- */
USE LOG_SHIPPING_MONITOR
GO
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS OFF 
GO
CREATE PROCEDURE DBO.SP_LogShip_Init
	@DBName Sysname,
	@CURRENTBACKUPFILE VARCHAR (100),
	@LOGTARGETSHARE VARCHAR (100)
AS
DECLARE 
@SQL  VARCHAR (256)
--CREATE BACKUP DEVICE
		EXEC sp_addumpdevice 'disk', 'DBBackupInit', @CURRENTBACKUPFILE
		PRINT 'BACKUP DEVICE CREATED'
--BACKUP LOG TO DEVICE
		BACKUP Database @DBName
		TO DBBackupInit
		PRINT 'BACKUP COMPLETED'
--Copy File To Target Server - suppressing Possible Overwrite with /Y
		SELECT @SQL = 'xcopy ' + @CURRENTBACKUPFILE + @LOGTargetShare+' /Y'
		EXEC master.dbo.xp_cmdshell @SQL
		PRINT 'FILE COPY COMPLETE'
--DROP BACKUP DEVICE SO IT CAN BE USED NEXT TIME - SIMPLE TO REPLACE WITH IF/EXISTS CHECK @ THE TOP
		EXEC sp_dropdevice 'DBBackupInit'
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

--EXEC LOG_SHIPPING_MONITOR.dbo.Sp_logship_init 'TESTE_LOG_SHIPING_SOURCE', 'D:\LOG_SHIPPING\CURRENTBACKUP\BACK_TESTE_FULL_TESTE.BAK', ' D:\LOG_SHIPPING\LOGTARGETSHARE\'

----------------------------------*/
/*TEST FOR STEP 1
 --CREATE BACKUP OF DB and Copy to Verio
 GO
*/
/*==============================================================================*/

/*-----------------------------------------------------------
This procedure  Initializes the backups  needed for log shipping on the target server 
USAGE: EXEC TESTE_LOG_SHIPING_TARGET.dbo.sp_logship_dbrestore ,<'dbname'>, 'L:\Undo.DAT', 'D:\MSSQL\Data\db_Data.MDF', 'L:\MSSQL\Data\db_log.LDF', '\\VSQL01V\Odimo_DB_Target\BackupInit.BAK'

--@DBNAME - <'dbname'>
--@UndoFile - <'L:\Undo.DAT'>
--@DataFile - <'D:\MSSQL\Data\DB_Data.MDF'>
--@LOGFILE - <'L:\MSSQL\Data\DB_log.LDF'>
--@BackupLocation - <'networkshare\BackupInit.BAK'>
----------------------------------*/
USE LOG_SHIPPING_MONITOR
GO
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS OFF 
GO
ALTER PROCEDURE DBO.sp_logship_dbrestore
	@DBName Sysname,
	@UndoFile varchar(12),
	@DATAFILE VARCHAR(100),
	@LOGFILE VARCHAR(100),
	@BACKUPLOCATION VARCHAR (50)
AS
--RESTORE DB FROM BACKUPLOCATION in STANDBY MODE
RESTORE DATABASE @dbname
FROM DISK = @BackupLocation
WITH 
  MOVE 'TESTE_LOG_SHIPING_Data' TO @DATAFILE,
  MOVE 'TESTE_LOG_SHIPING_Log' TO @LOGFILE,
  STANDBY = @UNDOFILE
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
--EXEC LOG_SHIPPING_MONITOR.dbo.sp_logship_dbrestore TESTE_LOG_SHIPING_TARGET, 'D:\LOG_SHIPPING\UndoFileDir\Undo.DAT', 'D:\LOG_SHIPPING\Data\db_Data.MDF', 'D:\LOG_SHIPPING\Data\db_log.LDF', 'D:\LOG_SHIPPING\CURRENTBACKUP\BACK_TESTE_FULL_TESTE.BAK'
----------------------------------*/
/* TEST FOR STEP 2
 --RESTORE DB in Standby mode for Log Shipping
 EXEC TESTE_LOG_SHIPING_TARGET.dbo.sp_logship_dbrestore ,<'dbname'>, 'L:\Undo.DAT', 
	'D:\MSSQL\Data\db_Data.MDF', 'L:\MSSQL\Data\db_log.LDF', 
	'\\VSQL01V\Odimo_DB_Target\BackupInit.BAK'
 GO
*/
/*---------------------------------*/
/*==============================================================================*/
----------------------------------*/
--This procedure  backs the log up from the Source Server and pushes it to the Target Server
-- USAGE EXEC MASTER.DBO.SP_LOGSHIP <'DBNAME'>, '<NETWORKSHARE>\LogShip.TRN', '<NETWORKSHARE> /Y', ' <NETWORKSHARE> /Y'
	-- @DBNAME - <'DBNAME'>
	-- @LOGBACKUPSHARE - '<NETWORKSHARE>\LogShip.TRN'
	-- @TARGETLOGSHARE - ' <NETWORKSHARE> /Y'
	-- @SOURCEARCHIVE - ' <NETWORKSHARE> /Y'
----------------------------------*/
USE LOG_SHIPPING_MONITOR
GO
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS OFF 
GO
CREATE PROCEDURE DBO.SP_LogShip
	@DBName Sysname,
	@LOGBACKUPSHARE VARCHAR(100),
	@TARGETLOGSHARE  VARCHAR(100),
	@VERIOSHARE VARCHAR(100),
	@SOURCEARCHIVE VARCHAR(100)
AS
DECLARE
	@SQL Varchar (256)
--CREATE BACKUP DEVICE
EXEC sp_addumpdevice 'disk', 'LogShipSource', @LOGBACKUPSHARE
--BACKUP LOG TO DEVICE
BACKUP LOG @DBname
TO LogShipSource
--Copy File To Target Server
 SELECT @SQL = 'xcopy ' + @LOGBACKUPSHARE + @TARGETLOGSHARE
 EXEC master.dbo.xp_cmdshell @SQL
--Archive File - YOU WILL WANT TO ADD YOUR OWN INCREMENTING SCHEME TO THE FILENAMES
 SELECT @SQL = 'xcopy ' + @LOGBACKUPSHARE + @SOURCEARCHIVE
 EXEC master.dbo.xp_cmdshell @SQL
--Drop BackupDevice
 EXEC sp_dropdevice 'LogShipSource'
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

EXEC LOG_SHIPPING_MONITOR.DBO.SP_LOGSHIP TESTE_LOG_SHIPING_SOURCE, 'D:\LOG_SHIPPING\TARGET\LogShip.TRN', ' D:\LOG_SHIPPING\log_target', 'D:\LOG_SHIPPING\TARGET /Y', ' D:\LOG_SHIPPING\TARGET /Y'
----------------------------------*/
/* TEST FOR STEP 3
--BACKUP LOG ON SOURCE AND MOVE TO TARGET
USAGE EXEC MASTER.DBO.SP_LOGSHIP 
		<'DBNAME'>, 
		'<NETWORKSHARE>\LogShip.TRN', 
		'<NETWORKSHARE> /Y', 
		' <NETWORKSHARE> /Y'
 GO
*/
/*---------------------------------*/
/*==============================================================================*/
----------------------------------*/
--This procedure  backs the log up from the Source Server and pushes it to the Target Server
--USAGE EXEC TESTE_LOG_SHIPING_TARGET.DBO.SP_LogShip_APPLYLOGS <'DBNAME'>,  '<NETWORKSHARE>\LogShip.TRN', ' <NETWORKSHARE> /Y'
	--@DBNAME SYSNAME,  - <'DBNAME'>
	--@LOGLOCATION VARCHAR(100), -  '<NETWORKSHARE>\LogShip.TRN'
	--@LOGARCHIVE VARCHAR (50) - ' <NETWORKSHARE> /Y'
----------------------------------*/
USE LOG_SHIPPING_MONITOR
GO
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS OFF 
GO
ALTER PROCEDURE DBO.SP_LogShip_APPLYLOGS
		@DBNAME SYSNAME,
		@LOGLOCATION VARCHAR(100),
		@LOGARCHIVE VARCHAR (50)
AS
DECLARE 
	@SQL VARCHAR (256)
--Apply Transaction LOG and Recover Database
	RESTORE LOG @DBNAME FROM DISK = @LOGLOCATION WITH NORECOVERY
--	SELECT @SQL = 'RESTORE LOG '+@DBNAME+' FROM DISK = '+@LOGLOCATION+ ' WITH NORECOVERY'
--	EXEC @SQL
--ARCHIVE LOG FILE ON TARGET
	SELECT @SQL = 'xcopy ' + @LOGLOCATION + @LOGARCHIVE
	EXEC master.dbo.xp_cmdshell @SQL
--Delete Existing File
	SELECT @SQL = 'DEL ' + @LOGLOCATION
	EXEC master.dbo.xp_cmdshell @SQL
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

EXEC LOG_SHIPPING_MONITOR.DBO.SP_LogShip_APPLYLOGS TESTE_LOG_SHIPING_TARGET,  'D:\LOG_SHIPPING\log_target\LogShip.TRN', ' D:\LOG_SHIPPING\LOGARCHIVE\ /Y'
----------------------------------*/
/* TEST FOR STEP 3
--APPLY LAST LOG BACKED UP AND COPY IT TO TARGET DB THEN RESTORE IT AND ARCHIVE IT TO ARCHIVE LOCATION
EXEC TESTE_LOG_SHIPING_TARGET.DBO.SP_LogShip_APPLYLOGS <'DBNAME'>,  '<NETWORKSHARE>\LogShip.TRN', ' <NETWORKSHARE> /Y'
 GO
*/
/*---------------------------------*/
/*==============================================================================*/
----------------------------------*/
--This procedure  backs the log up from the Source Server and pushes it to the Target Server
--USAGE EXEC TESTE_LOG_SHIPING_TARGET.DBO.SP_LogShiprecover <'DBNAME'>,  '<NETWORKSHARE>\LogShip.TRN', ' <NETWORKSHARE> /Y'
	--@DBNAME SYSNAME,  - <'DBNAME'>
	--@LOGLOCATION VARCHAR(100), -  '<NETWORKSHARE>\LogShip.TRN'
	--@LOGARCHIVE VARCHAR (50) - ' <NETWORKSHARE> /Y'
----------------------------------*/
USE LOG_SHIPPING_MONITOR
GO
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS OFF 
GO

ALTER PROCEDURE DBO.SP_LogShipRecover
		@DBNAME SYSNAME,
		@LOGLOCATION VARCHAR(100),
		@LOGARCHIVE VARCHAR (50)
AS
DECLARE 
	@SQL VARCHAR (256)
--Apply Transaction LOG and Recover Database
RESTORE LOG @DBNAME FROM DISK = @LOGLOCATION WITH RECOVERY
--ARCHIVE LOG FILE ON TARGET
 SELECT @SQL = 'xcopy ' + @LOGLOCATION + @LOGARCHIVE
 EXEC master.dbo.xp_cmdshell @SQL
--Delete Existing File
SELECT @SQL = 'DEL ' + @LOGLOCATION
EXEC master.dbo.xp_cmdshell @SQL

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

EXEC LOG_SHIPPING_MONITOR.DBO.SP_LogShipRecover TESTE_LOG_SHIPING_TARGET,  'D:\LOG_SHIPPING\log_target\LogShip.TRN', ' D:\LOG_SHIPPING\LOGARCHIVE\ /Y'

----------------------------------*/
/* TEST FOR STEP 3
--APPLY LAST LOG BACKED UP AND COPY IT TO TARGET DB THEN RESTORE IT AND ARCHIVE IT TO ARCHIVE LOCATION
EXEC TESTE_LOG_SHIPING_TARGET.DBO.SP_LogShipRecover <'DBNAME'>,  '<NETWORKSHARE>\LogShip.TRN', ' <NETWORKSHARE> /Y'
 GO
*/
/*---------------------------------*/
/*==============================================================================*/
