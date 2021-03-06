SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
Descrição	: Obter vigencia por filial
Autor		: Alex Fornazaro
Data		: 14/09/2006
Empresa		: B2Br
Projeto		: SICC New
*/

create procedure dbo.pr_CobCheque_ObterVigencia(
	@cod_empresa		int,
	@cod_filial		int,
	@dat_inicio_vigencia	Datetime
)
as
set nocount on
	select top 1 cod_empresa, cod_filial, dat_vigencia_inicial, dat_vigencia_final
	from dbo.tb_cobch_desconto  (nolock)
	where cod_empresa = @cod_empresa 
		and cod_filial = @cod_filial 
		and dat_vigencia_inicial = @dat_inicio_vigencia
set nocount off


GO
