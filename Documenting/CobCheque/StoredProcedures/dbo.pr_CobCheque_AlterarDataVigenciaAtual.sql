SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/* 
Descrição          : Stored Procedure para Alterar data da Vigência
Autor                : Fernando S. Jaconete
Data                 : 22/09/2006
Empresa           : B2Br
Projeto              : CobCheque
*/

CREATE proc dbo.pr_CobCheque_AlterarDataVigenciaAtual

	 @cod_empresa		int	
	,@cod_filial		int
	,@DataInicioVigencia	smalldatetime
	,@DataFimVigencia	smalldatetime
	

as
set nocount on

update 
	tb_cobch_desconto 
set 
	dat_vigencia_final = @DataFimVigencia
where
	dat_vigencia_inicial 	= @DataInicioVigencia
and	cod_filial 		= @cod_filial
and	cod_empresa		= @cod_empresa

set nocount off


GO
