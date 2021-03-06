SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
/* 
DescriþÒo          : Incluir na base de dados um arquivo texto gerado pelo SAP dos cheques 
		     que foram lanþados para lucros e perdas
Autor              : Fabio Luiz Paranhos Borelli
Data               : 12/03/2007
Empresa            : Riachuelo
Projeto            : CobCheque
*/
-- TRANSFERIDO EM 21/03/2007 09:51:00
CREATE  PROCEDURE [dbo].[pr_CobCheque_IncluirLucrosPerdasSAP]

@caminho nvarchar(1000)

AS

declare @comando nvarchar(1000)

/*
** Carrega arquivo texto
*/
set @comando = 'BULK INSERT CobCheque.dbo.[tb_cobch_lucros_perdas] FROM ''' + @caminho + ''' WITH (FIELDTERMINATOR = ''|'')'
execute sp_executesql @comando

/*
** Atualiza as datas de lucros e perdas
*/
execute dbo.pr_CobCheque_LancarLucrosPerdasSAP


GO
