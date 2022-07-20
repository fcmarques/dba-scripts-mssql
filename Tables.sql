USE QAN
GO
    SELECT TOP 1000
        (row_number() over(order by (a1.reserved + ISNULL(a4.reserved,0)) desc))%2 as l1,
        a3.name AS [schemaname],
        a2.name AS [tablename],
        a1.rows as row_count,
        (a1.reserved + ISNULL(a4.reserved,0))* 8 AS reserved,
        a1.data * 8 AS data,
        (CASE WHEN (a1.used + ISNULL(a4.used,0)) > a1.data THEN (a1.used + ISNULL(a4.used,0)) - a1.data ELSE 0 END) * 8 AS index_size,
        (CASE WHEN (a1.reserved + ISNULL(a4.reserved,0)) > a1.used THEN (a1.reserved + ISNULL(a4.reserved,0)) - a1.used ELSE 0 END) * 8 AS unused

    FROM    (   SELECT
                ps.object_id,
                SUM ( CASE WHEN (ps.index_id < 2) THEN row_count    ELSE 0 END ) AS [rows],
                SUM (ps.reserved_page_count) AS reserved,
                SUM (CASE   WHEN (ps.index_id < 2) THEN (ps.in_row_data_page_count + ps.lob_used_page_count + ps.row_overflow_used_page_count)
                            ELSE (ps.lob_used_page_count + ps.row_overflow_used_page_count) END
                    ) AS data,
                SUM (ps.used_page_count) AS used
                FROM sys.dm_db_partition_stats ps
                GROUP BY ps.object_id
            ) AS a1

    LEFT OUTER JOIN (   SELECT
                        it.parent_id,
                        SUM(ps.reserved_page_count) AS reserved,
                        SUM(ps.used_page_count) AS used
                        FROM sys.dm_db_partition_stats ps
                        INNER JOIN sys.internal_tables it ON (it.object_id = ps.object_id)
                        WHERE it.internal_type IN (202,204)
                        GROUP BY it.parent_id
                    ) AS a4 ON (a4.parent_id = a1.object_id)

    INNER JOIN sys.all_objects a2  ON ( a1.object_id = a2.object_id )

    INNER JOIN sys.schemas a3 ON (a2.schema_id = a3.schema_id)

    WHERE a2.type <> N'S' and a2.type <> N'IT'
    order by reserved DESC

========================================================================================
--lista o tamanho das tabelas
declare @cmd nvarchar(max),
		@ctrl int,
		@id int

--Criação da tabel de controle para acompanhar o processo

SELECT 
    t.NAME AS TableName,
    i.name as indexName,
    sum(p.rows) as RowCounts,
    sum(a.total_pages) as TotalPages, 
    sum(a.used_pages) as UsedPages, 
    sum(a.data_pages) as DataPages,
    (sum(a.total_pages) * 8) / 1024 as TotalSpaceMB, 
    (sum(a.used_pages) * 8) / 1024 as UsedSpaceMB, 
    (sum(a.data_pages) * 8) / 1024 as DataSpaceMB,
	getdate () data
into RCPL_IDCE
FROM 
    sys.tables t
INNER JOIN      
    sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN 
    sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN 
    sys.allocation_units a ON p.partition_id = a.container_id
WHERE 
    t.NAME NOT in (select a.name from sys.tables as a join sys.columns as b on a.object_id=b.object_id where b.system_type_id in (34,35,165,241)
										or (b.system_type_id = 165 and max_length < 0)
										or (b.system_type_id = 167 and max_length < 0)
										or (b.system_type_id = 231 and max_length < 0))
    --i.OBJECT_ID > 255 AND   
    and i.index_id <= 1
	and a.total_pages <= 8379272
GROUP BY 
    t.NAME, i.object_id, i.index_id, i.name 
ORDER BY 7 desc

