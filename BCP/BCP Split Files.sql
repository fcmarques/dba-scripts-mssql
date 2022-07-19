<<<<<<< HEAD
declare @c int = 1 --file version
declare @s int = 1 --predicate begin int
declare @e int = 2000000  --predicate end int
                 
while @s <= 29999999
begin

    declare @sql varchar(8000)
    print @sql

    select @sql = 'bcp "select * from vw_extracao_mdm where CG_CLTE >= ' + convert(varchar(10),@s) + ' and  CG_CLTE <=' + convert(varchar(10),@e) + '" queryout extracao_mdm_' + convert(varchar(10),@c) + '.txt -c -t; -d Sicc -T -S RIACHU_FIN'

    --exec  master..xp_cmdshell @sql

    set @s = @e + 1
    set @e = @s + 1999999
    set @c = @c + 1

end
=======
declare @c int = 1 --file version
declare @s int = 1 --predicate begin int
declare @e int = 2000000  --predicate end int
                 
while @s <= 29999999
begin

    declare @sql varchar(8000)
    print @sql

    select @sql = 'bcp "select * from vw_extracao_mdm where CG_CLTE >= ' + convert(varchar(10),@s) + ' and  CG_CLTE <=' + convert(varchar(10),@e) + '" queryout extracao_mdm_' + convert(varchar(10),@c) + '.txt -c -t; -d Sicc -T -S RIACHU_FIN'

    --exec  master..xp_cmdshell @sql

    set @s = @e + 1
    set @e = @s + 1999999
    set @c = @c + 1

end
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
