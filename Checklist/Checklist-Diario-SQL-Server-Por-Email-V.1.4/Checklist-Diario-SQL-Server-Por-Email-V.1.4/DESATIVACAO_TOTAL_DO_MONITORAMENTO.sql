<<<<<<< HEAD
/* 	CASO DESEJA MANTER OS DADOS E APENAS DESATIVAR O MONITORAMENTO
	DESABILITE O JOB JB_BD_EXECUCAODOSJOBSDIARIOS
*/
use Monitoramento
GO
drop table 	[BackupInfo] -- Informações de Backup
drop table [DashboardDatabase_Jobs] -- Jobs com falha
drop table	[JobsCriticos] -- Lista Jobs críticos
drop table	[StatusDosBancos] -- Status dos bancos
drop table	[StatusDosDiscos] -- Espaço em disco
drop table	[ErrorLogs] -- Errors Log SQL Server
drop table	[RelatorioDosJobs] -- Relatorio dos Jobs
drop Procedure [Proc_Atualiza_Dados] -- Atualiza Dados
drop Procedure [Proc_Atualiza_Planilha] -- Atualiza Planilha
drop procedure [EnviaErrorLogsAS2350] -- Envia Logs de erro as 23:50
EXEC msdb.dbo.sp_delete_job @job_name=N'JB_BD_EXECUCAODOSJOBSDIARIOS', @delete_unused_schedule=1
GO
EXEC msdb.dbo.sp_delete_job @job_name=N'Job_CriaArquivoDeLog', @delete_unused_schedule=1
GO
EXEC msdb.dbo.sp_delete_job @job_name=N'DB_DB_EnviaErrorLogsAS2350', @delete_unused_schedule=1
GO
=======
/* 	CASO DESEJA MANTER OS DADOS E APENAS DESATIVAR O MONITORAMENTO
	DESABILITE O JOB JB_BD_EXECUCAODOSJOBSDIARIOS
*/
use Monitoramento
GO
drop table 	[BackupInfo] -- Informações de Backup
drop table [DashboardDatabase_Jobs] -- Jobs com falha
drop table	[JobsCriticos] -- Lista Jobs críticos
drop table	[StatusDosBancos] -- Status dos bancos
drop table	[StatusDosDiscos] -- Espaço em disco
drop table	[ErrorLogs] -- Errors Log SQL Server
drop table	[RelatorioDosJobs] -- Relatorio dos Jobs
drop Procedure [Proc_Atualiza_Dados] -- Atualiza Dados
drop Procedure [Proc_Atualiza_Planilha] -- Atualiza Planilha
drop procedure [EnviaErrorLogsAS2350] -- Envia Logs de erro as 23:50
EXEC msdb.dbo.sp_delete_job @job_name=N'JB_BD_EXECUCAODOSJOBSDIARIOS', @delete_unused_schedule=1
GO
EXEC msdb.dbo.sp_delete_job @job_name=N'Job_CriaArquivoDeLog', @delete_unused_schedule=1
GO
EXEC msdb.dbo.sp_delete_job @job_name=N'DB_DB_EnviaErrorLogsAS2350', @delete_unused_schedule=1
GO
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
