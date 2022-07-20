SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[edu](
	[nr_recibo_identity] [int] NOT NULL,
	[Nr_PAGAMENTO] [int] NULL,
	[DT_PAGAMENTO] [datetime] NOT NULL,
	[CG_NMRO_APCE] [varchar](12) COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[id_status_pagto] [int] NOT NULL,
	[dt_debito_cliente] [datetime] NOT NULL,
	[ds_auxiliar] [int] NULL
) ON [PRIMARY]

GO
