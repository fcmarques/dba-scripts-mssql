
--use Dbalog
--go

--CREATE TABLE info_index_compress(
--Data				datetime,
--server_name			varchar(200),
--dbname				varchar(50),
--Table_Name			NVARCHAR(200),
--Index_Name			VARCHAR(200),
--[Partition]			INT,
--Index_ID				INT,
--Index_Type			NVARCHAR(50),
--Percent_Scan			INT,
--Percent_Update		INT,
--Compress_Type		Varchar(10)
--)


--select * from  dbalog.dbo.info_index_compress 



create procedure pr_levantamento_compress
as
begin




--insert into [RSQLADM\MAPS].dbalog.dbo.info_index_compress (Data, server_name,dbname,[Table_Name],[Index_Name],[Partition],[Index_ID],
--[Index_Type],[Percent_Scan],[Percent_Update], Compress_Type)
--SELECT getdate(), @@SERVERNAME, DB_NAME() as dbname ,o.name AS [Table_Name], x.name AS [Index_Name],
--       i.partition_number AS [Partition],
--       i.index_id AS [Index_ID], x.type_desc AS [Index_Type],
--       i.range_scan_count * 100.0 /
--           (i.range_scan_count + i.leaf_insert_count
--            + i.leaf_delete_count + i.leaf_update_count
--            + i.leaf_page_merge_count + i.singleton_lookup_count
--           ) AS [Percent_Scan],
           
--           i.leaf_update_count * 100.0 /
--           (i.range_scan_count + i.leaf_insert_count
--            + i.leaf_delete_count + i.leaf_update_count
--            + i.leaf_page_merge_count + i.singleton_lookup_count
--           ) AS [Percent_Update],
--          	CASE WHEN (   i.range_scan_count * 100.0 /
--           (i.range_scan_count + i.leaf_insert_count
--            + i.leaf_delete_count + i.leaf_update_count
--            + i.leaf_page_merge_count + i.singleton_lookup_count
--           ) > 75 AND  i.leaf_update_count * 100.0 /
--           (i.range_scan_count + i.leaf_insert_count
--            + i.leaf_delete_count + i.leaf_update_count
--            + i.leaf_page_merge_count + i.singleton_lookup_count
--           ) < 20) THEN 'PAGE' ELSE 'ROW' END AS Compress_Type
--FROM sys.dm_db_index_operational_stats (db_id(), NULL, NULL, NULL) i
--JOIN sys.objects o ON o.object_id = i.object_id
--JOIN sys.indexes x ON x.object_id = i.object_id 
--AND x.index_id = i.index_id
--WHERE (i.range_scan_count + i.leaf_insert_count
--       + i.leaf_delete_count + leaf_update_count
--       + i.leaf_page_merge_count + i.singleton_lookup_count) != 0
--AND objectproperty(i.object_id,'IsUserTable') = 1
--AND 



--end





-- select * from dbalog.dbo.info_index_compress where table_name = 'tb_rotativo'


exec sp_MSforeachdb 'use ?  insert into [RSQLADM\MAPS].dbalog.dbo.info_index_compress (Data, server_name,dbname,[Table_Name],[Index_Name],[Partition],[Index_ID],
[Index_Type],[Percent_Scan],[Percent_Update], Compress_Type)
SELECT getdate(), @@SERVERNAME, DB_NAME() as dbname ,o.name AS [Table_Name], x.name AS [Index_Name],
       i.partition_number AS [Partition],
       i.index_id AS [Index_ID], x.type_desc AS [Index_Type],
       i.range_scan_count * 100.0 /
           (i.range_scan_count + i.leaf_insert_count
            + i.leaf_delete_count + i.leaf_update_count
            + i.leaf_page_merge_count + i.singleton_lookup_count
           ) AS [Percent_Scan],           
           i.leaf_update_count * 100.0 /
           (i.range_scan_count + i.leaf_insert_count
            + i.leaf_delete_count + i.leaf_update_count
            + i.leaf_page_merge_count + i.singleton_lookup_count
           ) AS [Percent_Update],
          	CASE WHEN (   i.range_scan_count * 100.0 /
           (i.range_scan_count + i.leaf_insert_count
            + i.leaf_delete_count + i.leaf_update_count
            + i.leaf_page_merge_count + i.singleton_lookup_count
           ) > 75 AND  i.leaf_update_count * 100.0 /
           (i.range_scan_count + i.leaf_insert_count
            + i.leaf_delete_count + i.leaf_update_count
            + i.leaf_page_merge_count + i.singleton_lookup_count
           ) < 20) THEN ''PAGE'' ELSE ''ROW'' END AS Compress_Type
FROM sys.dm_db_index_operational_stats (db_id(), NULL, NULL, NULL) i
JOIN sys.objects o ON o.object_id = i.object_id
JOIN sys.indexes x ON x.object_id = i.object_id 
AND x.index_id = i.index_id
WHERE (i.range_scan_count + i.leaf_insert_count
       + i.leaf_delete_count + leaf_update_count
       + i.leaf_page_merge_count + i.singleton_lookup_count) != 0
AND objectproperty(i.object_id,''IsUserTable'') = 1'



end




