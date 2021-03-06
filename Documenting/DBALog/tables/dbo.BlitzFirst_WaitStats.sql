SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[BlitzFirst_WaitStats](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ServerName] [nvarchar](128) COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[CheckDate] [datetimeoffset](7) NULL,
	[wait_type] [nvarchar](60) COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[wait_time_ms] [bigint] NULL,
	[signal_wait_time_ms] [bigint] NULL,
	[waiting_tasks_count] [bigint] NULL
) ON [PRIMARY]

GO
