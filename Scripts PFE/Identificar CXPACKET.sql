select 
	ost.session_id,
    ost.scheduler_id,
    w.worker_address,
    qp.node_id,
    qp.physical_operator_name,
    ost.task_state,
    wt.wait_type,
    wt.wait_duration_ms,
    qp.cpu_time_ms
	,w.last_wait_type
	
from sys.dm_os_tasks ost
left join sys.dm_os_workers w on ost.worker_address=w.worker_address
left join sys.dm_os_waiting_tasks wt on w.task_address=wt.waiting_task_address
    and wt.session_id=ost.session_id
left join sys.dm_exec_query_profiles qp on w.task_address=qp.task_address
--left join sys.dm_os_threads t on t.worker_address = w.worker_address
where ost.session_id=76
order by scheduler_id, w.worker_address, node_id;
 