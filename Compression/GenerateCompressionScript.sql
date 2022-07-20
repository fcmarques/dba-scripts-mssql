<<<<<<< HEAD
select 'ALTER TABLE [' + name + '] REBUILD WITH (DATA_COMPRESSION = PAGE);'   
from   sysobjects   where  type = 'U' -- all user tables
UNION
select 'ALTER INDEX [' + k.name + '] ON [' + t.name + '] REBUILD WITH (DATA_COMPRESSION = PAGE);'
from   sysobjects k
join sysobjects t on k.parent_obj = t.id
   where  k.type = 'K' -- all keys
    AND t.type = 'U' -- all user tables
	
=======
select 'ALTER TABLE [' + name + '] REBUILD WITH (DATA_COMPRESSION = PAGE);'   
from   sysobjects   where  type = 'U' -- all user tables
UNION
select 'ALTER INDEX [' + k.name + '] ON [' + t.name + '] REBUILD WITH (DATA_COMPRESSION = PAGE);'
from   sysobjects k
join sysobjects t on k.parent_obj = t.id
   where  k.type = 'K' -- all keys
    AND t.type = 'U' -- all user tables
	
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
	