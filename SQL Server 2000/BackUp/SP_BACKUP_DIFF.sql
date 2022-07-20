USE ANFLA_TOOLS
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'BACKUP_DIFF' AND type = 'P')
   DROP PROCEDURE BACKUP_DIFF
GO
CREATE PROCEDURE BACKUP_DIFF 
   @BASE varchar(40),
   @DIRETORIO_BACK varchar(40) = 'D:\Microsoft SQL Server\MSSQL\BACKUP\'
AS

DECLARE @ARQUIVO_BACK VARCHAR(100)
DECLARE @BACK_NOME VARCHAR(128)

SET @ARQUIVO_BACK = @DIRETORIO_BACK+@BASE+'\BACK_'+@BASE+'_'+ltrim(rtrim((str(year(getdate())))))+ltrim(rtrim((str(month(getdate())))))+ltrim(rtrim((str(DATEPART(HOUR, GETDATE())))))+ltrim(rtrim((str(month(getdate())))))+ltrim(rtrim((str(DATEPART(MINUTE, GETDATE())))))+'_DIFF.BAK'
SET @BACK_NOME = 'BACK_'+@BASE+'_'+ltrim(rtrim((str(year(getdate())))))+'_'+ltrim(rtrim((str(month(getdate())))))
--PRINT @ARQUIVO_BACK
BACKUP DATABASE @BASE
TO DISK = @ARQUIVO_BACK
WITH DIFFERENTIAL, NAME = @BACK_NOME

GO
--EXEC BACKUP_DIFF HOSPITALAR