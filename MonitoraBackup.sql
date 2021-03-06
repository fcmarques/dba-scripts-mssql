USE [dbalog]
GO
/****** Object:  StoredProcedure [dbo].[monitora_backup]    Script Date: 05/01/2015 10:10:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[monitora_backup]                

as begin                

DECLARE @SERVIDOR NVARCHAR(100)                

  ,@cmd nvarchar (max)                

  ,@script nvarchar (max)                

  ,@erro nvarchar(max)                

  ,@data date = convert(date,getdate())                

    

if ((select max(date) from backups) >= getdate()-0.020)    

begin    

  select max([date]) as data from backups    

end    

else    

begin    

 delete from backups where date >= convert(date,getdate())      
 
set @cmd='SELECT  @@servername as ServerName,                

  sd.name AS [DatabaseName],                

  convert (nvarchar(20),databasepropertyex(sd.name, ''''Recovery'''')) as recovery, bs.type as BackupType, MAX(bs.backup_finish_date) as BackupFinishDate,                

  max (bs.backup_size) as backupSize,CONVERT (smalldatetime,GETDATE()) AS Date    

  FROM    master..sysdatabases sd LEFT OUTER JOIN msdb..backupset bs ON rtrim(bs.database_name) = rtrim(sd.name)                

          LEFT OUTER JOIN msdb..backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id                

  WHERE   sd.dbid > 4               

  GROUP BY sd.name, bs.type                

  having max(bs.backup_finish_date) >= GETDATE()-20                 

   --bs.backup_size                

   ORDER BY sd.name, [BackupFinishDate]'                

    

DECLARE cursor_n1 CURSOR FOR                

select ltrim(srvname) from sysservers where srvname not in ('RSQLADM\MAPS','RIACHU_CRM')                

OPEN cursor_n1                

 FETCH NEXT FROM cursor_n1 INTO @SERVIDOR                

   WHILE @@FETCH_STATUS = 0                

   BEGIN                

    BEGIN TRY                

     SET @script = 'insert into backups select * from openquery (['+@servidor+'],'''+@cmd+''')'                

     EXEC SP_EXECUTESQL @script                

    END TRY                

    BEGIN CATCH                

     SET @erro ='INSERT INTO BACKUPS ([DATABASE],[TYPE],DATA) VALUES ('''+@SERVIDOR+''',''E'','''+CONVERT(VARCHAR(10),GETDATE(),20)+''')'                

     EXEC SP_EXECUTESQL @erro                

     PRINT @SERVIDOR    

    END CATCH                

    FETCH NEXT FROM cursor_n1 INTO @SERVIDOR                

END                

CLOSE cursor_n1                

DEALLOCATE cursor_n1                

select max([date]) as data from backups                

end       

end 