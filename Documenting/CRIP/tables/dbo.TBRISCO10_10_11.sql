SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TBRISCO10_10_11](
	[dat_movimento] [datetime] NOT NULL,
	[num_cpf] [nchar](11) COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL,
	[cod_produto] [int] NOT NULL,
	[num_contrato] [bigint] NULL,
	[dat_vencimento] [datetime] NOT NULL,
	[num_parcela] [int] NOT NULL,
	[val_parcela] [money] NOT NULL,
	[val_parcela_futuro] [money] NOT NULL,
	[cod_nivel_risco] [char](2) COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL
) ON [PRIMARY]

GO
