DECLARE @BACK_FILE VARCHAR(40)

set @BACK_FILE = '\\fabio\shared\back_hosp'+ltrim(rtrim((str(year(getdate())))))+ltrim(rtrim((str(month(getdate())))))+ltrim(rtrim((str(DATEPART(HOUR, GETDATE())))))+ltrim(rtrim((str(month(getdate())))))+ltrim(rtrim((str(DATEPART(MINUTE, GETDATE())))))+'.bak'

BACKUP DATABASE BANCO_SANGUE
TO DISK = @BACK_FILE
WITH DIFFERENTIAL
