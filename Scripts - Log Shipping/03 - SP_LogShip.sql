--This procedure  backs the log up from the Source Server and pushes it to the Target Server
-- USAGE EXEC MASTER.DBO.SP_LOGSHIP <'DBNAME'>, '<NETWORKSHARE>\LogShip.TRN', '<NETWORKSHARE> /Y', ' <NETWORKSHARE> /Y'
	-- @DBNAME - <'DBNAME'>
	-- @LOGBACKUPSHARE - '<NETWORKSHARE>\'
	-- @TARGETLOGSHARE - ' <NETWORKSHARE> /Y'
	-- @SOURCEARCHIVE - ' <NETWORKSHARE> /Y'
----------------------------------*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS OFF 
GO
create PROCEDURE DBO.SP_LogShip
	@DBName Sysname,
	@LOGBACKUPSHARE VARCHAR(100),
	@TARGETLOGSHARE  VARCHAR(100),
	@SOURCEARCHIVE VARCHAR(100)
AS
DECLARE
	@SQL Varchar (256),
	@TimeStamp varchar(1000),
	@LogShipFile varchar(1000)
	
set @TimeStamp = replace(replace(replace(CONVERT(varchar, CURRENT_TIMESTAMP , 120), '-',''),':',''),' ','')
set @LogShipFile = @LOGBACKUPSHARE + 'BackUpLog_' + @DBName + '_' + @TimeStamp + '.TRN'
print @LogShipFile
--CREATE BACKUP DEVICE
EXEC sp_addumpdevice 'disk', 'LogShipSource', @LogShipFile
--BACKUP LOG TO DEVICE
BACKUP LOG @DBname
TO LogShipSource
--Copy File To Target Server
 SELECT @SQL = 'xcopy ' + @LogShipFile + @TARGETLOGSHARE
 EXEC master.dbo.xp_cmdshell @SQL
--Archive File - YOU WILL WANT TO ADD YOUR OWN INCREMENTING SCHEME TO THE FILENAMES
 SELECT @SQL = 'xcopy ' + @LogShipFile + @SOURCEARCHIVE
 EXEC master.dbo.xp_cmdshell @SQL
--Drop BackupDevice
 EXEC sp_dropdevice 'LogShipSource'
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

----------------------------------*/
/* TEST FOR STEP 3
--BACKUP LOG ON SOURCE AND MOVE TO TARGET
EXEC DBO.SP_LOGSHIP 
	TESTE_LOG_SHIPING_SOURCE, 
	'D:\Projetos\Campinas\LOG_SHIPPING\LOGBACKUPSHARE\', 
	' D:\Projetos\Campinas\LOG_SHIPPING\TARGETLOGSHARE', 
	' D:\Projetos\Campinas\LOG_SHIPPING\SOURCEARCHIVE /Y'
 GO
*/
/*---------------------------------*/
