select convert(nvarchar(22),db_name(database_id)) as [database],
case command when 'BACKUP DATABASE' then 'DB' when 'RESTORE DATABASE' then 'DB RESTORE' when 'RESTORE VERIFYON' then 'DB RESTORE/VERIFYING' else 'LOG' end as [type],
start_time as [started],
dateadd(mi,estimated_completion_time/60000,getdate()) as [finishing],
datediff(mi, start_time, (dateadd(mi,estimated_completion_time/60000,getdate()))) - wait_time/60000 as [mins left],
datediff(mi, start_time, (dateadd(mi,estimated_completion_time/60000,getdate()))) as [total wait mins (est)],
convert(varchar(5),cast((percent_complete) as decimal (4,1))) as [% complete],
getdate() as [current time]
from sys.dm_exec_requests
where command in ('BACKUP DATABASE','BACKUP LOG','RESTORE DATABASE','RESTORE VERIFYON')