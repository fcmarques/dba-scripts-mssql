SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CtrlEstatistica](
	[Banco] [nvarchar](128) COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[Tabela] [sysname] COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL,
	[IdIndice] [smallint] NULL,
	[UltimaAtualizacao] [datetime] NULL,
	[QtdeLinhas] [bigint] NULL,
	[Data] [datetime] NOT NULL,
	[controle] [int] NULL,
	[inicio] [datetime] NULL,
	[fim] [datetime] NULL
) ON [PRIMARY]

GO
