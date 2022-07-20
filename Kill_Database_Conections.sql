USE master
GO

SET NOCOUNT ON

DECLARE @DBName VARCHAR(50)
DECLARE @spidstr VARCHAR(8000)
DECLARE @ConnKilled SMALLINT

SET @ConnKilled = 0
SET @spidstr = ''
SET @DBName = 'DB_NAME'

IF db_id(@DBName) < 4
BEGIN
	PRINT 'Connections to system databases cannot be killed'

	RETURN
END

SELECT @spidstr = coalesce(@spidstr, ',') + 'kill ' + convert(VARCHAR, spid) + '; '
FROM master..sysprocesses
WHERE dbid = db_id(@DBName)

IF LEN(@spidstr) > 0
BEGIN
	EXEC (@spidstr)

	SELECT @ConnKilled = COUNT(1)
	FROM master..sysprocesses
	WHERE dbid = db_id(@DBName)
END
