--LISTING 1: Undocumented DBCC Command REBUILD_LOG
EXEC sp_configure 'allow updates', 1
RECONFIGURE WITH OVERRIDE
GO

BEGIN TRAN

UPDATE master..sysdatabases
SET status = status | 32768
WHERE name = 'MyDatabase'

IF @@ROWCOUNT = 1
BEGIN
   COMMIT TRAN
   RAISERROR('emergency mode set', 0, 1)
END
ELSE
BEGIN
   ROLLBACK
   RAISERROR('unable to set emergency mode', 16, 1)
END

GO

EXEC sp_configure 'allow updates', 0
RECONFIGURE WITH OVERRIDE
GO

-- Restart SQL Server at this point.

DBCC REBUILD_LOG('MyDatabase','C:\MyDatabase.ldf')


/*Perform physical and logical integrity checks at this point.
Bcp data out if your integrity checks demonstrate that problems exist.
*/

ALTER DATABASE MyDatabase SET MULTI_USER
GO

-- Set database options and recovery model as desired.
GO

