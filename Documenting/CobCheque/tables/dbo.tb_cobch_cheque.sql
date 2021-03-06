SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tb_cobch_cheque](
	[num_cheque] [varchar](20) COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL,
	[num_cpf] [decimal](15, 0) NOT NULL,
	[cod_motivo_devolucao] [decimal](5, 0) NULL,
	[num_conta] [varchar](20) COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[num_agencia] [varchar](20) COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[cod_banco] [decimal](5, 0) NULL,
	[val_cheque] [decimal](12, 2) NULL,
	[val_cheque_dinamico] [decimal](12, 2) NULL,
	[num_cupom] [decimal](10, 0) NULL,
	[cod_loja] [int] NULL,
	[dat_movimento] [datetime] NULL,
	[dat_importacao] [datetime] NULL,
	[dat_lucros_perdas] [datetime] NULL,
	[dat_recebido_filial] [datetime] NULL,
	[dat_enviado_filial] [datetime] NULL
) ON [PRIMARY]

GO
