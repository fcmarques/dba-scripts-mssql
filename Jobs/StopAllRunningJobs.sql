USE msdb;
GO
 
-- Stop Multiple running SQL Jobs at once:
DECLARE @dynSql NVARCHAR(MAX) = ''
 
SELECT @dynSql += N' msdb.dbo.sp_stop_job @job_name = ''' + j.name + N''''
            + CHAR(10) + CHAR(13)
FROM msdb.dbo.sysjobs j
JOIN msdb.dbo.sysjobactivity AS ja 
ON ja.job_id = j.job_id
WHERE ja.start_execution_date IS NOT NULL
AND ja.stop_execution_date IS NULL
ORDER BY j.name;
 
PRINT @dynSql;
GO