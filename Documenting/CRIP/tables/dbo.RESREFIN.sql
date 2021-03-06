SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[RESREFIN](
	[cod_empresa] [int] NOT NULL,
	[cod_filial] [int] NOT NULL,
	[cod_cliente] [int] NOT NULL,
	[num_cpf] [decimal](11, 0) NOT NULL,
	[cod_nivel_risco] [char](2) COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[dat_operacao] [datetime] NOT NULL,
	[dat_extrato] [datetime] NOT NULL,
	[dat_vencimento] [datetime] NOT NULL,
	[val_encargos_refinanciamento] [money] NULL,
	[val_movimento] [money] NULL,
	[resultado] [money] NULL
) ON [PRIMARY]

GO
