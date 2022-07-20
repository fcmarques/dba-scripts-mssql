<<<<<<< HEAD
create database dbacorp_maintenance
GO
use dbacorp_maintenance
GO

CREATE TABLE dbo.MaintenanceRoutines
	(
	RoutineName        NVARCHAR (128) NOT NULL,
	RoutineDescription NVARCHAR (1024) NOT NULL,
	CONSTRAINT PK__Maintena__A6FC7F707F60ED59 PRIMARY KEY (RoutineName)
	)
GO

CREATE TABLE dbo.MaintenanceParameters
	(
	RoutineName   NVARCHAR (128) NOT NULL,
	ParameterName NVARCHAR (128) NOT NULL,
	Value         NVARCHAR (1024) NULL,
	DatabaseName  NVARCHAR (128) NOT NULL,
	CONSTRAINT PK_MaintenanceRoutines_MaintenanceParameters_RoutineName_ParameterName PRIMARY KEY (RoutineName,ParameterName,DatabaseName),
	CONSTRAINT FK_MaintenanceRoutines_MaintenanceParameters_RoutineName FOREIGN KEY (RoutineName) REFERENCES dbo.MaintenanceRoutines (RoutineName)
	)
GO

CREATE TABLE dbo.MaintenanceErrorControl
	(
	RoutineName    NVARCHAR (128) NOT NULL,
	DatabaseName   NVARCHAR (128) NOT NULL,
	TableName      NVARCHAR (128) NULL,
	ErrorDate      DATETIME DEFAULT (getdate()) NULL,
	ErrorNumber    INT NULL,
	ErrorSeverity  INT NULL,
	ErrorState     INT NULL,
	ErrorProcedure NVARCHAR (128) NULL,
	ErrorLine      INT NULL,
	ErrorMessage   NVARCHAR (1024) NULL,
	CONSTRAINT FK_MaintenanceRoutines_MaintenanceErrorControl_RoutineName FOREIGN KEY (RoutineName) REFERENCES dbo.MaintenanceRoutines (RoutineName)
	)
GO

CREATE TABLE dbo.MaintenanceDatabases
	(
	DatabaseName       NVARCHAR (128) NOT NULL,
	IndBackupFull      CHAR (1) DEFAULT ('Y') NULL,
	IndBackupDiff      CHAR (1) DEFAULT ('N') NULL,
	IndBackupLog       CHAR (1) DEFAULT ('Y') NULL,
	IndRebuild         CHAR (1) DEFAULT ('Y') NULL,
	IndUpdateStatsFull CHAR (1) DEFAULT ('Y') NULL,
	IndCheckDB         CHAR (1) DEFAULT ('Y') NULL,
	PathBackupFull     NVARCHAR (1024) NULL,
	PathBackupDiff     NVARCHAR (1024) NULL,
	PathBackupLog      NVARCHAR (1024) NULL,
	DateIncluded       DATETIME DEFAULT (getdate()) NULL,
	IndBackupPurge     CHAR (1) NULL,
	IndAlwaysOn        CHAR (1) NULL,
	CONSTRAINT PK__Maintena__6F5131960F975522 PRIMARY KEY (DatabaseName)
	)
GO

CREATE TABLE dbo.MaintenanceControlFragmentation
	(
	DatabaseId                INT NULL,
	DatabaseName              NVARCHAR (128) NULL,
	ObjectId                  BIGINT NULL,
	IndexId                   INT NULL,
	PartitionNumer            INT NULL,
	AvgFragmentationInPercent FLOAT NULL,
	DateCollect               DATETIME DEFAULT (getdate()) NULL,
	StartTime                 DATETIME NULL,
	EndTime                   DATETIME NULL,
	RebuildStatus             NVARCHAR (100) DEFAULT ('') NULL,
	RebuildType               NVARCHAR (20) NULL
	)
GO

CREATE TABLE dbo.MaintenanceCheckdbTimes
	(
	CheckdbId     INT IDENTITY NOT NULL,
	DatabaseName  NVARCHAR (128) NOT NULL,
	StartTime     DATETIME DEFAULT (getdate()) NULL,
	EndTime       DATETIME NULL,
	CheckdbStatus NVARCHAR (100) NULL,
	CONSTRAINT PK__Checkdb__EB9069C207C12930 PRIMARY KEY (CheckdbId),
	CONSTRAINT FK_MaintenanceCheckdbs_MaintenanceCheckdbTimes_DatabaseName FOREIGN KEY (DatabaseName) REFERENCES dbo.MaintenanceDatabases (DatabaseName)
	)
GO


CREATE TABLE dbo.MaintenanceBackupTimes
	(
	BackupId     INT IDENTITY NOT NULL,
	DatabaseName NVARCHAR (128) NOT NULL,
	BackupType   NVARCHAR (20) NOT NULL,
	StartTime    DATETIME DEFAULT (getdate()) NULL,
	EndTime      DATETIME NULL,
	BackupStatus NVARCHAR (100) NULL,
	CONSTRAINT PK__Maintena__EB9069C207C12930 PRIMARY KEY (BackupId),
	CONSTRAINT FK_MaintenanceBackups_MaintenanceBackupTimes_DatabaseName FOREIGN KEY (DatabaseName) REFERENCES dbo.MaintenanceDatabases (DatabaseName)
	)
GO

CREATE TABLE dbo.MaintenanceRoutineTimes
	(
	RoutineId   INT IDENTITY NOT NULL,
	RoutineName NVARCHAR (128) NOT NULL,
	StartTime   DATETIME DEFAULT (getdate()) NULL,
	EndTime     DATETIME NULL,
	CONSTRAINT PK__Maintena__A6E3E4FA76969D2E PRIMARY KEY (RoutineId),
	CONSTRAINT FK_MaintenanceRoutines_MaintenanceRoutineTimes_RoutineName FOREIGN KEY (RoutineName) REFERENCES dbo.MaintenanceRoutines (RoutineName)
	)
GO

CREATE TABLE dbo.MaintenanceExcludeListTables
	(
	DatabaseName NVARCHAR (128) NOT NULL,
	TableSchema NVARCHAR (128) NULL,	
	TableName    NVARCHAR (128) NOT NULL,
	ObjectId	 AS (object_id((((((N'['+[DatabaseName])+'].[')+[TableSchema])+'].[')+[TableName])+']')),
	DatabaseId   AS (db_id((N''+[DatabaseName])+'')),	
	CONSTRAINT PK__Maintena__6F5131961F98B2C1 PRIMARY KEY (DatabaseName),
	CONSTRAINT UK_MaintenanceExcludeListTables_DatabaseName_TableName UNIQUE (DatabaseName,TableName),
	CONSTRAINT FK_MaintenanceDatabases_MaintenanceExcludeListTables_DatabaseName FOREIGN KEY (DatabaseName) REFERENCES dbo.MaintenanceDatabases (DatabaseName)
	)
GO



-- Table:  MaintenanceRoutines
INSERT INTO MaintenanceRoutines (RoutineName, RoutineDescription) VALUES ('BACKUPDIFF', 'Realiza o BACKUP Diferencial do(s) banco(s).')
INSERT INTO MaintenanceRoutines (RoutineName, RoutineDescription) VALUES ('BACKUPFULL', 'Realiza o BACKUP FULL do(s) banco(s).')
INSERT INTO MaintenanceRoutines (RoutineName, RoutineDescription) VALUES ('BACKUPLOG', 'Realiza o BACKUP Transacional do(s) banco(s).')
INSERT INTO MaintenanceRoutines (RoutineName, RoutineDescription) VALUES ('BACKUPPURGE', 'Tempo de retenção dos arquivos em minutos.')
INSERT INTO MaintenanceRoutines (RoutineName, RoutineDescription) VALUES ('CHECKDB', 'Realiza a verificação de integridade do(s) banco(s).')
INSERT INTO MaintenanceRoutines (RoutineName, RoutineDescription) VALUES ('COLLECTDEFRAG', 'Realiza a coleta de objetos fragmentados.')
INSERT INTO MaintenanceRoutines (RoutineName, RoutineDescription) VALUES ('DATABASES', 'INSERT DEFAULT DE DATABASES')
INSERT INTO MaintenanceRoutines (RoutineName, RoutineDescription) VALUES ('ERRO', 'ROTINA NÃO EXISTE')
INSERT INTO MaintenanceRoutines (RoutineName, RoutineDescription) VALUES ('REBUILD', 'Realiza a recriação de índices fragmentados.')
INSERT INTO MaintenanceRoutines (RoutineName, RoutineDescription) VALUES ('REORG', 'Realiza a reorganização de índices fragmentados.')
INSERT INTO MaintenanceRoutines (RoutineName, RoutineDescription) VALUES ('UPDATESTATSFULL', 'Realiza a atualização de estatísticas FULL da(s) tabela(s).')
-- Table:  MaintenanceParameters
INSERT INTO MaintenanceParameters (RoutineName, ParameterName, Value, DatabaseName) VALUES ('BACKUPFULL', 'COMPRESSION', '*', 'ALL')
INSERT INTO MaintenanceParameters (RoutineName, ParameterName, Value, DatabaseName) VALUES ('BACKUPPURGE', 'BACKUPDIFF', '7', 'ALL')
INSERT INTO MaintenanceParameters (RoutineName, ParameterName, Value, DatabaseName) VALUES ('BACKUPPURGE', 'BACKUPFULL', '7', 'ALL')
INSERT INTO MaintenanceParameters (RoutineName, ParameterName, Value, DatabaseName) VALUES ('BACKUPPURGE', 'BACKUPLOG', '7', 'ALL')
INSERT INTO MaintenanceParameters (RoutineName, ParameterName, Value, DatabaseName) VALUES ('DATABASES', 'IndAlwaysOn', 'N', 'ALL')
INSERT INTO MaintenanceParameters (RoutineName, ParameterName, Value, DatabaseName) VALUES ('DATABASES', 'IndBackupDiff', 'N', 'ALL')
INSERT INTO MaintenanceParameters (RoutineName, ParameterName, Value, DatabaseName) VALUES ('DATABASES', 'IndBackupFull', 'Y', 'ALL')
INSERT INTO MaintenanceParameters (RoutineName, ParameterName, Value, DatabaseName) VALUES ('DATABASES', 'IndBackupLog', 'Y', 'ALL')
INSERT INTO MaintenanceParameters (RoutineName, ParameterName, Value, DatabaseName) VALUES ('DATABASES', 'IndBackupPurge', 'Y', 'ALL')
INSERT INTO MaintenanceParameters (RoutineName, ParameterName, Value, DatabaseName) VALUES ('DATABASES', 'IndCheckDB', 'Y', 'ALL')
INSERT INTO MaintenanceParameters (RoutineName, ParameterName, Value, DatabaseName) VALUES ('DATABASES', 'IndRebuild', 'Y', 'ALL')
INSERT INTO MaintenanceParameters (RoutineName, ParameterName, Value, DatabaseName) VALUES ('DATABASES', 'IndUpdateStatsFull', 'Y', 'ALL')
INSERT INTO MaintenanceParameters (RoutineName, ParameterName, Value, DatabaseName) VALUES ('DATABASES', 'PathBackupDiff', 'D:\bkp_sql\DIFF\', 'ALL')
INSERT INTO MaintenanceParameters (RoutineName, ParameterName, Value, DatabaseName) VALUES ('DATABASES', 'PathBackupFull', 'D:\bkp_sql\FULL\', 'ALL')
INSERT INTO MaintenanceParameters (RoutineName, ParameterName, Value, DatabaseName) VALUES ('DATABASES', 'PathBackupLog', 'D:\bkp_sql\LOG\', 'ALL')
INSERT INTO MaintenanceParameters (RoutineName, ParameterName, Value, DatabaseName) VALUES ('REBUILD', 'AVGFRAGMENTATIONINPERCENT', '30.0', 'ALL')
INSERT INTO MaintenanceParameters (RoutineName, ParameterName, Value, DatabaseName) VALUES ('REBUILD', 'LIMITTIME', '240', 'ALL')
INSERT INTO MaintenanceParameters (RoutineName, ParameterName, Value, DatabaseName) VALUES ('REORG', 'AVGFRAGMENTATIONINPERCENT', '30.0', 'ALL')

=======
create database dbacorp_maintenance
GO
use dbacorp_maintenance
GO

CREATE TABLE dbo.MaintenanceRoutines
	(
	RoutineName        NVARCHAR (128) NOT NULL,
	RoutineDescription NVARCHAR (1024) NOT NULL,
	CONSTRAINT PK__Maintena__A6FC7F707F60ED59 PRIMARY KEY (RoutineName)
	)
GO

CREATE TABLE dbo.MaintenanceParameters
	(
	RoutineName   NVARCHAR (128) NOT NULL,
	ParameterName NVARCHAR (128) NOT NULL,
	Value         NVARCHAR (1024) NULL,
	DatabaseName  NVARCHAR (128) NOT NULL,
	CONSTRAINT PK_MaintenanceRoutines_MaintenanceParameters_RoutineName_ParameterName PRIMARY KEY (RoutineName,ParameterName,DatabaseName),
	CONSTRAINT FK_MaintenanceRoutines_MaintenanceParameters_RoutineName FOREIGN KEY (RoutineName) REFERENCES dbo.MaintenanceRoutines (RoutineName)
	)
GO

CREATE TABLE dbo.MaintenanceErrorControl
	(
	RoutineName    NVARCHAR (128) NOT NULL,
	DatabaseName   NVARCHAR (128) NOT NULL,
	TableName      NVARCHAR (128) NULL,
	ErrorDate      DATETIME DEFAULT (getdate()) NULL,
	ErrorNumber    INT NULL,
	ErrorSeverity  INT NULL,
	ErrorState     INT NULL,
	ErrorProcedure NVARCHAR (128) NULL,
	ErrorLine      INT NULL,
	ErrorMessage   NVARCHAR (1024) NULL,
	CONSTRAINT FK_MaintenanceRoutines_MaintenanceErrorControl_RoutineName FOREIGN KEY (RoutineName) REFERENCES dbo.MaintenanceRoutines (RoutineName)
	)
GO

CREATE TABLE dbo.MaintenanceDatabases
	(
	DatabaseName       NVARCHAR (128) NOT NULL,
	IndBackupFull      CHAR (1) DEFAULT ('Y') NULL,
	IndBackupDiff      CHAR (1) DEFAULT ('N') NULL,
	IndBackupLog       CHAR (1) DEFAULT ('Y') NULL,
	IndRebuild         CHAR (1) DEFAULT ('Y') NULL,
	IndUpdateStatsFull CHAR (1) DEFAULT ('Y') NULL,
	IndCheckDB         CHAR (1) DEFAULT ('Y') NULL,
	PathBackupFull     NVARCHAR (1024) NULL,
	PathBackupDiff     NVARCHAR (1024) NULL,
	PathBackupLog      NVARCHAR (1024) NULL,
	DateIncluded       DATETIME DEFAULT (getdate()) NULL,
	IndBackupPurge     CHAR (1) NULL,
	IndAlwaysOn        CHAR (1) NULL,
	CONSTRAINT PK__Maintena__6F5131960F975522 PRIMARY KEY (DatabaseName)
	)
GO

CREATE TABLE dbo.MaintenanceControlFragmentation
	(
	DatabaseId                INT NULL,
	DatabaseName              NVARCHAR (128) NULL,
	ObjectId                  BIGINT NULL,
	IndexId                   INT NULL,
	PartitionNumer            INT NULL,
	AvgFragmentationInPercent FLOAT NULL,
	DateCollect               DATETIME DEFAULT (getdate()) NULL,
	StartTime                 DATETIME NULL,
	EndTime                   DATETIME NULL,
	RebuildStatus             NVARCHAR (100) DEFAULT ('') NULL,
	RebuildType               NVARCHAR (20) NULL
	)
GO

CREATE TABLE dbo.MaintenanceCheckdbTimes
	(
	CheckdbId     INT IDENTITY NOT NULL,
	DatabaseName  NVARCHAR (128) NOT NULL,
	StartTime     DATETIME DEFAULT (getdate()) NULL,
	EndTime       DATETIME NULL,
	CheckdbStatus NVARCHAR (100) NULL,
	CONSTRAINT PK__Checkdb__EB9069C207C12930 PRIMARY KEY (CheckdbId),
	CONSTRAINT FK_MaintenanceCheckdbs_MaintenanceCheckdbTimes_DatabaseName FOREIGN KEY (DatabaseName) REFERENCES dbo.MaintenanceDatabases (DatabaseName)
	)
GO


CREATE TABLE dbo.MaintenanceBackupTimes
	(
	BackupId     INT IDENTITY NOT NULL,
	DatabaseName NVARCHAR (128) NOT NULL,
	BackupType   NVARCHAR (20) NOT NULL,
	StartTime    DATETIME DEFAULT (getdate()) NULL,
	EndTime      DATETIME NULL,
	BackupStatus NVARCHAR (100) NULL,
	CONSTRAINT PK__Maintena__EB9069C207C12930 PRIMARY KEY (BackupId),
	CONSTRAINT FK_MaintenanceBackups_MaintenanceBackupTimes_DatabaseName FOREIGN KEY (DatabaseName) REFERENCES dbo.MaintenanceDatabases (DatabaseName)
	)
GO

CREATE TABLE dbo.MaintenanceRoutineTimes
	(
	RoutineId   INT IDENTITY NOT NULL,
	RoutineName NVARCHAR (128) NOT NULL,
	StartTime   DATETIME DEFAULT (getdate()) NULL,
	EndTime     DATETIME NULL,
	CONSTRAINT PK__Maintena__A6E3E4FA76969D2E PRIMARY KEY (RoutineId),
	CONSTRAINT FK_MaintenanceRoutines_MaintenanceRoutineTimes_RoutineName FOREIGN KEY (RoutineName) REFERENCES dbo.MaintenanceRoutines (RoutineName)
	)
GO

CREATE TABLE dbo.MaintenanceExcludeListTables
	(
	DatabaseName NVARCHAR (128) NOT NULL,
	TableSchema NVARCHAR (128) NULL,	
	TableName    NVARCHAR (128) NOT NULL,
	ObjectId	 AS (object_id((((((N'['+[DatabaseName])+'].[')+[TableSchema])+'].[')+[TableName])+']')),
	DatabaseId   AS (db_id((N''+[DatabaseName])+'')),	
	CONSTRAINT PK__Maintena__6F5131961F98B2C1 PRIMARY KEY (DatabaseName),
	CONSTRAINT UK_MaintenanceExcludeListTables_DatabaseName_TableName UNIQUE (DatabaseName,TableName),
	CONSTRAINT FK_MaintenanceDatabases_MaintenanceExcludeListTables_DatabaseName FOREIGN KEY (DatabaseName) REFERENCES dbo.MaintenanceDatabases (DatabaseName)
	)
GO



-- Table:  MaintenanceRoutines
INSERT INTO MaintenanceRoutines (RoutineName, RoutineDescription) VALUES ('BACKUPDIFF', 'Realiza o BACKUP Diferencial do(s) banco(s).')
INSERT INTO MaintenanceRoutines (RoutineName, RoutineDescription) VALUES ('BACKUPFULL', 'Realiza o BACKUP FULL do(s) banco(s).')
INSERT INTO MaintenanceRoutines (RoutineName, RoutineDescription) VALUES ('BACKUPLOG', 'Realiza o BACKUP Transacional do(s) banco(s).')
INSERT INTO MaintenanceRoutines (RoutineName, RoutineDescription) VALUES ('BACKUPPURGE', 'Tempo de retenção dos arquivos em minutos.')
INSERT INTO MaintenanceRoutines (RoutineName, RoutineDescription) VALUES ('CHECKDB', 'Realiza a verificação de integridade do(s) banco(s).')
INSERT INTO MaintenanceRoutines (RoutineName, RoutineDescription) VALUES ('COLLECTDEFRAG', 'Realiza a coleta de objetos fragmentados.')
INSERT INTO MaintenanceRoutines (RoutineName, RoutineDescription) VALUES ('DATABASES', 'INSERT DEFAULT DE DATABASES')
INSERT INTO MaintenanceRoutines (RoutineName, RoutineDescription) VALUES ('ERRO', 'ROTINA NÃO EXISTE')
INSERT INTO MaintenanceRoutines (RoutineName, RoutineDescription) VALUES ('REBUILD', 'Realiza a recriação de índices fragmentados.')
INSERT INTO MaintenanceRoutines (RoutineName, RoutineDescription) VALUES ('REORG', 'Realiza a reorganização de índices fragmentados.')
INSERT INTO MaintenanceRoutines (RoutineName, RoutineDescription) VALUES ('UPDATESTATSFULL', 'Realiza a atualização de estatísticas FULL da(s) tabela(s).')
-- Table:  MaintenanceParameters
INSERT INTO MaintenanceParameters (RoutineName, ParameterName, Value, DatabaseName) VALUES ('BACKUPFULL', 'COMPRESSION', '*', 'ALL')
INSERT INTO MaintenanceParameters (RoutineName, ParameterName, Value, DatabaseName) VALUES ('BACKUPPURGE', 'BACKUPDIFF', '7', 'ALL')
INSERT INTO MaintenanceParameters (RoutineName, ParameterName, Value, DatabaseName) VALUES ('BACKUPPURGE', 'BACKUPFULL', '7', 'ALL')
INSERT INTO MaintenanceParameters (RoutineName, ParameterName, Value, DatabaseName) VALUES ('BACKUPPURGE', 'BACKUPLOG', '7', 'ALL')
INSERT INTO MaintenanceParameters (RoutineName, ParameterName, Value, DatabaseName) VALUES ('DATABASES', 'IndAlwaysOn', 'N', 'ALL')
INSERT INTO MaintenanceParameters (RoutineName, ParameterName, Value, DatabaseName) VALUES ('DATABASES', 'IndBackupDiff', 'N', 'ALL')
INSERT INTO MaintenanceParameters (RoutineName, ParameterName, Value, DatabaseName) VALUES ('DATABASES', 'IndBackupFull', 'Y', 'ALL')
INSERT INTO MaintenanceParameters (RoutineName, ParameterName, Value, DatabaseName) VALUES ('DATABASES', 'IndBackupLog', 'Y', 'ALL')
INSERT INTO MaintenanceParameters (RoutineName, ParameterName, Value, DatabaseName) VALUES ('DATABASES', 'IndBackupPurge', 'Y', 'ALL')
INSERT INTO MaintenanceParameters (RoutineName, ParameterName, Value, DatabaseName) VALUES ('DATABASES', 'IndCheckDB', 'Y', 'ALL')
INSERT INTO MaintenanceParameters (RoutineName, ParameterName, Value, DatabaseName) VALUES ('DATABASES', 'IndRebuild', 'Y', 'ALL')
INSERT INTO MaintenanceParameters (RoutineName, ParameterName, Value, DatabaseName) VALUES ('DATABASES', 'IndUpdateStatsFull', 'Y', 'ALL')
INSERT INTO MaintenanceParameters (RoutineName, ParameterName, Value, DatabaseName) VALUES ('DATABASES', 'PathBackupDiff', 'D:\bkp_sql\DIFF\', 'ALL')
INSERT INTO MaintenanceParameters (RoutineName, ParameterName, Value, DatabaseName) VALUES ('DATABASES', 'PathBackupFull', 'D:\bkp_sql\FULL\', 'ALL')
INSERT INTO MaintenanceParameters (RoutineName, ParameterName, Value, DatabaseName) VALUES ('DATABASES', 'PathBackupLog', 'D:\bkp_sql\LOG\', 'ALL')
INSERT INTO MaintenanceParameters (RoutineName, ParameterName, Value, DatabaseName) VALUES ('REBUILD', 'AVGFRAGMENTATIONINPERCENT', '30.0', 'ALL')
INSERT INTO MaintenanceParameters (RoutineName, ParameterName, Value, DatabaseName) VALUES ('REBUILD', 'LIMITTIME', '240', 'ALL')
INSERT INTO MaintenanceParameters (RoutineName, ParameterName, Value, DatabaseName) VALUES ('REORG', 'AVGFRAGMENTATIONINPERCENT', '30.0', 'ALL')

>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
