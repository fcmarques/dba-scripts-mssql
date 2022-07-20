select DB_NAME(drs.database_id)as [Database], ag.name as AG_NAME, 
	ar.replica_server_name as Replica, 
	drs.last_hardened_time, drs.last_redone_time,
	DATEDIFF(SECOND,drs.last_redone_time,drs.last_hardened_time) as [Redo Lag (seconds)] ,
	drs.redo_queue_size, DATEDIFF(SECOND, drs.last_received_time, 
	drs.last_sent_time) as 'send lag time', log_send_queue_size  
from sys.dm_hadr_database_replica_states drs join 
	sys.availability_groups ag on ag.group_id = drs.group_id join 
	sys.availability_replicas ar on ar.replica_id = drs.replica_id
