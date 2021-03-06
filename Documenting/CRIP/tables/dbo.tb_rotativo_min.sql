SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tb_rotativo_min](
	[cod_empresa] [int] NOT NULL,
	[cod_filial] [int] NOT NULL,
	[cod_cliente] [int] NOT NULL,
	[cod_produto] [int] NOT NULL,
	[dat_contabil] [datetime] NOT NULL,
	[val_saldo] [decimal](13, 2) NOT NULL,
	[dat_vencimento] [datetime] NOT NULL,
	[dat_proximo_extrato] [datetime] NOT NULL,
	[val_iof] [money] NULL,
	[cod_lancamento] [int] NULL
) ON [PRIMARY]

GO
