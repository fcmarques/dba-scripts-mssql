USE DBALOG
GO
DECLARE @SERVIDOR NVARCHAR(100)
		,@cmd nvarchar (max)
		,@script nvarchar (max)
		,@erro nvarchar(max)

set @cmd='SELECT  @@servername as Servidor,
		sd.name AS [Database],
        bs.type as Tipo,
        max(bs.backup_start_date) AS [UltimoBackup],
        CONVERT (smalldatetime,GETDATE()) AS Data
		FROM    master..sysdatabases sd
        LEFT OUTER JOIN msdb..backupset bs ON rtrim(bs.database_name) = rtrim(sd.name)
        LEFT OUTER JOIN msdb..backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
		WHERE   sd.dbid > 4
		GROUP BY sd.name,
        bs.type,
        bs.database_name
		ORDER BY sd.name, [UltimoBackup]'
		
DECLARE cursor_n1 CURSOR FOR
	select ltrim(srvname) from sysservers where srvname !='RSQLADM\MAPS'
		
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
					print @servidor
				END CATCH
			FETCH NEXT FROM cursor_n1 INTO @SERVIDOR
			END

CLOSE cursor_n1
DEALLOCATE cursor_n1

use dbalog
go

