SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
Descrição	: Inclui dados de Autorização Pendente
Autor		: Alex Fornazaro
Data		: 14/09/2006
Empresa		: B2Br
Projeto		: SICC New
*/

CREATE procedure dbo.pr_CobCheque_IncluirAutorizacaoPendente(
		@num_cpf		decimal(15,0) ,		
		@val_cheque		decimal(12,2) ,
		@val_encargo		decimal(12,2) ,
		@val_desconto		decimal(12,2) ,
		@val_total		decimal(12,2) ,		
		@cod_filial_requisicao	int ,
		@nom_login_requisicao	varchar(15) ,
		@dat_requisicao	datetime
)
as

SET NOCOUNT ON
	INSERT INTO [CobCheque].[dbo].[tb_cobch_autorizacao]
		([num_cpf], 
		[val_cheque], 
		[val_encargo], 
		[val_desconto], 
		[val_total], 		
		[cod_filial_requisicao], 
		[nom_login_requisicao], 
		[dat_requisicao])
	VALUES (@num_cpf ,		
		@val_cheque ,
		@val_encargo ,
		@val_desconto ,
		@val_total ,		
		@cod_filial_requisicao ,
		@nom_login_requisicao ,
		@dat_requisicao)

SET NOCOUNT OFF
	SELECT @@IDENTITY 


GO
