UPDATE EVOLUCAO
SET    EVOLUCAO.PAC_ID = PACIENTE_CARDIO.PAC_ID
FROM   EVOLUCAO INNER JOIN
       PACIENTE_CARDIO ON EVOLUCAO.RG_PACIENTE = PACIENTE_CARDIO.PAC_RG AND 
			  EVOLUCAO.RG_DIGITO_CHECK = PACIENTE_CARDIO.PAC_RG_DIGITO


UPDATE EVOLUCAO
SET    EVOLUCAO.PAC_ID = EVOLUCAO_ELETRONICA.PAC_ID
FROM   EVOLUCAO INNER JOIN
       PACIENTE_CARDIO ON EVOLUCAO.RG_PACIENTE = PACIENTE_CARDIO.PAC_RG AND 
			  EVOLUCAO.RG_DIGITO_CHECK = PACIENTE_CARDIO.PAC_RG_DIGITO
