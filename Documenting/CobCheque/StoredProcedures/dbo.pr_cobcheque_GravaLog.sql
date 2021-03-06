SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
Descrição	: Stored Procedure para gravar LOG do CobCheque
Autor		: Jeovane Goes Maciel
Data		: 31/08/2006
Empresa		: B2Br
Projeto		: SICC New / cobcheque
*/

create procedure dbo.pr_cobcheque_GravaLog(
	@cod_tipo_registro int
	,@dat_inclusao datetime
	,@cod_fil_alteracao int
	,@cod_usuario int
	,@txt_registro_log varchar(511)
	,@txt_registro_log_detalhe varchar(2047)
)
as

	--// insere o registro no log
begin tran
	insert into tb_log_registro(
		cod_tipo_registro
		,dat_inclusao
		,cod_fil_alteracao
		,cod_usuario
		,txt_registro_log
		,txt_registro_log_detalhe
	)values(
		@cod_tipo_registro
		,@dat_inclusao
		,@cod_fil_alteracao
		,@cod_usuario
		,@txt_registro_log
		,@txt_registro_log_detalhe
	)

	--// recupera o ID inserido
	declare @cod_alteracao int
	SELECT @cod_alteracao = SCOPE_IDENTITY()
	print @cod_alteracao

	--// insere o registro no indice
	insert into tb_log_registro_indice(
		cod_alteracao
		,ind_inclusao
		,dat_inclusao
		,num_tentativa_inclusao
	)values(
		@cod_alteracao
		,''
		,@dat_inclusao
		,0
	)

if @@error > 0
	rollback tran
else
	commit tran


GO
