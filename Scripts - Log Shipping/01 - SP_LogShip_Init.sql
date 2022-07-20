/*-----------------------------------------------------------
This procedure  Initializes the backups  needed for log shipping and copies them to your target Server
USAGE:  EXEC SOURCE>MASTER.dbo.Sp_logship_init <'dbname'>,'\\networkShare\BackupInit.bak',  ' \\target\networkshare\'
-- @DBNAME - <'dbname'>
-- @CURRENTBACKUPFILE - '\\networkShare\BackupInit.bak'
-- @LOGTARGETSHARE - ' \\target\networkshare\' 
--------------------------------------------------------------- */
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS OFF 
GO
alter PROCEDURE DBO.SP_LogShip_Init
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

/*TEST FOR STEP 1
EXEC dbo.Sp_logship_init 'TESTE_LOG_SHIPING_SOURCE', 'D:\Projetos\Campinas\LOG_SHIPPING\CURRENTBACKUP\BACK_TESTE_FULL_TESTE.BAK', ' D:\Projetos\Campinas\LOG_SHIPPING\TARGETLOGSHARE\'
GO
*/
