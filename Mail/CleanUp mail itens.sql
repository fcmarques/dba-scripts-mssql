--A. Deleting all e-mails
--The following example deletes all e-mails in the Database Mail system.

DECLARE @GETDATE datetime  
SET @GETDATE = GETDATE();  
EXECUTE msdb.dbo.sysmail_delete_mailitems_sp @sent_before = @GETDATE;  
GO  

--B. Deleting the oldest e-mails
--The following example deletes e-mails in the Database Mail log that are older than October 9, 2005.

EXECUTE msdb.dbo.sysmail_delete_mailitems_sp   
    @sent_before = 'October 9, 2005' ;  
GO  

--C. Deleting all e-mails of a certain type
--The following example deletes all failed e-mails in the Database Mail log.

EXECUTE msdb.dbo.sysmail_delete_mailitems_sp   
    @sent_status = 'failed' ;  
GO  