ALTER procedure SP_ProcessAllFilesInDir
@FilePath	varchar(1000) ,
@FileMask	varchar(100) ,
@ProcSp		varchar(128) ,
@Debug 		int = 0
as
/*
exec SP_ProcessAllFilesInDir
		@FilePath	= 'F:\LOG_SHIPPING\LOGBACKUPSHARE\' ,
		@FileMask	= '*.trn' ,
		@ProcSp		= '' ,
		@Debug		= 1
*/
set nocount on
	
declare 
	@File		varchar(128) ,
	@MaxFile	varchar(128) ,
	@cmd 		varchar(2000)
	
	create table #Dir (s varchar(8000))
	
	select	@cmd = 'dir /B ' + @FilePath + @FileMask
	insert #Dir exec master..xp_cmdshell @cmd
	
	delete #Dir where s is null or s like '%not found%'
	
	select	@File = '', @MaxFile = max(s) from #Dir
	while @File < @MaxFile
	begin
		select 	@File = min(s) from #Dir where s > @File
		
		select 	@cmd = @ProcSp + ' ''' + @FilePath + @File + ''''
		PRINT @FilePath + @File + ''''
		if @Debug = 1
			select 	@cmd
		else
			exec @cmd
		
	end
	drop table #Dir
go
