SET ANSI_NULLS OFF
SET QUOTED_IDENTIFIER OFF


CREATE  PROCEDURE ConsultaCliente
(
@nome varchar(60)
)
 AS

select	*
from	tb_cobch_cliente


GO
