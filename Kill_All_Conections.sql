USE master
GO

SET NOCOUNT ON

DECLARE @DBName VARCHAR(50)
DECLARE @spidstr VARCHAR(8000)
DECLARE @ConnKilled SMALLINT

SET @ConnKilled = 0
SET @spidstr = ''

SELECT @spidstr = coalesce(@spidstr, ',') + 'kill ' + convert(VARCHAR, spid) + '; '
FROM master..sysprocesses
WHERE spid > 50

IF LEN(@spidstr) > 0
BEGIN
	EXEC (@spidstr)

	SELECT @ConnKilled = COUNT(1)
	FROM master..sysprocesses
END
