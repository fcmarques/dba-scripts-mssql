SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
Descrição          : Stored Procedure para alterar dados da vigência
Autor                : Fernando S. Jaconete
Data                 : 22/09/2006
Empresa           : B2Br
Projeto              : CobCheque
*/

create procedure dbo.pr_CobCheque_AlterarVigencia(
	@cod_empresa			int,
	@cod_filial			int,
	@dat_vigencia_inicial_antiga	datetime,
	@dat_vigencia_final_antiga	datetime,
	@dat_vigencia_inicial		datetime,
	@dat_vigencia_final		datetime
)
as
set nocount on
	UPDATE tb_cobch_desconto
	set 	dat_vigencia_inicial = @dat_vigencia_inicial, 
		dat_vigencia_final = @dat_vigencia_final
	where	cod_empresa = @cod_empresa and 
		cod_filial = @cod_filial and 
		dat_vigencia_inicial = @dat_vigencia_inicial_antiga and
		dat_vigencia_final = @dat_vigencia_final_antiga
set nocount off


GO
