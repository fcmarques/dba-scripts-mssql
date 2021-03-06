SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
Descrição	: Lista vicencias de encargo por filial
Autor		: Alex Fornazaro
Data		: 14/09/2006
Empresa		: B2Br
Projeto		: SICC New
*/

create procedure dbo.pr_CobCheque_ListarVigenciasEncargoPorFilial(
	@cod_empresa	int,
	@cod_filial	int
)
as
set nocount on
	select cod_empresa, cod_filial, dat_vigencia_inicial, dat_vigencia_final
	from tb_cobch_encargo (nolock)
	where cod_empresa = @cod_empresa and cod_filial = @cod_filial
	group by cod_empresa, cod_filial, dat_vigencia_inicial, dat_vigencia_final
	order by cod_filial

set nocount off



GO
