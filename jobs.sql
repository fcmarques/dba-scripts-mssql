select a.name, 
b.status 
from msdb.dbo.sysjobs as a join (SELECT DISTINCT SJH1.job_id
       ,  (SELECT   TOP 1 SJH2.run_status 
             FROM   msdb.dbo.sysjobhistory SJH2
             WHERE  SJH2.job_id   = SJH1.job_id
             AND          SJH2.run_date = SJH1.run_date
             AND          SJH2.run_time = (SELECT MAX(SJH3.run_time)
                                                      FROM   msdb.dbo.sysjobhistory SJH3
                                                      WHERE  SJH3.run_date = SJH1.run_date
                                                      AND    SJH3.job_id   = SJH1.job_id)
             ORDER BY SJH2.run_time DESC) as status
FROM   msdb.dbo.sysjobhistory SJH1
WHERE  SJH1.run_date = CONVERT(VARCHAR,GETDATE(),112)) as b on a.job_id = b.job_id

----
SELECT JobName     = sj.name 
      ,StartDate = sja.start_execution_date 
      ,EndDate   = sja.stop_execution_date 
      ,Status    = CASE  
                   WHEN ISNULL(sjh.run_status,-1) = -1 AND sja.start_execution_date IS NULL AND sja.stop_execution_date IS NULL THEN 'Idle' 
                   WHEN ISNULL(sjh.run_status,-1) = -1 AND sja.start_execution_date IS NOT NULL AND sja.stop_execution_date IS NULL THEN 'Running' 
                   WHEN ISNULL(sjh.run_status,-1) =0  THEN 'Failed' 
                   WHEN ISNULL(sjh.run_status,-1) =1  THEN 'Succeeded' 
                   WHEN ISNULL(sjh.run_status,-1) =2  THEN 'Retry' 
                   WHEN ISNULL(sjh.run_status,-1) =3  THEN 'Canceled' 
                   END 
  FROM MSDB.DBO.sysjobs sj 
  JOIN MSDB.DBO.sysjobactivity sja 
    ON sj.job_id = sja.job_id  
  JOIN (SELECT MaxSessionid = MAX(Session_id) FROM MSDB.DBO.syssessions) ss 
    ON ss.MaxSessionid = sja.session_id 
LEFT JOIN MSDB.DBO.sysjobhistory sjh 
    ON sjh.instance_id = sja.job_history_id
