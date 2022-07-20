--verifica o status e configuração do logshipping

SELECT secondary_database,
restore_mode,
disconnect_users,
last_restored_file
 FROM msdb.dbo.log_shipping_secondary_databases

 go

SELECT secondary_server,
secondary_database,
primary_server,
primary_database,
last_copied_file,
last_copied_date,
last_restored_file,
last_restored_date
from msdb.dbo.log_shipping_monitor_secondary

 --altera o parametro restore mode =0 norecovery =1 standby, 
 EXEC sp_change_log_shipping_secondary_database
@secondary_database = 'PLUSOFTCRM',
@restore_mode = 1,
@disconnect_users =1