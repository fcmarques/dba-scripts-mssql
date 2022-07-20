SELECT Rtrim( Ltrim( s.NAME ) )                     AS [Database],
       Rtrim( Ltrim( mirroring_role_desc ) )        AS [Papel],
       Rtrim( Ltrim( mirroring_partner_instance ) ) AS [ServidorDestino],
       Rtrim( Ltrim( mirroring_state_desc ) )       AS [Status]
FROM   sys.DATABASE_MIRRORING mr
       INNER JOIN master..SYSDATABASES s
               ON mr.database_id = s.dbid
WHERE  mirroring_role_desc IN ( 'PRINCIPAL', 'MIRROR' )
ORDER  BY 1 
