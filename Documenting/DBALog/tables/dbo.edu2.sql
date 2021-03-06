SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[edu2](
	[nr_proposta] [varchar](12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[id_prod_emp] [int] NOT NULL,
	[id_emp] [int] NOT NULL,
	[nr_parcela] [int] NOT NULL,
	[nr_recibo] [int] NULL,
	[nr_recibo_identity] [int] NOT NULL,
	[dt_debito_cliente] [datetime] NOT NULL,
	[ds_auxiliar] [int] NULL
) ON [PRIMARY]

GO
