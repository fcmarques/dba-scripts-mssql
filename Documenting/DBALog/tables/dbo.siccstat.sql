SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[siccstat](
	[inicio] [datetime] NULL,
	[fim] [datetime] NULL,
	[cmd] [nvarchar](200) COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[ctrl] [int] NULL,
	[id] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]

GO
