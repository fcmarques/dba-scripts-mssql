SELECT ags.name as AGGroupName,
	ar.replica_server_name as InstanceName,
	hars.role_desc,
	db_name(drs.database_id) as DBName,
	drs.synchronization_state_desc as SyncState,
	ar.availability_mode_desc as SyncMode,
	CASE drs.is_local WHEN 1 THEN drs.database_id ELSE NULL END as database_id,
	drs.last_hardened_lsn, drs.end_of_log_lsn, drs.last_redone_lsn,
	drs.last_hardened_time, drs.last_redone_time,
	drs.log_send_queue_size, drs.redo_queue_size
	FROM sys.dm_hadr_database_replica_states drs
	LEFT JOIN sys.availability_replicas ar 
		ON drs.replica_id = ar.replica_id
	LEFT JOIN sys.availability_groups ags 
		ON ar.group_id = ags.group_id
	LEFT JOIN sys.dm_hadr_availability_replica_states hars
		ON ar.group_id = hars.group_id and ar.replica_id = hars.replica_id
	ORDER BY ags.name, group_database_id, hars.role_desc, ar.replica_server_name
