SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TBVISAOFINAL15561](
	[cod_empresa] [int] NOT NULL,
	[cod_filial] [int] NOT NULL,
	[cod_cliente] [int] NOT NULL,
	[num_cpf] [decimal](11, 0) NOT NULL,
	[cod_produto] [int] NOT NULL,
	[dat_operacao] [datetime] NOT NULL,
	[cod_tipo_movimento] [int] NOT NULL,
	[cod_evento] [int] NOT NULL,
	[val_movimento] [money] NOT NULL,
	[cod_filial_origem] [int] NOT NULL,
	[cod_decendio] [int] NOT NULL,
	[dat_extrato] [datetime] NOT NULL,
	[dat_vencimento] [datetime] NOT NULL,
	[val_debito_processamento] [money] NOT NULL,
	[val_credito_processamento] [money] NOT NULL,
	[cod_tipo_cartao] [int] NULL,
	[cod_rede_origem] [int] NULL
) ON [PRIMARY]

GO
