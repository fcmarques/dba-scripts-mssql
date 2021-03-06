SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TBVISAOFINAL](
	[cod_movimento] [bigint] NOT NULL,
	[cod_consolidado] [bigint] NOT NULL,
	[cod_evento] [int] NOT NULL,
	[val_movimento] [money] NOT NULL,
	[Natureza] [varchar](1) COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL,
	[cod_contabilizacao_dia] [bigint] NULL,
	[cod_empresa] [int] NOT NULL,
	[cod_filial] [int] NOT NULL,
	[cod_cliente] [int] NOT NULL,
	[num_cpf] [decimal](11, 0) NOT NULL,
	[dat_operacao] [datetime] NOT NULL,
	[dat_contabil] [datetime] NOT NULL,
	[cod_produto] [int] NULL,
	[cod_tipo_cartao] [int] NOT NULL,
	[cod_rede_origem] [int] NOT NULL,
	[num_refer] [varchar](10) COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[cod_contrato] [int] NULL
) ON [PRIMARY]

GO
