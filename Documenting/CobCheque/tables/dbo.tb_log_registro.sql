SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tb_log_registro](
	[cod_alteracao] [int] IDENTITY(1,1) NOT NULL,
	[cod_tipo_registro] [int] NOT NULL,
	[dat_inclusao] [datetime] NOT NULL,
	[cod_fil_alteracao] [int] NOT NULL,
	[cod_usuario] [int] NOT NULL,
	[txt_registro_log] [varchar](511) COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL,
	[txt_registro_log_detalhe] [varchar](2047) COLLATE SQL_Latin1_General_CP850_CI_AI NULL
) ON [PRIMARY]

GO
