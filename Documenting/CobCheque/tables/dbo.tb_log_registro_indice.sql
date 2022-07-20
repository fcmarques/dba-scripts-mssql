SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tb_log_registro_indice](
	[cod_alteracao] [int] NOT NULL,
	[ind_inclusao] [char](1) COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL,
	[dat_inclusao] [datetime] NOT NULL,
	[num_tentativa_inclusao] [int] NOT NULL
) ON [PRIMARY]

GO
