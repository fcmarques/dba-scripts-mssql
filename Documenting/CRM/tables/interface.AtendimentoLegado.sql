SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [interface].[AtendimentoLegado](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[CodigoEmpresa] [int] NOT NULL,
	[CodigoFilial] [int] NOT NULL,
	[CodigoCliente] [int] NOT NULL,
	[TipoAtendimentoLegadoId] [int] NOT NULL,
	[StatusAtendimentoLegadoId] [int] NOT NULL,
	[Observacao] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DataInclusao] [datetime] NOT NULL,
	[Usuario] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DataAtualizacaoCrm] [datetime] NULL,
	[NumeroProtocoloGerado] [int] NULL
) ON [PRIMARY]

GO
