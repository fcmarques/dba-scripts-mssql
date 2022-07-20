/* https://www.dirceuresende.com/blog/sql-server-como-identificar-e-coletar-informacoes-de-consultas-demoradas-utilizando-extended-events-xe/ */

/* Passo 1 ? Ativar o Extended Event no Servidor (SQL 2012+) */

-- Apaga a sess?o, caso ela j? exista
IF ((SELECT COUNT(*) FROM sys.server_event_sessions WHERE [name] = 'Query Lenta') > 0) DROP EVENT SESSION [Query Lenta] ON SERVER 
GO

-- Cria o Extended Event no servidor, configurado para iniciar automaticamente quando o servi?o do SQL ? iniciado
CREATE EVENT SESSION [Query Lenta] ON SERVER 
ADD EVENT sqlserver.sql_batch_completed (
    ACTION (
        sqlserver.session_id,
        sqlserver.client_app_name,
        sqlserver.client_hostname,
        sqlserver.database_name,
        sqlserver.username,
        sqlserver.session_nt_username,
        sqlserver.session_server_principal_name,
        sqlserver.sql_text
    )
    WHERE
        duration > (3000000) -- 3 segundos
)
ADD TARGET package0.event_file (
    SET filename=N'C:\Traces\Query Lenta',
    max_file_size=(10),
    max_rollover_files=(10)
)
WITH (STARTUP_STATE=ON)
GO

-- Ativa o Extended Event
ALTER EVENT SESSION [Query Lenta] ON SERVER STATE = START
GO

/* Passo 2 ? Criar a Tabela de Hist?rico dos Dados */

USE [DB_DBA]
GO
 
CREATE TABLE dbo.Historico_Query_Lenta (
    [Dt_Evento] DATETIME,
    [session_id] INT,
    [database_name] VARCHAR(128),
    [username] VARCHAR(128),
    [session_server_principal_name] VARCHAR(128),
    [session_nt_username] VARCHAR(128),
    [client_hostname] VARCHAR(128),
    [client_app_name] VARCHAR(128),
    [duration] DECIMAL(18, 2),
    [cpu_time] DECIMAL(18, 2),
    [logical_reads] BIGINT,
    [physical_reads] BIGINT,
    [writes] BIGINT,
    [row_count] BIGINT,
    [sql_text] XML,
    [batch_text] XML,
    [result] VARCHAR(100)
) WITH(DATA_COMPRESSION=PAGE)
GO

CREATE CLUSTERED INDEX SK01_Historico_Query_Lenta ON dbo.Historico_Query_Lenta (Dt_Evento) WITH(DATA_COMPRESSION=PAGE)
GO

/* Passo 3 ? Criar a Stored Procedure para Capturar os Dados */

USE [DB_DBA]
GO
 
IF (OBJECT_ID('dbo.stpCarga_Query_Lenta') IS NULL) EXEC('CREATE PROCEDURE dbo.stpCarga_Query_Lenta AS SELECT 1')
GO
 
ALTER PROCEDURE dbo.stpCarga_Query_Lenta
AS
BEGIN
    
    
    DECLARE 
        @TimeZone INT = DATEDIFF(HOUR, GETUTCDATE(), GETDATE()),
        @Dt_Ultimo_Registro DATETIME = ISNULL((SELECT MAX(Dt_Evento) FROM dbo.Historico_Query_Lenta), '1900-01-01')
 
 
    IF (OBJECT_ID('tempdb..#Eventos') IS NOT NULL) DROP TABLE #Eventos
    ;WITH CTE AS (
        SELECT CONVERT(XML, event_data) AS event_data
        FROM sys.fn_xe_file_target_read_file(N'C:\Traces\Query Lenta*.xel', NULL, NULL, NULL)
    )
    SELECT
        DATEADD(HOUR, @TimeZone, CTE.event_data.value('(//event/@timestamp)[1]', 'datetime')) AS Dt_Evento,
        CTE.event_data
    INTO
        #Eventos
    FROM
        CTE
    WHERE
        DATEADD(HOUR, @TimeZone, CTE.event_data.value('(//event/@timestamp)[1]', 'datetime')) > @Dt_Ultimo_Registro
    
 
    INSERT INTO dbo.Historico_Query_Lenta
    SELECT
        A.Dt_Evento,
        xed.event_data.value('(action[@name="session_id"]/value)[1]', 'int') AS session_id,
        xed.event_data.value('(action[@name="database_name"]/value)[1]', 'varchar(128)') AS [database_name],
        xed.event_data.value('(action[@name="username"]/value)[1]', 'varchar(128)') AS username,
        xed.event_data.value('(action[@name="session_server_principal_name"]/value)[1]', 'varchar(128)') AS session_server_principal_name,
        xed.event_data.value('(action[@name="session_nt_username"]/value)[1]', 'varchar(128)') AS [session_nt_username],
        xed.event_data.value('(action[@name="client_hostname"]/value)[1]', 'varchar(128)') AS [client_hostname],
        xed.event_data.value('(action[@name="client_app_name"]/value)[1]', 'varchar(128)') AS [client_app_name],
        CAST(xed.event_data.value('(//data[@name="duration"]/value)[1]', 'bigint') / 1000000.0 AS NUMERIC(18, 2)) AS duration,
        CAST(xed.event_data.value('(//data[@name="cpu_time"]/value)[1]', 'bigint') / 1000000.0 AS NUMERIC(18, 2)) AS cpu_time,
        xed.event_data.value('(//data[@name="logical_reads"]/value)[1]', 'bigint') AS logical_reads,
        xed.event_data.value('(//data[@name="physical_reads"]/value)[1]', 'bigint') AS physical_reads,
        xed.event_data.value('(//data[@name="writes"]/value)[1]', 'bigint') AS writes,
        xed.event_data.value('(//data[@name="row_count"]/value)[1]', 'bigint') AS row_count,
        TRY_CAST(xed.event_data.value('(//action[@name="sql_text"]/value)[1]', 'varchar(max)') AS XML) AS sql_text,
        TRY_CAST(xed.event_data.value('(//data[@name="batch_text"]/value)[1]', 'varchar(max)') AS XML) AS batch_text,
        xed.event_data.value('(//data[@name="result"]/text)[1]', 'varchar(100)') AS result
    FROM
        #Eventos A
        CROSS APPLY A.event_data.nodes('//event') AS xed (event_data)
 
 
END

/* Passo 4 ? Criar um job no SQL Agent para automatizar a coleta dos dados */

USE [msdb]
GO

DECLARE @jobId BINARY(16)
EXEC  msdb.dbo.sp_add_job @job_name=N'DBA - Coleta de Query Lenta', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'BB-8\fcmar', @job_id = @jobId OUTPUT
select @jobId
GO
EXEC msdb.dbo.sp_add_jobserver @job_name=N'DBA - Coleta de Query Lenta', @server_name = N'BB-8\SQL2017'
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_name=N'DBA - Coleta de Query Lenta', @step_name=N'Executa SP', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.stpCarga_Query_Lenta', 
		@database_name=N'DB_DBA', 
		@flags=8
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Coleta de Query Lenta', 
		@enabled=1, 
		@start_step_id=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'BB-8\fcmar', 
		@notify_email_operator_name=N'', 
		@notify_page_operator_name=N''
GO
USE [msdb]
GO
DECLARE @schedule_id int
EXEC msdb.dbo.sp_add_jobschedule @job_name=N'DBA - Coleta de Query Lenta', @name=N'A cada 10 minutos', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=10, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20190218, 
		@active_end_date=99991231, 
		@active_start_time=112, 
		@active_end_time=235959, @schedule_id = @schedule_id OUTPUT
select @schedule_id
GO

