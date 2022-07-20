SELECT rtrim(ltrim(s.name)) as [Database],  
rtrim(ltrim(mirroring_role_desc)) as [Servidor], 
rtrim(ltrim(mirroring_state_desc)) as [Status]
FROM 
sys.database_mirroring mr 
inner join master..sysdatabases s on mr.database_id = s.dbid 
WHERE mirroring_role_desc IN ('PRINCIPAL','MIRROR') order by 1
