SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TB_CENTAVOS](
	[num_cpf] [decimal](11, 0) NOT NULL,
	[num_refer] [varchar](10) COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[Menor_consolidado] [bigint] NULL,
	[Menor_data_contabil] [datetime] NULL,
	[Maior_data_contabil] [datetime] NULL,
	[Soma_val_movimento] [money] NULL
) ON [PRIMARY]

GO
