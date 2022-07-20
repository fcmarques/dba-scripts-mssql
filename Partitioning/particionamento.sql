select object_name(i.object_id)
from sys.partitions p join sys.indexes i on p.object_id = i.object_id 
and p.index_id= i.index_id
join sys.partition_schemes ps on ps.data_space_id = i.data_space_id
join sys.partition_functions f on f.function_id = ps.function_id
left join sys.partition_range_values rv on f.function_id = rv.function_id 
and p.partition_number = rv.boundary_id
join sys.destination_data_spaces dds on dds.partition_scheme_id=ps.data_space_id
and dds.destination_id = p.partition_number
join sys.filegroups fg on dds.data_space_id = fg.data_space_id
join (select container_id, sum(total_pages) as total_pages
from sys.allocation_units group by container_id) as au
on au.container_id= p.partition_id
where i.object_id=object_id('preco_venda')


select * from sys.partition_schemes
select * from  sys.partition_functions
select * from  sys.partition_range_values 