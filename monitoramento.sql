insert into mondaniel (wait_type,waiting_tasks_count,wait_time_ms,max_wait_time_ms,signal_wait_time_ms,data) 
select wait_type,waiting_tasks_count,wait_time_ms,max_wait_time_ms,signal_wait_time_ms,GETDATE ()
 from sys.dm_os_wait_stats
where waiting_tasks_count <> 0
and wait_time_ms <>0
and max_wait_time_ms <>0
and signal_wait_time_ms <>0