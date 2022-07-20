SELECT
    tb.name AS [Temporary Object Name],
    ps.row_count AS [# rows],
    ps.used_page_count * 8 AS [Used space (KB)],
    ps.reserved_page_count * 8 AS [Reserved space (KB)]
FROM
    tempdb.sys.partitions AS prt
    INNER JOIN tempdb.sys.dm_db_partition_stats AS ps ON prt.partition_id = ps.partition_id
    AND prt.partition_number = ps.partition_number
    INNER JOIN tempdb.sys.tables AS tb ON ps.object_id = tb.object_id
ORDER BY
    ps.reserved_page_count desc