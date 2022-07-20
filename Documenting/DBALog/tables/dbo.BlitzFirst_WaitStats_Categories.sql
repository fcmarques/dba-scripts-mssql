SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[BlitzFirst_WaitStats_Categories](
	[WaitType] [nvarchar](60) COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL,
	[WaitCategory] [nvarchar](128) COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL,
	[Ignorable] [bit] NULL
) ON [PRIMARY]

GO
