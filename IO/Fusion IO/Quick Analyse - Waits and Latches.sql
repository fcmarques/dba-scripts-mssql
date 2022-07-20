/* Script to Detect I/O Bottlenecks */

/* Copyright 2013 Fusion-io, Inc. */
 
/*
 *  This program is free software; you can redistribute it and/or modify it under the terms of the 
 *  GNU General Public License version 2 as published by the Free Software Foundation;
 *  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
 *  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
 *  See the GNU General Public License v2 for more details.
 * 
 *  A copy of the GNU General Public License v2 can be found at: http://www.gnu.org/licenses/old-licenses/gpl-2.0.html  
 *  You should have received a copy of the GNU General Public License along with this program; if not, write to the 
 *  Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA. 
 */


/* How long between each sample */
DECLARE @SampleDelay VARCHAR(16) 
SET @SampleDelay ='00:00:01.000'

/* How many samples to acquire. If set to zero, will report since last stat reset */
DECLARE @NumSamples INT
SET @NumSamples = 0

/* -------------------------------------- */

/* Initial magic chants */
SET NOCOUNT ON

/* Create a list of wait types we can safely ignore */
IF OBJECT_ID('tempdb..#ignore_res') IS NOT NULL DROP TABLE #ignore_res
CREATE TABLE #ignore_res
(
	resource VARCHAR(250) NOT NULL PRIMARY KEY
)
INSERT INTO #ignore_res (resource) VALUES ('SQLTRACE_BUFFER_FLUSH')
INSERT INTO #ignore_res (resource) VALUES ('DISPATCHER_QUEUE_SEMAPHORE')	/* Idle Dispatcher, expected */
INSERT INTO #ignore_res (resource) VALUES ('DBMIRRORING_CMD') 			/* Diagnosed from different waits */
INSERT INTO #ignore_res (resource) VALUES  ('LAZYWRITER_SLEEP')
INSERT INTO #ignore_res (resource) VALUES  ('LOGMGR_QUEUE')
INSERT INTO #ignore_res (resource) VALUES  ('CHECKPOINT_QUEUE')
INSERT INTO #ignore_res (resource) VALUES  ('WAITFOR')                          /* User initiated wait  */ 
INSERT INTO #ignore_res (resource) VALUES  ('SQLTRACE_LOCK')
INSERT INTO #ignore_res (resource) VALUES  ('FT_IFTS_SCHEDULER_IDLE_WAIT')
INSERT INTO #ignore_res (resource) VALUES  ('SQLTRACE_INCREMENTAL_FLUSH_SLEEP')
INSERT INTO #ignore_res (resource) VALUES  ('REQUEST_FOR_DEADLOCK_SEARCH')
INSERT INTO #ignore_res (resource) VALUES  ('BROKER_TO_FLUSH')
INSERT INTO #ignore_res (resource) VALUES  ('SLEEP_TASK')
INSERT INTO #ignore_res (resource) VALUES  ('XE_TIMER_EVENT')
INSERT INTO #ignore_res (resource) VALUES  ('SLEEP_BPOOL_FLUSH')
INSERT INTO #ignore_res (resource) VALUES  ('XE_DISPATCHER_WAIT')
INSERT INTO #ignore_res (resource) VALUES  ('TRACEWRITE')
INSERT INTO #ignore_res (resource) VALUES  ('BROKER_TASK_STOP')
INSERT INTO #ignore_res (resource) VALUES  ('DIRTY_PAGE_POLL')
INSERT INTO #ignore_res (resource) VALUES  ('HADR_FILESTREAM_IOMGR_IOCOMPLETION')
INSERT INTO #ignore_res (resource) VALUES  ('BUFFER')                           /* Already accounted for in PAGELATCH */
INSERT INTO #ignore_res (resource) VALUES  ('CXPACKET')                         /* Indicates a problem elsewhere. Ignore the symptom */
INSERT INTO #ignore_res (resource) VALUES  ('BROKER_EVENTHANDLER')
INSERT INTO #ignore_res (resource) VALUES  ('DEADLOCK_ENUM_MUTEX')
INSERT INTO #ignore_res (resource) VALUES  ('CLR_AUTO_EVENT')
INSERT INTO #ignore_res (resource) VALUES  ('SQLTRACE_SHUTDOWN')
INSERT INTO #ignore_res (resource) VALUES  ('SQLTRACE_WAIT_ENTRIES')
INSERT INTO #ignore_res (resource) VALUES  ('CHKPT')
INSERT INTO #ignore_res (resource) VALUES  ('FFT_RECOVERY')
INSERT INTO #ignore_res (resource) VALUES  ('RECOVER_CHANGEDB')
INSERT INTO #ignore_res (resource) VALUES  ('COMMIT_TABLE')
INSERT INTO #ignore_res (resource) VALUES  ('CREATE_DATINISERVICE')
INSERT INTO #ignore_res (resource) VALUES  ('PRINT_ROLLBACK_PROGRESS')
INSERT INTO #ignore_res (resource) VALUES  ('SRVPROC_SHUTDOWN')
INSERT INTO #ignore_res (resource) VALUES  ('BACKUP_TAPE_POOL')
INSERT INTO #ignore_res (resource) VALUES  ('DAC_INIT')
INSERT INTO #ignore_res (resource) VALUES  ('ABR')
INSERT INTO #ignore_res (resource) VALUES  ('PREEMPTIVE_ABR')
INSERT INTO #ignore_res (resource) VALUES  ('BACKUP')
INSERT INTO #ignore_res (resource) VALUES  ('DEADLOCK_TASK_SEARCH')
INSERT INTO #ignore_res (resource) VALUES  ('STARTUP_DEPENDENCY_MANAGER')
INSERT INTO #ignore_res (resource) VALUES  ('TIMEPRIV_TIMEPERIOD')
INSERT INTO #ignore_res (resource) VALUES  ('SHUTDOWN')
INSERT INTO #ignore_res (resource) VALUES  ('SERVER_IDLE_CHECK')
INSERT INTO #ignore_res (resource) VALUES  ('BACKUP_FILE_HANDLE')
/* Backup waits that are symptoms, not causes */
INSERT INTO #ignore_res (resource) VALUES  ('BACKUPTHREAD')
INSERT INTO #ignore_res (resource) VALUES  ('BACKUP_INSTANCE_ID')
INSERT INTO #ignore_res (resource) VALUES  ('BACKUP_MANAGER')
INSERT INTO #ignore_res (resource) VALUES  ('BACKUP_MANAGER_DIFFERENTIAL')
INSERT INTO #ignore_res (resource) VALUES  ('BACKUP_OPERATION')
INSERT INTO #ignore_res (resource) VALUES  ('WAITSTAT_MUTEX')
INSERT INTO #ignore_res (resource) VALUES  ('WCC')
INSERT INTO #ignore_res (resource) VALUES  ('LOG_MANAGER')                     /* Waits captured WRITELOG etc. */
INSERT INTO #ignore_res (resource) VALUES  ('CHECK_PRINT_RECORD')
INSERT INTO #ignore_res (resource) VALUES  ('CLEAR_DB')
INSERT INTO #ignore_res (resource) VALUES  ('CHANGE_TRACKING_WAITFORCHANGES')
INSERT INTO #ignore_res (resource) VALUES  ('FILETABLE_SHUTDOWN')
INSERT INTO #ignore_res (resource) VALUES  ('KSOURCE_WAKEUP')
/* Mirror symptom and ignore wait. Diagnosed elsewhere */
INSERT INTO #ignore_res (resource) VALUES  ('DBMIRROR_EVENTS_QUEUE')
INSERT INTO #ignore_res (resource) VALUES  ('BROKER_RECEIVE_WAITFOR')
INSERT INTO #ignore_res (resource) VALUES  ('DBMIRROR_DBM_EVENT')               
	/* Add more waits here as needed */

/* Query the waits registered on server to add more ignored waits */
INSERT INTO #ignore_res (resource)
SELECT DISTINCT wait_type
FROM sys.dm_os_wait_stats
WHERE (
	wait_type LIKE 'PREEMPTIVE%'
	OR wait_type LIKE 'SLEEP%'
	OR wait_type LIKE 'LATCH%'	/* We will find these in latch waits instead */
	OR wait_type LIKE 'DBCC%'	/* Reported as file waits */
	OR wait_type LIKE 'PWAIT[_]%'
	) 
AND wait_type NOT IN (SELECT resource FROM #ignore_res)
AND wait_type NOT LIKE 'PRE%SECURITY%' /* Security waits */
AND wait_type NOT LIKE 'PRE%AUTH%' /* Authentication waits */
AND wait_type NOT IN ('PREEMPTIVE_OS_CRYPTOPS'
	, 'PREEMPTIVE_OS_CRYPTACQUIRECONTEXT'
	, 'PREEMPTIVE_OS_CRYPTIMPORTKEY')


/* Create a tables to hold the results */
IF OBJECT_ID('tempdb..#resource_wait_samples') IS NOT NULL DROP TABLE #resource_wait_samples
CREATE TABLE #resource_wait_samples
( 
	  resource_type VARCHAR(255) NOT NULL	/* What was waited for */
	, wait_time_ms DECIMAL(16,0)					/* The total wait time */
	, num_waits BIGINT										/* The total number of times waited */
	, sample_number INT
	, sample_time DATETIME
)
CREATE UNIQUE CLUSTERED INDEX CIX ON #resource_wait_samples (sample_number, resource_type)





DECLARE @SampleNumber INT 
DECLARE @SampleTime DATETIME
SET @SampleNumber = 0

/* Sample @SampleNumber + 1 times (the first sample is the baseline) */
WHILE @SampleNumber <= @NumSamples BEGIN

	SELECT @SampleTime = GETUTCDATE();

	/* Grab the waits from the server */
	INSERT INTO #resource_wait_samples WITH (TABLOCK) (
	    sample_number
    , sample_time	  
	  , resource_type
		, wait_time_ms
		, num_waits)
	SELECT
		 	@SampleNumber
		, @SampleTime 	 
	  , wait_Type
		, wait_time_ms - signal_wait_time_ms
		, waiting_tasks_count
	FROM sys.dm_os_wait_stats
	UNION ALL
	SELECT 
		 	@SampleNumber
		, @SampleTime 	
	  , latch_class 
		, wait_time_ms
		, waiting_requests_count
	FROM sys.dm_os_latch_stats
	WHERE latch_class NOT IN (SELECT wait_type FROM sys.dm_os_wait_stats)
	UNION ALL
	SELECT 
			@SampleNumber
		, @SampleTime 	
	  , 'CPU'
		, SUM(signal_wait_time_ms)
		, SUM(waiting_tasks_count)
	FROM sys.dm_os_wait_stats

	IF @NumSamples > 0 WAITFOR DELAY @SampleDelay;

	SET @SampleNumber = @SampleNumber + 1
END



IF OBJECT_ID('tempdb..#resource_waits_delta') IS NOT NULL DROP TABLE #resource_waits_delta
CREATE TABLE #resource_waits_delta
(
	  resource_category VARCHAR(255)			/* The type of resource */
	, resource_type VARCHAR(255) NOT NULL	/* What was waited for */
	, wait_time_ms DECIMAL(16,0)					/* The total wait time */
	, avg_wait_time_ms DECIMAL(16,2)			/* The average time spend per wait */
	, num_waits BIGINT										/* The total number of times waited */
	, avg_waits_per_ms DECIMAL(16,2)					/* The number of waits per second */
	, sample_number INT
	, sample_time DATETIME
	, sample_duration_s BIGINT
)

/* Find restart data of SQL Server */
DECLARE @LastRestart DATETIME
SELECT @LastRestart = create_date
FROM sys.databases
WHERE database_id = 2

/* Calculate the Delta */
INSERT INTO #resource_waits_delta (
    resource_type
	, sample_number
	, sample_time
	, wait_time_ms
	, avg_wait_time_ms
	, num_waits
	, avg_waits_per_ms
	, sample_duration_s)
SELECT A.resource_type
  , A.sample_number
	, A.sample_time
	, A.wait_time_ms - ISNULL(B.wait_time_ms, 0)
	, (A.wait_time_ms - ISNULL(B.wait_time_ms, 0)) / NULLIF((A.num_waits - ISNULL(B.num_waits, 0)), 0)
	, (A.num_waits - ISNULL(B.num_waits, 0))
	, (A.num_waits - ISNULL(B.num_waits, 0)) 
	   / ISNULL(DATEDIFF(MILLISECOND, B.sample_time, A.sample_time)
		   , DATEDIFF(MILLISECOND, @LastRestart, A.sample_time)) AS avg_waits_per_ms
	, ISNULL(DATEDIFF(second, B.sample_time, A.sample_time)
		   , DATEDIFF(second, @LastRestart, A.sample_time)) AS sample_duration_s
FROM #resource_wait_samples A
LEFT OUTER JOIN #resource_wait_samples B
  ON A.resource_type = B.resource_type
	AND B.sample_number = A.sample_number - 1
WHERE (A.sample_number > 0 OR @NumSamples = 0)



/* Aggregate and enrich data */
UPDATE #resource_waits_delta
SET avg_wait_time_ms = wait_time_ms / num_waits
WHERE num_waits > 0

/* Categorise the waits that are I/O related */
UPDATE #resource_waits_delta
SET resource_category = 'I/O'
WHERE resource_type LIKE 'PAGEIO%'
OR resource_type IN 
	('LOGBUFFER'
	, 'WRITELOG'
	, 'IO_COMPLETION'
	, 'ASYNC_IO_COMPLETION'
	, 'IO_AUDIT_MUTEX'
	, 'IMPPROV_IOWAIT'
	, 'DISKIO_SUSPEND'
	, 'REPLICA_WRITES'
	, 'BACKUPIO'
	, 'BACKUPBUFFER'
	, 'SQLTRACE_FILE_READ_IO_COMPLETION'
	, 'SQLTRACE_FILE_WRITE_IO_COMPLETION'
	, 'SQLTRACE_FILE_BUFFER'
	, 'SQLTRACE_PENDING_BUFFER_WRITERS'
	, 'WRITE_COMPLETION'
	, 'BACKUP_LOG_REDO'
	, 'IO_RETRY'
	, 'IOAFF_RANGE_QUEUE'
	, 'ASYNC_DISKPOOL_LOCK')

/* waits caused by queries coordinating with each other
   Often related to data model issues */
UPDATE #resource_waits_delta
SET resource_category = 'Locking and Latching'
WHERE resource_type LIKE 'LCK%'
  OR resource_type IN ('TEMPOBJ'
		, 'SEQUENTIAL_GUID'
		, 'IDENTITY'
		, 'DROPTEMP'
		, 'DUMPTRIGGER')
	OR resource_type LIKE 'PAGELATCH%'

/* Waits caused by queries executing stuff at high parallelism
   Typically indicate some issue with the query plan or execution engine */
UPDATE #resource_waits_delta
SET resource_category = 'Intra Query Parallelism'
WHERE resource_type IN
	('EXCHANGE'
		, 'EE_SPECPROC_MAP_INIT'
		, 'CXROWSET_SYNC'
		, 'SOS_OBJECT_STORE'
		, 'EXECUTION_PIPE_EVENT_INTERNAL'
		, 'EE_SPECPROC_MAP_INIT'
		, 'HTREPARTITION'
		, 'HTBUILD'
		, 'AM_INDBUILD_ALLOCATION'
		, 'AM_SCHEMAMGR_UNSHARED_CACHE'
		, 'BUILTIN_HASHKEY_MUTEX'
		, 'CXROWSET_SYNC'
		, 'SCAN_CHAR_HASH_ARRAY_INITIALIZATION'
		, 'HOBT_LOBPAGEINFO'
		)
OR resource_type LIKE 'ACCESS_METHOD%'

/* waits related to version control of data. For example snapshot isolation.
   Can often be rememdied with faster tempdb */
UPDATE #resource_waits_delta
SET resource_category = 'Versioning and snapshot'
WHERE resource_category IS NULL
AND
(
	resource_type IN (
		'ENABLE_VERSIONING'
		, 'ENABLE_EMPTY_VERSIONING'
		, 'VERSIONING_COMMITTING'
		, 'DISABLE_VERSIONING')
	OR resource_type LIKE 'VERSIONING[_]%'
	OR resource_type LIKE 'FCB%'
)

/* Waits SQL uses to synchronise access to internal data. 
   Should NOT be high */
UPDATE #resource_waits_delta
SET resource_category = 'Internal Synchonization'
WHERE 
resource_category IS NULL
AND
(
	resource_type IN (
			'REDO_THREAD_PENDING_WORK'
		, 'REDO_THREAD_SYNC'
		, 'VIEW_DEFINITION_MUTEX'
		, 'SOS_STACKSTORE_INIT_MUTEX'
	  , 'SOS_SYNC_TASK_ENQUEUE_EVENT'
		, 'NODE_CACHE_MUTEX'
		, 'PERFORMANCE_COUNTERS_RWLOCK'
		, 'QRY_PARALLEL_THREAD_MUTEX'
		, 'DIRTY_PAGE_SYNC'
		, 'GHOSTCLEANUPSYNCMGR'
		, 'ONDEMAND_TASK_QUEUE')
	OR resource_type LIKE 'DISPATCHER[_]%'
	OR resource_type LIKE 'SPACEMGR[_]%'
	OR resource_type LIKE 'QUERY[_]OPTIMIZER%'
	OR resource_type LIKE 'SQLSORT[_]%'
	OR resource_type LIKE 'QUERY[_]%'
	OR resource_type LIKE 'METADATA[_]%'
	OR resource_type LIKE 'LOGPOOL[_]%'
)
	

/* Waits to get CPU resources (includes signal waits) */
UPDATE #resource_waits_delta
SET resource_category = 'Threading and CPU'
WHERE resource_type 
 IN ('THREADPOOL'
	, 'CPU', 'BACKUPTHREAD', 'EXECSYNC')
 OR resource_type LIKE 'SOSHOST[_]%'
 OR resource_type LIKE 'SOS[_]%'

/* Security related waits */
UPDATE #resource_waits_delta
SET resource_category = 'Security and Encryption'
WHERE resource_type LIKE 'PRE%SECURITY%' 
OR resource_type LIKE 'PRE%AUTH%' 
OR resource_type IN ('PREEMPTIVE_OS_CRYPTOPS'
	, 'PREEMPTIVE_OS_CRYPTACQUIRECONTEXT'
	, 'PREEMPTIVE_OS_CRYPTIMPORTKEY')


/* Network related waits */
UPDATE #resource_waits_delta
SET resource_category = 'Network'
WHERE resource_type 
 IN ('ASYNC_NETWORK_IO'
	, 'OLEDB'
	, 'VIA_ACCEPT'
	, 'NET_WAITFOR_PACKET'
	, 'WAIT_FOR_RESULTS'
	, 'MSQL_DQ')
OR resource_type LIKE 'DTC%'
OR resource_type LIKE 'SOAP[_]%'
OR resource_type LIKE 'SNI[_]%'

/* Waits to coordinate transactions */
UPDATE #resource_waits_delta
SET resource_category = 'Transaction Manager'
WHERE
	resource_category IS NULL 
AND
( 
	resource_type LIKE 'XACT%'
	OR resource_type LIKE 'XDES%'
	OR resource_type LIKE 'TRANSACTION[_]%'
	OR resource_type LIKE 'TRAN[_]%'
	OR resource_type LIKE 'NESTING[_]TRANSACTION%'
	OR resource_type IN ('MSQL_TRANSACTION_MANAGER')
	OR resource_type LIKE '%ACT%'
)

/* Waits to acquire memory */
UPDATE #resource_waits_delta
SET resource_category = 'Memory'
WHERE resource_type 
	IN ('CMEMTHREAD'
		, 'SOS_VIRTUALMEMORY_LOW'
		, 'QRY_MEM_GRANT_INFO_MUTEX'
		, 'WORKTBL_DROP'
		, 'EE_PMOLOCK'
		, 'RESOURCE_SEMAPHORE'
		, 'RESOURCE_SEMAPHORE_MUTEX')
	/* Columnstore waits indicating low memory */
	OR resource_type LIKE 'COLUMNSTORE[_]%'
	OR resource_type LIKE 'CSIBUILD[_]%'

/* resource waits related to replicas */
UPDATE #resource_waits_delta
SET resource_category = 'AlwaysOn / Mirror / Replica'
WHERE resource_type LIKE 'HADR%'
	OR resource_type LIKE 'DBMIRROR%'
	OR resource_type LIKE 'REPL[_]%'
	OR resource_type LIKE 'DATABASE[_]MIRRORING%'
	OR resource_type LIKE 'PWAIT[_]%'

/* Stuff caused by users or errors */
UPDATE #resource_waits_delta
SET resource_category = 'Tracing/Audit/Errors and Humans'
WHERE resource_category IS NULL
AND
	( 
		resource_type LIKE 'SP[_]%'
		OR resource_type LIKE 'XE[_]%'
		OR resource_type LIKE 'SP[_]SERVER%'
		OR resource_type LIKE 'AUDIT[_]%'
		OR resource_type LIKE 'TRACE[_]%'
		OR resource_type LIKE 'FS[_]%'
		OR resource_type LIKE 'FT[_]%'
		OR resource_type IN ('BACKUP_OPERATOR'
			, 'TRACE_EVTNOTIF'
			, 'CLR_MANUAL_EVENT'
			, 'WAITFOR'
			, 'TRACE'
			, 'BAD_PAGE_PROCESS'
			, 'DEBUG')
		OR resource_type LIKE 'DUMP[_]%'
		OR resource_type LIKE 'UTILITY[_]%'
	)

-- Service broker related
UPDATE #resource_waits_delta
SET resource_category = 'Service Broker'
WHERE resource_type LIKE 'BROKER[_]%'
OR resource_type LIKE 'SERVICE[_]BROKER%'
OR resource_type IN ('HTTP_ENUMERATION', 'HTTP_START')

/* Fulltext and filestreams waits */
UPDATE #resource_waits_delta
SET resource_category = 'Fulltext and Filestream'
WHERE resource_type IN ('MSSEARCH', 'FULLTEXT GATHERER')
	OR resource_type LIKE 'FULLTEXT[_]%'
	OR resource_type LIKE 'FILESTREAM[_]%'
	OR resource_type LIKE 'FFT[_]%'

/* code created by user and hosted in DB */
UPDATE #resource_waits_delta
SET resource_category = 'Custom Code (CLR/XP)'
WHERE resource_type IN ('MSQL_XP'
	, 'SECURITY_XPCMDSHELL'
	, 'ASSEMBLY_LOAD'
	, 'DLL_LOADING_MUTEX'
	, 'CLRHOST_STATE_ACCESS'
	)
	OR resource_type LIKE 'SQLCLR[_]%'
	OR resource_type LIKE 'CLR[_]%'
	
/* security calls */
UPDATE #resource_waits_delta
SET resource_category = 'Security and Encryption'
WHERE resource_category IS NULL 
AND
(
	resource_type LIKE 'SECURITY[_]%'
)
-- Pile the rest into a big bucket
UPDATE #resource_waits_delta
SET resource_category = 'Unknown'
WHERE resource_category IS NULL

/* Output the result */
SELECT 
  @@SERVERNAME AS server_name
, resource_category
, resource_type
, num_waits
, avg_waits_per_ms
, wait_time_ms
, avg_wait_time_ms
, CAST(ROUND(
		wait_time_ms / NULLIF(SUM(wait_time_ms) OVER (PARTITION BY sample_number), 0)  
		, 2) * 100 AS DECIMAL(4,1)) AS percent_total
, sample_number
, sample_time
, sample_duration_s
FROM #resource_waits_delta
WHERE 
resource_type NOT IN (SELECT resource FROM #ignore_res)
AND num_waits > 0
AND wait_time_ms > 0
ORDER BY sample_number, wait_time_ms DESC


/* Clean up */
IF OBJECT_ID('tempdb..#resource_waits_delta') IS NOT NULL DROP TABLE #resource_waits_delta
IF OBJECT_ID('tempdb..#ignore_res') IS NOT NULL DROP TABLE #ignore_res
