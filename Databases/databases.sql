<<<<<<< HEAD
select DB_NAME(database_id) as name , sum(size)/128/1024 as Space_Used_MB
from sys.master_files
group by DB_NAME(database_id)
=======
select DB_NAME(database_id) as name , sum(size)/128/1024 as Space_Used_MB
from sys.master_files
group by DB_NAME(database_id)
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
