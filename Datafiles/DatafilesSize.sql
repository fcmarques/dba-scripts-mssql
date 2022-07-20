<<<<<<< HEAD
select db_name(dbid), sum((size*8)/1024) as [size(MB)]
 from sysaltfiles
  where dbid > 4
 group by dbid
 order by db_name(dbid)
=======
select db_name(dbid), sum((size*8)/1024) as [size(MB)]
 from sysaltfiles
  where dbid > 4
 group by dbid
 order by db_name(dbid)
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
 