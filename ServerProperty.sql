SELECT
SERVERPROPERTY  ('MachineName') as Servidor,
SERVERPROPERTY  ('InstanceName') as Instance,
SERVERPROPERTY ('Edition') as Edicao,
SERVERPROPERTY ('LicenseType') as TipoLicenca,
SERVERPROPERTY ('NumLicenses') as NumeroLicencas,
SERVERPROPERTY('ProductVersion') AS ProductVersion,
SERVERPROPERTY('ProductLevel') AS ProductLevel;
GO
--exec xp_msver 'ProcessorCount'

select left((CONVERT(varchar(2) SERVERPROPERTY('ProductVersion')),2)


select convert (int,CONVERT (varchar(2),serverproperty('ProductVersion')))

select name, databasepropertyex(name, 'Recovery') as RecoveryModel from master.dbo.sysdatabases order by name


SELECT
SERVERPROPERTY  ('MachineName') as Servidor,
SERVERPROPERTY ('Edition') as Edicao,
SERVERPROPERTY('ProductVersion') AS ProductVersion,
SERVERPROPERTY('ProductLevel') AS ProductLevel,
GETDATE()
go