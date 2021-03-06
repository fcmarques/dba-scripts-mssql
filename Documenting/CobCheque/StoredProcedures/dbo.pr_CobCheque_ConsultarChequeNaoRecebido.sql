SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
Descrição	: Obtem autorizações que foram processadas no dia para o cliente selecionado
Autor		: Alex Fornazaro
Data		: 14/09/2006
Empresa		: B2Br
Projeto		: SICC New
*/

create procedure dbo.pr_CobCheque_ConsultarChequeNaoRecebido(
	@cod_loja 	int = NULL
)
as
set nocount on
	SELECT 
			T0.num_cheque
			,T0.num_cpf
			,T0.cod_motivo_devolucao
			,T0.num_conta
			,T0.num_agencia
			,T0.cod_banco
			,T0.val_cheque
			,T0.val_cheque_dinamico
			,T0.num_cupom
			,T0.cod_loja
			,T0.dat_movimento
			,T0.dat_importacao
			,T0.dat_lucros_perdas
			,T0.dat_recebido_filial
			,T0.dat_enviado_filial
		FROM dbo.tb_cobch_cheque T0 (NOLOCK)
		WHERE (@COD_LOJA IS NULL OR COD_LOJA = @COD_LOJA)
			and dat_recebido_filial is null
		ORDER BY cod_loja asc, dat_enviado_filial
			
set nocount off


GO
