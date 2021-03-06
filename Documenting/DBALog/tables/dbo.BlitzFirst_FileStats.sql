SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[BlitzFirst_FileStats](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ServerName] [nvarchar](128) COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[CheckDate] [datetimeoffset](7) NULL,
	[DatabaseID] [int] NOT NULL,
	[FileID] [int] NOT NULL,
	[DatabaseName] [nvarchar](256) COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[FileLogicalName] [nvarchar](256) COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[TypeDesc] [nvarchar](60) COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[SizeOnDiskMB] [bigint] NULL,
	[io_stall_read_ms] [bigint] NULL,
	[num_of_reads] [bigint] NULL,
	[bytes_read] [bigint] NULL,
	[io_stall_write_ms] [bigint] NULL,
	[num_of_writes] [bigint] NULL,
	[bytes_written] [bigint] NULL,
	[PhysicalName] [nvarchar](520) COLLATE SQL_Latin1_General_CP850_CI_AI NULL
) ON [PRIMARY]

GO
