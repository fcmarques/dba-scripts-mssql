--kill 2830
select a.spid,a.blocked,a.status,a.lastwaittype, a.cpu ,a.physical_io, a.hostname,a.cmd,db_name(a.dbid) as banco,a.program_name,b.text, a.open_tran, a.cmd
from sys.sysprocesses as a cross apply sys.dm_exec_sql_text(a.sql_handle) as b 
where
 a.status != 'sleeping'
 --hostname like '%R-AUTCSRV1%'
--and a.dbid = db_id('Midwayautorizador')
--and a.cmd = 'BACKUP DATABASE '
--spid = 2830
 --b.text like '%pr_accr_ades_data_calc_filial_s%'

order by a.cpu  desc
--select db_name(a.database_id),a.session_id,a.percent_complete from sys.dm_exec_requests  as a
--where a.command like 'backup%'

--select @@ROWCOUNT
select count (a.spid),a.blocked
from sys.sysprocesses as a
where a.blocked != 0
group by a.blocked
		having count (a.spid) >1
order by 2 desc
 --dbcc sqlperf (logspace)
 
--sp_msforeachdb 'use ? checkpoint'

select session_id,d.name,
convert (varchar(50),(estimated_completion_time/3600000))+'hrs' +
convert (varchar(50), ((estimated_completion_time%3600000)/60000))+'min' +
convert (varchar(50), (((estimated_completion_time%3600000)%60000)/1000))+ 'sec'
as Estimated_Completion_Time, 
command, round(percent_complete,2) as percent_complete
from sys.dm_exec_requests as s
inner join sys.databases as d
ON s.database_id = d.database_id
where 
--s.session_id = 52
command like '%restore%'

--exec xp_cmdshell 'wmic /node:sisfin05 computersystem get username'


--select * from sys.sysprocesses where spid = 280

--select spid, login_time, last_batch, hostname,program_name, hostprocess, cmd as status from sys.sysprocesses where spid = '62'

