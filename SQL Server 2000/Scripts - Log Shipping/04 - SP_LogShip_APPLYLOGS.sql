--This procedure  backs the log up from the Source Server and pushes it to the Target Server
--USAGE EXEC TESTE_LOG_SHIPING_TARGET.DBO.SP_LogShip_APPLYLOGS <'DBNAME'>,  '<NETWORKSHARE>\LogShip.TRN', ' <NETWORKSHARE> /Y'
	--@DBNAME SYSNAME,  - <'DBNAME'>
	--@LOGLOCATION VARCHAR(100), -  '<NETWORKSHARE>\LogShip.TRN'
	--@LOGARCHIVE VARCHAR (50) - ' <NETWORKSHARE> /Y'
----------------------------------*/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS OFF 
GO
alter PROCEDURE DBO.SP_LogShip_APPLYLOGS
		@DBNAME SYSNAME,
		@LOGLOCATION VARCHAR(100),
		@LOGARCHIVE VARCHAR (100),
		@UNDOFILE VARCHAR (100),
		@Debug int = 0
AS
DECLARE 
	@SQL VARCHAR (256),
	@File		varchar(128) ,
	@MaxFile	varchar(128) ,
	@cmd 		varchar(2000),
	@FullPath	varchar(2000)
	create table #Dir (s varchar(8000))
	
	select	@cmd = 'dir /B ' + @LOGLOCATION + '*.TRN'
	--print @cmd

	insert #Dir exec master..xp_cmdshell @cmd
	
	delete #Dir where s is null or s like '%not found%'
	
	select	@File = '', @MaxFile = max(s) from #Dir
	while @File < @MaxFile
	begin
		select @File = min(s) from #Dir where s > @File
		select @FullPath = @LOGLOCATION + @File
		if @Debug = 1
			PRINT @FullPath
		else
		begin
		--Apply Transaction LOG and Recover Database
			RESTORE LOG @DBNAME FROM DISK = @FullPath 
			WITH STANDBY = @UNDOFILE
		--ARCHIVE LOG FILE ON TARGET
			SELECT @SQL = 'xcopy ' + @FullPath + @LOGARCHIVE
			EXEC master.dbo.xp_cmdshell @SQL
		--Delete Existing File
			SELECT @SQL = 'DEL ' + @FullPath
			EXEC master.dbo.xp_cmdshell @SQL
		end
	end
	drop table #Dir

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

/* TEST FOR STEP 3
--APPLY LAST LOG BACKED UP AND COPY IT TO TARGET DB THEN RESTORE IT AND ARCHIVE IT TO ARCHIVE LOCATION
ALTER DATABASE TESTE_LOG_SHIPING_TARGET SET SINGLE_USER WITH ROLLBACK IMMEDIATE
EXEC DBO.SP_LogShip_APPLYLOGS 
	TESTE_LOG_SHIPING_TARGET, 
	'D:\Projetos\Campinas\LOG_SHIPPING\TARGETLOGSHARE\', 
	' D:\Projetos\Campinas\LOG_SHIPPING\LOGARCHIVE\ /Y',
	'D:\Projetos\Campinas\LOG_SHIPPING\UndoFileDir\Undo.DAT'

ALTER DATABASE TESTE_LOG_SHIPING_TARGET SET MULTI_USER
 GO
*/
--RESTORE DATABASE TESTE_LOG_SHIPING_TARGET WITH RECOVERY