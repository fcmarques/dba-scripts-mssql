DECLARE @tableHTML  NVARCHAR(MAX) ;

SET @tableHTML =
    N'<H1>LogShipping Status - SRV-SQLSTB</H1>' +
    N'<table border="1">' +
    N'<tr>' +
    N'<th>Session Id</th>' +
    N'<th>Database Name</th>' +
    N'<th>Session Status</th>' +
    N'<th>Log Time</th>' + 
    N'<th>Message</th>' +
    N'</tr>' +
    CAST ( ( 	select top 10 td = convert(nvarchar(4),session_id),       '',
				td = convert(nvarchar(256),database_name),       '',
				td = convert(char(1),session_status),       '',
				td = convert(nvarchar(20),log_time),       '',
				td = convert(nvarchar(4000),message),       ''
				from msdb.dbo.log_shipping_monitor_history_detail
				where message like 'The restore %'
				and database_name is not null
				and database_name <> 'db_principal_teste'
				order by log_time desc
              FOR XML PATH('tr'), TYPE 
    ) AS NVARCHAR(MAX) ) +
    N'</table>' ;


EXEC msdb.dbo.sp_send_dbmail @recipients='tecnologia@alpes.com.br',
    @subject = 'Status diário LogShipping - SRV-SQLSTB',
    @body = @tableHTML,
    @body_format = 'HTML' ;