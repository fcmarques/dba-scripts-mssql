ALTER PROCEDURE [dbo].[pr_gera_estoque_balanco_parcial]
AS    
BEGIN  
  
	SET NOCOUNT ON  
    
	PRINT '*************************************************************'    
	PRINT '*** INÍCIO DA EXECUÇÃO - pr_gera_estoque_balanco_parcial'    
	PRINT '*** ' + CONVERT(VARCHAR, GETDATE(), 114) + ''  
	PRINT '*************************************************************'    
  
	-- Cria variváveis  
	DECLARE @ZCOD_FIL			VARCHAR(4),   
			@ZCOD_DEPTO			VARCHAR(3),   
			@ZF_DATA_BAL_ATU    VARCHAR(8)     
  
	-- Cria tabelas Temporárias  
	DECLARE @Tabela_Filial  TABLE (codigo_loja VARCHAR (4))    
	DECLARE @Tabela_Depto   TABLE (codigo_loja VARCHAR (4), codigo_depto VARCHAR (3), codigo_grupo VARCHAR (1))    
	DECLARE @Tabela_Estoque TABLE (codigo_loja VARCHAR (4), codigo_produto VARCHAR (18), tipo_material VARCHAR(2), depto VARCHAR (3), qtde decimal (9,0), codigo_area VARCHAR(4))  
  
	-- Alimenta tabela temporária de lojas para a geração do arquivo de estoque -   
	-- Verifica as lojas a serem processadas  
	INSERT	INTO @Tabela_Filial  
	SELECT	ZCOD_FIL  
	FROM	ZWMTB004  
	WHERE	ZFLAG_PROC_R = '' AND   
			ZFLAG_ATIVO_R = '' AND  
			ZPARC = 'X'  
	ORDER BY ZDT_SOLI ASC,   
			 ZHR_SOLI ASC,  
			 ZCOD_FIL ASC  

	-- Alimenta tabela temporária de DEPTOS para a geração do arquivo de estoque  
	-- Verifica os deptos a serem processados  
	INSERT	INTO @Tabela_Depto  
	SELECT	ZF_WERKS,  
			ZF_DEPTO,  
			CASE  
				WHEN ZF_DEPTO IN (SELECT ZCOD_DEPTO FROM ZWMTB006) THEN (SELECT ZCOD_GRUPO FROM ZWMTB006 WHERE ZCOD_DEPTO = ZF_DEPTO)  
				WHEN ZF_DEPTO NOT IN (SELECT ZCOD_DEPTO FROM ZWMTB006) THEN LEFT(ZF_DEPTO, 1)  
			END  
	FROM	ZWMTB003  
	WHERE	ZF_WERKS IN (SELECT codigo_loja FROM @Tabela_Filial)  
	ORDER BY ZF_WERKS, ZF_DEPTO   

	-- Limpa a tabela ZWMTB092 para compor o arquivo  
	PRINT '*** ' + CONVERT(VARCHAR, GETDATE(), 114) + ' *** Limpando a tabela ZWMTB092 ***'    
	DELETE FROM ZWMTB092  

	/*------------------------------------  
	CURSOR PARA VARRER AS FILIAIS  
	*/------------------------------------   

	DECLARE cursor_filial CURSOR  
	FOR SELECT codigo_loja FROM @Tabela_Filial ORDER BY codigo_loja  

	OPEN cursor_filial  
	FETCH NEXT FROM cursor_filial INTO @ZCOD_FIL  

	PRINT '*** ' + CONVERT(VARCHAR, GETDATE(), 114) + ' *** Varrendo o cursor para verificar as filiais que precisam compor o estoque ***'    
	WHILE (@@FETCH_STATUS = 0)  
	BEGIN  

		PRINT '*************************************************************'    
		PRINT '*** ' + CONVERT(VARCHAR, GETDATE(), 114) + ''  
		PRINT '*** Filial a ser processada: ' + @ZCOD_FIL + ''  
		PRINT '*************************************************************'  

		SET @ZCOD_DEPTO = (SELECT TOP 1 codigo_depto FROM @Tabela_Depto WHERE codigo_loja = @ZCOD_FIL)  
		PRINT '*** ' + CONVERT(VARCHAR, GETDATE(), 114) + ' *** Departamento a ser processado: ' + @ZCOD_DEPTO + ' ***'    

		PRINT '*** ' + CONVERT(VARCHAR, GETDATE(), 114) + ' *** Selecionando datas de balanço ***'    
		SELECT	
			@ZF_DATA_BAL_ATU = ZF_DATA_BAL_ATU     
		FROM	
			ZWMTB003 WITH(NOLOCK)    
		WHERE	
			(ZF_WERKS = @ZCOD_FIL) AND  
			(ZF_DEPTO = @ZCOD_DEPTO)  

		PRINT '*** ' + CONVERT(VARCHAR, GETDATE(), 114) + ' *** Limpa o repositório temporário @Tabela_Estoque ***'      
		DELETE   
		FROM	@Tabela_Estoque    

		PRINT '*** ' + CONVERT(VARCHAR, GETDATE(), 114) + ' *** Inserindo dados na tabela @Tabela_Estoque ***'    
		INSERT INTO @Tabela_Estoque    
		SELECT
			s.WERKS,
            m.MATNR,
            m.ATTYP,
            LEFT(m.MATKL, 3),
            CASE
				WHEN s.SHKZG = 'S' THEN sum(s.MENGE)
                WHEN s.SHKZG = 'H' THEN sum(-s.MENGE)
			END SHKZG,
            s.LGORT
            FROM 
				((MARA m (NOLOCK) INNER JOIN MSEG s (NOLOCK) ON  s.MANDT = '200' and s.MATNR = m.MATNR and s.WERKS = @ZCOD_FIL AND
				s.LGORT in ('V001', 'V002', 'V003')) left join MKPF f (NOLOCK) on
                f.MANDT = '200' and f.MBLNR = s.MBLNR and f.MJAHR = s.MJAHR )
			WHERE 
				m.MANDT = '200' AND
				m.MATKL between @ZCOD_DEPTO + '000' and @ZCOD_DEPTO + '999' AND
                m.MTART IN ('ZHAW', 'ZIMP') AND
                m.ATTYP IN ('00', '02') AND
                f.BUDAT <= @ZF_DATA_BAL_ATU
			GROUP BY
				m.MATNR , m.MATKL, m.ATTYP, s.WERKS, SHKZG, s.LGORT
            ORDER BY 
				m.MATNR 

		PRINT '*** ' + CONVERT(VARCHAR, GETDATE(), 114) + ' *** Inserindo dados na tabela ZWMTB092 ***'    
		INSERT INTO ZWMTB092  
		SELECT 
			'200',
			t.codigo_loja,
			CASE
				WHEN t.tipo_material = '00' THEN right(t.codigo_produto, 7) + '000'
				WHEN t.tipo_material = '02' THEN right(t.codigo_produto, 10)
			END,
			t.depto,
			t.codigo_area,
			case
				WHEN t.depto in (select ZCOD_DEPTO from ZWMTB006 (NOLOCK)) THEN (select ZCOD_GRUPO from ZWMTB006 (NOLOCK) where ZCOD_DEPTO = t.depto)
				WHEN t.depto not in (select ZCOD_DEPTO from ZWMTB006 (NOLOCK)) THEN left(t.depto, 1)
			end,
			sum(t.qtde) as saldo,
			z.ZF_DATA_BAL_ATU
		from 
			@Tabela_Estoque t inner join ZWMTB003 z (NOLOCK) on t.depto = z.ZF_DEPTO
		where 
			ZF_WERKS = t.codigo_loja
		group by 
			t.codigo_loja,
			t.depto,
			t.codigo_produto,
			t.tipo_material,
			t.codigo_area,
			z.ZF_DATA_BAL_ATU
		order by 
			t.codigo_loja,
			t.depto,
			t.codigo_produto,
			t.tipo_material,
			t.codigo_area,
			z.ZF_DATA_BAL_ATU  

		PRINT '*** ' + CONVERT(VARCHAR, GETDATE(), 114) + ' *** Marca solicitação como processada ***'    
		UPDATE	
			ZWMTB004  
		SET		
			ZFLAG_PROC_R = 'X'  
		WHERE	
			ZCOD_FIL = @ZCOD_FIL AND   
			ZPARC = 'X'
		
		UPDATE R3P..ZWMTB092
	    SET ZQTD = 0.000
	    WHERE 1=1
	    and ZCOD_FIL = @ZCOD_FIL
	    and(
		     (left(ZMATERIAL, 10) between '1220209000' and '1997360999')
			  or (left(ZMATERIAL, 10) between '1220209000' and '1997360999')
			  or (left(ZMATERIAL, 10) between '2001276000' and '2999951999')
			  or (left(ZMATERIAL, 10) between '3000052000' and '3999998999') 
			  or (left(ZMATERIAL, 10) between '4000005000' and '4569768999') 
			  or (left(ZMATERIAL, 10) between '8025410000' and '8040001999') 
			  or (left(ZMATERIAL, 10) between '9104569000' and '9724370999'))

		FETCH NEXT FROM cursor_filial INTO @ZCOD_FIL  
	END  

	CLOSE cursor_filial  
	DEALLOCATE cursor_filial  

	PRINT '*************************************************************'    
	PRINT '*** FIM DA EXECUÇÃO'    
	PRINT '*** ' + CONVERT(VARCHAR, GETDATE(), 114) + ''    
	PRINT '*************************************************************'

END
