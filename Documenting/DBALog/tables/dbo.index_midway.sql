SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[index_midway](
	[index_name] [sysname] COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL,
	[table_name] [sysname] COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[pct_fragmentation] [float] NULL,
	[compression] [nvarchar](60) COLLATE Latin1_General_CI_AS_KS_WS NULL,
	[rows] [bigint] NOT NULL
) ON [PRIMARY]

GO
