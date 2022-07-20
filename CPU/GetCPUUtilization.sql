<<<<<<< HEAD
-- How to find the possible queries that caused high CPU utilization in the past 2 minutes? 
-- http://sqlblog.com/blogs/ben_nevarez/archive/2009/07/26/getting-cpu-utilization-data-from-sql-server.aspx 
-- http://sqlknowledge.com/2010/12/how-to-monitor-sql-server-cpu-usage-and-get-auto-alerts/ 
DECLARE @ts_now BIGINT 
DECLARE @SQLVersion DECIMAL (4, 2) -- 9.00, 10.00 
DECLARE @AvgCPUUtilization DECIMAL(10, 2) 

SELECT @SQLVersion = LEFT(Cast(Serverproperty('PRODUCTVERSION') AS VARCHAR), 4) -- find the SQL Server Version 
-- sys.dm_os_sys_info works differently in SQL Server 2005 vs SQL Server 2008+ 
-- comment out SQL Server 2005 if SQL Server 2008+ 
-- SQL Server 2005 
--IF @SQLVersion = 9.00 
--BEGIN  
--  SELECT @ts_now = cpu_ticks / CONVERT(float, cpu_ticks_in_ms) FROM sys.dm_os_sys_info  
--END 
-- SQL Server 2008+ 
IF @SQLVersion >= 10.00 
  BEGIN 
      SELECT @ts_now = cpu_ticks / ( cpu_ticks / ms_ticks ) 
      FROM   sys.dm_os_sys_info 
  END 

-- load the CPU utilization in the past 3 minutes into the temp table, you can load them into a permanent table
SELECT TOP(3) sqlprocessutilization                                  AS [SQLServerProcessCPUUtilization],
              systemidle                                             AS [SystemIdleProcess], 
              100 - systemidle - sqlprocessutilization               AS [OtherProcessCPU Utilization],
              Dateadd(ms, -1 * ( @ts_now - [timestamp] ), Getdate()) AS [EventTime] 
INTO   #cpuutilization 
FROM   (SELECT record.value('(./Record/@id)[1]', 'int')                                                   AS record_id, 
               record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int')         AS 
               [SystemIdle], 
               record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') AS 
                      [SQLProcessUtilization], 
               [timestamp] 
        FROM   (SELECT [timestamp], 
                       CONVERT(XML, record) AS [record] 
                FROM   sys.dm_os_ring_buffers 
                WHERE  ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR' 
                       AND record LIKE '%<SystemHealth>%') AS x) AS y 
ORDER  BY record_id DESC 

-- check if the average CPU utilization was over 90% in the past 2 minutes 
SELECT @AvgCPUUtilization = Avg([sqlserverprocesscpuutilization] 
                                + [otherprocesscpu utilization]) 
FROM   #cpuutilization 
WHERE  eventtime > Dateadd(mm, -2, Getdate()) 

IF @AvgCPUUtilization >= 20 
  BEGIN 
      SELECT TOP(10) CONVERT(VARCHAR(25), @AvgCPUUtilization) 
                     + '%' 
                     AS [AvgCPUUtilization], 
                     Getdate() 
                     [Date and Time], 
                     r.cpu_time, 
                     r.total_elapsed_time, 
                     s.session_id, 
                     s.login_name, 
                     s.host_name, 
                     Db_name(r.database_id) 
                     AS DatabaseName, 
                     Substring (t.text, ( r.statement_start_offset / 2 ) + 1, 
                     ( ( CASE 
                           WHEN r.statement_end_offset = -1 THEN 
                     Len(CONVERT(NVARCHAR(max), t.text)) * 2 
                     ELSE r.statement_end_offset 
                                                                                  END - r.statement_start_offset ) / 2 )
                     + 
                     1 
                     ) 
                     AS 
                     [IndividualQuery], 
                     Substring(text, 1, 200) 
                     AS [ParentQuery], 
                     r.status, 
                     r.start_time, 
                     r.wait_type, 
                     s.program_name 
      INTO   #possiblecpuutilizationqueries 
      FROM   sys.dm_exec_sessions s 
             INNER JOIN sys.dm_exec_connections c 
                     ON s.session_id = c.session_id 
             INNER JOIN sys.dm_exec_requests r 
                     ON c.connection_id = r.connection_id 
             CROSS apply sys.Dm_exec_sql_text(r.sql_handle) t 
      WHERE  s.session_id > 50 
             AND r.session_id != @@spid 
      ORDER  BY r.cpu_time DESC 

      -- query the temp table, you can also send an email report to yourself or your development team
      SELECT * 
      FROM   #possiblecpuutilizationqueries 
  END 

-- drop the temp tables 
IF Object_id('TEMPDB..#CPUUtilization') IS NOT NULL 
  DROP TABLE #cpuutilization 

IF Object_id('TEMPDB..#PossibleCPUUtilizationQueries') IS NOT NULL 
=======
-- How to find the possible queries that caused high CPU utilization in the past 2 minutes? 
-- http://sqlblog.com/blogs/ben_nevarez/archive/2009/07/26/getting-cpu-utilization-data-from-sql-server.aspx 
-- http://sqlknowledge.com/2010/12/how-to-monitor-sql-server-cpu-usage-and-get-auto-alerts/ 
DECLARE @ts_now BIGINT 
DECLARE @SQLVersion DECIMAL (4, 2) -- 9.00, 10.00 
DECLARE @AvgCPUUtilization DECIMAL(10, 2) 

SELECT @SQLVersion = LEFT(Cast(Serverproperty('PRODUCTVERSION') AS VARCHAR), 4) -- find the SQL Server Version 
-- sys.dm_os_sys_info works differently in SQL Server 2005 vs SQL Server 2008+ 
-- comment out SQL Server 2005 if SQL Server 2008+ 
-- SQL Server 2005 
--IF @SQLVersion = 9.00 
--BEGIN  
--  SELECT @ts_now = cpu_ticks / CONVERT(float, cpu_ticks_in_ms) FROM sys.dm_os_sys_info  
--END 
-- SQL Server 2008+ 
IF @SQLVersion >= 10.00 
  BEGIN 
      SELECT @ts_now = cpu_ticks / ( cpu_ticks / ms_ticks ) 
      FROM   sys.dm_os_sys_info 
  END 

-- load the CPU utilization in the past 3 minutes into the temp table, you can load them into a permanent table
SELECT TOP(3) sqlprocessutilization                                  AS [SQLServerProcessCPUUtilization],
              systemidle                                             AS [SystemIdleProcess], 
              100 - systemidle - sqlprocessutilization               AS [OtherProcessCPU Utilization],
              Dateadd(ms, -1 * ( @ts_now - [timestamp] ), Getdate()) AS [EventTime] 
INTO   #cpuutilization 
FROM   (SELECT record.value('(./Record/@id)[1]', 'int')                                                   AS record_id, 
               record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int')         AS 
               [SystemIdle], 
               record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') AS 
                      [SQLProcessUtilization], 
               [timestamp] 
        FROM   (SELECT [timestamp], 
                       CONVERT(XML, record) AS [record] 
                FROM   sys.dm_os_ring_buffers 
                WHERE  ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR' 
                       AND record LIKE '%<SystemHealth>%') AS x) AS y 
ORDER  BY record_id DESC 

-- check if the average CPU utilization was over 90% in the past 2 minutes 
SELECT @AvgCPUUtilization = Avg([sqlserverprocesscpuutilization] 
                                + [otherprocesscpu utilization]) 
FROM   #cpuutilization 
WHERE  eventtime > Dateadd(mm, -2, Getdate()) 

IF @AvgCPUUtilization >= 20 
  BEGIN 
      SELECT TOP(10) CONVERT(VARCHAR(25), @AvgCPUUtilization) 
                     + '%' 
                     AS [AvgCPUUtilization], 
                     Getdate() 
                     [Date and Time], 
                     r.cpu_time, 
                     r.total_elapsed_time, 
                     s.session_id, 
                     s.login_name, 
                     s.host_name, 
                     Db_name(r.database_id) 
                     AS DatabaseName, 
                     Substring (t.text, ( r.statement_start_offset / 2 ) + 1, 
                     ( ( CASE 
                           WHEN r.statement_end_offset = -1 THEN 
                     Len(CONVERT(NVARCHAR(max), t.text)) * 2 
                     ELSE r.statement_end_offset 
                                                                                  END - r.statement_start_offset ) / 2 )
                     + 
                     1 
                     ) 
                     AS 
                     [IndividualQuery], 
                     Substring(text, 1, 200) 
                     AS [ParentQuery], 
                     r.status, 
                     r.start_time, 
                     r.wait_type, 
                     s.program_name 
      INTO   #possiblecpuutilizationqueries 
      FROM   sys.dm_exec_sessions s 
             INNER JOIN sys.dm_exec_connections c 
                     ON s.session_id = c.session_id 
             INNER JOIN sys.dm_exec_requests r 
                     ON c.connection_id = r.connection_id 
             CROSS apply sys.Dm_exec_sql_text(r.sql_handle) t 
      WHERE  s.session_id > 50 
             AND r.session_id != @@spid 
      ORDER  BY r.cpu_time DESC 

      -- query the temp table, you can also send an email report to yourself or your development team
      SELECT * 
      FROM   #possiblecpuutilizationqueries 
  END 

-- drop the temp tables 
IF Object_id('TEMPDB..#CPUUtilization') IS NOT NULL 
  DROP TABLE #cpuutilization 

IF Object_id('TEMPDB..#PossibleCPUUtilizationQueries') IS NOT NULL 
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
  DROP TABLE #possiblecpuutilizationqueries 