SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tb_operacional_indice](
	[cod_operacional_indice] [bigint] IDENTITY(1,1) NOT NULL,
	[cod_empresa] [int] NOT NULL,
	[cod_filial] [int] NOT NULL,
	[cod_cliente] [int] NOT NULL,
	[num_cpf] [decimal](11, 0) NOT NULL,
	[cod_decendio] [int] NOT NULL,
	[cod_produto] [int] NOT NULL,
	[dat_operacao] [datetime] NOT NULL,
	[cod_filial_origem] [int] NOT NULL,
	[cod_tipo_movimento] [int] NOT NULL,
	[flg_finalizado] [bit] NOT NULL,
	[flg_erro] [bit] NOT NULL,
	[flg_processado] [bit] NOT NULL,
	[dat_inclusao] [datetime] NOT NULL,
	[num_chave_aux] [uniqueidentifier] NULL,
	[cod_tipo_cartao] [int] NOT NULL,
	[cod_rede_origem] [int] NOT NULL,
	[num_referencia] [varchar](23) COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[dat_liquidacao] [datetime] NULL,
	[IN_CART_CNBL_360] [char](1) COLLATE SQL_Latin1_General_CP850_CI_AI NOT NULL
) ON [PRIMARY]

GO
