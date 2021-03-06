SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[log_trans](
	[data_hora] [char](16) COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL,
	[num_caixa] [char](3) COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL,
	[cod_cliente] [char](11) COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL,
	[txt_registro] [char](255) COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL,
	[dat_incl] [datetime] NULL
) ON [PRIMARY]

GO
