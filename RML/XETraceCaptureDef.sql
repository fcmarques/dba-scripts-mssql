/***************************************************
Nov 2009

This XE trace definition provides capture support for replay and full reporting functionality.

Instructions
============
	Change the @strFileName e.g., 'C:\temp\MyServer_xe_trace'
***************************************************/
use master
go

if(1 = (select COUNT(*) from sys.dm_xe_sessions where name = 'XERMLCapture'))
begin
	alter event session XERMLCapture on server state = stop
end
go

if(1 = (select COUNT(*) from sys.server_event_sessions where name = 'XERMLCapture'))
begin
	drop event session XERMLCapture on server
end
go

declare @strFileName		nvarchar(256)
declare @strActions			nvarchar(max)
declare @strMinActions		nvarchar(max)

set @strFileName = N'c:\temp\XECapture.xel'

/*
select p.name, * from sys.dm_xe_objects o
	inner join sys.dm_xe_packages p on p.guid = o.package_guid
	where object_type = 'action'
*/
set @strMinActions =  N'sqlserver.session_id,
						sqlserver.request_id,
						sqlserver.database_id,
						sqlserver.database_name,
						sqlserver.is_system,
						sqlserver.event_sequence'
						
set @strActions =	  N'<<MINACTIONS>>,
						sqlserver.transaction_id,
						sqlserver.plan_handle,
						package0.collect_current_thread_id,
						sqlos.system_thread_id,
						sqlos.task_address,
						sqlos.worker_address,
						sqlos.scheduler_id,
						sqlos.cpu_id'
						--sqlos.node_id'
						--XeDvmPkg.brick_id'
						--package0.attach_activity_id,			Private so turn on TRACK_CAUSALITY = ON
						--package0.attach_activity_id_xfer,

/*
select * from sys.dm_xe_object_columns
	where object_name like '%rpc%'
	and column_type <> 'readonly'

select * from sys.dm_xe_object_columns
	where object_name like '%cache_miss%'
	and column_type <> 'readonly'

	select * from sys.dm_xe_packages
	BD97CC63-3F38-4922-AA93-607BD12E78B2

select * from sys.dm_xe_objects
where object_type = 'action'
and name like '%name%'
		
select distinct(object_name) from sys.dm_xe_object_columns
	where object_name like '%action%'
*/
---------------------------------------------------------------------------------
--		Create the session definition for a full replay/performance capture
---------------------------------------------------------------------------------
declare @strSession nvarchar(max)
set @strSession = N'create event session XERMLCapture on server
					ADD EVENT sqlserver.attention( action (<<MINACTIONS>>) )
					
					ADD TARGET package0.asynchronous_file_target (SET filename = N''<<FILENAME>>'' )
					
					WITH( MAX_DISPATCH_LATENCY = INFINITE, 
						  EVENT_RETENTION_MODE = NO_EVENT_LOSS,
						  MEMORY_PARTITION_MODE = PER_CPU,
						  TRACK_CAUSALITY = ON,
						  STARTUP_STATE = OFF)'
--	Order of replace is important to get MINACTIONS in ACTIONS
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		set @strSession = REPLACE(@strSession, N'<<FILENAME>>',   @strFileName)
		exec(@strSession)

--	sp_statement and RPC Events
--	RPC Output parameter, no such thing, output details in the RPC events
set @strSession = N'alter event session XERMLCapture on server
					add event sqlserver.rpc_starting ( set collect_data_stream = 1, 
					  collect_statement = 1
					  action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)

set @strSession = N'alter event session XERMLCapture on server										   
					add event sqlserver.rpc_completed( set collect_data_stream = 1, 
										   collect_statement = 1,
										   collect_output_parameters = 1
										   action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)

set @strSession = N'alter event session XERMLCapture on server										   
					add event sqlserver.sp_statement_starting ( set collect_object_name = 1,
												collect_statement = 1
												action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)

set @strSession = N'alter event session XERMLCapture on server												
	add event sqlserver.sp_statement_completed (set collect_object_name = 1,
													collect_statement = 1
													action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)
	
	--		SQL Batch and statments
	set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.sql_batch_starting ( set collect_batch_text = 1
												 action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)

set @strSession = N'alter event session XERMLCapture on server												 
	add event sqlserver.sql_batch_completed ( set collect_batch_text = 1
												  action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)
												  
set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.sql_statement_starting ( set collect_statement = 1
													 action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)
													 
set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.sql_statement_completed ( set collect_statement = 1
													  action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)
	
set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.module_start(  action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)
		
set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.module_end(  action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)
		
--		Connect and Disconnect
set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.existing_connection( set collect_options_text = 1,
												 collect_database_name = 1
												 action (<<MINACTIONS>>, 
															sqlserver.username,
															sqlserver.session_nt_username,
															sqlserver.nt_username,
															sqlserver.server_principle_name,
															sqlserver.session_resource_pool_id,
															sqlserver.session_resource_group_id,
															sqlserver.session_server_principal_name,
															sqlserver.client_hostname,
															sqlserver.client_pid,
															sqlserver.client_app_name,
															sqlserver.server_instance_name) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)
												
set @strSession = N'alter event session XERMLCapture on server 
	add event sqlserver.login( set collect_options_text = 1,
										 collect_database_name = 1
										 action (<<ACTIONS>>,
												sqlserver.username,
												sqlserver.session_nt_username,
												sqlserver.nt_username,
												sqlserver.server_principal_name,
												sqlserver.session_resource_pool_id,
												sqlserver.session_resource_group_id,
												sqlserver.session_server_principal_name,
												sqlserver.client_hostname,
												sqlserver.client_pid,
												sqlserver.client_app_name,
												sqlserver.server_instance_name) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)
										
set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.logout( action (<<ACTIONS>>,
												sqlserver.username,
												sqlserver.session_nt_username,
												sqlserver.nt_username,
												sqlserver.server_principal_name,
												sqlserver.session_resource_pool_id,
												sqlserver.session_resource_group_id,
												sqlserver.session_server_principal_name,
												sqlserver.client_hostname,
												sqlserver.client_pid,
												sqlserver.client_app_name,
												sqlserver.server_instance_name) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)
	
set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.preconnect_starting( set collect_database_name = 1
												action (<<ACTIONS>>,
												sqlserver.username,
												sqlserver.session_nt_username,
												sqlserver.session_resource_pool_id,
												sqlserver.session_resource_group_id,
												sqlserver.session_server_principal_name,
												sqlserver.client_hostname,
												sqlserver.client_pid,
												sqlserver.client_app_name,
												sqlserver.server_instance_name) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)
	
set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.preconnect_completed( set collect_database_name = 1
												action (<<ACTIONS>>,
												sqlserver.username,
												sqlserver.session_nt_username,
												sqlserver.session_resource_pool_id,
												sqlserver.session_resource_group_id,
												sqlserver.session_server_principal_name,
												sqlserver.client_hostname,
												sqlserver.client_pid,
												sqlserver.client_app_name,
												sqlserver.server_instance_name) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)
		
--		Transaction 
set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.dtc_transaction( action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)
	
set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.sql_transaction( action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)
		
--	TM Trans
set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.begin_tran_starting( set collect_statement = 1
												action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)
		
set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.begin_tran_completed( set collect_statement = 1
												action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)		

set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.promote_tran_completed( action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)		

set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.commit_tran_starting( set collect_statement = 1
												action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)
		
set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.commit_tran_completed( set collect_statement = 1
												action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)

set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.rollback_tran_starting( set collect_statement = 1
												action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)
		
set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.rollback_tran_completed( set collect_statement = 1
												action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)
		
set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.save_tran_starting( set collect_statement = 1
												action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)
		
set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.save_tran_completed( set collect_statement = 1
												action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)
		
--		Stats Profile
set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.query_post_execution_showplan( set collect_database_name=1
															action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)
	
--		Cursor
set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.cursor_recompile( action (sqlserver.sql_text, <<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)

set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.cursor_open( action (sqlserver.sql_text, <<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)

set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.cursor_prepare( action (sqlserver.sql_text, <<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)

set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.cursor_unprepare( action (sqlserver.sql_text, <<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)

set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.cursor_close( action (sqlserver.sql_text, <<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)

set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.cursor_execute( action (sqlserver.sql_text, <<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)

set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.cursor_implicit_conversion( action (sqlserver.sql_text, <<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)
	
--		Prepare
set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.exec_prepared_sql( action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)

set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.prepare_sql( action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)

set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.unprepare_sql( action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)
	
--	Error log
/*
		Currently can't be added with NO_EVENT_LOSS option
		We must collect the error logs as well at this time.
		
set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.errorlog_written( action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)
*/

--		Errors and Deadlocks
set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.error_reported( action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)

set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.xml_deadlock_report( action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)

set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.lock_deadlock( set collect_resource_description = 1,
										collect_database_name =1
										action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)
		
set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.lock_deadlock_chain( set collect_resource_description = 1,
												collect_database_name =1
												action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)
	
set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.lock_timeout( set collect_database_name = 1, 
										  collect_resource_description = 1 
										  action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)
										  
set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.lock_escalation( set collect_statement = 1, 
											 collect_database_name = 1
											 action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)
											 
--MAX DOP  - No need for this.  It was a 7.0 hold over when only inserts used DOP and fired this event

--		Exception
set @strSession = N'alter event session XERMLCapture on server
	add event sqlos.exception_ring_buffer_recorded(action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)	
		
--		Caching Activities		
set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.sp_cache_miss( set collect_cached_text = 1,
										   collect_object_name = 1,
										   collect_database_name = 1
										   action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)

--	Do we want hits, removes and inserts as well	  ??
										   
set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.sql_statement_recompile( set collect_statement = 1,
													 collect_object_name = 1
													 action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)
	
set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.auto_stats( set collect_database_name = 1
										action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)

--	Warnings
set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.hash_warning( action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)										
		
set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.execution_warning( set collect_server_memory_grants=1
											   action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)
											   
set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.sort_warning( action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)
	
set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.missing_column_statistics( set collect_column_list=1
												   action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)
	
set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.missing_join_predicate( action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)
	
--	Memory change	
set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.server_memory_change( action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)
	
--		File size changes
set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.database_file_size_change(set collect_database_name = 1
								action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)

--	DBCC
set @strSession = N'alter event session XERMLCapture on server
		add event sqlserver.databases_dbcc_logical_scan( action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)

--		Spill
set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.exchange_spill( action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)
		
--	Blocked process		
set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.blocked_process_report( action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)

--	CLR Assembly													 
set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.assembly_load( action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)
	
--	Look at trace flags
set @strSession = N'alter event session XERMLCapture on server
	add event sqlserver.trace_flag_changed( action (<<ACTIONS>>) )'
		set @strSession = REPLACE(@strSession, N'<<ACTIONS>>',	  @strActions)
		set @strSession = REPLACE(@strSession, N'<<MINACTIONS>>', @strMinActions)
		exec(@strSession)
	
go

alter event session XERMLCapture on server state = start
go

/*
alter event session XERMLCapture on server state = stop

select * from sys.fn_xe_file_target_read_file ( ....... )
*/

