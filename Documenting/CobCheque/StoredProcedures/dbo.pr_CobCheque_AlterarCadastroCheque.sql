SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
Descrição          : Stored Procedure para Alterar Cadastro Cheque
Autor                : Fernando S. Jaconete
Data                 : 22/09/2006
Empresa           : B2Br
Projeto              : CobCheque
*/

create procedure dbo.pr_CobCheque_AlterarCadastroCheque(
	@num_cpf		decimal(15,0),
	@num_cheque		varchar(20),	
	@cod_motivo_devolucao	decimal(5,0),
	@num_conta		varchar(20),
	@num_agencia		varchar(20),
	@cod_banco		decimal(5,0),
	@val_cheque		decimal(12,2),
	@val_cheque_dinamico	decimal(12,2),
	@num_cupom 		decimal(10,0),
	@cod_loja		int,
	@dat_movimento		datetime,
	@dat_importacao		datetime,
	@dat_lucros_perdas	datetime,
	@dat_recebido_filial	datetime,
	@dat_enviado_filial	datetime
)
as
	UPDATE 	[CobCheque].[dbo].[tb_cobch_cheque]
	SET 	
		[cod_motivo_devolucao]=	@cod_motivo_devolucao, 
		[num_conta]=		@num_conta, 
		[num_agencia]=		@num_agencia, 
		[cod_banco]=		@cod_banco, 
		[val_cheque]=		@val_cheque, 
		[val_cheque_dinamico]=	@val_cheque_dinamico, 
		[num_cupom]=		@num_cupom, 
		[cod_loja]=		@cod_loja, 
		[dat_movimento]=	@dat_movimento, 
		[dat_importacao]=	@dat_importacao, 
		[dat_lucros_perdas]=	@dat_lucros_perdas, 
		[dat_recebido_filial]=	@dat_recebido_filial, 
		[dat_enviado_filial]=	@dat_enviado_filial
	WHERE 	num_cpf = @num_cpf
		and num_cheque = @num_cheque


GO
