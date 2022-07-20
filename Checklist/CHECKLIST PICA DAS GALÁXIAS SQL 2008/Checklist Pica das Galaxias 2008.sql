<<<<<<< HEAD
-- CHECKLIST PICA DAS GALÁXIAS SQL 2008

SET NOCOUNT ON

PRINT '[INFO] Informações do servidor'

-- Dono da conta SQL Server
DECLARE @serviceaccount varchar(100)
EXECUTE master.dbo.xp_instance_regread
N'HKEY_LOCAL_MACHINE',
N'SYSTEM\CurrentControlSet\Services\MSSQLSERVER',
N'ObjectName',
@ServiceAccount OUTPUT, N'no_output'

SELECT 
convert (varchar (20), sqlserver_start_time, 120) 'SQLServer_start_time',
convert (varchar (50), @Serviceaccount) 'ServiceAccount',
convert (varchar (50), SERVERPROPERTY('ComputerNamePhysicalNetBIOS')) AS ComputerNamePhysicalNetBIOS, 
convert (varchar (50), SERVERPROPERTY('MachineName')) AS MachineName,
convert (varchar (50), SERVERPROPERTY('ProductVersion')) AS ProductVersion,
convert (varchar (50), SERVERPROPERTY('ProductLevel')) AS ProductLevel,
convert (varchar (50), SERVERPROPERTY('Edition')) AS Edition, 
cpu_count AS [Logical CPU Count], hyperthread_ratio AS [Hyperthread Ratio],
cpu_count/hyperthread_ratio AS [Physical CPU Count], 
physical_memory_in_bytes/1048576 AS [Physical Memory (MB)]
FROM sys.dm_os_sys_info; 


IF (SELECT COUNT (1) 
		FROM sys.databases 
		WHERE compatibility_level <> 100) > 0
BEGIN
	PRINT '[WARNING] Databases com compatibility_level < 100'
	SELECT convert (varchar (50), name), compatibility_level
	FROM sys.databases
	WHERE compatibility_level <> 100
END

IF (SELECT COUNT (1) 
		FROM sys.databases 
		WHERE is_auto_shrink_on = 1) > 0
BEGIN
	PRINT '[WARNING] Databases com autoshrink'
	SELECT name
	FROM sys.databases
	WHERE is_auto_shrink_on = 1
END

IF (SELECT COUNT (1) 
		FROM sys.databases 
		WHERE page_verify_option_desc <> 'CHECKSUM') > 0
BEGIN
	PRINT '[WARNING] Databases com pageverify antiquado'
	SELECT convert (varchar (50), name)
	FROM sys.databases
	WHERE page_verify_option_desc <> 'CHECKSUM'
END

IF (SELECT COUNT (1) 
		FROM tempdb..sysfiles) < 3
BEGIN
	PRINT '[WARNING] TempDB apenas com 1 arquivo de dados'
	SELECT *
	FROM tempdb..sysfiles
END

IF (SELECT COUNT (1) 
		FROM sys.databases 
		WHERE is_auto_create_stats_on = 0
		   OR is_auto_update_stats_on = 0) > 0
BEGIN
	PRINT '[WARNING] Databases com configurações de estatísticas incorretos'
	SELECT convert (varchar (50), name)
	FROM sys.databases
	WHERE is_auto_create_stats_on = 0
	   OR is_auto_update_stats_on = 0
END

IF (SELECT COUNT (1)
		FROM sys.master_files m 
			INNER JOIN sys.databases b
			ON m.database_id = b.database_id
			WHERE is_percent_growth = 1
			AND b.name NOT IN ('master', 'model', 'msdb')) > 0
BEGIN
	PRINT '[WARNING] Databases com growth em porcentagem'
	SELECT convert (varchar (50), m.name), type_desc, physical_name
	FROM sys.master_files m 
		INNER JOIN sys.databases b
		ON m.database_id = b.database_id
		WHERE is_percent_growth = 1
		AND b.name NOT IN ('master', 'model', 'msdb')
	END

PRINT '[INFO] Privilégios de Local Security Policies'
CREATE TABLE #Temp1 (
Campo varchar (8000))

DECLARE @cmdshell sql_variant

SELECT @cmdshell = value_in_use from sys.configurations WHERE name = 'xp_cmdshell'

EXEC sp_configure 'show advanced options', 1
RECONFIGURE

EXEC sp_configure 'xp_cmdshell', 1
RECONFIGURE

INSERT INTO #Temp1
EXEC xp_cmdshell 'whoami /priv'

SELECT *
	FROM #Temp1
	WHERE Campo Like 'SeLockMemoryPrivilege%'
	   OR Campo Like 'SeManageVolumePrivilege%'
	
DROP TABLE #Temp1

PRINT '[INFO] Informações do Pagefile'
EXEC xp_cmdshell 'wmic pagefileset list /format:list'

IF @cmdshell = 0 
BEGIN
	EXEC sp_configure 'xp_cmdshell', 0
	RECONFIGURE
END

SELECT objtype AS [Cache Store Type],
        COUNT_BIG(*) AS [Total Num Of Plans],
        SUM(CAST(size_in_bytes as decimal(14,2))) / 1048576 AS [Total Size In MB],
        AVG(usecounts) AS [All Plans - Ave Use Count],
        SUM(CAST((CASE WHEN usecounts = 1 THEN size_in_bytes ELSE 0 END) as decimal(14,2)))/ 1048576 AS [Size in MB of plans with a Use count = 1],
        SUM(CASE WHEN usecounts = 1 THEN 1 ELSE 0 END) AS [Number of of plans with a Use count = 1]
        FROM sys.dm_exec_cached_plans
        GROUP BY objtype
        ORDER BY [Size in MB of plans with a Use count = 1] DESC

DECLARE @AdHocSizeInMB decimal (14,2), @TotalSizeInMB decimal (14,2)

SELECT @AdHocSizeInMB = SUM(CAST((CASE WHEN usecounts = 1 AND LOWER(objtype) = 'adhoc' THEN size_in_bytes ELSE 0 END) as decimal(14,2))) / 1048576,
        @TotalSizeInMB = SUM (CAST (size_in_bytes as decimal (14,2))) / 1048576
        FROM sys.dm_exec_cached_plans 

SELECT @AdHocSizeInMB as [Current memory occupied by adhoc plans only used once (MB)],
         @TotalSizeInMB as [Total cache plan size (MB)],
         CAST((@AdHocSizeInMB / @TotalSizeInMB) * 100 as decimal(14,2)) as [% of total cache plan occupied by adhoc plans only used once]
IF  @AdHocSizeInMB > 400 or ((@AdHocSizeInMB / @TotalSizeInMB) * 100) > 30  -- 400MB ou > 30%
        SELECT '[INFO] Verificar utilização de Optimize for ad hoc workloads'
ELSE
        SELECT '[INFO] Não há necessidade de utilização de Optimize for ad hoc workloads'



PRINT '[INFO] Listagem de backups FULL'
SELECT b.name, max (a.backup_finish_date)
	FROM msdb..backupset a
	LEFT OUTER JOIN sys.databases b
	ON a.database_name = b.name
	WHERE type = 'D'
	AND b.name IS NOT NULL
	GROUP BY b.name
	ORDER BY 2 ASC, 1 ASC

PRINT '[INFO] Waittypes'
GO

WITH Waits AS
    (SELECT
        wait_type,
        wait_time_ms / 1000.0 AS WaitS,
        (wait_time_ms - signal_wait_time_ms) / 1000.0 AS ResourceS,
        signal_wait_time_ms / 1000.0 AS SignalS,
        waiting_tasks_count AS WaitCount,
        100.0 * wait_time_ms / SUM (wait_time_ms) OVER() AS Percentage,
        ROW_NUMBER() OVER(ORDER BY wait_time_ms DESC) AS RowNum
    FROM sys.dm_os_wait_stats
    WHERE wait_type NOT IN (
        'CLR_SEMAPHORE', 'LAZYWRITER_SLEEP', 'RESOURCE_QUEUE', 'SLEEP_TASK',
        'SLEEP_SYSTEMTASK', 'SQLTRACE_BUFFER_FLUSH', 'WAITFOR', 'LOGMGR_QUEUE',
        'CHECKPOINT_QUEUE', 'REQUEST_FOR_DEADLOCK_SEARCH', 'XE_TIMER_EVENT', 'BROKER_TO_FLUSH',
        'BROKER_TASK_STOP', 'CLR_MANUAL_EVENT', 'CLR_AUTO_EVENT', 'DISPATCHER_QUEUE_SEMAPHORE',
        'FT_IFTS_SCHEDULER_IDLE_WAIT', 'XE_DISPATCHER_WAIT', 'XE_DISPATCHER_JOIN', 'BROKER_EVENTHANDLER',
        'TRACEWRITE', 'FT_IFTSHC_MUTEX', 'SQLTRACE_INCREMENTAL_FLUSH_SLEEP')
     AND wait_type not like 'PREEMPTIVE%')
SELECT
     W1.wait_type AS WaitType,	
     REPLACE (CAST (W1.Percentage AS DECIMAL(4, 2)), '.', ',') AS Percentage
FROM Waits AS W1	
INNER JOIN Waits AS W2
     ON W2.RowNum <= W1.RowNum
GROUP BY W1.RowNum, W1.wait_type, W1.WaitS, W1.ResourceS, W1.SignalS, W1.WaitCount, W1.Percentage
HAVING SUM (W2.Percentage) - W1.Percentage < 95; -- percentage threshold
GO

IF (SELECT (a.cntr_value * 1.0 / b.cntr_value) * 100.0 as BufferCacheHitRatio
    FROM sys.dm_os_performance_counters  a
    JOIN  (SELECT cntr_value,OBJECT_NAME
        FROM sys.dm_os_performance_counters  
        WHERE counter_name = 'Buffer cache hit ratio base'
            AND OBJECT_NAME = 'SQLServer:Buffer Manager') b ON  a.OBJECT_NAME = b.OBJECT_NAME
    WHERE a.counter_name = 'Buffer cache hit ratio'
    AND a.OBJECT_NAME = 'SQLServer:Buffer Manager') < 98
BEGIN
PRINT '[WARNING] Buffer Cache Hit Ratio abaixo de 98%'
SELECT (a.cntr_value * 1.0 / b.cntr_value) * 100.0 as BufferCacheHitRatio
    FROM sys.dm_os_performance_counters  a
    JOIN  (SELECT cntr_value,OBJECT_NAME
        FROM sys.dm_os_performance_counters  
        WHERE counter_name = 'Buffer cache hit ratio base'
            AND OBJECT_NAME = 'SQLServer:Buffer Manager') b ON  a.OBJECT_NAME = b.OBJECT_NAME
    WHERE a.counter_name = 'Buffer cache hit ratio'
    AND a.OBJECT_NAME = 'SQLServer:Buffer Manager'
END

IF (SELECT cntr_value
		 FROM sys.dm_os_performance_counters  
		 WHERE counter_name = 'Page life expectancy'
		 AND OBJECT_NAME = 'SQLServer:Buffer Manager') < 300
BEGIN
PRINT '[WARNING] Page Life Expectancy abaixo de 300 segundos'
SELECT cntr_value
		 FROM sys.dm_os_performance_counters  
		 WHERE counter_name = 'Page life expectancy'
		 AND OBJECT_NAME = 'SQLServer:Buffer Manager'
END

=======
-- CHECKLIST PICA DAS GALÁXIAS SQL 2008

SET NOCOUNT ON

PRINT '[INFO] Informações do servidor'

-- Dono da conta SQL Server
DECLARE @serviceaccount varchar(100)
EXECUTE master.dbo.xp_instance_regread
N'HKEY_LOCAL_MACHINE',
N'SYSTEM\CurrentControlSet\Services\MSSQLSERVER',
N'ObjectName',
@ServiceAccount OUTPUT, N'no_output'

SELECT 
convert (varchar (20), sqlserver_start_time, 120) 'SQLServer_start_time',
convert (varchar (50), @Serviceaccount) 'ServiceAccount',
convert (varchar (50), SERVERPROPERTY('ComputerNamePhysicalNetBIOS')) AS ComputerNamePhysicalNetBIOS, 
convert (varchar (50), SERVERPROPERTY('MachineName')) AS MachineName,
convert (varchar (50), SERVERPROPERTY('ProductVersion')) AS ProductVersion,
convert (varchar (50), SERVERPROPERTY('ProductLevel')) AS ProductLevel,
convert (varchar (50), SERVERPROPERTY('Edition')) AS Edition, 
cpu_count AS [Logical CPU Count], hyperthread_ratio AS [Hyperthread Ratio],
cpu_count/hyperthread_ratio AS [Physical CPU Count], 
physical_memory_in_bytes/1048576 AS [Physical Memory (MB)]
FROM sys.dm_os_sys_info; 


IF (SELECT COUNT (1) 
		FROM sys.databases 
		WHERE compatibility_level <> 100) > 0
BEGIN
	PRINT '[WARNING] Databases com compatibility_level < 100'
	SELECT convert (varchar (50), name), compatibility_level
	FROM sys.databases
	WHERE compatibility_level <> 100
END

IF (SELECT COUNT (1) 
		FROM sys.databases 
		WHERE is_auto_shrink_on = 1) > 0
BEGIN
	PRINT '[WARNING] Databases com autoshrink'
	SELECT name
	FROM sys.databases
	WHERE is_auto_shrink_on = 1
END

IF (SELECT COUNT (1) 
		FROM sys.databases 
		WHERE page_verify_option_desc <> 'CHECKSUM') > 0
BEGIN
	PRINT '[WARNING] Databases com pageverify antiquado'
	SELECT convert (varchar (50), name)
	FROM sys.databases
	WHERE page_verify_option_desc <> 'CHECKSUM'
END

IF (SELECT COUNT (1) 
		FROM tempdb..sysfiles) < 3
BEGIN
	PRINT '[WARNING] TempDB apenas com 1 arquivo de dados'
	SELECT *
	FROM tempdb..sysfiles
END

IF (SELECT COUNT (1) 
		FROM sys.databases 
		WHERE is_auto_create_stats_on = 0
		   OR is_auto_update_stats_on = 0) > 0
BEGIN
	PRINT '[WARNING] Databases com configurações de estatísticas incorretos'
	SELECT convert (varchar (50), name)
	FROM sys.databases
	WHERE is_auto_create_stats_on = 0
	   OR is_auto_update_stats_on = 0
END

IF (SELECT COUNT (1)
		FROM sys.master_files m 
			INNER JOIN sys.databases b
			ON m.database_id = b.database_id
			WHERE is_percent_growth = 1
			AND b.name NOT IN ('master', 'model', 'msdb')) > 0
BEGIN
	PRINT '[WARNING] Databases com growth em porcentagem'
	SELECT convert (varchar (50), m.name), type_desc, physical_name
	FROM sys.master_files m 
		INNER JOIN sys.databases b
		ON m.database_id = b.database_id
		WHERE is_percent_growth = 1
		AND b.name NOT IN ('master', 'model', 'msdb')
	END

PRINT '[INFO] Privilégios de Local Security Policies'
CREATE TABLE #Temp1 (
Campo varchar (8000))

DECLARE @cmdshell sql_variant

SELECT @cmdshell = value_in_use from sys.configurations WHERE name = 'xp_cmdshell'

EXEC sp_configure 'show advanced options', 1
RECONFIGURE

EXEC sp_configure 'xp_cmdshell', 1
RECONFIGURE

INSERT INTO #Temp1
EXEC xp_cmdshell 'whoami /priv'

SELECT *
	FROM #Temp1
	WHERE Campo Like 'SeLockMemoryPrivilege%'
	   OR Campo Like 'SeManageVolumePrivilege%'
	
DROP TABLE #Temp1

PRINT '[INFO] Informações do Pagefile'
EXEC xp_cmdshell 'wmic pagefileset list /format:list'

IF @cmdshell = 0 
BEGIN
	EXEC sp_configure 'xp_cmdshell', 0
	RECONFIGURE
END

SELECT objtype AS [Cache Store Type],
        COUNT_BIG(*) AS [Total Num Of Plans],
        SUM(CAST(size_in_bytes as decimal(14,2))) / 1048576 AS [Total Size In MB],
        AVG(usecounts) AS [All Plans - Ave Use Count],
        SUM(CAST((CASE WHEN usecounts = 1 THEN size_in_bytes ELSE 0 END) as decimal(14,2)))/ 1048576 AS [Size in MB of plans with a Use count = 1],
        SUM(CASE WHEN usecounts = 1 THEN 1 ELSE 0 END) AS [Number of of plans with a Use count = 1]
        FROM sys.dm_exec_cached_plans
        GROUP BY objtype
        ORDER BY [Size in MB of plans with a Use count = 1] DESC

DECLARE @AdHocSizeInMB decimal (14,2), @TotalSizeInMB decimal (14,2)

SELECT @AdHocSizeInMB = SUM(CAST((CASE WHEN usecounts = 1 AND LOWER(objtype) = 'adhoc' THEN size_in_bytes ELSE 0 END) as decimal(14,2))) / 1048576,
        @TotalSizeInMB = SUM (CAST (size_in_bytes as decimal (14,2))) / 1048576
        FROM sys.dm_exec_cached_plans 

SELECT @AdHocSizeInMB as [Current memory occupied by adhoc plans only used once (MB)],
         @TotalSizeInMB as [Total cache plan size (MB)],
         CAST((@AdHocSizeInMB / @TotalSizeInMB) * 100 as decimal(14,2)) as [% of total cache plan occupied by adhoc plans only used once]
IF  @AdHocSizeInMB > 400 or ((@AdHocSizeInMB / @TotalSizeInMB) * 100) > 30  -- 400MB ou > 30%
        SELECT '[INFO] Verificar utilização de Optimize for ad hoc workloads'
ELSE
        SELECT '[INFO] Não há necessidade de utilização de Optimize for ad hoc workloads'



PRINT '[INFO] Listagem de backups FULL'
SELECT b.name, max (a.backup_finish_date)
	FROM msdb..backupset a
	LEFT OUTER JOIN sys.databases b
	ON a.database_name = b.name
	WHERE type = 'D'
	AND b.name IS NOT NULL
	GROUP BY b.name
	ORDER BY 2 ASC, 1 ASC

PRINT '[INFO] Waittypes'
GO

WITH Waits AS
    (SELECT
        wait_type,
        wait_time_ms / 1000.0 AS WaitS,
        (wait_time_ms - signal_wait_time_ms) / 1000.0 AS ResourceS,
        signal_wait_time_ms / 1000.0 AS SignalS,
        waiting_tasks_count AS WaitCount,
        100.0 * wait_time_ms / SUM (wait_time_ms) OVER() AS Percentage,
        ROW_NUMBER() OVER(ORDER BY wait_time_ms DESC) AS RowNum
    FROM sys.dm_os_wait_stats
    WHERE wait_type NOT IN (
        'CLR_SEMAPHORE', 'LAZYWRITER_SLEEP', 'RESOURCE_QUEUE', 'SLEEP_TASK',
        'SLEEP_SYSTEMTASK', 'SQLTRACE_BUFFER_FLUSH', 'WAITFOR', 'LOGMGR_QUEUE',
        'CHECKPOINT_QUEUE', 'REQUEST_FOR_DEADLOCK_SEARCH', 'XE_TIMER_EVENT', 'BROKER_TO_FLUSH',
        'BROKER_TASK_STOP', 'CLR_MANUAL_EVENT', 'CLR_AUTO_EVENT', 'DISPATCHER_QUEUE_SEMAPHORE',
        'FT_IFTS_SCHEDULER_IDLE_WAIT', 'XE_DISPATCHER_WAIT', 'XE_DISPATCHER_JOIN', 'BROKER_EVENTHANDLER',
        'TRACEWRITE', 'FT_IFTSHC_MUTEX', 'SQLTRACE_INCREMENTAL_FLUSH_SLEEP')
     AND wait_type not like 'PREEMPTIVE%')
SELECT
     W1.wait_type AS WaitType,	
     REPLACE (CAST (W1.Percentage AS DECIMAL(4, 2)), '.', ',') AS Percentage
FROM Waits AS W1	
INNER JOIN Waits AS W2
     ON W2.RowNum <= W1.RowNum
GROUP BY W1.RowNum, W1.wait_type, W1.WaitS, W1.ResourceS, W1.SignalS, W1.WaitCount, W1.Percentage
HAVING SUM (W2.Percentage) - W1.Percentage < 95; -- percentage threshold
GO

IF (SELECT (a.cntr_value * 1.0 / b.cntr_value) * 100.0 as BufferCacheHitRatio
    FROM sys.dm_os_performance_counters  a
    JOIN  (SELECT cntr_value,OBJECT_NAME
        FROM sys.dm_os_performance_counters  
        WHERE counter_name = 'Buffer cache hit ratio base'
            AND OBJECT_NAME = 'SQLServer:Buffer Manager') b ON  a.OBJECT_NAME = b.OBJECT_NAME
    WHERE a.counter_name = 'Buffer cache hit ratio'
    AND a.OBJECT_NAME = 'SQLServer:Buffer Manager') < 98
BEGIN
PRINT '[WARNING] Buffer Cache Hit Ratio abaixo de 98%'
SELECT (a.cntr_value * 1.0 / b.cntr_value) * 100.0 as BufferCacheHitRatio
    FROM sys.dm_os_performance_counters  a
    JOIN  (SELECT cntr_value,OBJECT_NAME
        FROM sys.dm_os_performance_counters  
        WHERE counter_name = 'Buffer cache hit ratio base'
            AND OBJECT_NAME = 'SQLServer:Buffer Manager') b ON  a.OBJECT_NAME = b.OBJECT_NAME
    WHERE a.counter_name = 'Buffer cache hit ratio'
    AND a.OBJECT_NAME = 'SQLServer:Buffer Manager'
END

IF (SELECT cntr_value
		 FROM sys.dm_os_performance_counters  
		 WHERE counter_name = 'Page life expectancy'
		 AND OBJECT_NAME = 'SQLServer:Buffer Manager') < 300
BEGIN
PRINT '[WARNING] Page Life Expectancy abaixo de 300 segundos'
SELECT cntr_value
		 FROM sys.dm_os_performance_counters  
		 WHERE counter_name = 'Page life expectancy'
		 AND OBJECT_NAME = 'SQLServer:Buffer Manager'
END

>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
