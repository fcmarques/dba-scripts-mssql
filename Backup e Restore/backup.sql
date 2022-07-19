<<<<<<< HEAD
--mostra estimativa de conclusão do backup ou restore
select 
convert (varchar(50),(estimated_completion_time/3600000))+'hrs'+
convert (varchar(50), ((estimated_completion_time%3600000)/60000))+'min'+
convert (varchar(50), (((estimated_completion_time%3600000)%60000)/1000))+'sec'
as Estimated_Completion_Time, 
session_id,
status, command, db_name(database_id), percent_complete
from sys.dm_exec_requests
where command like 'RESTORE%'
--where command like 'BACKUP%'

=====================================================================================================
select * from sys.dm_exec_requests 

==========================================================================================================
use master
go

declare @caminho varchar (135),
		@dbid int,
		@banco nvarchar (50),
		@status int,
		@cmd nvarchar (100),
		@cmdbackup nvarchar(1000),
		@size bigint  

create table #dbfiles (servidor varchar(30),banco nvarchar(30),name nvarchar(50),physical_name nvarchar(250),size bigint) 

DECLARE c1 CURSOR FOR  
	select dbid,name from sysdatabases where status=4194841 or status =2576 or status =540
		OPEN c1;  
		FETCH NEXT FROM c1 INTO @dbid,@banco; 
		WHILE @@FETCH_STATUS = 0  
		BEGIN  
			
			set @caminho ='''\\prod-tng\Archive_DB_Desativadas\'+replace (@@servername,'\','.')+'.'+@banco+'.bak'''
			set @cmd ='alter database '+ @banco+' set online'
			
			exec sp_executesql @cmd		
			
			insert into #dbfiles
			select @@servername,db_name(dbid),name,filename,size*8/1024 from sysaltfiles
			where dbid=@dbid
						
			set @cmdbackup = 'BACKUP DATABASE '+@banco+' TO  DISK ='+@caminho+' WITH NOFORMAT, INIT, SKIP, NOREWIND, NOUNLOAD,   STATS = 10'
			
			exec sp_executesql @cmdbackup
			
			if (@@error = 0)
			begin
				EXEC master.dbo.sp_detach_db @dbname = @banco
			end
			else print 'Processo de backup do banco '+@banco+' falhou'
									
		FETCH NEXT FROM c1 INTO @dbid,@banco;  
		END;  

CLOSE c1;  
DEALLOCATE c1;
select * from #dbfiles
drop table #dbfiles

========================================================================
use master
go
declare @caminho varchar (135),
		@dbid int,
		@banco nvarchar (50),
		@status int,
		@cmd nvarchar (100),
		@cmdbackup nvarchar(1000),
		@size bigint  

create table #dbfiles (servidor varchar(30),banco nvarchar(30),name nvarchar(50),physical_name nvarchar(250),size bigint) 

DECLARE c1 CURSOR FOR  
	select database_id,name from sys.databases where state=6
		OPEN c1;  
		FETCH NEXT FROM c1 INTO @dbid,@banco; 
		WHILE @@FETCH_STATUS = 0  
		BEGIN  
			
			set @caminho ='''\\prod-tng\Archive_DB_Desativadas\'+replace (@@servername,'\','.')+'.'+@banco+'.bak'''
			set @cmd ='alter database '+ @banco+' set online'
			
			exec sp_executesql @cmd		
			
			insert into #dbfiles
			select @@servername,db_name(dbid),name,filename,size*8/1024 from sys.sysaltfiles
			where dbid=@dbid
						
			set @cmdbackup = 'BACKUP DATABASE '+@banco+' TO  DISK ='+@caminho+' WITH NOFORMAT, INIT, SKIP, NOREWIND, NOUNLOAD,   STATS = 10'
			
			exec sp_executesql @cmdbackup
			
			if (@@error = 0)
			begin
				EXEC master.dbo.sp_detach_db @dbname = @banco
			end
			else 
			begin
				print 'Processo de backup do banco '+@banco+' falhou'
				set @cmd ='alter database '+ @banco+' set offline'
				exec sp_executesql @cmd
			end
			
									
		FETCH NEXT FROM c1 INTO @dbid,@banco;  
		END;  

CLOSE c1;  
DEALLOCATE c1;
select * from #dbfiles
drop table #dbfiles

=====================================
SELECT  sd.name AS [Database],
		MAX(bs.backup_finish_date)
    
FROM    master..sysdatabases sd
        LEFT OUTER JOIN msdb..backupset bs ON rtrim(bs.database_name) = rtrim(sd.name)
        LEFT OUTER JOIN msdb..backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
WHERE   sd.name = 'MidwayAutorizador'
and bs.type = 'D'
group by sd.name

SELECT  sd.name AS [Database],bs.backup_set_uuid,
		bs.type,
		MAX(bs.backup_finish_date)
FROM    master..sysdatabases sd
        LEFT OUTER JOIN msdb..backupset bs ON rtrim(bs.database_name) = rtrim(sd.name)
        LEFT OUTER JOIN msdb..backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
WHERE   sd.name = 'R3P'
AND bs.type='D'
GROUP BY sd.name, bs.type,bs.backup_set_uuid

select @@servername as servidor,name, backup_start_date,
	backup_finish_date, DATEDIFF(HOUR,backup_start_date,backup_finish_date)as [TimeDuration(H)],
	convert (int,backup_size/1024/1024/1024) as [BackupSize(GB)]
 from msdb..backupset
where backup_set_uuid='63639BC7-1530-4B3F-A431-59AE1B86791F'

SELECT  bs.backup_finish_date,bmf.physical_device_name
FROM    master..sysdatabases sd
        LEFT OUTER JOIN msdb..backupset bs ON rtrim(bs.database_name) = rtrim(sd.name)
        LEFT OUTER JOIN msdb..backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
WHERE   sd.name = 'R3P'
AND bs.type='L'
and bs.backup_start_date > '2014-09-30 01:05:10.000'

select open_tran from sys.sysprocesses where spid=2672


++++++++++++++++++++
select sum(a.size)/1024/1024/1024, a.data
from 
	(select backup_size as size, convert(date,backup_finish_date,112) as data
 from msdb..backupset
 where type = 'l'
 and database_name = 'sipf'
 and datepart(year,backup_finish_date) =2015) as a
group by a.data 
order by a.data desc

===========

SELECT  sd.name AS [Database],
bs.backup_start_date,
bs.backup_finish_date,
bs.checkpoint_lsn,
bs.first_lsn,
		bs.type,
		bmf.physical_device_name		    
FROM    master..sysdatabases sd
        LEFT OUTER JOIN msdb..backupset bs ON rtrim(bs.database_name) = rtrim(sd.name)
        LEFT OUTER JOIN msdb..backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
WHERE   sd.name = 'PLUSOFTCRM'
and bs.type='l'
--and bs.backup_start_date >= '2016-06-29 01:00:41.000'
and bs.checkpoint_lsn = '483038000241794300001'
--and bs.backup_start_date >= getdate()-4
order by bs.backup_start_date


SELECT  sd.name AS [Database],
bs.backup_start_date,
bs.backup_finish_date,
bs.checkpoint_lsn,
bs.first_lsn,
		bs.type,
		'restore log plusoftcrm from disk='''+bmf.physical_device_name+''' with norecovery'		    
FROM    master..sysdatabases sd
        LEFT OUTER JOIN msdb..backupset bs ON rtrim(bs.database_name) = rtrim(sd.name)
        LEFT OUTER JOIN msdb..backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
WHERE 
bs.backup_start_date >= '2016-07-08 01:00:41.000'
--bs.checkpoint_lsn ='483267000002543100028'
--bmf.physical_device_name = 'B:\MSSQL\LOGSHIPPING\PLUSOFTCRM\PLUSOFTCRM_20160708040041.trn'
 and bs.type = 'l'
and sd.name = 'Plusoftcrm'

'B:\MSSQL\LOGSHIPPING\PLUSOFTCRM\PLUSOFTCRM_20160708040041.trn'


order by bs.backup_start_date desc


B:\MSSQL\LOGSHIPPING\PLUSOFTCRM\PLUSOFTCRM_20160630113040.trn

sp_help_log_shipping_monitor

BKDB-RIACHU_FIN-MidwayAutorizador_L_29062016_7_15_0.trn

RESTORE VERIFYONLY FROM DISK = 'M:\MSSQL\Backup\BKDB-RIACHU_FIN-MidwayAutorizador_L_29062016_7_15_0.trn' WITH LOADHISTORY

=======
--mostra estimativa de conclusão do backup ou restore
select 
convert (varchar(50),(estimated_completion_time/3600000))+'hrs'+
convert (varchar(50), ((estimated_completion_time%3600000)/60000))+'min'+
convert (varchar(50), (((estimated_completion_time%3600000)%60000)/1000))+'sec'
as Estimated_Completion_Time, 
session_id,
status, command, db_name(database_id), percent_complete
from sys.dm_exec_requests
where command like 'RESTORE%'
--where command like 'BACKUP%'

=====================================================================================================
select * from sys.dm_exec_requests 

==========================================================================================================
use master
go

declare @caminho varchar (135),
		@dbid int,
		@banco nvarchar (50),
		@status int,
		@cmd nvarchar (100),
		@cmdbackup nvarchar(1000),
		@size bigint  

create table #dbfiles (servidor varchar(30),banco nvarchar(30),name nvarchar(50),physical_name nvarchar(250),size bigint) 

DECLARE c1 CURSOR FOR  
	select dbid,name from sysdatabases where status=4194841 or status =2576 or status =540
		OPEN c1;  
		FETCH NEXT FROM c1 INTO @dbid,@banco; 
		WHILE @@FETCH_STATUS = 0  
		BEGIN  
			
			set @caminho ='''\\prod-tng\Archive_DB_Desativadas\'+replace (@@servername,'\','.')+'.'+@banco+'.bak'''
			set @cmd ='alter database '+ @banco+' set online'
			
			exec sp_executesql @cmd		
			
			insert into #dbfiles
			select @@servername,db_name(dbid),name,filename,size*8/1024 from sysaltfiles
			where dbid=@dbid
						
			set @cmdbackup = 'BACKUP DATABASE '+@banco+' TO  DISK ='+@caminho+' WITH NOFORMAT, INIT, SKIP, NOREWIND, NOUNLOAD,   STATS = 10'
			
			exec sp_executesql @cmdbackup
			
			if (@@error = 0)
			begin
				EXEC master.dbo.sp_detach_db @dbname = @banco
			end
			else print 'Processo de backup do banco '+@banco+' falhou'
									
		FETCH NEXT FROM c1 INTO @dbid,@banco;  
		END;  

CLOSE c1;  
DEALLOCATE c1;
select * from #dbfiles
drop table #dbfiles

========================================================================
use master
go
declare @caminho varchar (135),
		@dbid int,
		@banco nvarchar (50),
		@status int,
		@cmd nvarchar (100),
		@cmdbackup nvarchar(1000),
		@size bigint  

create table #dbfiles (servidor varchar(30),banco nvarchar(30),name nvarchar(50),physical_name nvarchar(250),size bigint) 

DECLARE c1 CURSOR FOR  
	select database_id,name from sys.databases where state=6
		OPEN c1;  
		FETCH NEXT FROM c1 INTO @dbid,@banco; 
		WHILE @@FETCH_STATUS = 0  
		BEGIN  
			
			set @caminho ='''\\prod-tng\Archive_DB_Desativadas\'+replace (@@servername,'\','.')+'.'+@banco+'.bak'''
			set @cmd ='alter database '+ @banco+' set online'
			
			exec sp_executesql @cmd		
			
			insert into #dbfiles
			select @@servername,db_name(dbid),name,filename,size*8/1024 from sys.sysaltfiles
			where dbid=@dbid
						
			set @cmdbackup = 'BACKUP DATABASE '+@banco+' TO  DISK ='+@caminho+' WITH NOFORMAT, INIT, SKIP, NOREWIND, NOUNLOAD,   STATS = 10'
			
			exec sp_executesql @cmdbackup
			
			if (@@error = 0)
			begin
				EXEC master.dbo.sp_detach_db @dbname = @banco
			end
			else 
			begin
				print 'Processo de backup do banco '+@banco+' falhou'
				set @cmd ='alter database '+ @banco+' set offline'
				exec sp_executesql @cmd
			end
			
									
		FETCH NEXT FROM c1 INTO @dbid,@banco;  
		END;  

CLOSE c1;  
DEALLOCATE c1;
select * from #dbfiles
drop table #dbfiles

=====================================
SELECT  sd.name AS [Database],
		MAX(bs.backup_finish_date)
    
FROM    master..sysdatabases sd
        LEFT OUTER JOIN msdb..backupset bs ON rtrim(bs.database_name) = rtrim(sd.name)
        LEFT OUTER JOIN msdb..backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
WHERE   sd.name = 'MidwayAutorizador'
and bs.type = 'D'
group by sd.name

SELECT  sd.name AS [Database],bs.backup_set_uuid,
		bs.type,
		MAX(bs.backup_finish_date)
FROM    master..sysdatabases sd
        LEFT OUTER JOIN msdb..backupset bs ON rtrim(bs.database_name) = rtrim(sd.name)
        LEFT OUTER JOIN msdb..backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
WHERE   sd.name = 'R3P'
AND bs.type='D'
GROUP BY sd.name, bs.type,bs.backup_set_uuid

select @@servername as servidor,name, backup_start_date,
	backup_finish_date, DATEDIFF(HOUR,backup_start_date,backup_finish_date)as [TimeDuration(H)],
	convert (int,backup_size/1024/1024/1024) as [BackupSize(GB)]
 from msdb..backupset
where backup_set_uuid='63639BC7-1530-4B3F-A431-59AE1B86791F'

SELECT  bs.backup_finish_date,bmf.physical_device_name
FROM    master..sysdatabases sd
        LEFT OUTER JOIN msdb..backupset bs ON rtrim(bs.database_name) = rtrim(sd.name)
        LEFT OUTER JOIN msdb..backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
WHERE   sd.name = 'R3P'
AND bs.type='L'
and bs.backup_start_date > '2014-09-30 01:05:10.000'

select open_tran from sys.sysprocesses where spid=2672


++++++++++++++++++++
select sum(a.size)/1024/1024/1024, a.data
from 
	(select backup_size as size, convert(date,backup_finish_date,112) as data
 from msdb..backupset
 where type = 'l'
 and database_name = 'sipf'
 and datepart(year,backup_finish_date) =2015) as a
group by a.data 
order by a.data desc

===========

SELECT  sd.name AS [Database],
bs.backup_start_date,
bs.backup_finish_date,
bs.checkpoint_lsn,
bs.first_lsn,
		bs.type,
		bmf.physical_device_name		    
FROM    master..sysdatabases sd
        LEFT OUTER JOIN msdb..backupset bs ON rtrim(bs.database_name) = rtrim(sd.name)
        LEFT OUTER JOIN msdb..backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
WHERE   sd.name = 'PLUSOFTCRM'
and bs.type='l'
--and bs.backup_start_date >= '2016-06-29 01:00:41.000'
and bs.checkpoint_lsn = '483038000241794300001'
--and bs.backup_start_date >= getdate()-4
order by bs.backup_start_date


SELECT  sd.name AS [Database],
bs.backup_start_date,
bs.backup_finish_date,
bs.checkpoint_lsn,
bs.first_lsn,
		bs.type,
		'restore log plusoftcrm from disk='''+bmf.physical_device_name+''' with norecovery'		    
FROM    master..sysdatabases sd
        LEFT OUTER JOIN msdb..backupset bs ON rtrim(bs.database_name) = rtrim(sd.name)
        LEFT OUTER JOIN msdb..backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
WHERE 
bs.backup_start_date >= '2016-07-08 01:00:41.000'
--bs.checkpoint_lsn ='483267000002543100028'
--bmf.physical_device_name = 'B:\MSSQL\LOGSHIPPING\PLUSOFTCRM\PLUSOFTCRM_20160708040041.trn'
 and bs.type = 'l'
and sd.name = 'Plusoftcrm'

'B:\MSSQL\LOGSHIPPING\PLUSOFTCRM\PLUSOFTCRM_20160708040041.trn'


order by bs.backup_start_date desc


B:\MSSQL\LOGSHIPPING\PLUSOFTCRM\PLUSOFTCRM_20160630113040.trn

sp_help_log_shipping_monitor

BKDB-RIACHU_FIN-MidwayAutorizador_L_29062016_7_15_0.trn

RESTORE VERIFYONLY FROM DISK = 'M:\MSSQL\Backup\BKDB-RIACHU_FIN-MidwayAutorizador_L_29062016_7_15_0.trn' WITH LOADHISTORY

>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
