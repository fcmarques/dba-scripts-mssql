IF EXISTS (
SELECT   
                        td = convert ( nvarchar(20 ),upper( rtrim(ltrim (s. name)))),       ''
                               , 'td/@bgcolor' = CASE WHEN rtrim(ltrim (mirroring_role_desc)) <> 'MIRROR' THEN '#FFFF00' END 
                ,td = convert (nvarchar( 20),rtrim (ltrim( mirroring_role_desc))),        ''
                               , 'td/@bgcolor' = CASE WHEN rtrim(ltrim (mirroring_state_desc)) not IN ( 'SYNCHRONIZED', 'SYNCHRONIZING' ) THEN '#FF0000' END
                ,td = convert (nvarchar( 20),rtrim (ltrim( mirroring_state_desc)) ),       ''
                               FROM
                                     sys.database_mirroring mr
                                           inner join
                                     master..sysdatabases s on mr.database_id = s.dbid
                               WHERE
                                    mirroring_role_desc IN ('PRINCIPAL', 'MIRROR')
                                    and rtrim(ltrim (mirroring_state_desc)) not IN ( 'SYNCHRONIZED', 'SYNCHRONIZING' ))
                                    
BEGIN 

DECLARE @tableHTML  NVARCHAR (MAX) ;
 
SET @tableHTML =
    N'<H1>Mirroring Status - MCASSAB17</H1>' +
    N'<table cellpadding=0 cellspacing=0 border=1 style="border: solid black 1px;padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font-size:11pt;">' +
    N'<tr bgcolor=#BEBEBE>' +
    N'<th>Nome Banco</th>' +
    N'<th>Regra Atual</th>' +
    N'<th>Status Espelho</th>' +
 --   N'<th>Status Witness</th>' +
    N'</tr>' +
    CAST ( (      select   
                        td = convert ( nvarchar(20 ),upper( rtrim(ltrim (s. name)))),       ''
                               , 'td/@bgcolor' = CASE WHEN rtrim(ltrim (mirroring_role_desc)) <> 'MIRROR' THEN '#FFFF00' END 
                ,td = convert (nvarchar( 20),rtrim (ltrim( mirroring_role_desc))),        ''
                               , 'td/@bgcolor' = CASE WHEN rtrim(ltrim (mirroring_state_desc)) not IN ( 'SYNCHRONIZED', 'SYNCHRONIZING' ) THEN '#FF0000' END
                ,td = convert (nvarchar( 20),rtrim (ltrim( mirroring_state_desc)) ),       ''
/*                               , 'td/@bgcolor' = CASE WHEN rtrim(ltrim (mirroring_witness_state_desc)) <> 'CONNECTED' THEN '#FF0000' END
                ,td = convert (nvarchar( 20),rtrim (ltrim( mirroring_witness_state_desc)) ),       ''
*/               
                               FROM
                                     sys.database_mirroring mr
                                           inner join
                                     master..sysdatabases s on mr.database_id = s.dbid
                               WHERE
                                    mirroring_role_desc IN ('PRINCIPAL', 'MIRROR')
                               order by s.name
              FOR XML PATH( 'tr'), TYPE
    ) AS NVARCHAR( MAX) ) +
    N'</table>' ;
 
 
       EXEC msdb. dbo.sp_send_dbmail
    @profile_name = 'DBmail',
    @recipients= 'alexandre.guimaraes@mcassab.com.br; sergio.pelosi@mcassab.com.br' ,
    @subject = 'Status diário Mirroring - MCASSAB17' ,
    @body = @tableHTML,
    @body_format = 'HTML' ;
END