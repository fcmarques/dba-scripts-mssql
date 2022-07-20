USE master
go

DECLARE @database varchar(30)
DECLARE @backup_file varchar(100)
DECLARE @strAlterDb varchar(500)

SET @database = 'HOSPITALAR_DARCY'
SET @backup_file = 'D:\Restore\Darcy29062006.bak'

EXEC('ALTER DATABASE ' + @database + ' SET SINGLE_USER WITH ROLLBACK IMMEDIATE')

RESTORE DATABASE @database
   FROM DISK = @backup_file
   WITH REPLACE
PRINT ''
PRINT 'ATUALIZANDO USUARIO'
PRINT ''
EXEC('ALTER DATABASE ' + @database + ' SET MULTI_USER')

EXEC('USE  ' + @database + '; EXEC sp_change_users_login auto_fix, AnflaHospitalar')

INSERT INTO ANFLA_TOOLS.DBO.BACKUP_LOG(BACK_DT, BACK_DATABASE, BACK_FILE)
VALUES(GETDATE(), @database, @backup_file)

--sp_change_users_login auto_fix, conquest

--SELECT * FROM LOGIN
--CREATE DATABASE ONCOVILLE


