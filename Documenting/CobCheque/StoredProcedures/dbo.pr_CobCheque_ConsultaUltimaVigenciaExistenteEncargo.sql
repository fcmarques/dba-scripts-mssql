SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/* 
Descrição          : Consulta a data Final da ultima vigencia existente para validar inclusão
Autor                : Fernando
Data                 : 26/09/2006
Empresa           : B2Br
Projeto              : CobCheque
*/

CREATE proc dbo.pr_CobCheque_ConsultaUltimaVigenciaExistenteEncargo     
(
@cod_empresa int, 
@cod_filial int
)
as    
set nocount on     
Select     
	max(dat_vigencia_final) as ultimaVigencia
from     
	tb_cobch_encargo(nolock)  
where    
	cod_empresa = @cod_empresa and
	cod_filial = @cod_filial
set nocount off    



GO
