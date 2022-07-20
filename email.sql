declare @query nvarchar(200)
SET @query = 'select FLAG_CONVERSAO_MOVIMENTO_ATIVO from sicc..TB_BAND_CONVERSAO_MOVIMENTOS_PARAMETROS' 
EXEC master..pr_sendmail @recipients='danielc@riachuelo.com.br',            
                          @message='SDM139110',            
                          
use sicc

select FLAG_CONVERSAO_MOVIMENTO_ATIVO from sicc..TB_BAND_CONVERSAO_MOVIMENTOS_PARAMETROS



STR_EXTRATO_0045 

sp_helptext pr_sendmail