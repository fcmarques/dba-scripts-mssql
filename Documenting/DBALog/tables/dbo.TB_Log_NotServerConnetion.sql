SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TB_Log_NotServerConnetion](
	[Identificador] [int] IDENTITY(1,1) NOT NULL,
	[Servidor] [varchar](100) COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[Host] [varchar](100) COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[Login] [varchar](100) COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[Aplicacao] [nvarchar](300) COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[Horario] [datetime] NULL,
	[SPID] [int] NULL
) ON [PRIMARY]

GO
