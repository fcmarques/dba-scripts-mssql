USE master
GO
SET NOCOUNT ON

DECLARE @now DATETIME
DECLARE @today VARCHAR(10), @time VARCHAR(8), @futureDate VARCHAR(20)
DECLARE @dtToday DATETIME, @dtTime DATETIME, @dtFutureDate DATETIME
DECLARE @interval INT

SELECT @interval = 0
SELECT @now = GETDATE()

SELECT @today = CONVERT(VARCHAR(10), @now, 120),
       @time = SUBSTRING( CONVERT(VARCHAR(19), @now, 120), 12, 8)

SELECT @dtToday = CAST( @today AS DATETIME ),
       @dtTime = CAST( @time AS DATETIME )

SELECT Day = @today, Time = @time

IF @dtTime < '06:00:00' 
BEGIN
   SET @futureDate = @today + ' ' + '06:00:00'
   SET @dtFutureDate = CAST( @futureDate AS DATETIME )
END
ELSE IF @dtTime < '18:00:00'
BEGIN
   SET @futureDate = @today + ' ' + '18:00:00'
   SET @dtFutureDate = CAST( @futureDate AS DATETIME )
END
ELSE 
BEGIN
   SET @futureDate = @today + ' ' + '06:00:00'
   SET @dtFutureDate = CAST( @futureDate AS DATETIME )
   SET @dtFutureDate = DATEADD(day, 1, @dtFutureDate)
END

SELECT Endtime = @dtFutureDate

EXEC spBlockerPFE @dtFutureDate
GO
