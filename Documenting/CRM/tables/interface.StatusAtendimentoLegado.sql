SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [interface].[StatusAtendimentoLegado](
	[StatusAtendimentoLegadoId] [int] NOT NULL,
	[Descricao] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DataInclusao] [datetime] NOT NULL,
	[Usuario] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
