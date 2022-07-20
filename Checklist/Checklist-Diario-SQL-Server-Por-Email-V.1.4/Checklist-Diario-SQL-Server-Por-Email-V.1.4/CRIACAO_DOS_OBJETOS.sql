<<<<<<< HEAD
/*
	Tabela [BackupInfo] -- Informações de Backup
	Tabela [DashboardDatabase_Jobs] -- Jobs com falha
	Tabela [JobsCriticos] -- Lista Jobs críticos
	Tabela [StatusDosBancos] -- Status dos bancos
	Tabela [StatusDosDiscos] -- Espaço em disco
	Tabela [ErrorLogs] -- Errors Log SQL Server
	Tabela [RelatorioDosJobs] -- Relatorio dos Jobs
	Procedure [Proc_Atualiza_Dados] -- Atualiza Dados
	Procedure [Proc_Atualiza_Planilha] -- AtualizaPlanilha
	Procedure [EnviaErrorLogsAS2350] -- Atualiza Logs as 23:50
*/

USE [master]
GO
sp_configure 'show advanced options', 1;  
GO  
RECONFIGURE;  
GO  
sp_configure 'Ole Automation Procedures', 1;  
GO  
RECONFIGURE;  
GO
USE [master]
GO

EXEC sp_configure 'show advanced options', 1
RECONFIGURE
GO
EXEC sp_configure 'ad hoc distributed queries', 1
RECONFIGURE
GO
USE [master]
GO
 
EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0' , N'AllowInProcess' , 1
GO
EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0' , N'DynamicParameters' , 1
GO


EXEC sp_configure 'show advanced options', 1;  
GO  

RECONFIGURE;  
GO  

EXEC sp_configure 'xp_cmdshell', 1;  
GO  

RECONFIGURE;  
GO 

EXEC sp_configure 'show advanced options', '1';
RECONFIGURE
GO

EXEC sp_configure 'Database Mail XPs', 1;
RECONFIGURE
GO

USE [master]
GO
EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'NumErrorLogs', REG_DWORD, 31
GO



USE [Monitoramento]
GO
PRINT 'Verificando se existe a tabela BackupInfo'

IF OBJECT_ID('dbo.BackupInfo', 'U') IS NOT NULL 
  DROP TABLE dbo.BackupInfo
GO
/****** Object:  Table [dbo].[BackupInfo]    Script Date: 16/04/2017 22:53:06 ******/
PRINT 'Criando a tabela BackupInfo'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[BackupInfo](
	[NomeDoBanco] [varchar](50) NULL,
	[TipoDeBackup] [varchar](20) NULL,
	[CaminhoFisicoDoArquivo] [varchar](1000) NULL,
	[TamanhoDoBackup] [varchar](15) NULL,
	[TempoDoBackup] [varchar](100) NULL,
	[DataInicioDoBackup] [datetime] NULL,
	[Servidor] [varchar](50) NULL,
	[FoiNotificado] [int] NULL,
	[RecoveryModel] [varchar](15) NULL,
	[verificacao] [datetime] DEFAULT GETDATE()
) ON [PRIMARY]
GO



PRINT 'Verificando se existe a tabela DashboardDatabase_Jobs'
GO
IF OBJECT_ID('dbo.DashboardDatabase_Jobs', 'U') IS NOT NULL 
  DROP TABLE dbo.DashboardDatabase_Jobs
GO


USE [Monitoramento]
GO

/****** Object:  Table [dbo].[DashboardDatabase_Jobs]    Script Date: 16/04/2017 23:07:46 ******/
PRINT 'Criando a tabela DashboardDatabase_Jobs'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DashboardDatabase_Jobs](
	[Ano] [int] NOT NULL,
	[Mes] [int] NOT NULL,
	[Dia] [int] NOT NULL,
	[ServerName] [varchar](50) NOT NULL,
	[Nome] [varchar](255) NOT NULL,
	[Sucesso] [int] NULL,
	[Falha] [int] NULL,
	[Ticket] [varchar](255) NULL,
	[DuracaoMax] [varchar](20) NULL,
	[DuracaoMin] [varchar](20) NULL,
	[Verificacao] [datetime] NULL,
	[FoiNotificado] [int] NULL,
 CONSTRAINT [pk_DashboardDatabase_Jobs] PRIMARY KEY CLUSTERED 
(
	[Ano] ASC,
	[Mes] ASC,
	[Dia] ASC,
	[ServerName] ASC,
	[Nome] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


PRINT 'Verificando se existe a tabela JobsCriticos'
GO
IF OBJECT_ID('dbo.JobsCriticos', 'U') IS NOT NULL 
  DROP TABLE dbo.JobsCriticos
GO

USE [Monitoramento]
GO

/****** Object:  Table [dbo].[JobsCriticos]    Script Date: 16/04/2017 23:09:11 ******/
PRINT 'Criando a tabela JobsCriticos'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[JobsCriticos](
	[Nome] [varchar](255) NOT NULL,
	[Critical] [varchar](1) NULL,
 CONSTRAINT [pk_DashboardDatabase_CriticalJobs] PRIMARY KEY CLUSTERED 
(
	[Nome] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO


PRINT 'Verificando se existe a tabela StatusDosBancos'
GO
IF OBJECT_ID('dbo.StatusDosBancos', 'U') IS NOT NULL 
  DROP TABLE dbo.StatusDosBancos
GO

USE [Monitoramento]
GO

/****** Object:  Table [dbo].[StatusDosBancos]    Script Date: 16/04/2017 23:13:21 ******/
PRINT 'Criando a tabela StatusDosBancos'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[StatusDosBancos](
	[NomeDoBanco] [sysname] NOT NULL,
	[state_desc] [nvarchar](60) NULL,
	[recovery_model_desc] [nvarchar](60) NULL,
	[total_size] [decimal](18, 2) NULL,
	[data_size] [decimal](18, 2) NULL,
	[data_used_size] [decimal](18, 2) NULL,
	[log_size] [decimal](18, 2) NULL,
	[log_used_size] [decimal](18, 2) NULL,
	[verificacao] [datetime] NULL,
	[FoiNotificado] [int] NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[StatusDosBancos] ADD  DEFAULT (getdate()) FOR [verificacao]
GO


PRINT 'Verificando se existe a tabela StatusDosDiscos'
GO
IF OBJECT_ID('dbo.StatusDosDiscos', 'U') IS NOT NULL 
  DROP TABLE dbo.StatusDosDiscos
GO

USE [Monitoramento]
GO

/****** Object:  Table [dbo].[StatusDosDiscos]    Script Date: 16/04/2017 23:17:01 ******/
PRINT 'Criando a tabela StatusDosDiscos'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[StatusDosDiscos](
	[Server] [nvarchar](128) NULL,
	[DriveLetter] [char](1) NULL,
	[Label] [varchar](10) NULL,
	[FreeSpace_MB] [int] NULL,
	[UsedSpace_MB] [int] NULL,
	[TotalSpace_MB] [int] NULL,
	[Percentage_Free] [int] NULL,
	[Verificacao] [datetime] NULL,
	[FoiNotificado] [int] NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[StatusDosDiscos] ADD  DEFAULT (getdate()) FOR [Verificacao]
GO

PRINT 'Verificando se existe a tabela ErrorLogs'
GO
IF OBJECT_ID('dbo.ErrorLogs', 'U') IS NOT NULL 
  DROP TABLE dbo.ErrorLogs
GO

USE [Monitoramento]
GO

/****** Object:  Table [dbo].[ErrorLogs]    Script Date: 16/04/2017 23:23:24 ******/
PRINT 'Criando a tabela ErrorLogs'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ErrorLogs](
	[Servidor] [varchar](100) NULL,
	[Descricao] [varchar](MAX) NULL,
	[DataDoLog] [varchar](MAX) NULL,
	[Verificacao] [datetime] NOT NULL,
	[FoiNotificado] [int] NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ErrorLogs] ADD  DEFAULT (getdate()) FOR [Verificacao]
GO

PRINT 'Verificando se existe a tabela RelatorioDosJobs'
GO
IF OBJECT_ID('dbo.RelatorioDosJobs', 'U') IS NOT NULL 
  DROP TABLE dbo.RelatorioDosJobs
GO

PRINT 'Criando a tabela RelatorioDosJobs'
CREATE TABLE [dbo].[RelatorioDosJobs](
	[Ano] [int] NOT NULL,
	[Mes] [int] NOT NULL,
	[Dia] [int] NOT NULL,
	[ServerName] [varchar](50) NOT NULL,
	[Nome] [varchar](255) NOT NULL,
	[Sucesso] [int] NULL,
	[Falha] [int] NULL,
	[Ticket] [varchar](255) NULL,
	[DuracaoMax] [varchar](10) NULL,
	[DuracaoMin] [varchar](10) NULL,
	[Verificacao] [datetime] NULL,
	[FoiNotificado] [int] NULL
	)

ALTER TABLE [dbo].[RelatorioDosJobs] ADD  DEFAULT (getdate()) FOR [Verificacao]
GO


PRINT 'TABELAS CRIADAS COM SUCESSO!'
PRINT 'Criando os índices'

CREATE INDEX idx_BackupInfo_verificacao ON BackupInfo (verificacao, FoiNotificado)
CREATE INDEX idx_DashboardDatabase_Jobs_verificacao ON DashboardDatabase_Jobs (Verificacao, FoiNotificado)
CREATE INDEX idx_StatusDosBancos_verificacao ON StatusDosBancos (verificacao, FoiNotificado)
CREATE INDEX idx_StatusDosDiscos_verificacao ON StatusDosDiscos (Verificacao, FoiNotificado)
CREATE INDEX idx_ErrorLogs_verificacao ON ErrorLogs (Verificacao, FoiNotificado)
CREATE INDEX idx_datas_RelatorioDosJobs ON RelatorioDosJobs (Verificacao, FoiNotificado, Ano, Mes, Dia, ServerName, Nome)

PRINT 'INDICES CRIADOS COM SUCESSO!'
GO

PRINT 'Criando procedures'
GO

CREATE PROCEDURE EnviaErrorLogsAS2350 AS
BEGIN
-- Envia Status dos Logs
IF OBJECT_ID('tempdb..#Errors') IS NOT NULL
       DROP TABLE #Errors


DECLARE @SERVER nvarchar(600)
SET @SERVER = @@SERVERNAME -- Servidor Atual
DECLARE @sqlStatement1 varchar(600)
SET @sqlStatement1 = @SERVER + '.master.dbo.xp_readerrorlog'
CREATE TABLE #Errors (
       DataDoLog varchar(4000),
       SP_ID varchar(600),
       Descricao varchar(1000)
)
INSERT #Errors EXEC @sqlStatement1
/*Caso queira gravar os dados em uma tabela descomente o código abaixo*/
--SELECT * INTO TBL_MONITOR_SQL_ERROR_LOG FROM #Errors
--SELECT * FROM TBL_MONITOR_SQL_ERROR_LOG

INSERT INTO ErrorLogs (Servidor
, Descricao
, DataDoLog)
       SELECT
              @SERVER AS Servidor,
              RTRIM(LTRIM(Descricao)) AS Descricao,
              DataDoLog AS DataDoLog
       FROM #Errors
       WHERE ([Descricao] LIKE '%error%'
       OR [Descricao] LIKE '%fail%'
       OR [Descricao] LIKE '%Warning%'
       OR [Descricao] LIKE '%The SQL Server cannot obtain a LOCK resource at this time%'
       OR [Descricao] LIKE '%Autogrow of file%in database%cancelled or timed out after%'
       OR [Descricao] LIKE '%Consider using ALTER DATABASE to set smaller FILEGROWTH%'
       OR [Descricao] LIKE '% is full%'
       OR [Descricao] LIKE '% blocking processes%'
       OR [Descricao] LIKE '%SQL Server has encountered%IO requests taking longer%to complete%'
	   OR [Descricao] LIKE '%DBCC CHECKDB%'
       )

       AND [Descricao] NOT LIKE '%\ERRORLOG%'
       AND [Descricao] NOT LIKE '%Attempting to cycle errorlog%'
       AND [Descricao] NOT LIKE '%Errorlog has been reinitialized.%'
       AND [Descricao] NOT LIKE '%without errors%'
       AND [Descricao] NOT LIKE '%This is an informational message%'
       AND [Descricao] NOT LIKE '%WARNING:%Failed to reserve contiguous memory%'
       AND [Descricao] NOT LIKE '%The error log has been reinitialized%'
       AND [Descricao] NOT LIKE '%Setting database option ANSI_WARNINGS%'
       AND [Descricao] NOT LIKE '%Error: 15457, Severity: 0, State: 1%'
       AND [Descricao] <> 'Error: 18456, Severity: 14, State: 16.'

       ORDER BY 3 DESC
DROP TABLE #Errors

END

GO

CREATE PROCEDURE Proc_Atualiza_Dados AS
BEGIN

-- Envia Informações de Backup
INSERT INTO BackupInfo (NomeDoBanco
, TipoDeBackup
, CaminhoFisicoDoArquivo
, TamanhoDoBackup
, TempoDoBackup
, DataInicioDoBackup
, Servidor
, RecoveryModel)

       SELECT TOP 100
              s.database_name AS NomeDobanco,
              CASE s.[type]
                     WHEN 'D' THEN 'Full'
                     WHEN 'I' THEN 'Differential'
                     WHEN 'L' THEN 'Transaction Log'
              END AS TipoDeBackup,
              m.physical_device_name AS CaminhoFisicoDoArquivo,
              CAST(CAST(s.backup_size / 1000000 AS int) AS varchar(14))
              + ' ' + 'MB' AS TamanhoDoBackup,
              CAST(DATEDIFF(SECOND, s.backup_start_date, s.backup_finish_date)
              AS varchar(4))
              + ' ' + 'Segundos' AS TempoDoBackup,
              s.backup_start_date AS DataInicioDoBackup,
              s.server_name AS Servidor,
              s.recovery_model
       FROM msdb.dbo.backupset s
       INNER JOIN msdb.dbo.backupmediafamily m
              ON s.media_set_id = m.media_set_id
       ORDER BY backup_start_date DESC,
       backup_finish_date


-- Envia Status dos Bancos
IF OBJECT_ID('tempdb.dbo.#space') IS NOT NULL
       DROP TABLE #space

CREATE TABLE #space (
       database_id int PRIMARY KEY,
       data_used_size decimal(18, 2),
       log_used_size decimal(18, 2)
)

DECLARE @SQL nvarchar(max)

SELECT
       @SQL = STUFF((SELECT
              '
    USE [' + d.name + ']
    INSERT INTO #space (database_id, data_used_size, log_used_size)
    SELECT
          DB_ID()
        , SUM(CASE WHEN [type] = 0 THEN space_used END)
        , SUM(CASE WHEN [type] = 1 THEN space_used END)
    FROM (
        SELECT s.[type], space_used = SUM(FILEPROPERTY(s.name, ''SpaceUsed'') * 8. / 1024)
        FROM sys.database_files s
        GROUP BY s.[type]
    ) t;'
       FROM sys.databases d
       WHERE d.[state] = 0
       FOR xml PATH (''), TYPE)
       .value('.', 'NVARCHAR(MAX)'), 1, 2, '')

EXEC sys.sp_executesql @SQL

INSERT INTO [StatusDosBancos] (NomeDoBanco
, state_desc
, recovery_model_desc
, total_size
, data_size
, data_used_size
, log_size
, log_used_size)

       SELECT
              --  d.database_id
              d.name,
              d.state_desc,
              d.recovery_model_desc,
              t.total_size,
              t.data_size,
              s.data_used_size,
              t.log_size,
              s.log_used_size
       --, bu.full_last_date
       --, bu.full_size
       --, bu.log_last_date
       --, bu.log_size
       FROM (SELECT
              database_id,
              log_size = CAST(SUM(CASE
                     WHEN [type] = 1 THEN size
              END) * 8. / 1024 AS decimal(18, 2)),
              data_size = CAST(SUM(CASE
                     WHEN [type] = 0 THEN size
              END) * 8. / 1024 AS decimal(18, 2)),
              total_size = CAST(SUM(size) * 8. / 1024 AS decimal(18, 2))
       FROM sys.master_files
       GROUP BY database_id) t
       JOIN sys.databases d
              ON d.database_id = t.database_id
       LEFT JOIN #space s
              ON d.database_id = s.database_id
       LEFT JOIN (SELECT
              database_name,
              full_last_date = MAX(CASE
                     WHEN [type] = 'D' THEN backup_finish_date
              END),
              full_size = MAX(CASE
                     WHEN [type] = 'D' THEN backup_size
              END),
              log_last_date = MAX(CASE
                     WHEN [type] = 'L' THEN backup_finish_date
              END),
              log_size = MAX(CASE
                     WHEN [type] = 'L' THEN backup_size
              END)
       FROM (SELECT
              s.database_name,
              s.[type],
              s.backup_finish_date,
              backup_size =
              CAST(CASE
                     WHEN s.backup_size = s.compressed_backup_size THEN s.backup_size
                     ELSE s.compressed_backup_size
              END / 1048576.0 AS decimal(18, 2)),
              RowNum = ROW_NUMBER() OVER (PARTITION BY s.database_name, s.[type] ORDER BY s.backup_finish_date DESC)
       FROM msdb.dbo.backupset s
       WHERE s.[type] IN ('D', 'L')) f
       WHERE f.RowNum = 1
       GROUP BY f.database_name) bu
              ON d.name = bu.database_name
       ORDER BY t.total_size DESC


-- Envia Status dos discos
SET NOCOUNT ON
IF EXISTS (SELECT
              name
       FROM tempdb..sysobjects
       WHERE name = '##_DriveSpace')
       DROP TABLE ##_DriveSpace
IF EXISTS (SELECT
              name
       FROM tempdb..sysobjects
       WHERE name = '##_DriveInfo')
       DROP TABLE ##_DriveInfo

DECLARE @Result int,
        @objFSO int,
        @Drv int,
        @cDrive varchar(13),
        @Size varchar(50),
        @Free varchar(50),
        @Label varchar(10)

CREATE TABLE ##_DriveSpace (
       DriveLetter char(1) NOT NULL,
       FreeSpace varchar(10) NOT NULL

)

CREATE TABLE ##_DriveInfo (
       DriveLetter char(1),
       TotalSpace bigint,
       FreeSpace bigint,
       Label varchar(10)
)

INSERT INTO ##_DriveSpace
EXEC master.dbo.xp_fixeddrives


-- Iterar através de letras de unidade.
DECLARE curDriveLetters CURSOR FOR
SELECT
       DriveLetter
FROM ##_DriveSpace

DECLARE @DriveLetter char(1)
OPEN curDriveLetters

FETCH NEXT FROM curDriveLetters INTO @DriveLetter
WHILE (@@fetch_status <> -1)
BEGIN
       IF (@@fetch_status <> -2)
       BEGIN

              SET @cDrive = 'GetDrive("' + @DriveLetter + '")'

              EXEC @Result = sp_OACreate 'Scripting.FileSystemObject',
                                         @objFSO OUTPUT

              IF @Result = 0

                     EXEC @Result = sp_OAMethod @objFSO,
                                                @cDrive,
                                                @Drv OUTPUT

              IF @Result = 0

                     EXEC @Result = sp_OAGetProperty @Drv,
                                                     'TotalSize',
                                                     @Size OUTPUT

              IF @Result = 0

                     EXEC @Result = sp_OAGetProperty @Drv,
                                                     'FreeSpace',
                                                     @Free OUTPUT

              IF @Result = 0

                     EXEC @Result = sp_OAGetProperty @Drv,
                                                     'VolumeName',
                                                     @Label OUTPUT

              IF @Result <> 0

                     EXEC sp_OADestroy @Drv
              EXEC sp_OADestroy @objFSO

              SET @Size = (CONVERT(bigint, @Size) / 1048576)

              SET @Free = (CONVERT(bigint, @Free) / 1048576)

              INSERT INTO ##_DriveInfo
                     VALUES (@DriveLetter, @Size, @Free, @Label)

       END
       FETCH NEXT FROM curDriveLetters INTO @DriveLetter
END

CLOSE curDriveLetters
DEALLOCATE curDriveLetters

PRINT 'Drive information for server ' + @@SERVERNAME + '.'
PRINT ''

-- Relatório.

INSERT INTO StatusDosDiscos (Server
, DriveLetter
, Label
, FreeSpace_MB
, UsedSpace_MB
, TotalSpace_MB
, Percentage_Free)
       SELECT
              @@SERVERNAME AS Server,
              DriveLetter,
              Label,
              FreeSpace AS [FreeSpace MB],
              (TotalSpace - FreeSpace) AS [UsedSpace MB],
              TotalSpace AS [TotalSpace MB],
              ((CONVERT(numeric(9, 0), FreeSpace) / CONVERT(numeric(9, 0), TotalSpace)) * 100) AS [Percentage Free]
       FROM ##_DriveInfo
       ORDER BY [DriveLetter] ASC


DROP TABLE ##_DriveSpace
DROP TABLE ##_DriveInfo

-- Envia Status dos Jobs

INSERT INTO Monitoramento.dbo.RelatorioDosJobs (Ano, Mes, Dia, ServerName, Nome, Sucesso, Falha, DuracaoMax, DuracaoMin)
       SELECT
              YEAR(GETDATE() - 1) Ano,
              MONTH(GETDATE() - 1) Mes,
              DAY(GETDATE() - 1) Dia,
              jh.server Servidor,
              jb.name 'Nome do Job',
              (SELECT
                     COUNT(jh2.run_status)
              FROM msdb..sysjobs jb2
              JOIN msdb..sysjobhistory jh2
                     ON jb2.job_id = jh2.job_id
              WHERE jh2.run_date = CAST(CONVERT(char(8), GETDATE() - 1, 112) AS int)
              AND jh2.run_status = 1
              AND jh2.step_id = 0
              AND jb.name = jb2.name)
              Sucesso,
              (SELECT
                     COUNT(jh2.run_status)
              FROM msdb..sysjobs jb2
              JOIN msdb..sysjobhistory jh2
                     ON jb2.job_id = jh2.job_id
              WHERE jh2.run_date = CAST(CONVERT(char(8), GETDATE() - 1, 112) AS int)
              AND jh2.run_status = 0
              AND jh2.step_id = 0
              AND jb.name = jb2.name)
              Falha,
              MAX(STUFF(STUFF(REPLACE(STR(jh.run_duration, 6, 0), ' ', '0'), 3, 0, ':'), 6, 0, ':')) 'Duração Máxima',
              MIN(STUFF(STUFF(REPLACE(STR(jh.run_duration, 6, 0), ' ', '0'), 3, 0, ':'), 6, 0, ':')) 'Duração Mínima'
       FROM msdb..sysjobs jb
       JOIN msdb..sysjobhistory jh
              ON jb.job_id = jh.job_id
       WHERE jh.step_id = 0
       AND jh.run_date = CAST(CONVERT(char(8), GETDATE() - 1, 112) AS int)
       GROUP BY jb.name,
                jh.server
       ORDER BY jb.name


-- Envia Status dos Logs
IF OBJECT_ID('tempdb..#Errors') IS NOT NULL
       DROP TABLE #Errors


DECLARE @SERVER nvarchar(600)
SET @SERVER = @@SERVERNAME -- Servidor Atual
DECLARE @sqlStatement1 varchar(600)
SET @sqlStatement1 = @SERVER + '.master.dbo.xp_readerrorlog'
CREATE TABLE #Errors (
       DataDoLog varchar(4000),
       SP_ID varchar(600),
       Descricao varchar(1000)
)
INSERT #Errors EXEC @sqlStatement1
/*Caso queira gravar os dados em uma tabela descomente o código abaixo*/
--SELECT * INTO TBL_MONITOR_SQL_ERROR_LOG FROM #Errors
--SELECT * FROM TBL_MONITOR_SQL_ERROR_LOG

INSERT INTO ErrorLogs (Servidor
, Descricao
, DataDoLog)
       SELECT
              @SERVER AS Servidor,
              RTRIM(LTRIM(Descricao)) AS Descricao,
              DataDoLog AS DataDoLog
       FROM #Errors
       WHERE ([Descricao] LIKE '%error%'
       OR [Descricao] LIKE '%fail%'
       OR [Descricao] LIKE '%Warning%'
       OR [Descricao] LIKE '%The SQL Server cannot obtain a LOCK resource at this time%'
       OR [Descricao] LIKE '%Autogrow of file%in database%cancelled or timed out after%'
       OR [Descricao] LIKE '%Consider using ALTER DATABASE to set smaller FILEGROWTH%'
       OR [Descricao] LIKE '% is full%'
       OR [Descricao] LIKE '% blocking processes%'
       OR [Descricao] LIKE '%SQL Server has encountered%IO requests taking longer%to complete%'
	   OR [Descricao] LIKE '%DBCC CHECKDB%'
       )

       AND [Descricao] NOT LIKE '%\ERRORLOG%'
       AND [Descricao] NOT LIKE '%Attempting to cycle errorlog%'
       AND [Descricao] NOT LIKE '%Errorlog has been reinitialized.%'
       AND [Descricao] NOT LIKE '%without errors%'
       AND [Descricao] NOT LIKE '%This is an informational message%'
       AND [Descricao] NOT LIKE '%WARNING:%Failed to reserve contiguous memory%'
       AND [Descricao] NOT LIKE '%The error log has been reinitialized%'
       AND [Descricao] NOT LIKE '%Setting database option ANSI_WARNINGS%'
       AND [Descricao] NOT LIKE '%Error: 15457, Severity: 0, State: 1%'
       AND [Descricao] <> 'Error: 18456, Severity: 14, State: 16.'

       ORDER BY 3 DESC
DROP TABLE #Errors

END
GO

CREATE PROCEDURE Proc_Atualiza_Planilha AS
BEGIN
/*Verifica anexos*/

if exists (select * from sys.objects where name = 'checkattachment')
	drop table checkattachment 


declare @arquivoDVG varchar(255)
set @arquivoDVG = ''
select @arquivoDVG = @arquivoDVG+'C:\Monitoramento\Arquivos\DatabaseDashboard_DVG_'+convert(varchar,DATEPART(YEAR,getdate()-1))+CASE LEN(convert(varchar,DATEPART(MM,getdate()-1))) WHEN 1 THEN '0'+convert(varchar,DATEPART(MM,getdate()-1)) ELSE convert(varchar,DATEPART(MM,getdate()-1)) END+CASE LEN(convert(varchar,DATEPART(DD,getdate()-1))) WHEN 1 THEN '0'+convert(varchar,DATEPART(DD,getdate()-1)) ELSE convert(varchar,DATEPART(DD,getdate()-1)) END+'.xlsx'

create table checkattachment (FileExists bit,FileDirectory bit,ParentExists bit)--drop table checkattachment
insert into checkattachment 
exec master.dbo.xp_fileexist @arquivoDVG
--select * from checkattachment 


/* INSERIR NA PLANILHA */

EXEC xp_cmdshell 'copy /y C:\Monitoramento\DatabaseDashboard_modelo.xlsx C:\Monitoramento\Arquivos\DatabaseDashboard.xlsx'


/*DiskSpace*/
INSERT INTO OPENROWSET(
'Microsoft.ACE.OLEDB.12.0', 
'Excel 12.0;Database=C:\Monitoramento\Arquivos\DatabaseDashboard.xlsx;HDR=NO;', 
'SELECT * FROM [Disco$]')
SELECT	Server COLLATE SQL_Latin1_General_CP1_CI_AI, 
		DriveLetter COLLATE SQL_Latin1_General_CP1_CI_AI,
		Label COLLATE SQL_Latin1_General_CP1_CI_AI, 
		FreeSpace_MB, 
		UsedSpace_MB,
		TotalSpace_MB,
		Percentage_Free,
		Verificacao
FROM Monitoramento.dbo.StatusDosDiscos
WHERE FoiNotificado IS NULL


/*BACKUP*/
declare @BACKUP varchar(max) = 
'INSERT INTO OPENROWSET(
''Microsoft.ACE.OLEDB.12.0'', 
''Excel 12.0;Database=C:\Monitoramento\Arquivos\DatabaseDashboard.xlsx;HDR=NO'', 
''SELECT * FROM [Backup$]'')
SELECT 
	NomeDoBanco COLLATE SQL_Latin1_General_CP1_CI_AI, 
	TipoDeBackup COLLATE SQL_Latin1_General_CP1_CI_AI, 
	SUBSTRING(CaminhoFisicoDoArquivo, 1, 250) COLLATE SQL_Latin1_General_CP1_CI_AI, 
	TamanhoDoBackup COLLATE SQL_Latin1_General_CP1_CI_AI, 
	TempoDoBackup COLLATE SQL_Latin1_General_CP1_CI_AI,
	DataInicioDoBackup,
	Servidor COLLATE SQL_Latin1_General_CP1_CI_AI, 
	RecoveryModel COLLATE SQL_Latin1_General_CP1_CI_AI
FROM Monitoramento.dbo.BackupInfo
WHERE FoiNotificado IS NULL' +char(13) +char(10)


exec(@BACKUP)


/*JOBS*/
declare @JOBS varchar(max) = 
'INSERT INTO OPENROWSET(
''Microsoft.ACE.OLEDB.12.0'',
''Excel 12.0;Database=C:\Monitoramento\Arquivos\DatabaseDashboard.xlsx;HDR=NO'',
''SELECT * FROM [Jobs$]'')
SELECT	Ano, 
		Mes, 
		Dia, 
		ServerName COLLATE SQL_Latin1_General_CP1_CI_AI, 
		RelatorioDosJobs.Nome COLLATE SQL_Latin1_General_CP1_CI_AI, 
		Sucesso, 
		Falha, 
		DuracaoMax COLLATE SQL_Latin1_General_CP1_CI_AI, 
		DuracaoMin COLLATE SQL_Latin1_General_CP1_CI_AI
FROM Monitoramento.dbo.RelatorioDosJobs
LEFT JOIN [JobsCriticos]
       ON RelatorioDosJobs.Nome = [JobsCriticos].Nome
WHERE Ano = YEAR(GETDATE() - 1)
AND Mes = MONTH(GETDATE() - 1)
AND Dia = DAY(GETDATE() - 1)
--AND ServerName IN ('')
AND FoiNotificado IS NULL '+char(13)+char(10)
select @JOBS = @JOBS


exec(@JOBS)

/*Errorlogs*/

declare @LOGS varchar(max) = 
'INSERT INTO OPENROWSET(
''Microsoft.ACE.OLEDB.12.0'',
''Excel 12.0;Database=C:\Monitoramento\Arquivos\DatabaseDashboard.xlsx;HDR=NO'',
''SELECT * FROM [Logs$]'')
SELECT	Servidor COLLATE SQL_Latin1_General_CP1_CI_AI, 
		SUBSTRING(Descricao, 1, 250 ) COLLATE SQL_Latin1_General_CP1_CI_AI, 
		DataDoLog COLLATE SQL_Latin1_General_CP1_CI_AI
FROM Monitoramento.dbo.ErrorLogs
WHERE FoiNotificado IS NULL'+char(13)+char(10)
select @LOGS = @LOGS

exec(@LOGS)

END

GO
PRINT'PROCEDURES CRIADAS COM SUCESSO'
PRINT 'CRIANDO JOBS'
GO

USE [msdb]
GO

/****** Object:  Job [JB_BD_EXECUCAODOSJOBSDIARIOS]    Script Date: 24/04/2017 11:56:17 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 24/04/2017 11:56:17 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'JB_BD_EXECUCAODOSJOBSDIARIOS', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Envia um dashboard diário para os supervisores de sistemas com a relação de execução (sucesso/falha) dos jobs no dia anterior.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Atualiza Dados]    Script Date: 24/04/2017 11:56:18 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Atualiza Dados', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec Proc_Atualiza_Dados', 
		@database_name=N'Monitoramento', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Monta Planilha]    Script Date: 24/04/2017 11:56:18 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Monta Planilha', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'Exec Proc_Atualiza_Planilha', 
		@database_name=N'Monitoramento', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Envia relatório Jobs]    Script Date: 24/04/2017 11:56:19 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Envia relatório Jobs', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'use Monitoramento
GO
IF OBJECT_ID(''tempdb..#Dashboard'') IS NOT NULL
       DROP TABLE #Dashboard
GO
SELECT
       ServerName,
       RelatorioDosJobs.Nome,
       Sucesso,
       Falha,
       CASE [JobsCriticos].[Critical]
              WHEN ''S'' THEN ''ALTA''
              ELSE ''''
       END AS [Criticidade] INTO #Dashboard
FROM RelatorioDosJobs
LEFT JOIN [JobsCriticos]
       ON RelatorioDosJobs.Nome = [JobsCriticos].Nome
WHERE Ano = YEAR(GETDATE() - 1)
AND Mes = MONTH(GETDATE() - 1)
AND Dia = DAY(GETDATE() - 1)
--AND ServerName IN ('''')
AND FoiNotificado IS NULL
ORDER BY Falha DESC, [JobsCriticos].[Critical] DESC

/*---------------*/

-- >> Header

DECLARE @header VARCHAR(MAX)
SET @header = ''<table border=0 bordercolor=#000000 cellpadding=7 cellspacing=0 style="width: 100%;" border = "1">'' +
''<tr>'' +
''<td><a href="https://dbasqlserverbr.com.br/"> <img src="https://dbasqlserverbr.com.br/img/database.png" alt="Database" height="100" width="100"></a></td>'' +
''<td><font face=verdana size=4 color=#000000> <center> <p style="font-family:Verdana,sans-serif; font-size: 23px;">Bom dia DBA! Segue Abaixo seu Checklist Diário</p></center></font></td>'' +
''</tr>''

SET @header = @header + ''</table>'' + ''<br /> <br />''

DECLARE @tabela VARCHAR(MAX)
-- Cabeçalho 
SET @tabela = ''<table border=1 bordercolor=#000000 cellpadding=7 cellspacing=0 style="width:100%">'' + 
''<tr bgcolor=#3366ff>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Servidor</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Job</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Sucesso</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Falha</b></font></center></td>'' +
''<td><center><font face=verdana size=2 color=#ffffff><b>Criticidade</b></font></center></td>'' + 
''</tr>''

SELECT @tabela = @tabela + 
-- Corpo do e-mail
''<tr>'' + 
''<td bgcolor='' + CASE WHEN Q.Falha > 0 THEN ''#ff4d4d'' WHEN Q.Falha = 0 THEN ''#00B050'' END + ''><font face=verdana size=2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font></td>'' +
''<td><font face=verdana size=2 color='' + CASE WHEN Q.Falha > 0 THEN ''#ff4d4d'' WHEN Q.Falha = 0 THEN ''#000000'' END + ''>'' + Q.ServerName + ''</font></td>'' + 
''<td><font face=verdana size=2 color='' + CASE WHEN Q.Falha > 0 THEN ''#ff4d4d'' WHEN Q.Falha = 0 THEN ''#000000'' END + ''>'' + Q.Nome + ''</font></td>'' + 
''<td><font face=verdana size=2 color='' + CASE WHEN Q.Falha > 0 THEN ''#ff4d4d'' WHEN Q.Falha = 0 THEN ''#000000'' END + ''>'' + CONVERT(VARCHAR, Q.Sucesso) + ''</font></td>'' +
''<td><font face=verdana size=2 color='' + CASE WHEN Q.Falha > 0 THEN ''#ff4d4d'' WHEN Q.Falha = 0 THEN ''#000000'' END + ''>'' + CONVERT(VARCHAR, Q.Falha) + ''</font></td>'' +
''<td><font face=verdana size=2 color='' + CASE WHEN Q.Falha > 0 THEN ''#ff4d4d'' WHEN Q.Falha = 0 THEN ''#000000'' END + ''>'' + Q.Criticidade + ''</font></td>'' + 
''</tr>'' 

FROM 
                (
                SELECT 
                ServerName, 
				Nome, 
				Sucesso, 
				Falha,
				ISNULL(Criticidade,'''') as [Criticidade]
				FROM #Dashboard
				) Q
				ORDER BY Q.Falha DESC

SET @tabela = @tabela + ''</table>''

-- Montando backups

IF OBJECT_ID(''tempdb..#DashboardBackup'') IS NOT NULL
       DROP TABLE #DashboardBackup
SELECT 
NomeDoBanco
,TipoDeBackup
,TamanhoDoBackup
,TempoDoBackup
,DataInicioDoBackup
,Servidor
,RecoveryModel
INTO #DashboardBackup
 FROM BackupInfo WHERE FoiNotificado IS NULL

DECLARE @tabela2 VARCHAR(MAX)
-- Cabeçalho 
SET @tabela2 = ''<table border=1 bordercolor=#000000 cellpadding=7 cellspacing=0 style="width:100%">'' + 
''<tr bgcolor=#3366ff>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Nome Do Banco</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Tipo De Backup</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Tamanho Do Backup</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Tempo do Backup</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Data Inicio do Backup</b></font></center></td>'' +
''<td><center><font face=verdana size=2 color=#ffffff><b>Servidor</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Recovery Model</b></font></center></td>'' + 
''</tr>''

SELECT @tabela2 = @tabela2 + 
-- Corpo do e-mail
''<tr>'' + 
''<td bgcolor=#ffffff>''+'' <font face=verdana size=2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font></td>'' +
''<td><font face=verdana size=2 color= #000000>'' + B.NomeDoBanco + ''</font></td>'' + 
''<td><font face=verdana size=2 color= #000000>'' + B.TipoDeBackup + ''</font></td>'' + 
''<td><font face=verdana size=2 color= #000000>'' + B.TamanhoDoBackup + ''</font></td>'' + 
''<td><font face=verdana size=2 color= #000000>'' + B.TempoDoBackup + ''</font></td>'' + 
''<td><font face=verdana size=2 color= #000000>'' + CONVERT(VARCHAR, B.DataInicioDoBackup, 13) + ''</font></td>'' + 
''<td><font face=verdana size=2 color= #000000>'' + B.Servidor + ''</font></td>'' + 
''<td><font face=verdana size=2 color= #000000>'' + B.RecoveryModel + ''</font></td>'' + 
''</tr>'' 

FROM 
                (
                 SELECT 
				 NomeDoBanco
				,TipoDeBackup
				,TamanhoDoBackup
				,TempoDoBackup
				,DataInicioDoBackup
				,Servidor
				,RecoveryModel
				FROM #DashboardBackup
				) B

SET @tabela2 = @tabela2 + ''</table>''

-- ////// Montando Status do banco ///////

IF OBJECT_ID(''tempdb..#DashboardStatusDB'') IS NOT NULL
       DROP TABLE #DashboardStatusDB
		SELECT 
			NomeDoBanco
			,state_desc
			,recovery_model_desc
			,total_size
			,data_size
			,data_used_size
			,log_size
			,log_used_size
		INTO #DashboardStatusDB
 FROM StatusDosBancos WHERE FoiNotificado IS NULL

DECLARE @tabela3 VARCHAR(MAX)
-- Cabeçalho 
SET @tabela3 = ''<table border=1 bordercolor=#000000 cellpadding=7 cellspacing=0 style="width:100%">'' + 
''<tr bgcolor=#3366ff>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Nome Do Banco</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Status</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Recovery Model</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Tamanho Total MB</b></font></center></td>'' +
''<td><center><font face=verdana size=2 color=#ffffff><b>Dados MB</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Dados Usados MB</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Log MB</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Log Usado MB</b></font></center></td>'' + 
''</tr>''

SELECT @tabela3 = @tabela3 + 
-- Corpo do e-mail
''<tr>'' + 
''<td bgcolor='' + CASE WHEN C.state_desc <> ''ONLINE'' THEN ''#ff4d4d'' WHEN C.state_desc = ''ONLINE'' THEN ''#00B050'' END + ''><font face=verdana size=2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font></td>'' +
''<td><font face=verdana size=2 color='' + CASE WHEN C.state_desc <> ''ONLINE'' THEN ''#ff4d4d'' WHEN C.state_desc = ''ONLINE'' THEN ''#000000'' END + ''>'' + C.NomeDoBanco + ''</font></td>'' + 
''<td><font face=verdana size=2 color='' + CASE WHEN C.state_desc <> ''ONLINE'' THEN ''#ff4d4d'' WHEN C.state_desc = ''ONLINE'' THEN ''#000000'' END + ''>'' + C.state_desc + ''</font></td>'' + 
''<td><font face=verdana size=2 color='' + CASE WHEN C.state_desc <> ''ONLINE'' THEN ''#ff4d4d'' WHEN C.state_desc = ''ONLINE'' THEN ''#000000'' END + ''>'' + C.recovery_model_desc + ''</font></td>'' + 
''<td><font face=verdana size=2 color='' + CASE WHEN C.state_desc <> ''ONLINE'' THEN ''#ff4d4d'' WHEN C.state_desc = ''ONLINE'' THEN ''#000000'' END + ''>'' + CONVERT(VARCHAR, C.total_size) + ''</font></td>'' +
''<td><font face=verdana size=2 color='' + CASE WHEN C.state_desc <> ''ONLINE'' THEN ''#ff4d4d'' WHEN C.state_desc = ''ONLINE'' THEN ''#000000'' END + ''>'' + CONVERT(VARCHAR, C.data_size) + ''</font></td>'' +
''<td><font face=verdana size=2 color='' + CASE WHEN C.state_desc <> ''ONLINE'' THEN ''#ff4d4d'' WHEN C.state_desc = ''ONLINE'' THEN ''#000000'' END + ''>'' + CONVERT(VARCHAR, C.data_used_size) + ''</font></td>'' +
''<td><font face=verdana size=2 color='' + CASE WHEN C.state_desc <> ''ONLINE'' THEN ''#ff4d4d'' WHEN C.state_desc = ''ONLINE'' THEN ''#000000'' END + ''>'' + CONVERT(VARCHAR, C.log_size) + ''</font></td>'' +
''<td><font face=verdana size=2 color='' + CASE WHEN C.state_desc <> ''ONLINE'' THEN ''#ff4d4d'' WHEN C.state_desc = ''ONLINE'' THEN ''#000000'' END + ''>'' + CONVERT(VARCHAR, C.log_used_size) + ''</font></td>'' +
''</tr>'' 

FROM 
                (
                 SELECT 
					 NomeDoBanco
					,state_desc
					,recovery_model_desc
					,ISNULL (total_size, 0) AS total_size
					,ISNULL (data_size, 0) AS data_size
					,ISNULL (data_used_size, 0) AS data_used_size
					,ISNULL (log_size, 0) AS log_size
					,ISNULL (log_used_size, 0) AS log_used_size
				FROM #DashboardStatusDB
				) C

SET @tabela3 = @tabela3 + ''</table>''


-- ////// Monitoramento de Disco ///////

IF OBJECT_ID(''tempdb..#DashboardStatusDisco'') IS NOT NULL
       DROP TABLE #DashboardStatusDisco
		SELECT 
			Server
			,DriveLetter
			,Label
			,FreeSpace_MB
			,UsedSpace_MB
			,TotalSpace_MB
			,Percentage_Free
		INTO #DashboardStatusDisco
 FROM StatusDosDiscos WHERE FoiNotificado IS NULL

DECLARE @tabela4 VARCHAR(MAX)
-- Cabeçalho 
SET @tabela4 = ''<table border=1 bordercolor=#000000 cellpadding=7 cellspacing=0 style="width:100%">'' + 
''<tr bgcolor=#3366ff>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Servidor</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Drive</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Label</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Espaço Livre MB</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Espaço Usado MB</b></font></center></td>'' +
''<td><center><font face=verdana size=2 color=#ffffff><b>Total MB</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Procentagem Livre</b></font></center></td>'' + 
''</tr>''

SELECT @tabela4 = @tabela4 + 
-- Corpo do e-mail
''<tr>'' + 
''<td bgcolor='' + CASE WHEN D.Percentage_Free <= 10 THEN ''#ff4d4d'' WHEN D.Percentage_Free BETWEEN 11 AND 20 THEN ''#ffff33'' WHEN D.Percentage_Free >= 21 THEN ''#00B050'' END + ''><font face=verdana size=2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font></td>'' +
''<td><font face=verdana size=2 color='' + CASE WHEN D.Percentage_Free <= 25 THEN ''#000000'' WHEN D.Percentage_Free >= 25 THEN ''#000000'' END + ''>'' + D.Server + ''</font></td>'' + 
''<td><font face=verdana size=2 color='' + CASE WHEN D.Percentage_Free <= 25 THEN ''#000000'' WHEN D.Percentage_Free >= 25 THEN ''#000000'' END + ''>'' + D.DriveLetter + ''</font></td>'' + 
''<td><font face=verdana size=2 color='' + CASE WHEN D.Percentage_Free <= 25 THEN ''#000000'' WHEN D.Percentage_Free >= 25 THEN ''#000000'' END + ''>'' + D.Label + ''</font></td>'' + 
''<td><font face=verdana size=2 color='' + CASE WHEN D.Percentage_Free <= 25 THEN ''#000000'' WHEN D.Percentage_Free >= 25 THEN ''#000000'' END + ''>'' + CONVERT(VARCHAR, D.FreeSpace_MB) + ''</font></td>'' +
''<td><font face=verdana size=2 color='' + CASE WHEN D.Percentage_Free <= 25 THEN ''#000000'' WHEN D.Percentage_Free >= 25 THEN ''#000000'' END + ''>'' + CONVERT(VARCHAR, D.UsedSpace_MB) + ''</font></td>'' +
''<td><font face=verdana size=2 color='' + CASE WHEN D.Percentage_Free <= 25 THEN ''#000000'' WHEN D.Percentage_Free >= 25 THEN ''#000000'' END + ''>'' + CONVERT(VARCHAR, D.TotalSpace_MB) + ''</font></td>'' +
''<td><font face=verdana size=2 color='' + CASE WHEN D.Percentage_Free <= 25 THEN ''#000000'' WHEN D.Percentage_Free >= 25 THEN ''#000000'' END + ''>'' + CONVERT(VARCHAR, D.Percentage_Free) + ''</font></td>'' +
''</tr>'' 

FROM 
                (
                 SELECT 
					 Server
					,DriveLetter
					,Label
					,FreeSpace_MB
					,UsedSpace_MB
					,TotalSpace_MB
					,Percentage_Free
				FROM #DashboardStatusDisco
				) D

SET @tabela4 = @tabela4 + ''</table>''

-- ////// Logs Files ///////

IF OBJECT_ID(''tempdb..#StatusLogFile'') IS NOT NULL
       DROP TABLE #StatusLogFile
		SELECT 
			Servidor
			,Descricao
			,DataDoLog
		INTO #StatusLogFile
 FROM ErrorLogs WHERE FoiNotificado IS NULL

DECLARE @tabela5 VARCHAR(MAX)
-- Cabeçalho 
SET @tabela5 = ''<table border=1 bordercolor=#000000 cellpadding=7 cellspacing=0 style="width:100%">'' + 
''<tr bgcolor=#3366ff>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Servidor</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Descrição</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Data Do Log</b></font></center></td>'' + 
''</tr>''

SELECT @tabela5 = @tabela5 + 
-- Corpo do e-mail
''<tr>'' + 
''<td bgcolor=#3366ff><font face=verdana size=2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font></td>'' +
''<td><font face=verdana size=2 color=#000000>'' + E.Servidor + ''</font></td>'' + 
''<td><font face=verdana size=2 color=#000000>'' + E.Descricao + ''</font></td>'' + 
''<td><font face=verdana size=2 color=#000000>'' + E.DataDoLog + ''</font></td>'' + 
''</tr>'' 

FROM 
                (
                SELECT 
                Servidor
				,Descricao
				,DataDoLog
				FROM #StatusLogFile
				) E

SET @tabela5 = @tabela5 + ''</table>''

/*
Envio de e-mail
*/

DECLARE @corpo VARCHAR(MAX)
DECLARE @corpo2 VARCHAR(MAX)
DECLARE @corpo3 VARCHAR(MAX)
DECLARE @corpo4 VARCHAR(MAX)
DECLARE @corpo5 VARCHAR(MAX)
DECLARE @assunto VARCHAR(255) = ''Checklist Diário do Ambiente '' + @@SERVERNAME + '' ['' + CONVERT(VARCHAR, GETDATE()-1, 103) + '']''

SET @corpo = '''' + 
''<font size=2 face="verdana">'' + 
''<hr noshade size=2><br>'' + CHAR(13) + CHAR(10) + 
''<b><center>Execução dos Jobs</center></b><br>'' + CHAR(13) + CHAR(10) +
''<hr noshade size=2><br>'' + CHAR(13) + CHAR(10) 

SET @corpo2 = '''' + 
''<font size=2 face="verdana">'' + 
''<hr noshade size=2><br>'' + CHAR(13) + CHAR(10) + 
''<b><center>Execução dos Backups</center></b><br>'' + CHAR(13) + CHAR(10) +
''<hr noshade size=2><br>'' + CHAR(13) + CHAR(10) 

SET @corpo3 = '''' + 
''<font size=2 face="verdana">'' + 
''<hr noshade size=2><br>'' + CHAR(13) + CHAR(10) + 
''<b><center>Status Dos Bancos SQL Server</center></b><br>'' + CHAR(13) + CHAR(10) +
''<hr noshade size=2><br>'' + CHAR(13) + CHAR(10) 

SET @corpo4 = '''' + 
''<font size=2 face="verdana">'' + 
''<hr noshade size=2><br>'' + CHAR(13) + CHAR(10) + 
''<b><center>Status Dos Discos</center></b><br>'' + CHAR(13) + CHAR(10) +
''<hr noshade size=2><br>'' + CHAR(13) + CHAR(10) 

SET @corpo5 = '''' + 
''<font size=2 face="verdana">'' + 
''<hr noshade size=2><br>'' + CHAR(13) + CHAR(10) + 
''<b><center>Logs Do Servidor</center></b><br>'' + CHAR(13) + CHAR(10) +
''<hr noshade size=2><br>'' + CHAR(13) + CHAR(10) 

SET @corpo = @corpo + @tabela + CHAR(13) + CHAR(10)
SET @corpo2 = @corpo2 + @tabela2 + CHAR(13) + CHAR(10)
SET @corpo3 = @corpo3 + @tabela3 + CHAR(13) + CHAR(10)
SET @corpo4 = @corpo4 + @tabela4 + CHAR(13) + CHAR(10)
SET @corpo5 = @corpo5 + @tabela5 + CHAR(13) + CHAR(10)

SET @corpo = @header + @corpo + '''' + @corpo2 + @corpo3 + @corpo4 + @corpo5 + 
''<br><br>'' + CHAR(13) + CHAR(10) +
''<hr />'' +
''<h3>Seu Servidor está Ligado há '' + CONVERT(VARCHAR(5),(SELECT DATEDIFF(day,(SELECT sqlserver_start_time FROM sys.dm_os_sys_info),GETDATE()))) + '' Dias </h3>''
+
''<hr />''
+
''<br><br>'' + CHAR(13) + CHAR(10) +
''<b>Checklist Gerado em: </b>'' + CONVERT(VARCHAR, GETDATE(), 103) + '' às '' + CONVERT(VARCHAR, GETDATE(), 108) + 
''</font>''


/*Anexa Excel*/
		
		/*Renomeia arquivos temporários*/

declare @command varchar(max)
declare @nomearquivoDVB varchar(255)
declare @nomearquivoDVG varchar(255)
set @command = ''''
set @nomearquivoDVB = ''''
set @nomearquivoDVG = ''''
select @nomearquivoDVB = @nomearquivoDVB+''DatabaseDashboard''+convert(varchar,DATEPART(YEAR,getdate()-1))+CASE LEN(convert(varchar,DATEPART(MM,getdate()-1))) WHEN 1 THEN ''0''+convert(varchar,DATEPART(MM,getdate()-1)) ELSE convert(varchar,DATEPART(MM,getdate()-1)) END+CASE LEN(convert(varchar,DATEPART(DD,getdate()-1))) WHEN 1 THEN ''0''+convert(varchar,DATEPART(DD,getdate()-1)) ELSE convert(varchar,DATEPART(DD,getdate()-1)) END+''.xlsx''
select @nomearquivoDVG = @nomearquivoDVG+''DatabaseDashboard''+convert(varchar,DATEPART(YEAR,getdate()-1))+CASE LEN(convert(varchar,DATEPART(MM,getdate()-1))) WHEN 1 THEN ''0''+convert(varchar,DATEPART(MM,getdate()-1)) ELSE convert(varchar,DATEPART(MM,getdate()-1)) END+CASE LEN(convert(varchar,DATEPART(DD,getdate()-1))) WHEN 1 THEN ''0''+convert(varchar,DATEPART(DD,getdate()-1)) ELSE convert(varchar,DATEPART(DD,getdate()-1)) END+''.xlsx''
select @command = @command+''EXEC xp_cmdshell ''''rename C:\Monitoramento\Arquivos\DatabaseDashboard.xlsx ''+@nomearquivoDVB+''''''''

EXEC(@command)

       declare @caminhoarquivo varchar(8000)
       set @caminhoarquivo = ''''
       
       if exists (select 1 from checkattachment where [FileExists] = 1)
             set @caminhoarquivo = ''C:\Monitoramento\Arquivos\''+@nomearquivoDVB+'';''+''C:\Monitoramento\Arquivos\''+@nomearquivoDVG+''''
       else
             set @caminhoarquivo = ''C:\Monitoramento\Arquivos\''+@nomearquivoDVB+''''



            EXEC msdb..sp_send_dbmail

            @profile_name = '''', 	
            @recipients = '''',
            --@copy_recipients = '''',
            @subject = @assunto,
            @body_format = ''HTML'',
			@file_attachments = @caminhoarquivo,
            @body = @corpo

/*
Exclui arquivo temporário XLS
*/

UPDATE RelatorioDosJobs SET FoiNotificado = 1 WHERE FoiNotificado IS NULL
UPDATE BackupInfo SET FoiNotificado = 1 WHERE FoiNotificado IS NULL
UPDATE StatusDosBancos SET FoiNotificado = 1 WHERE FoiNotificado IS NULL
UPDATE StatusDosDiscos SET FoiNotificado = 1 WHERE FoiNotificado IS NULL
UPDATE ErrorLogs SET FoiNotificado = 1 WHERE FoiNotificado IS NULL


declare @delete varchar(8000)
set @delete = ''''
set @delete = @delete+''del /q C:\Monitoramento\Arquivos\'' + @nomearquivoDVB

EXEC xp_cmdshell @delete
GO

EXEC xp_cmdshell ''copy /y C:\Monitoramento\DatabaseDashboard_modelo.xlsx C:\Monitoramento\Arquivos\DatabaseDashboard.xlsx''', 
		@database_name=N'Monitoramento', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Agenda', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20140408, 
		@active_end_date=99991231, 
		@active_start_time=73000, 
		@active_end_time=235959, 
		@schedule_uid=N'e4239bb2-f010-48c4-9ac5-0e283c2b8757'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'testa_execucao', 
		@enabled=0, 
		@freq_type=8, 
		@freq_interval=16, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20170420, 
		@active_end_date=99991231, 
		@active_start_time=143300, 
		@active_end_time=235959, 
		@schedule_uid=N'ee41b0d2-5a0d-4bca-a2ba-30dca8ab0f4d'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO




USE [msdb]
GO

/****** Object:  Job [Job_CriaArquivoDeLog]    Script Date: 17/04/2017 17:49:31 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 17/04/2017 17:49:32 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Job_CriaArquivoDeLog', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Passo1]    Script Date: 17/04/2017 17:49:32 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Passo1', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'sp_cycle_errorlog', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Agendamento', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20170125, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'40b51436-bb8a-4c3e-b04f-ce85fcf6ad47'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

PRINT 'JOBS CRIADOS COM SUCESSO'
GO

USE [msdb]
GO

/****** Object:  Job [DB_DB_EnviaErrorLogsAS2350]    Script Date: 19/04/2017 16:50:19 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 19/04/2017 16:50:19 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DB_DB_EnviaErrorLogsAS2350', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Atualiza ErrrorLog do SQL Server as 23:50 antes de criar um novo arquivo de ErrorLog no SQL Server.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EnviaErrorLogsAS2350]    Script Date: 19/04/2017 16:50:19 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EnviaErrorLogsAS2350', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'Exec EnviaErrorLogsAS2350', 
		@database_name=N'Monitoramento', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Agendamento', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20170419, 
		@active_end_date=99991231, 
		@active_start_time=235000, 
		@active_end_time=235959, 
		@schedule_uid=N'6aec5f24-7302-42bd-b90c-2c6fd50591f8'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

=======
/*
	Tabela [BackupInfo] -- Informações de Backup
	Tabela [DashboardDatabase_Jobs] -- Jobs com falha
	Tabela [JobsCriticos] -- Lista Jobs críticos
	Tabela [StatusDosBancos] -- Status dos bancos
	Tabela [StatusDosDiscos] -- Espaço em disco
	Tabela [ErrorLogs] -- Errors Log SQL Server
	Tabela [RelatorioDosJobs] -- Relatorio dos Jobs
	Procedure [Proc_Atualiza_Dados] -- Atualiza Dados
	Procedure [Proc_Atualiza_Planilha] -- AtualizaPlanilha
	Procedure [EnviaErrorLogsAS2350] -- Atualiza Logs as 23:50
*/

USE [master]
GO
sp_configure 'show advanced options', 1;  
GO  
RECONFIGURE;  
GO  
sp_configure 'Ole Automation Procedures', 1;  
GO  
RECONFIGURE;  
GO
USE [master]
GO

EXEC sp_configure 'show advanced options', 1
RECONFIGURE
GO
EXEC sp_configure 'ad hoc distributed queries', 1
RECONFIGURE
GO
USE [master]
GO
 
EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0' , N'AllowInProcess' , 1
GO
EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0' , N'DynamicParameters' , 1
GO


EXEC sp_configure 'show advanced options', 1;  
GO  

RECONFIGURE;  
GO  

EXEC sp_configure 'xp_cmdshell', 1;  
GO  

RECONFIGURE;  
GO 

EXEC sp_configure 'show advanced options', '1';
RECONFIGURE
GO

EXEC sp_configure 'Database Mail XPs', 1;
RECONFIGURE
GO

USE [master]
GO
EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'NumErrorLogs', REG_DWORD, 31
GO



USE [Monitoramento]
GO
PRINT 'Verificando se existe a tabela BackupInfo'

IF OBJECT_ID('dbo.BackupInfo', 'U') IS NOT NULL 
  DROP TABLE dbo.BackupInfo
GO
/****** Object:  Table [dbo].[BackupInfo]    Script Date: 16/04/2017 22:53:06 ******/
PRINT 'Criando a tabela BackupInfo'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[BackupInfo](
	[NomeDoBanco] [varchar](50) NULL,
	[TipoDeBackup] [varchar](20) NULL,
	[CaminhoFisicoDoArquivo] [varchar](1000) NULL,
	[TamanhoDoBackup] [varchar](15) NULL,
	[TempoDoBackup] [varchar](100) NULL,
	[DataInicioDoBackup] [datetime] NULL,
	[Servidor] [varchar](50) NULL,
	[FoiNotificado] [int] NULL,
	[RecoveryModel] [varchar](15) NULL,
	[verificacao] [datetime] DEFAULT GETDATE()
) ON [PRIMARY]
GO



PRINT 'Verificando se existe a tabela DashboardDatabase_Jobs'
GO
IF OBJECT_ID('dbo.DashboardDatabase_Jobs', 'U') IS NOT NULL 
  DROP TABLE dbo.DashboardDatabase_Jobs
GO


USE [Monitoramento]
GO

/****** Object:  Table [dbo].[DashboardDatabase_Jobs]    Script Date: 16/04/2017 23:07:46 ******/
PRINT 'Criando a tabela DashboardDatabase_Jobs'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DashboardDatabase_Jobs](
	[Ano] [int] NOT NULL,
	[Mes] [int] NOT NULL,
	[Dia] [int] NOT NULL,
	[ServerName] [varchar](50) NOT NULL,
	[Nome] [varchar](255) NOT NULL,
	[Sucesso] [int] NULL,
	[Falha] [int] NULL,
	[Ticket] [varchar](255) NULL,
	[DuracaoMax] [varchar](20) NULL,
	[DuracaoMin] [varchar](20) NULL,
	[Verificacao] [datetime] NULL,
	[FoiNotificado] [int] NULL,
 CONSTRAINT [pk_DashboardDatabase_Jobs] PRIMARY KEY CLUSTERED 
(
	[Ano] ASC,
	[Mes] ASC,
	[Dia] ASC,
	[ServerName] ASC,
	[Nome] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


PRINT 'Verificando se existe a tabela JobsCriticos'
GO
IF OBJECT_ID('dbo.JobsCriticos', 'U') IS NOT NULL 
  DROP TABLE dbo.JobsCriticos
GO

USE [Monitoramento]
GO

/****** Object:  Table [dbo].[JobsCriticos]    Script Date: 16/04/2017 23:09:11 ******/
PRINT 'Criando a tabela JobsCriticos'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[JobsCriticos](
	[Nome] [varchar](255) NOT NULL,
	[Critical] [varchar](1) NULL,
 CONSTRAINT [pk_DashboardDatabase_CriticalJobs] PRIMARY KEY CLUSTERED 
(
	[Nome] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO


PRINT 'Verificando se existe a tabela StatusDosBancos'
GO
IF OBJECT_ID('dbo.StatusDosBancos', 'U') IS NOT NULL 
  DROP TABLE dbo.StatusDosBancos
GO

USE [Monitoramento]
GO

/****** Object:  Table [dbo].[StatusDosBancos]    Script Date: 16/04/2017 23:13:21 ******/
PRINT 'Criando a tabela StatusDosBancos'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[StatusDosBancos](
	[NomeDoBanco] [sysname] NOT NULL,
	[state_desc] [nvarchar](60) NULL,
	[recovery_model_desc] [nvarchar](60) NULL,
	[total_size] [decimal](18, 2) NULL,
	[data_size] [decimal](18, 2) NULL,
	[data_used_size] [decimal](18, 2) NULL,
	[log_size] [decimal](18, 2) NULL,
	[log_used_size] [decimal](18, 2) NULL,
	[verificacao] [datetime] NULL,
	[FoiNotificado] [int] NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[StatusDosBancos] ADD  DEFAULT (getdate()) FOR [verificacao]
GO


PRINT 'Verificando se existe a tabela StatusDosDiscos'
GO
IF OBJECT_ID('dbo.StatusDosDiscos', 'U') IS NOT NULL 
  DROP TABLE dbo.StatusDosDiscos
GO

USE [Monitoramento]
GO

/****** Object:  Table [dbo].[StatusDosDiscos]    Script Date: 16/04/2017 23:17:01 ******/
PRINT 'Criando a tabela StatusDosDiscos'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[StatusDosDiscos](
	[Server] [nvarchar](128) NULL,
	[DriveLetter] [char](1) NULL,
	[Label] [varchar](10) NULL,
	[FreeSpace_MB] [int] NULL,
	[UsedSpace_MB] [int] NULL,
	[TotalSpace_MB] [int] NULL,
	[Percentage_Free] [int] NULL,
	[Verificacao] [datetime] NULL,
	[FoiNotificado] [int] NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[StatusDosDiscos] ADD  DEFAULT (getdate()) FOR [Verificacao]
GO

PRINT 'Verificando se existe a tabela ErrorLogs'
GO
IF OBJECT_ID('dbo.ErrorLogs', 'U') IS NOT NULL 
  DROP TABLE dbo.ErrorLogs
GO

USE [Monitoramento]
GO

/****** Object:  Table [dbo].[ErrorLogs]    Script Date: 16/04/2017 23:23:24 ******/
PRINT 'Criando a tabela ErrorLogs'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ErrorLogs](
	[Servidor] [varchar](100) NULL,
	[Descricao] [varchar](MAX) NULL,
	[DataDoLog] [varchar](MAX) NULL,
	[Verificacao] [datetime] NOT NULL,
	[FoiNotificado] [int] NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ErrorLogs] ADD  DEFAULT (getdate()) FOR [Verificacao]
GO

PRINT 'Verificando se existe a tabela RelatorioDosJobs'
GO
IF OBJECT_ID('dbo.RelatorioDosJobs', 'U') IS NOT NULL 
  DROP TABLE dbo.RelatorioDosJobs
GO

PRINT 'Criando a tabela RelatorioDosJobs'
CREATE TABLE [dbo].[RelatorioDosJobs](
	[Ano] [int] NOT NULL,
	[Mes] [int] NOT NULL,
	[Dia] [int] NOT NULL,
	[ServerName] [varchar](50) NOT NULL,
	[Nome] [varchar](255) NOT NULL,
	[Sucesso] [int] NULL,
	[Falha] [int] NULL,
	[Ticket] [varchar](255) NULL,
	[DuracaoMax] [varchar](10) NULL,
	[DuracaoMin] [varchar](10) NULL,
	[Verificacao] [datetime] NULL,
	[FoiNotificado] [int] NULL
	)

ALTER TABLE [dbo].[RelatorioDosJobs] ADD  DEFAULT (getdate()) FOR [Verificacao]
GO


PRINT 'TABELAS CRIADAS COM SUCESSO!'
PRINT 'Criando os índices'

CREATE INDEX idx_BackupInfo_verificacao ON BackupInfo (verificacao, FoiNotificado)
CREATE INDEX idx_DashboardDatabase_Jobs_verificacao ON DashboardDatabase_Jobs (Verificacao, FoiNotificado)
CREATE INDEX idx_StatusDosBancos_verificacao ON StatusDosBancos (verificacao, FoiNotificado)
CREATE INDEX idx_StatusDosDiscos_verificacao ON StatusDosDiscos (Verificacao, FoiNotificado)
CREATE INDEX idx_ErrorLogs_verificacao ON ErrorLogs (Verificacao, FoiNotificado)
CREATE INDEX idx_datas_RelatorioDosJobs ON RelatorioDosJobs (Verificacao, FoiNotificado, Ano, Mes, Dia, ServerName, Nome)

PRINT 'INDICES CRIADOS COM SUCESSO!'
GO

PRINT 'Criando procedures'
GO

CREATE PROCEDURE EnviaErrorLogsAS2350 AS
BEGIN
-- Envia Status dos Logs
IF OBJECT_ID('tempdb..#Errors') IS NOT NULL
       DROP TABLE #Errors


DECLARE @SERVER nvarchar(600)
SET @SERVER = @@SERVERNAME -- Servidor Atual
DECLARE @sqlStatement1 varchar(600)
SET @sqlStatement1 = @SERVER + '.master.dbo.xp_readerrorlog'
CREATE TABLE #Errors (
       DataDoLog varchar(4000),
       SP_ID varchar(600),
       Descricao varchar(1000)
)
INSERT #Errors EXEC @sqlStatement1
/*Caso queira gravar os dados em uma tabela descomente o código abaixo*/
--SELECT * INTO TBL_MONITOR_SQL_ERROR_LOG FROM #Errors
--SELECT * FROM TBL_MONITOR_SQL_ERROR_LOG

INSERT INTO ErrorLogs (Servidor
, Descricao
, DataDoLog)
       SELECT
              @SERVER AS Servidor,
              RTRIM(LTRIM(Descricao)) AS Descricao,
              DataDoLog AS DataDoLog
       FROM #Errors
       WHERE ([Descricao] LIKE '%error%'
       OR [Descricao] LIKE '%fail%'
       OR [Descricao] LIKE '%Warning%'
       OR [Descricao] LIKE '%The SQL Server cannot obtain a LOCK resource at this time%'
       OR [Descricao] LIKE '%Autogrow of file%in database%cancelled or timed out after%'
       OR [Descricao] LIKE '%Consider using ALTER DATABASE to set smaller FILEGROWTH%'
       OR [Descricao] LIKE '% is full%'
       OR [Descricao] LIKE '% blocking processes%'
       OR [Descricao] LIKE '%SQL Server has encountered%IO requests taking longer%to complete%'
	   OR [Descricao] LIKE '%DBCC CHECKDB%'
       )

       AND [Descricao] NOT LIKE '%\ERRORLOG%'
       AND [Descricao] NOT LIKE '%Attempting to cycle errorlog%'
       AND [Descricao] NOT LIKE '%Errorlog has been reinitialized.%'
       AND [Descricao] NOT LIKE '%without errors%'
       AND [Descricao] NOT LIKE '%This is an informational message%'
       AND [Descricao] NOT LIKE '%WARNING:%Failed to reserve contiguous memory%'
       AND [Descricao] NOT LIKE '%The error log has been reinitialized%'
       AND [Descricao] NOT LIKE '%Setting database option ANSI_WARNINGS%'
       AND [Descricao] NOT LIKE '%Error: 15457, Severity: 0, State: 1%'
       AND [Descricao] <> 'Error: 18456, Severity: 14, State: 16.'

       ORDER BY 3 DESC
DROP TABLE #Errors

END

GO

CREATE PROCEDURE Proc_Atualiza_Dados AS
BEGIN

-- Envia Informações de Backup
INSERT INTO BackupInfo (NomeDoBanco
, TipoDeBackup
, CaminhoFisicoDoArquivo
, TamanhoDoBackup
, TempoDoBackup
, DataInicioDoBackup
, Servidor
, RecoveryModel)

       SELECT TOP 100
              s.database_name AS NomeDobanco,
              CASE s.[type]
                     WHEN 'D' THEN 'Full'
                     WHEN 'I' THEN 'Differential'
                     WHEN 'L' THEN 'Transaction Log'
              END AS TipoDeBackup,
              m.physical_device_name AS CaminhoFisicoDoArquivo,
              CAST(CAST(s.backup_size / 1000000 AS int) AS varchar(14))
              + ' ' + 'MB' AS TamanhoDoBackup,
              CAST(DATEDIFF(SECOND, s.backup_start_date, s.backup_finish_date)
              AS varchar(4))
              + ' ' + 'Segundos' AS TempoDoBackup,
              s.backup_start_date AS DataInicioDoBackup,
              s.server_name AS Servidor,
              s.recovery_model
       FROM msdb.dbo.backupset s
       INNER JOIN msdb.dbo.backupmediafamily m
              ON s.media_set_id = m.media_set_id
       ORDER BY backup_start_date DESC,
       backup_finish_date


-- Envia Status dos Bancos
IF OBJECT_ID('tempdb.dbo.#space') IS NOT NULL
       DROP TABLE #space

CREATE TABLE #space (
       database_id int PRIMARY KEY,
       data_used_size decimal(18, 2),
       log_used_size decimal(18, 2)
)

DECLARE @SQL nvarchar(max)

SELECT
       @SQL = STUFF((SELECT
              '
    USE [' + d.name + ']
    INSERT INTO #space (database_id, data_used_size, log_used_size)
    SELECT
          DB_ID()
        , SUM(CASE WHEN [type] = 0 THEN space_used END)
        , SUM(CASE WHEN [type] = 1 THEN space_used END)
    FROM (
        SELECT s.[type], space_used = SUM(FILEPROPERTY(s.name, ''SpaceUsed'') * 8. / 1024)
        FROM sys.database_files s
        GROUP BY s.[type]
    ) t;'
       FROM sys.databases d
       WHERE d.[state] = 0
       FOR xml PATH (''), TYPE)
       .value('.', 'NVARCHAR(MAX)'), 1, 2, '')

EXEC sys.sp_executesql @SQL

INSERT INTO [StatusDosBancos] (NomeDoBanco
, state_desc
, recovery_model_desc
, total_size
, data_size
, data_used_size
, log_size
, log_used_size)

       SELECT
              --  d.database_id
              d.name,
              d.state_desc,
              d.recovery_model_desc,
              t.total_size,
              t.data_size,
              s.data_used_size,
              t.log_size,
              s.log_used_size
       --, bu.full_last_date
       --, bu.full_size
       --, bu.log_last_date
       --, bu.log_size
       FROM (SELECT
              database_id,
              log_size = CAST(SUM(CASE
                     WHEN [type] = 1 THEN size
              END) * 8. / 1024 AS decimal(18, 2)),
              data_size = CAST(SUM(CASE
                     WHEN [type] = 0 THEN size
              END) * 8. / 1024 AS decimal(18, 2)),
              total_size = CAST(SUM(size) * 8. / 1024 AS decimal(18, 2))
       FROM sys.master_files
       GROUP BY database_id) t
       JOIN sys.databases d
              ON d.database_id = t.database_id
       LEFT JOIN #space s
              ON d.database_id = s.database_id
       LEFT JOIN (SELECT
              database_name,
              full_last_date = MAX(CASE
                     WHEN [type] = 'D' THEN backup_finish_date
              END),
              full_size = MAX(CASE
                     WHEN [type] = 'D' THEN backup_size
              END),
              log_last_date = MAX(CASE
                     WHEN [type] = 'L' THEN backup_finish_date
              END),
              log_size = MAX(CASE
                     WHEN [type] = 'L' THEN backup_size
              END)
       FROM (SELECT
              s.database_name,
              s.[type],
              s.backup_finish_date,
              backup_size =
              CAST(CASE
                     WHEN s.backup_size = s.compressed_backup_size THEN s.backup_size
                     ELSE s.compressed_backup_size
              END / 1048576.0 AS decimal(18, 2)),
              RowNum = ROW_NUMBER() OVER (PARTITION BY s.database_name, s.[type] ORDER BY s.backup_finish_date DESC)
       FROM msdb.dbo.backupset s
       WHERE s.[type] IN ('D', 'L')) f
       WHERE f.RowNum = 1
       GROUP BY f.database_name) bu
              ON d.name = bu.database_name
       ORDER BY t.total_size DESC


-- Envia Status dos discos
SET NOCOUNT ON
IF EXISTS (SELECT
              name
       FROM tempdb..sysobjects
       WHERE name = '##_DriveSpace')
       DROP TABLE ##_DriveSpace
IF EXISTS (SELECT
              name
       FROM tempdb..sysobjects
       WHERE name = '##_DriveInfo')
       DROP TABLE ##_DriveInfo

DECLARE @Result int,
        @objFSO int,
        @Drv int,
        @cDrive varchar(13),
        @Size varchar(50),
        @Free varchar(50),
        @Label varchar(10)

CREATE TABLE ##_DriveSpace (
       DriveLetter char(1) NOT NULL,
       FreeSpace varchar(10) NOT NULL

)

CREATE TABLE ##_DriveInfo (
       DriveLetter char(1),
       TotalSpace bigint,
       FreeSpace bigint,
       Label varchar(10)
)

INSERT INTO ##_DriveSpace
EXEC master.dbo.xp_fixeddrives


-- Iterar através de letras de unidade.
DECLARE curDriveLetters CURSOR FOR
SELECT
       DriveLetter
FROM ##_DriveSpace

DECLARE @DriveLetter char(1)
OPEN curDriveLetters

FETCH NEXT FROM curDriveLetters INTO @DriveLetter
WHILE (@@fetch_status <> -1)
BEGIN
       IF (@@fetch_status <> -2)
       BEGIN

              SET @cDrive = 'GetDrive("' + @DriveLetter + '")'

              EXEC @Result = sp_OACreate 'Scripting.FileSystemObject',
                                         @objFSO OUTPUT

              IF @Result = 0

                     EXEC @Result = sp_OAMethod @objFSO,
                                                @cDrive,
                                                @Drv OUTPUT

              IF @Result = 0

                     EXEC @Result = sp_OAGetProperty @Drv,
                                                     'TotalSize',
                                                     @Size OUTPUT

              IF @Result = 0

                     EXEC @Result = sp_OAGetProperty @Drv,
                                                     'FreeSpace',
                                                     @Free OUTPUT

              IF @Result = 0

                     EXEC @Result = sp_OAGetProperty @Drv,
                                                     'VolumeName',
                                                     @Label OUTPUT

              IF @Result <> 0

                     EXEC sp_OADestroy @Drv
              EXEC sp_OADestroy @objFSO

              SET @Size = (CONVERT(bigint, @Size) / 1048576)

              SET @Free = (CONVERT(bigint, @Free) / 1048576)

              INSERT INTO ##_DriveInfo
                     VALUES (@DriveLetter, @Size, @Free, @Label)

       END
       FETCH NEXT FROM curDriveLetters INTO @DriveLetter
END

CLOSE curDriveLetters
DEALLOCATE curDriveLetters

PRINT 'Drive information for server ' + @@SERVERNAME + '.'
PRINT ''

-- Relatório.

INSERT INTO StatusDosDiscos (Server
, DriveLetter
, Label
, FreeSpace_MB
, UsedSpace_MB
, TotalSpace_MB
, Percentage_Free)
       SELECT
              @@SERVERNAME AS Server,
              DriveLetter,
              Label,
              FreeSpace AS [FreeSpace MB],
              (TotalSpace - FreeSpace) AS [UsedSpace MB],
              TotalSpace AS [TotalSpace MB],
              ((CONVERT(numeric(9, 0), FreeSpace) / CONVERT(numeric(9, 0), TotalSpace)) * 100) AS [Percentage Free]
       FROM ##_DriveInfo
       ORDER BY [DriveLetter] ASC


DROP TABLE ##_DriveSpace
DROP TABLE ##_DriveInfo

-- Envia Status dos Jobs

INSERT INTO Monitoramento.dbo.RelatorioDosJobs (Ano, Mes, Dia, ServerName, Nome, Sucesso, Falha, DuracaoMax, DuracaoMin)
       SELECT
              YEAR(GETDATE() - 1) Ano,
              MONTH(GETDATE() - 1) Mes,
              DAY(GETDATE() - 1) Dia,
              jh.server Servidor,
              jb.name 'Nome do Job',
              (SELECT
                     COUNT(jh2.run_status)
              FROM msdb..sysjobs jb2
              JOIN msdb..sysjobhistory jh2
                     ON jb2.job_id = jh2.job_id
              WHERE jh2.run_date = CAST(CONVERT(char(8), GETDATE() - 1, 112) AS int)
              AND jh2.run_status = 1
              AND jh2.step_id = 0
              AND jb.name = jb2.name)
              Sucesso,
              (SELECT
                     COUNT(jh2.run_status)
              FROM msdb..sysjobs jb2
              JOIN msdb..sysjobhistory jh2
                     ON jb2.job_id = jh2.job_id
              WHERE jh2.run_date = CAST(CONVERT(char(8), GETDATE() - 1, 112) AS int)
              AND jh2.run_status = 0
              AND jh2.step_id = 0
              AND jb.name = jb2.name)
              Falha,
              MAX(STUFF(STUFF(REPLACE(STR(jh.run_duration, 6, 0), ' ', '0'), 3, 0, ':'), 6, 0, ':')) 'Duração Máxima',
              MIN(STUFF(STUFF(REPLACE(STR(jh.run_duration, 6, 0), ' ', '0'), 3, 0, ':'), 6, 0, ':')) 'Duração Mínima'
       FROM msdb..sysjobs jb
       JOIN msdb..sysjobhistory jh
              ON jb.job_id = jh.job_id
       WHERE jh.step_id = 0
       AND jh.run_date = CAST(CONVERT(char(8), GETDATE() - 1, 112) AS int)
       GROUP BY jb.name,
                jh.server
       ORDER BY jb.name


-- Envia Status dos Logs
IF OBJECT_ID('tempdb..#Errors') IS NOT NULL
       DROP TABLE #Errors


DECLARE @SERVER nvarchar(600)
SET @SERVER = @@SERVERNAME -- Servidor Atual
DECLARE @sqlStatement1 varchar(600)
SET @sqlStatement1 = @SERVER + '.master.dbo.xp_readerrorlog'
CREATE TABLE #Errors (
       DataDoLog varchar(4000),
       SP_ID varchar(600),
       Descricao varchar(1000)
)
INSERT #Errors EXEC @sqlStatement1
/*Caso queira gravar os dados em uma tabela descomente o código abaixo*/
--SELECT * INTO TBL_MONITOR_SQL_ERROR_LOG FROM #Errors
--SELECT * FROM TBL_MONITOR_SQL_ERROR_LOG

INSERT INTO ErrorLogs (Servidor
, Descricao
, DataDoLog)
       SELECT
              @SERVER AS Servidor,
              RTRIM(LTRIM(Descricao)) AS Descricao,
              DataDoLog AS DataDoLog
       FROM #Errors
       WHERE ([Descricao] LIKE '%error%'
       OR [Descricao] LIKE '%fail%'
       OR [Descricao] LIKE '%Warning%'
       OR [Descricao] LIKE '%The SQL Server cannot obtain a LOCK resource at this time%'
       OR [Descricao] LIKE '%Autogrow of file%in database%cancelled or timed out after%'
       OR [Descricao] LIKE '%Consider using ALTER DATABASE to set smaller FILEGROWTH%'
       OR [Descricao] LIKE '% is full%'
       OR [Descricao] LIKE '% blocking processes%'
       OR [Descricao] LIKE '%SQL Server has encountered%IO requests taking longer%to complete%'
	   OR [Descricao] LIKE '%DBCC CHECKDB%'
       )

       AND [Descricao] NOT LIKE '%\ERRORLOG%'
       AND [Descricao] NOT LIKE '%Attempting to cycle errorlog%'
       AND [Descricao] NOT LIKE '%Errorlog has been reinitialized.%'
       AND [Descricao] NOT LIKE '%without errors%'
       AND [Descricao] NOT LIKE '%This is an informational message%'
       AND [Descricao] NOT LIKE '%WARNING:%Failed to reserve contiguous memory%'
       AND [Descricao] NOT LIKE '%The error log has been reinitialized%'
       AND [Descricao] NOT LIKE '%Setting database option ANSI_WARNINGS%'
       AND [Descricao] NOT LIKE '%Error: 15457, Severity: 0, State: 1%'
       AND [Descricao] <> 'Error: 18456, Severity: 14, State: 16.'

       ORDER BY 3 DESC
DROP TABLE #Errors

END
GO

CREATE PROCEDURE Proc_Atualiza_Planilha AS
BEGIN
/*Verifica anexos*/

if exists (select * from sys.objects where name = 'checkattachment')
	drop table checkattachment 


declare @arquivoDVG varchar(255)
set @arquivoDVG = ''
select @arquivoDVG = @arquivoDVG+'C:\Monitoramento\Arquivos\DatabaseDashboard_DVG_'+convert(varchar,DATEPART(YEAR,getdate()-1))+CASE LEN(convert(varchar,DATEPART(MM,getdate()-1))) WHEN 1 THEN '0'+convert(varchar,DATEPART(MM,getdate()-1)) ELSE convert(varchar,DATEPART(MM,getdate()-1)) END+CASE LEN(convert(varchar,DATEPART(DD,getdate()-1))) WHEN 1 THEN '0'+convert(varchar,DATEPART(DD,getdate()-1)) ELSE convert(varchar,DATEPART(DD,getdate()-1)) END+'.xlsx'

create table checkattachment (FileExists bit,FileDirectory bit,ParentExists bit)--drop table checkattachment
insert into checkattachment 
exec master.dbo.xp_fileexist @arquivoDVG
--select * from checkattachment 


/* INSERIR NA PLANILHA */

EXEC xp_cmdshell 'copy /y C:\Monitoramento\DatabaseDashboard_modelo.xlsx C:\Monitoramento\Arquivos\DatabaseDashboard.xlsx'


/*DiskSpace*/
INSERT INTO OPENROWSET(
'Microsoft.ACE.OLEDB.12.0', 
'Excel 12.0;Database=C:\Monitoramento\Arquivos\DatabaseDashboard.xlsx;HDR=NO;', 
'SELECT * FROM [Disco$]')
SELECT	Server COLLATE SQL_Latin1_General_CP1_CI_AI, 
		DriveLetter COLLATE SQL_Latin1_General_CP1_CI_AI,
		Label COLLATE SQL_Latin1_General_CP1_CI_AI, 
		FreeSpace_MB, 
		UsedSpace_MB,
		TotalSpace_MB,
		Percentage_Free,
		Verificacao
FROM Monitoramento.dbo.StatusDosDiscos
WHERE FoiNotificado IS NULL


/*BACKUP*/
declare @BACKUP varchar(max) = 
'INSERT INTO OPENROWSET(
''Microsoft.ACE.OLEDB.12.0'', 
''Excel 12.0;Database=C:\Monitoramento\Arquivos\DatabaseDashboard.xlsx;HDR=NO'', 
''SELECT * FROM [Backup$]'')
SELECT 
	NomeDoBanco COLLATE SQL_Latin1_General_CP1_CI_AI, 
	TipoDeBackup COLLATE SQL_Latin1_General_CP1_CI_AI, 
	SUBSTRING(CaminhoFisicoDoArquivo, 1, 250) COLLATE SQL_Latin1_General_CP1_CI_AI, 
	TamanhoDoBackup COLLATE SQL_Latin1_General_CP1_CI_AI, 
	TempoDoBackup COLLATE SQL_Latin1_General_CP1_CI_AI,
	DataInicioDoBackup,
	Servidor COLLATE SQL_Latin1_General_CP1_CI_AI, 
	RecoveryModel COLLATE SQL_Latin1_General_CP1_CI_AI
FROM Monitoramento.dbo.BackupInfo
WHERE FoiNotificado IS NULL' +char(13) +char(10)


exec(@BACKUP)


/*JOBS*/
declare @JOBS varchar(max) = 
'INSERT INTO OPENROWSET(
''Microsoft.ACE.OLEDB.12.0'',
''Excel 12.0;Database=C:\Monitoramento\Arquivos\DatabaseDashboard.xlsx;HDR=NO'',
''SELECT * FROM [Jobs$]'')
SELECT	Ano, 
		Mes, 
		Dia, 
		ServerName COLLATE SQL_Latin1_General_CP1_CI_AI, 
		RelatorioDosJobs.Nome COLLATE SQL_Latin1_General_CP1_CI_AI, 
		Sucesso, 
		Falha, 
		DuracaoMax COLLATE SQL_Latin1_General_CP1_CI_AI, 
		DuracaoMin COLLATE SQL_Latin1_General_CP1_CI_AI
FROM Monitoramento.dbo.RelatorioDosJobs
LEFT JOIN [JobsCriticos]
       ON RelatorioDosJobs.Nome = [JobsCriticos].Nome
WHERE Ano = YEAR(GETDATE() - 1)
AND Mes = MONTH(GETDATE() - 1)
AND Dia = DAY(GETDATE() - 1)
--AND ServerName IN ('')
AND FoiNotificado IS NULL '+char(13)+char(10)
select @JOBS = @JOBS


exec(@JOBS)

/*Errorlogs*/

declare @LOGS varchar(max) = 
'INSERT INTO OPENROWSET(
''Microsoft.ACE.OLEDB.12.0'',
''Excel 12.0;Database=C:\Monitoramento\Arquivos\DatabaseDashboard.xlsx;HDR=NO'',
''SELECT * FROM [Logs$]'')
SELECT	Servidor COLLATE SQL_Latin1_General_CP1_CI_AI, 
		SUBSTRING(Descricao, 1, 250 ) COLLATE SQL_Latin1_General_CP1_CI_AI, 
		DataDoLog COLLATE SQL_Latin1_General_CP1_CI_AI
FROM Monitoramento.dbo.ErrorLogs
WHERE FoiNotificado IS NULL'+char(13)+char(10)
select @LOGS = @LOGS

exec(@LOGS)

END

GO
PRINT'PROCEDURES CRIADAS COM SUCESSO'
PRINT 'CRIANDO JOBS'
GO

USE [msdb]
GO

/****** Object:  Job [JB_BD_EXECUCAODOSJOBSDIARIOS]    Script Date: 24/04/2017 11:56:17 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 24/04/2017 11:56:17 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'JB_BD_EXECUCAODOSJOBSDIARIOS', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Envia um dashboard diário para os supervisores de sistemas com a relação de execução (sucesso/falha) dos jobs no dia anterior.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Atualiza Dados]    Script Date: 24/04/2017 11:56:18 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Atualiza Dados', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec Proc_Atualiza_Dados', 
		@database_name=N'Monitoramento', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Monta Planilha]    Script Date: 24/04/2017 11:56:18 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Monta Planilha', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'Exec Proc_Atualiza_Planilha', 
		@database_name=N'Monitoramento', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Envia relatório Jobs]    Script Date: 24/04/2017 11:56:19 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Envia relatório Jobs', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'use Monitoramento
GO
IF OBJECT_ID(''tempdb..#Dashboard'') IS NOT NULL
       DROP TABLE #Dashboard
GO
SELECT
       ServerName,
       RelatorioDosJobs.Nome,
       Sucesso,
       Falha,
       CASE [JobsCriticos].[Critical]
              WHEN ''S'' THEN ''ALTA''
              ELSE ''''
       END AS [Criticidade] INTO #Dashboard
FROM RelatorioDosJobs
LEFT JOIN [JobsCriticos]
       ON RelatorioDosJobs.Nome = [JobsCriticos].Nome
WHERE Ano = YEAR(GETDATE() - 1)
AND Mes = MONTH(GETDATE() - 1)
AND Dia = DAY(GETDATE() - 1)
--AND ServerName IN ('''')
AND FoiNotificado IS NULL
ORDER BY Falha DESC, [JobsCriticos].[Critical] DESC

/*---------------*/

-- >> Header

DECLARE @header VARCHAR(MAX)
SET @header = ''<table border=0 bordercolor=#000000 cellpadding=7 cellspacing=0 style="width: 100%;" border = "1">'' +
''<tr>'' +
''<td><a href="https://dbasqlserverbr.com.br/"> <img src="https://dbasqlserverbr.com.br/img/database.png" alt="Database" height="100" width="100"></a></td>'' +
''<td><font face=verdana size=4 color=#000000> <center> <p style="font-family:Verdana,sans-serif; font-size: 23px;">Bom dia DBA! Segue Abaixo seu Checklist Diário</p></center></font></td>'' +
''</tr>''

SET @header = @header + ''</table>'' + ''<br /> <br />''

DECLARE @tabela VARCHAR(MAX)
-- Cabeçalho 
SET @tabela = ''<table border=1 bordercolor=#000000 cellpadding=7 cellspacing=0 style="width:100%">'' + 
''<tr bgcolor=#3366ff>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Servidor</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Job</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Sucesso</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Falha</b></font></center></td>'' +
''<td><center><font face=verdana size=2 color=#ffffff><b>Criticidade</b></font></center></td>'' + 
''</tr>''

SELECT @tabela = @tabela + 
-- Corpo do e-mail
''<tr>'' + 
''<td bgcolor='' + CASE WHEN Q.Falha > 0 THEN ''#ff4d4d'' WHEN Q.Falha = 0 THEN ''#00B050'' END + ''><font face=verdana size=2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font></td>'' +
''<td><font face=verdana size=2 color='' + CASE WHEN Q.Falha > 0 THEN ''#ff4d4d'' WHEN Q.Falha = 0 THEN ''#000000'' END + ''>'' + Q.ServerName + ''</font></td>'' + 
''<td><font face=verdana size=2 color='' + CASE WHEN Q.Falha > 0 THEN ''#ff4d4d'' WHEN Q.Falha = 0 THEN ''#000000'' END + ''>'' + Q.Nome + ''</font></td>'' + 
''<td><font face=verdana size=2 color='' + CASE WHEN Q.Falha > 0 THEN ''#ff4d4d'' WHEN Q.Falha = 0 THEN ''#000000'' END + ''>'' + CONVERT(VARCHAR, Q.Sucesso) + ''</font></td>'' +
''<td><font face=verdana size=2 color='' + CASE WHEN Q.Falha > 0 THEN ''#ff4d4d'' WHEN Q.Falha = 0 THEN ''#000000'' END + ''>'' + CONVERT(VARCHAR, Q.Falha) + ''</font></td>'' +
''<td><font face=verdana size=2 color='' + CASE WHEN Q.Falha > 0 THEN ''#ff4d4d'' WHEN Q.Falha = 0 THEN ''#000000'' END + ''>'' + Q.Criticidade + ''</font></td>'' + 
''</tr>'' 

FROM 
                (
                SELECT 
                ServerName, 
				Nome, 
				Sucesso, 
				Falha,
				ISNULL(Criticidade,'''') as [Criticidade]
				FROM #Dashboard
				) Q
				ORDER BY Q.Falha DESC

SET @tabela = @tabela + ''</table>''

-- Montando backups

IF OBJECT_ID(''tempdb..#DashboardBackup'') IS NOT NULL
       DROP TABLE #DashboardBackup
SELECT 
NomeDoBanco
,TipoDeBackup
,TamanhoDoBackup
,TempoDoBackup
,DataInicioDoBackup
,Servidor
,RecoveryModel
INTO #DashboardBackup
 FROM BackupInfo WHERE FoiNotificado IS NULL

DECLARE @tabela2 VARCHAR(MAX)
-- Cabeçalho 
SET @tabela2 = ''<table border=1 bordercolor=#000000 cellpadding=7 cellspacing=0 style="width:100%">'' + 
''<tr bgcolor=#3366ff>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Nome Do Banco</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Tipo De Backup</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Tamanho Do Backup</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Tempo do Backup</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Data Inicio do Backup</b></font></center></td>'' +
''<td><center><font face=verdana size=2 color=#ffffff><b>Servidor</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Recovery Model</b></font></center></td>'' + 
''</tr>''

SELECT @tabela2 = @tabela2 + 
-- Corpo do e-mail
''<tr>'' + 
''<td bgcolor=#ffffff>''+'' <font face=verdana size=2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font></td>'' +
''<td><font face=verdana size=2 color= #000000>'' + B.NomeDoBanco + ''</font></td>'' + 
''<td><font face=verdana size=2 color= #000000>'' + B.TipoDeBackup + ''</font></td>'' + 
''<td><font face=verdana size=2 color= #000000>'' + B.TamanhoDoBackup + ''</font></td>'' + 
''<td><font face=verdana size=2 color= #000000>'' + B.TempoDoBackup + ''</font></td>'' + 
''<td><font face=verdana size=2 color= #000000>'' + CONVERT(VARCHAR, B.DataInicioDoBackup, 13) + ''</font></td>'' + 
''<td><font face=verdana size=2 color= #000000>'' + B.Servidor + ''</font></td>'' + 
''<td><font face=verdana size=2 color= #000000>'' + B.RecoveryModel + ''</font></td>'' + 
''</tr>'' 

FROM 
                (
                 SELECT 
				 NomeDoBanco
				,TipoDeBackup
				,TamanhoDoBackup
				,TempoDoBackup
				,DataInicioDoBackup
				,Servidor
				,RecoveryModel
				FROM #DashboardBackup
				) B

SET @tabela2 = @tabela2 + ''</table>''

-- ////// Montando Status do banco ///////

IF OBJECT_ID(''tempdb..#DashboardStatusDB'') IS NOT NULL
       DROP TABLE #DashboardStatusDB
		SELECT 
			NomeDoBanco
			,state_desc
			,recovery_model_desc
			,total_size
			,data_size
			,data_used_size
			,log_size
			,log_used_size
		INTO #DashboardStatusDB
 FROM StatusDosBancos WHERE FoiNotificado IS NULL

DECLARE @tabela3 VARCHAR(MAX)
-- Cabeçalho 
SET @tabela3 = ''<table border=1 bordercolor=#000000 cellpadding=7 cellspacing=0 style="width:100%">'' + 
''<tr bgcolor=#3366ff>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Nome Do Banco</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Status</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Recovery Model</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Tamanho Total MB</b></font></center></td>'' +
''<td><center><font face=verdana size=2 color=#ffffff><b>Dados MB</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Dados Usados MB</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Log MB</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Log Usado MB</b></font></center></td>'' + 
''</tr>''

SELECT @tabela3 = @tabela3 + 
-- Corpo do e-mail
''<tr>'' + 
''<td bgcolor='' + CASE WHEN C.state_desc <> ''ONLINE'' THEN ''#ff4d4d'' WHEN C.state_desc = ''ONLINE'' THEN ''#00B050'' END + ''><font face=verdana size=2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font></td>'' +
''<td><font face=verdana size=2 color='' + CASE WHEN C.state_desc <> ''ONLINE'' THEN ''#ff4d4d'' WHEN C.state_desc = ''ONLINE'' THEN ''#000000'' END + ''>'' + C.NomeDoBanco + ''</font></td>'' + 
''<td><font face=verdana size=2 color='' + CASE WHEN C.state_desc <> ''ONLINE'' THEN ''#ff4d4d'' WHEN C.state_desc = ''ONLINE'' THEN ''#000000'' END + ''>'' + C.state_desc + ''</font></td>'' + 
''<td><font face=verdana size=2 color='' + CASE WHEN C.state_desc <> ''ONLINE'' THEN ''#ff4d4d'' WHEN C.state_desc = ''ONLINE'' THEN ''#000000'' END + ''>'' + C.recovery_model_desc + ''</font></td>'' + 
''<td><font face=verdana size=2 color='' + CASE WHEN C.state_desc <> ''ONLINE'' THEN ''#ff4d4d'' WHEN C.state_desc = ''ONLINE'' THEN ''#000000'' END + ''>'' + CONVERT(VARCHAR, C.total_size) + ''</font></td>'' +
''<td><font face=verdana size=2 color='' + CASE WHEN C.state_desc <> ''ONLINE'' THEN ''#ff4d4d'' WHEN C.state_desc = ''ONLINE'' THEN ''#000000'' END + ''>'' + CONVERT(VARCHAR, C.data_size) + ''</font></td>'' +
''<td><font face=verdana size=2 color='' + CASE WHEN C.state_desc <> ''ONLINE'' THEN ''#ff4d4d'' WHEN C.state_desc = ''ONLINE'' THEN ''#000000'' END + ''>'' + CONVERT(VARCHAR, C.data_used_size) + ''</font></td>'' +
''<td><font face=verdana size=2 color='' + CASE WHEN C.state_desc <> ''ONLINE'' THEN ''#ff4d4d'' WHEN C.state_desc = ''ONLINE'' THEN ''#000000'' END + ''>'' + CONVERT(VARCHAR, C.log_size) + ''</font></td>'' +
''<td><font face=verdana size=2 color='' + CASE WHEN C.state_desc <> ''ONLINE'' THEN ''#ff4d4d'' WHEN C.state_desc = ''ONLINE'' THEN ''#000000'' END + ''>'' + CONVERT(VARCHAR, C.log_used_size) + ''</font></td>'' +
''</tr>'' 

FROM 
                (
                 SELECT 
					 NomeDoBanco
					,state_desc
					,recovery_model_desc
					,ISNULL (total_size, 0) AS total_size
					,ISNULL (data_size, 0) AS data_size
					,ISNULL (data_used_size, 0) AS data_used_size
					,ISNULL (log_size, 0) AS log_size
					,ISNULL (log_used_size, 0) AS log_used_size
				FROM #DashboardStatusDB
				) C

SET @tabela3 = @tabela3 + ''</table>''


-- ////// Monitoramento de Disco ///////

IF OBJECT_ID(''tempdb..#DashboardStatusDisco'') IS NOT NULL
       DROP TABLE #DashboardStatusDisco
		SELECT 
			Server
			,DriveLetter
			,Label
			,FreeSpace_MB
			,UsedSpace_MB
			,TotalSpace_MB
			,Percentage_Free
		INTO #DashboardStatusDisco
 FROM StatusDosDiscos WHERE FoiNotificado IS NULL

DECLARE @tabela4 VARCHAR(MAX)
-- Cabeçalho 
SET @tabela4 = ''<table border=1 bordercolor=#000000 cellpadding=7 cellspacing=0 style="width:100%">'' + 
''<tr bgcolor=#3366ff>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Servidor</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Drive</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Label</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Espaço Livre MB</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Espaço Usado MB</b></font></center></td>'' +
''<td><center><font face=verdana size=2 color=#ffffff><b>Total MB</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Procentagem Livre</b></font></center></td>'' + 
''</tr>''

SELECT @tabela4 = @tabela4 + 
-- Corpo do e-mail
''<tr>'' + 
''<td bgcolor='' + CASE WHEN D.Percentage_Free <= 10 THEN ''#ff4d4d'' WHEN D.Percentage_Free BETWEEN 11 AND 20 THEN ''#ffff33'' WHEN D.Percentage_Free >= 21 THEN ''#00B050'' END + ''><font face=verdana size=2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font></td>'' +
''<td><font face=verdana size=2 color='' + CASE WHEN D.Percentage_Free <= 25 THEN ''#000000'' WHEN D.Percentage_Free >= 25 THEN ''#000000'' END + ''>'' + D.Server + ''</font></td>'' + 
''<td><font face=verdana size=2 color='' + CASE WHEN D.Percentage_Free <= 25 THEN ''#000000'' WHEN D.Percentage_Free >= 25 THEN ''#000000'' END + ''>'' + D.DriveLetter + ''</font></td>'' + 
''<td><font face=verdana size=2 color='' + CASE WHEN D.Percentage_Free <= 25 THEN ''#000000'' WHEN D.Percentage_Free >= 25 THEN ''#000000'' END + ''>'' + D.Label + ''</font></td>'' + 
''<td><font face=verdana size=2 color='' + CASE WHEN D.Percentage_Free <= 25 THEN ''#000000'' WHEN D.Percentage_Free >= 25 THEN ''#000000'' END + ''>'' + CONVERT(VARCHAR, D.FreeSpace_MB) + ''</font></td>'' +
''<td><font face=verdana size=2 color='' + CASE WHEN D.Percentage_Free <= 25 THEN ''#000000'' WHEN D.Percentage_Free >= 25 THEN ''#000000'' END + ''>'' + CONVERT(VARCHAR, D.UsedSpace_MB) + ''</font></td>'' +
''<td><font face=verdana size=2 color='' + CASE WHEN D.Percentage_Free <= 25 THEN ''#000000'' WHEN D.Percentage_Free >= 25 THEN ''#000000'' END + ''>'' + CONVERT(VARCHAR, D.TotalSpace_MB) + ''</font></td>'' +
''<td><font face=verdana size=2 color='' + CASE WHEN D.Percentage_Free <= 25 THEN ''#000000'' WHEN D.Percentage_Free >= 25 THEN ''#000000'' END + ''>'' + CONVERT(VARCHAR, D.Percentage_Free) + ''</font></td>'' +
''</tr>'' 

FROM 
                (
                 SELECT 
					 Server
					,DriveLetter
					,Label
					,FreeSpace_MB
					,UsedSpace_MB
					,TotalSpace_MB
					,Percentage_Free
				FROM #DashboardStatusDisco
				) D

SET @tabela4 = @tabela4 + ''</table>''

-- ////// Logs Files ///////

IF OBJECT_ID(''tempdb..#StatusLogFile'') IS NOT NULL
       DROP TABLE #StatusLogFile
		SELECT 
			Servidor
			,Descricao
			,DataDoLog
		INTO #StatusLogFile
 FROM ErrorLogs WHERE FoiNotificado IS NULL

DECLARE @tabela5 VARCHAR(MAX)
-- Cabeçalho 
SET @tabela5 = ''<table border=1 bordercolor=#000000 cellpadding=7 cellspacing=0 style="width:100%">'' + 
''<tr bgcolor=#3366ff>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Servidor</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Descrição</b></font></center></td>'' + 
''<td><center><font face=verdana size=2 color=#ffffff><b>Data Do Log</b></font></center></td>'' + 
''</tr>''

SELECT @tabela5 = @tabela5 + 
-- Corpo do e-mail
''<tr>'' + 
''<td bgcolor=#3366ff><font face=verdana size=2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font></td>'' +
''<td><font face=verdana size=2 color=#000000>'' + E.Servidor + ''</font></td>'' + 
''<td><font face=verdana size=2 color=#000000>'' + E.Descricao + ''</font></td>'' + 
''<td><font face=verdana size=2 color=#000000>'' + E.DataDoLog + ''</font></td>'' + 
''</tr>'' 

FROM 
                (
                SELECT 
                Servidor
				,Descricao
				,DataDoLog
				FROM #StatusLogFile
				) E

SET @tabela5 = @tabela5 + ''</table>''

/*
Envio de e-mail
*/

DECLARE @corpo VARCHAR(MAX)
DECLARE @corpo2 VARCHAR(MAX)
DECLARE @corpo3 VARCHAR(MAX)
DECLARE @corpo4 VARCHAR(MAX)
DECLARE @corpo5 VARCHAR(MAX)
DECLARE @assunto VARCHAR(255) = ''Checklist Diário do Ambiente '' + @@SERVERNAME + '' ['' + CONVERT(VARCHAR, GETDATE()-1, 103) + '']''

SET @corpo = '''' + 
''<font size=2 face="verdana">'' + 
''<hr noshade size=2><br>'' + CHAR(13) + CHAR(10) + 
''<b><center>Execução dos Jobs</center></b><br>'' + CHAR(13) + CHAR(10) +
''<hr noshade size=2><br>'' + CHAR(13) + CHAR(10) 

SET @corpo2 = '''' + 
''<font size=2 face="verdana">'' + 
''<hr noshade size=2><br>'' + CHAR(13) + CHAR(10) + 
''<b><center>Execução dos Backups</center></b><br>'' + CHAR(13) + CHAR(10) +
''<hr noshade size=2><br>'' + CHAR(13) + CHAR(10) 

SET @corpo3 = '''' + 
''<font size=2 face="verdana">'' + 
''<hr noshade size=2><br>'' + CHAR(13) + CHAR(10) + 
''<b><center>Status Dos Bancos SQL Server</center></b><br>'' + CHAR(13) + CHAR(10) +
''<hr noshade size=2><br>'' + CHAR(13) + CHAR(10) 

SET @corpo4 = '''' + 
''<font size=2 face="verdana">'' + 
''<hr noshade size=2><br>'' + CHAR(13) + CHAR(10) + 
''<b><center>Status Dos Discos</center></b><br>'' + CHAR(13) + CHAR(10) +
''<hr noshade size=2><br>'' + CHAR(13) + CHAR(10) 

SET @corpo5 = '''' + 
''<font size=2 face="verdana">'' + 
''<hr noshade size=2><br>'' + CHAR(13) + CHAR(10) + 
''<b><center>Logs Do Servidor</center></b><br>'' + CHAR(13) + CHAR(10) +
''<hr noshade size=2><br>'' + CHAR(13) + CHAR(10) 

SET @corpo = @corpo + @tabela + CHAR(13) + CHAR(10)
SET @corpo2 = @corpo2 + @tabela2 + CHAR(13) + CHAR(10)
SET @corpo3 = @corpo3 + @tabela3 + CHAR(13) + CHAR(10)
SET @corpo4 = @corpo4 + @tabela4 + CHAR(13) + CHAR(10)
SET @corpo5 = @corpo5 + @tabela5 + CHAR(13) + CHAR(10)

SET @corpo = @header + @corpo + '''' + @corpo2 + @corpo3 + @corpo4 + @corpo5 + 
''<br><br>'' + CHAR(13) + CHAR(10) +
''<hr />'' +
''<h3>Seu Servidor está Ligado há '' + CONVERT(VARCHAR(5),(SELECT DATEDIFF(day,(SELECT sqlserver_start_time FROM sys.dm_os_sys_info),GETDATE()))) + '' Dias </h3>''
+
''<hr />''
+
''<br><br>'' + CHAR(13) + CHAR(10) +
''<b>Checklist Gerado em: </b>'' + CONVERT(VARCHAR, GETDATE(), 103) + '' às '' + CONVERT(VARCHAR, GETDATE(), 108) + 
''</font>''


/*Anexa Excel*/
		
		/*Renomeia arquivos temporários*/

declare @command varchar(max)
declare @nomearquivoDVB varchar(255)
declare @nomearquivoDVG varchar(255)
set @command = ''''
set @nomearquivoDVB = ''''
set @nomearquivoDVG = ''''
select @nomearquivoDVB = @nomearquivoDVB+''DatabaseDashboard''+convert(varchar,DATEPART(YEAR,getdate()-1))+CASE LEN(convert(varchar,DATEPART(MM,getdate()-1))) WHEN 1 THEN ''0''+convert(varchar,DATEPART(MM,getdate()-1)) ELSE convert(varchar,DATEPART(MM,getdate()-1)) END+CASE LEN(convert(varchar,DATEPART(DD,getdate()-1))) WHEN 1 THEN ''0''+convert(varchar,DATEPART(DD,getdate()-1)) ELSE convert(varchar,DATEPART(DD,getdate()-1)) END+''.xlsx''
select @nomearquivoDVG = @nomearquivoDVG+''DatabaseDashboard''+convert(varchar,DATEPART(YEAR,getdate()-1))+CASE LEN(convert(varchar,DATEPART(MM,getdate()-1))) WHEN 1 THEN ''0''+convert(varchar,DATEPART(MM,getdate()-1)) ELSE convert(varchar,DATEPART(MM,getdate()-1)) END+CASE LEN(convert(varchar,DATEPART(DD,getdate()-1))) WHEN 1 THEN ''0''+convert(varchar,DATEPART(DD,getdate()-1)) ELSE convert(varchar,DATEPART(DD,getdate()-1)) END+''.xlsx''
select @command = @command+''EXEC xp_cmdshell ''''rename C:\Monitoramento\Arquivos\DatabaseDashboard.xlsx ''+@nomearquivoDVB+''''''''

EXEC(@command)

       declare @caminhoarquivo varchar(8000)
       set @caminhoarquivo = ''''
       
       if exists (select 1 from checkattachment where [FileExists] = 1)
             set @caminhoarquivo = ''C:\Monitoramento\Arquivos\''+@nomearquivoDVB+'';''+''C:\Monitoramento\Arquivos\''+@nomearquivoDVG+''''
       else
             set @caminhoarquivo = ''C:\Monitoramento\Arquivos\''+@nomearquivoDVB+''''



            EXEC msdb..sp_send_dbmail

            @profile_name = '''', 	
            @recipients = '''',
            --@copy_recipients = '''',
            @subject = @assunto,
            @body_format = ''HTML'',
			@file_attachments = @caminhoarquivo,
            @body = @corpo

/*
Exclui arquivo temporário XLS
*/

UPDATE RelatorioDosJobs SET FoiNotificado = 1 WHERE FoiNotificado IS NULL
UPDATE BackupInfo SET FoiNotificado = 1 WHERE FoiNotificado IS NULL
UPDATE StatusDosBancos SET FoiNotificado = 1 WHERE FoiNotificado IS NULL
UPDATE StatusDosDiscos SET FoiNotificado = 1 WHERE FoiNotificado IS NULL
UPDATE ErrorLogs SET FoiNotificado = 1 WHERE FoiNotificado IS NULL


declare @delete varchar(8000)
set @delete = ''''
set @delete = @delete+''del /q C:\Monitoramento\Arquivos\'' + @nomearquivoDVB

EXEC xp_cmdshell @delete
GO

EXEC xp_cmdshell ''copy /y C:\Monitoramento\DatabaseDashboard_modelo.xlsx C:\Monitoramento\Arquivos\DatabaseDashboard.xlsx''', 
		@database_name=N'Monitoramento', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Agenda', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20140408, 
		@active_end_date=99991231, 
		@active_start_time=73000, 
		@active_end_time=235959, 
		@schedule_uid=N'e4239bb2-f010-48c4-9ac5-0e283c2b8757'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'testa_execucao', 
		@enabled=0, 
		@freq_type=8, 
		@freq_interval=16, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20170420, 
		@active_end_date=99991231, 
		@active_start_time=143300, 
		@active_end_time=235959, 
		@schedule_uid=N'ee41b0d2-5a0d-4bca-a2ba-30dca8ab0f4d'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO




USE [msdb]
GO

/****** Object:  Job [Job_CriaArquivoDeLog]    Script Date: 17/04/2017 17:49:31 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 17/04/2017 17:49:32 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Job_CriaArquivoDeLog', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Passo1]    Script Date: 17/04/2017 17:49:32 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Passo1', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'sp_cycle_errorlog', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Agendamento', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20170125, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'40b51436-bb8a-4c3e-b04f-ce85fcf6ad47'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

PRINT 'JOBS CRIADOS COM SUCESSO'
GO

USE [msdb]
GO

/****** Object:  Job [DB_DB_EnviaErrorLogsAS2350]    Script Date: 19/04/2017 16:50:19 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 19/04/2017 16:50:19 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DB_DB_EnviaErrorLogsAS2350', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Atualiza ErrrorLog do SQL Server as 23:50 antes de criar um novo arquivo de ErrorLog no SQL Server.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EnviaErrorLogsAS2350]    Script Date: 19/04/2017 16:50:19 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EnviaErrorLogsAS2350', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'Exec EnviaErrorLogsAS2350', 
		@database_name=N'Monitoramento', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Agendamento', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20170419, 
		@active_end_date=99991231, 
		@active_start_time=235000, 
		@active_end_time=235959, 
		@schedule_uid=N'6aec5f24-7302-42bd-b90c-2c6fd50591f8'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
