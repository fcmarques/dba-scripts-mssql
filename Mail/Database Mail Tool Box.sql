/* Lista erros de envio */
select 
  err.[description] ,
  fail.*
FROM [msdb].[dbo].[sysmail_event_log] err
  inner join [msdb].dbo.sysmail_faileditems fail
    On err.mailitem_id = fail.mailitem_id
order by send_request_date desc;

/* Lista todos os emails enviados */
select * from dbo.sysmail_sentitems
WHERE recipients LIKE '%fabio%';

/* Lista todos os itens de emails */
SELECT * FROM dbo.sysmail_allitems
WHERE recipients LIKE '%fabio.marques%' 
ORDER BY 1 DESC

/* Lista todos os logs de email*/
SELECT * FROM msdb..sysmail_event_log 
order by log_id DESC;

/* Mostra estado do broker */
SELECT is_broker_enabled 
FROM sys.databases WHERE name = 'msdb';

/* Lista todos eamils enviados com respectivos logs */
SELECT items.subject,  
    items.last_mod_date  
    ,l.description FROM dbo.sysmail_sentitems as items  
INNER JOIN dbo.sysmail_event_log AS l  
    ON items.mailitem_id = l.mailitem_id  
WHERE items.recipients LIKE '%fabio%'    
    OR items.copy_recipients LIKE '%fabio%'   
    OR items.blind_copy_recipients LIKE '%fabio%';

/* Lista erros de envio */
select * from sysmail_faileditems
order by mailitem_id desc

/* Mostra fila */
EXEC sysmail_help_queue_sp @queue_type = 'Mail' ;

-- This one told me that Database Mail was started
EXEC msdb.dbo.sysmail_help_status_sp;
 
-- Here I learned that there were 5 items queued and the last times I tried sending mail
EXEC msdb.dbo.sysmail_help_queue_sp @queue_type = 'mail';

-- This confirmed none of the email was sent
SELECT * FROM msdb.dbo.sysmail_sentitems
order by 1 desc;

SELECT * FROM msdb.dbo.sysmail_unsentitems
order by 1 desc;
 
-- Is Service Broker enabled? It has to be to send mail
SELECT is_broker_enabled FROM sys.databases WHERE name = 'msdb';
 
-- I tried stopping and restarting the Database Mail exe
EXEC msdb.dbo.sysmail_stop_sp;
EXEC msdb.dbo.sysmail_start_sp;
exec msdb.dbo.sysmail_help_status_sp

/* Limpa emails por tipo ou data */
EXEC msdb.dbo.sysmail_delete_mailitems_sp @sent_status = 'unsent' --(valid values are: unsent, sent, failed, retrying).
--,@sent_before = '2019-04-01'
;
/* sp_sysmail_activate : Starts the DatabaseMail process if it isn't already running   */
EXEC sp_sysmail_activate;

/* Lista fila de email externo */
select * from ExternalMailQueue;

/* Limpa fila de email externo */
DECLARE @conversation UNIQUEIDENTIFIER 

WHILE EXISTS (SELECT 1 FROM   dbo.externalmailqueue) 
  BEGIN 
      SET @conversation = (SELECT TOP 1 conversation_handle FROM   dbo.externalmailqueue) 

      END conversation @conversation WITH cleanup 
  END 


