SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
Descrição	: Obtém descontos por dia de atraso.
Autor		: Alex Fornazaro
Data		: 14/09/2006
Empresa		: B2Br
Projeto		: SICC New
*/

create procedure dbo.pr_CobCheque_ObterDescontoPorDiasDeAtraso(
	@cod_filial		int,
	@data_atual		datetime,
	@dias_de_atraso		int
)
as
set nocount on
	SELECT [cod_empresa], 
	[cod_filial], 
	[dat_vigencia_inicial], 
	[dat_vigencia_final], 
	[num_dias_de], 
	[num_dias_ate], 
	[pct_principal], 
	[pct_encargo], 
	[nom_login_responsavel], 
	[dat_atualizacao] 
	FROM [CobCheque].[dbo].[tb_cobch_desconto] (nolock)
	WHERE	cod_filial = @cod_filial
		and (dat_vigencia_inicial <= @data_atual and dat_vigencia_final >= @data_atual)
		and (num_dias_de <= @dias_de_atraso and num_dias_ate>=@dias_de_atraso)
set nocount off


GO
