use dbalog
go
select sum(capacidade), sum(freespace)
from discmon
where data >= getdate ()-1
and servidor = 'R-CRMDB-N2'

delete from discmon where capacidade <= 10disco like 'z:\%'

restore