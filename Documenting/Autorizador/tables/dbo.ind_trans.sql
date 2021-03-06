SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ind_trans](
	[data_hora] [char](16) COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL,
	[num_caixa] [char](3) COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL,
	[cod_cliente] [char](11) COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL,
	[ind_prior] [int] NOT NULL,
	[data_hora_envio] [datetime] NOT NULL
) ON [PRIMARY]

GO
