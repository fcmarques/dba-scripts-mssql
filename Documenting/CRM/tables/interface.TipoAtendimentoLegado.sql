SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [interface].[TipoAtendimentoLegado](
	[TipoAtendimentoLegadoId] [int] NOT NULL,
	[DescricaoTipoAtendimentoLegado] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TipoAtendimentoCrmId] [int] NOT NULL,
	[DescricaoTipoAtendimentoCrm] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DataInclusao] [datetime] NOT NULL,
	[Usuario] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
