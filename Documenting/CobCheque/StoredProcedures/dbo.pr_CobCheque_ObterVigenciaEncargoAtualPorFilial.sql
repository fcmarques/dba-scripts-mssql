SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
Descrição	: Obtem vigencia atual de encargo por filial
Autor		: Alex Fornazaro
Data		: 14/09/2006
Empresa		: B2Br
Projeto		: SICC New
*/

create procedure dbo.pr_CobCheque_ObterVigenciaEncargoAtualPorFilial(
	@cod_empresa		int = null,
	@cod_filial		int,
	@dias_atraso		int = null
)
as
set nocount on
	select 
		cod_empresa, 
		cod_filial, 
		dat_vigencia_inicial, 
		dat_vigencia_final,
		num_dias_de,
		num_dias_ate,
		pct_encargo
	from dbo.tb_cobch_encargo (nolock)
	where 
		(cod_empresa = @cod_empresa or @cod_empresa is null)
		and cod_filial = @cod_filial 
 		and dat_vigencia_inicial <= GetDate()
 		and dat_vigencia_final >= GetDate()
 		and (@dias_atraso is null or num_dias_de <= @dias_atraso)
 		and (@dias_atraso is null or num_dias_ate >= @dias_atraso)
set nocount off


GO
