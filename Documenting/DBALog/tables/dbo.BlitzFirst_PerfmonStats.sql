SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[BlitzFirst_PerfmonStats](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ServerName] [nvarchar](128) COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[CheckDate] [datetimeoffset](7) NULL,
	[object_name] [nvarchar](128) COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL,
	[counter_name] [nvarchar](128) COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL,
	[instance_name] [nvarchar](128) COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[cntr_value] [bigint] NULL,
	[cntr_type] [int] NOT NULL,
	[value_delta] [bigint] NULL,
	[value_per_second] [decimal](18, 2) NULL
) ON [PRIMARY]

GO
