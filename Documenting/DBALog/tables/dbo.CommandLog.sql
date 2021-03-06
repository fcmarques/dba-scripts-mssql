SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CommandLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DatabaseName] [sysname] COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[SchemaName] [sysname] COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[ObjectName] [sysname] COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[ObjectType] [char](2) COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[IndexName] [sysname] COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[IndexType] [tinyint] NULL,
	[StatisticsName] [sysname] COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[PartitionNumber] [int] NULL,
	[ExtendedInfo] [xml] NULL,
	[Command] [nvarchar](max) COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL,
	[CommandType] [nvarchar](60) COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL,
	[StartTime] [datetime] NOT NULL,
	[EndTime] [datetime] NULL,
	[ErrorNumber] [int] NULL,
	[ErrorMessage] [nvarchar](max) COLLATE SQL_Latin1_General_CP850_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
