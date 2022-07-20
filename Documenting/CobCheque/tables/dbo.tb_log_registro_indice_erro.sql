SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tb_log_registro_indice_erro](
	[cod_alteracao] [int] NOT NULL,
	[dat_inclusao] [datetime] NOT NULL,
	[txt_origem_erro] [varchar](255) COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL,
	[txt_mensagem_erro] [varchar](255) COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL,
	[dat_erro] [datetime] NOT NULL
) ON [PRIMARY]

GO
