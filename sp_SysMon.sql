USE [master]
GO
IF OBJECT_ID('dbo.sp_SysMon') IS NULL
 EXEC('CREATE PROCEDURE dbo.sp_SysMon AS SELECT 1 AS ID')
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE dbo.sp_SysMon
AS
SET NOCOUNT ON
SET ANSI_WARNINGS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
DECLARE
 @BatchRequestsPerSecond BIGINT,
 @CompilationsPerSecond BIGINT,
 @ReCompilationsPerSecond BIGINT,
 @LockWaitsPerSecond BIGINT,
 @PageSplitsPerSecond BIGINT,
 @CheckpointPagesPerSecond BIGINT,
 @stat_date DATETIME,
 @MachineName VARCHAR(128) = CAST(SERVERPROPERTY('ComputerNamePhysicalNetBIOS')AS VARCHAR(128)),
 @SQLServerCPU TINYINT,
 @ServerCPU TINYINT
DECLARE
 @ServicePath NVARCHAR(156) = N'SYSTEM\CurrentControlSet\Services\' + CASE
                                                                            WHEN @@SERVICENAME = 'MSSQLSERVER' THEN 'MSSQLSERVER'
                                                                         ELSE 'MSSQL$' + @@SERVICENAME
                                                                        END,
 @MSSQLServiceAccountName VARCHAR(250)
EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', @ServicePath, N'ObjectName', @MSSQLServiceAccountName OUTPUT, N'no_output'
SET ANSI_WARNINGS OFF
SELECT
     @stat_date = GETDATE(),
     @BatchRequestsPerSecond = MAX(CASE
                                         WHEN counter_name = 'Batch Requests/sec'
                                         AND object_name LIKE '%SQL Statistics%' THEN cntr_value
                                     END),
     @CompilationsPerSecond = MAX(CASE
                                        WHEN counter_name = 'SQL Compilations/sec'
                                         AND object_name LIKE '%SQL Statistics%' THEN cntr_value
                                    END),
     @ReCompilationsPerSecond = MAX(CASE
                                         WHEN counter_name = 'SQL Re-Compilations/sec'
                                         AND object_name LIKE '%SQL Statistics%' THEN cntr_value
                                     END),
     @LockWaitsPerSecond = MAX(CASE
                                     WHEN counter_name = 'Lock Waits/sec'
                                     AND object_name LIKE '%Locks%'
                                     AND instance_name = '_Total' THEN cntr_value
                                 END),
     @PageSplitsPerSecond = MAX(CASE
                                     WHEN counter_name = 'Page Splits/sec'
                                     AND object_name LIKE '%Access Methods%' THEN cntr_value
                                 END),
     @CheckpointPagesPerSecond = MAX(CASE
                                         WHEN counter_name = 'Checkpoint Pages/sec'
                                            AND object_name LIKE '%Buffer Manager%' THEN cntr_value
                                     END)
FROM sys.dm_os_performance_counters AS a(NOLOCK)
WHERE(counter_name = 'Batch Requests/sec'
 AND object_name LIKE '%SQL Statistics%')
 OR (counter_name = 'SQL Compilations/sec'
 AND object_name LIKE '%SQL Statistics%')
 OR (counter_name = 'SQL Re-Compilations/sec'
 AND object_name LIKE '%SQL Statistics%')
 OR (counter_name = 'Lock Waits/sec'
 AND object_name LIKE '%Locks%'
 AND instance_name = '_Total')
 OR (counter_name = 'Page Splits/sec'
 AND object_name LIKE '%Access Methods%')
 OR (counter_name = 'Checkpoint Pages/sec'
 AND object_name LIKE '%Buffer Manager%')
WAITFOR DELAY '00:00:01'
SET ANSI_WARNINGS ON
SELECT
     @SQLServerCPU = SQLServerCPU,
     @ServerCPU = ServerCPU
FROM dbo.GetCPUUsage(1)
SELECT TOP (1)
     @SQLServerCPU = SQLProcessUtilization,
     @ServerCPU = 100 - SystemIdle
FROM(SELECT TOP 1
            cpu_ticks / cpu_ticks / ms_ticks AS ts_now
     FROM sys.dm_os_sys_info(NOLOCK))AS a
     CROSS JOIN sys.dm_os_ring_buffers(NOLOCK)
                 CROSS APPLY(SELECT
                                    CAST(record AS XML)AS rXML)AS rx
                             CROSS APPLY(SELECT
                                                XmlInfo.Record.value('(./@id)[1]', 'int')AS record_id,
                                                XmlInfo.Record.value('(./SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int')AS SystemIdle,
                                                XmlInfo.Record.value('(./SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int')AS SQLProcessUtilization
                                         FROM rXML.nodes('./Record')AS XmlInfo(Record))AS nd
WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
 AND record LIKE '%<SystemHealth>%'
ORDER BY
         timestamp DESC
SET ANSI_WARNINGS OFF;
WITH dd
    AS (SELECT
             [Batch Requests/sec] = MAX(CASE
                                             WHEN counter_name = 'Batch Requests/sec'
                                             AND object_name LIKE '%SQL Statistics%' THEN cntr_value
                                         END),
             [SQL Compilations/sec] = MAX(CASE
                                                WHEN counter_name = 'SQL Compilations/sec'
                                                 AND object_name LIKE '%SQL Statistics%' THEN cntr_value
                                            END),
             [SQL Re-Compilations/sec] = MAX(CASE
                                                 WHEN counter_name = 'SQL Re-Compilations/sec'
                                                    AND object_name LIKE '%SQL Statistics%' THEN cntr_value
                                             END),
             [Lock Waits/sec] = MAX(CASE
                                         WHEN counter_name = 'Lock Waits/sec'
                                         AND object_name LIKE '%Locks%'
                                         AND instance_name = '_Total' THEN cntr_value
                                     END),
             [Page Splits/sec] = MAX(CASE
                                         WHEN counter_name = 'Page Splits/sec'
                                            AND object_name LIKE '%Access Methods%' THEN cntr_value
                                     END),
             [Checkpoint Pages/sec] = MAX(CASE
                                                WHEN counter_name = 'Checkpoint Pages/sec'
                                                 AND object_name LIKE '%Buffer Manager%' THEN cntr_value
                                            END),
             PageLifeExpectency = MAX(CASE
                                            WHEN counter_name = 'Page life expectancy'
                                             AND object_name LIKE '%Buffer Manager%' THEN cntr_value
                                        END),
             [Buffer cache hit ratio] = MAX(CASE
                                                 WHEN counter_name = 'Buffer cache hit ratio'
                                                 AND object_name LIKE '%Buffer Manager%' THEN cntr_value
                                             END),
             [Buffer cache hit ratio base] = MAX(CASE
                                                     WHEN counter_name = 'Buffer cache hit ratio base'
                                                        AND object_name LIKE '%Buffer Manager%' THEN cntr_value
                                                 END),
             [Target Server Memory (MB)] = MAX(CASE
                                                     WHEN counter_name = 'Target Server Memory (KB)'
                                                     AND object_name LIKE '%:Memory Manager%' THEN cntr_value
                                                 END) / 1024.0,
             [Total Server Memory (MB)] = MAX(CASE
                                                    WHEN counter_name = 'Total Server Memory (KB)'
                                                     AND object_name LIKE '%:Memory Manager%' THEN cntr_value
                                                END) / 1024.0,
             [Connection Memory (MB)] = MAX(CASE
                                                 WHEN counter_name = 'Connection Memory (KB)'
                                                 AND object_name LIKE '%:Memory Manager%' THEN cntr_value
                                             END) / 1024.0,
             [Granted Workspace Memory (MB)] = MAX(CASE
                                                         WHEN counter_name = 'Granted Workspace Memory (KB)'
                                                         AND object_name LIKE '%:Memory Manager%' THEN cntr_value
                                                     END) / 1024.0,
             [Lock Memory (MB)] = MAX(CASE
                                            WHEN counter_name = 'Lock Memory (KB)'
                                             AND object_name LIKE '%:Memory Manager%' THEN cntr_value
                                        END) / 1024.0,
             [Maximum Workspace Memory (MB)] = MAX(CASE
                                                         WHEN counter_name = 'Maximum Workspace Memory (KB)'
                                                         AND object_name LIKE '%:Memory Manager%' THEN cntr_value
                                                     END) / 1024.0,
             [Memory Grants Outstanding] = MAX(CASE
                                                     WHEN counter_name = 'Memory Grants Outstanding'
                                                     AND object_name LIKE '%:Memory Manager%' THEN cntr_value
                                                 END),
             [Memory Grants Pending] = MAX(CASE
                                                 WHEN counter_name = 'Memory Grants Pending'
                                                 AND object_name LIKE '%:Memory Manager%' THEN cntr_value
                                             END),
             [Optimizer Memory (MB)] = MAX(CASE
                                                 WHEN counter_name = 'Optimizer Memory (KB)'
                                                 AND object_name LIKE '%:Memory Manager%' THEN cntr_value
                                             END) / 1024.0,
             [SQL Cache Memory (MB)] = MAX(CASE
                                                 WHEN counter_name = 'SQL Cache Memory (KB)'
                                                 AND object_name LIKE '%:Memory Manager%' THEN cntr_value
                                             END) / 1024.0,
             [User Connections] = MAX(CASE
                                            WHEN counter_name = 'User Connections'
                                             AND object_name LIKE '%General Statistics%' THEN cntr_value
                                        END),
             [Processes blocked] = MAX(CASE
                                             WHEN counter_name = 'Processes blocked'
                                             AND object_name LIKE '%General Statistics%' THEN cntr_value
                                         END),
             [Lock Blocks Allocated] = MAX(CASE
                                                 WHEN counter_name = 'Lock Blocks Allocated'
                                                 AND object_name LIKE '%:Memory Manager%' THEN cntr_value
                                             END),
             [Lock Owner Blocks Allocated] = MAX(CASE
                                                     WHEN counter_name = 'Lock Owner Blocks Allocated'
                                                        AND object_name LIKE '%:Memory Manager%' THEN cntr_value
                                                 END),
             [Lock Blocks] = MAX(CASE
                                     WHEN counter_name = 'Lock Blocks'
                                        AND object_name LIKE '%:Memory Manager%' THEN cntr_value
                                 END),
             [Lock Owner Blocks] = MAX(CASE
                                             WHEN counter_name = 'Lock Owner Blocks'
                                             AND object_name LIKE '%:Memory Manager%' THEN cntr_value
                                         END)
        FROM sys.dm_os_performance_counters AS a(NOLOCK)
        WHERE(counter_name = 'Batch Requests/sec'
         AND object_name LIKE '%SQL Statistics%')
         OR (counter_name = 'SQL Compilations/sec'
         AND object_name LIKE '%SQL Statistics%')
         OR (counter_name = 'SQL Re-Compilations/sec'
         AND object_name LIKE '%SQL Statistics%')
         OR (counter_name = 'Lock Waits/sec'
         AND object_name LIKE '%Locks%'
         AND instance_name = '_Total')
         OR (counter_name = 'Page Splits/sec'
         AND object_name LIKE '%Access Methods%')
         OR (counter_name = 'Checkpoint Pages/sec'
         AND object_name LIKE '%Buffer Manager%')
         OR (counter_name = 'Page life expectancy'
         AND object_name LIKE '%Buffer Manager%')
         OR (counter_name = 'Buffer cache hit ratio'
         AND object_name LIKE '%Buffer Manager%')
         OR (counter_name = 'Buffer cache hit ratio base'
         AND object_name LIKE '%Buffer Manager%')
         OR (counter_name = 'Target Server Memory (KB)'
         AND object_name LIKE '%:Memory Manager%')
         OR (counter_name = 'Total Server Memory (KB)'
         AND object_name LIKE '%:Memory Manager%')
         OR (counter_name = 'Connection Memory (KB)'
         AND object_name LIKE '%:Memory Manager%')
         OR (counter_name = 'Granted Workspace Memory (KB)'
         AND object_name LIKE '%:Memory Manager%')
         OR (counter_name = 'Lock Memory (KB)'
         AND object_name LIKE '%:Memory Manager%')
         OR (counter_name = 'Maximum Workspace Memory (KB)'
         AND object_name LIKE '%:Memory Manager%')
         OR (counter_name = 'Memory Grants Outstanding'
         AND object_name LIKE '%:Memory Manager%')
         OR (counter_name = 'Memory Grants Pending'
         AND object_name LIKE '%:Memory Manager%')
         OR (counter_name = 'Optimizer Memory (KB)'
         AND object_name LIKE '%:Memory Manager%')
         OR (counter_name = 'SQL Cache Memory (KB)'
         AND object_name LIKE '%:Memory Manager%')
         OR (counter_name = 'User Connections'
         AND object_name LIKE '%General Statistics%')
         OR (counter_name = 'Processes blocked'
         AND object_name LIKE '%General Statistics%')
         OR (counter_name = 'Lock Blocks Allocated'
         AND object_name LIKE '%:Memory Manager%')
         OR (counter_name = 'Lock Owner Blocks Allocated'
         AND object_name LIKE '%:Memory Manager%')
         OR (counter_name = 'Lock Blocks'
         AND object_name LIKE '%:Memory Manager%')
         OR (counter_name = 'Lock Owner Blocks'
         AND object_name LIKE '%:Memory Manager%')), rr
    AS (SELECT
             GETDATE()AS StatDate,
             @@SERVERNAME AS ServerName,
             @MachineName AS MachineName,
             @SQLServerCPU AS SQLServerCPU,
             @ServerCPU AS ServerCPU,
             [Buffer cache hit ratio] * 1.0 / [Buffer cache hit ratio base] * 100.0 AS BufferCacheHitRatio,
             PageLifeExpectency,
             CAST([Total Server Memory (MB)] / 4096 * 300 AS INT)AS PLEThreshold,
             m.available_physical_memory_kb / 1024 AS AvailablePhysicalMemoryMB,
             m.total_physical_memory_kb / 1024 AS TotalPhysicalMemoryMB,
             [Total Server Memory (MB)] AS TotalServerMemoryMB,
             [Target Server Memory (MB)] AS TargetServerMemoryMB,
             ([Batch Requests/sec] - @BatchRequestsPerSecond) / SecondsDiff AS BatchRequestsPerSecond,
             ([SQL Compilations/sec] - @CompilationsPerSecond) / SecondsDiff AS CompilationsPerSecond,
             ([SQL Re-Compilations/sec] - @ReCompilationsPerSecond) / SecondsDiff AS ReCompilationsPerSecond,
             ([Lock Waits/sec] - @LockWaitsPerSecond) / SecondsDiff AS LockWaitsPerSecond,
             ([Page Splits/sec] - @PageSplitsPerSecond) / SecondsDiff AS PageSplitsPerSecond,
             ([Checkpoint Pages/sec] - @CheckpointPagesPerSecond) / SecondsDiff AS CheckpointPagesPerSecond,
             [Connection Memory (MB)] AS ConnectionMemoryMB,
             [Granted Workspace Memory (MB)] AS GrantedWorkspaceMemoryMB,
             [Lock Memory (MB)] AS LockMemoryMB,
             [Maximum Workspace Memory (MB)] AS MaximumWorkspaceMemoryMB,
             [Memory Grants Outstanding] AS MemoryGrantsOutstanding,
             [Memory Grants Pending] AS MemoryGrantsPending,
             [Optimizer Memory (MB)] AS OptimizerMemoryMB,
             [SQL Cache Memory (MB)] AS SQLCacheMemoryMB,
             [Processes blocked] AS Processesblocked,
             [Lock Blocks Allocated] AS LockBlocksAllocated,
             [Lock Owner Blocks Allocated] AS LockOwnerBlocksAllocated,
             [Lock Blocks] AS LockBlocks,
             [Lock Owner Blocks] AS LockOwnerBlocks,
             [User Connections] AS UserConnections,
             pr.Sessions,
             pr.ServiceAccountSessions,
             pr.UserAccountSessions,
             pr.BlockingSessions,
             pr.BlockedSessions,
             pr.DormantSessions,
             pr.RunningSessions,
             pr.BackgroundSessions,
             pr.RollbackSessions,
             pr.PendingSessions,
             pr.RunnableSessions,
             pr.SpinloopSessions,
             pr.SuspendedSessions,
             pr.ServerStartTime
        FROM dd
             CROSS JOIN(SELECT
                                DATEDIFF(millisecond, @stat_date, GETDATE()) / 1000.0 AS SecondsDiff)AS sd
                         CROSS JOIN sys.dm_os_sys_memory AS m(NOLOCK)
                                     CROSS JOIN(SELECT
                                                     COUNT(DISTINCT spid)AS Sessions,
                                                     COUNT(DISTINCT CASE
                                                                         WHEN loginame = @MSSQLServiceAccountName THEN spid
                                                                     END)AS ServiceAccountSessions,
                                                     COUNT(DISTINCT CASE
                                                                         WHEN loginame NOT IN('', 'sa', @MSSQLServiceAccountName)THEN spid
                                                                     END)AS UserAccountSessions,
                                                     COUNT(DISTINCT NULLIF(blocked, 0))AS BlockingSessions,
                                                     COUNT(DISTINCT CASE
                                                                         WHEN blocked > 0 THEN spid
                                                                     END)AS BlockedSessions,
                                                     COUNT(DISTINCT CASE
                                                                         WHEN STATUS = 'dormant' THEN SPID
                                                                     END)AS DormantSessions,
                                                     COUNT(DISTINCT CASE
                                                                         WHEN STATUS = 'running' THEN SPID
                                                                     END)AS RunningSessions,
                                                     COUNT(DISTINCT CASE
                                                                         WHEN STATUS = 'background' THEN SPID
                                                                     END)AS BackgroundSessions,
                                                     COUNT(DISTINCT CASE
                                                                         WHEN STATUS = 'rollback' THEN SPID
                                                                     END)AS RollbackSessions,
                                                     COUNT(DISTINCT CASE
                                                                         WHEN STATUS = 'pending' THEN SPID
                                                                     END)AS PendingSessions,
                                                     COUNT(DISTINCT CASE
                                                                         WHEN STATUS = 'runnable' THEN SPID
                                                                     END)AS RunnableSessions,
                                                     COUNT(DISTINCT CASE
                                                                         WHEN STATUS = 'spinloop' THEN SPID
                                                                     END)AS SpinloopSessions,
                                                     COUNT(DISTINCT CASE
                                                                         WHEN STATUS = 'suspended' THEN SPID
                                                                     END)AS SuspendedSessions,
                                                     MIN(login_time)AS ServerStartTime
                                                FROM master.sys.sysprocesses(NOLOCK))AS pr)
    SELECT
         StatDate,
         ServerName AS SQLServerName,
         MachineName,
         SQLServerCPU,
         ServerCPU,
         PageLifeExpectency,
         PLEThreshold,
         CAST(CASE
                    WHEN PageLifeExpectency > PLEThreshold * 100 THEN NULL
                    WHEN PLEThreshold <> 0 THEN PageLifeExpectency * 100.0 / PLEThreshold
                 ELSE 0
                END AS NUMERIC(6, 2))AS [PLE%],
         BufferCacheHitRatio,
         AvailablePhysicalMemoryMB,
         TotalPhysicalMemoryMB,
         TotalServerMemoryMB,
         TargetServerMemoryMB,
         ConnectionMemoryMB,
         GrantedWorkspaceMemoryMB,
         LockMemoryMB,
         MaximumWorkspaceMemoryMB,
         OptimizerMemoryMB,
         SQLCacheMemoryMB,
         MemoryGrantsOutstanding,
         MemoryGrantsPending,
         BatchRequestsPerSecond,
         CompilationsPerSecond,
         ReCompilationsPerSecond,
         LockWaitsPerSecond,
         PageSplitsPerSecond,
         CheckpointPagesPerSecond,
         LockBlocks,
         LockBlocksAllocated,
         LockOwnerBlocks,
         LockOwnerBlocksAllocated,
         Processesblocked,
         BlockingSessions,
         BlockedSessions,
         UserConnections,
         Sessions,
         ServiceAccountSessions,
         UserAccountSessions,
         DormantSessions,
         RunningSessions,
         BackgroundSessions,
         RollbackSessions,
         PendingSessions,
         RunnableSessions,
         SpinloopSessions,
         SuspendedSessions,
         ServerStartTime,
         (SELECT
                 ISNULL(CAST(NULLIF(DATEDIFF(HOUR, ServerStartTime, StatDate) / 24, 0)AS VARCHAR) + ' days ', '') + RIGHT('0' + CAST(DATEDIFF(MINUTE, StartDateTime, StatDate) / 60 % 24 AS VARCHAR), 2) + ':' + RIGHT('0' + CAST(DATEDIFF(MINUTE, StartDateTime, StatDate) % 60 AS VARCHAR), 2) + ':' + RIGHT('0' + CAST(DATEDIFF(second, StartDateTime, StatDate) % 60 AS VARCHAR), 2)
            FROM(SELECT
                        DATEDIFF(DAY, ServerStartTime, StatDate)AS DayDiff)AS dd
                 CROSS APPLY(SELECT
                                    CASE
                                        WHEN DayDiff > 1 THEN DATEADD(DAY, DayDiff - 1, ServerStartTime)
                                     ELSE ServerStartTime
                                    END AS StartDateTime)AS b)AS ServerUpTime
    FROM rr
GO
EXEC sys.sp_MS_marksystemobject
 sp_SysMon
GO

EXEC sp_SysMon
