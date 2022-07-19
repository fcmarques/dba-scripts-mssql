<<<<<<< HEAD
USE msdb
GO
CHECKPOINT 
GO

DECLARE @XXX INT
SET @XXX = -1000

WHILE @XXX <= -30
BEGIN
	PRINT @XXX
	DECLARE @CleanupDate datetime;
	SET @CleanupDate = DATEADD(dd,@XXX,GETDATE());
	EXECUTE dbo.sp_delete_backuphistory @oldest_date = @CleanupDate;
	EXECUTE dbo.sp_purge_jobhistory @oldest_date = @CleanupDate;
	DBCC SHRINKFILE (N'MSDBLog' , 0)
	SET @XXX = @XXX + 10
END

CHECKPOINT 
GO
DBCC SHRINKFILE (N'MSDBData' , 0)
GO
=======
USE msdb
GO
CHECKPOINT 
GO

DECLARE @XXX INT
SET @XXX = -1000

WHILE @XXX <= -30
BEGIN
	PRINT @XXX
	DECLARE @CleanupDate datetime;
	SET @CleanupDate = DATEADD(dd,@XXX,GETDATE());
	EXECUTE dbo.sp_delete_backuphistory @oldest_date = @CleanupDate;
	EXECUTE dbo.sp_purge_jobhistory @oldest_date = @CleanupDate;
	DBCC SHRINKFILE (N'MSDBLog' , 0)
	SET @XXX = @XXX + 10
END

CHECKPOINT 
GO
DBCC SHRINKFILE (N'MSDBData' , 0)
GO
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
