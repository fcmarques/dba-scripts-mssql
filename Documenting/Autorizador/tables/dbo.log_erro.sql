SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[log_erro](
	[data_hora] [char](16) COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[num_caixa] [char](3) COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[cod_cliente] [char](11) COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[txt_registro] [char](255) COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL,
	[dat_ocor] [datetime] NULL,
	[cod_erro] [int] NOT NULL
) ON [PRIMARY]

GO
