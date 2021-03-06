SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[conexoes](
	[spid] [smallint] NOT NULL,
	[kpid] [smallint] NOT NULL,
	[blocked] [smallint] NOT NULL,
	[waittype] [binary](2) NOT NULL,
	[waittime] [bigint] NOT NULL,
	[lastwaittype] [nchar](32) COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL,
	[waitresource] [nchar](256) COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL,
	[dbid] [smallint] NOT NULL,
	[uid] [smallint] NULL,
	[cpu] [int] NOT NULL,
	[physical_io] [bigint] NOT NULL,
	[memusage] [int] NOT NULL,
	[login_time] [datetime] NOT NULL,
	[last_batch] [datetime] NOT NULL,
	[ecid] [smallint] NOT NULL,
	[open_tran] [smallint] NOT NULL,
	[status] [nchar](30) COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL,
	[sid] [binary](86) NOT NULL,
	[hostname] [nchar](128) COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL,
	[program_name] [nchar](128) COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL,
	[hostprocess] [nchar](10) COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL,
	[cmd] [nchar](16) COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL,
	[nt_domain] [nchar](128) COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL,
	[nt_username] [nchar](128) COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL,
	[net_address] [nchar](12) COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL,
	[net_library] [nchar](12) COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL,
	[loginame] [nchar](128) COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL,
	[context_info] [binary](128) NOT NULL,
	[sql_handle] [binary](20) NOT NULL,
	[stmt_start] [int] NOT NULL,
	[stmt_end] [int] NOT NULL,
	[request_id] [int] NOT NULL
) ON [PRIMARY]

GO
