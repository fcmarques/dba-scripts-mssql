
select distinct 
      j.name as [nome do job],
      convert(char(10), cast(str(h.run_date,8, 0) as datetime), 105) as [data da execu��o],
      --stuff(stuff(right('000000' + cast ( h.run_time as varchar(6 ) ) ,6),5,0,':'),3,0,':') as [hora execu��o],
      --h.run_duration [tempo (ss)],
      case h.run_status when 0 then 'falha'
            when 2 then 'retry'
            when 3 then 'cancelado pelo usu�rio'
            when 4 then 'em execu��o'
      end as [status]
from 
      msdb.dbo.sysjobhistory h 
      inner join msdb.dbo.sysjobs j on j.job_id = h.job_id
where h.run_status<>1 and h.step_id=0
	  and convert(nvarchar(10),h.run_date,105) >= convert(nvarchar(8),getdate()-7,112)	
order by 2 
--order by 
      --j.name, 
      --h.run_date, 
      --h.run_time
