SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[SchemaChangeLog](
	[SchemaChangeLogID] [int] IDENTITY(1,1) NOT NULL,
	[CreateDate] [datetime] NULL,
	[LoginName] [sysname] COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[ComputerName] [sysname] COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[DBName] [sysname] COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL,
	[SQLEvent] [sysname] COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL,
	[Schema] [sysname] COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[ObjectName] [sysname] COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[SQLCmd] [nvarchar](max) COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[XmlEvent] [xml] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
