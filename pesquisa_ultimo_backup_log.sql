
--Pesquisa Último Backup do Banco e Log
Select Left(Database_name,30) Name , Max(Backup_start_date) Backup_Date, type From msdb..Backupset
Where Database_name in (select name from master..sysdatabases Where name not in ('tempdb')
)
Group by DataBase_name, type
Order by 1,3,2


--Pesquisa Último Backup de Log
Select name, Backup_start_date From (
Select top 30 Left(Database_name,30) Name, Backup_start_date From msdb..Backupset
Where Database_name in (select name from master..sysdatabases Where name not in ('tempdb')
And Type = 'L'
)
Order by 2 Desc, 1
) TB
Order by 1,2
