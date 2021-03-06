SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON



/* 
Descri¦Êo          : Stored Procedure para consultar lista de cheques pendentes
Autor                : Fernando S. Jaconete
Data                 : 22/09/2006
Empresa           : B2Br
Projeto              : CobCheque
*/
-- TRANSFERIDO EM 24/01/2007 10:20:49
CREATE   PROC dbo.pr_CobCheque_ConsultaListaChequesPendentes
(
@cpf numeric(15)
)
as
set nocount on

select 	a.num_cheque, 
	a.num_cpf, 
	a.cod_motivo_devolucao, 
	b.desc_motivo_devolucao,
	a.num_conta, 
	a.num_agencia, 
	a.cod_banco, 
	a.val_cheque, 
	a.val_cheque_dinamico, 
	a.num_cupom, 
	a.cod_loja, 
	a.dat_movimento, 
	a.dat_importacao, 
	a.dat_lucros_perdas, 
	a.dat_recebido_filial, 
	a.dat_enviado_filial,
	c.cod_emp,
	c.cod_fil,
	c.nom_fantasia
from tb_cobch_cheque a (nolock), tb_cobch_motivo_devolucao b (nolock), sicc.dbo.c_empresa_filial c (nolock)
where a.cod_motivo_devolucao = b.cod_motivo_devolucao
and a.cod_loja = c.cod_fil
and num_cpf = @cpf
and val_cheque_dinamico > 0 

set nocount off







GO
