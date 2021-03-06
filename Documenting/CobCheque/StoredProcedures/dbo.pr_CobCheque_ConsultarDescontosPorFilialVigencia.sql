SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/* 
Descrição	: Consulta descontos filtrando filial e vigencia
Autor		: Alex Fornazaro
Data		: 14/09/2006
Empresa		: B2Br
Projeto		: SICC New
*/
create procedure dbo.pr_CobCheque_ConsultarDescontosPorFilialVigencia(
	@cod_empresa 		int = null,
	@cod_loja 		int,
	@dat_inicio_vigencia 	datetime,
	@dat_fim_vigencia	datetime = null,
	@num_dias_de		int = null,
	@num_dias_ate		int = null)
AS
set nocount on
	SELECT 	cod_empresa, 
		cod_filial, 
		dat_vigencia_inicial, 
		dat_vigencia_final, 
		num_dias_de, 
		num_dias_ate, 
		pct_principal, 
		pct_encargo, 
		nom_login_responsavel, 
		dat_atualizacao
	FROM dbo.tb_cobch_desconto (nolock)
	where  	cod_filial = @cod_loja 
		and dat_vigencia_inicial = @dat_inicio_vigencia 
		and (@cod_empresa is null or cod_empresa = @cod_empresa)
		and (@dat_fim_vigencia is null or dat_vigencia_final = @dat_fim_vigencia)
		and (@num_dias_de is null or num_dias_de = @num_dias_de)
		and (@num_dias_ate is null or num_dias_ate = @num_dias_ate)
set nocount off


GO
