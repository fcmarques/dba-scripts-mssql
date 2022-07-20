if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[LOG_SPACE]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[LOG_SPACE]
GO

CREATE TABLE [dbo].[LOG_SPACE] (
	[LS_ID] [int] IDENTITY (1, 1) NOT NULL ,
	[LS_DB_NAME] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[LS_LOG_SIZE] [real] NULL ,
	[LS_LOG_SPACE_USED] [real] NULL ,
	[LS_STATUS] [int] NULL ,
	[LS_DATE] [datetime] NULL 
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[LOG_SPACE] ADD 
	CONSTRAINT [DF_LOG_SPACE_LS_DATE] DEFAULT (getdate()) FOR [LS_DATE],
	CONSTRAINT [PK_LOG_SPACE] PRIMARY KEY  CLUSTERED 
	(
		[LS_ID]
	)  ON [PRIMARY] 
GO


USE db_Database_Log
go

INSERT INTO LOG_SPACE(LS_DB_NAME, LS_LOG_SIZE, LS_LOG_SPACE_USED, LS_STATUS) 
EXEC ('dbcc sqlperf (logspace)')

--select * from log_space
--TRUNCATE TABLE log_space
