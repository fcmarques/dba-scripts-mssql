SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tb_operacional_movimento](
	[cod_movimento] [bigint] IDENTITY(1,1) NOT NULL,
	[cod_operacional_indice] [bigint] NOT NULL,
	[cod_evento] [int] NOT NULL,
	[val_movimento] [money] NOT NULL,
	[dsc_adicional] [char](18) COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[num_cnpj] [char](14) COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[dat_vencimento] [char](8) COLLATE SQL_Latin1_General_CP850_CI_AI NULL
) ON [PRIMARY]

GO
