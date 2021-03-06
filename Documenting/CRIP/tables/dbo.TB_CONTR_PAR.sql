SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TB_CONTR_PAR](
	[NUM_CPF] [decimal](15, 0) NULL,
	[cod_empresa] [int] NOT NULL,
	[cod_filial] [int] NOT NULL,
	[cod_cliente] [int] NOT NULL,
	[cod_produto] [int] NOT NULL,
	[cod_adesao] [int] NOT NULL,
	[dat_liberacao] [datetime] NOT NULL,
	[cod_contrato] [int] NULL,
	[num_parcela] [int] NULL,
	[dat_vencimento] [datetime] NULL,
	[val_parcela] [money] NULL,
	[flg_quitada] [bit] NULL,
	[cod_consolidado_quitada] [bigint] NULL,
	[cod_consolidado_estornada] [bigint] NULL,
	[COD_RECEBIMENTO_SIPF] [int] NULL,
	[COD_STATUS_PARCELA_SIPF] [int] NULL,
	[TXT_DSCR_STATUS_PARCELA] [nvarchar](50) COLLATE SQL_Latin1_General_CP850_CI_AI NULL,
	[DAT_VENCTO_SIPF] [datetime] NULL,
	[DAT_PGTO_SIPF] [datetime] NULL,
	[VAL_PARCELA_SIPF] [float] NULL,
	[VAL_PAGO_SIPF] [float] NULL,
	[VAL_JUROS_SIPF] [float] NULL,
	[VAL_MULTA_SIPF] [float] NULL,
	[VAL_DESCONTO_SIPF] [float] NULL
) ON [PRIMARY]

GO
