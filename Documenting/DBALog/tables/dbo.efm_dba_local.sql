SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[efm_dba_local](
	[db] [nvarchar](128) COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[name] [sysname] COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL,
	[groupid] [smallint] NULL,
	[filename] [nvarchar](260) COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL
) ON [PRIMARY]

GO
