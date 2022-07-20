select  name, type,create_date, modify_date
from sys.objects
where modify_date >= getdate()-1 or create_date>= getdate()-1
order by type