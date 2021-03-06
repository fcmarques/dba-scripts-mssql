SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[BlitzFirst](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ServerName] [nvarchar](128) COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[CheckDate] [datetimeoffset](7) NULL,
	[CheckID] [int] NOT NULL,
	[Priority] [tinyint] NOT NULL,
	[FindingsGroup] [varchar](50) COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL,
	[Finding] [varchar](200) COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL,
	[URL] [varchar](200) COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL,
	[Details] [nvarchar](4000) COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[HowToStopIt] [xml] NULL,
	[QueryPlan] [xml] NULL,
	[QueryText] [nvarchar](max) COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[StartTime] [datetimeoffset](7) NULL,
	[LoginName] [nvarchar](128) COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[NTUserName] [nvarchar](128) COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[OriginalLoginName] [nvarchar](128) COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[ProgramName] [nvarchar](128) COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[HostName] [nvarchar](128) COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[DatabaseID] [int] NULL,
	[DatabaseName] [nvarchar](128) COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[OpenTransactionCount] [int] NULL,
	[DetailsInt] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
