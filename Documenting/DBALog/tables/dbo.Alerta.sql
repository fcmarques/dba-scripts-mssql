SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Alerta](
	[Id_Alerta] [int] IDENTITY(1,1) NOT NULL,
	[Nm_Alerta] [varchar](200) COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[Ds_Mensagem] [varchar](2000) COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[Fl_Tipo] [tinyint] NULL,
	[Dt_Alerta] [datetime] NULL
) ON [PRIMARY]

GO
