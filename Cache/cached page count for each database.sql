<<<<<<< HEAD
SELECT COUNT(*)AS cached_pages_count  
    ,CASE database_id   
        WHEN 32767 THEN 'ResourceDb'   
        ELSE db_name(database_id)   
        END AS database_name  
FROM sys.dm_os_buffer_descriptors  
GROUP BY DB_NAME(database_id) ,database_id  
ORDER BY cached_pages_count DESC;  


/*
select count(*)*8 AS 'Cached Size (KB)'        
,case database_id                
when 32767 then 'ResourceDB'                
else db_name(database_id)                
end as 'Database'
from sys.dm_os_buffer_descriptors
where page_type in
(
'INDEX_PAGE'
,'DATA_PAGE'
)
group by db_name(database_id), database_id
order by 'Cached Size (KB)' desc
=======
SELECT COUNT(*)AS cached_pages_count  
    ,CASE database_id   
        WHEN 32767 THEN 'ResourceDb'   
        ELSE db_name(database_id)   
        END AS database_name  
FROM sys.dm_os_buffer_descriptors  
GROUP BY DB_NAME(database_id) ,database_id  
ORDER BY cached_pages_count DESC;  


/*
select count(*)*8 AS 'Cached Size (KB)'        
,case database_id                
when 32767 then 'ResourceDB'                
else db_name(database_id)                
end as 'Database'
from sys.dm_os_buffer_descriptors
where page_type in
(
'INDEX_PAGE'
,'DATA_PAGE'
)
group by db_name(database_id), database_id
order by 'Cached Size (KB)' desc
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
*/