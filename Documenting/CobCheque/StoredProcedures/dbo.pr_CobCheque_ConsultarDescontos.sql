SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/* 
Descrição	: Consulta Descontos
Autor		: Alex Fornazaro
Data		: 14/09/2006
Empresa		: B2Br
Projeto		: SICC New
*/

create procedure dbo.pr_CobCheque_ConsultarDescontos(
	@cod_empresa 		int,
	@cod_loja 		int,
	@dat_inicio_vigencia 	datetime,
	@dat_fim_vigencia	datetime)
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
	where cod_empresa = @cod_empresa 
	and cod_filial = @cod_loja 
	and dat_vigencia_inicial = @dat_inicio_vigencia 
	and dat_vigencia_final = @dat_fim_vigencia
set nocount off


GO
