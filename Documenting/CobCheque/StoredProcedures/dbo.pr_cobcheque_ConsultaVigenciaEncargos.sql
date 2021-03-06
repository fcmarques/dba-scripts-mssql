SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
Descrição	: Consulta Vigencias de Encargos
Autor		: Alex Fornazaro
Data		: 14/09/2006
Empresa		: B2Br
Projeto		: SICC New
*/

create proc dbo.pr_cobcheque_ConsultaVigenciaEncargos

	 @cod_Empresa	int
	,@cod_filial	int
as

set nocount on

select	cod_empresa,
	cod_filial,
	dat_vigencia_inicial,
	dat_vigencia_final,
	num_dias_de,
	num_dias_ate,
	pct_encargo,
	nom_login_responsavel,
	dat_atualizacao
	
	from dbo.tb_cobch_encargo (nolock)
	
	where 
	cod_empresa = @cod_empresa
	and cod_filial = @cod_filial

set nocount off


GO
