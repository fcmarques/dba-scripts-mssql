SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
Descrição	: Inclui dados cadastrais de cheque
Autor		: Alex Fornazaro
Data		: 14/09/2006
Empresa		: B2Br
Projeto		: SICC New
*/

create procedure dbo.pr_CobCheque_IncluirCadastroCheque(
	@num_cheque		varchar(20), 
	@num_cpf		decimal(15,0), 
	@cod_motivo_devolucao	decimal(5,0), 
	@num_conta		varchar(20), 
	@num_agencia		varchar(20), 
	@cod_banco		decimal(5,0), 
	@val_cheque		decimal(12,2), 
	@val_cheque_dinamico	decimal(12,2), 
	@num_cupom		decimal(10,0), 
	@cod_loja		int, 
	@dat_movimento		datetime, 
	@dat_importacao		datetime, 
	@dat_lucros_perdas	datetime, 
	@dat_recebido_filial	datetime, 
	@dat_enviado_filial	datetime
)
as
set nocount on
	INSERT INTO [CobCheque].[dbo].[tb_cobch_cheque]
	([num_cheque], 
	[num_cpf], 
	[cod_motivo_devolucao], 
	[num_conta], 
	[num_agencia], 
	[cod_banco], 
	[val_cheque], 
	[val_cheque_dinamico], 
	[num_cupom], 
	[cod_loja], 
	[dat_movimento], 
	[dat_importacao], 
	[dat_lucros_perdas], 
	[dat_recebido_filial], 
	[dat_enviado_filial])
	VALUES
	(
	@num_cheque	,
	@num_cpf	,
	@cod_motivo_devolucao	,
	@num_conta	,
	@num_agencia	,
	@cod_banco	,
	@val_cheque	,
	@val_cheque_dinamico	,
	@num_cupom	,
	@cod_loja	,
	@dat_movimento	,
	@dat_importacao	,
	@dat_lucros_perdas	,
	@dat_recebido_filial	,
	@dat_enviado_filial	
	)
set nocount off


GO
