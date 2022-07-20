select @@servername, d.name as [Database], sum(size/128) as [Total-MB], f.filename as [Localização] from sysaltfiles f
inner join sysdatabases d on d.dbid = f.dbid
where d.name = 'Envios'
group by d.name, f.filename
