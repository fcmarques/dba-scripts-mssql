SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TBCPF_VISAOFINAL](
	[cod_empresa] [int] NOT NULL,
	[cod_filial] [int] NOT NULL,
	[cod_cliente] [int] NOT NULL,
	[num_cpf] [decimal](11, 0) NOT NULL
) ON [PRIMARY]

GO
