SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[dtproperties](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[objectid] [int] NULL,
	[property] [varchar](64) COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL,
	[value] [varchar](255) COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[uvalue] [nvarchar](255) COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[lvalue] [image] NULL,
	[version] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
