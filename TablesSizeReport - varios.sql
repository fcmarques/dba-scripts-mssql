;with cte as (
SELECT
t.name as TableName,
SUM (s.used_page_count) as used_pages_count,
SUM (CASE
            WHEN (i.index_id < 2) THEN (in_row_data_page_count + lob_used_page_count + row_overflow_used_page_count)
            ELSE lob_used_page_count + row_overflow_used_page_count
        END) as pages
FROM sys.dm_db_partition_stats  AS s 
JOIN sys.tables AS t ON s.object_id = t.object_id
JOIN sys.indexes AS i ON i.[object_id] = t.[object_id] AND s.index_id = i.index_id
GROUP BY t.name
)
select
    cte.TableName, 
    cast((cte.pages * 8.)/1024 as decimal(10,3)) as TableSizeInMB, 
    cast(((CASE WHEN cte.used_pages_count > cte.pages 
                THEN cte.used_pages_count - cte.pages
                ELSE 0 
          END) * 8./1024) as decimal(10,3)) as IndexSizeInMB
from cte
order by 2 desc

------------------------------------------------------------------------------------------------

SELECT 
    t.NAME AS TableName,
    s.Name AS SchemaName,
    p.rows AS RowCounts,
    SUM(a.total_pages) * 8 AS TotalSpaceKB, 
    CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS TotalSpaceMB,
    SUM(a.used_pages) * 8 AS UsedSpaceKB, 
    CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS UsedSpaceMB, 
    (SUM(a.total_pages) - SUM(a.used_pages)) * 8 AS UnusedSpaceKB,
    CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00, 2) AS NUMERIC(36, 2)) AS UnusedSpaceMB
FROM 
    sys.tables t
INNER JOIN      
    sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN 
    sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN 
    sys.allocation_units a ON p.partition_id = a.container_id
LEFT OUTER JOIN 
    sys.schemas s ON t.schema_id = s.schema_id
WHERE 
    t.NAME NOT LIKE 'dt%' 
    AND t.is_ms_shipped = 0
    AND i.OBJECT_ID > 255 
GROUP BY 
    t.Name, s.Name, p.Rows
ORDER BY 
    t.Name

------------------------------------------------------------------------------------------------

SELECT
    a2.name AS [tablename],
    a1.rows as row_count,
    (a1.reserved + ISNULL(a4.reserved,0))* 8 AS reserved, 
    a1.data * 8 AS data,
    (CASE WHEN (a1.used + ISNULL(a4.used,0)) > a1.data THEN (a1.used + ISNULL(a4.used,0)) - a1.data ELSE 0 END) * 8 AS index_size,
    (CASE WHEN (a1.reserved + ISNULL(a4.reserved,0)) > a1.used THEN (a1.reserved + ISNULL(a4.reserved,0)) - a1.used ELSE 0 END) * 8 AS unused
FROM
    (SELECT 
        ps.object_id,
        SUM (
            CASE
                WHEN (ps.index_id < 2) THEN row_count
                ELSE 0
            END
            ) AS [rows],
        SUM (ps.reserved_page_count) AS reserved,
        SUM (
            CASE
                WHEN (ps.index_id < 2) THEN (ps.in_row_data_page_count + ps.lob_used_page_count + ps.row_overflow_used_page_count)
                ELSE (ps.lob_used_page_count + ps.row_overflow_used_page_count)
            END
            ) AS data,
        SUM (ps.used_page_count) AS used
    FROM sys.dm_db_partition_stats ps
        --WHERE ps.object_id NOT IN (SELECT object_id FROM sys.tables WHERE is_memory_optimized = 1)
    GROUP BY ps.object_id) AS a1
LEFT OUTER JOIN 
    (SELECT 
        it.parent_id,
        SUM(ps.reserved_page_count) AS reserved,
        SUM(ps.used_page_count) AS used
     FROM sys.dm_db_partition_stats ps
     INNER JOIN sys.internal_tables it ON (it.object_id = ps.object_id)
     WHERE it.internal_type IN (202,204)
     GROUP BY it.parent_id) AS a4 ON (a4.parent_id = a1.object_id)
INNER JOIN sys.all_objects a2  ON ( a1.object_id = a2.object_id ) 
INNER JOIN sys.schemas a3 ON (a2.schema_id = a3.schema_id)
WHERE a2.type <> N'S' and a2.type <> N'IT'
ORDER BY 4 desc --a3.name, a2.name

------------------------------------------------------------------------------------------------

with fs
as
(
select i.object_id,
        p.rows AS RowCounts,
        SUM(a.total_pages) * 8 AS TotalSpaceKb
from     sys.indexes i INNER JOIN 
        sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id INNER JOIN 
         sys.allocation_units a ON p.partition_id = a.container_id
WHERE 
    i.OBJECT_ID > 255 
GROUP BY 
    i.object_id,
    p.rows
)

SELECT 
    t.NAME AS TableName,
    fs.RowCounts,
    fs.TotalSpaceKb,
    t.create_date,
    t.modify_date,
    ( select COUNT(1)
        from sys.columns c 
        where c.object_id = t.object_id ) TotalColumns    
FROM 
    sys.tables t INNER JOIN      
    fs  ON t.OBJECT_ID = fs.object_id
WHERE 
    t.NAME NOT LIKE 'dt%' 
    AND t.is_ms_shipped = 0
ORDER BY 
    t.Name

------------------------------------------------------------------------------------------------
	
SELECT
    a2.name AS TableName,
    a1.rows as [RowCount],
    --(a1.reserved + ISNULL(a4.reserved,0)) * 8 AS ReservedSize_KB,
    --a1.data * 8 AS DataSize_KB,
    --(CASE WHEN (a1.used + ISNULL(a4.used,0)) > a1.data THEN (a1.used + ISNULL(a4.used,0)) - a1.data ELSE 0 END) * 8 AS IndexSize_KB,
    --(CASE WHEN (a1.reserved + ISNULL(a4.reserved,0)) > a1.used THEN (a1.reserved + ISNULL(a4.reserved,0)) - a1.used ELSE 0 END) * 8 AS UnusedSize_KB,
    CAST(ROUND(((a1.reserved + ISNULL(a4.reserved,0)) * 8) / 1024.00, 2) AS NUMERIC(36, 2)) AS ReservedSize_MB,
    CAST(ROUND(a1.data * 8 / 1024.00, 2) AS NUMERIC(36, 2)) AS DataSize_MB,
    CAST(ROUND((CASE WHEN (a1.used + ISNULL(a4.used,0)) > a1.data THEN (a1.used + ISNULL(a4.used,0)) - a1.data ELSE 0 END) * 8 / 1024.00, 2) AS NUMERIC(36, 2)) AS IndexSize_MB,
    CAST(ROUND((CASE WHEN (a1.reserved + ISNULL(a4.reserved,0)) > a1.used THEN (a1.reserved + ISNULL(a4.reserved,0)) - a1.used ELSE 0 END) * 8 / 1024.00, 2) AS NUMERIC(36, 2)) AS UnusedSize_MB,
    --'| |' Separator_MB_GB,
    CAST(ROUND(((a1.reserved + ISNULL(a4.reserved,0)) * 8) / 1024.00 / 1024.00, 2) AS NUMERIC(36, 2)) AS ReservedSize_GB,
    CAST(ROUND(a1.data * 8 / 1024.00 / 1024.00, 2) AS NUMERIC(36, 2)) AS DataSize_GB,
    CAST(ROUND((CASE WHEN (a1.used + ISNULL(a4.used,0)) > a1.data THEN (a1.used + ISNULL(a4.used,0)) - a1.data ELSE 0 END) * 8 / 1024.00 / 1024.00, 2) AS NUMERIC(36, 2)) AS IndexSize_GB,
    CAST(ROUND((CASE WHEN (a1.reserved + ISNULL(a4.reserved,0)) > a1.used THEN (a1.reserved + ISNULL(a4.reserved,0)) - a1.used ELSE 0 END) * 8 / 1024.00 / 1024.00, 2) AS NUMERIC(36, 2)) AS UnusedSize_GB
FROM
    (SELECT 
        ps.object_id,
        SUM (CASE WHEN (ps.index_id < 2) THEN row_count ELSE 0 END) AS [rows],
        SUM (ps.reserved_page_count) AS reserved,
        SUM (CASE
                WHEN (ps.index_id < 2) THEN (ps.in_row_data_page_count + ps.lob_used_page_count + ps.row_overflow_used_page_count)
                ELSE (ps.lob_used_page_count + ps.row_overflow_used_page_count)
            END
            ) AS data,
        SUM (ps.used_page_count) AS used
    FROM sys.dm_db_partition_stats ps
        --===Remove the following comment for SQL Server 2014+
        --WHERE ps.object_id NOT IN (SELECT object_id FROM sys.tables WHERE is_memory_optimized = 1)
    GROUP BY ps.object_id) AS a1
LEFT OUTER JOIN 
    (SELECT 
        it.parent_id,
        SUM(ps.reserved_page_count) AS reserved,
        SUM(ps.used_page_count) AS used
     FROM sys.dm_db_partition_stats ps
     INNER JOIN sys.internal_tables it ON (it.object_id = ps.object_id)
     WHERE it.internal_type IN (202,204)
     GROUP BY it.parent_id) AS a4 ON (a4.parent_id = a1.object_id)
INNER JOIN sys.all_objects a2  ON ( a1.object_id = a2.object_id ) 
INNER JOIN sys.schemas a3 ON (a2.schema_id = a3.schema_id)
WHERE a2.type <> N'S' and a2.type <> N'IT'
--AND a2.name = 'MyTable'       --Filter for specific table
--ORDER BY a3.name, a2.name
ORDER BY ReservedSize_MB DESC

------------------------------------------------------------------------------------------------
	
SELECT *
FROM
(

SELECT 
    t.NAME AS TableName,
    s.Name AS SchemaName,
    p.rows AS RowCounts,
    COUNT(DISTINCT c.COLUMN_NAME) as ColumnCount,
    SUM(a.total_pages) * 8 AS TotalSpaceKB, 
    (SUM(a.used_pages) * 8) AS UsedSpaceKB, 
    (SUM(a.total_pages) - SUM(a.used_pages)) * 8 AS UnusedSpaceKB
FROM 
    sys.tables t
INNER JOIN      
    sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN 
    sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN 
    sys.allocation_units a ON p.partition_id = a.container_id
INNER JOIN
    INFORMATION_SCHEMA.COLUMNS c ON t.NAME = c.TABLE_NAME
LEFT OUTER JOIN 
    sys.schemas s ON t.schema_id = s.schema_id
WHERE 
    t.NAME NOT LIKE 'dt%' 
    AND t.is_ms_shipped = 0
    AND i.OBJECT_ID > 255
GROUP BY 
    t.Name, s.Name, p.Rows
) AS Result

WHERE
    RowCounts > 1000
    AND ColumnCount > 10
ORDER BY 
    UsedSpaceKB DESC