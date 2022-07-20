use master
go
sp_delete_log_shipping_primary_secondary @primary_database='Sicc_band_Hist',
												@secondary_server='RIACHU_FIN',
												@secondary_database='Sicc_band_Hist'
												
			\\RIACHU-FIN-N\DR_SICC\Sicc_20141113150041.trn									
												
====================================================================================================
SELECT       upper(secondary_database),upper(last_restored_file), last_restored_date
FROM        msdb.dbo.log_shipping_secondary_databases
order by 1 
go
select db_name(database_id),a.session_id,a.percent_complete, command
from sys.dm_exec_requests  as a
where command like 'restore%'

where secondary_database = 'Sicc'

==================================================================================================
SELECT  sd.name AS [Database],
		
		bs.type,
        MAX(bs.backup_finish_date)
FROM    master..sysdatabases sd
        LEFT OUTER JOIN msdb..backupset bs ON rtrim(bs.database_name) = rtrim(sd.name)
        LEFT OUTER JOIN msdb..backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
WHERE   sd.name = 'autcom'
 and bmf.physical_device_name like '%AUTCOM_20150910001704%'
--AND bs.type='I'
GROUP BY sd.name, bs.type

SELECT  @@servername, bs.backup_start_date, bs.backup_finish_date,bmf.physical_device_name, bs.type,bs.backup_set_uuid
FROM    master..sysdatabases sd
        LEFT OUTER JOIN msdb..backupset bs ON rtrim(bs.database_name) = rtrim(sd.name)
        LEFT OUTER JOIN msdb..backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
WHERE   sd.name = 'sicc'
AND bs.type='D'
order by bs.backup_finish_date desc

and bmf.physical_device_name like '%Sicc_20141113150041%'

and bs.backup_finish_date > '2014-09-01 04:00:33.000'
order by 2

\\RIACHU-FIN-N\DR_SICC\Sicc_20140901080031.trn
=====================================================================================================