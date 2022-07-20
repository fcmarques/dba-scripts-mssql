select 
  err.[description] ,
  fail.*
FROM [msdb].[dbo].[sysmail_event_log] err
  inner join [msdb].dbo.sysmail_faileditems fail
    On err.mailitem_id = fail.mailitem_id