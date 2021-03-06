SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
Descrição	: Exclui uma unica Vigencia
Autor		: Alex Fornazaro
Data		: 14/09/2006
Empresa		: B2Br
Projeto		: SICC New
*/

Create proc dbo.pr_CobCheque_ExcluirDataVigenciaFutura
(
	 @cod_empresa		int	
	,@cod_filial		int
	,@DataInicioVigencia	smalldatetime
	,@DataFimVigencia	smalldatetime
	,@num_dias_de		int
	,@num_dias_ate		int
)	

as
set nocount on

delete from
	tb_cobch_desconto 
where
	dat_vigencia_inicial 	= @DataInicioVigencia
and	cod_filial 		= @cod_filial
and	cod_empresa		= @cod_empresa
and	num_dias_de		= @num_dias_de
and	num_dias_ate		= @num_dias_ate

set nocount off



GO
