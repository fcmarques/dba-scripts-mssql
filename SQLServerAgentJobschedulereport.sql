USE msdb
GO

SELECT 
               j.name,
               j.enabled,
               ss.active_start_date,
              CAST(ss.active_start_time / 10000 AS VARCHAR(10))  
              + ':' + RIGHT('00' + CAST(ss.active_start_time % 10000 / 100 AS VARCHAR(10)), 2) AS start_time,
              ss.active_end_date,
             CAST(ss.active_end_time / 10000 AS VARCHAR(10))  
             + ':' + RIGHT('00' + CAST(ss.active_end_time % 10000 / 100 AS VARCHAR(10)), 2) AS end_time
             ,ss.freq_interval
             ,ss.freq_type
             ,ss.enabled
FROM dbo.sysjobs j
INNER JOIN dbo.sysjobschedules js ON j.job_id = js.job_id 
INNER JOIN dbo.sysschedules ss ON ss.schedule_id = js.schedule_id 
WHERE 
j.enabled = 1
and ss.enabled =1
