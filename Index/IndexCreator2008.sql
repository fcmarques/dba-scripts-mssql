/* 

	William Durkin (williamdurkin.wordpress.com) (@sql_williamd)
	2010-11-21
	Index Creator v1.1
		Fixed a syntax error - thanks @Fatherjack - spotted after 5 minutes!

	A script for generating create index commands.
	
	This interrogates all tables (system tables can be turned on and off via @IncludeSystemTables) and
	produces a create script for each index that can be found.
	
	It is clever enough to spot the difference between / usage of :
	
	  - Primary Keys
	  - Unique Constraints
	  - Clustered and Non-Clustered Indexes
	  - Filtered Indexes (produces the filter too)
	  - Included Columns
	  - Partitioned Tables/Indexes (although the partition schema and functions are not produced)
	  - Data Compression (on a partition level if used - yes this is possible!)
	  - Fill Factor
	  - Index Padding
	  - Locking (Row and Page)
	
	The variables at the beginning allow a little control over some settings that are not index specific, but system specific.
	These are best decided upon by the person generating the index creation commands, the defaults are conservative, with the 
	exception of @MaxDop which reads that settings from the system configuration view sys.configurations.

*/
DECLARE @IncludeSystemTables bit = 0,
    @MaxDop tinyint = (SELECT   CONVERT(tinyint, value_in_use)
                       FROM     sys.configurations
                       WHERE    name = 'max degree of parallelism'),
    @SortInTempDB bit = 0,
    @DropExisting bit = 0,
    @OnlineProcessing bit = 0,
    @StatsRecompute bit = 0
		/* Edition check for online index processing */
IF SERVERPROPERTY('EngineEdition') <> 3
    AND @OnlineProcessing = 1 
    BEGIN
        SET @OnlineProcessing = 0
        RAISERROR ('Online Index Processing only supported with Enterprise, Developer and Datacenter Editions',10,1) WITH NOWAIT
    END

/* SELECT to do the work */	
SELECT  CASE WHEN (I.is_unique_constraint = 0
                   AND I.is_primary_key = 0) THEN 'CREATE '
             ELSE 'ALTER TABLE ' + QUOTENAME(S.name) + '.' + QUOTENAME(O.name) + ' ADD CONSTRAINT ' + QUOTENAME(I.name) + ' '
        END + CASE WHEN I.is_unique = 1
                        AND I.is_primary_key = 0 THEN 'UNIQUE '
                   WHEN I.is_unique = 1
                        AND I.is_primary_key = 1 THEN 'PRIMARY KEY '
                   ELSE ''
              END + CASE WHEN I.type_desc = 'CLUSTERED' THEN 'CLUSTERED '
                         ELSE 'NONCLUSTERED '
                    END + CASE WHEN (I.is_unique_constraint = 0
                                     AND I.is_primary_key = 0) THEN 'INDEX ' + QUOTENAME(I.name) + ' '
                               ELSE ''
                          END + CASE WHEN (I.is_unique_constraint = 0
                                           AND I.is_primary_key = 0) THEN ' ON ' + QUOTENAME(S.name) + '.' + QUOTENAME(O.name)
                                     ELSE ''
                                END + ' (' + IC.index_columns_key + ') ' + ISNULL('INCLUDE (' + IC.index_columns_include + ')', '') + CASE WHEN (I.has_filter = 1
                                                                                                                                                 AND I.filter_definition IS NOT NULL) THEN ' WHERE ' + I.filter_definition
                                                                                                                                           ELSE ''
                                                                                                                                      END + 'WITH (' + CASE WHEN (i.allow_page_locks = 1) THEN 'ALLOW_PAGE_LOCKS = ON, '
                                                                                                                                                            ELSE 'ALLOW_PAGE_LOCKS = OFF, '
                                                                                                                                                       END + CASE WHEN (i.allow_row_locks = 1) THEN 'ALLOW_ROW_LOCKS = ON, '
                                                                                                                                                                  ELSE 'ALLOW_ROW_LOCKS = OFF, '
                                                                                                                                                             END + CASE WHEN (i.is_padded = 1) THEN 'PAD_INDEX = ON, '
                                                                                                                                                                        ELSE 'PAD_INDEX = OFF, '
                                                                                                                                                                   END + CASE WHEN (i.ignore_dup_key = 1) THEN 'IGNORE_DUP_KEY = ON, '
                                                                                                                                                                              ELSE 'IGNORE_DUP_KEY = OFF, '
                                                                                                                                                                         END + CASE WHEN (i.fill_factor <> 0) THEN 'FILLFACTOR = ' + CAST((i.fill_factor) AS varchar(3)) + ', '
                                                                                                                                                                                    ELSE 'FILLFACTOR = 100, '
                                                                                                                                                                               END + ISNULL('DATA_COMPRESSION = NONE ON PARTITIONS (' + PC.NoCompression + ')' + ', DATA_COMPRESSION = ROW ON PARTITIONS (' + PC.RowCompression + ')' + ', DATA_COMPRESSION = PAGE ON PARTITIONS (' + PC.PageCompression + '), ', CASE WHEN PC.RowCompression IS NOT NULL THEN 'DATA_COMPRESSION = ROW, '
                                                                                                                                                                                                                                                                                                                                                                                                                       ELSE CASE WHEN PC.PageCompression IS NOT NULL THEN 'DATA_COMPRESSION = PAGE, '
                                                                                                                                                                                                                                                                                                                                                                                                                                 ELSE ''
                                                                                                                                                                                                                                                                                                                                                                                                                            END
                                                                                                                                                                                                                                                                                                                                                                                                                  END) + 'STATISTICS_NORECOMPUTE = ' + CASE WHEN @StatsRecompute = 1 THEN 'ON'
                                                                                                                                                                                                                                                                                                                                                                                                                                                            ELSE 'OFF'
                                                                                                                                                                                                                                                                                                                                                                                                                                                       END + ', SORT_IN_TEMPDB = ' + CASE WHEN @SortInTempDB = 1 THEN 'ON'
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          ELSE 'OFF'
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     END + CASE WHEN (I.is_unique_constraint = 0
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      AND I.is_primary_key = 0) THEN ', DROP_EXISTING = ' + CASE WHEN @DropExisting = 1 THEN 'ON'
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 ELSE 'OFF'
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            END
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                ELSE ''
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           END + ', ONLINE = ' + CASE WHEN @OnlineProcessing = 1 THEN 'ON'
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      ELSE 'OFF'
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 END + ', MAXDOP = ' + CAST(@MaxDop AS varchar(5)) + ' ) ON ' + QUOTENAME(ISNULL(FG.name, PS.name))
FROM    sys.objects O
INNER JOIN sys.schemas S ON O.schema_id = S.schema_id
INNER JOIN sys.indexes I ON I.object_id = O.object_id
LEFT JOIN sys.filegroups FG ON I.data_space_id = FG.data_space_id
LEFT JOIN sys.partition_schemes PS ON PS.data_space_id = I.data_space_id
CROSS APPLY (SELECT LEFT(index_columns_key, LEN(index_columns_key) - 1) AS index_columns_key,
                    LEFT(index_columns_include, LEN(index_columns_include) - 1) AS index_columns_include
             FROM   (SELECT (SELECT QUOTENAME(c.name) + ','
                             FROM   sys.index_columns ic
                             JOIN   sys.columns c ON ic.column_id = c.column_id
                                                     AND ic.object_id = c.object_id
                             WHERE  ic.is_included_column = 0
                                    AND I.object_id = ic.object_id
                                    AND I.index_id = ic.index_id
                             ORDER BY key_ordinal
                            FOR
                             XML PATH('')) AS index_columns_key,
                            (SELECT QUOTENAME(c.name) + ','
                             FROM   sys.index_columns ic
                             JOIN   sys.columns c ON ic.column_id = c.column_id
                                                     AND ic.object_id = c.object_id
                             WHERE  ic.is_included_column = 1
                                    AND I.object_id = ic.object_id
                                    AND I.index_id = ic.index_id
                             ORDER BY index_column_id
                            FOR
                             XML PATH('')) AS index_columns_include) AS Index_Columns) IC
OUTER APPLY (--/* Get the compression information for each partition of an index, as they can have different compression settings*/
             SELECT LEFT(NoCompression, LEN(NoCompression) - 1) AS NoCompression,
                    LEFT(RowCompression, LEN(RowCompression) - 1) AS RowCompression,
                    LEFT(PageCompression, LEN(PageCompression) - 1) AS PageCompression
             FROM   (SELECT (SELECT CAST(Parts.partition_number AS varchar(10)) + ','
                             FROM   sys.partitions Parts
                             INNER JOIN sys.indexes PartInd ON Parts.object_id = PartInd.object_id
                                                               AND Parts.index_id = PartInd.index_id
                             WHERE  Parts.data_compression_desc = 'NONE'
                                    AND I.object_id = PartInd.object_id
                                    AND I.index_id = PartInd.index_id
                            FOR
                             XML PATH('')) NoCompression,
                            (SELECT CAST(Parts.partition_number AS varchar(10)) + ','
                             FROM   sys.partitions Parts
                             INNER JOIN sys.indexes PartInd ON Parts.object_id = PartInd.object_id
                                                               AND Parts.index_id = PartInd.index_id
                             WHERE  Parts.data_compression_desc = 'ROW'
                                    AND I.object_id = PartInd.object_id
                                    AND I.index_id = PartInd.index_id
                            FOR
                             XML PATH('')) RowCompression,
                            (SELECT CAST(Parts.partition_number AS varchar(10)) + ','
                             FROM   sys.partitions Parts
                             INNER JOIN sys.indexes PartInd ON Parts.object_id = PartInd.object_id
                                                               AND Parts.index_id = PartInd.index_id
                             WHERE  Parts.data_compression_desc = 'PAGE'
                                    AND I.object_id = PartInd.object_id
                                    AND I.index_id = PartInd.index_id
                            FOR
                             XML PATH('')) PageCompression) PartCompression) PC
WHERE   i.type > 0 /* Only interested in tables that have indexes or are clustered indexes - heaps themselves are irrelevant here */
        AND (1 = @IncludeSystemTables /* Only user tables, or also system tables? */
             OR o.type = 'u')