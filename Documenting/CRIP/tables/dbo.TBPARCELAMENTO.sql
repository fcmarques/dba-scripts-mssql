SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TBPARCELAMENTO](
	[cod_empresa] [int] NOT NULL,
	[cod_filial] [int] NOT NULL,
	[cod_cliente] [int] NOT NULL,
	[num_cpf] [decimal](11, 0) NOT NULL,
	[dat_operacao] [varchar](10) COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[dat_contabil] [varchar](10) COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[cod_produto] [int] NULL,
	[cod_tipo_cartao] [int] NOT NULL,
	[cod_rede_origem] [int] NOT NULL,
	[cod_consolidado] [bigint] NOT NULL,
	[cod_evento] [int] NOT NULL,
	[val_movimento] [money] NOT NULL,
	[Natureza] [char](1) COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL,
	[cod_contabilizacao_dia] [bigint] NULL
) ON [PRIMARY]

GO
