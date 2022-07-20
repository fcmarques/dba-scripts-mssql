CREATE FUNCTION dbo.GetCPUUsage (@TOP INT = 1)
RETURNS TABLE
RETURN
    SELECT TOP (@TOP)
            SQLProcessUtilization AS SQLServerCPU,
            100 - SystemIdle AS ServerCPU,
            DATEADD(ms, -1 * (ts_now - [timestamp]), GETDATE()) AS [EventTime]
    FROM    (SELECT TOP 1 cpu_ticks/ (cpu_ticks/ ms_ticks) AS ts_now FROM sys.dm_os_sys_info (NOLOCK)) a
    CROSS JOIN sys.dm_os_ring_buffers (NOLOCK)
    CROSS APPLY (SELECT CAST( record AS XML) AS rXML) rx
    CROSS APPLY (SELECT XmlInfo.Record.value('(./@id)[1]', 'int') AS record_id,
                        XmlInfo.Record.value('(./SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') AS SystemIdle,
                        XmlInfo.Record.value('(./SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') AS SQLProcessUtilization
                 FROM   rXML.nodes('./Record') AS XmlInfo (Record)) nd
    WHERE   ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
            AND record LIKE '%%'
    ORDER BY [timestamp] DESC