SELECT SUM(unallocated_extent_page_count) AS [free_pages]
,(SUM(unallocated_extent_page_count) * 1.0 / 128) AS [free_space_MB]
,SUM(version_store_reserved_page_count) AS [version_pages_used]
,(SUM(version_store_reserved_page_count) * 1.0 / 128) AS [version_space_MB]
,SUM(internal_object_reserved_page_count) AS [internal_object_pages_used]
,(SUM(internal_object_reserved_page_count) * 1.0 / 128) AS [internal_object_space_MB]
,SUM(user_object_reserved_page_count) AS [user object pages used]
,(SUM(user_object_reserved_page_count) * 1.0 / 128) AS [user_object_space_MB]
FROM sys.dm_db_file_space_usage;
GO