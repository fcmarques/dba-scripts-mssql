-- Summary of SQL Agent jobs
-- job name, typical start time, average duration, average job runs per day, last run date/time, enabled
 
USE msdb
 
DECLARE @job_user sysname
SET @job_user = '[domain]\[account]'
SET @job_user = NULL
 
SELECT
   src2.name AS job_name,
  
   -- -- if a job runs more than once per day, its average start time tends to cluster near mid-day
   -- -- and become a useless measure, so we'll use NULL for these cases
   CASE WHEN src5.avg_runs_per_day = 1 THEN
      RIGHT('00' + CAST(((AVG(src2.start_time_in_seconds)/60)/60) % 60 AS VARCHAR), 2) + ':' +
      RIGHT('00' + CAST((AVG(src2.start_time_in_seconds)/60) % 60 AS VARCHAR), 2) + ':' +
      RIGHT('00' + CAST(AVG(src2.start_time_in_seconds) % 60 AS VARCHAR), 2)
   ELSE
      NULL
   END  AS typical_start_time,
  
   RIGHT('00' + CAST(((AVG(src2.duration_in_seconds)/60)/60) % 60 AS VARCHAR), 2) + ':' +
   RIGHT('00' + CAST((AVG(src2.duration_in_seconds)/60) % 60 AS VARCHAR), 2) + ':' +
   RIGHT('00' + CAST(AVG(src2.duration_in_seconds) % 60 AS VARCHAR), 2)  AS avg_duration,
  
   src5.avg_runs_per_day,
  
  CONVERT(VARCHAR, MAX(src2.run_date_time), 120) AS last_run_date_time,
 
  src6.enabled
     
FROM
 
-- -- get our average start time and average duration by job name
(
   SELECT
      CAST(SUBSTRING(convert(VARCHAR, run_date_time, 121), 12, 2) AS INT) * 60 * 60 +
      CAST(SUBSTRING(convert(VARCHAR, run_date_time, 121), 15, 2) AS INT) * 60 +
      CAST(SUBSTRING(convert(VARCHAR, run_date_time, 121), 18, 2) AS INT) AS start_time_in_seconds,
 
      CAST(SUBSTRING(run_duration, 1, 2) AS INT) * 60 * 60 +
      CAST(SUBSTRING(run_duration, 4, 2) AS INT) * 60 +
      CAST(SUBSTRING(run_duration, 7, 2) AS INT) AS duration_in_seconds,
     
      run_date_time,
     
      name
   FROM
   (
      SELECT
         sj.NAME,
        
         cast(  
         SUBSTRING(CAST(run_date AS VARCHAR), 1, 4) + '-' +
         SUBSTRING(CAST(run_date AS VARCHAR), 5, 2) + '-' +
         SUBSTRING(CAST(run_date AS VARCHAR), 7, 2) + ' ' +
         SUBSTRING(RIGHT('00000' + CAST(run_time AS VARCHAR), 6), 1, 2) + ':' +
         SUBSTRING(RIGHT('00000' + CAST(run_time AS VARCHAR), 6), 3, 2) + ':' +
         SUBSTRING(RIGHT('00000' + CAST(run_time AS VARCHAR), 6), 5, 2)
         AS DATETIME) AS run_date_time,
        
         SUBSTRING(RIGHT('00000' + CAST(run_duration AS VARCHAR), 6), 1, 2) + ':' +
         SUBSTRING(RIGHT('00000' + CAST(run_duration AS VARCHAR), 6), 3, 2) + ':' +
         SUBSTRING(RIGHT('00000' + CAST(run_duration AS VARCHAR), 6), 5, 2)
         AS run_duration
      FROM
         sysjobhistory AS jh
            INNER JOIN sysjobs AS sj
               ON jh.[job_id] = sj.[job_id]
               AND jh.step_name = '(Job outcome)'
      WHERE
         -- -- we only want to know about jobs that were running because they were scheduled or because
         -- -- they were called by another job
            jh.MESSAGE LIKE 'The job succeeded.  The Job was invoked by Schedule%'
            OR jh.MESSAGE LIKE 'The job succeeded.  The job was invoked by User ' + @job_user + '%'
            OR jh.MESSAGE LIKE 'The job failed.  The Job was invoked by Schedule%'
            OR jh.MESSAGE LIKE 'The job failed.  The job was invoked by User ' + @job_user + '%'
   ) AS src
) AS src2
 
-- -- we have average start time and average duration.  now, let's get join in average runs per day by job name
INNER JOIN
(
   SELECT
      name AS job_name,
      AVG(runs_per_day) AS avg_runs_per_day
   FROM
   (
      SELECT
         NAME,
         COUNT(run_duration) AS runs_per_day
      FROM
      (
         SELECT
            sj.NAME,
           
            cast(  
            SUBSTRING(CAST(run_date AS VARCHAR), 1, 4) + '-' +
            SUBSTRING(CAST(run_date AS VARCHAR), 5, 2) + '-' +
            SUBSTRING(CAST(run_date AS VARCHAR), 7, 2) + ' ' +
            SUBSTRING(RIGHT('00000' + CAST(run_time AS VARCHAR), 6), 1, 2) + ':' +
            SUBSTRING(RIGHT('00000' + CAST(run_time AS VARCHAR), 6), 3, 2) + ':' +
            SUBSTRING(RIGHT('00000' + CAST(run_time AS VARCHAR), 6), 5, 2)
            AS DATETIME) AS run_date_time,
           
            SUBSTRING(RIGHT('00000' + CAST(run_duration AS VARCHAR), 6), 1, 2) + ':' +
            SUBSTRING(RIGHT('00000' + CAST(run_duration AS VARCHAR), 6), 3, 2) + ':' +
            SUBSTRING(RIGHT('00000' + CAST(run_duration AS VARCHAR), 6), 5, 2)
            AS run_duration
         FROM
            sysjobhistory AS jh
               INNER JOIN sysjobs AS sj
                  ON jh.[job_id] = sj.[job_id]
                  AND jh.step_name = '(Job outcome)'
         WHERE
         -- -- we only want to know about jobs that were running because they were scheduled or because
         -- -- they were called by another job
            jh.MESSAGE LIKE 'The job succeeded.  The Job was invoked by Schedule%'
            OR jh.MESSAGE LIKE 'The job succeeded.  The job was invoked by User ' + @job_user + '%'
            OR jh.MESSAGE LIKE 'The job failed.  The Job was invoked by Schedule%'
            OR jh.MESSAGE LIKE 'The job failed.  The job was invoked by User ' + @job_user + '%'
      ) AS src3
      GROUP BY
         name,
         CONVERT(VARCHAR, run_date_time,112)
      ) AS src4
      GROUP BY
         NAME
   ) AS src5
   ON src2.NAME = src5.job_name
 
INNER JOIN sysjobs AS src6
   ON src2.NAME = src6.NAME
  
GROUP BY
   src2.NAME,
   src5.avg_runs_per_day,
   src6.enabled
  
ORDER BY
   typical_start_time DESC,
   last_run_date_time ASC