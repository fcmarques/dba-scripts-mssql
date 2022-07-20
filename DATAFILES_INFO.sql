SELECT Db_name(mf.database_id)                 AS databasename, 
       name                                    AS file_logicalname, 
       CASE 
         WHEN type_desc = 'LOG' THEN 'Log File' 
         WHEN type_desc = 'ROWS' THEN 'Data File' 
         ELSE type_desc 
       END                                     AS file_type_desc, 
       mf.physical_name, 
       num_of_reads, 
       num_of_bytes_read, 
       io_stall_read_ms, 
       num_of_writes, 
       num_of_bytes_written, 
       io_stall_write_ms, 
       io_stall, 
       size_on_disk_bytes, 
       size_on_disk_bytes / 1024               AS size_on_disk_kb, 
       size_on_disk_bytes / 1024 / 1024        AS size_on_disk_mb, 
       size_on_disk_bytes / 1024 / 1024 / 1024 AS size_on_disk_gb 
FROM   sys.Dm_io_virtual_file_stats(NULL, NULL) AS divfs 
       JOIN sys.master_files AS mf 
         ON mf.database_id = divfs.database_id 
            AND mf.file_id = divfs.file_id 
ORDER  BY 1 DESC 