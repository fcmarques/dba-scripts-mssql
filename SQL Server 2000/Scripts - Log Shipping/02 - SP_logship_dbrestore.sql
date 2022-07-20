
/*-----------------------------------------------------------
This procedure  Initializes the backups  needed for log shipping on the target server 
USAGE: EXEC TESTE_LOG_SHIPING_TARGET.dbo.sp_logship_dbrestore ,<'dbname'>, 'L:\Undo.DAT', 'D:\MSSQL\Data\db_Data.MDF', 'L:\MSSQL\Data\db_log.LDF', '\\VSQL01V\Odimo_DB_Target\BackupInit.BAK'

--@DBNAME - <'dbname'>
--@UndoFile - <'L:\Undo.DAT'>
--@DataFile - <'D:\MSSQL\Data\DB_Data.MDF'>
--@LOGFILE - <'L:\MSSQL\Data\DB_log.LDF'>
--@BackupLocation - <'networkshare\BackupInit.BAK'>
----------------------------------*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS OFF 
GO
alter PROCEDURE DBO.sp_logship_dbrestore
	@DBName Sysname,
	@UndoFile varchar(100),
	@DATAFILE VARCHAR(100),
	@LOGFILE VARCHAR(100),
	@BACKUPLOCATION VARCHAR (100)
AS
--RESTORE DB FROM BACKUPLOCATION in STANDBY MODE
RESTORE DATABASE @dbname
FROM DISK = @BackupLocation
WITH 
  MOVE 'TESTE_LOG_SHIPING_SOURCE' TO @DATAFILE,
  MOVE 'TESTE_LOG_SHIPING_SOURCE_log' TO @LOGFILE,
  STANDBY = @UNDOFILE
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

/* TEST FOR STEP 2

 --RESTORE DB in Standby mode for Log Shipping

EXEC dbo.sp_logship_dbrestore 
	TESTE_LOG_SHIPING_TARGET, 
	'D:\Projetos\Campinas\LOG_SHIPPING\UndoFileDir\Undo.DAT', 
	'D:\Projetos\Campinas\LOG_SHIPPING\Data\db_Data.MDF', 
	'D:\Projetos\Campinas\LOG_SHIPPING\Data\db_log.LDF', 
	'D:\Projetos\Campinas\LOG_SHIPPING\CURRENTBACKUP\BACK_TESTE_FULL_TESTE.BAK'
 GO
*/
