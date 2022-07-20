--create table #ErrorLog(
--	LogDate datetime,
--	ProcessInfo varchar(100),
--	Text varchar(max)
--)

--insert into #ErrorLog EXEC sys.xp_readerrorlog


SELECT Min(logdate)                LogStart, 
       Max(logdate)                LogEnd, 
       DATEDIFF(HH,Min(logdate),Max(logdate)) as LogDeltaHours,
       COUNT(*) as Errors,
       COUNT(*)/DATEDIFF(HH,Min(logdate),Max(logdate)) as ErrorsRate
FROM   #errorlog 
WHERE  text LIKE '%Login Failed%' 
ORDER  BY 1 DESC 

--drop table #ErrorLog